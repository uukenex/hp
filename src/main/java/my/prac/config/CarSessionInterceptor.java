package my.prac.config;

import javax.servlet.http.Cookie;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import org.springframework.web.servlet.handler.HandlerInterceptorAdapter;

import my.prac.api.car.controller.KakaoLoginController;
import my.prac.core.car.dto.CarUserDto;
import my.prac.core.car.dto.TuserKakaoDto;
import my.prac.core.car.service.TuserKakaoService;
import my.prac.core.car.push.CarPushService;

public class CarSessionInterceptor extends HandlerInterceptorAdapter {

    private final TuserKakaoService tuserKakaoService;
    private final CarPushService carPushService;

    public CarSessionInterceptor(TuserKakaoService tuserKakaoService, CarPushService carPushService) {
        this.carPushService = carPushService;
        this.tuserKakaoService = tuserKakaoService;
    }

    @Override
    public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler)
            throws Exception {
        HttpSession session = request.getSession();

        // 1. 세션이 살아있으면 통과
        if (session.getAttribute("carUser") != null) {
            return true;
        }

        // 2. 자동로그인 쿠키 확인
        String token = getCookieValue(request, KakaoLoginController.AUTO_LOGIN_COOKIE);
        if (token != null) {
            TuserKakaoDto saved = tuserKakaoService.findByToken(token);
            if (saved != null) {
                CarUserDto carUser = new CarUserDto();
                carUser.setKakaoId(saved.getKakaoId());
                carUser.setNickname(saved.getNickname());
                carUser.setProfileImage(saved.getProfileImage());
                session.setAttribute("carUser", carUser);
                carPushService.notifyLogin(carUser);   // 자동로그인(새 세션)도 접속 알림 (30분 간격 제한)
                return true;
            }
        }

        // 3. 인증 없음 → 원래 요청 URL 저장 후 로그인 페이지
        String query = request.getQueryString();
        String originalUrl = request.getRequestURI() + (query != null ? "?" + query : "");
        session.setAttribute("redirectAfterLogin", originalUrl);
        response.sendRedirect(request.getContextPath() + "/car/login");
        return false;
    }

    private String getCookieValue(HttpServletRequest request, String name) {
        Cookie[] cookies = request.getCookies();
        if (cookies == null) return null;
        for (Cookie c : cookies) {
            if (name.equals(c.getName())) return c.getValue();
        }
        return null;
    }
}
