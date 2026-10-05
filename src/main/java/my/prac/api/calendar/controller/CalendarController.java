package my.prac.api.calendar.controller;

import java.awt.BasicStroke;
import java.awt.Color;
import java.awt.Font;
import java.awt.FontMetrics;
import java.awt.Graphics2D;
import java.awt.RenderingHints;
import java.awt.geom.Area;
import java.awt.geom.Rectangle2D;
import java.awt.geom.RoundRectangle2D;
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
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import my.prac.core.calendar.dto.CalItemDto;
import my.prac.core.calendar.service.CalendarService;
import my.prac.core.calendar.service.KoreanHolidays;
import my.prac.core.calendar.service.CalendarService.Occurrence;
import my.prac.core.car.dto.CarUserDto;
import my.prac.core.car.push.CarPushService;

/** 캘린더(D-day / 생일) 화면, API, PWA 리소스, 푸시 구독 */
@Controller
@RequestMapping("/calendar")
public class CalendarController {

    private static final String APP = "CALENDAR";

    @Resource(name = "core.calendar.CalendarService")
    private CalendarService calendarService;

    @Resource(name = "core.car.CarPushService")
    private CarPushService pushService;

    // ===== 화면 =====

    @GetMapping
    public String root() {
        return "redirect:/calendar/main";
    }

    @GetMapping("/main")
    public String main() {
        return "calendar/calendar_main";
    }

    // ===== 항목 API =====

    @GetMapping("/api/items")
    @ResponseBody
    public Map<String, Object> items(HttpSession session) {
        Map<String, Object> res = new HashMap<String, Object>();
        res.put("today", CalendarService.today().toString());
        res.put("items", calendarService.getItems(kakaoId(session)));
        res.put("todayHoliday", KoreanHolidays.forYear(CalendarService.today().getYear()).get(CalendarService.today().toString()));
        return res;
    }

    /** 다가오는 기념일 (오늘부터 400일 이내) */
    @GetMapping("/api/upcoming")
    @ResponseBody
    public Map<String, Object> upcoming(HttpSession session) {
        LocalDate today = CalendarService.today();
        List<Occurrence> list = calendarService.occurrences(calendarService.getItems(kakaoId(session)), today, today.plusDays(400));
        Map<String, Object> res = new HashMap<String, Object>();
        res.put("today", today.toString());
        res.put("list", list.size() > 60 ? list.subList(0, 60) : list);
        return res;
    }

    /** 달력 표시용: from~to 구간(최대 2년) 발생일 */
    @GetMapping("/api/occurrences")
    @ResponseBody
    public Map<String, Object> occurrences(@RequestParam String from, @RequestParam String to, HttpSession session) {
        Map<String, Object> res = new HashMap<String, Object>();
        try {
            LocalDate f = LocalDate.parse(from), t = LocalDate.parse(to);
            if (t.isBefore(f) || f.plusDays(800).isBefore(t)) throw new IllegalArgumentException("range");
            res.put("list", calendarService.occurrences(calendarService.getItems(kakaoId(session)), f, t));
            res.put("holidays", KoreanHolidays.range(f, t));
        } catch (Exception e) {
            res.put("list", new java.util.ArrayList<Occurrence>());
        }
        res.put("today", CalendarService.today().toString());
        return res;
    }

    /** id 가 0이면 등록, 아니면 수정 */
    @PostMapping("/api/save")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> save(@RequestBody CalItemDto dto, HttpSession session) {
        String me = kakaoId(session);
        if (me == null) return new ResponseEntity<Map<String, Object>>(HttpStatus.UNAUTHORIZED);
        String err = normalize(dto);
        Map<String, Object> res = new HashMap<String, Object>();
        if (err != null) {
            res.put("ok", false);
            res.put("error", err);
            return new ResponseEntity<Map<String, Object>>(res, HttpStatus.BAD_REQUEST);
        }
        dto.setOwnerKakaoId(me);
        if (dto.getItemId() > 0) {
            if (calendarService.update(dto) == 0) return new ResponseEntity<Map<String, Object>>(HttpStatus.FORBIDDEN);
        } else {
            calendarService.insert(dto);
        }
        res.put("ok", true);
        res.put("id", dto.getItemId());
        return new ResponseEntity<Map<String, Object>>(res, HttpStatus.OK);
    }

    @PostMapping("/api/delete/{id}")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> delete(@PathVariable int id, HttpSession session) {
        String me = kakaoId(session);
        if (me == null || calendarService.delete(id, me) == 0) return new ResponseEntity<Map<String, Object>>(HttpStatus.FORBIDDEN);
        Map<String, Object> res = new HashMap<String, Object>();
        res.put("ok", true);
        return new ResponseEntity<Map<String, Object>>(res, HttpStatus.OK);
    }

    /** 입력값 검증/정리. 문제가 있으면 오류 메시지 반환 */
    private String normalize(CalItemDto d) {
        if (!CalItemDto.TYPE_DDAY.equals(d.getItemType()) && !CalItemDto.TYPE_BIRTHDAY.equals(d.getItemType())) return "종류를 선택해 주세요.";
        String title = stripEmoji(d.getTitle());   // DB 문자셋이 이모지를 저장하지 못함
        if (title.isEmpty()) return "제목을 입력해 주세요.";
        if (title.length() > 100) title = title.substring(0, 100);
        d.setTitle(title);
        String memo = stripEmoji(d.getMemo());
        d.setMemo(memo.length() > 500 ? memo.substring(0, 500) : memo);
        try {
            LocalDate b = LocalDate.parse(d.getBaseDate());
            if (b.getYear() < 1900 || b.getYear() > 2100) return "날짜를 확인해 주세요.";
        } catch (Exception e) {
            return "날짜를 확인해 주세요.";
        }
        d.setHasYear(d.getHasYear() == 0 ? 0 : 1);
        d.setCountFromOne(d.getCountFromOne() == 0 ? 0 : 1);
        d.setYearly(d.getYearly() == 0 ? 0 : 1);
        d.setIntervalDays(Math.max(0, Math.min(36500, d.getIntervalDays())));
        d.setNotifyDays(CalendarService.sanitizeNotifyDays(d.getNotifyDays()));
        if (CalItemDto.TYPE_BIRTHDAY.equals(d.getItemType())) {   // 생일은 간격/주년 개념 없음
            d.setIntervalDays(0);
            d.setYearly(0);
            d.setCountFromOne(1);
        }
        return null;
    }

    private static String stripEmoji(String s) {
        if (s == null) return "";
        StringBuilder b = new StringBuilder(s.length());
        for (int i = 0; i < s.length(); i++) {
            char ch = s.charAt(i);
            if (!Character.isSurrogate(ch)) b.append(ch);
        }
        return b.toString().trim();
    }

    // ===== 푸시 구독 (캘린더 앱용) =====

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
        LocalDate t = CalendarService.today();
        int n = me == null ? 0 : pushService.sendToUserApp(me, APP, "CAL_TEST", "🔔 캘린더 테스트 알림", "알림이 정상적으로 도착했습니다.",
                "main", "icon/date.png?m=" + t.getMonthValue() + "&d=" + t.getDayOfMonth(), "cal-test");
        res.put("devices", n);
        return res;
    }

    private String kakaoId(HttpSession session) {
        Object u = session.getAttribute("carUser");
        return (u instanceof CarUserDto) ? ((CarUserDto) u).getKakaoId() : null;
    }

    // ===== PWA 리소스 (로그인 없이 접근 가능해야 함: 인터셉터 제외 대상) =====

    private static final String MANIFEST =
        "{\"id\":\"/calendar/\",\"name\":\"캘린더 D-day\",\"short_name\":\"캘린더\",\"start_url\":\"main\",\"scope\":\"./\","
        + "\"display\":\"standalone\",\"background_color\":\"#f5f7fa\",\"theme_color\":\"#0F6E56\","
        + "\"icons\":[{\"src\":\"icon/192.png\",\"sizes\":\"192x192\",\"type\":\"image/png\",\"purpose\":\"any maskable\"},"
        + "{\"src\":\"icon/512.png\",\"sizes\":\"512x512\",\"type\":\"image/png\",\"purpose\":\"any maskable\"}]}";

    private static final String SERVICE_WORKER =
        "self.addEventListener('install', function(e){ self.skipWaiting(); });\n"
        + "self.addEventListener('activate', function(e){ e.waitUntil(self.clients.claim()); });\n"
        + "self.addEventListener('fetch', function(e){});\n"
        + "self.addEventListener('push', function(e) {\n"
        + "  var d = {};\n"
        + "  try { d = e.data.json(); } catch (x) { d = { title: '캘린더', body: e.data ? e.data.text() : '' }; }\n"
        + "  e.waitUntil(self.registration.showNotification(d.title || '캘린더', {\n"
        + "    body: d.body || '', icon: d.icon || 'icon/192.png', badge: 'icon/192.png',\n"
        + "    tag: d.tag || 'calendar', data: { url: d.url || 'main' }\n"
        + "  }));\n"
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

    /** 알림/탭용 날짜 아이콘: /calendar/icon/date.png?m=10&d=5 (영문 월 약어와 숫자만 사용해 서버 폰트에 의존하지 않음) */
    @GetMapping("/icon/date.png")
    public void dateIcon(@RequestParam(defaultValue = "1") int m, @RequestParam(defaultValue = "1") int d,
                         @RequestParam(defaultValue = "192") int s, HttpServletResponse res) throws IOException {
        int mm = Math.max(1, Math.min(12, m)), dd = Math.max(1, Math.min(31, d)), size = Math.max(32, Math.min(512, s));
        write(res, "image/png", dateIconPng(mm, dd, size), true);
    }

    private void write(HttpServletResponse res, String type, byte[] body, boolean cache) throws IOException {
        res.setContentType(type);
        res.setHeader("Cache-Control", cache ? "public, max-age=86400" : "no-cache");
        res.setContentLength(body.length);
        res.getOutputStream().write(body);
    }

    /** 초록 배경에 흰 달력 모양 (날짜 칸은 비움) */
    private byte[] appIcon(int size) throws IOException {
        System.setProperty("java.awt.headless", "true");
        BufferedImage img = new BufferedImage(size, size, BufferedImage.TYPE_INT_ARGB);
        Graphics2D g = img.createGraphics();
        g.setRenderingHint(RenderingHints.KEY_ANTIALIASING, RenderingHints.VALUE_ANTIALIAS_ON);
        double u = size / 100.0;
        g.setColor(new Color(0x0F, 0x6E, 0x56));
        g.fillRect(0, 0, size, size);
        g.setColor(Color.WHITE);
        g.fill(new RoundRectangle2D.Double(22 * u, 26 * u, 56 * u, 52 * u, 8 * u, 8 * u));
        g.setColor(new Color(0xE2, 0x4B, 0x4A));
        Area top = new Area(new RoundRectangle2D.Double(22 * u, 26 * u, 56 * u, 18 * u, 8 * u, 8 * u));
        top.add(new Area(new Rectangle2D.Double(22 * u, 34 * u, 56 * u, 10 * u)));
        g.fill(top);
        g.setColor(Color.WHITE);
        g.fill(new RoundRectangle2D.Double(32 * u, 20 * u, 6 * u, 14 * u, 3 * u, 3 * u));
        g.fill(new RoundRectangle2D.Double(62 * u, 20 * u, 6 * u, 14 * u, 3 * u, 3 * u));
        g.setColor(new Color(0xD3, 0xD1, 0xC7));
        for (int r = 0; r < 2; r++) {
            for (int c = 0; c < 3; c++) {
                g.fill(new RoundRectangle2D.Double((30 + c * 15) * u, (52 + r * 12) * u, 9 * u, 8 * u, 2 * u, 2 * u));
            }
        }
        g.dispose();
        return png(img);
    }

    private byte[] dateIconPng(int month, int day, int size) throws IOException {
        System.setProperty("java.awt.headless", "true");
        String[] mon = { "JAN", "FEB", "MAR", "APR", "MAY", "JUN", "JUL", "AUG", "SEP", "OCT", "NOV", "DEC" };
        BufferedImage img = new BufferedImage(size, size, BufferedImage.TYPE_INT_ARGB);
        Graphics2D g = img.createGraphics();
        g.setRenderingHint(RenderingHints.KEY_ANTIALIASING, RenderingHints.VALUE_ANTIALIAS_ON);
        g.setRenderingHint(RenderingHints.KEY_TEXT_ANTIALIASING, RenderingHints.VALUE_TEXT_ANTIALIAS_ON);
        double u = size / 100.0;
        RoundRectangle2D card = new RoundRectangle2D.Double(2 * u, 2 * u, 96 * u, 96 * u, 22 * u, 22 * u);
        g.setColor(Color.WHITE);
        g.fill(card);
        g.setClip(card);
        g.setColor(new Color(0xE2, 0x4B, 0x4A));
        g.fill(new Rectangle2D.Double(0, 0, size, 32 * u));
        g.setClip(null);
        g.setColor(new Color(0xB4, 0xB2, 0xA9));
        g.setStroke(new BasicStroke((float) Math.max(1, u)));
        g.draw(card);

        g.setColor(Color.WHITE);
        g.setFont(new Font(Font.SANS_SERIF, Font.BOLD, (int) Math.round(18 * u)));
        center(g, mon[month - 1], size / 2.0, 24 * u);
        g.setColor(new Color(0x2C, 0x2C, 0x2A));
        g.setFont(new Font(Font.SANS_SERIF, Font.BOLD, (int) Math.round(54 * u)));
        center(g, String.valueOf(day), size / 2.0, 82 * u);
        g.dispose();
        return png(img);
    }

    private void center(Graphics2D g, String text, double cx, double baseline) {
        FontMetrics fm = g.getFontMetrics();
        g.drawString(text, (float) (cx - fm.stringWidth(text) / 2.0), (float) baseline);
    }

    private byte[] png(BufferedImage img) throws IOException {
        ByteArrayOutputStream out = new ByteArrayOutputStream();
        ImageIO.write(img, "png", out);
        return out.toByteArray();
    }
}
