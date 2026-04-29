package my.prac.core.car.service;

import java.util.List;
import java.util.Map;

import my.prac.core.car.dto.CarTransportDto;

public interface CarTransportService {
    List<CarTransportDto> getList(Map<String, Object> params);
    CarTransportDto getDetail(int id);
    void insert(CarTransportDto dto);
    void update(CarTransportDto dto);
    void delete(int id);
}
