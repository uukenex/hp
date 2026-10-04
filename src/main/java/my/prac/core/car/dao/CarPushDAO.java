package my.prac.core.car.dao;

import java.util.List;

import org.apache.ibatis.annotations.Param;
import org.springframework.stereotype.Repository;

import my.prac.core.car.dto.PushLogDto;
import my.prac.core.car.dto.PushSubDto;

@Repository("core.car.CarPushDAO")
public interface CarPushDAO {
    /** endpoint 기준 등록/갱신 */
    int mergeSub(PushSubDto dto);

    int deleteByEndpoint(@Param("endpoint") String endpoint);

    List<PushSubDto> getSubsByKakaoId(@Param("kakaoId") String kakaoId);

    /** 로그인 알림 수신자(NOTIFY_LOGIN='Y')의 구독 목록. exceptKakaoId 본인은 제외 */
    List<PushSubDto> getLoginNotifySubs(@Param("exceptKakaoId") String exceptKakaoId);

    String getConfig(@Param("key") String key);

    int mergeConfig(@Param("key") String key, @Param("value") String value);

    /** 푸시 발송 이력 */
    int insertLog(PushLogDto dto);
}
