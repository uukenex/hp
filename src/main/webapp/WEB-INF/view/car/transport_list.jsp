<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>차량 운송 관리</title>
<style>
  * { box-sizing: border-box; margin: 0; padding: 0; }
  body { font-family: 'Apple SD Gothic Neo','Malgun Gothic', sans-serif; background: #f5f7fa; font-size: 13px; }

  .top-bar {
    background: #fff; padding: 0 16px; height: 52px;
    display: flex; align-items: center; justify-content: space-between;
    position: sticky; top: 0; z-index: 100; box-shadow: 0 1px 4px rgba(0,0,0,0.08);
  }
  .top-bar h1 { font-size: 16px; font-weight: 700; color: #1565c0; }
  .nav-links { display: flex; gap: 14px; align-items: center; }
  .nav-links a { color: #1976d2; text-decoration: none; font-size: 12px; }

  .container { padding: 12px 12px 60px; }

  /* 월 선택 + 상태 */
  .toolbar { display: flex; align-items: center; gap: 8px; flex-wrap: wrap; margin-bottom: 10px; }
  .month-btn {
    padding: 8px 18px; border: 1px solid #b0bec5; background: #fff; color: #455a64;
    border-radius: 20px; font-size: 13px; font-weight: 600; cursor: pointer; touch-action: manipulation;
  }
  .month-btn.active { background: #1976d2; border-color: #1976d2; color: #fff; }
  .toolbar .spacer { flex: 1; }
  .filter-in { border: 1px solid #ccc; border-radius: 6px; padding: 7px 10px; font-size: 13px; width: 120px; }
  .filter-in:focus { outline: none; border-color: #1976d2; }
  .save-status { font-size: 12px; color: #888; min-width: 90px; text-align: right; }
  .save-status.saving { color: #f57c00; }
  .save-status.saved  { color: #2e7d32; }
  .save-status.error  { color: #c62828; font-weight: 700; }
  .btn-col-filter {
    background: #f5f7fa; color: #555; border: 1px solid #ccc; border-radius: 6px;
    padding: 7px 12px; font-size: 12px; font-weight: 600; cursor: pointer;
  }

  /* 요약 */
  .summary-row { display: grid; grid-template-columns: repeat(4, 1fr); gap: 8px; margin-bottom: 10px; }
  .summary-card {
    background: #fff; border: 1px solid #dde3ed; border-radius: 10px;
    padding: 8px 12px; text-align: center;
  }
  .s-label { font-size: 11px; color: #888; margin-bottom: 2px; }
  .s-value { font-size: 15px; font-weight: 700; color: #1565c0; }
  .s-unit  { font-size: 10px; color: #888; margin-left: 1px; }

  /* 컬럼 필터 */
  .col-filter-panel {
    display: none; background: #fff; border: 1px solid #dde3ed; border-radius: 8px;
    padding: 10px 14px; margin-bottom: 10px;
  }
  .col-filter-panel.open { display: block; }
  .col-filter-list { display: flex; flex-wrap: wrap; gap: 8px; }
  .col-filter-list label {
    display: flex; align-items: center; gap: 4px; font-size: 12px; color: #555; cursor: pointer;
    background: #f5f7fa; border: 1px solid #dde3ed; border-radius: 20px; padding: 4px 10px; user-select: none;
  }

  /* 그리드 */
  .grid-wrap {
    background: #fff; border: 1px solid #dde3ed; border-radius: 10px;
    overflow: auto; height: calc(100vh - 230px); min-height: 260px;
  }
  table { border-collapse: collapse; min-width: 100%; }
  thead th {
    background: #f0f4fa; border-bottom: 2px solid #dde3ed; border-right: 1px solid #e3e8f0;
    padding: 9px 6px; font-size: 12px; font-weight: 700; color: #444; white-space: nowrap;
    position: sticky; top: 0; z-index: 5;
  }
  thead th.red { color: #c62828; }
  tbody td { border-bottom: 1px solid #eef0f4; border-right: 1px solid #f0f2f5; padding: 0; }
  tbody td.td-no { text-align: center; font-size: 11px; color: #bbb; width: 34px; padding: 0 4px; }
  tbody td.td-del { text-align: center; width: 34px; }
  tbody tr:hover { background: #f4f8ff; }
  tbody tr.blank-row { background: #fcfdff; }
  tbody tr.row-error td { background: #fff3f3; }

  .cell {
    width: 100%; border: none; background: transparent; padding: 8px 7px; height: 34px;
    font-size: 13px; font-family: inherit; color: #222; outline: none;
  }
  .cell:focus { background: #fff8e1; box-shadow: inset 0 0 0 2px #f59f00; }
  .cell.num { text-align: right; font-weight: 600; }
  .cell.supply { color: #1565c0; }
  .cell.company-price { color: #b71c1c; }
  .cell[type="date"] { padding: 6px 4px; }

  .del-btn { background: none; border: none; color: #e53935; cursor: pointer; font-size: 15px; padding: 4px 8px; border-radius: 4px; }
  .del-btn:hover { background: #fde8e8; }
  tbody tr.blank-row .del-btn { visibility: hidden; }

  tfoot td {
    background: #e8edf5; font-weight: 700; padding: 8px 8px; font-size: 12px;
    border-top: 2px solid #dde3ed; position: sticky; bottom: 0; z-index: 4;
  }
  .foot-supply { text-align: right; color: #1565c0; }
  .foot-company { text-align: right; color: #b71c1c; }

  /* 좌측 고정 열 (#, 날짜) */
  th.th-no, td.td-no { position: sticky; left: 0; background: #fff; z-index: 3; }
  thead th.th-no { background: #f0f4fa; z-index: 7; }
  tfoot td.td-no { background: #e8edf5; z-index: 6; }
  td[data-col="0"], th[data-col="0"] { position: sticky; left: 34px; background: #fff; z-index: 3; box-shadow: 1px 0 0 #dde3ed; }
  thead th[data-col="0"] { background: #f0f4fa; z-index: 7; }
  tfoot td[data-col="0"] { background: #e8edf5; z-index: 6; }
  tbody tr:hover td.td-no, tbody tr:hover td[data-col="0"] { background: #f4f8ff; }
  tbody tr.blank-row td.td-no, tbody tr.blank-row td[data-col="0"] { background: #fcfdff; }
  #fillRow td { padding: 0; border: none; background: repeating-linear-gradient(to bottom, #fff 0, #fff 34px, #eef0f4 34px, #eef0f4 35px); }

  .btn-go { background: #1976d2; color: #fff; border: none; border-radius: 12px; padding: 5px 12px; font-size: 12px; font-weight: 700; cursor: pointer; }
  #sug { display: none; position: fixed; z-index: 400; background: #fff; border: 1px solid #90a4ae; border-radius: 6px; box-shadow: 0 4px 16px rgba(0,0,0,0.18); max-height: 230px; overflow-y: auto; min-width: 120px; }
  #sug .it { padding: 7px 10px; font-size: 13px; cursor: pointer; display: flex; justify-content: space-between; gap: 14px; white-space: nowrap; }
  #sug .it small { color: #888; font-size: 11px; }
  #sug .it.on, #sug .it:hover { background: #e3f0fb; }

  /* 이력 팝업 */
  .modal-bg { display: none; position: fixed; inset: 0; background: rgba(0,0,0,0.45); z-index: 500; align-items: center; justify-content: center; }
  .modal-bg.show { display: flex; }
  .modal { background: #fff; border-radius: 12px; width: min(900px, 94vw); max-height: 86vh; display: flex; flex-direction: column; box-shadow: 0 8px 32px rgba(0,0,0,0.25); }
  .modal-head { display: flex; align-items: center; justify-content: space-between; padding: 14px 18px; border-bottom: 1px solid #eee; font-size: 15px; font-weight: 700; color: #1565c0; }
  .modal-head button { background: none; border: none; font-size: 20px; cursor: pointer; color: #666; }
  .modal-body { overflow: auto; padding: 4px 18px 16px; }
  .hist-item { border-bottom: 1px solid #eef0f4; padding: 10px 0; }
  .hist-top { display: flex; gap: 8px; align-items: center; flex-wrap: wrap; font-size: 12px; color: #777; }
  .hist-badge { padding: 2px 8px; border-radius: 10px; font-size: 11px; font-weight: 700; color: #fff; }
  .hist-badge.INSERT { background: #2e7d32; } .hist-badge.UPDATE { background: #1976d2; } .hist-badge.DELETE { background: #c62828; }
  .hist-label { font-weight: 700; color: #333; margin: 4px 0 2px; font-size: 13px; }
  .hist-detail { white-space: pre-wrap; font-size: 12px; color: #444; background: #f7f9fc; border-radius: 6px; padding: 6px 10px; }
  .hist-empty { text-align: center; color: #aaa; padding: 40px 0; }
  .btn-save { background: #1976d2; color: #fff; border: none; border-radius: 6px; padding: 8px 18px; font-size: 13px; font-weight: 700; cursor: pointer; }
  .btn-save:active { background: #1565c0; }
  .btn-hist { background: #fff8e1; color: #8d6e00; border: 1px solid #ffe082; border-radius: 6px; padding: 7px 12px; font-size: 12px; font-weight: 600; cursor: pointer; }
  .auto-note { font-size: 11px; color: #999; }

  /* 열 너비 */
  .w-date { min-width: 118px; } .w-driver { min-width: 78px; } .w-co { min-width: 88px; }
  .w-point { min-width: 120px; } .w-model { min-width: 78px; } .w-vin { min-width: 105px; }
  .w-price { min-width: 88px; } .w-extra { min-width: 96px; } .w-remark { min-width: 140px; }

  @media (max-width: 700px) {
    .container { padding: 8px 8px 60px; }
    .summary-row { grid-template-columns: 1fr 1fr; }
    .top-bar h1 { font-size: 14px; }
    .grid-wrap { min-height: 320px; }
    .cell { font-size: 16px; height: 40px; }
  }
</style>
</head>
<body>

<div class="top-bar">
  <h1>🚚 차량 운송 관리 <span id="roleBadge" style="font-size:11px;font-weight:700;color:#fff;background:#6a1b9a;border-radius:10px;padding:2px 8px;margin-left:6px;display:none;">관리자</span></h1>
  <div class="nav-links">
    <a href="${pageContext.request.contextPath}/">홈</a>
    <a href="${pageContext.request.contextPath}/car/logout">로그아웃</a>
  </div>
</div>

<datalist id="driverNameList"></datalist>
<datalist id="companyList"></datalist>
<datalist id="loadingList"></datalist>
<datalist id="unloadingList"></datalist>

<div class="container">

  <div class="toolbar">
    <div id="monthBtns" style="display:flex;gap:6px;"></div>
    <span class="spacer"></span>
    <input type="text" id="fDriver" class="filter-in" placeholder="기사님 조회" list="driverNameList" autocomplete="off">
    <input type="text" id="fCompany" class="filter-in" placeholder="회사 조회" list="companyList" autocomplete="off">
    <span class="save-status" id="saveStatus"></span>
    <button type="button" class="btn-save" onclick="manualSave()">💾 저장</button>
    <span class="auto-note">다른 행으로 이동하면 자동저장됩니다</span>
    <button type="button" class="btn-hist" onclick="openHistory()">🕘 변경이력</button>
    <button type="button" class="btn-col-filter" onclick="toggleColFilter()">⚙ 컬럼</button>
  </div>

  <div class="summary-row">
    <div class="summary-card"><div class="s-label">건수</div><div class="s-value"><span id="sumCount">0</span><span class="s-unit">건</span></div></div>
    <div class="summary-card" id="cardSupply"><div class="s-label">공급가 합계</div><div class="s-value"><span id="sumSupply">0</span><span class="s-unit">원</span></div></div>
    <div class="summary-card" id="cardCompany"><div class="s-label">회사공급가 합계</div><div class="s-value"><span id="sumCompany">0</span><span class="s-unit">원</span></div></div>
    <div class="summary-card" id="cardMargin"><div class="s-label">마진 합계</div><div class="s-value" style="color:#2e7d32;"><span id="sumMargin">0</span><span class="s-unit">원</span></div></div>
  </div>

  <div class="col-filter-panel" id="colFilterPanel">
    <div class="col-filter-list" id="colFilterList"></div>
  </div>

  <div class="grid-wrap">
    <table id="grid">
      <thead><tr id="headRow"></tr></thead>
      <tbody id="gridBody"></tbody>
      <tbody id="fillBody"><tr id="fillRow"><td colspan="17"></td></tr></tbody>
      <tfoot><tr id="footRow"></tr></tfoot>
    </table>
  </div>

</div>

<div class="modal-bg" id="prevModal" onclick="if(event.target===this)closePrevPanel()">
  <div class="modal" style="width:min(340px,92vw);">
    <div class="modal-head"><span>📅 조회할 년월 선택</span><button type="button" onclick="closePrevPanel()">✕</button></div>
    <div class="modal-body" style="padding:18px;">
      <div id="prevEmpty" style="display:none;text-align:center;color:#999;padding:8px 0 18px;">조회할 수 있는 데이터가 없습니다.</div>
      <div style="display:flex;align-items:center;gap:8px;justify-content:center;margin-bottom:18px;">
        <select id="prevYear" style="border:1px solid #ccc;border-radius:6px;padding:9px;font-size:15px;" onchange="fillPrevMonths()"></select> <span>년</span>
        <select id="prevMonth" style="border:1px solid #ccc;border-radius:6px;padding:9px;font-size:15px;"></select>
      </div>
      <div style="display:flex;gap:8px;justify-content:flex-end;">
        <button type="button" class="btn-hist" style="padding:9px 18px;" onclick="closePrevPanel()">취소</button>
        <button type="button" class="btn-save" id="prevGo" onclick="goPrevMonth()">조회</button>
      </div>
    </div>
  </div>
</div>

<div class="modal-bg" id="histModal" onclick="if(event.target===this)closeHistory()">
  <div class="modal">
    <div class="modal-head"><span>🕘 변경 이력 (최근 300건)</span><button type="button" onclick="closeHistory()">✕</button></div>
    <div class="modal-body" id="histBody"></div>
  </div>
</div>

<script>
var CTX = '${pageContext.request.contextPath}';

/* ===== 컬럼 정의 ===== */
var COLS = [
  { key:'transportDate',  label:'날짜',          type:'date',  w:'w-date' },
  { key:'driverName',     label:'기사님',        type:'text',  w:'w-driver', list:'driverNameList' },
  { key:'company',        label:'회사',          type:'text',  w:'w-co',     list:'companyList' },
  { key:'loadingPoint',   label:'상차',          type:'text',  w:'w-point', list:'loadingList' },
  { key:'unloadingPoint', label:'하차',          type:'text',  w:'w-point', list:'unloadingList' },
  { key:'carModel',       label:'차종',          type:'text',  w:'w-model' },
  { key:'vehicleNo',      label:'차대번호',      type:'text',  w:'w-vin' },
  { key:'supplyPrice',    label:'공급가',        type:'num',   w:'w-price', cls:'supply' },
  { key:'companyPrice',   label:'회사공급가',    type:'num',   w:'w-price', cls:'company-price' },
  { key:'loadingPhone',   label:'상차폰,사업자', type:'text',  w:'w-extra' },
  { key:'photoPayment',   label:'사진,지급',     type:'text',  w:'w-extra' },
  { key:'deposit',        label:'입금',          type:'text',  w:'w-extra', red:true },
  { key:'invoiceIssued',  label:'계산서발행',    type:'text',  w:'w-extra' },
  { key:'statementDoc',   label:'내역서',        type:'text',  w:'w-extra' },
  { key:'remark',         label:'비고',          type:'text',  w:'w-remark' }
];
var DATE_IDX = 0, SUPPLY_IDX = 7, COMPANY_IDX = 8;

var rows = [];          // {id, tr, inputs[], timer, saving, dirty}
var curMonth = '';
var inflight = 0;       // 진행 중 저장 요청 수
var IDLE_SAVE_MS = 20000;  // 입력을 멈춘 채 20초 이상 머물면 자동 저장 (유실 방지)
var statusTimer = null;

/* ===== 유틸 ===== */
function pad(n){ return n < 10 ? '0' + n : '' + n; }
function ymOf(d){ return d.getFullYear() + '-' + pad(d.getMonth() + 1); }
function todayStr(){ var d = new Date(); return d.getFullYear() + '-' + pad(d.getMonth()+1) + '-' + pad(d.getDate()); }
function toNum(s){ var n = parseInt(String(s == null ? '' : s).replace(/[^0-9]/g, ''), 10); return isNaN(n) ? 0 : n; }
function fmt(n){ return n ? n.toLocaleString('ko-KR') : ''; }
function defaultDate(){ return curMonth === ymOf(new Date()) ? todayStr() : curMonth + '-01'; }

function setStatus(cls, text, autoClear) {
  var el = document.getElementById('saveStatus');
  el.className = 'save-status ' + cls;
  el.textContent = text;
  clearTimeout(statusTimer);
  if (autoClear) statusTimer = setTimeout(function(){ if (!inflight) { el.textContent = ''; } }, 2500);
}

function api(url, opts) {
  return fetch(CTX + url, opts).then(function(r) {
    // 세션 만료 시 로그인 페이지로 리다이렉트된 경우
    if (r.redirected || !r.ok) throw new Error('http ' + r.status);
    return r.json();
  });
}

/* ===== 월 버튼 (당월 포함 최근 3개월 + 이전) ===== */
function buildMonthBtns() {
  var box = document.getElementById('monthBtns');
  box.innerHTML = '';
  var now = new Date();
  var recent = [];
  for (var k = 2; k >= 0; k--) recent.push(ymOf(new Date(now.getFullYear(), now.getMonth() - k, 1)));
  var custom = recent.indexOf(curMonth) < 0;
  var pb = document.createElement('button');
  pb.type = 'button';
  pb.className = 'month-btn' + (custom ? ' active' : '');
  pb.textContent = custom ? curMonth.replace('-', '년 ').replace(/ 0?/, ' ') + '월' : '이전 ▾';
  pb.addEventListener('click', togglePrevPanel);
  box.appendChild(pb);
  for (var i = 2; i >= 0; i--) {
    var d = new Date(now.getFullYear(), now.getMonth() - i, 1);
    var ym = ymOf(d);

    var b = document.createElement('button');
    b.type = 'button';
    b.className = 'month-btn' + (ym === curMonth ? ' active' : '');
    b.textContent = (d.getMonth() + 1) + '월';
    b.dataset.ym = ym;
    b.addEventListener('click', function(){ closePrevPanel(); switchMonth(this.dataset.ym); });
    box.appendChild(b);
  }
  // 이전 버튼: 최근 3개월 밖의 달을 보고 있으면 그 달을 표시
}

var availMonths = [];   // 데이터가 있는 년월 (YYYY-MM, 최신순)

function togglePrevPanel() {
  document.getElementById('prevModal').classList.add('show');   // 화면을 어둡게 하고 가운데 팝업
  api('/transport/api/months').then(function(list) {
    availMonths = list || [];
    var ySel = document.getElementById('prevYear');
    ySel.innerHTML = '';
    var years = [];
    availMonths.forEach(function(ym) { var y = ym.substring(0, 4); if (years.indexOf(y) < 0) years.push(y); });
    years.forEach(function(y) { var o = document.createElement('option'); o.value = y; o.textContent = y; ySel.appendChild(o); });
    var has = years.length > 0;
    document.getElementById('prevEmpty').style.display = has ? 'none' : 'block';
    ySel.parentNode.style.display = has ? 'flex' : 'none';
    document.getElementById('prevGo').disabled = !has;
    if (has) {
      var base = curMonth || ymOf(new Date());
      ySel.value = years.indexOf(base.substring(0, 4)) >= 0 ? base.substring(0, 4) : years[0];
      fillPrevMonths(base.substring(5, 7));
    }
  }).catch(function() {
    document.getElementById('prevEmpty').textContent = '목록을 불러오지 못했습니다.';
    document.getElementById('prevEmpty').style.display = 'block';
    document.getElementById('prevYear').parentNode.style.display = 'none';
    document.getElementById('prevGo').disabled = true;
  });
}

/* 선택한 년도에 데이터가 있는 월만 표시 */
function fillPrevMonths(preferred) {
  var y = document.getElementById('prevYear').value;
  var sel = document.getElementById('prevMonth');
  sel.innerHTML = '';
  availMonths.forEach(function(ym) {
    if (ym.substring(0, 4) !== y) return;
    var o = document.createElement('option');
    o.value = ym.substring(5, 7);
    o.textContent = parseInt(ym.substring(5, 7), 10) + '월';
    sel.appendChild(o);
  });
  if (typeof preferred === 'string' && Array.prototype.some.call(sel.options, function(o) { return o.value === preferred; })) sel.value = preferred;
}
function closePrevPanel() { document.getElementById('prevModal').classList.remove('show'); }
function goPrevMonth() {
  var y = parseInt(document.getElementById('prevYear').value, 10);
  var m = document.getElementById('prevMonth').value;
  if (!y || !m) return;
  closePrevPanel();
  switchMonth(y + '-' + m);
}

function switchMonth(ym) {
  if (ym === curMonth) return;
  flushAll().then(function(){ loadMonth(ym); });
}

/* ===== 헤더/푸터 구성 ===== */
function buildHeader() {
  var head = document.getElementById('headRow');
  var foot = document.getElementById('footRow');
  head.innerHTML = '';
  foot.innerHTML = '';
  var thNo = document.createElement('th'); thNo.textContent = '#'; thNo.className = 'th-no'; head.appendChild(thNo);
  var tfNo = document.createElement('td'); tfNo.className = 'td-no'; foot.appendChild(tfNo);
  COLS.forEach(function(c, i) {
    var th = document.createElement('th');
    th.textContent = c.label;
    th.dataset.col = i;
    if (c.red) th.className = 'red';
    head.appendChild(th);
    var td = document.createElement('td');
    td.dataset.col = i;
    if (i === 0) { td.textContent = '합계'; td.style.textAlign = 'right'; }
    if (i === SUPPLY_IDX) { td.className = 'foot-supply'; td.id = 'footSupply'; }
    if (i === COMPANY_IDX) { td.className = 'foot-company'; td.id = 'footCompany'; }
    foot.appendChild(td);
  });
  head.appendChild(document.createElement('th'));
  foot.appendChild(document.createElement('td'));
}

/* ===== 행 생성 ===== */
function addRow(data) {
  var tbody = document.getElementById('gridBody');
  var tr = document.createElement('tr');
  var row = { id: data ? data.id : 0, tr: tr, inputs: [], timer: null, saving: false, dirty: false };

  var tdNo = document.createElement('td');
  tdNo.className = 'td-no';
  tr.appendChild(tdNo);

  COLS.forEach(function(c, i) {
    var td = document.createElement('td');
    td.dataset.col = i;
    var inp = document.createElement('input');
    inp.className = 'cell' + (c.type === 'num' ? ' num' : '') + (c.cls ? ' ' + c.cls : '') + ' ' + c.w;
    inp.autocomplete = 'off';
    inp.spellcheck = false;
    inp.dataset.i = i;
    if (c.type === 'date') {
      inp.type = 'date';
      inp.value = data ? (data[c.key] || '') : defaultDate();
    } else if (c.type === 'num') {
      inp.type = 'text';
      inp.inputMode = 'numeric';
      inp.value = data ? fmt(data[c.key]) : '';
      inp.addEventListener('focus', function(){ this.select(); });
    } else {
      inp.type = 'text';
      inp.value = data ? (data[c.key] || '') : '';
      if (c.list) inp.setAttribute('list', c.list);
      inp.maxLength = c.key === 'remark' ? 1000 : 200;
    }
    inp.addEventListener('focus', function(){ onFocusCell(row, this); });
    inp.addEventListener('input', function(){ onEdit(row, this); });
    inp.addEventListener('change', function(){ onCommit(row, this); });
    inp.addEventListener('blur', function(){ onCommit(row, this); });
    inp.addEventListener('keydown', function(e){ onKey(e, row, this); });
    td.appendChild(inp);
    tr.appendChild(td);
    row.inputs.push(inp);
  });

  var tdDel = document.createElement('td');
  tdDel.className = 'td-del';
  var del = document.createElement('button');
  del.type = 'button'; del.className = 'del-btn'; del.title = '삭제'; del.textContent = '✕';
  del.addEventListener('click', function(){ deleteRow(row); });
  tdDel.appendChild(del);
  tr.appendChild(tdDel);

  tbody.appendChild(tr);
  rows.push(row);
  refreshRowState(row);
  renumber();
  return row;
}

/* 날짜 기본값을 제외하고 입력된 내용이 있는지 */
function isBlank(row) {
  for (var i = 0; i < COLS.length; i++) {
    if (i === DATE_IDX) continue;
    if (row.inputs[i].value.trim() !== '') return false;
  }
  return true;
}

function refreshRowState(row) {
  row.tr.classList.toggle('blank-row', row.id === 0 && isBlank(row));
}

function ensureBlankRow() {
  var last = rows[rows.length - 1];
  if (!last || !isBlank(last) || last.id !== 0) addRow(null);
}

function renumber() {
  var n = 0;
  rows.forEach(function(r){ r.tr.firstChild.textContent = r.tr.style.display === "none" ? "" : ++n; });
  fitGrid();
}

/* ===== 편집 / 자동저장 ===== */
function onEdit(row, inp) {
  var i = +inp.dataset.i;
  if (COLS[i].type === 'num') {
    var raw = inp.value.replace(/[^0-9]/g, '');
    inp.value = raw ? parseInt(raw, 10).toLocaleString('ko-KR') : '';
  }
  row.touched = true; // 편집한 행은 조회 필터에 가려지지 않게
  refreshRowState(row);
  ensureBlankRow();
  updateTotals();
  updateSuggest(row, inp);
  scheduleSave(row, IDLE_SAVE_MS);   // 타자마다 저장하지 않음: 행을 벗어날 때 저장, 오래 멈추면 대비용으로 저장
}

function onCommit(row, inp) {
  hideSuggest();
  rememberValue(inp);
  // 다른 칸으로 이동하는 중일 수 있으므로 포커스 이동이 끝난 뒤 판단
  setTimeout(function() {
    if (autoRemoveIfBlank(row)) return;
    // 같은 행의 다른 칸으로 이동한 경우에는 저장하지 않고, 행 밖으로 나갔을 때 저장
    if ((row.timer || row.dirty) && !row.tr.contains(document.activeElement)) scheduleSave(row, 0);
  }, 0);
}

function scheduleSave(row, delay) {
  clearTimeout(row.timer);
  row.timer = null;
  if (row.id === 0 && isBlank(row)) return;
  row.dirty = true;
  setStatus('saving', '입력 중…');
  if (delay === 0) { saveRow(row); return; }
  row.timer = setTimeout(function(){ row.timer = null; saveRow(row); }, delay);
}

function collect(row) {
  var d = { id: row.id };
  COLS.forEach(function(c, i) {
    var v = row.inputs[i].value;
    d[c.key] = c.type === 'num' ? toNum(v) : v.trim();
  });
  return d;
}

function saveRow(row) {
  clearTimeout(row.timer);
  row.timer = null;
  if (row.removing) return Promise.resolve();
  if (autoRemoveIfBlank(row)) return Promise.resolve();
  if (!row.dirty) return Promise.resolve();
  if (row.saving) return row.promise || Promise.resolve(); // 저장 중이면 끝난 뒤 dirty 로 재저장
  if (!row.inputs[DATE_IDX].value) {
    row.tr.classList.add('row-error');
    setStatus('error', '날짜를 입력하세요');
    return Promise.resolve();
  }
  row.tr.classList.remove('row-error');
  row.dirty = false;
  row.saving = true;
  inflight++;
  setStatus('saving', '저장 중…');
  var data = collect(row);
  row.promise = api('/transport/api/save', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(data)
  }).then(function(res) {
    row.id = res.id;
    refreshRowState(row);
  }).catch(function() {
    row.dirty = true;
    row.tr.classList.add('row-error');
    setStatus('error', '저장 실패 - 다시 시도 중');
    row.retry = setTimeout(function(){ saveRow(row); }, 3000);
  }).then(function() {
    row.saving = false;
    inflight--;
    var p = row.dirty && !row.tr.classList.contains('row-error') ? saveRow(row) : Promise.resolve();
    if (!inflight && !pending()) setStatus('saved', '저장됨 ✓', true);
    return p;
  });
  return row.promise;
}

function pending() {
  return rows.some(function(r){ return r.dirty || r.saving || r.timer; });
}

function flushAll() {
  return Promise.all(rows.map(function(r){ return r.dirty ? saveRow(r) : r.promise || null; }));
}

window.addEventListener('beforeunload', function(e) {
  if (pending()) { flushAll(); e.preventDefault(); e.returnValue = ''; }
});
document.addEventListener('visibilitychange', function() {
  if (document.hidden) flushAll();
});

/* ===== 삭제 ===== */
function deleteRow(row) {
  if (row.id === 0 && isBlank(row)) return;
  if (!confirm('이 행을 삭제하시겠습니까?')) return;
  removeRow(row);
}

/* 날짜 외 내용이 모두 비면 자동 삭제 (포커스가 해당 행을 벗어났을 때) */
function autoRemoveIfBlank(row) {
  if (row.id > 0 && !row.removing && isBlank(row) && !row.tr.contains(document.activeElement)) {
    row.removing = true;
    removeRow(row);
    return true;
  }
  return false;
}

function removeRow(row) {
  clearTimeout(row.timer);
  row.dirty = false;
  var done = function() {
    var idx = rows.indexOf(row);
    if (idx >= 0) rows.splice(idx, 1);
    row.tr.remove();
    ensureBlankRow();
    renumber();
    updateTotals();
    setStatus('saved', '삭제되었습니다', true);
  };
  var wait = row.promise || Promise.resolve();
  wait.then(function() {
    if (row.id > 0) {
      api('/transport/api/delete/' + row.id, { method: 'POST' }).then(done).catch(function(){ row.removing = false; setStatus('error', '삭제 실패'); });
    } else { done(); }
  });
}

/* ===== 키보드 이동 ===== */
function onKey(e, row, inp) {
  if (sugOpen() && handleSugKey(e)) return;
  var idx = rows.indexOf(row);
  var col = +inp.dataset.i;
  var target = null;
  if (e.key === 'Enter') {
    e.preventDefault();
    target = rows[idx + 1];
    if (!target) { ensureBlankRow(); target = rows[idx + 1]; }
  } else if (e.key === 'ArrowDown' && inp.type !== 'date') {
    target = rows[idx + 1];
  } else if (e.key === 'ArrowUp' && inp.type !== 'date') {
    target = rows[idx - 1];
  }
  if (target) { e.preventDefault(); var t = target.inputs[col]; t.focus(); if (t.select) t.select(); }
}

/* ===== 기사님/회사 조회 (표시 중인 월 안에서 필터) ===== */
function rowMatches(r, drv, co) {
  if (r.touched || isBlank(r)) return true;
  return r.inputs[1].value.toLowerCase().indexOf(drv) >= 0 && r.inputs[2].value.toLowerCase().indexOf(co) >= 0;
}
function applyFilter() {
  var drv = document.getElementById("fDriver").value.trim().toLowerCase();
  var co  = document.getElementById("fCompany").value.trim().toLowerCase();
  rows.forEach(function(r){ r.tr.style.display = rowMatches(r, drv, co) ? "" : "none"; });
  renumber();
  updateTotals();
}

/* ===== 합계 ===== */
function updateTotals() {
  var cnt = 0, s = 0, c = 0;
  rows.forEach(function(r) {
    if ((r.id === 0 && isBlank(r)) || r.tr.style.display === "none") return;
    cnt++;
    s += toNum(r.inputs[SUPPLY_IDX].value);
    c += toNum(r.inputs[COMPANY_IDX].value);
  });
  document.getElementById('sumCount').textContent = cnt;
  document.getElementById('sumSupply').textContent = s.toLocaleString('ko-KR');
  document.getElementById('sumCompany').textContent = c.toLocaleString('ko-KR');
  document.getElementById('sumMargin').textContent = (c - s).toLocaleString('ko-KR');
  document.getElementById('footSupply').textContent = s.toLocaleString('ko-KR');
  document.getElementById('footCompany').textContent = c.toLocaleString('ko-KR');
}

/* ===== 데이터 로드 ===== */
function fillDatalist(id, arr) {
  var dl = document.getElementById(id);
  dl.innerHTML = '';
  (arr || []).forEach(function(v) {
    var o = document.createElement('option');
    o.value = v;
    dl.appendChild(o);
  });
}

function loadMonth(ym) {
  setStatus('saving', '불러오는 중…');
  return api('/transport/api/list?month=' + encodeURIComponent(ym)).then(function(res) {
    curMonth = res.month;
    document.getElementById('roleBadge').style.display = res.isAdmin ? 'inline' : 'none';
    buildMonthBtns();
    fillDatalist('driverNameList', res.driverNames);
    fillDatalist('companyList', res.companies);
    fillDatalist('loadingList', res.loadingPoints);
    fillDatalist('unloadingList', res.unloadingPoints);
    document.getElementById('gridBody').innerHTML = '';
    rows = [];
    (res.list || []).forEach(function(d){ addRow(d); });
    addRow(null);
    updateTotals();
    applyColVisibility();
    applyFilter();
    setStatus('', '');
    try { localStorage.setItem('transport_month', curMonth); } catch(e) {}
  }).catch(function() {
    setStatus('error', '불러오기 실패 (로그인 만료 시 새로고침)');
  });
}

/* ===== 컬럼 필터 ===== */
var COL_STORAGE_KEY = 'transport_hidden_cols2';
function getHiddenCols() {
  try { var v = localStorage.getItem(COL_STORAGE_KEY); return v ? JSON.parse(v) : []; } catch(e) { return []; }
}
function applyColVisibility() {
  var hidden = getHiddenCols();
  document.querySelectorAll('#grid [data-col]').forEach(function(el) {
    el.style.display = hidden.indexOf(+el.dataset.col) >= 0 ? 'none' : '';
  });
  var sh = hidden.indexOf(SUPPLY_IDX) >= 0, ch = hidden.indexOf(COMPANY_IDX) >= 0;
  document.getElementById('cardSupply').style.display  = sh ? 'none' : '';
  document.getElementById('cardCompany').style.display = ch ? 'none' : '';
  document.getElementById('cardMargin').style.display  = (sh || ch) ? 'none' : '';
}
function buildColFilterUI() {
  var box = document.getElementById('colFilterList');
  box.innerHTML = '';
  var hidden = getHiddenCols();
  COLS.forEach(function(c, i) {
    var label = document.createElement('label');
    var cb = document.createElement('input');
    cb.type = 'checkbox';
    cb.checked = hidden.indexOf(i) < 0;
    cb.addEventListener('change', function() {
      var h = getHiddenCols().filter(function(x){ return x !== i; });
      if (!this.checked) h.push(i);
      try { localStorage.setItem(COL_STORAGE_KEY, JSON.stringify(h)); } catch(e) {}
      applyColVisibility();
    });
    label.appendChild(cb);
    label.appendChild(document.createTextNode(' ' + c.label));
    box.appendChild(label);
  });
}
function toggleColFilter() {
  document.getElementById('colFilterPanel').classList.toggle('open');
}

/* ===== 화면 높이 채우기 ===== */
function fitGrid() {
  var wrap = document.querySelector('.grid-wrap');
  var h = Math.max(260, window.innerHeight - wrap.getBoundingClientRect().top - 16);
  wrap.style.height = h + 'px';
  var td = document.querySelector('#fillRow td');
  td.style.height = '0px';
  var used = document.getElementById('grid').offsetHeight;
  td.style.height = Math.max(0, wrap.clientHeight - used) + 'px';
}
window.addEventListener('resize', fitGrid);

/* ===== 수동 저장 ===== */
function manualSave() {
  setStatus('saving', '저장 중…');
  flushAll().then(function() {
    if (!pending()) setStatus('saved', '저장됨 ✓', true);
  });
}

/* ===== 변경 이력 팝업 ===== */
function openHistory() {
  var body = document.getElementById('histBody');
  body.innerHTML = '<div class="hist-empty">불러오는 중…</div>';
  document.getElementById('histModal').classList.add('show');
  flushAll().then(function() { return api('/transport/api/history'); }).then(function(list) {
    body.innerHTML = '';
    if (!list.length) { body.innerHTML = '<div class="hist-empty">변경 이력이 없습니다.</div>'; return; }
    var names = { INSERT: '등록', UPDATE: '수정', DELETE: '삭제' };
    list.forEach(function(h) {
      var item = document.createElement('div'); item.className = 'hist-item';
      var top = document.createElement('div'); top.className = 'hist-top';
      var badge = document.createElement('span'); badge.className = 'hist-badge ' + h.action; badge.textContent = names[h.action] || h.action;
      var when = document.createElement('span'); when.textContent = h.changedAt + (h.changedBy ? ' · ' + h.changedBy : '') + ' · #' + h.transportId;
      top.appendChild(badge); top.appendChild(when);
      var label = document.createElement('div'); label.className = 'hist-label'; label.textContent = h.rowLabel || '';
      var detail = document.createElement('div'); detail.className = 'hist-detail';
      detail.textContent = (h.action === 'DELETE' ? '삭제된 내용\n' : '') + (h.detail || '');
      item.appendChild(top); item.appendChild(label); item.appendChild(detail);
      body.appendChild(item);
    });
  }).catch(function() { body.innerHTML = '<div class="hist-empty">이력을 불러오지 못했습니다.</div>'; });
}
function closeHistory() { document.getElementById('histModal').classList.remove('show'); }
document.addEventListener('keydown', function(e) {
  if (e.key === 'Escape') { closeHistory(); closePrevPanel(); }
  if (e.key === 'Enter' && document.getElementById('prevModal').classList.contains('show')) goPrevMonth();
});

/* ===== 자동입력 추천 (차종 / 공급가 / 회사공급가) ===== */
var CAR_MODELS = [
  '아반떼','쏘나타','그랜저','싼타페','투싼','팰리세이드','코나','캐스퍼','스타리아','포터','베뉴','넥쏘','벨로스터','아이오닉5','아이오닉6',
  '제네시스 G70','제네시스 G80','제네시스 G90','GV60','GV70','GV80',
  '모닝','레이','K3','K5','K8','K9','스포티지','쏘렌토','카니발','셀토스','니로','쏘울','모하비','봉고','EV3','EV6','EV9','스팅어','스토닉',
  'SM6','QM6','XM3','아르카나','그랑 콜레오스',
  '티볼리','코란도','렉스턴','토레스','액티언',
  '스파크','트랙스','트레일블레이저','말리부','이쿼녹스','볼트',
  'BMW 1시리즈','BMW 3시리즈','BMW 5시리즈','BMW 7시리즈','BMW X1','BMW X3','BMW X4','BMW X5','BMW X6','BMW X7','BMW 4시리즈','BMW 6시리즈','BMW 8시리즈','BMW Z4','BMW i4','BMW iX',
  '벤츠 A클래스','벤츠 C클래스','벤츠 E클래스','벤츠 S클래스','벤츠 CLA','벤츠 CLS','벤츠 GLA','벤츠 GLB','벤츠 GLC','벤츠 GLE','벤츠 GLS','벤츠 G클래스','벤츠 EQE','벤츠 EQS','벤츠 마이바흐',
  '아우디 A3','아우디 A4','아우디 A5','아우디 A6','아우디 A7','아우디 A8','아우디 Q3','아우디 Q5','아우디 Q7','아우디 Q8','아우디 e-tron','아우디 TT',
  '폭스바겐 골프','폭스바겐 티구안','폭스바겐 파사트','폭스바겐 아테온','폭스바겐 투아렉','폭스바겐 제타','폭스바겐 ID.4',
  '볼보 S60','볼보 S90','볼보 V60','볼보 XC40','볼보 XC60','볼보 XC90',
  '테슬라 모델3','테슬라 모델Y','테슬라 모델S','테슬라 모델X','테슬라 사이버트럭',
  '렉서스 ES','렉서스 LS','렉서스 NX','렉서스 RX','렉서스 UX','렉서스 LC',
  '토요타 캠리','토요타 프리우스','토요타 라브4','토요타 시에나','토요타 크라운','혼다 어코드','혼다 CR-V','혼다 시빅','닛산 알티마','닛산 로그','마쯔다 CX-5','스바루 포레스터',
  '미니 쿠퍼','미니 컨트리맨','미니 클럽맨',
  '포르쉐 카이엔','포르쉐 마칸','포르쉐 파나메라','포르쉐 911','포르쉐 타이칸','포르쉐 박스터','포르쉐 카이맨',
  '랜드로버 디펜더','랜드로버 레인지로버','랜드로버 디스커버리','랜드로버 이보크','재규어 F-PACE','재규어 XF',
  '포드 머스탱','포드 익스플로러','포드 F-150','링컨 에비에이터','링컨 노틸러스','캐딜락 에스컬레이드','캐딜락 CT5','지프 랭글러','지프 체로키','지프 그랜드체로키','크라이슬러 300C','닷지 챌린저','쉐보레 콜로라도','쉐보레 타호','GMC 시에라',
  '푸조 3008','푸조 5008','시트로엥 C5','DS 7','피아트 500','알파로메오 스텔비오','마세라티 기블리','마세라티 르반떼','페라리 로마','람보르기니 우라칸','벤틀리 벤테이가','롤스로이스 컬리넌','맥라렌 720S','애스턴마틴 DB11',
  '폴스타 2','BYD 아토3','리비안 R1T'
];
var CAR_IDX = 5;
var sug = { el: null, items: [], active: -1, inp: null, row: null };

function sugOpen() { return sug.el && sug.el.style.display === 'block'; }
function hideSuggest() {
  if (sug.el) sug.el.style.display = 'none';
  sug.items = []; sug.active = -1;
}

function showSuggest(row, inp, items) {
  if (!items.length) { hideSuggest(); return; }
  if (!sug.el) {
    sug.el = document.createElement('div');
    sug.el.id = 'sug';
    document.body.appendChild(sug.el);
  }
  sug.items = items; sug.active = -1; sug.inp = inp; sug.row = row;
  sug.el.innerHTML = '';
  items.forEach(function(it, k) {
    var d = document.createElement('div');
    d.className = 'it';
    var a = document.createElement('span'); a.textContent = it.text;
    d.appendChild(a);
    if (it.hint) { var s = document.createElement('small'); s.textContent = it.hint; d.appendChild(s); }
    d.addEventListener('mousedown', function(e) { e.preventDefault(); pickSuggest(k); }); // blur 방지
    sug.el.appendChild(d);
  });
  var r = inp.getBoundingClientRect();
  sug.el.style.left = r.left + 'px';
  sug.el.style.top = r.bottom + 'px';
  sug.el.style.minWidth = Math.max(120, r.width) + 'px';
  sug.el.style.display = 'block';
}

function setSugActive(k) {
  sug.active = k;
  Array.prototype.forEach.call(sug.el.children, function(c, i) { c.classList.toggle('on', i === k); });
  if (k >= 0) sug.el.children[k].scrollIntoView({ block: 'nearest' });
}

function pickSuggest(k) {
  var it = sug.items[k], inp = sug.inp, row = sug.row;
  if (!it) return;
  inp.value = it.text;
  onEdit(row, inp);   // 숫자 서식/저장 처리
  hideSuggest();      // onEdit 이 다시 목록을 띄우지 않게 닫음
  inp.focus();
  var len = inp.value.length;
  try { inp.setSelectionRange(len, len); } catch (e) {}  // 뒤에 이어서 입력 가능
}

/* 열린 목록의 키보드 조작. 처리했으면 true */
function handleSugKey(e) {
  if (e.key === 'ArrowDown') { e.preventDefault(); setSugActive(Math.min(sug.active + 1, sug.items.length - 1)); return true; }
  if (e.key === 'ArrowUp')   { e.preventDefault(); setSugActive(Math.max(sug.active - 1, -1)); return true; }
  if (e.key === 'Enter' && sug.active >= 0) { e.preventDefault(); pickSuggest(sug.active); return true; }
  if (e.key === 'Escape') { hideSuggest(); return true; }
  return false;
}

function updateSuggest(row, inp) {
  var i = +inp.dataset.i;
  var v = inp.value.trim();
  if (i === CAR_IDX) {
    showSuggest(row, inp, carCandidates(v));
  } else if (i === SUPPLY_IDX || i === COMPANY_IDX) {
    showSuggest(row, inp, priceCandidates(row, i, inp.value.replace(/[^0-9]/g, '')));
  } else {
    hideSuggest();
  }
}

/* 자주 쓰는 국산차 (빈칸일 때 위쪽에 표시) */
var POPULAR_CARS = ['아반떼','쏘나타','그랜저','싼타페','투싼','팰리세이드','카니발','쏘렌토','스포티지','K5','K8','모닝','레이','캐스퍼','포터','봉고','스타리아','코나','제네시스 G80','GV80'];

function carCandidates(v) {
  var q = (v || '').toLowerCase();
  var seen = {}, out = [];
  // 이번 달에 이미 입력된 차종도 후보에 포함
  var used = [];
  rows.forEach(function(r) { var x = r.inputs[CAR_IDX].value.trim(); if (x && used.indexOf(x) < 0) used.push(x); });
  var all = POPULAR_CARS.concat(CAR_MODELS, used);   // 자주 쓰는 차가 항상 위쪽
  all.forEach(function(m) {
    if (seen[m] || m === v) return;
    if (q && m.toLowerCase().indexOf(q) < 0) return;
    seen[m] = true;
    out.push({ text: m, hint: !q && POPULAR_CARS.indexOf(m) >= 0 ? '자주 쓰는 차' : '' });
  });
  return out.slice(0, q ? 20 : 12);
}

/* 같은 달(현재 화면에 로드된 행) 중 같은 상차→하차 / 같은 회사의 금액 */
function priceCandidates(row, col, typed) {
  var load = row.inputs[3].value.trim(), unload = row.inputs[4].value.trim(), co = row.inputs[2].value.trim();
  var map = {};
  rows.forEach(function(r) {
    if (r === row) return;
    var price = toNum(r.inputs[col].value);
    if (!price) return;
    var score = 0, why = '';
    if (load && unload && r.inputs[3].value.trim() === load && r.inputs[4].value.trim() === unload) { score = 2; why = '같은 구간'; }
    else if (co && r.inputs[2].value.trim() === co) { score = 1; why = '같은 회사'; }
    if (!score) why = '이번 달';   // 같은 구간/회사가 아니어도 후보에 포함 (낮은 우선순위)
    var m = map[price] || (map[price] = { price: price, score: 0, why: '', cnt: 0 });
    if (score > m.score) { m.score = score; m.why = why; }
    m.cnt++;
  });
  return Object.keys(map).map(function(k) { return map[k]; })
    .filter(function(m) { return !typed || String(m.price).indexOf(typed) === 0; })
    .filter(function(m) { return String(m.price) !== typed; })
    .sort(function(a, b) { return b.score - a.score || b.cnt - a.cnt; })
    .slice(0, 10)
    .map(function(m) { return { text: m.price.toLocaleString('ko-KR'), hint: m.why }; });
}

function onFocusCell(row, inp) {
  var i = +inp.dataset.i;
  if ((i === SUPPLY_IDX || i === COMPANY_IDX || i === CAR_IDX) && !inp.value.trim()) updateSuggest(row, inp);
}

/* 입력한 새 값을 자동완성 목록에도 즉시 반영 */
function rememberValue(inp) {
  var c = COLS[+inp.dataset.i], v = inp.value.trim();
  if (!c.list || !v) return;
  var dl = document.getElementById(c.list);
  var exists = Array.prototype.some.call(dl.options, function(o) { return o.value === v; });
  if (!exists) { var o = document.createElement('option'); o.value = v; dl.appendChild(o); }
}

function repositionSuggest() {
  if (!sugOpen() || !sug.inp) return;
  var r = sug.inp.getBoundingClientRect();
  var wr = document.querySelector('.grid-wrap').getBoundingClientRect();
  if (r.bottom < wr.top || r.top > wr.bottom) { hideSuggest(); return; }   // 입력칸이 화면 밖으로 나간 경우만 닫음
  sug.el.style.left = r.left + 'px';
  sug.el.style.top = r.bottom + 'px';
}
window.addEventListener('resize', repositionSuggest);
document.querySelector('.grid-wrap').addEventListener('scroll', repositionSuggest);

/* ===== 초기화 ===== */
(function() {
  buildHeader();
  buildColFilterUI();
  document.getElementById("fDriver").addEventListener("input", applyFilter);
  document.getElementById("fCompany").addEventListener("input", applyFilter);
  loadMonth(ymOf(new Date()));
})();
</script>
</body>
</html>
