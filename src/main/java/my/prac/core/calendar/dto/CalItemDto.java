package my.prac.core.calendar.dto;

import java.io.Serializable;

/** 캘린더 항목: D-day(연애 등 기준일부터 N일) 또는 생일(매년 반복) */
public class CalItemDto implements Serializable {
    private static final long serialVersionUID = 1L;

    public static final String TYPE_DDAY = "DDAY";
    public static final String TYPE_BIRTHDAY = "BIRTHDAY";

    private int    itemId;
    private String ownerKakaoId;
    private String itemType;      // DDAY / BIRTHDAY
    private String title;
    private String baseDate;      // yyyy-MM-dd (D-day 시작일 또는 생일)
    private int    hasYear = 1;   // 생일: 출생 연도 포함 여부 (0이면 월/일만 사용)
    private int    countFromOne = 1; // 1: 기준일을 1일로 계산
    private int    intervalDays = 100; // D-day 기념일 간격(일), 0이면 사용 안 함
    private int    yearly = 1;    // D-day: 매년 주년 표시
    private String notifyDays = "7,1,0"; // 며칠 전에 알릴지 (쉼표 구분, 0=당일)
    private String memo;

    public int getItemId() { return itemId; }
    public void setItemId(int itemId) { this.itemId = itemId; }

    public String getOwnerKakaoId() { return ownerKakaoId; }
    public void setOwnerKakaoId(String ownerKakaoId) { this.ownerKakaoId = ownerKakaoId; }

    public String getItemType() { return itemType; }
    public void setItemType(String itemType) { this.itemType = itemType; }

    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }

    public String getBaseDate() { return baseDate; }
    public void setBaseDate(String baseDate) { this.baseDate = baseDate; }

    public int getHasYear() { return hasYear; }
    public void setHasYear(int hasYear) { this.hasYear = hasYear; }

    public int getCountFromOne() { return countFromOne; }
    public void setCountFromOne(int countFromOne) { this.countFromOne = countFromOne; }

    public int getIntervalDays() { return intervalDays; }
    public void setIntervalDays(int intervalDays) { this.intervalDays = intervalDays; }

    public int getYearly() { return yearly; }
    public void setYearly(int yearly) { this.yearly = yearly; }

    public String getNotifyDays() { return notifyDays; }
    public void setNotifyDays(String notifyDays) { this.notifyDays = notifyDays; }

    public String getMemo() { return memo; }
    public void setMemo(String memo) { this.memo = memo; }
}
