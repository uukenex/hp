package my.prac.core.car.dao;

import org.mybatis.spring.SqlSessionTemplate;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Repository;

import my.prac.core.car.dto.TuserKakaoDto;

@Repository
public class TuserKakaoDAO {

    private static final String NS = "TuserKakaoMapper.";

    @Autowired
    private SqlSessionTemplate sqlSession;

    public TuserKakaoDto findByKakaoId(String kakaoId) {
        return sqlSession.selectOne(NS + "findByKakaoId", kakaoId);
    }

    public TuserKakaoDto findByToken(String token) {
        return sqlSession.selectOne(NS + "findByToken", token);
    }

    public int insert(TuserKakaoDto dto) {
        return sqlSession.insert(NS + "insert", dto);
    }

    public int updateLogin(TuserKakaoDto dto) {
        return sqlSession.update(NS + "updateLogin", dto);
    }
}
