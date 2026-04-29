package my.prac.core.car.dao;

import org.springframework.stereotype.Repository;

import my.prac.core.car.dto.TuserKakaoDto;

@Repository("core.car.TuserKakaoDAO")
public interface TuserKakaoDAO {

    public TuserKakaoDto findByKakaoId(String kakaoId);

    public TuserKakaoDto findByToken(String token);

    public int insert(TuserKakaoDto dto);

    public int updateLogin(TuserKakaoDto dto);
}
