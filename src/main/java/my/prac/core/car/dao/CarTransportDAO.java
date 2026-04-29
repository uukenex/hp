package my.prac.core.car.dao;

import java.util.List;
import java.util.Map;

import org.mybatis.spring.SqlSessionTemplate;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Repository;

import my.prac.core.car.dto.CarTransportDto;

@Repository
public class CarTransportDAO {

    private static final String NS = "CarTransportMapper.";

    @Autowired
    private SqlSessionTemplate sqlSession;

    public List<CarTransportDto> getList(Map<String, Object> params) {
        return sqlSession.selectList(NS + "getList", params);
    }

    public CarTransportDto getDetail(int id) {
        return sqlSession.selectOne(NS + "getDetail", id);
    }

    public int insert(CarTransportDto dto) {
        return sqlSession.insert(NS + "insert", dto);
    }

    public int update(CarTransportDto dto) {
        return sqlSession.update(NS + "update", dto);
    }

    public int delete(int id) {
        return sqlSession.delete(NS + "delete", id);
    }
}
