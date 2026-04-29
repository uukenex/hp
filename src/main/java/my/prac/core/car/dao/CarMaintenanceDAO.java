package my.prac.core.car.dao;

import java.util.List;

import org.springframework.stereotype.Repository;

import my.prac.core.car.dto.CarMaintenanceDto;

@Repository("core.car.CarMaintenanceDAO")
public interface CarMaintenanceDAO {

    public List<CarMaintenanceDto> getList(String kakaoId);

    public CarMaintenanceDto getDetail(int id);

    public int insert(CarMaintenanceDto dto);

    public int update(CarMaintenanceDto dto);

    public int delete(int id);
}
