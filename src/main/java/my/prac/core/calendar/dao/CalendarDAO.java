package my.prac.core.calendar.dao;

import java.util.List;

import org.apache.ibatis.annotations.Param;
import org.springframework.stereotype.Repository;

import my.prac.core.calendar.dto.CalItemDto;

@Repository("core.calendar.CalendarDAO")
public interface CalendarDAO {
    List<CalItemDto> getItemsByOwner(@Param("ownerId") String ownerId);

    /** 알림 스케줄러용: 삭제되지 않은 전체 항목 */
    List<CalItemDto> getAllItems();

    CalItemDto getItem(@Param("itemId") int itemId);

    int insertItem(CalItemDto dto);

    /** 본인 항목만 수정 (ownerKakaoId 일치) */
    int updateItem(CalItemDto dto);

    /** 삭제(숨김) 처리. 본인 항목만 */
    int hideItem(@Param("itemId") int itemId, @Param("ownerId") String ownerId);

    /** 같은 알림을 두 번 보내지 않기 위한 기록. 새로 기록되면 1, 이미 있으면 0 */
    int insertNotifyLog(@Param("itemId") int itemId, @Param("occurDate") String occurDate, @Param("daysBefore") int daysBefore);

    /** 발송 실패 시 다음 주기에 재시도할 수 있게 기록 삭제 */
    int deleteNotifyLog(@Param("itemId") int itemId, @Param("occurDate") String occurDate, @Param("daysBefore") int daysBefore);
}
