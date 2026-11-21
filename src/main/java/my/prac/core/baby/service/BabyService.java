package my.prac.core.baby.service;

import java.security.SecureRandom;
import java.time.Duration;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.time.ZoneId;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

import javax.annotation.Resource;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;

import my.prac.core.baby.dao.BabyDAO;
import my.prac.core.baby.dto.BabyDto;
import my.prac.core.baby.dto.BabyLogDto;
import my.prac.core.baby.dto.BabyMemberDto;
import my.prac.core.car.push.CarPushService;

/** 육아 기록: 아기/보호자/기록 관리, 일일 요약 계산, 보호자 알림 */
@Service("core.baby.BabyService")
public class BabyService {

    private static final Logger logger = LoggerFactory.getLogger(BabyService.class);

    public static final ZoneId ZONE = ZoneId.of("Asia/Seoul");
    public static final String APP = "BABY";
    private static final DateTimeFormatter DT = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm");
    private static final String CODE_CHARS = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789";   // 헷갈리는 0/O/1/I 제외
    private static final int INVITE_HOURS = 72;
    /** 이 시간보다 오래된 시각의 기록(나중에 채워 넣는 기록)은 보호자 알림을 보내지 않음 */
    private static final long LIVE_WINDOW_MIN = 180;

    private final SecureRandom random = new SecureRandom();

    @Resource(name = "core.baby.BabyDAO")
    private BabyDAO dao;

    @Resource(name = "core.car.CarPushService")
    private CarPushService pushService;

    // ===== 시간 =====

    public static LocalDateTime now() {
        return LocalDateTime.now(ZONE).withSecond(0).withNano(0);
    }

    public static String fmt(LocalDateTime t) {
        return t.format(DT);
    }

    static LocalDateTime parse(String s) {
        return LocalDateTime.parse(s.trim().replace(' ', 'T'));
    }

    // ===== 아기 / 보호자 =====

    public List<BabyDto> myBabies(String me) {
        return dao.getBabiesByMember(me);
    }

    public boolean isMember(int babyId, String me) {
        return me != null && dao.getMember(babyId, me) != null;
    }

    public boolean isOwner(int babyId, String me) {
        BabyMemberDto m = me == null ? null : dao.getMember(babyId, me);
        return m != null && m.getIsOwner() == 1;
    }

    public BabyDto getBaby(int babyId) {
        return dao.getBaby(babyId);
    }

    public BabyDto createBaby(String me, String name, String birthDate, String gender, String relation) {
        BabyDto b = new BabyDto();
        b.setName(name);
        b.setBirthDate(birthDate);
        b.setGender(gender);
        b.setFeedRemindHours(0);
        b.setCreatedBy(me);
        dao.insertBaby(b);
        dao.insertMember(b.getBabyId(), me, relation, 1);
        return b;
    }

    public boolean updateBaby(int babyId, String name, String birthDate, String gender, double remindHours) {
        BabyDto b = new BabyDto();
        b.setBabyId(babyId);
        b.setName(name);
        b.setBirthDate(birthDate);
        b.setGender(gender);
        b.setFeedRemindHours(remindHours);
        return dao.updateBaby(b) > 0;
    }

    public List<BabyMemberDto> members(int babyId) {
        return dao.getMembers(babyId);
    }

    public boolean updateMember(int babyId, String me, String relation, String notifyActivity, String notifyRemind) {
        return dao.updateMember(babyId, me, relation, "N".equals(notifyActivity) ? "N" : "Y", "N".equals(notifyRemind) ? "N" : "Y") > 0;
    }

    /** 보호자 초대 코드 발급 (72시간, 1회용) */
    public String createInvite(int babyId, String me) {
        for (int attempt = 0; attempt < 5; attempt++) {
            StringBuilder b = new StringBuilder();
            for (int i = 0; i < 6; i++) b.append(CODE_CHARS.charAt(random.nextInt(CODE_CHARS.length())));
            try {
                dao.insertInvite(b.toString(), babyId, me, INVITE_HOURS);
                return b.toString();
            } catch (Exception e) {
                logger.warn("초대 코드 중복, 재시도", e);   // 코드가 겹친 경우만 재시도
            }
        }
        return null;
    }

    /** 초대 코드로 보호자 합류. 합류한 아기 ID, 실패하면 null */
    public Integer joinByCode(String code, String me, String relation) {
        if (code == null) return null;
        String c = code.trim().toUpperCase();
        Integer babyId = dao.getInviteBabyId(c);
        if (babyId == null) return null;
        if (dao.getMember(babyId, me) != null) return babyId;   // 이미 보호자면 그대로 성공 처리 (코드는 소모하지 않음)
        if (dao.useInvite(c, me) == 0) return null;             // 동시에 쓴 다른 사람이 먼저 썼다면 실패
        dao.insertMember(babyId, me, relation, 0);
        return babyId;
    }

    /** 보호자 탈퇴. 마지막 보호자였다면 아기 기록을 숨김 처리 */
    public void leave(int babyId, String me) {
        dao.deleteMember(babyId, me);
        if (dao.getMembers(babyId).isEmpty()) dao.hideBaby(babyId);
    }

    // ===== 기록 =====

    public List<BabyLogDto> logsOfDay(int babyId, LocalDate day) {
        return dao.getLogsRange(babyId, fmt(day.atStartOfDay()), fmt(day.plusDays(1).atStartOfDay()));
    }

    public List<BabyLogDto> growth(int babyId) {
        return dao.getGrowthLogs(babyId);
    }

    public BabyLogDto getLog(int logId) {
        return dao.getLog(logId);
    }

    /** 입력값 검증/정리. 문제가 있으면 오류 메시지 */
    public String normalize(BabyLogDto d) {
        String t = d.getLogType();
        if (!Arrays.asList("FORMULA", "BREAST", "SOLID", "SLEEP", "DIAPER", "GROWTH", "TEMP", "MEDICINE").contains(t)) return "기록 종류를 확인해 주세요.";
        LocalDateTime start, end = null;
        try {
            start = parse(d.getStartAt());
            if (d.getEndAt() != null && !d.getEndAt().trim().isEmpty()) end = parse(d.getEndAt());
        } catch (Exception e) {
            return "시간을 확인해 주세요.";
        }
        if (start.isAfter(now().plusDays(1))) return "미래 시간은 입력할 수 없습니다.";
        if (end != null && end.isBefore(start)) return "끝나는 시간이 시작 시간보다 빠릅니다.";
        d.setStartAt(fmt(start));
        d.setEndAt(end == null ? null : fmt(end));
        if (!"SLEEP".equals(t) && !"BREAST".equals(t)) d.setEndAt(null);

        String memo = stripEmoji(d.getMemo());
        d.setMemo(memo.length() > 300 ? memo.substring(0, 300) : memo);

        // 종류와 상관없는 값은 비움
        if (!"FORMULA".equals(t) && !"SOLID".equals(t)) d.setMl(null);
        if (!"GROWTH".equals(t)) { d.setWeightKg(null); d.setHeightCm(null); d.setHeadCm(null); }
        if (!"TEMP".equals(t)) d.setTempC(null);
        if (!"BREAST".equals(t) && !"DIAPER".equals(t)) d.setDetail(null);

        switch (t) {
            case "FORMULA":
                if (d.getMl() == null || d.getMl() <= 0 || d.getMl() > 1000) return "분유량(ml)을 입력해 주세요.";
                break;
            case "SOLID":
                if (d.getMl() != null && (d.getMl() < 0 || d.getMl() > 2000)) return "이유식 양을 확인해 주세요.";
                break;
            case "BREAST":
                if (!Arrays.asList("L", "R", "B").contains(d.getDetail())) return "수유한 쪽(좌/우/양쪽)을 선택해 주세요.";
                break;
            case "DIAPER":
                if (!Arrays.asList("PEE", "POOP", "BOTH").contains(d.getDetail())) return "기저귀 종류를 선택해 주세요.";
                break;
            case "GROWTH":
                if (d.getWeightKg() == null && d.getHeightCm() == null && d.getHeadCm() == null) return "체중, 키, 머리둘레 중 하나는 입력해 주세요.";
                if (d.getWeightKg() != null && (d.getWeightKg() < 0.3 || d.getWeightKg() > 40)) return "체중을 확인해 주세요.";
                if (d.getHeightCm() != null && (d.getHeightCm() < 20 || d.getHeightCm() > 130)) return "키를 확인해 주세요.";
                if (d.getHeadCm() != null && (d.getHeadCm() < 20 || d.getHeadCm() > 60)) return "머리둘레를 확인해 주세요.";
                break;
            case "TEMP":
                if (d.getTempC() == null || d.getTempC() < 30 || d.getTempC() > 43) return "체온을 확인해 주세요.";
                break;
            case "MEDICINE":
                if (d.getMemo().isEmpty()) return "약 이름을 입력해 주세요.";
                break;
            default:
                break;
        }
        return null;
    }

    /**
     * 기록 저장 (id 가 0이면 등록). 검증 오류가 있으면 오류 메시지 반환, 성공이면 null.
     * 저장 후 다른 보호자에게 알림(최근 시각의 기록만).
     */
    public String saveLog(BabyLogDto d, String me) {
        String err = normalize(d);
        if (err != null) return err;
        BabyLogDto before = null;
        if (d.getLogId() > 0) {
            before = dao.getLog(d.getLogId());
            if (before == null || before.getBabyId() != d.getBabyId()) return "기록을 찾을 수 없습니다.";
        }
        if ("SLEEP".equals(d.getLogType()) && d.getEndAt() == null) {   // 자는 중 기록은 아기당 하나만
            BabyLogDto open = dao.getOpenSleep(d.getBabyId());
            if (open != null && open.getLogId() != d.getLogId()) return "이미 자는 중으로 기록되어 있습니다.";
        }
        if (before == null) {
            d.setCreatedBy(me);
            dao.insertLog(d);
        } else {
            if (dao.updateLog(d) == 0) return "기록을 찾을 수 없습니다.";
        }
        notifyActivity(d, before, me);
        return null;
    }

    public boolean deleteLog(int logId, int babyId) {
        return dao.hideLog(logId, babyId) > 0;
    }

    // ===== 일일 요약 =====

    /** 하루 요약 + 현재 상태(마지막 수유, 수면 상태) */
    public Map<String, Object> summary(int babyId, LocalDate day) {
        LocalDateTime now = now();
        Map<String, Object> m = summarize(logsOfDay(babyId, day), day, now);
        BabyLogDto lastFeed = dao.getLastFeed(babyId);
        BabyLogDto openSleep = dao.getOpenSleep(babyId);
        BabyLogDto lastWake = dao.getLastSleepEnd(babyId);
        Map<String, Object> status = new LinkedHashMap<String, Object>();
        status.put("now", fmt(now));
        if (lastFeed != null) {
            status.put("lastFeedAt", lastFeed.getStartAt());
            status.put("lastFeedType", lastFeed.getLogType());
            status.put("lastFeedMl", lastFeed.getMl());
            status.put("lastFeedMinAgo", Duration.between(parse(lastFeed.getStartAt()), now).toMinutes());
        }
        if (openSleep != null) {
            status.put("sleeping", true);
            status.put("sleepStartAt", openSleep.getStartAt());
            status.put("sleepLogId", openSleep.getLogId());
            status.put("sleepMin", Duration.between(parse(openSleep.getStartAt()), now).toMinutes());
        } else {
            status.put("sleeping", false);
            if (lastWake != null) status.put("awakeMin", Duration.between(parse(lastWake.getEndAt()), now).toMinutes());
        }
        m.put("status", status);
        return m;
    }

    /** 최근 7일(마지막 날 포함) 일별 요약 */
    public List<Map<String, Object>> week(int babyId, LocalDate endDay) {
        LocalDate start = endDay.minusDays(6);
        List<BabyLogDto> logs = dao.getLogsRange(babyId, fmt(start.atStartOfDay()), fmt(endDay.plusDays(1).atStartOfDay()));
        LocalDateTime now = now();
        List<Map<String, Object>> out = new ArrayList<Map<String, Object>>();
        for (int i = 0; i < 7; i++) {
            LocalDate d = start.plusDays(i);
            Map<String, Object> s = summarize(logs, d, now);
            s.put("date", d.toString());
            out.add(s);
        }
        return out;
    }

    /** 해당 날짜(day)에 대한 합계. logs 에는 그날과 겹치는 기록이 들어 있어야 한다 */
    static Map<String, Object> summarize(List<BabyLogDto> logs, LocalDate day, LocalDateTime now) {
        LocalDateTime dayStart = day.atStartOfDay(), dayEnd = day.plusDays(1).atStartOfDay();
        double formulaMl = 0, solidMl = 0;
        int formulaCnt = 0, breastCnt = 0, solidCnt = 0, pee = 0, poop = 0, feedCnt = 0;
        long breastMin = 0, sleepMin = 0, napMin = 0, nightMin = 0;
        int sleepCnt = 0;
        List<LocalDateTime> feedTimes = new ArrayList<LocalDateTime>();

        for (BabyLogDto l : logs) {
            LocalDateTime s = parse(l.getStartAt());
            boolean startsToday = !s.isBefore(dayStart) && s.isBefore(dayEnd);
            switch (l.getLogType()) {
                case "FORMULA":
                    if (startsToday) { formulaCnt++; formulaMl += l.getMl() == null ? 0 : l.getMl(); feedTimes.add(s); }
                    break;
                case "BREAST":
                    if (startsToday) {
                        breastCnt++;
                        if (l.getEndAt() != null) breastMin += Math.max(0, Duration.between(s, parse(l.getEndAt())).toMinutes());
                        feedTimes.add(s);
                    }
                    break;
                case "SOLID":
                    if (startsToday) { solidCnt++; solidMl += l.getMl() == null ? 0 : l.getMl(); }
                    break;
                case "DIAPER":
                    if (startsToday) {
                        if ("PEE".equals(l.getDetail()) || "BOTH".equals(l.getDetail())) pee++;
                        if ("POOP".equals(l.getDetail()) || "BOTH".equals(l.getDetail())) poop++;
                    }
                    break;
                case "SLEEP": {
                    LocalDateTime e = l.getEndAt() == null ? now : parse(l.getEndAt());
                    LocalDateTime a = s.isAfter(dayStart) ? s : dayStart;
                    LocalDateTime b = e.isBefore(dayEnd) ? e : dayEnd;
                    long min = Duration.between(a, b).toMinutes();
                    if (min > 0) {
                        sleepMin += min;
                        int h = s.getHour();
                        if (h >= 19 || h < 6) nightMin += min; else napMin += min;   // 시작 시각 기준 밤잠/낮잠
                    }
                    if (startsToday) sleepCnt++;
                    break;
                }
                default:
                    break;
            }
        }
        feedCnt = formulaCnt + breastCnt;
        long avgGap = 0;
        if (feedTimes.size() >= 2) {
            java.util.Collections.sort(feedTimes);
            long total = 0;
            for (int i = 1; i < feedTimes.size(); i++) total += Duration.between(feedTimes.get(i - 1), feedTimes.get(i)).toMinutes();
            avgGap = total / (feedTimes.size() - 1);
        }
        Map<String, Object> m = new LinkedHashMap<String, Object>();
        m.put("formulaMl", Math.round(formulaMl * 10) / 10.0);
        m.put("formulaCount", formulaCnt);
        m.put("breastCount", breastCnt);
        m.put("breastMin", breastMin);
        m.put("solidCount", solidCnt);
        m.put("solidMl", Math.round(solidMl * 10) / 10.0);
        m.put("feedCount", feedCnt);
        m.put("avgFeedGapMin", avgGap);
        m.put("sleepMin", sleepMin);
        m.put("napMin", napMin);
        m.put("nightMin", nightMin);
        m.put("sleepCount", sleepCnt);
        m.put("pee", pee);
        m.put("poop", poop);
        return m;
    }

    // ===== 보호자 알림 =====

    private void notifyActivity(BabyLogDto d, BabyLogDto before, String me) {
        try {
            String type = d.getLogType();
            LocalDateTime now = now();
            String text = null;
            boolean live;
            if ("SLEEP".equals(type)) {
                boolean woke = d.getEndAt() != null && (before == null || before.getEndAt() == null);
                if (woke) {
                    live = Duration.between(parse(d.getEndAt()), now).toMinutes() <= LIVE_WINDOW_MIN;
                    long min = Duration.between(parse(d.getStartAt()), parse(d.getEndAt())).toMinutes();
                    text = "아기가 깼어요 (" + durationText(min) + " 잤어요)";
                } else if (d.getEndAt() == null && before == null) {
                    live = Duration.between(parse(d.getStartAt()), now).toMinutes() <= LIVE_WINDOW_MIN;
                    text = "아기가 잠들었어요 (" + parse(d.getStartAt()).toLocalTime() + ")";
                } else {
                    return;
                }
                if (!live) return;
            } else {
                if (before != null) return;   // 수정은 알리지 않음
                live = Duration.between(parse(d.getStartAt()), now).toMinutes() <= LIVE_WINDOW_MIN;
                if (!live) return;
                LocalTime t = parse(d.getStartAt()).toLocalTime();
                if ("FORMULA".equals(type)) text = "분유 " + trimNum(d.getMl()) + "ml를 먹였어요 (" + t + ")";
                else if ("BREAST".equals(type)) text = "모유 수유를 했어요 (" + sideText(d.getDetail()) + ", " + t + ")";
                else if ("SOLID".equals(type)) text = "이유식을 먹였어요 (" + t + ")";
                else if ("TEMP".equals(type)) text = "체온 " + trimNum(d.getTempC()) + "℃를 기록했어요";
                else if ("MEDICINE".equals(type)) text = "투약을 기록했어요 (" + d.getMemo() + ")";
                else return;   // 기저귀, 성장은 알리지 않음 (너무 잦음)
            }
            BabyDto baby = dao.getBaby(d.getBabyId());
            if (baby == null) return;
            BabyMemberDto actor = dao.getMember(d.getBabyId(), me);
            String who = actor == null ? "" : (actor.getRelation() != null ? actor.getRelation() : actor.getNickname());
            String body = (who == null || who.isEmpty() ? "" : "[" + who + "] ") + text;   // 조사 문제를 피하려고 대괄호 표기
            for (BabyMemberDto m : dao.getMembers(d.getBabyId())) {
                if (m.getKakaoId().equals(me) || !"Y".equals(m.getNotifyActivity())) continue;
                pushService.sendToUserApp(m.getKakaoId(), APP, "BABY", "👶 " + baby.getName(), body, "main", "icon/192.png",
                        "baby-" + d.getBabyId() + "-" + System.currentTimeMillis());
            }
        } catch (Exception e) {
            logger.warn("보호자 알림 실패", e);   // 알림 실패가 기록 저장에 영향을 주지 않도록
        }
    }

    /** 수유 간격 알림: 마지막 수유 후 설정한 시간이 지나면 보호자 모두에게 한 번 알림 */
    public int sendFeedReminders() {
        int sent = 0;
        LocalDateTime now = now();
        for (BabyDto baby : dao.getRemindBabies()) {
            try {
                BabyLogDto last = dao.getLastFeed(baby.getBabyId());
                if (last == null) continue;
                if (baby.getLastRemindLogId() != null && baby.getLastRemindLogId() == last.getLogId()) continue;   // 이 수유에 대해 이미 알림
                LocalDateTime lastAt = parse(last.getStartAt());
                long elapsed = Duration.between(lastAt, now).toMinutes();
                long threshold = Math.round(baby.getFeedRemindHours() * 60);
                if (elapsed < threshold || elapsed > 24 * 60) continue;   // 기록이 하루 넘게 비었으면 알리지 않음
                dao.updateLastRemind(baby.getBabyId(), last.getLogId());   // 먼저 기록해 중복 발송 방지
                String body = "마지막 수유 후 " + durationText(elapsed) + "이 지났어요 (" + lastAt.toLocalTime()
                        + (last.getMl() != null ? ", " + trimNum(last.getMl()) + "ml" : "") + ")";
                for (BabyMemberDto m : dao.getMembers(baby.getBabyId())) {
                    if (!"Y".equals(m.getNotifyRemind())) continue;
                    pushService.sendToUserApp(m.getKakaoId(), APP, "BABY", "🍼 " + baby.getName() + " 수유 시간", body, "main",
                            "icon/192.png", "baby-remind-" + baby.getBabyId());
                    sent++;
                }
            } catch (Exception e) {
                logger.warn("수유 알림 처리 실패 baby={}", baby.getBabyId(), e);
            }
        }
        return sent;
    }

    // ===== 유틸 =====

    static String durationText(long min) {
        if (min < 60) return min + "분";
        long h = min / 60, r = min % 60;
        return r == 0 ? h + "시간" : h + "시간 " + r + "분";
    }

    private static String sideText(String d) {
        return "L".equals(d) ? "왼쪽" : "R".equals(d) ? "오른쪽" : "양쪽";
    }

    private static String trimNum(Double v) {
        if (v == null) return "";
        return v == Math.floor(v) ? String.valueOf(v.longValue()) : String.valueOf(v);
    }

    /** DB 문자셋이 이모지(4바이트 문자)를 저장하지 못하므로 제거 */
    public static String stripEmoji(String s) {
        if (s == null) return "";
        StringBuilder b = new StringBuilder(s.length());
        for (int i = 0; i < s.length(); i++) {
            char ch = s.charAt(i);
            if (!Character.isSurrogate(ch)) b.append(ch);
        }
        return b.toString().trim();
    }

    public Map<String, Object> mapOf(Object... kv) {
        Map<String, Object> m = new HashMap<String, Object>();
        for (int i = 0; i + 1 < kv.length; i += 2) m.put(String.valueOf(kv[i]), kv[i + 1]);
        return m;
    }
}
