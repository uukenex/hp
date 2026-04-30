<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>운송 일괄 입력</title>
<style>
  * { box-sizing: border-box; margin: 0; padding: 0; }
  body { font-family: 'Apple SD Gothic Neo','Malgun Gothic', sans-serif; background: #f0f2f5; font-size: 13px; }

  /* 상단바 */
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
    z-index: 200;
  }
  .top-bar h1 { font-size: 16px; font-weight: 700; }
  .nav-links { display: flex; gap: 14px; align-items: center; }
  .nav-links a { color: rgba(255,255,255,0.75); text-decoration: none; font-size: 12px; }
  .nav-links a:hover { color: #fff; }

  /* 툴바 */
  .toolbar {
    background: #fff;
    border-bottom: 1px solid #dde1e7;
    padding: 10px 16px;
    display: flex;
    gap: 8px;
    align-items: center;
    position: sticky;
    top: 52px;
    z-index: 100;
    flex-wrap: wrap;
  }
  .toolbar-left { display: flex; gap: 8px; align-items: center; flex: 1; flex-wrap: wrap; }
  .toolbar-right { display: flex; gap: 8px; align-items: center; }

  .btn {
    padding: 7px 16px;
    border: none;
    border-radius: 6px;
    cursor: pointer;
    font-size: 13px;
    font-weight: 600;
    white-space: nowrap;
    touch-action: manipulation;
    display: inline-flex;
    align-items: center;
    gap: 5px;
  }
  .btn-add-row  { background: #e8f5e9; color: #2e7d32; border: 1px solid #a5d6a7; }
  .btn-del-rows { background: #fde8e8; color: #c62828; border: 1px solid #ef9a9a; }
  .btn-save     { background: #1e3a5f; color: #fff; padding: 8px 22px; }
  .btn-paste-help { background: #e8edf5; color: #1e3a5f; border: 1px solid #b0bec5; font-size: 12px; }
  .btn-add-row:hover  { background: #c8e6c9; }
  .btn-del-rows:hover { background: #ffcdd2; }
  .btn-save:hover     { background: #163060; }

  .row-count { font-size: 12px; color: #888; white-space: nowrap; }

  /* 그리드 래퍼 */
  .grid-outer {
    overflow-x: auto;
    padding: 12px 16px 80px;
    -webkit-overflow-scrolling: touch;
  }

  /* 그리드 테이블 */
  .grid-table {
    border-collapse: collapse;
    min-width: 1000px;
    width: 100%;
  }
  .grid-table thead th {
    background: #1e3a5f;
    color: #fff;
    padding: 9px 8px;
    font-size: 12px;
    font-weight: 700;
    white-space: nowrap;
    position: sticky;
    top: 0;
    border-right: 1px solid rgba(255,255,255,0.15);
    user-select: none;
  }
  .grid-table thead th.th-check { width: 36px; }
  .grid-table thead th.th-no    { width: 40px; color: rgba(255,255,255,0.6); }
  .grid-table thead th.th-date  { width: 130px; }
  .grid-table thead th.th-driver{ width: 90px; }
  .grid-table thead th.th-co    { width: 100px; }
  .grid-table thead th.th-load  { width: 150px; }
  .grid-table thead th.th-unload{ width: 150px; }
  .grid-table thead th.th-model { width: 90px; }
  .grid-table thead th.th-vin   { width: 100px; }
  .grid-table thead th.th-price { width: 100px; }
  .grid-table thead th.th-cprice{ width: 100px; }
  .grid-table thead th.th-del   { width: 40px; border-right: none; }

  /* 데이터 행 */
  .grid-table tbody tr { background: #fff; }
  .grid-table tbody tr:nth-child(even) { background: #f7f9fc; }
  .grid-table tbody tr.selected { background: #e3f0fb !important; }
  .grid-table tbody tr:hover { background: #eef4ff !important; }
  .grid-table tbody tr.selected:hover { background: #d0e8f8 !important; }

  .grid-table tbody td {
    border: 1px solid #dde1e7;
    border-top: none;
    padding: 0;
    vertical-align: middle;
  }
  .grid-table tbody td.td-no {
    text-align: center;
    font-size: 11px;
    color: #bbb;
    padding: 6px 4px;
    user-select: none;
  }
  .grid-table tbody td.td-check {
    text-align: center;
    padding: 6px;
  }
  .grid-table tbody td.td-del {
    text-align: center;
    padding: 4px;
    border-right: none;
  }

  /* 셀 인풋 */
  .cell-input {
    width: 100%;
    border: none;
    background: transparent;
    padding: 8px 8px;
    font-size: 13px;
    font-family: inherit;
    color: #222;
    outline: none;
    height: 36px;
  }
  .cell-input:focus {
    background: #fff8e1;
    box-shadow: inset 0 0 0 2px #f59f00;
  }
  .cell-input.price-input { text-align: right; }
  .cell-input[type="date"] { padding: 6px 4px; }

  /* 선택 체크박스 */
  .row-check { width: 16px; height: 16px; cursor: pointer; accent-color: #1e3a5f; }

  /* 행 삭제 버튼 */
  .del-row-btn {
    background: none;
    border: none;
    color: #e53935;
    cursor: pointer;
    font-size: 16px;
    padding: 4px 6px;
    border-radius: 4px;
    line-height: 1;
  }
  .del-row-btn:hover { background: #fde8e8; }

  /* 에러 표시 */
  .cell-input.error { box-shadow: inset 0 0 0 2px #e53935 !important; background: #fff5f5 !important; }

  /* 결과 메시지 */
  .result-msg {
    display: none;
    position: fixed;
    bottom: 24px;
    left: 50%;
    transform: translateX(-50%);
    background: #2e7d32;
    color: #fff;
    padding: 12px 28px;
    border-radius: 8px;
    font-size: 14px;
    font-weight: 600;
    box-shadow: 0 4px 16px rgba(0,0,0,0.22);
    z-index: 999;
    white-space: nowrap;
  }
  .result-msg.error { background: #c62828; }

  /* 붙여넣기 안내 */
  .paste-guide {
    display: none;
    position: fixed;
    inset: 0;
    background: rgba(0,0,0,0.55);
    z-index: 500;
    align-items: center;
    justify-content: center;
  }
  .paste-guide.show { display: flex; }
  .paste-guide-box {
    background: #fff;
    border-radius: 14px;
    padding: 28px 32px;
    max-width: 480px;
    width: 90%;
  }
  .paste-guide-box h3 { font-size: 16px; color: #1e3a5f; margin-bottom: 14px; }
  .paste-guide-box table { width: 100%; border-collapse: collapse; font-size: 12px; margin-bottom: 16px; }
  .paste-guide-box th { background: #f0f2f5; padding: 6px 8px; border: 1px solid #dde1e7; }
  .paste-guide-box td { padding: 6px 8px; border: 1px solid #eee; color: #555; }
  .paste-guide-box p  { font-size: 12px; color: #888; margin-bottom: 16px; line-height: 1.7; }
  .close-guide { background: #1e3a5f; color: #fff; border: none; border-radius: 6px; padding: 9px 22px; cursor: pointer; font-size: 13px; font-weight: 600; }

  /* 저장 버튼 고정 (모바일) */
  .save-fab {
    display: none;
    position: fixed;
    bottom: 18px;
    right: 16px;
    background: #1e3a5f;
    color: #fff;
    border: none;
    border-radius: 28px;
    padding: 13px 22px;
    font-size: 15px;
    font-weight: 700;
    box-shadow: 0 4px 16px rgba(0,0,0,0.22);
    z-index: 300;
    cursor: pointer;
    touch-action: manipulation;
  }

  @media (max-width: 700px) {
    .toolbar { top: 52px; padding: 8px 10px; gap: 6px; }
    .btn { padding: 8px 12px; font-size: 12px; }
    .btn-save { display: none; }
    .save-fab { display: block; }
    .grid-outer { padding: 8px 0 100px; }
  }
</style>
</head>
<body>

<div class="top-bar">
  <h1>🚚 운송 일괄 입력</h1>
  <div class="nav-links">
    <a href="${pageContext.request.contextPath}/transport/list">목록</a>
    <a href="${pageContext.request.contextPath}/">홈</a>
  </div>
</div>

<div class="toolbar">
  <div class="toolbar-left">
    <button class="btn btn-add-row" onclick="addRow()">＋ 행 추가</button>
    <button class="btn btn-del-rows" onclick="deleteSelected()">✕ 선택 삭제</button>
    <button class="btn btn-paste-help" onclick="showPasteGuide()">📋 엑셀 붙여넣기 안내</button>
    <span class="row-count" id="rowCount">0행</span>
  </div>
  <div class="toolbar-right">
    <button class="btn btn-save" onclick="submitGrid()">💾 저장</button>
  </div>
</div>

<form id="bulkForm" method="post" action="${pageContext.request.contextPath}/transport/bulk">
<div class="grid-outer">
  <table class="grid-table" id="gridTable">
    <thead>
      <tr>
        <th class="th-check">
          <input type="checkbox" class="row-check" id="checkAll" onchange="toggleAll(this)">
        </th>
        <th class="th-no">#</th>
        <th class="th-date">날짜 *</th>
        <th class="th-driver">기사님 *</th>
        <th class="th-co">회사 *</th>
        <th class="th-load">상차 위치 *</th>
        <th class="th-unload">하차 위치 *</th>
        <th class="th-model">차종</th>
        <th class="th-vin">차대번호</th>
        <th class="th-price">공급가</th>
        <th class="th-cprice">회사공급가</th>
        <th class="th-del"></th>
      </tr>
    </thead>
    <tbody id="gridBody">
    </tbody>
  </table>
</div>
</form>

<!-- 저장 FAB (모바일) -->
<button class="save-fab" onclick="submitGrid()">💾 저장</button>

<!-- 붙여넣기 안내 모달 -->
<div class="paste-guide" id="pasteGuide" onclick="hidePasteGuide(event)">
  <div class="paste-guide-box">
    <h3>📋 엑셀 붙여넣기 방법</h3>
    <p>엑셀(Excel)에서 데이터를 복사한 뒤, 그리드의 시작 셀을 클릭하고 <strong>Ctrl+V</strong>를 누르면 자동으로 채워집니다.</p>
    <table>
      <thead>
        <tr>
          <th>A열</th><th>B열</th><th>C열</th><th>D열</th>
          <th>E열</th><th>F열</th><th>G열</th><th>H열</th><th>I열</th>
        </tr>
      </thead>
      <tbody>
        <tr>
          <td>날짜<br><small>YYYY-MM-DD</small></td>
          <td>기사님</td>
          <td>회사</td>
          <td>상차 위치</td>
          <td>하차 위치</td>
          <td>차종</td>
          <td>차대번호</td>
          <td>공급가</td>
          <td>회사공급가</td>
        </tr>
      </tbody>
    </table>
    <p>날짜는 <strong>YYYY-MM-DD</strong> 형식으로 입력하거나, 엑셀에서 텍스트 형식으로 복사해 주세요.</p>
    <button class="close-guide" onclick="hidePasteGuide()">확인</button>
  </div>
</div>

<!-- 결과 메시지 -->
<div class="result-msg" id="resultMsg"></div>

<script>
var COLS = ['transportDate','driverName','company','loadingPoint','unloadingPoint','carModel','vehicleNo','supplyPrice','companyPrice'];
var REQUIRED = [0,1,2,3,4]; // date, driver, company, load, unload
var rowSeq = 0;

// ===== 행 추가 =====
function addRow(data) {
  var tbody = document.getElementById('gridBody');
  var tr = document.createElement('tr');
  rowSeq++;
  tr.dataset.rid = rowSeq;

  // 체크박스
  var tdChk = document.createElement('td');
  tdChk.className = 'td-check';
  tdChk.innerHTML = '<input type="checkbox" class="row-check" onchange="updateCount()">';
  tr.appendChild(tdChk);

  // 번호
  var tdNo = document.createElement('td');
  tdNo.className = 'td-no';
  tdNo.textContent = tbody.rows.length + 1;
  tr.appendChild(tdNo);

  // 셀
  COLS.forEach(function(col, i) {
    var td = document.createElement('td');
    var inp = document.createElement('input');
    inp.name = col + '[]';
    inp.className = 'cell-input' + (i >= 7 ? ' price-input' : '');
    inp.autocomplete = 'off';
    inp.spellcheck = false;

    if (col === 'transportDate') {
      inp.type = 'date';
      inp.value = data && data[i] ? parseDate(data[i]) : todayStr();
    } else if (col === 'supplyPrice' || col === 'companyPrice') {
      inp.type = 'text';
      inp.inputMode = 'numeric';
      inp.value = data && data[i] ? data[i].replace(/[^0-9]/g,'') : '0';
      inp.addEventListener('focus', function(){ this.select(); });
      inp.addEventListener('blur', formatPrice);
    } else {
      inp.type = 'text';
      inp.value = data && data[i] ? data[i] : '';
    }

    inp.addEventListener('keydown', cellKeydown);
    inp.addEventListener('paste', onCellPaste);
    inp.addEventListener('input', function(){ this.classList.remove('error'); });

    td.appendChild(inp);
    tr.appendChild(td);
  });

  // 삭제 버튼
  var tdDel = document.createElement('td');
  tdDel.className = 'td-del';
  tdDel.innerHTML = '<button type="button" class="del-row-btn" onclick="deleteRow(this)" title="행 삭제">✕</button>';
  tr.appendChild(tdDel);

  tbody.appendChild(tr);
  updateRowNumbers();
  updateCount();
  return tr;
}

// ===== 날짜 파싱 =====
function parseDate(val) {
  if (!val) return '';
  val = String(val).trim();
  // YYYY-MM-DD
  if (/^\d{4}-\d{2}-\d{2}$/.test(val)) return val;
  // YYYY/MM/DD or YYYYMMDD
  var m = val.match(/^(\d{4})[\/\.]?(\d{2})[\/\.]?(\d{2})$/);
  if (m) return m[1] + '-' + m[2] + '-' + m[3];
  return val;
}

function todayStr() {
  var d = new Date();
  return d.getFullYear() + '-' + pad(d.getMonth()+1) + '-' + pad(d.getDate());
}
function pad(n){ return n < 10 ? '0'+n : ''+n; }

// ===== 가격 포맷 =====
function formatPrice() {
  var raw = this.value.replace(/[^0-9]/g,'');
  this.value = raw ? parseInt(raw,10).toLocaleString('ko-KR') : '0';
}

// ===== 행 삭제 =====
function deleteRow(btn) {
  var tr = btn.closest('tr');
  tr.parentNode.removeChild(tr);
  updateRowNumbers();
  updateCount();
}

function deleteSelected() {
  var checked = document.querySelectorAll('#gridBody .row-check:checked');
  if (!checked.length) { showMsg('선택된 행이 없습니다.', true); return; }
  if (!confirm(checked.length + '행을 삭제하시겠습니까?')) return;
  checked.forEach(function(cb){ cb.closest('tr').remove(); });
  updateRowNumbers();
  updateCount();
}

// ===== 전체 선택 =====
function toggleAll(cb) {
  document.querySelectorAll('#gridBody .row-check').forEach(function(c){ c.checked = cb.checked; });
  document.querySelectorAll('#gridBody tr').forEach(function(tr){
    tr.classList.toggle('selected', cb.checked);
  });
  updateCount();
}

// ===== 번호 갱신 =====
function updateRowNumbers() {
  var rows = document.querySelectorAll('#gridBody tr');
  rows.forEach(function(tr, i){
    var td = tr.querySelector('.td-no');
    if (td) td.textContent = i + 1;
  });
}

// ===== 행 수 표시 =====
function updateCount() {
  var total = document.querySelectorAll('#gridBody tr').length;
  var sel   = document.querySelectorAll('#gridBody .row-check:checked').length;
  document.getElementById('rowCount').textContent =
    total + '행' + (sel ? ' / ' + sel + '선택' : '');
  // 행 강조
  document.querySelectorAll('#gridBody tr').forEach(function(tr){
    var cb = tr.querySelector('.row-check');
    tr.classList.toggle('selected', cb && cb.checked);
  });
}

// ===== 키보드 네비게이션 =====
function cellKeydown(e) {
  var inputs = Array.from(document.querySelectorAll('#gridTable input.cell-input'));
  var idx = inputs.indexOf(this);
  if (e.key === 'Tab') {
    e.preventDefault();
    var next = e.shiftKey ? inputs[idx-1] : inputs[idx+1];
    if (!next && !e.shiftKey) { addRow(); next = inputs[inputs.length-1]; }
    if (next) { next.focus(); next.select && next.select(); }
  } else if (e.key === 'Enter') {
    e.preventDefault();
    // 다음 행 같은 열로 이동
    var col = inputs.filter(function(inp){ return inp.closest('tr') === this.closest('tr'); }, this).indexOf(this);
    var tr = this.closest('tr');
    var nextTr = tr.nextElementSibling;
    if (!nextTr) { addRow(); nextTr = tr.nextElementSibling; }
    if (nextTr) {
      var colInputs = nextTr.querySelectorAll('.cell-input');
      if (colInputs[col]) { colInputs[col].focus(); colInputs[col].select && colInputs[col].select(); }
    }
  } else if (e.key === 'ArrowDown') {
    var tr2 = this.closest('tr');
    var nextTr2 = tr2.nextElementSibling;
    if (nextTr2) {
      var col2 = Array.from(tr2.querySelectorAll('.cell-input')).indexOf(this);
      var ni = nextTr2.querySelectorAll('.cell-input')[col2];
      if (ni) { e.preventDefault(); ni.focus(); }
    }
  } else if (e.key === 'ArrowUp') {
    var tr3 = this.closest('tr');
    var prevTr = tr3.previousElementSibling;
    if (prevTr) {
      var col3 = Array.from(tr3.querySelectorAll('.cell-input')).indexOf(this);
      var pi = prevTr.querySelectorAll('.cell-input')[col3];
      if (pi) { e.preventDefault(); pi.focus(); }
    }
  }
}

// ===== 엑셀 붙여넣기 =====
function onCellPaste(e) {
  var text = (e.clipboardData || window.clipboardData).getData('text');
  if (!text.includes('\t') && !text.includes('\n')) return; // 단일 셀은 그냥
  e.preventDefault();

  var rows = text.trim().split(/\r?\n/).map(function(r){ return r.split('\t'); });
  var startInput = this;
  var allInputs = Array.from(document.querySelectorAll('#gridTable input.cell-input'));
  var startIdx = allInputs.indexOf(startInput);
  var startTr = startInput.closest('tr');
  var startColInputs = Array.from(startTr.querySelectorAll('.cell-input'));
  var startCol = startColInputs.indexOf(startInput);

  rows.forEach(function(rowData, ri) {
    var targetTr;
    if (ri === 0) {
      targetTr = startTr;
    } else {
      var tbody = document.getElementById('gridBody');
      var existingRows = Array.from(tbody.rows);
      var startRowIdx = existingRows.indexOf(startTr);
      if (startRowIdx + ri < existingRows.length) {
        targetTr = existingRows[startRowIdx + ri];
      } else {
        addRow();
        targetTr = tbody.rows[tbody.rows.length - 1];
      }
    }
    var cellInputs = Array.from(targetTr.querySelectorAll('.cell-input'));
    rowData.forEach(function(val, ci) {
      var inp = cellInputs[startCol + ci];
      if (!inp) return;
      val = val.trim();
      if (inp.type === 'date') {
        inp.value = parseDate(val);
      } else if (inp.classList.contains('price-input')) {
        inp.value = val.replace(/[^0-9]/g,'') || '0';
      } else {
        inp.value = val;
      }
      inp.classList.remove('error');
    });
  });
  updateCount();
}

// ===== 제출 =====
function submitGrid() {
  var rows = document.querySelectorAll('#gridBody tr');
  if (!rows.length) { showMsg('입력된 행이 없습니다.', true); return; }

  var hasError = false;
  rows.forEach(function(tr) {
    var inputs = tr.querySelectorAll('.cell-input');
    REQUIRED.forEach(function(ci) {
      var inp = inputs[ci];
      if (inp && !inp.value.trim()) {
        inp.classList.add('error');
        hasError = true;
      }
    });
  });
  if (hasError) { showMsg('필수 항목(*)을 모두 입력해 주세요.', true); return; }

  // 가격 필드: 숫자만 추출
  rows.forEach(function(tr) {
    tr.querySelectorAll('.price-input').forEach(function(inp){
      inp.value = inp.value.replace(/[^0-9]/g,'') || '0';
    });
  });

  document.getElementById('bulkForm').submit();
}

// ===== 안내 모달 =====
function showPasteGuide() { document.getElementById('pasteGuide').classList.add('show'); }
function hidePasteGuide(e) {
  if (!e || e.target === document.getElementById('pasteGuide')) {
    document.getElementById('pasteGuide').classList.remove('show');
  }
}

// ===== 메시지 =====
function showMsg(msg, isErr) {
  var el = document.getElementById('resultMsg');
  el.textContent = msg;
  el.className = 'result-msg' + (isErr ? ' error' : '');
  el.style.display = 'block';
  setTimeout(function(){ el.style.display = 'none'; }, 3000);
}

// ===== 초기화: 5행 기본 생성 =====
(function init() {
  for (var i = 0; i < 5; i++) addRow();
  // 저장 성공 메시지 확인
  var saved = '${param.saved}';
  if (saved) showMsg(saved + '건이 저장되었습니다.');
})();
</script>
</body>
</html>
