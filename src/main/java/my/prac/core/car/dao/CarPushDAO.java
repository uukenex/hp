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

    /** 알림 수신자(NOTIFY_LOGIN=Y)의 구독 목록. exceptKakaoId 본인은 제외 */
    List<PushSubDto> getNotifySubs(@Param("exceptKakaoId") String exceptKakaoId);

    String getConfig(@Param("key") String key);

    int mergeConfig(@Param("key") String key, @Param("value") String value);

    /** 푸시 발송 이력 */
    int insertLog(PushLogDto dto);

    /** 해당 사용자가 유발한 같은 종류 알림을 마지막으로 보낸 뒤 경과 분 (이력이 없으면 null) */
    Double getMinutesSinceLast(@Param("actorKakaoId") String actorKakaoId, @Param("type") String type);
}
