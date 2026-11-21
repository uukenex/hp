package my.prac.core.baby.dao;

import java.util.List;

import org.apache.ibatis.annotations.Param;
import org.springframework.stereotype.Repository;

import my.prac.core.baby.dto.BabyDto;
import my.prac.core.baby.dto.BabyLogDto;
import my.prac.core.baby.dto.BabyMemberDto;

@Repository("core.baby.BabyDAO")
public interface BabyDAO {

    // ===== 아기 =====
    /** 내가 보호자로 등록된 아기들 (내 보호자 정보 포함) */
    List<BabyDto> getBabiesByMember(@Param("kakaoId") String kakaoId);

    BabyDto getBaby(@Param("babyId") int babyId);

    int insertBaby(BabyDto dto);

    int updateBaby(BabyDto dto);

    int hideBaby(@Param("babyId") int babyId);

    /** 수유 간격 알림이 켜진 아기들 */
    List<BabyDto> getRemindBabies();

    int updateLastRemind(@Param("babyId") int babyId, @Param("logId") int logId);

    // ===== 보호자 =====
    int insertMember(@Param("babyId") int babyId, @Param("kakaoId") String kakaoId,
                     @Param("relation") String relation, @Param("isOwner") int isOwner);

    BabyMemberDto getMember(@Param("babyId") int babyId, @Param("kakaoId") String kakaoId);

    List<BabyMemberDto> getMembers(@Param("babyId") int babyId);

    int updateMember(@Param("babyId") int babyId, @Param("kakaoId") String kakaoId, @Param("relation") String relation,
                     @Param("notifyActivity") String notifyActivity, @Param("notifyRemind") String notifyRemind);

    int deleteMember(@Param("babyId") int babyId, @Param("kakaoId") String kakaoId);

    // ===== 초대 코드 =====
    int insertInvite(@Param("code") String code, @Param("babyId") int babyId, @Param("createdBy") String createdBy,
                     @Param("hours") int hours);

    /** 유효한(미사용, 만료 전) 코드의 아기 ID. 없으면 null */
    Integer getInviteBabyId(@Param("code") String code);

    /** 코드를 사용 처리. 처음 사용하면 1, 이미 사용/만료면 0 (동시에 두 명이 써도 한 명만 성공) */
    int useInvite(@Param("code") String code, @Param("kakaoId") String kakaoId);

    // ===== 기록 =====
    /** [from, to) 와 겹치는 기록 (수면처럼 걸쳐 있는 기록 포함) */
    List<BabyLogDto> getLogsRange(@Param("babyId") int babyId, @Param("from") String from, @Param("to") String to);

    BabyLogDto getLog(@Param("logId") int logId);

    /** 가장 최근 수유(분유/모유) 기록 */
    BabyLogDto getLastFeed(@Param("babyId") int babyId);

    /** 아직 끝나지 않은(자는 중인) 수면 기록 */
    BabyLogDto getOpenSleep(@Param("babyId") int babyId);

    /** 가장 최근에 끝난 수면 기록 */
    BabyLogDto getLastSleepEnd(@Param("babyId") int babyId);

    List<BabyLogDto> getGrowthLogs(@Param("babyId") int babyId);

    int insertLog(BabyLogDto dto);

    int updateLog(BabyLogDto dto);

    int hideLog(@Param("logId") int logId, @Param("babyId") int babyId);
}
