<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>차량 운송 관리</title>
<style>
  * { box-sizing: border-box; margin: 0; padding: 0; }
  body { font-family: 'Apple SD Gothic Neo','Malgun Gothic', sans-serif; background: #f0f2f5; font-size: 13px; }

  /* ===== 상단바 ===== */
  .top-bar {
    background: #1e3a5f;
    color: #fff;
    padding: 0 16px;
    height: 52px;
    display: flex;
    align-items: center;
    justify-content: space-between;
    position: sticky;
    top: 0;
    z-index: 100;
  }
  .top-bar h1 { font-size: 16px; font-weight: 700; letter-spacing: -0.3px; }
  .nav-links { display: flex; gap: 14px; }
  .nav-links a {
    color: rgba(255,255,255,0.75);
    text-decoration: none;
    font-size: 12px;
  }
  .nav-links a:hover { color: #fff; }

  .container { padding: 14px 14px 80px; }

  /* ===== 검색 ===== */
  .search-box {
    background: #fff;
    border: 1px solid #dde1e7;
    border-radius: 10px;
    padding: 14px;
    margin-bottom: 12px;
  }
  .search-row {
    display: flex;
    flex-wrap: wrap;
    gap: 8px;
    align-items: center;
  }
  .search-field {
    display: flex;
    align-items: center;
    gap: 6px;
  }
  .search-field label { font-size: 12px; color: #555; white-space: nowrap; }
  .search-field input {
    border: 1px solid #ccc;
    border-radius: 5px;
    padding: 7px 10px;
    font-size: 13px;
    width: 130px;
  }
  .sep { color: #aaa; font-size: 12px; }
  .search-btns { display: flex; gap: 6px; margin-left: auto; }

  /* ===== 버튼 ===== */
  .btn {
    padding: 8px 16px;
    border: none;
    border-radius: 6px;
    cursor: pointer;
    font-size: 13px;
    font-weight: 600;
    white-space: nowrap;
    touch-action: manipulation;
  }
  .btn-search { background: #1e3a5f; color: #fff; }
  .btn-reset  { background: #eee;    color: #555; }
  .btn-search:active { background: #163060; }

  /* ===== 요약 카드 ===== */
  .summary-row {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 8px;
    margin-bottom: 12px;
  }
  .summary-card {
    background: #fff;
    border: 1px solid #dde1e7;
    border-radius: 10px;
    padding: 10px 14px;
    text-align: center;
  }
  .s-label { font-size: 11px; color: #888; margin-bottom: 3px; }
  .s-value { font-size: 16px; font-weight: 700; color: #1e3a5f; }
  .s-unit  { font-size: 10px; color: #888; margin-left: 1px; }

  /* ===== 테이블 (데스크탑) ===== */
  .table-wrap {
    background: #fff;
    border: 1px solid #dde1e7;
    border-radius: 10px;
    overflow: hidden;
  }
  .table-header {
    padding: 10px 14px;
    border-bottom: 1px solid #eee;
    display: flex;
    align-items: center;
    justify-content: space-between;
  }
  .table-header .count { font-size: 12px; color: #888; }
  table { width: 100%; border-collapse: collapse; }
  thead th {
    background: #f7f8fa;
    border-bottom: 2px solid #dde1e7;
    padding: 9px 8px;
    text-align: center;
    font-size: 12px;
    font-weight: 700;
    color: #444;
    white-space: nowrap;
  }
  tbody td {
    padding: 8px;
    border-bottom: 1px solid #f0f2f5;
    text-align: center;
    font-size: 12px;
    color: #333;
  }
  tbody tr:hover { background: #f5f8ff; }
  tbody tr:last-child td { border-bottom: none; }
  .td-supply  { text-align: right; font-weight: 700; color: #1565c0; }
  .td-company { text-align: right; font-weight: 700; color: #b71c1c; }
  tfoot td {
    background: #e8edf5;
    font-weight: 700;
    padding: 9px 8px;
    font-size: 12px;
    border-top: 2px solid #dde1e7;
  }
  .empty-row td { color: #aaa; padding: 40px; text-align: center; }

  .btn-edit {
    padding: 5px 12px;
    background: #1976d2; color: #fff;
    border: none; border-radius: 4px;
    font-size: 12px; cursor: pointer;
    touch-action: manipulation;
  }
  .btn-del {
    padding: 5px 12px;
    background: #e53935; color: #fff;
    border: none; border-radius: 4px;
    font-size: 12px; cursor: pointer;
    margin-left: 4px;
    touch-action: manipulation;
  }

  /* ===== 카드 뷰 (모바일) ===== */
  .card-list { display: none; }
  .transport-card {
    background: #fff;
    border: 1px solid #dde1e7;
    border-radius: 12px;
    padding: 14px;
    margin-bottom: 10px;
  }
  .card-top {
    display: flex;
    align-items: center;
    justify-content: space-between;
    margin-bottom: 10px;
  }
  .card-date { font-size: 13px; font-weight: 700; color: #1e3a5f; }
  .card-company { font-size: 12px; color: #666; }
  .card-driver {
    display: inline-block;
    background: #e8edf5;
    color: #1e3a5f;
    font-size: 12px;
    font-weight: 700;
    padding: 3px 10px;
    border-radius: 20px;
  }
  .card-route {
    display: flex;
    align-items: center;
    gap: 6px;
    font-size: 12px;
    color: #444;
    margin-bottom: 10px;
    flex-wrap: wrap;
  }
  .card-route .arrow { color: #1e3a5f; font-weight: 700; }
  .card-route .point {
    background: #f0f2f5;
    padding: 3px 8px;
    border-radius: 4px;
    flex: 1;
    min-width: 0;
    overflow: hidden;
    text-overflow: ellipsis;
    white-space: nowrap;
  }
  .card-info {
    display: flex;
    gap: 6px;
    flex-wrap: wrap;
    font-size: 11px;
    color: #888;
    margin-bottom: 10px;
  }
  .card-info .tag {
    background: #f7f8fa;
    border: 1px solid #eee;
    padding: 2px 8px;
    border-radius: 4px;
  }
  .card-prices {
    display: flex;
    gap: 8px;
    margin-bottom: 12px;
  }
  .card-price-box {
    flex: 1;
    background: #f7f8fa;
    border-radius: 8px;
    padding: 8px 10px;
    text-align: center;
  }
  .price-label { font-size: 10px; color: #888; margin-bottom: 2px; }
  .price-val { font-size: 14px; font-weight: 700; }
  .price-supply  { color: #1565c0; }
  .price-company { color: #b71c1c; }
  .card-actions { display: flex; gap: 8px; }
  .card-actions button {
    flex: 1;
    padding: 10px;
    border: none;
    border-radius: 8px;
    font-size: 14px;
    font-weight: 600;
    cursor: pointer;
    touch-action: manipulation;
  }
  .card-actions .btn-edit { background: #e3f0fb; color: #1565c0; padding: 10px; }
  .card-actions .btn-del  { background: #fde8e8; color: #c62828; margin-left: 0; padding: 10px; }

  /* ===== FAB (모바일 추가 버튼) ===== */
  .fab {
    display: none;
    position: fixed;
    bottom: 20px;
    right: 18px;
    width: 54px;
    height: 54px;
    background: #2e7d32;
    color: #fff;
    border: none;
    border-radius: 50%;
    font-size: 28px;
    line-height: 54px;
    text-align: center;
    text-decoration: none;
    box-shadow: 0 4px 16px rgba(0,0,0,0.22);
    z-index: 200;
    touch-action: manipulation;
  }

  /* ===== 모바일 미디어쿼리 ===== */
  @media (max-width: 700px) {
    .container { padding: 10px 10px 80px; }

    /* 검색폼 세로 정렬 */
    .search-row { flex-direction: column; align-items: stretch; gap: 10px; }
    .search-field { flex-wrap: wrap; }
    .search-field input { flex: 1; width: auto; min-width: 0; }
    .search-btns { margin-left: 0; }
    .search-btns .btn { flex: 1; padding: 10px; font-size: 14px; }

    /* 요약: 이미 2x2 그리드라 OK */
    .s-value { font-size: 14px; }

    /* 테이블 숨기고 카드 표시 */
    .table-wrap { display: none; }
    .card-list { display: block; }

    /* FAB 표시 */
    .fab { display: block; }

    /* 데스크탑 추가 버튼 숨김 */
    .btn-add-desktop { display: none; }

    /* 상단바 */
    .top-bar h1 { font-size: 14px; }
    .nav-links a { font-size: 11px; }
    .nav-links { gap: 10px; }
  }

  @media (min-width: 701px) {
    .btn-add-desktop {
      background: #2e7d32; color: #fff;
      text-decoration: none;
      padding: 8px 16px;
      border-radius: 6px;
      font-size: 13px;
      font-weight: 600;
      white-space: nowrap;
    }
    .btn-add-desktop:hover { background: #245f27; }
  }
</style>
</head>
<body>

<div class="top-bar">
  <h1>🚚 차량 운송 관리</h1>
  <div class="nav-links">
    <a href="${pageContext.request.contextPath}/car/board/list">정비기록부</a>
    <a href="${pageContext.request.contextPath}/">홈</a>
    <a href="${pageContext.request.contextPath}/car/logout">로그아웃</a>
  </div>
</div>

<div class="container">

  <%-- 검색 --%>
  <form method="get" action="${pageContext.request.contextPath}/transport/list">
    <div class="search-box">
      <div class="search-row">
        <div class="search-field">
          <label>날짜</label>
          <input type="date" name="dateFrom" value="${dateFrom}">
          <span class="sep">~</span>
          <input type="date" name="dateTo" value="${dateTo}">
        </div>
        <div class="search-field">
          <label>기사님</label>
          <input type="text" name="driverName" value="${driverName}" placeholder="기사님 이름">
        </div>
        <div class="search-field">
          <label>회사</label>
          <input type="text" name="company" value="${company}" placeholder="회사명">
        </div>
        <div class="search-btns">
          <button type="submit" class="btn btn-search">검색</button>
          <button type="button" class="btn btn-reset"
            onclick="location.href='${pageContext.request.contextPath}/transport/list'">초기화</button>
          <a href="${pageContext.request.contextPath}/transport/write" class="btn btn-add-desktop">+ 새 기록</a>
        </div>
      </div>
    </div>
  </form>

  <%-- 요약 --%>
  <div class="summary-row">
    <div class="summary-card">
      <div class="s-label">조회 건수</div>
      <div class="s-value">${list.size()}<span class="s-unit">건</span></div>
    </div>
    <div class="summary-card">
      <div class="s-label">공급가 합계</div>
      <div class="s-value"><fmt:formatNumber value="${totalSupply}" pattern="#,###"/><span class="s-unit">원</span></div>
    </div>
    <div class="summary-card">
      <div class="s-label">회사공급가 합계</div>
      <div class="s-value"><fmt:formatNumber value="${totalCompany}" pattern="#,###"/><span class="s-unit">원</span></div>
    </div>
    <div class="summary-card">
      <div class="s-label">마진 합계</div>
      <div class="s-value" style="color:#2e7d32;">
        <fmt:formatNumber value="${totalCompany - totalSupply}" pattern="#,###"/><span class="s-unit">원</span>
      </div>
    </div>
  </div>

  <%-- 데스크탑: 테이블 --%>
  <div class="table-wrap">
    <div class="table-header">
      <span class="count">총 <strong>${list.size()}</strong> 건</span>
    </div>
    <table>
      <thead>
        <tr>
          <th>날짜</th><th>기사님</th><th>회사</th>
          <th>상차</th><th>하차</th>
          <th>차종</th><th>차대번호</th>
          <th>공급가</th><th>회사공급가</th><th>관리</th>
        </tr>
      </thead>
      <tbody>
        <c:choose>
          <c:when test="${empty list}">
            <tr class="empty-row"><td colspan="10">등록된 운송 기록이 없습니다.</td></tr>
          </c:when>
          <c:otherwise>
            <c:forEach var="item" items="${list}">
            <tr>
              <td>${item.transportDate}</td>
              <td>${item.driverName}</td>
              <td>${item.company}</td>
              <td>${item.loadingPoint}</td>
              <td>${item.unloadingPoint}</td>
              <td>${item.carModel}</td>
              <td>${item.vehicleNo}</td>
              <td class="td-supply"><fmt:formatNumber value="${item.supplyPrice}" pattern="#,###"/></td>
              <td class="td-company"><fmt:formatNumber value="${item.companyPrice}" pattern="#,###"/></td>
              <td>
                <button class="btn-edit" onclick="location.href='${pageContext.request.contextPath}/transport/edit/${item.id}'">수정</button>
                <button class="btn-del" onclick="confirmDelete(${item.id})">삭제</button>
              </td>
            </tr>
            </c:forEach>
          </c:otherwise>
        </c:choose>
      </tbody>
      <c:if test="${not empty list}">
      <tfoot>
        <tr>
          <td colspan="7" style="text-align:right;color:#555;">합계</td>
          <td class="td-supply"><fmt:formatNumber value="${totalSupply}" pattern="#,###"/></td>
          <td class="td-company"><fmt:formatNumber value="${totalCompany}" pattern="#,###"/></td>
          <td></td>
        </tr>
      </tfoot>
      </c:if>
    </table>
  </div>

  <%-- 모바일: 카드 리스트 --%>
  <div class="card-list">
    <c:choose>
      <c:when test="${empty list}">
        <div style="text-align:center;color:#aaa;padding:40px 0;">등록된 운송 기록이 없습니다.</div>
      </c:when>
      <c:otherwise>
        <c:forEach var="item" items="${list}">
        <div class="transport-card">
          <div class="card-top">
            <div>
              <div class="card-date">${item.transportDate}</div>
              <div class="card-company">${item.company}</div>
            </div>
            <span class="card-driver">${item.driverName}</span>
          </div>
          <div class="card-route">
            <span class="point">${item.loadingPoint}</span>
            <span class="arrow">→</span>
            <span class="point">${item.unloadingPoint}</span>
          </div>
          <div class="card-info">
            <c:if test="${not empty item.carModel}">
              <span class="tag">🚗 ${item.carModel}</span>
            </c:if>
            <c:if test="${not empty item.vehicleNo}">
              <span class="tag">🔢 ${item.vehicleNo}</span>
            </c:if>
          </div>
          <div class="card-prices">
            <div class="card-price-box">
              <div class="price-label">공급가</div>
              <div class="price-val price-supply">
                <fmt:formatNumber value="${item.supplyPrice}" pattern="#,###"/>원
              </div>
            </div>
            <div class="card-price-box">
              <div class="price-label">회사공급가</div>
              <div class="price-val price-company">
                <fmt:formatNumber value="${item.companyPrice}" pattern="#,###"/>원
              </div>
            </div>
          </div>
          <div class="card-actions">
            <button class="btn-edit"
              onclick="location.href='${pageContext.request.contextPath}/transport/edit/${item.id}'">수정</button>
            <button class="btn-del" onclick="confirmDelete(${item.id})">삭제</button>
          </div>
        </div>
        </c:forEach>
      </c:otherwise>
    </c:choose>
  </div>

</div>

<%-- FAB (모바일 추가 버튼) --%>
<a href="${pageContext.request.contextPath}/transport/write" class="fab" title="새 기록 추가">+</a>

<form id="deleteForm" method="post">
  <input type="hidden" name="_method" value="delete">
</form>

<script>
function confirmDelete(id) {
  if (!confirm('삭제하시겠습니까?')) return;
  var f = document.getElementById('deleteForm');
  f.action = '${pageContext.request.contextPath}/transport/delete/' + id;
  f.submit();
}
</script>
</body>
</html>
