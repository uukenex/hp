package my.prac.core.car.dto;

import java.io.Serializable;

public class CarTransportDto implements Serializable {
    private static final long serialVersionUID = 1L;

    private int    id;
    private String transportDate;
    private String driverName;
    private String company;
    private String loadingPoint;
    private String unloadingPoint;
    private String carModel;
    private String vehicleNo;
    private long   supplyPrice;
    private long   companyPrice;
    private String loadingPhone;
    private String photoPayment;
    private String deposit;
    private String invoiceIssued;
    private String statementDoc;
    private String remark;
    private int    isHidden;
    private String createdAt;

    public String getLoadingPhone() { return loadingPhone; }
    public void setLoadingPhone(String loadingPhone) { this.loadingPhone = loadingPhone; }

    public String getPhotoPayment() { return photoPayment; }
    public void setPhotoPayment(String photoPayment) { this.photoPayment = photoPayment; }

    public String getDeposit() { return deposit; }
    public void setDeposit(String deposit) { this.deposit = deposit; }

    public String getInvoiceIssued() { return invoiceIssued; }
    public void setInvoiceIssued(String invoiceIssued) { this.invoiceIssued = invoiceIssued; }

    public String getStatementDoc() { return statementDoc; }
    public void setStatementDoc(String statementDoc) { this.statementDoc = statementDoc; }

    public String getRemark() { return remark; }
    public void setRemark(String remark) { this.remark = remark; }

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public String getTransportDate() { return transportDate; }
    public void setTransportDate(String transportDate) { this.transportDate = transportDate; }

    public String getDriverName() { return driverName; }
    public void setDriverName(String driverName) { this.driverName = driverName; }

    public String getCompany() { return company; }
    public void setCompany(String company) { this.company = company; }

    public String getLoadingPoint() { return loadingPoint; }
    public void setLoadingPoint(String loadingPoint) { this.loadingPoint = loadingPoint; }

    public String getUnloadingPoint() { return unloadingPoint; }
    public void setUnloadingPoint(String unloadingPoint) { this.unloadingPoint = unloadingPoint; }

    public String getCarModel() { return carModel; }
    public void setCarModel(String carModel) { this.carModel = carModel; }

    public String getVehicleNo() { return vehicleNo; }
    public void setVehicleNo(String vehicleNo) { this.vehicleNo = vehicleNo; }

    public long getSupplyPrice() { return supplyPrice; }
    public void setSupplyPrice(long supplyPrice) { this.supplyPrice = supplyPrice; }

    public long getCompanyPrice() { return companyPrice; }
    public void setCompanyPrice(long companyPrice) { this.companyPrice = companyPrice; }

    public int getIsHidden() { return isHidden; }
    public void setIsHidden(int isHidden) { this.isHidden = isHidden; }

    public String getCreatedAt() { return createdAt; }
    public void setCreatedAt(String createdAt) { this.createdAt = createdAt; }
}
