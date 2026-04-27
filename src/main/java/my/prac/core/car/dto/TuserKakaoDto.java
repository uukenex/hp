package my.prac.core.car.dto;

import java.io.Serializable;

public class TuserKakaoDto implements Serializable {
    private static final long serialVersionUID = 1L;

    private int    userSeq;
    private String kakaoId;
    private String nickname;
    private String profileImage;
    private String autoLoginToken;
    private String tokenExpire;
    private String lastLogin;
    private String insertDate;

    public int getUserSeq() { return userSeq; }
    public void setUserSeq(int userSeq) { this.userSeq = userSeq; }

    public String getKakaoId() { return kakaoId; }
    public void setKakaoId(String kakaoId) { this.kakaoId = kakaoId; }

    public String getNickname() { return nickname; }
    public void setNickname(String nickname) { this.nickname = nickname; }

    public String getProfileImage() { return profileImage; }
    public void setProfileImage(String profileImage) { this.profileImage = profileImage; }

    public String getAutoLoginToken() { return autoLoginToken; }
    public void setAutoLoginToken(String autoLoginToken) { this.autoLoginToken = autoLoginToken; }

    public String getTokenExpire() { return tokenExpire; }
    public void setTokenExpire(String tokenExpire) { this.tokenExpire = tokenExpire; }

    public String getLastLogin() { return lastLogin; }
    public void setLastLogin(String lastLogin) { this.lastLogin = lastLogin; }

    public String getInsertDate() { return insertDate; }
    public void setInsertDate(String insertDate) { this.insertDate = insertDate; }
}
