package my.prac.core.car.dto;

import java.io.Serializable;

public class CarTransportHistoryDto implements Serializable {
    private static final long serialVersionUID = 1L;

    private long   histId;
    private int    transportId;
    private String action;      // INSERT / UPDATE / DELETE
    private String rowLabel;    // 날짜 / 기사님 / 회사 / 상차→하차
    private String detail;      // 변경 내용
    private String changedBy;
    private String changedAt;

    public long getHistId() { return histId; }
    public void setHistId(long histId) { this.histId = histId; }

    public int getTransportId() { return transportId; }
    public void setTransportId(int transportId) { this.transportId = transportId; }

    public String getAction() { return action; }
    public void setAction(String action) { this.action = action; }

    public String getRowLabel() { return rowLabel; }
    public void setRowLabel(String rowLabel) { this.rowLabel = rowLabel; }

    public String getDetail() { return detail; }
    public void setDetail(String detail) { this.detail = detail; }

    public String getChangedBy() { return changedBy; }
    public void setChangedBy(String changedBy) { this.changedBy = changedBy; }

    public String getChangedAt() { return changedAt; }
    public void setChangedAt(String changedAt) { this.changedAt = changedAt; }
}
