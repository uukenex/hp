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
  body { font-family: 'Malgun Gothic', sans-serif; background: #f0f2f5; font-size: 13px; }

  .top-bar {
    background: #1e3a5f;
    color: #fff;
    padding: 12px 20px;
    display: flex;
    align-items: center;
    justify-content: space-between;
  }
  .top-bar h1 { font-size: 17px; font-weight: 700; letter-spacing: -0.3px; }
  .top-bar .nav-links a {
    color: rgba(255,255,255,0.7);
    text-decoration: none;
    margin-left: 16px;
    font-size: 12px;
  }
  .top-bar .nav-links a:hover { color: #fff; }

  .container { padding: 16px 20px; }

  /* 검색 영역 */
  .search-box {
    background: #fff;
    border: 1px solid #dde1e7;
    border-radius: 8px;
    padding: 14px 16px;
    margin-bottom: 12px;
    display: flex;
    flex-wrap: wrap;
    gap: 10px;
    align-items: center;
  }
  .search-box label { font-size: 12px; color: #555; white-space: nowrap; }
  .search-box input {
    border: 1px solid #ccc;
    border-radius: 4px;
    padding: 5px 8px;
    font-size: 12px;
    width: 130px;
  }
  .search-box .sep { color: #aaa; font-size: 12px; }
  .btn {
    padding: 6px 14px;
    border: none;
    border-radius: 4px;
    cursor: pointer;
    font-size: 12px;
    font-weight: 600;
  }
  .btn-search { background: #1e3a5f; color: #fff; }
  .btn-reset  { background: #eee; color: #555; }
  .btn-add    { background: #2e7d32; color: #fff; margin-left: auto; }
  .btn-search:hover { background: #16305a; }
  .btn-add:hover    { background: #245f27; }

  /* 요약 */
  .summary-row {
    display: flex;
    gap: 10px;
    margin-bottom: 12px;
  }
  .summary-card {
    background: #fff;
    border: 1px solid #dde1e7;
    border-radius: 8px;
    padding: 10px 18px;
    flex: 1;
    text-align: center;
  }
  .summary-card .s-label { font-size: 11px; color: #888; margin-bottom: 4px; }
  .summary-card .s-value { font-size: 18px; font-weight: 700; color: #1e3a5f; }
  .summary-card .s-unit  { font-size: 11px; color: #888; margin-left: 2px; }

  /* 테이블 */
  .table-wrap {
    background: #fff;
    border: 1px solid #dde1e7;
    border-radius: 8px;
    overflow: hidden;
  }
  .table-header {
    padding: 10px 16px;
    border-bottom: 1px solid #eee;
    display: flex;
    align-items: center;
    justify-content: space-between;
  }
  .table-header .count { font-size: 12px; color: #888; }
  table {
    width: 100%;
    border-collapse: collapse;
  }
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
    padding: 8px 8px;
    border-bottom: 1px solid #f0f2f5;
    text-align: center;
    font-size: 12px;
    color: #333;
  }
  tbody tr:hover { background: #f5f8ff; }
  tbody tr:last-child td { border-bottom: none; }

  .td-price { text-align: right; font-weight: 600; color: #1e3a5f; }
  .td-supply  { color: #1565c0; font-weight: 700; }
  .td-company { color: #b71c1c; font-weight: 700; }

  .btn-edit {
    padding: 3px 10px;
    background: #1976d2;
    color: #fff;
    border: none;
    border-radius: 3px;
    font-size: 11px;
    cursor: pointer;
  }
  .btn-del {
    padding: 3px 10px;
    background: #e53935;
    color: #fff;
    border: none;
    border-radius: 3px;
    font-size: 11px;
    cursor: pointer;
    margin-left: 3px;
  }

  tfoot td {
    background: #e8edf5;
    font-weight: 700;
    padding: 9px 8px;
    font-size: 12px;
    border-top: 2px solid #dde1e7;
  }
  .empty-row td { color: #aaa; padding: 30px; text-align: center; }
</style>
</head>
<body>

<div class="top-bar">
  <h1>&#x1F697; 차량 운송 관리</h1>
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
      <label>날짜</label>
      <input type="date" name="dateFrom" value="${dateFrom}">
      <span class="sep">~</span>
      <input type="date" name="dateTo" value="${dateTo}">
      <label style="margin-left:8px;">기사님</label>
      <input type="text" name="driverName" value="${driverName}" placeholder="기사님 이름">
      <label>회사</label>
      <input type="text" name="company" value="${company}" placeholder="회사명">
      <button type="submit" class="btn btn-search">검색</button>
      <button type="button" class="btn btn-reset" onclick="location.href='${pageContext.request.contextPath}/transport/list'">초기화</button>
      <a href="${pageContext.request.contextPath}/transport/write" class="btn btn-add">+ 새 기록 추가</a>
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
      <div class="s-value" style="color:#2e7d32;"><fmt:formatNumber value="${totalCompany - totalSupply}" pattern="#,###"/><span class="s-unit">원</span></div>
    </div>
  </div>

  <%-- 테이블 --%>
  <div class="table-wrap">
    <div class="table-header">
      <span class="count">총 <strong>${list.size()}</strong> 건</span>
    </div>
    <table>
      <thead>
        <tr>
          <th>날짜</th>
          <th>기사님</th>
          <th>회사</th>
          <th>상차</th>
          <th>하차</th>
          <th>차종</th>
          <th>차대번호</th>
          <th>공급가</th>
          <th>회사공급가</th>
          <th>관리</th>
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
              <td class="td-price td-supply"><fmt:formatNumber value="${item.supplyPrice}" pattern="#,###"/></td>
              <td class="td-price td-company"><fmt:formatNumber value="${item.companyPrice}" pattern="#,###"/></td>
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
          <td colspan="7" style="text-align:right; color:#555;">합계</td>
          <td class="td-price td-supply"><fmt:formatNumber value="${totalSupply}" pattern="#,###"/></td>
          <td class="td-price td-company"><fmt:formatNumber value="${totalCompany}" pattern="#,###"/></td>
          <td></td>
        </tr>
      </tfoot>
      </c:if>
    </table>
  </div>

</div>

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
