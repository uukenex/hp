package my.prac.core.baby.dto;

import java.io.Serializable;

/** 아기 (조회한 사용자 기준의 보호자 정보 포함) */
public class BabyDto implements Serializable {
    private static final long serialVersionUID = 1L;

    private int    babyId;
    private String name;
    private String birthDate;          // yyyy-MM-dd
    private String gender;             // M / F / null
    private double feedRemindHours;    // 0이면 수유 간격 알림 끔
    private Integer lastRemindLogId;   // 마지막으로 알림을 보낸 수유 기록 (중복 알림 방지)
    private String createdBy;

    // 조회한 사용자 기준
    private String relation;
    private int    isOwner;
    private String notifyActivity = "Y";
    private String notifyRemind = "Y";

    public int getBabyId() { return babyId; }
    public void setBabyId(int babyId) { this.babyId = babyId; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public String getBirthDate() { return birthDate; }
    public void setBirthDate(String birthDate) { this.birthDate = birthDate; }

    public String getGender() { return gender; }
    public void setGender(String gender) { this.gender = gender; }

    public double getFeedRemindHours() { return feedRemindHours; }
    public void setFeedRemindHours(double feedRemindHours) { this.feedRemindHours = feedRemindHours; }

    public Integer getLastRemindLogId() { return lastRemindLogId; }
    public void setLastRemindLogId(Integer lastRemindLogId) { this.lastRemindLogId = lastRemindLogId; }

    public String getCreatedBy() { return createdBy; }
    public void setCreatedBy(String createdBy) { this.createdBy = createdBy; }

    public String getRelation() { return relation; }
    public void setRelation(String relation) { this.relation = relation; }

    public int getIsOwner() { return isOwner; }
    public void setIsOwner(int isOwner) { this.isOwner = isOwner; }

    public String getNotifyActivity() { return notifyActivity; }
    public void setNotifyActivity(String notifyActivity) { this.notifyActivity = notifyActivity; }

    public String getNotifyRemind() { return notifyRemind; }
    public void setNotifyRemind(String notifyRemind) { this.notifyRemind = notifyRemind; }
}
