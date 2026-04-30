<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>운송 기록 등록</title>
<style>
  * { box-sizing: border-box; margin: 0; padding: 0; }
  body { font-family: 'Apple SD Gothic Neo','Malgun Gothic', sans-serif; background: #f0f2f5; font-size: 13px; }

  .top-bar {
    background: #fff;
    color: #1565c0;
    padding: 0 16px;
    height: 52px;
    display: flex;
    align-items: center;
    position: sticky;
    top: 0;
    z-index: 100;
    box-shadow: 0 1px 4px rgba(0,0,0,0.08);
  }
  .top-bar h1 { font-size: 16px; font-weight: 700; color: #1565c0; }
  .back-btn {
    color: #1976d2;
    text-decoration: none;
    font-size: 13px;
    margin-left: auto;
    padding: 6px 0 6px 16px;
  }
  .back-btn:hover { color: #1565c0; }

  .container { padding: 16px 14px; max-width: 760px; margin: 0 auto; }

  .form-card {
    background: #fff;
    border: 1px solid #dde1e7;
    border-radius: 12px;
    padding: 20px;
  }
  .form-card h2 {
    font-size: 15px;
    font-weight: 700;
    color: #1565c0;
    margin-bottom: 18px;
    padding-bottom: 12px;
    border-bottom: 2px solid #1976d2;
  }

  .form-grid {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 14px;
  }
  .form-group { display: flex; flex-direction: column; gap: 6px; }
  .form-group.full { grid-column: 1 / -1; }
  .form-group label { font-size: 12px; font-weight: 700; color: #444; }
  .form-group input, .form-group select {
    border: 1px solid #ccc;
    border-radius: 8px;
    padding: 11px 12px;
    font-size: 14px;
    transition: border-color 0.15s;
    -webkit-appearance: none;
  }
  .form-group input:focus, .form-group select:focus {
    outline: none;
    border-color: #1976d2;
    box-shadow: 0 0 0 3px rgba(25,118,210,0.10);
  }
  .price-hint { font-size: 11px; color: #999; }

  .section-label {
    font-size: 11px;
    font-weight: 700;
    color: #888;
    letter-spacing: 0.5px;
    text-transform: uppercase;
    margin: 18px 0 10px;
    padding-bottom: 6px;
    border-bottom: 1px solid #eee;
    grid-column: 1 / -1;
  }

  .btn-row {
    margin-top: 24px;
    display: flex;
    gap: 10px;
    justify-content: flex-end;
  }
  .btn {
    padding: 12px 24px;
    border: none;
    border-radius: 8px;
    cursor: pointer;
    font-size: 14px;
    font-weight: 600;
    touch-action: manipulation;
  }
  .btn-submit { background: #1976d2; color: #fff; }
  .btn-cancel { background: #eee; color: #555; }
  .btn-submit:active { background: #1565c0; }

  /* ===== 모바일 ===== */
  @media (max-width: 600px) {
    .container { padding: 10px 10px; }
    .form-card { padding: 16px; border-radius: 10px; }
    .form-grid { grid-template-columns: 1fr; gap: 12px; }
    .form-group.full { grid-column: 1; }
    .form-group input, .form-group select {
      padding: 13px 14px;
      font-size: 16px; /* iOS 줌 방지: 16px 이상 */
      border-radius: 10px;
    }
    .btn-row { flex-direction: column-reverse; }
    .btn { width: 100%; padding: 15px; font-size: 16px; text-align: center; }
  }
</style>
</head>
<body>

<div class="top-bar">
  <h1>🚚 운송 기록 등록</h1>
  <a class="back-btn" href="${pageContext.request.contextPath}/transport/list">← 목록</a>
</div>

<div class="container">
  <div class="form-card">
    <h2>새 운송 기록 입력</h2>
    <form method="post" action="${pageContext.request.contextPath}/transport/write">
      <div class="form-grid">

        <div class="section-label">기본 정보</div>

        <div class="form-group">
          <label>날짜 *</label>
          <input type="date" name="transportDate" required>
        </div>

        <div class="form-group">
          <label>기사님 *</label>
          <input type="text" name="driverName" placeholder="기사님 이름" required maxlength="100">
        </div>

        <div class="form-group">
          <label>회사 *</label>
          <input type="text" name="company" placeholder="회사명" required maxlength="100">
        </div>

        <div class="form-group">
          <label>차종</label>
          <input type="text" name="carModel" placeholder="예) 쏘렌토, 투싼" maxlength="100">
        </div>

        <div class="section-label">운송 경로</div>

        <div class="form-group">
          <label>상차 위치 *</label>
          <input type="text" name="loadingPoint" placeholder="상차지 주소" required maxlength="200">
        </div>

        <div class="form-group">
          <label>하차 위치 *</label>
          <input type="text" name="unloadingPoint" placeholder="하차지 주소" required maxlength="200">
        </div>

        <div class="form-group full">
          <label>차대번호 (VIN)</label>
          <input type="text" name="vehicleNo" placeholder="차대번호" maxlength="50">
        </div>

        <div class="section-label">금액</div>

        <div class="form-group">
          <label>공급가 (원)</label>
          <input type="number" name="supplyPrice" placeholder="0" min="0" value="0" inputmode="numeric">
          <span class="price-hint">기사님에게 지급하는 금액</span>
        </div>

        <div class="form-group">
          <label>회사공급가 (원)</label>
          <input type="number" name="companyPrice" placeholder="0" min="0" value="0" inputmode="numeric">
          <span class="price-hint">고객사에 청구하는 금액</span>
        </div>

      </div>

      <div class="btn-row">
        <button type="button" class="btn btn-cancel" onclick="history.back()">취소</button>
        <button type="submit" class="btn btn-submit">저장</button>
      </div>
    </form>
  </div>
</div>

</body>
</html>
