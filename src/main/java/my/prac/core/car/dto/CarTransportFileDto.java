package my.prac.core.car.dto;

import java.io.Serializable;

public class CarTransportFileDto implements Serializable {
    private static final long serialVersionUID = 1L;

    private int    fileId;
    private int    transportId;
    private String originalName;   // 업로드 원본 파일명
    private String savedName;      // 서버 저장 파일명 (UUID 등)
    private String filePath;       // 저장 경로
    private long   fileSize;
    private String fileExt;
    private String createdAt;

    public int getFileId() { return fileId; }
    public void setFileId(int fileId) { this.fileId = fileId; }

    public int getTransportId() { return transportId; }
    public void setTransportId(int transportId) { this.transportId = transportId; }

    public String getOriginalName() { return originalName; }
    public void setOriginalName(String originalName) { this.originalName = originalName; }

    public String getSavedName() { return savedName; }
    public void setSavedName(String savedName) { this.savedName = savedName; }

    public String getFilePath() { return filePath; }
    public void setFilePath(String filePath) { this.filePath = filePath; }

    public long getFileSize() { return fileSize; }
    public void setFileSize(long fileSize) { this.fileSize = fileSize; }

    public String getFileExt() { return fileExt; }
    public void setFileExt(String fileExt) { this.fileExt = fileExt; }

    public String getCreatedAt() { return createdAt; }
    public void setCreatedAt(String createdAt) { this.createdAt = createdAt; }
}
