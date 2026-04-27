package my.prac.core.car.service;

import java.util.List;

import my.prac.core.car.dto.CarMaintenanceDto;

public interface CarMaintenanceService {
    List<CarMaintenanceDto> getList(String kakaoId);
    CarMaintenanceDto getDetail(int id);
    void insert(CarMaintenanceDto dto);
    void update(CarMaintenanceDto dto);
    void delete(int id);
}
