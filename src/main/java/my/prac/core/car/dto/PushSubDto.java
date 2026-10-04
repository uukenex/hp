package my.prac.core.car.dto;

import java.io.Serializable;

public class PushSubDto implements Serializable {
    private static final long serialVersionUID = 1L;

    private long   subId;
    private String kakaoId;
    private String endpoint;
    private String p256dh;
    private String auth;
    private String userAgent;

    public long getSubId() { return subId; }
    public void setSubId(long subId) { this.subId = subId; }

    public String getKakaoId() { return kakaoId; }
    public void setKakaoId(String kakaoId) { this.kakaoId = kakaoId; }

    public String getEndpoint() { return endpoint; }
    public void setEndpoint(String endpoint) { this.endpoint = endpoint; }

    public String getP256dh() { return p256dh; }
    public void setP256dh(String p256dh) { this.p256dh = p256dh; }

    public String getAuth() { return auth; }
    public void setAuth(String auth) { this.auth = auth; }

    public String getUserAgent() { return userAgent; }
    public void setUserAgent(String userAgent) { this.userAgent = userAgent; }
}
