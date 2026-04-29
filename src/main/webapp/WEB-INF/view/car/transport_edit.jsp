<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>운송 기록 수정</title>
<style>
  * { box-sizing: border-box; margin: 0; padding: 0; }
  body { font-family: 'Malgun Gothic', sans-serif; background: #f0f2f5; font-size: 13px; }

  .top-bar {
    background: #1e3a5f;
    color: #fff;
    padding: 12px 20px;
    display: flex;
    align-items: center;
    gap: 12px;
  }
  .top-bar h1 { font-size: 17px; font-weight: 700; }
  .back-btn {
    color: rgba(255,255,255,0.7);
    text-decoration: none;
    font-size: 12px;
    margin-left: auto;
  }

  .container { padding: 20px; max-width: 760px; margin: 0 auto; }

  .form-card {
    background: #fff;
    border: 1px solid #dde1e7;
    border-radius: 10px;
    padding: 24px;
  }
  .form-card h2 {
    font-size: 15px;
    font-weight: 700;
    color: #1e3a5f;
    margin-bottom: 20px;
    padding-bottom: 12px;
    border-bottom: 2px solid #1e3a5f;
  }
  .form-grid {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 14px;
  }
  .form-group { display: flex; flex-direction: column; gap: 5px; }
  .form-group.full { grid-column: 1 / -1; }
  .form-group label { font-size: 12px; font-weight: 600; color: #555; }
  .form-group input {
    border: 1px solid #ccc;
    border-radius: 5px;
    padding: 8px 10px;
    font-size: 13px;
  }
  .form-group input:focus { outline: none; border-color: #1e3a5f; }
  .price-hint { font-size: 11px; color: #888; margin-top: 2px; }

  .btn-row { margin-top: 22px; display: flex; gap: 10px; justify-content: flex-end; }
  .btn { padding: 9px 22px; border: none; border-radius: 5px; cursor: pointer; font-size: 13px; font-weight: 600; }
  .btn-submit { background: #1e3a5f; color: #fff; }
  .btn-cancel { background: #eee; color: #555; }
</style>
</head>
<body>

<div class="top-bar">
  <h1>&#x1F697; 운송 기록 수정</h1>
  <a class="back-btn" href="${pageContext.request.contextPath}/transport/list">← 목록으로</a>
</div>

<div class="container">
  <div class="form-card">
    <h2>운송 기록 수정 (#${dto.id})</h2>
    <form method="post" action="${pageContext.request.contextPath}/transport/edit/${dto.id}">
      <div class="form-grid">

        <div class="form-group">
          <label>날짜 *</label>
          <input type="date" name="transportDate" value="${dto.transportDate}" required>
        </div>

        <div class="form-group">
          <label>기사님 *</label>
          <input type="text" name="driverName" value="${dto.driverName}" required maxlength="100">
        </div>

        <div class="form-group">
          <label>회사 *</label>
          <input type="text" name="company" value="${dto.company}" required maxlength="100">
        </div>

        <div class="form-group">
          <label>차종</label>
          <input type="text" name="carModel" value="${dto.carModel}" maxlength="100">
        </div>

        <div class="form-group">
          <label>상차 위치 *</label>
          <input type="text" name="loadingPoint" value="${dto.loadingPoint}" required maxlength="200">
        </div>

        <div class="form-group">
          <label>하차 위치 *</label>
          <input type="text" name="unloadingPoint" value="${dto.unloadingPoint}" required maxlength="200">
        </div>

        <div class="form-group full">
          <label>차대번호</label>
          <input type="text" name="vehicleNo" value="${dto.vehicleNo}" maxlength="50">
        </div>

        <div class="form-group">
          <label>공급가 (원)</label>
          <input type="number" name="supplyPrice" value="${dto.supplyPrice}" min="0">
          <span class="price-hint">기사님에게 지급하는 금액</span>
        </div>

        <div class="form-group">
          <label>회사공급가 (원)</label>
          <input type="number" name="companyPrice" value="${dto.companyPrice}" min="0">
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
