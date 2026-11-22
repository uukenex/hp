package my.prac.api.baby.controller;

import java.awt.Color;
import java.awt.Graphics2D;
import java.awt.RenderingHints;
import java.awt.geom.Arc2D;
import java.awt.geom.Ellipse2D;
import java.awt.image.BufferedImage;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.time.LocalDate;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.annotation.Resource;
import javax.imageio.ImageIO;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import my.prac.core.baby.dto.BabyDto;
import my.prac.core.baby.dto.BabyLogDto;
import my.prac.core.baby.service.BabyService;
import my.prac.core.car.dto.CarUserDto;
import my.prac.core.car.push.CarPushService;

/** 아기 관리(육아 기록) 화면, API, PWA 리소스, 푸시 구독 */
@Controller
@RequestMapping("/baby")
public class BabyController {

    private static final String APP = BabyService.APP;

    @Resource(name = "core.baby.BabyService")
    private BabyService babyService;

    @Resource(name = "core.car.CarPushService")
    private CarPushService pushService;

    // ===== 화면 =====

    @GetMapping
    public String root() {
        return "redirect:/baby/main";
    }

    @GetMapping("/main")
    public String main() {
        return "baby/baby_main";
    }

    // ===== 아기 / 보호자 API =====

    @GetMapping("/api/babies")
    @ResponseBody
    public Map<String, Object> babies(HttpSession session) {
        Map<String, Object> res = new HashMap<String, Object>();
        res.put("today", LocalDate.now(BabyService.ZONE).toString());
        res.put("babies", babyService.myBabies(kakaoId(session)));
        Object u = session.getAttribute("carUser");
        res.put("meName", (u instanceof CarUserDto && ((CarUserDto) u).getNickname() != null) ? ((CarUserDto) u).getNickname() : "");
        return res;
    }

    @PostMapping("/api/baby/create")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> create(@RequestBody Map<String, Object> body, HttpSession session) {
        String me = kakaoId(session);
        if (me == null) return status(HttpStatus.UNAUTHORIZED);
        String name = clean(str(body, "name"), 50);
        String birth = str(body, "birthDate");
        if (name.isEmpty()) return bad("아기 이름을 입력해 주세요.");
        if (!validBirth(birth)) return bad("생년월일을 확인해 주세요.");
        BabyDto b = babyService.createBaby(me, name, birth, gender(str(body, "gender")), clean(str(body, "relation"), 20));
        return ok(babyService.mapOf("babyId", b.getBabyId()));
    }

    @PostMapping("/api/baby/update")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> update(@RequestBody Map<String, Object> body, HttpSession session) {
        String me = kakaoId(session);
        int babyId = num(body, "babyId");
        if (!babyService.isOwner(babyId, me)) return status(HttpStatus.FORBIDDEN);
        String name = clean(str(body, "name"), 50);
        String birth = str(body, "birthDate");
        if (name.isEmpty()) return bad("아기 이름을 입력해 주세요.");
        if (!validBirth(birth)) return bad("생년월일을 확인해 주세요.");
        double hours = dbl(body, "feedRemindHours");
        if (hours != 0 && (hours < 1 || hours > 8 || (hours * 2) != Math.floor(hours * 2))) return bad("알림 간격을 확인해 주세요.");
        babyService.updateBaby(babyId, name, birth, gender(str(body, "gender")), hours);
        return ok(babyService.mapOf("ok", true));
    }

    @GetMapping("/api/members")
    @ResponseBody
    public ResponseEntity<Object> members(@RequestParam int babyId, HttpSession session) {
        if (!babyService.isMember(babyId, kakaoId(session))) return new ResponseEntity<Object>(HttpStatus.FORBIDDEN);
        return new ResponseEntity<Object>(babyService.members(babyId), HttpStatus.OK);
    }

    @PostMapping("/api/member/update")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> updateMember(@RequestBody Map<String, Object> body, HttpSession session) {
        String me = kakaoId(session);
        int babyId = num(body, "babyId");
        if (!babyService.isMember(babyId, me)) return status(HttpStatus.FORBIDDEN);
        babyService.updateMember(babyId, me, clean(str(body, "relation"), 20), str(body, "notifyActivity"), str(body, "notifyRemind"));
        return ok(babyService.mapOf("ok", true));
    }

    @PostMapping("/api/invite")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> invite(@RequestBody Map<String, Object> body, HttpSession session) {
        String me = kakaoId(session);
        int babyId = num(body, "babyId");
        if (!babyService.isMember(babyId, me)) return status(HttpStatus.FORBIDDEN);
        String code = babyService.createInvite(babyId, me);
        if (code == null) return bad("초대 코드를 만들지 못했습니다. 다시 시도해 주세요.");
        return ok(babyService.mapOf("code", code, "hours", 72));
    }

    @PostMapping("/api/join")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> join(@RequestBody Map<String, Object> body, HttpSession session) {
        String me = kakaoId(session);
        if (me == null) return status(HttpStatus.UNAUTHORIZED);
        Integer babyId = babyService.joinByCode(str(body, "code"), me, clean(str(body, "relation"), 20));
        if (babyId == null) return bad("초대 코드가 올바르지 않거나 만료되었습니다.");
        return ok(babyService.mapOf("babyId", babyId));
    }

    @PostMapping("/api/leave")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> leave(@RequestBody Map<String, Object> body, HttpSession session) {
        String me = kakaoId(session);
        int babyId = num(body, "babyId");
        if (!babyService.isMember(babyId, me)) return status(HttpStatus.FORBIDDEN);
        babyService.leave(babyId, me);
        return ok(babyService.mapOf("ok", true));
    }

    // ===== 기록 API =====

    @GetMapping("/api/day")
    @ResponseBody
    public ResponseEntity<Object> day(@RequestParam int babyId, @RequestParam String date, HttpSession session) {
        if (!babyService.isMember(babyId, kakaoId(session))) return new ResponseEntity<Object>(HttpStatus.FORBIDDEN);
        LocalDate d;
        try {
            d = LocalDate.parse(date);
        } catch (Exception e) {
            return new ResponseEntity<Object>(HttpStatus.BAD_REQUEST);
        }
        Map<String, Object> res = new HashMap<String, Object>();
        res.put("logs", babyService.logsOfDay(babyId, d));
        res.put("summary", babyService.summary(babyId, d));
        return new ResponseEntity<Object>(res, HttpStatus.OK);
    }

    @GetMapping("/api/week")
    @ResponseBody
    public ResponseEntity<Object> week(@RequestParam int babyId, @RequestParam String end, HttpSession session) {
        if (!babyService.isMember(babyId, kakaoId(session))) return new ResponseEntity<Object>(HttpStatus.FORBIDDEN);
        try {
            return new ResponseEntity<Object>(babyService.week(babyId, LocalDate.parse(end)), HttpStatus.OK);
        } catch (Exception e) {
            return new ResponseEntity<Object>(HttpStatus.BAD_REQUEST);
        }
    }

    @GetMapping("/api/growth")
    @ResponseBody
    public ResponseEntity<Object> growth(@RequestParam int babyId, HttpSession session) {
        if (!babyService.isMember(babyId, kakaoId(session))) return new ResponseEntity<Object>(HttpStatus.FORBIDDEN);
        List<BabyLogDto> list = babyService.growth(babyId);
        return new ResponseEntity<Object>(list, HttpStatus.OK);
    }

    /** logId 가 0이면 등록, 아니면 수정 */
    @PostMapping("/api/log/save")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> saveLog(@RequestBody BabyLogDto dto, HttpSession session) {
        String me = kakaoId(session);
        if (!babyService.isMember(dto.getBabyId(), me)) return status(HttpStatus.FORBIDDEN);
        String err = babyService.saveLog(dto, me);
        if (err != null) return bad(err);
        return ok(babyService.mapOf("ok", true, "logId", dto.getLogId()));
    }

    @PostMapping("/api/log/delete")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> deleteLog(@RequestBody Map<String, Object> body, HttpSession session) {
        int babyId = num(body, "babyId");
        if (!babyService.isMember(babyId, kakaoId(session))) return status(HttpStatus.FORBIDDEN);
        babyService.deleteLog(num(body, "logId"), babyId, kakaoId(session));
        return ok(babyService.mapOf("ok", true));
    }

    // ===== 푸시 구독 (아기 앱용) =====

    @GetMapping("/push/key")
    @ResponseBody
    public Map<String, Object> pushKey(HttpServletRequest req) throws Exception {
        pushService.rememberOrigin(req.getHeader("Origin"));
        Map<String, Object> res = new HashMap<String, Object>();
        res.put("key", pushService.getPublicKey());
        return res;
    }

    @SuppressWarnings("unchecked")
    @PostMapping("/push/subscribe")
    @ResponseBody
    public Map<String, Object> pushSubscribe(@RequestBody Map<String, Object> body, HttpServletRequest req, HttpSession session) {
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
                req.getHeader("User-Agent"), APP);
        res.put("ok", true);
        return res;
    }

    @PostMapping("/push/unsubscribe")
    @ResponseBody
    public Map<String, Object> pushUnsubscribe(@RequestBody Map<String, Object> body) {
        Object ep = body.get("endpoint");
        if (ep != null) pushService.unsubscribe(String.valueOf(ep));
        Map<String, Object> res = new HashMap<String, Object>();
        res.put("ok", true);
        return res;
    }

    @PostMapping("/push/test")
    @ResponseBody
    public Map<String, Object> pushTest(HttpSession session) {
        Map<String, Object> res = new HashMap<String, Object>();
        String me = kakaoId(session);
        int n = me == null ? 0 : pushService.sendToUserApp(me, APP, "BABY_TEST", "👶 시루노트 테스트 알림", "알림이 정상적으로 도착했습니다.",
                "main", "icon/192.png", "baby-test");
        res.put("devices", n);
        return res;
    }

    // ===== 공통 =====

    private String kakaoId(HttpSession session) {
        Object u = session.getAttribute("carUser");
        return (u instanceof CarUserDto) ? ((CarUserDto) u).getKakaoId() : null;
    }

    private static String str(Map<String, Object> m, String k) {
        Object v = m.get(k);
        return v == null ? "" : String.valueOf(v).trim();
    }

    private static int num(Map<String, Object> m, String k) {
        try {
            return (int) Double.parseDouble(str(m, k));
        } catch (Exception e) {
            return 0;
        }
    }

    private static double dbl(Map<String, Object> m, String k) {
        try {
            return Double.parseDouble(str(m, k));
        } catch (Exception e) {
            return 0;
        }
    }

    private static String clean(String s, int max) {
        String t = BabyService.stripEmoji(s);
        return t.length() > max ? t.substring(0, max) : t;
    }

    private static String gender(String g) {
        return "M".equals(g) || "F".equals(g) ? g : null;
    }

    private static boolean validBirth(String s) {
        try {
            LocalDate d = LocalDate.parse(s);
            return d.getYear() >= 2000 && !d.isAfter(LocalDate.now(BabyService.ZONE).plusYears(1));   // 출산 예정일(미래) 허용
        } catch (Exception e) {
            return false;
        }
    }

    private ResponseEntity<Map<String, Object>> ok(Map<String, Object> body) {
        return new ResponseEntity<Map<String, Object>>(body, HttpStatus.OK);
    }

    private ResponseEntity<Map<String, Object>> bad(String msg) {
        return new ResponseEntity<Map<String, Object>>(babyService.mapOf("ok", false, "error", msg), HttpStatus.BAD_REQUEST);
    }

    private ResponseEntity<Map<String, Object>> status(HttpStatus s) {
        return new ResponseEntity<Map<String, Object>>(s);
    }

    // ===== PWA 리소스 (로그인 없이 접근 가능해야 함: 인터셉터 제외 대상) =====

    private static final String MANIFEST =
        "{\"id\":\"/baby/\",\"name\":\"시루노트\",\"short_name\":\"시루노트\",\"start_url\":\"main\",\"scope\":\"./\","
        + "\"display\":\"standalone\",\"background_color\":\"#fff5f7\",\"theme_color\":\"#ED93B1\","
        + "\"icons\":[{\"src\":\"icon/192.png\",\"sizes\":\"192x192\",\"type\":\"image/png\",\"purpose\":\"any maskable\"},"
        + "{\"src\":\"icon/512.png\",\"sizes\":\"512x512\",\"type\":\"image/png\",\"purpose\":\"any maskable\"}]}";

    private static final String SERVICE_WORKER =
        "self.addEventListener('install', function(e){ self.skipWaiting(); });\n"
        + "self.addEventListener('activate', function(e){ e.waitUntil(self.clients.claim()); });\n"
        + "self.addEventListener('fetch', function(e){});\n"
        + "self.addEventListener('push', function(e) {\n"
        + "  var d = {};\n"
        + "  try { d = e.data.json(); } catch (x) { d = { title: '시루노트', body: e.data ? e.data.text() : '' }; }\n"
        + "  var tell = self.clients.matchAll({ type: 'window', includeUncontrolled: true }).then(function(list) {\n"
        + "    list.forEach(function(c) { c.postMessage({ type: 'baby-sync' }); });\n"   // 열려 있는 화면은 즉시 갱신
        + "  }).catch(function() {});\n"
        + "  e.waitUntil(Promise.all([tell, self.registration.showNotification(d.title || '시루노트', {\n"
        + "    body: d.body || '', icon: d.icon || 'icon/192.png', badge: 'icon/badge.png',\n"
        + "    tag: d.tag || 'baby', data: { url: d.url || 'main' }\n"
        + "  })]));\n"
        + "});\n"
        + "self.addEventListener('notificationclick', function(e) {\n"
        + "  e.notification.close();\n"
        + "  var url = new URL((e.notification.data && e.notification.data.url) || 'main', self.registration.scope).href;\n"
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
        write(res, "image/png", appIcon(192), true);
    }

    @GetMapping("/icon/512.png")
    public void icon512(HttpServletResponse res) throws IOException {
        write(res, "image/png", appIcon(512), true);
    }

    /** 안드로이드 상태표시줄용 알림 아이콘(배지). 투명 배경 + 흰색 젖병 모양이어야 네모로 보이지 않음 */
    @GetMapping("/icon/badge.png")
    public void badge(HttpServletResponse res) throws IOException {
        write(res, "image/png", badgeIcon(96), true);
    }

    private byte[] badgeIcon(int size) throws IOException {
        System.setProperty("java.awt.headless", "true");
        BufferedImage img = new BufferedImage(size, size, BufferedImage.TYPE_INT_ARGB);
        Graphics2D g = img.createGraphics();
        g.setRenderingHint(RenderingHints.KEY_ANTIALIASING, RenderingHints.VALUE_ANTIALIAS_ON);
        double u = size / 100.0;
        g.setColor(Color.WHITE);
        g.fill(new Ellipse2D.Double(41 * u, 4 * u, 18 * u, 18 * u));                                       // 젖꼭지
        g.fill(new java.awt.geom.Rectangle2D.Double(44 * u, 13 * u, 12 * u, 11 * u));
        g.fill(new java.awt.geom.RoundRectangle2D.Double(32 * u, 22 * u, 36 * u, 11 * u, 5 * u, 5 * u));    // 뚜껑
        g.fill(new java.awt.geom.RoundRectangle2D.Double(29 * u, 35 * u, 42 * u, 61 * u, 18 * u, 18 * u)); // 몸통
        g.setComposite(java.awt.AlphaComposite.Clear);                                                     // 눈금은 투명하게 뚫음
        for (int y : new int[] { 50, 62, 74 }) {
            g.fill(new java.awt.geom.RoundRectangle2D.Double(36 * u, y * u, 14 * u, 4 * u, 4 * u, 4 * u));
        }
        g.dispose();
        ByteArrayOutputStream out = new ByteArrayOutputStream();
        ImageIO.write(img, "png", out);
        return out.toByteArray();
    }

    private void write(HttpServletResponse res, String type, byte[] body, boolean cache) throws IOException {
        res.setContentType(type);
        res.setHeader("Cache-Control", cache ? "public, max-age=86400" : "no-cache");
        res.setContentLength(body.length);
        res.getOutputStream().write(body);
    }

    /** 분홍 배경에 아기 얼굴 (도형만 사용해 서버 폰트에 의존하지 않음) */
    private byte[] appIcon(int size) throws IOException {
        System.setProperty("java.awt.headless", "true");
        BufferedImage img = new BufferedImage(size, size, BufferedImage.TYPE_INT_ARGB);
        Graphics2D g = img.createGraphics();
        g.setRenderingHint(RenderingHints.KEY_ANTIALIASING, RenderingHints.VALUE_ANTIALIAS_ON);
        double u = size / 100.0;
        g.setColor(new Color(0xED, 0x93, 0xB1));
        g.fillRect(0, 0, size, size);
        g.setColor(new Color(0xFF, 0xE4, 0xCC));
        g.fill(new Ellipse2D.Double(23 * u, 25 * u, 54 * u, 54 * u));                     // 얼굴
        g.fill(new Ellipse2D.Double(18 * u, 46 * u, 10 * u, 14 * u));                     // 귀
        g.fill(new Ellipse2D.Double(72 * u, 46 * u, 10 * u, 14 * u));
        g.setColor(new Color(0x72, 0x24, 0x3E));
        g.fill(new Ellipse2D.Double(38 * u, 48 * u, 6 * u, 8 * u));                       // 눈
        g.fill(new Ellipse2D.Double(56 * u, 48 * u, 6 * u, 8 * u));
        g.setStroke(new java.awt.BasicStroke((float) (2.4 * u), java.awt.BasicStroke.CAP_ROUND, java.awt.BasicStroke.JOIN_ROUND));
        g.draw(new Arc2D.Double(42 * u, 56 * u, 16 * u, 12 * u, 200, 140, Arc2D.OPEN)); // 웃는 입
        g.setColor(new Color(0xF4, 0xB0, 0x9A));
        g.fill(new Ellipse2D.Double(32 * u, 58 * u, 8 * u, 5 * u));                       // 볼
        g.fill(new Ellipse2D.Double(60 * u, 58 * u, 8 * u, 5 * u));
        g.setColor(new Color(0x72, 0x24, 0x3E));
        g.draw(new Arc2D.Double(40 * u, 22 * u, 20 * u, 14 * u, 40, 100, Arc2D.OPEN));    // 머리카락 한 가닥
        g.dispose();
        ByteArrayOutputStream out = new ByteArrayOutputStream();
        ImageIO.write(img, "png", out);
        return out.toByteArray();
    }
}
