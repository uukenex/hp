package my.prac.core.car.service.impl;

import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import my.prac.core.car.dao.CarTransportDAO;
import my.prac.core.car.dto.CarTransportDto;
import my.prac.core.car.service.CarTransportService;

@Service
public class CarTransportServiceImpl implements CarTransportService {

    @Autowired
    private CarTransportDAO carTransportDAO;

    @Override
    public List<CarTransportDto> getList(Map<String, Object> params) {
        return carTransportDAO.getList(params);
    }

    @Override
    public CarTransportDto getDetail(int id) {
        return carTransportDAO.getDetail(id);
    }

    @Override
    public void insert(CarTransportDto dto) {
        carTransportDAO.insert(dto);
    }

    @Override
    public void update(CarTransportDto dto) {
        carTransportDAO.update(dto);
    }

    @Override
    public void delete(int id) {
        carTransportDAO.delete(id);
    }
}
