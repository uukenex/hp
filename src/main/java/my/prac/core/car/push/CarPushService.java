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
import my.prac.core.car.dto.PushLogDto;
import my.prac.core.car.dto.PushSubDto;

/** 웹 푸시 구독 관리 및 발송 */
@Service("core.car.CarPushService")
public class CarPushService {

    private static final Logger logger = LoggerFactory.getLogger(CarPushService.class);

    private static final String CFG_PUB = "VAPID_PUBLIC";
    private static final String CFG_PRIV = "VAPID_PRIVATE";
    private static final String CFG_SUB = "VAPID_SUBJECT";
    private static final long WORK_NOTIFY_INTERVAL_MS = 6L * 60 * 60 * 1000;   // 같은 사용자 작업 알림 최소 간격(6시간)

    @Resource(name = "core.car.CarPushDAO")
    private CarPushDAO dao;

    private final Map<String, Long> lastWorkNotify = new ConcurrentHashMap<String, Long>();

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
        sendAsync(subs, "TEST", kakaoId, null, title, body, url);
        return subs.size();
    }

    /**
     * 사용자가 운송 데이터를 추가/수정해서 저장할 때 개발자(NOTIFY_LOGIN='Y')에게 "작업을 시작했습니다" 알림.
     * 같은 사용자에 대해 마지막 발송 후 6시간 이내에는 다시 보내지 않음 (서버 재기동 후에도 이력 기준으로 판단).
     */
    public void notifyWork(final CarUserDto user) {
        if (user == null || user.getKakaoId() == null) return;
        final String actorId = user.getKakaoId();
        final long now = System.currentTimeMillis();

        // 빠른 경로: 메모리에서 6시간 이내면 즉시 종료. 아니면 먼저 선점해 동시 저장 시 중복 발송 방지
        Long last = lastWorkNotify.get(actorId);
        if (last != null && now - last < WORK_NOTIFY_INTERVAL_MS) return;
        lastWorkNotify.put(actorId, now);

        final String name = user.getNickname() == null ? "사용자" : user.getNickname();
        executor.submit(new Runnable() {
            @Override
            public void run() {
                try {
                    // 서버 재기동 등으로 메모리가 비었어도 DB 발송 이력으로 6시간 확인
                    Double mins = dao.getMinutesSinceLast(actorId, "WORK");
                    if (mins != null && mins * 60 * 1000 < WORK_NOTIFY_INTERVAL_MS) return;

                    List<PushSubDto> subs = dao.getNotifySubs(actorId);
                    if (subs.isEmpty()) {
                        lastWorkNotify.remove(actorId);   // 받을 기기가 없으면 선점 해제
                        return;
                    }
                    sendAsync(subs, "WORK", actorId, name, "🚚 운송관리", name + "님이 작업을 시작했습니다", "list");
                } catch (Exception e) {
                    lastWorkNotify.remove(actorId);
                    logger.warn("작업 알림 실패", e);   // 알림 실패가 저장에 영향을 주지 않도록
                }
            }
        });
    }

    private void sendAsync(final List<PushSubDto> subs, final String type, final String actorKakaoId, final String actorName,
                           final String title, final String body, String url) {
        if (subs == null || subs.isEmpty()) return;
        final String payload = "{\"title\":" + json(title) + ",\"body\":" + json(body) + ",\"url\":" + json(url) + "}";
        executor.submit(new Runnable() {
            @Override
            public void run() {
                for (PushSubDto s : subs) {
                    PushLogDto log = new PushLogDto();
                    log.setType(type);
                    log.setTargetKakaoId(s.getKakaoId());
                    log.setSubId(s.getSubId());
                    log.setActorKakaoId(actorKakaoId);
                    log.setActorName(actorName);
                    log.setTitle(title);
                    log.setBody(body);
                    try {
                        int code = send(s, payload);
                        log.setHttpCode(code);
                        if (code == 404 || code == 410) {            // 만료/해지된 구독은 정리
                            dao.deleteByEndpoint(s.getEndpoint());
                            log.setResult("EXPIRED");
                            logger.info("만료된 푸시 구독 삭제 sub={}", s.getSubId());
                        } else if (code >= 200 && code < 300) {
                            log.setResult("OK");
                        } else {
                            log.setResult("FAIL");
                            log.setErrorMsg("HTTP " + code);
                            logger.warn("푸시 응답 code={} sub={}", code, s.getSubId());
                        }
                    } catch (Exception e) {
                        log.setResult("FAIL");
                        log.setErrorMsg(cut(e.getClass().getSimpleName() + ": " + e.getMessage(), 450));
                        logger.warn("푸시 발송 실패 sub={}", s.getSubId(), e);
                    }
                    saveLog(log);
                }
            }
        });
    }

    /** 이력 저장 실패가 발송 흐름에 영향을 주지 않도록 */
    private void saveLog(PushLogDto log) {
        try {
            // DB 문자셋이 이모지(4바이트 문자)를 저장하지 못해 깨지므로 제거 후 저장 (한글은 정상)
            log.setActorName(stripEmoji(log.getActorName()));
            log.setTitle(stripEmoji(log.getTitle()));
            log.setBody(stripEmoji(log.getBody()));
            log.setErrorMsg(stripEmoji(log.getErrorMsg()));
            dao.insertLog(log);
        } catch (Exception e) {
            logger.warn("푸시 이력 저장 실패", e);
        }
    }

    /** 서로게이트 쌍(이모지 등)을 제거하고 앞뒤 공백 정리 */
    private static String stripEmoji(String s) {
        if (s == null) return null;
        StringBuilder b = new StringBuilder(s.length());
        for (int i = 0; i < s.length(); i++) {
            char ch = s.charAt(i);
            if (Character.isSurrogate(ch)) continue;
            b.append(ch);
        }
        return b.toString().trim();
    }

    private static String cut(String s, int max) {
        return s != null && s.length() > max ? s.substring(0, max) : s;
    }

    /** 푸시 서버로 전송하고 HTTP 응답 코드를 반환 */
    private int send(PushSubDto s, String payload) throws Exception {
        ensureKeys();
        byte[] ua = WebPushCrypto.b64urlDecode(s.getP256dh());
        byte[] auth = WebPushCrypto.b64urlDecode(s.getAuth());
        byte[] body = WebPushCrypto.encrypt(payload.getBytes(StandardCharsets.UTF_8), ua, auth);

        HttpURLConnection c = (HttpURLConnection) new URL(s.getEndpoint()).openConnection();
        try {
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
            return c.getResponseCode();
        } finally {
            c.disconnect();
        }
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
