<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>캘린더 D-day</title>
<link rel="manifest" href="${pageContext.request.contextPath}/calendar/manifest.json">
<meta name="theme-color" content="#0F6E56">
<link rel="icon" id="favicon" href="${pageContext.request.contextPath}/calendar/icon/192.png">
<style>
  * { box-sizing: border-box; margin: 0; padding: 0; -webkit-tap-highlight-color: transparent; }
  body { font-family: 'Apple SD Gothic Neo','Malgun Gothic', sans-serif; background: #f5f7fa; color: #222; font-size: 14px; }
  button { font-family: inherit; cursor: pointer; touch-action: manipulation; }

  .top { background: #fff; display: flex; align-items: center; gap: 10px; padding: 10px 14px; position: sticky; top: 0; z-index: 50; box-shadow: 0 1px 4px rgba(0,0,0,0.08); }
  .top h1 { font-size: 16px; font-weight: 700; color: #0F6E56; line-height: 1.2; }
  .top .sub { font-size: 12px; color: #777; }
  .top .grow { flex: 1; }
  .bell { background: #fff; border: 1px solid #9FE1CB; color: #0F6E56; border-radius: 16px; padding: 6px 10px; font-size: 13px; font-weight: 600; white-space: nowrap; }
  .bell.on { background: #E1F5EE; }
  .link { color: #0F6E56; font-size: 12px; text-decoration: none; }

  .wrap { max-width: 640px; margin: 0 auto; padding: 12px 12px 90px; }

  .tabs { display: flex; gap: 6px; margin-bottom: 12px; }
  .tabs button { flex: 1; padding: 9px 4px; border: 1px solid #b0bec5; background: #fff; color: #455a64; border-radius: 20px; font-size: 13px; font-weight: 600; }
  .tabs button.on { background: #0F6E56; border-color: #0F6E56; color: #fff; }

  .card { background: #fff; border: 1px solid #dde3ed; border-radius: 12px; padding: 12px 14px; margin-bottom: 8px; display: flex; align-items: center; gap: 12px; }
  .badge { min-width: 62px; text-align: center; padding: 8px 6px; border-radius: 10px; font-weight: 700; font-size: 15px; background: #f0f4fa; color: #1565c0; flex: none; }
  .badge.today { background: #E24B4A; color: #fff; }
  .badge.soon { background: #FAEEDA; color: #854F0B; }
  .badge.past { background: #eee; color: #888; }
  .card .main { flex: 1; min-width: 0; }
  .card .t { font-size: 15px; font-weight: 600; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
  .card .s { font-size: 12px; color: #777; margin-top: 2px; }
  .card .act { display: flex; gap: 6px; flex: none; }
  .mini { border: 1px solid #ccc; background: #fff; color: #555; border-radius: 6px; padding: 5px 9px; font-size: 12px; }
  .mini.del { color: #c62828; border-color: #ef9a9a; }
  .empty { text-align: center; color: #999; padding: 40px 10px; line-height: 1.8; }

  .monthbar { display: flex; align-items: center; justify-content: space-between; margin-bottom: 8px; }
  .monthbar .m { font-size: 16px; font-weight: 700; }
  .monthbar button { background: #fff; border: 1px solid #b0bec5; border-radius: 8px; padding: 6px 12px; font-size: 14px; }
  .grid { display: grid; grid-template-columns: repeat(7, 1fr); gap: 2px; background: #fff; border: 1px solid #dde3ed; border-radius: 12px; padding: 6px; }
  .dow { text-align: center; font-size: 11px; color: #888; padding: 4px 0; }
  .dow.sun, .day.sun .n { color: #c62828; }
  .day.hol .n { color: #c62828 !important; }
  .day .hn { font-size: 9px; color: #c62828; line-height: 1.2; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
  .dow.sat, .day.sat .n { color: #1565c0; }
  .day { min-height: 52px; border-radius: 8px; padding: 3px 2px; text-align: center; cursor: pointer; border: 1px solid transparent; }
  .day.out { opacity: 0.35; }
  .day.today { border-color: #0F6E56; }
  .day.sel { background: #E1F5EE; }
  .day .n { font-size: 13px; }
  .dots { display: flex; justify-content: center; gap: 2px; flex-wrap: wrap; margin-top: 3px; }
  .dot { width: 7px; height: 7px; border-radius: 50%; background: #378ADD; }
  .dot.bd { background: #D4537E; }
  .detail { margin-top: 10px; }

  .fab { position: fixed; right: 16px; bottom: 18px; width: 56px; height: 56px; border-radius: 50%; border: none; background: #0F6E56; color: #fff; font-size: 30px; line-height: 56px; text-align: center; box-shadow: 0 4px 14px rgba(0,0,0,0.25); z-index: 60; }

  .modal-bg { display: none; position: fixed; inset: 0; background: rgba(0,0,0,0.5); z-index: 500; align-items: flex-end; justify-content: center; }
  .modal-bg.show { display: flex; }
  .modal { background: #fff; width: 100%; max-width: 560px; max-height: 92vh; overflow-y: auto; border-radius: 16px 16px 0 0; padding: 16px; }
  .modal h2 { font-size: 16px; color: #0F6E56; margin-bottom: 12px; display: flex; justify-content: space-between; align-items: center; }
  .modal h2 button { background: none; border: none; font-size: 22px; color: #666; }
  .seg { display: flex; gap: 6px; margin-bottom: 12px; }
  .seg button { flex: 1; padding: 9px 4px; border: 1px solid #b0bec5; background: #fff; border-radius: 8px; font-size: 14px; font-weight: 600; color: #455a64; }
  .seg button.on { background: #E1F5EE; border-color: #0F6E56; color: #0F6E56; }
  .field { margin-bottom: 12px; }
  .field label.l { display: block; font-size: 12px; font-weight: 700; color: #444; margin-bottom: 5px; }
  .field input[type=text], .field input[type=date], .field input[type=number], .field textarea { width: 100%; border: 1px solid #ccc; border-radius: 8px; padding: 11px 12px; font-size: 16px; font-family: inherit; }
  .field input:focus, .field textarea:focus { outline: none; border-color: #0F6E56; }
  .hint { font-size: 11px; color: #888; margin-top: 4px; line-height: 1.5; }
  .chk { display: flex; align-items: center; gap: 8px; font-size: 14px; margin-bottom: 8px; }
  .chk input { width: 18px; height: 18px; accent-color: #0F6E56; }
  .chips { display: flex; flex-wrap: wrap; gap: 6px; }
  .chips label { border: 1px solid #b0bec5; border-radius: 16px; padding: 6px 12px; font-size: 13px; color: #455a64; cursor: pointer; user-select: none; }
  .chips input { display: none; }
  .chips label.on { background: #E1F5EE; border-color: #0F6E56; color: #0F6E56; font-weight: 700; }
  .err { color: #c62828; font-size: 12px; margin-bottom: 8px; min-height: 16px; }
  .btns { display: flex; gap: 8px; margin-top: 6px; }
  .btns button { flex: 1; padding: 13px; border-radius: 10px; border: none; font-size: 15px; font-weight: 700; }
  .btns .cancel { background: #eee; color: #555; }
  .btns .ok { background: #0F6E56; color: #fff; flex: 2; }

  .loading { display: none; position: fixed; inset: 0; z-index: 900; background: rgba(0,0,0,0.5); flex-direction: column; align-items: center; justify-content: center; gap: 14px; color: #fff; font-size: 14px; }
  .loading.show { display: flex; }
  .spinner { width: 46px; height: 46px; border: 5px solid rgba(255,255,255,0.3); border-top-color: #fff; border-radius: 50%; animation: spin 0.8s linear infinite; }
  @keyframes spin { to { transform: rotate(360deg); } }
</style>
</head>
<body>

<div id="loading" class="loading show"><div class="spinner"></div><div>불러오는 중…</div></div>

<div class="top">
  <span id="hdrIcon" style="display:inline-block;width:40px;height:40px;"></span>
  <div>
    <h1>캘린더 D-day</h1>
    <div class="sub" id="todayText"></div>
  </div>
  <span class="grow"></span>
  <button type="button" id="bell" class="bell" style="display:none;" onclick="togglePush()">🔕 알림</button>
  <a class="link" href="${pageContext.request.contextPath}/">홈</a>
</div>

<div class="wrap">
  <div class="tabs" id="tabs">
    <button type="button" data-tab="up" class="on">다가오는</button>
    <button type="button" data-tab="cal">달력</button>
    <button type="button" data-tab="list">내 목록</button>
  </div>

  <section id="tab-up"></section>

  <section id="tab-cal" style="display:none;">
    <div class="monthbar">
      <button type="button" onclick="moveMonth(-1)">‹</button>
      <div class="m" id="monthTitle"></div>
      <button type="button" onclick="moveMonth(1)">›</button>
    </div>
    <div class="grid" id="calGrid"></div>
    <div class="detail" id="calDetail"></div>
  </section>

  <section id="tab-list" style="display:none;"></section>
</div>

<button type="button" class="fab" aria-label="추가" onclick="openForm()">+</button>

<div class="modal-bg" id="formModal" onclick="if(event.target===this)closeForm()">
  <div class="modal">
    <h2><span id="formTitle">추가</span><button type="button" onclick="closeForm()">✕</button></h2>
    <div class="seg" id="typeSeg">
      <button type="button" data-type="DDAY" class="on">💕 D-day</button>
      <button type="button" data-type="BIRTHDAY">🎂 생일</button>
    </div>
    <div class="field">
      <label class="l">제목</label>
      <input type="text" id="fTitle" maxlength="100" placeholder="예) 우리 연애 / 엄마 생일" autocomplete="off">
    </div>
    <div class="field">
      <label class="l" id="fDateLabel">시작일</label>
      <input type="date" id="fDate">
    </div>

    <div id="ddayOpts">
      <label class="chk"><input type="checkbox" id="fFromOne" checked> 시작일을 1일로 계산 (예: 5월 9일 = 1일)</label>
      <div class="field">
        <label class="l">기념일 간격 (일)</label>
        <input type="number" id="fInterval" min="0" max="36500" value="100" inputmode="numeric">
        <div class="hint">100이면 100일, 200일, 300일… 마다 표시합니다. 0이면 사용하지 않습니다.</div>
      </div>
      <label class="chk"><input type="checkbox" id="fYearly" checked> 매년 주년(1주년, 2주년…)도 표시</label>
    </div>

    <div id="bdayOpts" style="display:none;">
      <label class="chk"><input type="checkbox" id="fHasYear" checked> 출생 연도 포함 (나이 표시)</label>
      <div class="hint" style="margin:-4px 0 10px;">한 번만 등록하면 매년 같은 날짜에 표시됩니다. 양력 기준입니다.</div>
    </div>

    <div class="field">
      <label class="l">알림 (아침 8시에 푸시)</label>
      <div class="chips" id="notifyChips"></div>
      <div class="hint">알림을 받으려면 위쪽의 알림 버튼에서 이 기기의 알림을 켜 주세요.</div>
    </div>
    <div class="field">
      <label class="l">메모 (선택)</label>
      <textarea id="fMemo" rows="2" maxlength="500"></textarea>
    </div>
    <div class="err" id="fErr"></div>
    <div class="btns">
      <button type="button" class="cancel" onclick="closeForm()">취소</button>
      <button type="button" class="ok" onclick="saveForm()">저장</button>
    </div>
  </div>
</div>

<script>
var CTX = '${pageContext.request.contextPath}';
var DOW = ['일', '월', '화', '수', '목', '금', '토'];
var NOTIFY_OPTS = [[0, '당일'], [1, '1일 전'], [3, '3일 전'], [7, '7일 전'], [30, '30일 전']];

var today = null;          // 서버(한국 시간) 기준 오늘 yyyy-MM-dd
var items = [];
var upcoming = [];
var viewYear = 0, viewMonth = 0;   // 달력 표시 월 (month: 1~12)
var monthOcc = [];
var monthHol = {};         // 해당 달력 구간의 공휴일 (날짜 → 이름)
var todayHoliday = null;
var selDate = null;
var editing = null;        // 수정 중인 항목 (신규면 null)
var formType = 'DDAY';

/* ===== 유틸 ===== */
function pad(n) { return n < 10 ? '0' + n : '' + n; }
function ymd(y, m, d) { return y + '-' + pad(m) + '-' + pad(d); }
function parse(s) { var p = s.split('-'); return { y: +p[0], m: +p[1], d: +p[2] }; }
function dowOf(s) { var p = parse(s); return new Date(p.y, p.m - 1, p.d).getDay(); }
function niceDate(s) { var p = parse(s); return p.m + '월 ' + p.d + '일 (' + DOW[dowOf(s)] + ')'; }
function el(tag, cls, text) { var e = document.createElement(tag); if (cls) e.className = cls; if (text != null) e.textContent = text; return e; }

function api(url, opts) {
  return fetch(CTX + url, opts).then(function(r) {
    if (r.redirected) { location.reload(); throw new Error('login'); }   // 로그인 만료
    if (!r.ok) { var err = new Error('http ' + r.status); err.status = r.status; throw err; }
    return r.json();
  });
}
function showLoading() { document.getElementById('loading').classList.add('show'); }
function hideLoading() { document.getElementById('loading').classList.remove('show'); }

/* ===== 날짜 아이콘 (헤더 / 탭 아이콘) ===== */
function dateIconSvg(m, d, size) {
  var s = size, r = Math.round(s * 0.22), top = Math.round(s * 0.3);
  var mon = ['JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN', 'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'][m - 1];
  return '<svg width="' + s + '" height="' + s + '" viewBox="0 0 ' + s + ' ' + s + '" role="img" aria-label="오늘 날짜">'
    + '<rect x="0.5" y="0.5" width="' + (s - 1) + '" height="' + (s - 1) + '" rx="' + r + '" fill="#FFFFFF" stroke="#B4B2A9"/>'
    + '<path d="M' + r + ' 0.5 H' + (s - r) + ' Q' + (s - 0.5) + ' 0.5 ' + (s - 0.5) + ' ' + r + ' V' + top + ' H0.5 V' + r + ' Q0.5 0.5 ' + r + ' 0.5 Z" fill="#E24B4A"/>'
    + '<text x="' + (s / 2) + '" y="' + (top - Math.max(2, s * 0.08)) + '" text-anchor="middle" font-size="' + Math.max(7, Math.round(s * 0.2)) + '" fill="#FFFFFF" font-family="sans-serif" font-weight="700">' + mon + '</text>'
    + '<text x="' + (s / 2) + '" y="' + (s - Math.round(s * 0.14)) + '" text-anchor="middle" font-size="' + Math.round(s * 0.5) + '" font-weight="700" fill="#2C2C2A" font-family="sans-serif">' + d + '</text></svg>';
}

function paintToday() {
  var p = parse(today);
  document.getElementById('hdrIcon').innerHTML = dateIconSvg(p.m, p.d, 40);
  document.getElementById('todayText').textContent = p.y + '년 ' + p.m + '월 ' + p.d + '일 ' + DOW[dowOf(today)] + '요일' + (todayHoliday ? ' · ' + todayHoliday : '');
  document.getElementById('todayText').style.color = (todayHoliday || dowOf(today) === 0) ? '#c62828' : '';
  // 파비콘도 오늘 날짜로
  try {
    var c = document.createElement('canvas'); c.width = 64; c.height = 64;
    var g = c.getContext('2d');
    g.fillStyle = '#fff'; g.strokeStyle = '#B4B2A9'; g.lineWidth = 2;
    g.beginPath(); g.moveTo(14, 2); g.lineTo(50, 2); g.quadraticCurveTo(62, 2, 62, 14); g.lineTo(62, 50); g.quadraticCurveTo(62, 62, 50, 62); g.lineTo(14, 62); g.quadraticCurveTo(2, 62, 2, 50); g.lineTo(2, 14); g.quadraticCurveTo(2, 2, 14, 2); g.closePath(); g.fill(); g.stroke();
    g.save(); g.clip(); g.fillStyle = '#E24B4A'; g.fillRect(0, 0, 64, 20); g.restore();
    g.fillStyle = '#2C2C2A'; g.font = 'bold 34px sans-serif'; g.textAlign = 'center'; g.fillText(String(p.d), 32, 54);
    document.getElementById('favicon').href = c.toDataURL('image/png');
  } catch (e) {}
}

/* ===== 탭 ===== */
function showTab(name) {
  ['up', 'cal', 'list'].forEach(function(t) { document.getElementById('tab-' + t).style.display = t === name ? 'block' : 'none'; });
  Array.prototype.forEach.call(document.querySelectorAll('#tabs button'), function(b) { b.classList.toggle('on', b.dataset.tab === name); });
  if (name === 'cal') loadMonth();
}
Array.prototype.forEach.call(document.querySelectorAll('#tabs button'), function(b) {
  b.addEventListener('click', function() { showTab(this.dataset.tab); });
});

/* ===== 다가오는 기념일 ===== */
function badgeFor(daysLeft) {
  var b = el('div', 'badge');
  if (daysLeft === 0) { b.textContent = 'D-DAY'; b.classList.add('today'); }
  else if (daysLeft > 0) { b.textContent = 'D-' + daysLeft; if (daysLeft <= 7) b.classList.add('soon'); }
  else { b.textContent = 'D+' + (-daysLeft); b.classList.add('past'); }
  return b;
}
function occCard(o, showDate) {
  var c = el('div', 'card');
  c.appendChild(badgeFor(o.daysLeft));
  var m = el('div', 'main');
  m.appendChild(el('div', 't', (o.type === 'BIRTHDAY' ? '🎂 ' : '💕 ') + o.title + ' · ' + o.label));
  m.appendChild(el('div', 's', niceDate(o.date) + (o.memo ? ' · ' + o.memo : '')));
  c.appendChild(m);
  return c;
}
function renderUpcoming() {
  var box = document.getElementById('tab-up');
  box.innerHTML = '';
  if (!upcoming.length) {
    var e = el('div', 'empty');
    e.appendChild(document.createTextNode('다가오는 기념일이 없습니다.'));
    e.appendChild(document.createElement('br'));
    e.appendChild(document.createTextNode('아래 + 버튼으로 D-day나 생일을 추가해 보세요.'));
    box.appendChild(e);
    return;
  }
  upcoming.forEach(function(o) { box.appendChild(occCard(o)); });
}

/* ===== 달력 ===== */
function moveMonth(delta) {
  viewMonth += delta;
  if (viewMonth < 1) { viewMonth = 12; viewYear--; }
  if (viewMonth > 12) { viewMonth = 1; viewYear++; }
  loadMonth();
}
function loadMonth() {
  var first = new Date(viewYear, viewMonth - 1, 1);
  var start = new Date(viewYear, viewMonth - 1, 1 - first.getDay());
  var end = new Date(start.getFullYear(), start.getMonth(), start.getDate() + 41);
  var from = ymd(start.getFullYear(), start.getMonth() + 1, start.getDate());
  var to = ymd(end.getFullYear(), end.getMonth() + 1, end.getDate());
  return api('/calendar/api/occurrences?from=' + from + '&to=' + to).then(function(res) {
    monthOcc = res.list || [];
    monthHol = res.holidays || {};
    renderMonth(start);
  }).catch(function() {});
}
function renderMonth(start) {
  document.getElementById('monthTitle').textContent = viewYear + '년 ' + viewMonth + '월';
  var g = document.getElementById('calGrid');
  g.innerHTML = '';
  DOW.forEach(function(d, i) { g.appendChild(el('div', 'dow' + (i === 0 ? ' sun' : i === 6 ? ' sat' : ''), d)); });
  var byDate = {};
  monthOcc.forEach(function(o) { (byDate[o.date] = byDate[o.date] || []).push(o); });
  for (var i = 0; i < 42; i++) {
    var d = new Date(start.getFullYear(), start.getMonth(), start.getDate() + i);
    var key = ymd(d.getFullYear(), d.getMonth() + 1, d.getDate());
    var cls = 'day' + (d.getMonth() + 1 !== viewMonth ? ' out' : '') + (key === today ? ' today' : '') + (key === selDate ? ' sel' : '')
      + (d.getDay() === 0 ? ' sun' : d.getDay() === 6 ? ' sat' : '') + (monthHol[key] ? ' hol' : '');
    var cell = el('div', cls);
    cell.dataset.date = key;
    cell.appendChild(el('div', 'n', String(d.getDate())));
    if (monthHol[key]) {
      var hn = monthHol[key];
      if (hn.indexOf('대체공휴일') === 0) hn = '대체휴일';   // 칸이 좁아서 줄임 (전체 이름은 날짜를 누르면 표시)
      cell.appendChild(el('div', 'hn', hn));
    }
    var dots = el('div', 'dots');
    (byDate[key] || []).slice(0, 4).forEach(function(o) { dots.appendChild(el('span', 'dot' + (o.type === 'BIRTHDAY' ? ' bd' : ''))); });
    cell.appendChild(dots);
    cell.addEventListener('click', function() { selDate = this.dataset.date; renderMonth(start); });
    g.appendChild(cell);
  }
  var box = document.getElementById('calDetail');
  box.innerHTML = '';
  if (selDate) {
    box.appendChild(el('div', 's', niceDate(selDate) + (monthHol[selDate] ? ' · ' + monthHol[selDate] : '')));
    if (monthHol[selDate]) box.lastChild.style.color = '#c62828';
    var list = byDate[selDate] || [];
    if (!list.length) box.appendChild(el('div', 'empty', '이 날은 기념일이 없습니다.'));
    list.forEach(function(o) { box.appendChild(occCard(o)); });
  }
}

/* ===== 내 목록 ===== */
function itemSummary(it) {
  if (it.itemType === 'BIRTHDAY') return '생일 · ' + (it.hasYear === 1 ? it.baseDate : it.baseDate.substring(5)) + ' · 매년 반복';
  var parts = ['시작 ' + it.baseDate];
  if (it.intervalDays > 0) parts.push(it.intervalDays + '일마다');
  if (it.yearly === 1) parts.push('매년 주년');
  return parts.join(' · ');
}
function renderList() {
  var box = document.getElementById('tab-list');
  box.innerHTML = '';
  if (!items.length) { box.appendChild(el('div', 'empty', '등록된 항목이 없습니다.')); return; }
  items.forEach(function(it) {
    var c = el('div', 'card');
    var m = el('div', 'main');
    m.appendChild(el('div', 't', (it.itemType === 'BIRTHDAY' ? '🎂 ' : '💕 ') + it.title));
    m.appendChild(el('div', 's', itemSummary(it)));
    m.appendChild(el('div', 's', '알림: ' + notifyText(it.notifyDays)));
    c.appendChild(m);
    var act = el('div', 'act');
    var eb = el('button', 'mini', '수정'); eb.type = 'button'; eb.addEventListener('click', function() { openForm(it); });
    var db = el('button', 'mini del', '삭제'); db.type = 'button'; db.addEventListener('click', function() { removeItem(it); });
    act.appendChild(eb); act.appendChild(db);
    c.appendChild(act);
    box.appendChild(c);
  });
}
function notifyText(s) {
  if (!s) return '없음';
  return s.split(',').map(function(n) { return +n === 0 ? '당일' : n + '일 전'; }).join(', ');
}
function removeItem(it) {
  if (!confirm('"' + it.title + '" 을(를) 삭제하시겠습니까?')) return;
  showLoading();
  api('/calendar/api/delete/' + it.itemId, { method: 'POST' }).then(reloadAll).catch(function() { hideLoading(); alert('삭제에 실패했습니다.'); });
}

/* ===== 추가/수정 폼 ===== */
function buildChips(selected) {
  var box = document.getElementById('notifyChips');
  box.innerHTML = '';
  NOTIFY_OPTS.forEach(function(o) {
    var lab = el('label', selected.indexOf(o[0]) >= 0 ? 'on' : '');
    var cb = document.createElement('input'); cb.type = 'checkbox'; cb.value = o[0]; cb.checked = selected.indexOf(o[0]) >= 0;
    cb.addEventListener('change', function() { lab.classList.toggle('on', cb.checked); });
    lab.appendChild(cb); lab.appendChild(document.createTextNode(o[1]));
    box.appendChild(lab);
  });
}
function setType(t) {
  formType = t;
  Array.prototype.forEach.call(document.querySelectorAll('#typeSeg button'), function(b) { b.classList.toggle('on', b.dataset.type === t); });
  document.getElementById('ddayOpts').style.display = t === 'DDAY' ? 'block' : 'none';
  document.getElementById('bdayOpts').style.display = t === 'BIRTHDAY' ? 'block' : 'none';
  document.getElementById('fDateLabel').textContent = t === 'DDAY' ? '시작일' : '생일';
}
Array.prototype.forEach.call(document.querySelectorAll('#typeSeg button'), function(b) {
  b.addEventListener('click', function() { setType(this.dataset.type); });
});

function openForm(it) {
  editing = it || null;
  document.getElementById('formTitle').textContent = it ? '수정' : '추가';
  document.getElementById('fErr').textContent = '';
  setType(it ? it.itemType : 'DDAY');
  document.getElementById('fTitle').value = it ? it.title : '';
  document.getElementById('fDate').value = it ? it.baseDate : today;
  document.getElementById('fFromOne').checked = it ? it.countFromOne === 1 : true;
  document.getElementById('fInterval').value = it ? it.intervalDays : 100;
  document.getElementById('fYearly').checked = it ? it.yearly === 1 : true;
  document.getElementById('fHasYear').checked = it ? it.hasYear === 1 : true;
  document.getElementById('fMemo').value = it && it.memo ? it.memo : '';
  var sel = it ? (it.notifyDays ? it.notifyDays.split(',').map(Number) : []) : [7, 1, 0];
  buildChips(sel);
  // 항목 종류는 수정 시 바꾸지 않음
  document.getElementById('typeSeg').style.display = it ? 'none' : 'flex';
  document.getElementById('formModal').classList.add('show');
}
function closeForm() { document.getElementById('formModal').classList.remove('show'); }

function saveForm() {
  var title = document.getElementById('fTitle').value.trim();
  var date = document.getElementById('fDate').value;
  var err = document.getElementById('fErr');
  if (!title) { err.textContent = '제목을 입력해 주세요.'; return; }
  if (!date) { err.textContent = '날짜를 선택해 주세요.'; return; }
  var days = [];
  Array.prototype.forEach.call(document.querySelectorAll('#notifyChips input'), function(cb) { if (cb.checked) days.push(cb.value); });
  var body = {
    itemId: editing ? editing.itemId : 0,
    itemType: formType,
    title: title,
    baseDate: date,
    hasYear: document.getElementById('fHasYear').checked ? 1 : 0,
    countFromOne: document.getElementById('fFromOne').checked ? 1 : 0,
    intervalDays: parseInt(document.getElementById('fInterval').value, 10) || 0,
    yearly: document.getElementById('fYearly').checked ? 1 : 0,
    notifyDays: days.join(','),
    memo: document.getElementById('fMemo').value.trim()
  };
  err.textContent = '';
  showLoading();
  api('/calendar/api/save', { method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify(body) })
    .then(function() { closeForm(); return reloadAll(); })
    .catch(function() { hideLoading(); err.textContent = '저장에 실패했습니다. 입력값을 확인해 주세요.'; });
}

/* ===== 데이터 로드 ===== */
function reloadAll() {
  return Promise.all([api('/calendar/api/items'), api('/calendar/api/upcoming')]).then(function(r) {
    today = r[0].today;
    todayHoliday = r[0].todayHoliday || null;
    items = r[0].items || [];
    upcoming = r[1].list || [];
    if (!viewYear) { var p = parse(today); viewYear = p.y; viewMonth = p.m; selDate = today; }
    paintToday();
    renderUpcoming();
    renderList();
    if (document.getElementById('tab-cal').style.display !== 'none') return loadMonth();
  }).catch(function() {
    document.getElementById('tab-up').innerHTML = '';
    document.getElementById('tab-up').appendChild(el('div', 'empty', '불러오지 못했습니다. 새로고침해 주세요.'));
  }).then(hideLoading);
}

/* ===== PWA / 푸시 알림 ===== */
var pushSub = null;
function pushSupported() { return 'serviceWorker' in navigator && 'PushManager' in window && 'Notification' in window; }
function b64ToU8(s) {
  var pad2 = new Array((4 - s.length % 4) % 4 + 1).join('=');
  var raw = atob((s + pad2).replace(/-/g, '+').replace(/_/g, '/'));
  var out = new Uint8Array(raw.length);
  for (var i = 0; i < raw.length; i++) out[i] = raw.charCodeAt(i);
  return out;
}
function updateBell() {
  var b = document.getElementById('bell');
  b.textContent = pushSub ? '🔔 알림 켜짐' : '🔕 알림 켜기';
  b.className = 'bell' + (pushSub ? ' on' : '');
}
function registerSW() {
  if (!('serviceWorker' in navigator)) return Promise.reject(new Error('no sw'));
  return navigator.serviceWorker.register(CTX + '/calendar/sw.js', { scope: CTX + '/calendar/' }).then(function() { return navigator.serviceWorker.ready; });
}
function initPush() {
  registerSW().then(function(reg) {
    if (!pushSupported()) return;
    document.getElementById('bell').style.display = 'inline-block';
    return reg.pushManager.getSubscription().then(function(sub) { pushSub = sub; updateBell(); });
  }).catch(function() {});
}
function togglePush() {
  if (pushSub) {
    if (!confirm('이 기기의 알림을 끌까요?')) return;
    var ep = pushSub.endpoint;
    pushSub.unsubscribe().then(function() {
      return api('/calendar/push/unsubscribe', { method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify({ endpoint: ep }) });
    }).then(function() { pushSub = null; updateBell(); }).catch(function() { alert('알림 해제에 실패했습니다.'); });
    return;
  }
  Notification.requestPermission().then(function(perm) {
    if (perm !== 'granted') { alert('알림 권한이 허용되지 않았습니다.\n브라우저(사이트) 설정에서 알림을 허용해 주세요.'); return; }
    return registerSW().then(function(reg) {
      return api('/calendar/push/key').then(function(r) {
        return reg.pushManager.subscribe({ userVisibleOnly: true, applicationServerKey: b64ToU8(r.key) });
      });
    }).then(function(sub) {
      return api('/calendar/push/subscribe', { method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify(sub.toJSON()) }).then(function(r) {
        if (!r.ok) throw new Error('subscribe failed');
        pushSub = sub; updateBell();
        return api('/calendar/push/test', { method: 'POST' });
      });
    });
  }).catch(function() { alert('알림 설정에 실패했습니다. (HTTPS 접속인지 확인해 주세요)'); });
}

document.addEventListener('keydown', function(e) { if (e.key === 'Escape') closeForm(); });

/* ===== 시작 ===== */
reloadAll();
initPush();
</script>
</body>
</html>
