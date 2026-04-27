package my.prac.core.car.dto;

public class CarMaintenanceDto {

    private int id;
    private String kakaoId;
    private String kakaoNickname;
    private String carName;         // 차량명
    private String carNumber;       // 차량번호
    private String maintenanceDate; // 정비일자 (YYYY-MM-DD)
    private int mileage;            // 주행거리 (km)
    private String maintenanceType; // 정비유형
    private String description;     // 상세내용
    private long cost;              // 비용
    private String shopName;        // 정비소명
    private String createdAt;       // 등록일시
    private String updatedAt;       // 수정일시

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public String getKakaoId() { return kakaoId; }
    public void setKakaoId(String kakaoId) { this.kakaoId = kakaoId; }

    public String getKakaoNickname() { return kakaoNickname; }
    public void setKakaoNickname(String kakaoNickname) { this.kakaoNickname = kakaoNickname; }

    public String getCarName() { return carName; }
    public void setCarName(String carName) { this.carName = carName; }

    public String getCarNumber() { return carNumber; }
    public void setCarNumber(String carNumber) { this.carNumber = carNumber; }

    public String getMaintenanceDate() { return maintenanceDate; }
    public void setMaintenanceDate(String maintenanceDate) { this.maintenanceDate = maintenanceDate; }

    public int getMileage() { return mileage; }
    public void setMileage(int mileage) { this.mileage = mileage; }

    public String getMaintenanceType() { return maintenanceType; }
    public void setMaintenanceType(String maintenanceType) { this.maintenanceType = maintenanceType; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public long getCost() { return cost; }
    public void setCost(long cost) { this.cost = cost; }

    public String getShopName() { return shopName; }
    public void setShopName(String shopName) { this.shopName = shopName; }

    public String getCreatedAt() { return createdAt; }
    public void setCreatedAt(String createdAt) { this.createdAt = createdAt; }

    public String getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(String updatedAt) { this.updatedAt = updatedAt; }
}
