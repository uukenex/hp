package my.prac.core.baby.dto;

import java.io.Serializable;

/** 아기의 보호자 */
public class BabyMemberDto implements Serializable {
    private static final long serialVersionUID = 1L;

    private int    babyId;
    private String kakaoId;
    private String nickname;        // 카카오 닉네임
    private String relation;        // 엄마 / 아빠 / 기타
    private String notifyActivity;  // Y / N
    private String notifyRemind;    // Y / N
    private int    isOwner;

    public int getBabyId() { return babyId; }
    public void setBabyId(int babyId) { this.babyId = babyId; }

    public String getKakaoId() { return kakaoId; }
    public void setKakaoId(String kakaoId) { this.kakaoId = kakaoId; }

    public String getNickname() { return nickname; }
    public void setNickname(String nickname) { this.nickname = nickname; }

    public String getRelation() { return relation; }
    public void setRelation(String relation) { this.relation = relation; }

    public String getNotifyActivity() { return notifyActivity; }
    public void setNotifyActivity(String notifyActivity) { this.notifyActivity = notifyActivity; }

    public String getNotifyRemind() { return notifyRemind; }
    public void setNotifyRemind(String notifyRemind) { this.notifyRemind = notifyRemind; }

    public int getIsOwner() { return isOwner; }
    public void setIsOwner(int isOwner) { this.isOwner = isOwner; }
}
