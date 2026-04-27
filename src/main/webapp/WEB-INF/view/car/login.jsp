<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>자동차 관리기록부 - 로그인</title>
<style>
  * { box-sizing: border-box; margin: 0; padding: 0; }
  body {
    font-family: 'Apple SD Gothic Neo', 'Malgun Gothic', sans-serif;
    background: linear-gradient(135deg, #1a1a2e 0%, #16213e 50%, #0f3460 100%);
    min-height: 100vh;
    display: flex;
    align-items: center;
    justify-content: center;
  }
  .login-card {
    background: rgba(255,255,255,0.05);
    border: 1px solid rgba(255,255,255,0.1);
    border-radius: 20px;
    padding: 60px 50px;
    text-align: center;
    backdrop-filter: blur(10px);
    max-width: 420px;
    width: 90%;
    box-shadow: 0 25px 50px rgba(0,0,0,0.4);
  }
  .car-icon {
    font-size: 64px;
    margin-bottom: 20px;
  }
  h1 {
    color: #fff;
    font-size: 26px;
    font-weight: 700;
    margin-bottom: 8px;
  }
  .subtitle {
    color: rgba(255,255,255,0.5);
    font-size: 14px;
    margin-bottom: 40px;
  }
  .kakao-btn {
    display: flex;
    align-items: center;
    justify-content: center;
    gap: 12px;
    background: #FEE500;
    color: #3C1E1E;
    border: none;
    border-radius: 12px;
    padding: 16px 24px;
    font-size: 16px;
    font-weight: 700;
    cursor: pointer;
    text-decoration: none;
    transition: transform 0.1s, box-shadow 0.1s;
    width: 100%;
    box-shadow: 0 4px 15px rgba(254,229,0,0.3);
  }
  .kakao-btn:hover {
    transform: translateY(-2px);
    box-shadow: 0 8px 20px rgba(254,229,0,0.4);
  }
  .kakao-btn:active { transform: translateY(0); }
  .kakao-logo {
    width: 24px;
    height: 24px;
  }
  .error-msg {
    background: rgba(255,80,80,0.15);
    border: 1px solid rgba(255,80,80,0.3);
    color: #ff8080;
    border-radius: 8px;
    padding: 12px;
    font-size: 13px;
    margin-bottom: 20px;
  }
  .features {
    display: flex;
    gap: 20px;
    justify-content: center;
    margin-top: 36px;
    padding-top: 30px;
    border-top: 1px solid rgba(255,255,255,0.1);
  }
  .feature-item {
    color: rgba(255,255,255,0.5);
    font-size: 12px;
    text-align: center;
  }
  .feature-item .icon { font-size: 20px; display: block; margin-bottom: 4px; }
</style>
</head>
<body>

<div class="login-card">
  <div class="car-icon">&#x1F697;</div>
  <h1>자동차 관리기록부</h1>
  <p class="subtitle">내 차의 정비 이력을 한눈에 관리하세요</p>

  <%-- 에러 메시지 --%>
  <% if ("kakao".equals(request.getParameter("error"))) { %>
  <div class="error-msg">&#x26A0; 카카오 로그인이 취소되었습니다.</div>
  <% } else if ("server".equals(request.getParameter("error"))) { %>
  <div class="error-msg">&#x26A0; 로그인 처리 중 오류가 발생했습니다. 잠시 후 다시 시도해주세요.</div>
  <% } %>

  <a href="${pageContext.request.contextPath}/car/kakao/start" class="kakao-btn">
    <svg class="kakao-logo" viewBox="0 0 24 24" fill="#3C1E1E">
      <path d="M12 3C6.48 3 2 6.58 2 11c0 2.82 1.7 5.3 4.27 6.8L5.2 21l4.25-2.17c.83.18 1.7.27 2.55.27 5.52 0 10-3.58 10-8S17.52 3 12 3z"/>
    </svg>
    카카오 로그인
  </a>

  <div class="features">
    <div class="feature-item"><span class="icon">&#x1F527;</span>정비 기록</div>
    <div class="feature-item"><span class="icon">&#x1F4C5;</span>이력 관리</div>
    <div class="feature-item"><span class="icon">&#x1F4B0;</span>비용 추적</div>
  </div>
</div>

</body>
</html>
