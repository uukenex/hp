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
  body { font-family: 'Apple SD Gothic Neo','Malgun Gothic', sans-serif; background: #f5f7fa; font-size: 13px; }

  /* ===== 상단바 ===== */
  .top-bar {
    background: #fff;
    color: #1565c0;
    padding: 0 16px;
    height: 52px;
    display: flex;
    align-items: center;
    justify-content: space-between;
    position: sticky;
    top: 0;
    z-index: 100;
    box-shadow: 0 1px 4px rgba(0,0,0,0.08);
  }
  .top-bar h1 { font-size: 16px; font-weight: 700; color: #1565c0; }
  .nav-links { display: flex; gap: 14px; }
  .nav-links a {
    color: #1976d2;
    text-decoration: none;
    font-size: 12px;
  }
  .nav-links a:hover { color: #1565c0; }

  .container { padding: 14px 14px 80px; }

  /* ===== 검색 ===== */
  .search-box {
    background: #fff;
    border: 1px solid #dde3ed;
    border-radius: 10px;
    padding: 14px;
    margin-bottom: 12px;
    box-shadow: 0 1px 4px rgba(0,0,0,0.04);
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
  .search-field input:focus {
    outline: none;
    border-color: #1976d2;
    box-shadow: 0 0 0 2px rgba(25,118,210,0.10);
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
    text-decoration: none;
    display: inline-flex;
    align-items: center;
    gap: 4px;
  }
  .btn-search  { background: #1976d2; color: #fff; }
  .btn-reset   { background: #eee;    color: #555; }
  .btn-new     { background: #2e7d32; color: #fff; }
  .btn-bulk    { background: #e8f0fe; color: #1565c0; border: 1px solid #90caf9; }
  .btn-col-filter { background: #f5f7fa; color: #555; border: 1px solid #ccc; }
  .btn-search:active { background: #1565c0; }
  .btn-new:hover     { background: #245f27; }
  .btn-bulk:hover    { background: #d0e4fd; }

  /* ===== 요약 카드 ===== */
  .summary-row {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 8px;
    margin-bottom: 12px;
  }
  .summary-card {
    background: #fff;
    border: 1px solid #dde3ed;
    border-radius: 10px;
    padding: 10px 14px;
    text-align: center;
    box-shadow: 0 1px 4px rgba(0,0,0,0.04);
  }
  .s-label { font-size: 11px; color: #888; margin-bottom: 3px; }
  .s-value { font-size: 16px; font-weight: 700; color: #1565c0; }
  .s-unit  { font-size: 10px; color: #888; margin-left: 1px; }

  /* ===== 테이블 래퍼 ===== */
  .table-wrap {
    background: #fff;
    border: 1px solid #dde3ed;
    border-radius: 10px;
    overflow: hidden;
    box-shadow: 0 1px 4px rgba(0,0,0,0.04);
  }
  .table-header {
    padding: 10px 14px;
    border-bottom: 1px solid #eee;
    display: flex;
    align-items: center;
    justify-content: space-between;
    gap: 8px;
  }
  .table-header .count { font-size: 12px; color: #888; }
  .table-header-right { display: flex; gap: 6px; align-items: center; }

  table { width: 100%; border-collapse: collapse; }
  thead th {
    background: #f0f4fa;
    border-bottom: 2px solid #dde3ed;
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
  tbody tr:hover { background: #f0f6ff; }
  tbody tr:last-child td { border-bottom: none; }
  .td-supply  { text-align: right; font-weight: 700; color: #1565c0; }
  .td-company { text-align: right; font-weight: 700; color: #b71c1c; }
  tfoot td {
    background: #e8edf5;
    font-weight: 700;
    padding: 9px 8px;
    font-size: 12px;
    border-top: 2px solid #dde3ed;
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

  /* ===== 컬럼 필터 패널 ===== */
  .col-filter-panel {
    display: none;
    background: #fff;
    border: 1px solid #dde3ed;
    border-radius: 8px;
    padding: 12px 16px;
    margin-bottom: 10px;
    box-shadow: 0 2px 8px rgba(0,0,0,0.08);
  }
  .col-filter-panel.open { display: block; }
  .col-filter-title { font-size: 12px; font-weight: 700; color: #444; margin-bottom: 8px; }
  .col-filter-list { display: flex; flex-wrap: wrap; gap: 8px; }
  .col-filter-list label {
    display: flex; align-items: center; gap: 4px;
    font-size: 12px; color: #555; cursor: pointer;
    background: #f5f7fa; border: 1px solid #dde3ed;
    border-radius: 20px; padding: 4px 10px;
    user-select: none;
    transition: background 0.1s;
  }
  .col-filter-list label:hover { background: #e8f0fe; }
  .col-filter-list input[type=checkbox] { accent-color: #1976d2; }

  /* ===== 카드 뷰 (모바일) ===== */
  .card-list { display: none; }
  .transport-card {
    background: #fff;
    border: 1px solid #dde3ed;
    border-radius: 12px;
    padding: 14px;
    margin-bottom: 10px;
    box-shadow: 0 1px 4px rgba(0,0,0,0.04);
  }
  .card-top {
    display: flex;
    align-items: center;
    justify-content: space-between;
    margin-bottom: 10px;
  }
  .card-date { font-size: 13px; font-weight: 700; color: #1565c0; }
  .card-company { font-size: 12px; color: #666; }
  .card-driver {
    display: inline-block;
    background: #e8f0fe;
    color: #1565c0;
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
  .card-route .arrow { color: #1976d2; font-weight: 700; }
  .card-route .point {
    background: #f5f7fa;
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
    background: #f5f7fa;
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
    background: #f5f7fa;
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

  /* ===== FAB ===== */
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

  /* ===== 모바일 ===== */
  @media (max-width: 700px) {
    .container { padding: 10px 10px 80px; }
    .search-row { flex-direction: column; align-items: stretch; gap: 10px; }
    .search-field { flex-wrap: wrap; }
    .search-field input { flex: 1; width: auto; min-width: 0; }
    .search-btns { margin-left: 0; flex-wrap: wrap; }
    .search-btns .btn { flex: 1; padding: 10px; font-size: 14px; }
    .s-value { font-size: 14px; }
    .table-wrap { display: none; }
    .card-list { display: block; }
    .fab { display: block; }
    .btn-add-desktop { display: none; }
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
      display: inline-flex;
      align-items: center;
      gap: 4px;
    }
    .btn-add-desktop:hover { background: #245f27; }
  }
</style>
</head>
<body>

<div class="top-bar">
  <h1>🚚 차량 운송 관리</h1>
  <div class="nav-links">
    <a href="${pageContext.request.contextPath}/">홈</a>
    <a href="${pageContext.request.contextPath}/car/logout">로그아웃</a>
  </div>
</div>

<%-- datalist: 기사님 이름 --%>
<datalist id="driverNameList">
  <c:forEach var="name" items="${driverNames}">
    <option value="${name}"/>
  </c:forEach>
</datalist>
<%-- datalist: 회사명 --%>
<datalist id="companyList">
  <c:forEach var="co" items="${companies}">
    <option value="${co}"/>
  </c:forEach>
</datalist>

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
          <input type="text" name="driverName" value="${driverName}"
                 placeholder="이름 입력 또는 선택"
                 list="driverNameList" autocomplete="off">
        </div>
        <div class="search-field">
          <label>회사</label>
          <input type="text" name="company" value="${company}"
                 placeholder="회사명 입력 또는 선택"
                 list="companyList" autocomplete="off">
        </div>
        <div class="search-btns">
          <button type="submit" class="btn btn-search">검색</button>
          <button type="button" class="btn btn-reset"
            onclick="location.href='${pageContext.request.contextPath}/transport/list'">초기화</button>
          <a href="${pageContext.request.contextPath}/transport/write"
             class="btn btn-new btn-add-desktop">+ 새 기록</a>
          <a href="${pageContext.request.contextPath}/transport/bulk"
             class="btn btn-bulk btn-add-desktop">📋 일괄입력</a>
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

  <%-- 컬럼 필터 패널 --%>
  <div class="col-filter-panel" id="colFilterPanel">
    <div class="col-filter-title">표시할 컬럼 선택</div>
    <div class="col-filter-list" id="colFilterList"></div>
  </div>

  <%-- 데스크탑: 테이블 --%>
  <div class="table-wrap">
    <div class="table-header">
      <span class="count">총 <strong>${list.size()}</strong> 건</span>
      <div class="table-header-right">
        <button type="button" class="btn btn-col-filter" onclick="toggleColFilter()">⚙ 컬럼</button>
      </div>
    </div>
    <table id="mainTable">
      <thead>
        <tr>
          <th data-col="날짜">날짜</th>
          <th data-col="기사님">기사님</th>
          <th data-col="회사">회사</th>
          <th data-col="상차">상차</th>
          <th data-col="하차">하차</th>
          <th data-col="차종">차종</th>
          <th data-col="차대번호">차대번호</th>
          <th data-col="공급가">공급가</th>
          <th data-col="회사공급가">회사공급가</th>
          <th data-col="관리">관리</th>
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
              <td data-col="날짜">${item.transportDate}</td>
              <td data-col="기사님">${item.driverName}</td>
              <td data-col="회사">${item.company}</td>
              <td data-col="상차">${item.loadingPoint}</td>
              <td data-col="하차">${item.unloadingPoint}</td>
              <td data-col="차종">${item.carModel}</td>
              <td data-col="차대번호">${item.vehicleNo}</td>
              <td data-col="공급가" class="td-supply"><fmt:formatNumber value="${item.supplyPrice}" pattern="#,###"/></td>
              <td data-col="회사공급가" class="td-company"><fmt:formatNumber value="${item.companyPrice}" pattern="#,###"/></td>
              <td data-col="관리">
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
/* ===== 삭제 확인 ===== */
function confirmDelete(id) {
  if (!confirm('삭제하시겠습니까?\n(숨김 처리되며 실제 삭제되지 않습니다)')) return;
  var f = document.getElementById('deleteForm');
  f.action = '${pageContext.request.contextPath}/transport/delete/' + id;
  f.submit();
}

/* ===== 컬럼 필터 ===== */
var COL_STORAGE_KEY = 'transport_hidden_cols';

// 숨길 수 없는 컬럼
var FIXED_COLS = ['관리'];

function getHiddenCols() {
  try {
    var v = localStorage.getItem(COL_STORAGE_KEY);
    return v ? JSON.parse(v) : [];
  } catch(e) { return []; }
}

function saveHiddenCols(hidden) {
  try { localStorage.setItem(COL_STORAGE_KEY, JSON.stringify(hidden)); } catch(e) {}
}

function applyColVisibility() {
  var hidden = getHiddenCols();
  var table = document.getElementById('mainTable');
  if (!table) return;

  // thead th
  table.querySelectorAll('thead th[data-col]').forEach(function(th) {
    var col = th.getAttribute('data-col');
    th.style.display = hidden.indexOf(col) >= 0 ? 'none' : '';
  });
  // tbody td, tfoot td — data-col 속성으로 처리
  table.querySelectorAll('tbody td[data-col], tfoot td[data-col]').forEach(function(td) {
    var col = td.getAttribute('data-col');
    td.style.display = hidden.indexOf(col) >= 0 ? 'none' : '';
  });
}

function buildColFilterUI() {
  var table = document.getElementById('mainTable');
  if (!table) return;
  var hidden = getHiddenCols();
  var container = document.getElementById('colFilterList');
  container.innerHTML = '';

  table.querySelectorAll('thead th[data-col]').forEach(function(th) {
    var col = th.getAttribute('data-col');
    if (FIXED_COLS.indexOf(col) >= 0) return; // 관리 컬럼은 항상 표시

    var label = document.createElement('label');
    var cb = document.createElement('input');
    cb.type = 'checkbox';
    cb.checked = hidden.indexOf(col) < 0;
    cb.dataset.col = col;
    cb.addEventListener('change', function() {
      var h = getHiddenCols();
      if (this.checked) {
        h = h.filter(function(c){ return c !== col; });
      } else {
        if (h.indexOf(col) < 0) h.push(col);
      }
      saveHiddenCols(h);
      applyColVisibility();
    });
    label.appendChild(cb);
    label.appendChild(document.createTextNode(' ' + col));
    container.appendChild(label);
  });
}

function toggleColFilter() {
  var panel = document.getElementById('colFilterPanel');
  panel.classList.toggle('open');
}

// 초기화
(function() {
  buildColFilterUI();
  applyColVisibility();
})();
</script>
</body>
</html>
