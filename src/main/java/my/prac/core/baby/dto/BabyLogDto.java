package my.prac.core.baby.dto;

import java.io.Serializable;

/** 육아 기록 한 건 (수유/수면/기저귀/성장/건강) */
public class BabyLogDto implements Serializable {
    private static final long serialVersionUID = 1L;

    public static final String FORMULA = "FORMULA";   // 분유 (ml)
    public static final String BREAST = "BREAST";     // 모유 (DETAIL: L/R/B, 시작~종료)
    public static final String SOLID = "SOLID";       // 이유식 (ml 또는 g, 메모에 음식)
    public static final String SLEEP = "SLEEP";       // 수면 (종료가 없으면 자는 중)
    public static final String DIAPER = "DIAPER";     // 기저귀 (DETAIL: PEE/POOP/BOTH)
    public static final String GROWTH = "GROWTH";     // 성장 (체중/키/머리둘레)
    public static final String TEMP = "TEMP";         // 체온
    public static final String MEDICINE = "MEDICINE"; // 투약 (메모에 약 이름)

    private int    logId;
    private int    babyId;
    private String logType;
    private String startAt;     // yyyy-MM-dd HH:mm
    private String endAt;       // yyyy-MM-dd HH:mm (없으면 null)
    private Double ml;
    private String detail;
    private Double weightKg;
    private Double heightCm;
    private Double headCm;
    private Double tempC;
    private String memo;
    private String createdBy;
    private String createdByName;   // 기록한 보호자 표시용 (관계 또는 닉네임)

    public int getLogId() { return logId; }
    public void setLogId(int logId) { this.logId = logId; }

    public int getBabyId() { return babyId; }
    public void setBabyId(int babyId) { this.babyId = babyId; }

    public String getLogType() { return logType; }
    public void setLogType(String logType) { this.logType = logType; }

    public String getStartAt() { return startAt; }
    public void setStartAt(String startAt) { this.startAt = startAt; }

    public String getEndAt() { return endAt; }
    public void setEndAt(String endAt) { this.endAt = endAt; }

    public Double getMl() { return ml; }
    public void setMl(Double ml) { this.ml = ml; }

    public String getDetail() { return detail; }
    public void setDetail(String detail) { this.detail = detail; }

    public Double getWeightKg() { return weightKg; }
    public void setWeightKg(Double weightKg) { this.weightKg = weightKg; }

    public Double getHeightCm() { return heightCm; }
    public void setHeightCm(Double heightCm) { this.heightCm = heightCm; }

    public Double getHeadCm() { return headCm; }
    public void setHeadCm(Double headCm) { this.headCm = headCm; }

    public Double getTempC() { return tempC; }
    public void setTempC(Double tempC) { this.tempC = tempC; }

    public String getMemo() { return memo; }
    public void setMemo(String memo) { this.memo = memo; }

    public String getCreatedBy() { return createdBy; }
    public void setCreatedBy(String createdBy) { this.createdBy = createdBy; }

    public String getCreatedByName() { return createdByName; }
    public void setCreatedByName(String createdByName) { this.createdByName = createdByName; }
}
