package my.prac.api.car.controller;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

import javax.servlet.http.Cookie;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import org.apache.http.NameValuePair;
import org.apache.http.client.entity.UrlEncodedFormEntity;
import org.apache.http.client.methods.CloseableHttpResponse;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.impl.client.CloseableHttpClient;
import org.apache.http.impl.client.HttpClients;
import org.apache.http.message.BasicNameValuePair;
import org.apache.http.util.EntityUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;

import my.prac.core.car.dto.CarUserDto;
import my.prac.core.car.dto.TuserKakaoDto;
import my.prac.core.car.service.TuserKakaoService;

@Controller
public class KakaoLoginController {

    private static final Logger logger = LoggerFactory.getLogger(KakaoLoginController.class);

    private static final String KAKAO_AUTH_URL  = "https://kauth.kakao.com/oauth/authorize?client_id=%s&redirect_uri=%s&response_type=code";
    private static final String KAKAO_TOKEN_URL = "https://kauth.kakao.com/oauth/token";
    private static final String KAKAO_USER_URL  = "https://kapi.kakao.com/v2/user/me";
    private static final String CALLBACK_PATH   = "/kakao/callback";
    public static final String AUTO_LOGIN_COOKIE  = "car_auto";
    private static final int    COOKIE_MAX_AGE   = 60 * 60 * 24 * 30; // 30일

    @Value("${kakaoKey}")
    private String kakaoClientId;

    @Autowired
    private TuserKakaoService tuserKakaoService;

    @GetMapping("/car/login")
    public String loginPage() {
        return "car/login";
    }

    @GetMapping("/car/kakao/start")
    public void kakaoStart(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String redirectUri = buildRedirectUri(request);
        response.sendRedirect(String.format(KAKAO_AUTH_URL, kakaoClientId, redirectUri));
    }

    @GetMapping("/kakao/callback")
    public String kakaoCallback(@RequestParam(required = false) String code,
                                @RequestParam(required = false) String error,
                                HttpServletRequest request,
                                HttpServletResponse response,
                                HttpSession session) {
        if (error != null || code == null) {
            logger.warn("Kakao OAuth error: {}", error);
            return "redirect:/car/login?error=kakao";
        }
        try {
            String redirectUri   = buildRedirectUri(request);
            String accessToken   = getKakaoAccessToken(code, redirectUri);
            CarUserDto kakaoInfo  = getKakaoUserInfo(accessToken);

            // tuser_kakao upsert + 자동로그인 토큰 발급
            TuserKakaoDto saved = tuserKakaoService.saveOrUpdateLogin(toTuserDto(kakaoInfo));

            // 세션 저장
            session.setAttribute("carUser", kakaoInfo);

            // 자동로그인 쿠키 (30일)
            Cookie cookie = new Cookie(AUTO_LOGIN_COOKIE, saved.getAutoLoginToken());
            cookie.setMaxAge(COOKIE_MAX_AGE);
            cookie.setPath("/");
            response.addCookie(cookie);

            return "redirect:/car/board/list";
        } catch (Exception e) {
            logger.error("Kakao login failed", e);
            return "redirect:/car/login?error=server";
        }
    }

    @GetMapping("/car/logout")
    public String logout(HttpServletRequest request, HttpServletResponse response, HttpSession session) {
        session.invalidate();
        Cookie cookie = new Cookie(AUTO_LOGIN_COOKIE, "");
        cookie.setMaxAge(0);
        cookie.setPath("/");
        response.addCookie(cookie);
        return "redirect:/car/login";
    }

    // ── 내부 메서드 ────────────────────────────────────────────────────────────

    private String buildRedirectUri(HttpServletRequest request) {
        StringBuilder sb = new StringBuilder();
        sb.append(request.getScheme()).append("://").append(request.getServerName());
        int port = request.getServerPort();
        if (port != 80 && port != 443) {
            sb.append(":").append(port);
        }
        sb.append(request.getContextPath()).append(CALLBACK_PATH);
        return sb.toString();
    }

    private TuserKakaoDto toTuserDto(CarUserDto src) {
        TuserKakaoDto dto = new TuserKakaoDto();
        dto.setKakaoId(src.getKakaoId());
        dto.setNickname(src.getNickname());
        dto.setProfileImage(src.getProfileImage());
        return dto;
    }

    private String getKakaoAccessToken(String code, String redirectUri) throws IOException {
        try (CloseableHttpClient client = HttpClients.createDefault()) {
            HttpPost httpPost = new HttpPost(KAKAO_TOKEN_URL);

            List<NameValuePair> params = new ArrayList<>();
            params.add(new BasicNameValuePair("grant_type",   "authorization_code"));
            params.add(new BasicNameValuePair("client_id",    kakaoClientId));
            params.add(new BasicNameValuePair("redirect_uri", redirectUri));
            params.add(new BasicNameValuePair("code",         code));
            httpPost.setEntity(new UrlEncodedFormEntity(params, "UTF-8"));

            try (CloseableHttpResponse resp = client.execute(httpPost)) {
                String body = EntityUtils.toString(resp.getEntity(), "UTF-8");
                JsonNode root = new ObjectMapper().readTree(body);
                if (root.has("error")) {
                    throw new RuntimeException("Kakao token error: "
                            + root.path("error_description").asText());
                }
                return root.get("access_token").asText();
            }
        }
    }

    private CarUserDto getKakaoUserInfo(String accessToken) throws IOException {
        try (CloseableHttpClient client = HttpClients.createDefault()) {
            HttpGet httpGet = new HttpGet(KAKAO_USER_URL);
            httpGet.addHeader("Authorization", "Bearer " + accessToken);

            try (CloseableHttpResponse resp = client.execute(httpGet)) {
                String body = EntityUtils.toString(resp.getEntity(), "UTF-8");
                JsonNode root = new ObjectMapper().readTree(body);

                CarUserDto user = new CarUserDto();
                user.setKakaoId(root.get("id").asText());

                JsonNode props = root.path("properties");
                if (!props.isMissingNode()) {
                    user.setNickname(props.path("nickname").asText(""));
                    user.setProfileImage(props.path("profile_image").asText(""));
                }
                return user;
            }
        }
    }
}
