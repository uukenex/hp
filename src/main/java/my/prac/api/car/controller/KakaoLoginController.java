package my.prac.api.car.controller;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

import javax.servlet.http.HttpSession;

import org.apache.http.HttpEntity;
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
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;

import my.prac.core.car.dto.CarUserDto;

@Controller
@RequestMapping("/car")
public class KakaoLoginController {

    private static final Logger logger = LoggerFactory.getLogger(KakaoLoginController.class);

    // TODO: 카카오 개발자 콘솔에서 발급받은 REST API 키로 교체하세요
    private static final String KAKAO_CLIENT_ID = "YOUR_KAKAO_REST_API_KEY";
    // TODO: 카카오 개발자 콘솔 > 앱 설정 > Redirect URI에 등록한 값으로 교체하세요
    private static final String REDIRECT_URI = "http://localhost:8080/hp/car/kakao/callback";

    private static final String KAKAO_AUTH_URL =
            "https://kauth.kakao.com/oauth/authorize?client_id=%s&redirect_uri=%s&response_type=code";
    private static final String KAKAO_TOKEN_URL = "https://kauth.kakao.com/oauth/token";
    private static final String KAKAO_USER_URL = "https://kapi.kakao.com/v2/user/me";

    @GetMapping("/login")
    public String loginPage() {
        return "car/login";
    }

    @GetMapping("/kakao/start")
    public void kakaoStart(javax.servlet.http.HttpServletResponse response) throws IOException {
        String url = String.format(KAKAO_AUTH_URL, KAKAO_CLIENT_ID, REDIRECT_URI);
        response.sendRedirect(url);
    }

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
            CarUserDto carUser = getKakaoUserInfo(accessToken);
            session.setAttribute("carUser", carUser);
            return "redirect:/car/board/list";
        } catch (Exception e) {
            logger.error("Kakao login failed", e);
            return "redirect:/car/login?error=server";
        }
    }

    @GetMapping("/logout")
    public String logout(HttpSession session) {
        session.invalidate();
        return "redirect:/car/login";
    }

    private String getKakaoAccessToken(String code) throws IOException {
        try (CloseableHttpClient client = HttpClients.createDefault()) {
            HttpPost httpPost = new HttpPost(KAKAO_TOKEN_URL);

            List<NameValuePair> params = new ArrayList<>();
            params.add(new BasicNameValuePair("grant_type", "authorization_code"));
            params.add(new BasicNameValuePair("client_id", KAKAO_CLIENT_ID));
            params.add(new BasicNameValuePair("redirect_uri", REDIRECT_URI));
            params.add(new BasicNameValuePair("code", code));
            httpPost.setEntity(new UrlEncodedFormEntity(params, "UTF-8"));

            try (CloseableHttpResponse response = client.execute(httpPost)) {
                String body = EntityUtils.toString(response.getEntity(), "UTF-8");
                ObjectMapper mapper = new ObjectMapper();
                JsonNode root = mapper.readTree(body);
                if (root.has("error")) {
                    throw new RuntimeException("Kakao token error: " + root.get("error_description").asText());
                }
                return root.get("access_token").asText();
            }
        }
    }

    private CarUserDto getKakaoUserInfo(String accessToken) throws IOException {
        try (CloseableHttpClient client = HttpClients.createDefault()) {
            HttpGet httpGet = new HttpGet(KAKAO_USER_URL);
            httpGet.addHeader("Authorization", "Bearer " + accessToken);

            try (CloseableHttpResponse response = client.execute(httpGet)) {
                String body = EntityUtils.toString(response.getEntity(), "UTF-8");
                ObjectMapper mapper = new ObjectMapper();
                JsonNode root = mapper.readTree(body);

                CarUserDto user = new CarUserDto();
                user.setKakaoId(root.get("id").asText());

                JsonNode properties = root.path("properties");
                if (!properties.isMissingNode()) {
                    user.setNickname(properties.path("nickname").asText(""));
                    user.setProfileImage(properties.path("profile_image").asText(""));
                }

                return user;
            }
        }
    }
}
