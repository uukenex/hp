<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>정비 상세 - 자동차 관리기록부</title>
<style>
  * { box-sizing: border-box; margin: 0; padding: 0; }
  body { font-family: 'Apple SD Gothic Neo', 'Malgun Gothic', sans-serif; background: #f5f7fa; color: #333; }

  .nav {
    background: #1a1a2e;
    padding: 0 30px;
    display: flex;
    align-items: center;
    justify-content: space-between;
    height: 60px;
    box-shadow: 0 2px 10px rgba(0,0,0,0.2);
  }
  .nav-brand { color: #fff; font-size: 18px; font-weight: 700; text-decoration: none; }
  .nav-user span { color: rgba(255,255,255,0.7); font-size: 14px; }

  .container { max-width: 760px; margin: 0 auto; padding: 30px 20px; }
  .breadcrumb { font-size: 13px; color: #999; margin-bottom: 20px; }
  .breadcrumb a { color: #1a73e8; text-decoration: none; }
  .breadcrumb a:hover { text-decoration: underline; }

  .card {
    background: #fff;
    border-radius: 12px;
    box-shadow: 0 2px 12px rgba(0,0,0,0.08);
    overflow: hidden;
    margin-bottom: 16px;
  }

  .card-header {
    background: linear-gradient(135deg, #1a1a2e 0%, #0f3460 100%);
    padding: 28px 32px;
    color: #fff;
  }
  .card-header .car-name { font-size: 24px; font-weight: 700; margin-bottom: 6px; }
  .card-header .car-meta { font-size: 14px; color: rgba(255,255,255,0.7); display: flex; gap: 20px; }

  .card-body { padding: 32px; }
  .info-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 0; }
  .info-item {
    padding: 16px 0;
    border-bottom: 1px solid #f5f5f5;
  }
  .info-item:nth-child(odd) { padding-right: 24px; border-right: 1px solid #f5f5f5; }
  .info-item:nth-child(even) { padding-left: 24px; }
  .info-label { font-size: 12px; color: #999; font-weight: 600; text-transform: uppercase; letter-spacing: 0.5px; margin-bottom: 6px; }
  .info-value { font-size: 15px; color: #1a1a2e; font-weight: 500; }
  .info-value.cost { font-size: 20px; font-weight: 700; color: #0f3460; }

  .type-badge {
    display: inline-block;
    padding: 4px 12px;
    border-radius: 20px;
    font-size: 13px;
    font-weight: 600;
    background: #e8f0fe;
    color: #1a73e8;
  }

  .description-section { margin-top: 24px; padding-top: 24px; border-top: 1px solid #f0f0f0; }
  .description-label { font-size: 12px; color: #999; font-weight: 600; text-transform: uppercase; letter-spacing: 0.5px; margin-bottom: 10px; }
  .description-content {
    background: #f8f9ff;
    border-radius: 8px;
    padding: 16px;
    font-size: 14px;
    line-height: 1.6;
    color: #444;
    white-space: pre-wrap;
    min-height: 60px;
  }

  .action-row {
    display: flex;
    gap: 10px;
    justify-content: flex-end;
  }
  .btn-back {
    background: #f5f7fa;
    color: #666;
    border: 1px solid #ddd;
    border-radius: 8px;
    padding: 10px 20px;
    font-size: 14px;
    font-weight: 600;
    cursor: pointer;
    text-decoration: none;
  }
  .btn-edit {
    background: #0f3460;
    color: #fff;
    border: none;
    border-radius: 8px;
    padding: 10px 20px;
    font-size: 14px;
    font-weight: 600;
    cursor: pointer;
    text-decoration: none;
    transition: background 0.2s;
  }
  .btn-edit:hover { background: #16213e; }
  .btn-delete {
    background: #fff;
    color: #e53935;
    border: 1px solid #e53935;
    border-radius: 8px;
    padding: 10px 20px;
    font-size: 14px;
    font-weight: 600;
    cursor: pointer;
    transition: all 0.2s;
  }
  .btn-delete:hover { background: #e53935; color: #fff; }

  .meta-info { font-size: 12px; color: #bbb; text-align: right; padding: 12px 32px; }
</style>
</head>
<body>

<nav class="nav">
  <a href="${pageContext.request.contextPath}/car/board/list" class="nav-brand">&#x1F697; 자동차 관리기록부</a>
  <div class="nav-user"><span>${carUser.nickname} 님</span></div>
</nav>

<div class="container">
  <div class="breadcrumb">
    <a href="${pageContext.request.contextPath}/car/board/list">목록</a> &gt; 정비 상세
  </div>

  <div class="card">
    <div class="card-header">
      <div class="car-name">${dto.carName}</div>
      <div class="car-meta">
        <span>&#x1F50D; ${dto.carNumber}</span>
        <span>&#x1F4C5; ${dto.maintenanceDate}</span>
      </div>
    </div>
    <div class="card-body">
      <div class="info-grid">
        <div class="info-item">
          <div class="info-label">정비유형</div>
          <div class="info-value"><span class="type-badge">${dto.maintenanceType}</span></div>
        </div>
        <div class="info-item">
          <div class="info-label">주행거리</div>
          <div class="info-value"><fmt:formatNumber value="${dto.mileage}" pattern="#,###" /> km</div>
        </div>
        <div class="info-item">
          <div class="info-label">정비소</div>
          <div class="info-value">${empty dto.shopName ? '-' : dto.shopName}</div>
        </div>
        <div class="info-item">
          <div class="info-label">비용</div>
          <div class="info-value cost"><fmt:formatNumber value="${dto.cost}" pattern="#,###" /> 원</div>
        </div>
      </div>

      <div class="description-section">
        <div class="description-label">상세 내용</div>
        <div class="description-content">${empty dto.description ? '(내용 없음)' : dto.description}</div>
      </div>
    </div>
    <div class="meta-info">
      등록: ${dto.createdAt}
      <c:if test="${not empty dto.updatedAt}"> &nbsp;|&nbsp; 수정: ${dto.updatedAt}</c:if>
    </div>
  </div>

  <div class="action-row">
    <a href="${pageContext.request.contextPath}/car/board/list" class="btn-back">목록으로</a>
    <a href="${pageContext.request.contextPath}/car/board/edit/${dto.id}" class="btn-edit">수정</a>
    <form action="${pageContext.request.contextPath}/car/board/delete/${dto.id}" method="post"
          onsubmit="return confirm('이 기록을 삭제하시겠습니까?');">
      <button type="submit" class="btn-delete">삭제</button>
    </form>
  </div>
</div>

</body>
</html>
