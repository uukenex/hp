package my.prac.core.calendar.service;

import java.time.LocalDate;
import java.time.YearMonth;
import java.time.ZoneId;
import java.time.temporal.ChronoUnit;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Set;
import java.util.TreeSet;

import javax.annotation.Resource;

import org.springframework.stereotype.Service;

import my.prac.core.calendar.dao.CalendarDAO;
import my.prac.core.calendar.dto.CalItemDto;

/** 캘린더 항목 관리 및 기념일(발생일) 계산. 화면과 알림이 같은 계산 결과를 쓰도록 서버에서 한 번만 계산한다. */
@Service("core.calendar.CalendarService")
public class CalendarService {

    public static final ZoneId ZONE = ZoneId.of("Asia/Seoul");
    private static final int MAX_INTERVAL = 36500;

    @Resource(name = "core.calendar.CalendarDAO")
    private CalendarDAO dao;

    // ===== 발생일 =====

    /** 하루의 기념일/생일 한 건 */
    public static class Occurrence {
        public int itemId;
        public String type;
        public String title;
        public String date;     // yyyy-MM-dd
        public String label;    // 100일, 1주년, 생일 등
        public String memo;
        public int daysLeft;    // 오늘 기준 남은 일수 (지난 날짜는 음수)
        public int baseYear;    // 생일: 출생 연도(없으면 0)

        public int getItemId() { return itemId; }
        public String getType() { return type; }
        public String getTitle() { return title; }
        public String getDate() { return date; }
        public String getLabel() { return label; }
        public String getMemo() { return memo; }
        public int getDaysLeft() { return daysLeft; }
    }

    public static LocalDate today() {
        return LocalDate.now(ZONE);
    }

    /** 항목의 [from, to] 범위 발생일 목록 (날짜순) */
    public List<Occurrence> occurrences(CalItemDto it, LocalDate from, LocalDate to) {
        List<Occurrence> out = new ArrayList<Occurrence>();
        LocalDate base;
        try {
            base = LocalDate.parse(it.getBaseDate());
        } catch (Exception e) {
            return out;
        }
        if (CalItemDto.TYPE_BIRTHDAY.equals(it.getItemType())) {
            for (int y = from.getYear(); y <= to.getYear(); y++) {
                LocalDate d = safeDate(y, base.getMonthValue(), base.getDayOfMonth());
                if (d.isBefore(from) || d.isAfter(to)) continue;
                if (it.getHasYear() == 1) {
                    int age = y - base.getYear();
                    if (age <= 0) continue;
                    out.add(occ(it, d, age + "번째 생일"));
                } else {
                    out.add(occ(it, d, "생일"));
                }
            }
        } else {
            // D-day: 시작일 + N일 단위 기념일 + 매년 주년
            if (!base.isBefore(from) && !base.isAfter(to)) out.add(occ(it, base, "시작일"));
            int offset = it.getCountFromOne() == 1 ? 1 : 0;      // 시작일을 1일로 셀 때 N일째 = 시작일 + (N-1)
            int interval = Math.min(Math.max(it.getIntervalDays(), 0), MAX_INTERVAL);
            if (interval > 0) {
                long fromN = ChronoUnit.DAYS.between(base, from) + offset;   // from 날짜가 몇 일째인지
                long k = Math.max(1, (fromN + interval - 1) / interval);      // from 이후 첫 배수
                for (;; k++) {
                    long n = k * interval;
                    LocalDate d = base.plusDays(n - offset);
                    if (d.isAfter(to)) break;
                    if (d.isBefore(from)) continue;
                    out.add(occ(it, d, n + "일"));
                    if (n > 1000000L) break;
                }
            }
            if (it.getYearly() == 1) {
                for (int k = 1; ; k++) {
                    LocalDate d = base.plusYears(k);
                    if (d.isAfter(to)) break;
                    if (d.isBefore(from)) continue;
                    out.add(occ(it, d, k + "주년"));
                    if (k > 200) break;
                }
            }
        }
        Collections.sort(out, new Comparator<Occurrence>() {
            @Override
            public int compare(Occurrence a, Occurrence b) {
                return a.date.compareTo(b.date);
            }
        });
        return out;
    }

    private Occurrence occ(CalItemDto it, LocalDate d, String label) {
        Occurrence o = new Occurrence();
        o.itemId = it.getItemId();
        o.type = it.getItemType();
        o.title = it.getTitle();
        o.date = d.toString();
        o.label = label;
        o.memo = it.getMemo();
        o.daysLeft = (int) ChronoUnit.DAYS.between(today(), d);
        return o;
    }

    /** 2월 29일 생일은 평년에는 2월 말일로 */
    private static LocalDate safeDate(int year, int month, int day) {
        int max = YearMonth.of(year, month).lengthOfMonth();
        return LocalDate.of(year, month, Math.min(day, max));
    }

    public List<Occurrence> occurrences(List<CalItemDto> items, LocalDate from, LocalDate to) {
        List<Occurrence> all = new ArrayList<Occurrence>();
        for (CalItemDto it : items) all.addAll(occurrences(it, from, to));
        Collections.sort(all, new Comparator<Occurrence>() {
            @Override
            public int compare(Occurrence a, Occurrence b) {
                return a.date.compareTo(b.date);
            }
        });
        return all;
    }

    // ===== 알림 일수 =====

    /** "7, 1,0,abc,-3,999" → "0,1,7" (0~365 범위의 정수만, 중복 제거, 오름차순) */
    public static String sanitizeNotifyDays(String raw) {
        Set<Integer> set = new TreeSet<Integer>();
        if (raw != null) {
            for (String p : raw.split(",")) {
                try {
                    int n = Integer.parseInt(p.trim());
                    if (n >= 0 && n <= 365) set.add(n);
                } catch (NumberFormatException ignore) {
                    // 숫자가 아닌 값은 무시
                }
            }
        }
        StringBuilder b = new StringBuilder();
        for (Integer n : set) {
            if (b.length() > 0) b.append(',');
            b.append(n);
        }
        return b.toString();
    }

    public static List<Integer> parseNotifyDays(String raw) {
        List<Integer> out = new ArrayList<Integer>();
        String s = sanitizeNotifyDays(raw);
        if (s.isEmpty()) return out;
        for (String p : s.split(",")) out.add(Integer.valueOf(p));
        return out;
    }

    // ===== CRUD =====

    public List<CalItemDto> getItems(String ownerId) { return dao.getItemsByOwner(ownerId); }
    public List<CalItemDto> getAllItems()           { return dao.getAllItems(); }
    public CalItemDto getItem(int itemId)           { return dao.getItem(itemId); }
    public void insert(CalItemDto dto)              { dao.insertItem(dto); }
    public int update(CalItemDto dto)               { return dao.updateItem(dto); }
    public int delete(int itemId, String ownerId)   { return dao.hideItem(itemId, ownerId); }

    public boolean tryRecordNotify(int itemId, String occurDate, int daysBefore) {
        return dao.insertNotifyLog(itemId, occurDate, daysBefore) > 0;
    }

    public void forgetNotify(int itemId, String occurDate, int daysBefore) {
        dao.deleteNotifyLog(itemId, occurDate, daysBefore);
    }

    /** 중복 없는 문자열 집합 유틸 */
    static Set<String> set(String... v) {
        Set<String> s = new LinkedHashSet<String>();
        Collections.addAll(s, v);
        return s;
    }
}
