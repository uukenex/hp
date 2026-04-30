<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>자동차 관리기록부</title>
<style>
  * { box-sizing: border-box; margin: 0; padding: 0; }
  body { font-family: 'Apple SD Gothic Neo', 'Malgun Gothic', sans-serif; background: #f5f7fa; color: #333; }

  /* 상단 네비 */
  .nav {
    background: #fff;
    padding: 0 30px;
    display: flex;
    align-items: center;
    justify-content: space-between;
    height: 60px;
    box-shadow: 0 1px 4px rgba(0,0,0,0.08);
  }
  .nav-brand { color: #1565c0; font-size: 18px; font-weight: 700; text-decoration: none; display: flex; align-items: center; gap: 8px; }
  .nav-user { display: flex; align-items: center; gap: 12px; }
  .nav-user span { color: #555; font-size: 14px; }
  .btn-logout {
    background: #f5f7fa;
    color: #555;
    border: 1px solid #dde3ed;
    border-radius: 6px;
    padding: 6px 14px;
    font-size: 13px;
    cursor: pointer;
    text-decoration: none;
    transition: background 0.2s;
  }
  .btn-logout:hover { background: #e8edf5; }

  /* 컨텐츠 영역 */
  .container { max-width: 1100px; margin: 0 auto; padding: 30px 20px; }

  /* 상단 타이틀 + 버튼 */
  .page-header { display: flex; align-items: center; justify-content: space-between; margin-bottom: 24px; }
  .page-title { font-size: 22px; font-weight: 700; color: #1565c0; }
  .btn-write {
    background: #1976d2;
    color: #fff;
    border: none;
    border-radius: 8px;
    padding: 10px 20px;
    font-size: 14px;
    font-weight: 600;
    cursor: pointer;
    text-decoration: none;
    transition: background 0.2s;
    display: flex;
    align-items: center;
    gap: 6px;
  }
  .btn-write:hover { background: #1565c0; }

  /* 테이블 */
  .card {
    background: #fff;
    border-radius: 12px;
    box-shadow: 0 2px 12px rgba(0,0,0,0.08);
    overflow: hidden;
  }
  table { width: 100%; border-collapse: collapse; }
  thead { background: #1976d2; }
  thead th { color: rgba(255,255,255,0.95); padding: 14px 16px; font-size: 13px; font-weight: 600; text-align: left; }
  tbody tr { border-bottom: 1px solid #f0f0f0; transition: background 0.15s; }
  tbody tr:hover { background: #f8f9ff; }
  tbody tr:last-child { border-bottom: none; }
  tbody td { padding: 14px 16px; font-size: 14px; color: #444; vertical-align: middle; }
  .car-name-cell { font-weight: 600; color: #1565c0; }
  .type-badge {
    display: inline-block;
    padding: 3px 10px;
    border-radius: 20px;
    font-size: 12px;
    font-weight: 600;
    background: #e8f0fe;
    color: #1a73e8;
  }
  .type-badge.tire { background: #fce8e6; color: #d93025; }
  .type-badge.brake { background: #fef7e0; color: #f9ab00; }
  .type-badge.wash { background: #e6f4ea; color: #34a853; }
  .type-badge.etc { background: #f1f3f4; color: #5f6368; }
  .cost-cell { font-weight: 600; color: #1565c0; }
  .detail-link { color: #1a73e8; text-decoration: none; font-weight: 500; }
  .detail-link:hover { text-decoration: underline; }

  /* 빈 상태 */
  .empty-state {
    text-align: center;
    padding: 80px 20px;
  }
  .empty-state .icon { font-size: 60px; margin-bottom: 16px; }
  .empty-state p { color: #999; font-size: 15px; margin-bottom: 24px; }

  /* 요약 카드 */
  .summary-row { display: flex; gap: 16px; margin-bottom: 24px; }
  .summary-card {
    background: #fff;
    border-radius: 10px;
    padding: 20px 24px;
    flex: 1;
    box-shadow: 0 2px 8px rgba(0,0,0,0.06);
    display: flex;
    align-items: center;
    gap: 16px;
  }
  .summary-icon { font-size: 32px; }
  .summary-label { font-size: 12px; color: #888; margin-bottom: 4px; }
  .summary-value { font-size: 22px; font-weight: 700; color: #1565c0; }
</style>
</head>
<body>

<!-- 네비 -->
<nav class="nav">
  <a href="${pageContext.request.contextPath}/car/board/list" class="nav-brand">
    &#x1F697; 자동차 관리기록부
  </a>
  <div class="nav-user">
    <span>${carUser.nickname} 님</span>
    <a href="${pageContext.request.contextPath}/car/logout" class="btn-logout">로그아웃</a>
  </div>
</nav>

<div class="container">

  <!-- 요약 -->
  <div class="summary-row">
    <div class="summary-card">
      <div class="summary-icon">&#x1F4CB;</div>
      <div>
        <div class="summary-label">총 정비 기록</div>
        <div class="summary-value">${fn:length(list)} 건</div>
      </div>
    </div>
    <div class="summary-card">
      <div class="summary-icon">&#x1F4B0;</div>
      <div>
        <div class="summary-label">총 정비 비용</div>
        <div class="summary-value">
          <c:set var="totalCost" value="0" />
          <c:forEach var="item" items="${list}">
            <c:set var="totalCost" value="${totalCost + item.cost}" />
          </c:forEach>
          <fmt:formatNumber value="${totalCost}" pattern="#,###" /> 원
        </div>
      </div>
    </div>
    <div class="summary-card">
      <div class="summary-icon">&#x1F527;</div>
      <div>
        <div class="summary-label">최근 정비</div>
        <div class="summary-value" style="font-size:15px;">
          <c:choose>
            <c:when test="${not empty list}">${list[0].maintenanceDate}</c:when>
            <c:otherwise>-</c:otherwise>
          </c:choose>
        </div>
      </div>
    </div>
  </div>

  <!-- 리스트 -->
  <div class="page-header">
    <div class="page-title">정비 이력</div>
    <a href="${pageContext.request.contextPath}/car/board/write" class="btn-write">
      &#x2B; 새 기록 추가
    </a>
  </div>

  <div class="card">
    <c:choose>
      <c:when test="${empty list}">
        <div class="empty-state">
          <div class="icon">&#x1F697;</div>
          <p>아직 등록된 정비 기록이 없습니다.</p>
          <a href="${pageContext.request.contextPath}/car/board/write" class="btn-write" style="display:inline-flex; margin:0 auto;">
            &#x2B; 첫 기록 추가하기
          </a>
        </div>
      </c:when>
      <c:otherwise>
        <table>
          <thead>
            <tr>
              <th>차량명</th>
              <th>차량번호</th>
              <th>정비일자</th>
              <th>주행거리</th>
              <th>정비유형</th>
              <th>정비소</th>
              <th>비용</th>
              <th></th>
            </tr>
          </thead>
          <tbody>
            <c:forEach var="item" items="${list}">
              <tr>
                <td class="car-name-cell">${item.carName}</td>
                <td>${item.carNumber}</td>
                <td>${item.maintenanceDate}</td>
                <td><fmt:formatNumber value="${item.mileage}" pattern="#,###" /> km</td>
                <td>
                  <c:choose>
                    <c:when test="${item.maintenanceType == '엔진오일'}">
                      <span class="type-badge">${item.maintenanceType}</span>
                    </c:when>
                    <c:when test="${item.maintenanceType == '타이어'}">
                      <span class="type-badge tire">${item.maintenanceType}</span>
                    </c:when>
                    <c:when test="${item.maintenanceType == '브레이크'}">
                      <span class="type-badge brake">${item.maintenanceType}</span>
                    </c:when>
                    <c:when test="${item.maintenanceType == '세차/광택'}">
                      <span class="type-badge wash">${item.maintenanceType}</span>
                    </c:when>
                    <c:otherwise>
                      <span class="type-badge etc">${item.maintenanceType}</span>
                    </c:otherwise>
                  </c:choose>
                </td>
                <td>${item.shopName}</td>
                <td class="cost-cell"><fmt:formatNumber value="${item.cost}" pattern="#,###" /> 원</td>
                <td><a href="${pageContext.request.contextPath}/car/board/detail/${item.id}" class="detail-link">상세보기</a></td>
              </tr>
            </c:forEach>
          </tbody>
        </table>
      </c:otherwise>
    </c:choose>
  </div>

</div>
</body>
</html>
