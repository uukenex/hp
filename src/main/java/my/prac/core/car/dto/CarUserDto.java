package my.prac.core.car.dto;

import java.io.Serializable;

public class CarUserDto implements Serializable {
    private static final long serialVersionUID = 1L;

    private String kakaoId;
    private String nickname;
    private String profileImage;

    public String getKakaoId() { return kakaoId; }
    public void setKakaoId(String kakaoId) { this.kakaoId = kakaoId; }

    public String getNickname() { return nickname; }
    public void setNickname(String nickname) { this.nickname = nickname; }

    public String getProfileImage() { return profileImage; }
    public void setProfileImage(String profileImage) { this.profileImage = profileImage; }
}
