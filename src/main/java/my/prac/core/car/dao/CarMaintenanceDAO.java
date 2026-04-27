package my.prac.core.car.dao;

import java.util.List;

import org.mybatis.spring.SqlSessionTemplate;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Repository;

import my.prac.core.car.dto.CarMaintenanceDto;

@Repository
public class CarMaintenanceDAO {

    private static final String NS = "CarMaintenanceMapper.";

    @Autowired
    private SqlSessionTemplate sqlSession;

    public List<CarMaintenanceDto> getList(String kakaoId) {
        return sqlSession.selectList(NS + "getList", kakaoId);
    }

    public CarMaintenanceDto getDetail(int id) {
        return sqlSession.selectOne(NS + "getDetail", id);
    }

    public int insert(CarMaintenanceDto dto) {
        return sqlSession.insert(NS + "insert", dto);
    }

    public int update(CarMaintenanceDto dto) {
        return sqlSession.update(NS + "update", dto);
    }

    public int delete(int id) {
        return sqlSession.delete(NS + "delete", id);
    }
}
