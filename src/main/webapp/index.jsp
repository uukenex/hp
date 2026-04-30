<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>dev-apc</title>
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
  .wrap {
    text-align: center;
    padding: 40px 20px;
  }
  h1 {
    color: #fff;
    font-size: 28px;
    font-weight: 700;
    margin-bottom: 8px;
    letter-spacing: -0.5px;
  }
  .sub {
    color: rgba(255,255,255,0.4);
    font-size: 13px;
    margin-bottom: 48px;
  }
  .card-row {
    display: flex;
    gap: 20px;
    justify-content: center;
    flex-wrap: wrap;
  }
  .card {
    background: rgba(255,255,255,0.06);
    border: 1px solid rgba(255,255,255,0.12);
    border-radius: 16px;
    padding: 36px 32px;
    width: 200px;
    text-decoration: none;
    transition: transform 0.15s, background 0.15s;
    backdrop-filter: blur(8px);
  }
  .card:hover {
    transform: translateY(-4px);
    background: rgba(255,255,255,0.1);
  }
  .card .icon { font-size: 44px; display: block; margin-bottom: 14px; }
  .card .label {
    color: #fff;
    font-size: 15px;
    font-weight: 600;
  }
  .card .desc {
    color: rgba(255,255,255,0.45);
    font-size: 12px;
    margin-top: 6px;
  }
</style>
</head>
<body>
<div class="wrap">
  <h1>dev-apc</h1>
  <p class="sub">서비스를 선택해주세요</p>
  <div class="card-row">
    <a href="<%=request.getContextPath()%>/transport/list" class="card">
      <span class="icon">&#x1F69A;</span>
      <div class="label">차량 운송관리</div>
      <div class="desc">운송 정보 관리</div>
    </a>
    <!--
    <a href="<%=request.getContextPath()%>/bom/invite" class="card">
      <span class="icon">&#x1F490;</span>
      <div class="label">청첩장</div>
      <div class="desc">모바일 초대장</div>
    </a>
     -->
  </div>
</div>
</body>
</html>
