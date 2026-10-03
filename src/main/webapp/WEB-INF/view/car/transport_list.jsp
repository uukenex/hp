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
    overflow: auto; max-height: calc(100vh - 230px);
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

  /* 열 너비 */
  .w-date { min-width: 128px; } .w-driver { min-width: 90px; } .w-co { min-width: 100px; }
  .w-point { min-width: 150px; } .w-model { min-width: 90px; } .w-vin { min-width: 130px; }
  .w-price { min-width: 100px; } .w-extra { min-width: 110px; } .w-remark { min-width: 180px; }

  @media (max-width: 700px) {
    .container { padding: 8px 8px 60px; }
    .summary-row { grid-template-columns: 1fr 1fr; }
    .top-bar h1 { font-size: 14px; }
    .grid-wrap { max-height: calc(100vh - 280px); }
    .cell { font-size: 16px; height: 40px; }
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

<datalist id="driverNameList"></datalist>
<datalist id="companyList"></datalist>

<div class="container">

  <div class="toolbar">
    <div id="monthBtns" style="display:flex;gap:6px;"></div>
    <span class="spacer"></span>
    <input type="text" id="fDriver" class="filter-in" placeholder="기사님 조회" list="driverNameList" autocomplete="off">
    <input type="text" id="fCompany" class="filter-in" placeholder="회사 조회" list="companyList" autocomplete="off">
    <span class="save-status" id="saveStatus"></span>
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
      <tfoot><tr id="footRow"></tr></tfoot>
    </table>
  </div>

</div>

<script>
var CTX = '${pageContext.request.contextPath}';

/* ===== 컬럼 정의 ===== */
var COLS = [
  { key:'transportDate',  label:'날짜',          type:'date',  w:'w-date' },
  { key:'driverName',     label:'기사님',        type:'text',  w:'w-driver', list:'driverNameList' },
  { key:'company',        label:'회사',          type:'text',  w:'w-co',     list:'companyList' },
  { key:'loadingPoint',   label:'상차',          type:'text',  w:'w-point' },
  { key:'unloadingPoint', label:'하차',          type:'text',  w:'w-point' },
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

/* ===== 월 버튼 (당월 포함 최근 3개월) ===== */
function buildMonthBtns() {
  var box = document.getElementById('monthBtns');
  box.innerHTML = '';
  var now = new Date();
  for (var i = 2; i >= 0; i--) {
    var d = new Date(now.getFullYear(), now.getMonth() - i, 1);
    var ym = ymOf(d);
    var b = document.createElement('button');
    b.type = 'button';
    b.className = 'month-btn' + (ym === curMonth ? ' active' : '');
    b.textContent = (d.getMonth() + 1) + '월';
    b.dataset.ym = ym;
    b.addEventListener('click', function(){ switchMonth(this.dataset.ym); });
    box.appendChild(b);
  }
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
  var thNo = document.createElement('th'); thNo.textContent = '#'; head.appendChild(thNo);
  var tfNo = document.createElement('td'); foot.appendChild(tfNo);
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
  scheduleSave(row, 800);
}

function onCommit(row, inp) {
  // 다른 칸으로 이동하는 중일 수 있으므로 포커스 이동이 끝난 뒤 판단
  setTimeout(function() {
    if (autoRemoveIfBlank(row)) return;
    if (row.timer || row.dirty) scheduleSave(row, 0);
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
  if (!confirm('삭제하시겠습니까?\n(숨김 처리되며 실제 삭제되지 않습니다)')) return;
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
    buildMonthBtns();
    fillDatalist('driverNameList', res.driverNames);
    fillDatalist('companyList', res.companies);
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
