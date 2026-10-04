package my.prac.core.car.push;

import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.nio.charset.StandardCharsets;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.ThreadFactory;

import javax.annotation.Resource;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;

import my.prac.core.car.dao.CarPushDAO;
import my.prac.core.car.dto.CarUserDto;
import my.prac.core.car.dto.PushSubDto;

/** 웹 푸시 구독 관리 및 발송 */
@Service("core.car.CarPushService")
public class CarPushService {

    private static final Logger logger = LoggerFactory.getLogger(CarPushService.class);

    private static final String CFG_PUB = "VAPID_PUBLIC";
    private static final String CFG_PRIV = "VAPID_PRIVATE";
    private static final String CFG_SUB = "VAPID_SUBJECT";
    private static final long LOGIN_NOTIFY_INTERVAL_MS = 30L * 60 * 1000;   // 같은 사용자 로그인 알림 최소 간격

    @Resource(name = "core.car.CarPushDAO")
    private CarPushDAO dao;

    private final Map<String, Long> lastLoginNotify = new ConcurrentHashMap<String, Long>();

    private final ExecutorService executor = Executors.newSingleThreadExecutor(new ThreadFactory() {
        @Override
        public Thread newThread(Runnable r) {
            Thread t = new Thread(r, "car-push-sender");
            t.setDaemon(true);
            return t;
        }
    });

    private String pub, priv;

    // ===== 키 =====

    private synchronized void ensureKeys() throws Exception {
        if (pub != null && priv != null) return;
        String p = dao.getConfig(CFG_PUB), s = dao.getConfig(CFG_PRIV);
        if (p == null || s == null) {
            String[] k = WebPushCrypto.generateVapidKeys();
            dao.mergeConfig(CFG_PRIV, k[0]);
            dao.mergeConfig(CFG_PUB, k[1]);
            s = k[0];
            p = k[1];
            logger.info("VAPID 키 생성 완료");
        }
        priv = s;
        pub = p;
    }

    public String getPublicKey() throws Exception {
        ensureKeys();
        return pub;
    }

    /** VAPID subject: 사이트 https 주소 (없으면 기존 값 유지) */
    public void rememberOrigin(String origin) {
        if (origin == null || !origin.startsWith("https://")) return;
        try {
            if (!origin.equals(dao.getConfig(CFG_SUB))) dao.mergeConfig(CFG_SUB, origin);
        } catch (Exception e) {
            logger.warn("subject 저장 실패", e);
        }
    }

    private String subject() {
        String s = dao.getConfig(CFG_SUB);
        return s != null ? s : "https://localhost";
    }

    // ===== 구독 =====

    public void subscribe(String kakaoId, String endpoint, String p256dh, String auth, String userAgent) {
        PushSubDto d = new PushSubDto();
        d.setKakaoId(kakaoId);
        d.setEndpoint(endpoint);
        d.setP256dh(p256dh);
        d.setAuth(auth);
        d.setUserAgent(userAgent != null && userAgent.length() > 300 ? userAgent.substring(0, 300) : userAgent);
        dao.mergeSub(d);
    }

    public void unsubscribe(String endpoint) {
        dao.deleteByEndpoint(endpoint);
    }

    public int countSubs(String kakaoId) {
        return dao.getSubsByKakaoId(kakaoId).size();
    }

    // ===== 발송 =====

    /** 해당 사용자의 모든 기기로 발송(비동기). 대상 기기 수 반환 */
    public int sendToUser(String kakaoId, String title, String body, String url) {
        List<PushSubDto> subs = dao.getSubsByKakaoId(kakaoId);
        sendAsync(subs, title, body, url);
        return subs.size();
    }

    /** 사용자 로그인 시 개발자(NOTIFY_LOGIN='Y')에게 알림. 같은 사용자는 30분에 한 번만 */
    public void notifyLogin(CarUserDto user) {
        if (user == null || user.getKakaoId() == null) return;
        try {
            long now = System.currentTimeMillis();
            Long last = lastLoginNotify.get(user.getKakaoId());
            if (last != null && now - last < LOGIN_NOTIFY_INTERVAL_MS) return;

            List<PushSubDto> subs = dao.getLoginNotifySubs(user.getKakaoId());
            if (subs.isEmpty()) return;   // 수신 기기가 없으면 간격 기록도 하지 않음
            lastLoginNotify.put(user.getKakaoId(), now);

            String name = user.getNickname() == null ? "사용자" : user.getNickname();
            String time = new SimpleDateFormat("HH:mm").format(new Date(now));
            sendAsync(subs, "🚚 운송관리 로그인", name + "님이 로그인했습니다 (" + time + ")", "list");
        } catch (Exception e) {
            logger.warn("로그인 알림 실패", e);   // 알림 실패가 로그인에 영향을 주지 않도록
        }
    }

    private void sendAsync(final List<PushSubDto> subs, String title, String body, String url) {
        if (subs == null || subs.isEmpty()) return;
        final String payload = "{\"title\":" + json(title) + ",\"body\":" + json(body) + ",\"url\":" + json(url) + "}";
        executor.submit(new Runnable() {
            @Override
            public void run() {
                for (PushSubDto s : subs) {
                    try {
                        send(s, payload);
                    } catch (Exception e) {
                        logger.warn("푸시 발송 실패 sub={}", s.getSubId(), e);
                    }
                }
            }
        });
    }

    private void send(PushSubDto s, String payload) throws Exception {
        ensureKeys();
        byte[] ua = WebPushCrypto.b64urlDecode(s.getP256dh());
        byte[] auth = WebPushCrypto.b64urlDecode(s.getAuth());
        byte[] body = WebPushCrypto.encrypt(payload.getBytes(StandardCharsets.UTF_8), ua, auth);

        HttpURLConnection c = (HttpURLConnection) new URL(s.getEndpoint()).openConnection();
        c.setRequestMethod("POST");
        c.setConnectTimeout(10000);
        c.setReadTimeout(15000);
        c.setDoOutput(true);
        c.setRequestProperty("Content-Encoding", "aes128gcm");
        c.setRequestProperty("Content-Type", "application/octet-stream");
        c.setRequestProperty("TTL", "3600");
        c.setRequestProperty("Urgency", "high");
        c.setRequestProperty("Authorization", WebPushCrypto.vapidAuthHeader(s.getEndpoint(), subject(), priv, pub));
        c.setFixedLengthStreamingMode(body.length);
        OutputStream os = c.getOutputStream();
        try {
            os.write(body);
        } finally {
            os.close();
        }

        int code = c.getResponseCode();
        if (code == 404 || code == 410) {            // 만료/해지된 구독은 정리
            dao.deleteByEndpoint(s.getEndpoint());
            logger.info("만료된 푸시 구독 삭제 sub={}", s.getSubId());
        } else if (code < 200 || code >= 300) {
            logger.warn("푸시 응답 code={} sub={}", code, s.getSubId());
        }
        c.disconnect();
    }

    private static String json(String v) {
        if (v == null) return "null";
        StringBuilder b = new StringBuilder("\"");
        for (char ch : v.toCharArray()) {
            switch (ch) {
                case '"':  b.append("\\\""); break;
                case '\\': b.append("\\\\"); break;
                case '\n': b.append("\\n"); break;
                case '\r': b.append("\\r"); break;
                case '\t': b.append("\\t"); break;
                default:
                    if (ch < 0x20) b.append(String.format("\\u%04x", (int) ch));
                    else b.append(ch);
            }
        }
        return b.append('"').toString();
    }
}
