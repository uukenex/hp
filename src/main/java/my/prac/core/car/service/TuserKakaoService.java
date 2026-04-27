package my.prac.core.car.service;

import my.prac.core.car.dto.TuserKakaoDto;

public interface TuserKakaoService {
    /** 로그인시 upsert + 자동로그인 토큰 갱신 */
    TuserKakaoDto saveOrUpdateLogin(TuserKakaoDto dto);
    /** 자동로그인 토큰으로 사용자 조회 (만료 체크 포함) */
    TuserKakaoDto findByToken(String token);
}
