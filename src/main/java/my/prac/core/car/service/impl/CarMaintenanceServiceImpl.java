package my.prac.core.car.service.impl;

import java.util.List;

import javax.annotation.Resource;

import org.springframework.stereotype.Service;

import my.prac.core.car.dao.CarMaintenanceDAO;
import my.prac.core.car.dto.CarMaintenanceDto;
import my.prac.core.car.service.CarMaintenanceService;

@Service("core.car.CarMaintenanceService")
public class CarMaintenanceServiceImpl implements CarMaintenanceService {

    @Resource(name = "core.car.CarMaintenanceDAO")
    private CarMaintenanceDAO carMaintenanceDAO;

    @Override
    public List<CarMaintenanceDto> getList(String kakaoId) {
        return carMaintenanceDAO.getList(kakaoId);
    }

    @Override
    public CarMaintenanceDto getDetail(int id) {
        return carMaintenanceDAO.getDetail(id);
    }

    @Override
    public void insert(CarMaintenanceDto dto) {
        carMaintenanceDAO.insert(dto);
    }

    @Override
    public void update(CarMaintenanceDto dto) {
        carMaintenanceDAO.update(dto);
    }

    @Override
    public void delete(int id) {
        carMaintenanceDAO.delete(id);
    }
}
