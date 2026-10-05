package my.prac.core.calendar.service;

import java.time.DayOfWeek;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.Map;
import java.util.TreeMap;
import java.util.concurrent.ConcurrentHashMap;

/**
 * 대한민국 공휴일 계산 (달력의 빨간 날 표시용).
 *
 * - 양력 공휴일(신정, 삼일절, 어린이날, 현충일, 광복절, 개천절, 한글날, 성탄절)은 규칙으로 계산한다.
 * - 음력 공휴일(설날, 추석, 부처님오신날)은 음력 변환 라이브러리 없이 연도별 날짜표를 쓰므로 2024~2030년만 지원한다.
 *   그 밖의 연도는 양력 공휴일만 표시된다.
 * - 대체공휴일은 현행 규정에 맞춰 계산한다.
 *   설날/추석 연휴가 일요일과 겹치면 연휴 다음 첫 평일, 어린이날/삼일절/광복절/개천절/한글날은 토/일요일 또는 다른 공휴일과 겹치면,
 *   부처님오신날/성탄절은 일요일 또는 다른 공휴일과 겹치면 다음 첫 평일.
 * - 임시공휴일/선거일은 알려진 날짜를 표에 직접 넣었다. (새로 지정되면 TEMP 표에 추가)
 */
public final class KoreanHolidays {

    private static final char A = 'A';   // 토/일/다른 공휴일과 겹치면 대체
    private static final char B = 'B';   // 일/다른 공휴일과 겹치면 대체
    private static final char C = 'C';   // 설날/추석 연휴 (일요일과 겹치면 대체)
    private static final char N = 'N';   // 대체 없음

    /** 연도 → {설날 월, 설날 일} (설날 당일. 연휴는 전날/다음날 포함) */
    private static final int[][] SEOLLAL = {
        {2024, 2, 10}, {2025, 1, 29}, {2026, 2, 17}, {2027, 2, 7}, {2028, 1, 27}, {2029, 2, 13}, {2030, 2, 3}
    };
    private static final int[][] CHUSEOK = {
        {2024, 9, 17}, {2025, 10, 6}, {2026, 9, 25}, {2027, 9, 15}, {2028, 10, 3}, {2029, 9, 22}, {2030, 9, 12}
    };
    private static final int[][] BUDDHA = {
        {2024, 5, 15}, {2025, 5, 5}, {2026, 5, 24}, {2027, 5, 13}, {2028, 5, 2}, {2029, 5, 20}, {2030, 5, 9}
    };

    /** 임시공휴일 / 선거일 (알려진 것만) */
    private static final String[][] TEMP = {
        {"2024-04-10", "국회의원선거일"},
        {"2024-10-01", "임시공휴일"},
        {"2025-01-27", "임시공휴일"},
        {"2025-06-03", "대통령선거일"},
        {"2026-06-03", "전국동시지방선거일"},
        {"2028-04-12", "국회의원선거일"}
    };

    private static final Map<Integer, Map<String, String>> CACHE = new ConcurrentHashMap<Integer, Map<String, String>>();

    private KoreanHolidays() {}

    private static class H {
        final LocalDate date;
        final String name;
        final char group;
        H(LocalDate date, String name, char group) { this.date = date; this.name = name; this.group = group; }
    }

    /** 해당 연도의 공휴일 (yyyy-MM-dd → 이름). 같은 날 겹치면 "·"로 연결 */
    public static Map<String, String> forYear(int year) {
        Map<String, String> cached = CACHE.get(year);
        if (cached != null) return cached;
        Map<String, String> m = compute(year);
        CACHE.put(year, m);
        return m;
    }

    /** [from, to] 범위의 공휴일 */
    public static Map<String, String> range(LocalDate from, LocalDate to) {
        Map<String, String> out = new TreeMap<String, String>();
        for (int y = from.getYear(); y <= to.getYear(); y++) {
            for (Map.Entry<String, String> e : forYear(y).entrySet()) {
                LocalDate d = LocalDate.parse(e.getKey());
                if (!d.isBefore(from) && !d.isAfter(to)) out.put(e.getKey(), e.getValue());
            }
        }
        return out;
    }

    private static Map<String, String> compute(int year) {
        List<H> base = new ArrayList<H>();
        base.add(new H(LocalDate.of(year, 1, 1), "신정", N));
        base.add(new H(LocalDate.of(year, 3, 1), "삼일절", A));
        base.add(new H(LocalDate.of(year, 5, 5), "어린이날", A));
        base.add(new H(LocalDate.of(year, 6, 6), "현충일", N));
        base.add(new H(LocalDate.of(year, 8, 15), "광복절", A));
        base.add(new H(LocalDate.of(year, 10, 3), "개천절", A));
        base.add(new H(LocalDate.of(year, 10, 9), "한글날", A));
        base.add(new H(LocalDate.of(year, 12, 25), "성탄절", B));

        int[] s = find(SEOLLAL, year), c = find(CHUSEOK, year), b = find(BUDDHA, year);
        if (s != null) addTriple(base, LocalDate.of(year, s[0], s[1]), "설날");
        if (c != null) addTriple(base, LocalDate.of(year, c[0], c[1]), "추석");
        if (b != null) base.add(new H(LocalDate.of(year, b[0], b[1]), "부처님오신날", B));
        for (String[] t : TEMP) {
            LocalDate d = LocalDate.parse(t[0]);
            if (d.getYear() == year) base.add(new H(d, t[1], N));
        }

        // 날짜별로 묶기
        Map<LocalDate, List<H>> byDate = new TreeMap<LocalDate, List<H>>();
        for (H h : base) {
            List<H> l = byDate.get(h.date);
            if (l == null) { l = new ArrayList<H>(); byDate.put(h.date, l); }
            l.add(h);
        }

        // 대체공휴일 (날짜 순서대로 다음 첫 평일 배정)
        Map<LocalDate, String> subs = new TreeMap<LocalDate, String>();
        for (Map.Entry<LocalDate, List<H>> e : new ArrayList<Map.Entry<LocalDate, List<H>>>(byDate.entrySet())) {
            LocalDate date = e.getKey();
            List<H> list = e.getValue();
            DayOfWeek dow = date.getDayOfWeek();
            boolean weekend = dow == DayOfWeek.SATURDAY || dow == DayOfWeek.SUNDAY;
            boolean sunday = dow == DayOfWeek.SUNDAY;
            String subName = null;
            for (H h : list) {
                boolean need = false;
                if (h.group == A) need = weekend || list.size() > 1;
                else if (h.group == B) need = sunday || list.size() > 1;
                else if (h.group == C) need = sunday;
                if (need) { subName = h.name; break; }
            }
            if (subName != null) {
                LocalDate d = date.plusDays(1);
                while (isWeekend(d) || byDate.containsKey(d) || subs.containsKey(d)) d = d.plusDays(1);
                subs.put(d, "대체공휴일(" + subName.replace(" 연휴", "") + ")");
            }
        }

        Map<String, String> out = new TreeMap<String, String>();
        for (Map.Entry<LocalDate, List<H>> e : byDate.entrySet()) {
            StringBuilder sb = new StringBuilder();
            for (H h : e.getValue()) {
                if (sb.length() > 0) sb.append('·');
                sb.append(h.name);
            }
            out.put(e.getKey().toString(), sb.toString());
        }
        for (Map.Entry<LocalDate, String> e : subs.entrySet()) {
            String key = e.getKey().toString();
            out.put(key, out.containsKey(key) ? out.get(key) + "·" + e.getValue() : e.getValue());
        }
        return Collections.unmodifiableMap(out);
    }

    private static void addTriple(List<H> base, LocalDate center, String name) {
        base.add(new H(center.minusDays(1), name + " 연휴", C));
        base.add(new H(center, name, C));
        base.add(new H(center.plusDays(1), name + " 연휴", C));
    }

    private static boolean isWeekend(LocalDate d) {
        return d.getDayOfWeek() == DayOfWeek.SATURDAY || d.getDayOfWeek() == DayOfWeek.SUNDAY;
    }

    private static int[] find(int[][] table, int year) {
        for (int[] r : table) if (r[0] == year) return new int[] { r[1], r[2] };
        return null;
    }
}
