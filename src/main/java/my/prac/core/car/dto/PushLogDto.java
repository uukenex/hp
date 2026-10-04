package my.prac.core.car.dto;

import java.io.Serializable;

/** 푸시 발송 이력 (기기 1대 발송 = 1건) */
public class PushLogDto implements Serializable {
    private static final long serialVersionUID = 1L;

    private String type;            // LOGIN / TEST
    private String targetKakaoId;   // 수신자
    private long   subId;           // 수신 기기(구독) ID
    private String actorKakaoId;    // 알림을 유발한 사용자(로그인한 사람)
    private String actorName;
    private String title;
    private String body;
    private String result;          // OK / FAIL / EXPIRED
    private int    httpCode;
    private String errorMsg;

    public String getType() { return type; }
    public void setType(String type) { this.type = type; }

    public String getTargetKakaoId() { return targetKakaoId; }
    public void setTargetKakaoId(String targetKakaoId) { this.targetKakaoId = targetKakaoId; }

    public long getSubId() { return subId; }
    public void setSubId(long subId) { this.subId = subId; }

    public String getActorKakaoId() { return actorKakaoId; }
    public void setActorKakaoId(String actorKakaoId) { this.actorKakaoId = actorKakaoId; }

    public String getActorName() { return actorName; }
    public void setActorName(String actorName) { this.actorName = actorName; }

    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }

    public String getBody() { return body; }
    public void setBody(String body) { this.body = body; }

    public String getResult() { return result; }
    public void setResult(String result) { this.result = result; }

    public int getHttpCode() { return httpCode; }
    public void setHttpCode(int httpCode) { this.httpCode = httpCode; }

    public String getErrorMsg() { return errorMsg; }
    public void setErrorMsg(String errorMsg) { this.errorMsg = errorMsg; }
}
