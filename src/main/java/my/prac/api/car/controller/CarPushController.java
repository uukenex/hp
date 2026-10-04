package my.prac.api.car.controller;

import java.awt.BasicStroke;
import java.awt.Color;
import java.awt.Graphics2D;
import java.awt.RenderingHints;
import java.awt.geom.Ellipse2D;
import java.awt.geom.RoundRectangle2D;
import java.awt.image.BufferedImage;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.util.HashMap;
import java.util.Map;

import javax.annotation.Resource;
import javax.imageio.ImageIO;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;

import my.prac.core.car.dto.CarUserDto;
import my.prac.core.car.push.CarPushService;

/** PWA(manifest / service worker / 아이콘) 및 웹 푸시 구독 API */
@Controller
@RequestMapping("/transport")
public class CarPushController {

    @Resource(name = "core.car.CarPushService")
    private CarPushService pushService;

    // ===== PWA 정적 리소스 (로그인 없이 접근 가능해야 함: CarSessionInterceptor 제외 대상) =====

    private static final String MANIFEST =
        "{\"name\":\"차량 운송 관리\",\"short_name\":\"운송관리\",\"start_url\":\"list\",\"scope\":\"./\","
        + "\"display\":\"standalone\",\"background_color\":\"#f5f7fa\",\"theme_color\":\"#1565c0\","
        + "\"icons\":[{\"src\":\"icon/192.png\",\"sizes\":\"192x192\",\"type\":\"image/png\",\"purpose\":\"any maskable\"},"
        + "{\"src\":\"icon/512.png\",\"sizes\":\"512x512\",\"type\":\"image/png\",\"purpose\":\"any maskable\"}]}";

    private static final String SERVICE_WORKER =
        "self.addEventListener('install', function(e){ self.skipWaiting(); });\n"
        + "self.addEventListener('activate', function(e){ e.waitUntil(self.clients.claim()); });\n"
        + "self.addEventListener('fetch', function(e){});\n"
        + "self.addEventListener('push', function(e) {\n"
        + "  var d = {};\n"
        + "  try { d = e.data.json(); } catch (x) { d = { title: '운송 관리', body: e.data ? e.data.text() : '' }; }\n"
        + "  e.waitUntil(self.registration.showNotification(d.title || '운송 관리', {\n"
        + "    body: d.body || '', icon: 'icon/192.png', badge: 'icon/192.png',\n"
        + "    tag: d.tag || 'transport', data: { url: d.url || 'list' }\n"
        + "  }));\n"
        + "});\n"
        + "self.addEventListener('notificationclick', function(e) {\n"
        + "  e.notification.close();\n"
        + "  var url = new URL((e.notification.data && e.notification.data.url) || 'list', self.registration.scope).href;\n"
        + "  e.waitUntil(self.clients.matchAll({ type: 'window', includeUncontrolled: true }).then(function(list) {\n"
        + "    for (var i = 0; i < list.length; i++) {\n"
        + "      if (list[i].url.indexOf(self.registration.scope) === 0 && 'focus' in list[i]) return list[i].focus();\n"
        + "    }\n"
        + "    return self.clients.openWindow(url);\n"
        + "  }));\n"
        + "});\n";

    @GetMapping("/manifest.json")
    public void manifest(HttpServletResponse res) throws IOException {
        write(res, "application/manifest+json;charset=UTF-8", MANIFEST.getBytes(StandardCharsets.UTF_8), false);
    }

    @GetMapping("/sw.js")
    public void serviceWorker(HttpServletResponse res) throws IOException {
        write(res, "application/javascript;charset=UTF-8", SERVICE_WORKER.getBytes(StandardCharsets.UTF_8), false);
    }

    @GetMapping("/icon/192.png")
    public void icon192(HttpServletResponse res) throws IOException {
        write(res, "image/png", icon(192), true);
    }

    @GetMapping("/icon/512.png")
    public void icon512(HttpServletResponse res) throws IOException {
        write(res, "image/png", icon(512), true);
    }

    private void write(HttpServletResponse res, String type, byte[] body, boolean cache) throws IOException {
        res.setContentType(type);
        res.setHeader("Cache-Control", cache ? "public, max-age=86400" : "no-cache");
        res.setContentLength(body.length);
        res.getOutputStream().write(body);
    }

    /** 파란 배경 + 흰색 트럭 아이콘 (폰트 의존 없이 도형으로만 그림) */
    private byte[] icon(int size) throws IOException {
        System.setProperty("java.awt.headless", "true");
        BufferedImage img = new BufferedImage(size, size, BufferedImage.TYPE_INT_ARGB);
        Graphics2D g = img.createGraphics();
        g.setRenderingHint(RenderingHints.KEY_ANTIALIASING, RenderingHints.VALUE_ANTIALIAS_ON);
        double u = size / 100.0;
        g.setColor(new Color(0x15, 0x65, 0xC0));
        g.fillRect(0, 0, size, size);                                   // maskable 대응: 가득 채움
        g.setColor(Color.WHITE);
        g.fill(new RoundRectangle2D.Double(18 * u, 32 * u, 40 * u, 28 * u, 4 * u, 4 * u));   // 적재함
        g.fill(new RoundRectangle2D.Double(61 * u, 42 * u, 22 * u, 18 * u, 4 * u, 4 * u));   // 운전석
        g.setColor(new Color(0x15, 0x65, 0xC0));
        g.fill(new Ellipse2D.Double(27 * u, 54 * u, 14 * u, 14 * u));
        g.fill(new Ellipse2D.Double(63 * u, 54 * u, 14 * u, 14 * u));
        g.setColor(Color.WHITE);
        g.setStroke(new BasicStroke((float) (3 * u)));
        g.draw(new Ellipse2D.Double(28.5 * u, 55.5 * u, 11 * u, 11 * u));
        g.draw(new Ellipse2D.Double(64.5 * u, 55.5 * u, 11 * u, 11 * u));
        g.dispose();
        ByteArrayOutputStream out = new ByteArrayOutputStream();
        ImageIO.write(img, "png", out);
        return out.toByteArray();
    }

    // ===== 푸시 구독 API (로그인 필요) =====

    @GetMapping("/push/key")
    @ResponseBody
    public Map<String, Object> key(HttpServletRequest req) throws Exception {
        pushService.rememberOrigin(req.getHeader("Origin"));
        Map<String, Object> res = new HashMap<String, Object>();
        res.put("key", pushService.getPublicKey());
        return res;
    }

    @SuppressWarnings("unchecked")
    @PostMapping("/push/subscribe")
    @ResponseBody
    public Map<String, Object> subscribe(@RequestBody Map<String, Object> body, HttpServletRequest req, HttpSession session) {
        Map<String, Object> res = new HashMap<String, Object>();
        String me = kakaoId(session);
        Map<String, Object> keys = (Map<String, Object>) body.get("keys");
        String endpoint = body.get("endpoint") == null ? null : String.valueOf(body.get("endpoint"));
        if (me == null || endpoint == null || keys == null || keys.get("p256dh") == null || keys.get("auth") == null
                || !endpoint.startsWith("https://")) {
            res.put("ok", false);
            return res;
        }
        pushService.rememberOrigin(req.getHeader("Origin"));
        pushService.subscribe(me, endpoint, String.valueOf(keys.get("p256dh")), String.valueOf(keys.get("auth")),
                req.getHeader("User-Agent"));
        res.put("ok", true);
        return res;
    }

    @PostMapping("/push/unsubscribe")
    @ResponseBody
    public Map<String, Object> unsubscribe(@RequestBody Map<String, Object> body) {
        Object ep = body.get("endpoint");
        if (ep != null) pushService.unsubscribe(String.valueOf(ep));
        Map<String, Object> res = new HashMap<String, Object>();
        res.put("ok", true);
        return res;
    }

    /** 내 기기로 테스트 알림 */
    @PostMapping("/push/test")
    @ResponseBody
    public Map<String, Object> test(HttpSession session) {
        Map<String, Object> res = new HashMap<String, Object>();
        String me = kakaoId(session);
        int n = me == null ? 0 : pushService.sendToUser(me, "🔔 테스트 알림", "알림이 정상적으로 도착했습니다.", "list");
        res.put("devices", n);
        return res;
    }

    private String kakaoId(HttpSession session) {
        Object u = session.getAttribute("carUser");
        return (u instanceof CarUserDto) ? ((CarUserDto) u).getKakaoId() : null;
    }
}
