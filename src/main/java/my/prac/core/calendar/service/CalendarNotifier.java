package my.prac.core.calendar.service;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;

import javax.annotation.Resource;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

import my.prac.core.calendar.dto.CalItemDto;
import my.prac.core.calendar.service.CalendarService.Occurrence;
import my.prac.core.car.push.CarPushService;

/**
 * 기념일/생일 푸시 알림. 30분마다 확인하며 매일 오전 8시(한국 시간) 이후 처음 도는 주기에 그날 보낼 알림을 모두 보낸다.
 * 발송 기록(TCAL_NOTIFY_LOG)을 먼저 남기고(중복 방지) 보내므로, 재시작하거나 서버가 여러 대여도 같은 알림이 두 번 가지 않는다.
 */
@Component("core.calendar.CalendarNotifier")
public class CalendarNotifier {

    private static final Logger logger = LoggerFactory.getLogger(CalendarNotifier.class);
    private static final int SEND_HOUR = 8;

    @Resource(name = "core.calendar.CalendarService")
    private CalendarService calendarService;

    @Resource(name = "core.car.CarPushService")
    private CarPushService pushService;

    @Scheduled(cron = "0 0/30 * * * *", zone = "Asia/Seoul")
    public void run() {
        try {
            LocalDateTime now = LocalDateTime.now(CalendarService.ZONE);
            if (now.getHour() < SEND_HOUR) return;
            notifyFor(now.toLocalDate());
        } catch (Exception e) {
            logger.warn("캘린더 알림 처리 실패", e);   // 다음 주기에 다시 시도
        }
    }

    /** 지정한 '오늘' 기준으로 보낼 알림을 모두 발송 (테스트/수동 호출 가능) */
    public int notifyFor(LocalDate today) {
        int sent = 0;
        List<CalItemDto> items = calendarService.getAllItems();
        for (CalItemDto it : items) {
            for (Integer days : CalendarService.parseNotifyDays(it.getNotifyDays())) {
                LocalDate target = today.plusDays(days);
                for (Occurrence o : calendarService.occurrences(it, target, target)) {
                    if (send(it, o, days, target)) sent++;
                }
            }
        }
        return sent;
    }

    private boolean send(CalItemDto it, Occurrence o, int daysBefore, LocalDate target) {
        // 먼저 기록해서 중복 발송을 막고, 대상 기기가 없거나 실패하면 기록을 지워 다음 주기에 다시 시도
        if (!calendarService.tryRecordNotify(it.getItemId(), o.date, daysBefore)) return false;
        try {
            boolean birthday = CalItemDto.TYPE_BIRTHDAY.equals(it.getItemType());
            String head = birthday ? "🎂 " : "💕 ";
            String when = daysBefore == 0 ? "오늘" : daysBefore + "일 전";
            String title = head + (daysBefore == 0 ? "오늘은 " : "") + it.getTitle() + " " + o.label;
            String body = daysBefore == 0
                    ? "오늘 " + target.getMonthValue() + "월 " + target.getDayOfMonth() + "일입니다"
                    : target.getMonthValue() + "월 " + target.getDayOfMonth() + "일 · " + when + " 알림";
            String icon = "icon/date.png?m=" + target.getMonthValue() + "&d=" + target.getDayOfMonth();
            int n = pushService.sendToUserApp(it.getOwnerKakaoId(), "CALENDAR", "CAL", title, body, "main", icon,
                    "cal-" + it.getItemId() + "-" + o.date);
            if (n == 0) {
                calendarService.forgetNotify(it.getItemId(), o.date, daysBefore);
                return false;
            }
            return true;
        } catch (Exception e) {
            calendarService.forgetNotify(it.getItemId(), o.date, daysBefore);
            logger.warn("캘린더 알림 발송 실패 item={}", it.getItemId(), e);
            return false;
        }
    }
}
