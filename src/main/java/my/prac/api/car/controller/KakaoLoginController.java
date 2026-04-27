package my.prac.api.car.controller;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

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
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;

import my.prac.core.car.dto.CarUserDto;

@Controller
public class KakaoLoginController {

    private static final Logger logger = LoggerFactory.getLogger(KakaoLoginController.class);

    @Value("${kakaoKey}")
    private String kakaoClientId;

    @Value("${kakaoRedirectUri}")
    private String redirectUri;

    private static final String KAKAO_AUTH_URL =
            "https://kauth.kakao.com/oauth/authorize?client_id=%s&redirect_uri=%s&response_type=code";
    private static final String KAKAO_TOKEN_URL = "https://kauth.kakao.com/oauth/token";
    private static final String KAKAO_USER_URL  = "https://kapi.kakao.com/v2/user/me";

    @GetMapping("/car/login")
    public String loginPage() {
        return "car/login";
    }

    @GetMapping("/car/kakao/start")
    public void kakaoStart(HttpServletResponse response) throws IOException {
        String url = String.format(KAKAO_AUTH_URL, kakaoClientId, redirectUri);
        response.sendRedirect(url);
    }

    /** 카카오 개발자 콘솔 Redirect URI: http://sub.dev-apc.com/kakao/callback */
    @GetMapping("/kakao/callback")
    public String kakaoCallback(@RequestParam(required = false) String code,
                                @RequestParam(required = false) String error,
                                HttpSession session) {
        if (error != null || code == null) {
            logger.warn("Kakao OAuth error: {}", error);
            return "redirect:/car/login?error=kakao";
        }
        try {
            String accessToken = getKakaoAccessToken(code);
            CarUserDto carUser   = getKakaoUserInfo(accessToken);
            session.setAttribute("carUser", carUser);
            return "redirect:/car/board/list";
        } catch (Exception e) {
            logger.error("Kakao login failed", e);
            return "redirect:/car/login?error=server";
        }
    }

    @GetMapping("/car/logout")
    public String logout(HttpSession session) {
        session.invalidate();
        return "redirect:/car/login";
    }

    // ── 내부 메서드 ────────────────────────────────────────────────────────────

    private String getKakaoAccessToken(String code) throws IOException {
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
