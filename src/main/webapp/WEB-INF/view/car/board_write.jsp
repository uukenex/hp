<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>정비 기록 추가 - 자동차 관리기록부</title>
<style>
  * { box-sizing: border-box; margin: 0; padding: 0; }
  body { font-family: 'Apple SD Gothic Neo', 'Malgun Gothic', sans-serif; background: #f5f7fa; color: #333; }

  .nav {
    background: #fff;
    padding: 0 30px;
    display: flex;
    align-items: center;
    justify-content: space-between;
    height: 60px;
    box-shadow: 0 1px 4px rgba(0,0,0,0.08);
  }
  .nav-brand { color: #1565c0; font-size: 18px; font-weight: 700; text-decoration: none; }
  .nav-user span { color: rgba(255,255,255,0.7); font-size: 14px; }

  .container { max-width: 760px; margin: 0 auto; padding: 30px 20px; }
  .page-title { font-size: 22px; font-weight: 700; color: #1565c0; margin-bottom: 24px; display: flex; align-items: center; gap: 10px; }

  .card {
    background: #fff;
    border-radius: 12px;
    box-shadow: 0 2px 12px rgba(0,0,0,0.08);
    padding: 36px;
  }

  .form-section { margin-bottom: 28px; }
  .section-title {
    font-size: 13px;
    font-weight: 700;
    color: #888;
    text-transform: uppercase;
    letter-spacing: 0.5px;
    margin-bottom: 16px;
    padding-bottom: 8px;
    border-bottom: 1px solid #f0f0f0;
  }
  .form-row { display: flex; gap: 16px; margin-bottom: 16px; }
  .form-group { flex: 1; display: flex; flex-direction: column; gap: 6px; }
  .form-group.full { flex: 1 1 100%; }
  label { font-size: 13px; font-weight: 600; color: #555; }
  label .required { color: #e53935; margin-left: 2px; }
  input, select, textarea {
    border: 1px solid #ddd;
    border-radius: 8px;
    padding: 10px 14px;
    font-size: 14px;
    font-family: inherit;
    color: #333;
    transition: border-color 0.2s, box-shadow 0.2s;
    background: #fafafa;
  }
  input:focus, select:focus, textarea:focus {
    outline: none;
    border-color: #1976d2;
    box-shadow: 0 0 0 3px rgba(15,52,96,0.1);
    background: #fff;
  }
  textarea { resize: vertical; min-height: 100px; }
  input[type="number"] { -moz-appearance: textfield; }

  .btn-row { display: flex; gap: 12px; justify-content: flex-end; margin-top: 32px; padding-top: 24px; border-top: 1px solid #f0f0f0; }
  .btn-cancel {
    background: #f5f7fa;
    color: #666;
    border: 1px solid #ddd;
    border-radius: 8px;
    padding: 11px 24px;
    font-size: 14px;
    font-weight: 600;
    cursor: pointer;
    text-decoration: none;
  }
  .btn-cancel:hover { background: #eee; }
  .btn-submit {
    background: #1976d2;
    color: #fff;
    border: none;
    border-radius: 8px;
    padding: 11px 28px;
    font-size: 14px;
    font-weight: 600;
    cursor: pointer;
    transition: background 0.2s;
  }
  .btn-submit:hover { background: #1565c0; }
</style>
</head>
<body>

<nav class="nav">
  <a href="${pageContext.request.contextPath}/car/board/list" class="nav-brand">&#x1F697; 자동차 관리기록부</a>
  <div class="nav-user"><span>${carUser.nickname} 님</span></div>
</nav>

<div class="container">
  <div class="page-title">&#x1F527; 정비 기록 추가</div>

  <div class="card">
    <form action="${pageContext.request.contextPath}/car/board/write" method="post">

      <div class="form-section">
        <div class="section-title">차량 정보</div>
        <div class="form-row">
          <div class="form-group">
            <label>차량명 <span class="required">*</span></label>
            <input type="text" name="carName" placeholder="예: 아반떼 N Line" required maxlength="100">
          </div>
          <div class="form-group">
            <label>차량번호</label>
            <input type="text" name="carNumber" placeholder="예: 12가 3456" maxlength="20">
          </div>
        </div>
      </div>

      <div class="form-section">
        <div class="section-title">정비 정보</div>
        <div class="form-row">
          <div class="form-group">
            <label>정비일자 <span class="required">*</span></label>
            <input type="date" name="maintenanceDate" required>
          </div>
          <div class="form-group">
            <label>주행거리 (km)</label>
            <input type="number" name="mileage" placeholder="예: 45000" min="0" max="9999999">
          </div>
        </div>
        <div class="form-row">
          <div class="form-group">
            <label>정비유형 <span class="required">*</span></label>
            <select name="maintenanceType" required>
              <option value="">-- 선택 --</option>
              <option value="엔진오일">엔진오일 교체</option>
              <option value="타이어">타이어 교체/점검</option>
              <option value="브레이크">브레이크 점검/교체</option>
              <option value="에어컨/히터">에어컨/히터 점검</option>
              <option value="배터리">배터리 교체</option>
              <option value="세차/광택">세차/광택</option>
              <option value="정기점검">정기점검</option>
              <option value="사고수리">사고수리</option>
              <option value="기타">기타</option>
            </select>
          </div>
          <div class="form-group">
            <label>정비소명</label>
            <input type="text" name="shopName" placeholder="예: 현대서비스센터 강남점" maxlength="200">
          </div>
        </div>
        <div class="form-row">
          <div class="form-group">
            <label>비용 (원)</label>
            <input type="number" name="cost" placeholder="예: 80000" min="0">
          </div>
        </div>
        <div class="form-row">
          <div class="form-group full">
            <label>상세 내용</label>
            <textarea name="description" placeholder="정비 상세 내용을 입력하세요. (교환한 부품, 특이사항 등)" maxlength="2000"></textarea>
          </div>
        </div>
      </div>

      <div class="btn-row">
        <a href="${pageContext.request.contextPath}/car/board/list" class="btn-cancel">취소</a>
        <button type="submit" class="btn-submit">저장</button>
      </div>
    </form>
  </div>
</div>

</body>
</html>
