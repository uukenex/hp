package my.prac.core.baby.service;

import javax.annotation.Resource;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

/** 5분마다 수유 간격 알림 대상을 확인 (마지막 수유 후 설정한 시간이 지난 아기) */
@Component("core.baby.BabyNotifier")
public class BabyNotifier {

    private static final Logger logger = LoggerFactory.getLogger(BabyNotifier.class);

    @Resource(name = "core.baby.BabyService")
    private BabyService babyService;

    @Scheduled(cron = "0 0/5 * * * *", zone = "Asia/Seoul")
    public void run() {
        try {
            int n = babyService.sendFeedReminders();
            if (n > 0) logger.info("수유 간격 알림 {}건 발송", n);
        } catch (Exception e) {
            logger.warn("수유 간격 알림 처리 실패", e);   // 다음 주기에 다시 시도
        }
    }
}
