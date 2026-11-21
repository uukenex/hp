<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>아기 기록</title>
<link rel="manifest" href="${pageContext.request.contextPath}/baby/manifest.json">
<meta name="theme-color" content="#ED93B1">
<link rel="icon" href="${pageContext.request.contextPath}/baby/icon/192.png">
<style>
  :root {
    --bg: #fff8fa; --card: #ffffff; --line: #f0dfe5; --text: #2d2327; --sub: #8a7a81;
    --accent: #D4537E; --accent-soft: #FBEAF0; --accent-text: #72243E;
    --blue: #378ADD; --blue-soft: #E6F1FB; --amber-soft: #FAEEDA; --amber: #854F0B; --green-soft: #E1F5EE; --green: #0F6E56;
    --danger: #c62828; --overlay: rgba(0,0,0,0.5);
  }
  @media (prefers-color-scheme: dark) {
    :root {
      --bg: #17121a; --card: #231b27; --line: #3a2f40; --text: #f3e9ee; --sub: #a99aa3;
      --accent: #ED93B1; --accent-soft: #3d2230; --accent-text: #f8cfe0;
      --blue: #85B7EB; --blue-soft: #1d2d40; --amber-soft: #3a2d17; --amber: #FAC775; --green-soft: #12332b; --green: #5DCAA5;
      --danger: #ef9a9a; --overlay: rgba(0,0,0,0.7);
    }
  }
  * { box-sizing: border-box; margin: 0; padding: 0; -webkit-tap-highlight-color: transparent; }
  body { font-family: 'Apple SD Gothic Neo','Malgun Gothic', sans-serif; background: var(--bg); color: var(--text); font-size: 14px; }
  button { font-family: inherit; cursor: pointer; touch-action: manipulation; color: inherit; }
  input, select, textarea { font-family: inherit; color: var(--text); }

  .top { background: var(--card); border-bottom: 1px solid var(--line); padding: 10px 14px; position: sticky; top: 0; z-index: 50; display: flex; align-items: center; gap: 10px; }
  .top .who { flex: 1; min-width: 0; }
  .top .nm { font-size: 17px; font-weight: 700; color: var(--accent); }
  .top .age { font-size: 12px; color: var(--sub); }
  .top .me { display: inline-block; margin-top: 3px; font-size: 11px; font-weight: 700; color: var(--accent-text); background: var(--accent-soft); border-radius: 10px; padding: 2px 9px; }
  .top select { border: 1px solid var(--line); background: var(--card); border-radius: 8px; padding: 5px 8px; font-size: 13px; }
  .bell { border: 1px solid var(--line); background: var(--card); border-radius: 16px; padding: 6px 10px; font-size: 13px; font-weight: 600; white-space: nowrap; }
  .bell.on { background: var(--accent-soft); border-color: var(--accent); }
  .home { color: var(--sub); font-size: 12px; text-decoration: none; }

  .wrap { max-width: 560px; margin: 0 auto; padding: 12px 12px 40px; }
  .tabs { display: flex; gap: 6px; margin-bottom: 12px; }
  .tabs button { flex: 1; padding: 9px 2px; border: 1px solid var(--line); background: var(--card); border-radius: 20px; font-size: 13px; font-weight: 600; color: var(--sub); }
  .tabs button.on { background: var(--accent); border-color: var(--accent); color: #fff; }

  .card { background: var(--card); border: 1px solid var(--line); border-radius: 14px; padding: 12px 14px; margin-bottom: 10px; }
  .card h3 { font-size: 13px; color: var(--sub); font-weight: 600; margin-bottom: 8px; }
  .row { display: flex; align-items: center; gap: 8px; }
  .grow { flex: 1; min-width: 0; }
  .muted { color: var(--sub); font-size: 12px; }

  .datenav { display: flex; align-items: center; justify-content: center; gap: 10px; margin-bottom: 10px; }
  .datenav button { border: 1px solid var(--line); background: var(--card); border-radius: 8px; padding: 6px 12px; font-size: 15px; }
  .datenav .d { font-weight: 700; min-width: 140px; text-align: center; }
  .datenav .td { font-size: 12px; padding: 6px 10px; }

  .status { display: grid; grid-template-columns: 1fr 1fr; gap: 8px; margin-bottom: 10px; }
  .st { border-radius: 14px; padding: 10px 12px; }
  .st .l { font-size: 11px; color: var(--sub); }
  .st .v { font-size: 16px; font-weight: 700; margin-top: 2px; }
  .st .s { font-size: 12px; color: var(--sub); margin-top: 2px; }
  .st.feed { background: var(--blue-soft); }
  .st.sleep { background: var(--accent-soft); }
  .st.sleep.on { background: var(--amber-soft); }

  .quick { display: grid; grid-template-columns: repeat(4, 1fr); gap: 8px; margin-bottom: 10px; }
  .quick button { border: 1px solid var(--line); background: var(--card); border-radius: 14px; padding: 12px 2px 9px; font-size: 12px; font-weight: 600; display: flex; flex-direction: column; align-items: center; gap: 4px; }
  .quick .ic { font-size: 26px; line-height: 1; }
  .quick button:active { background: var(--accent-soft); }

  .sum { display: grid; grid-template-columns: repeat(4, 1fr); gap: 6px; margin-bottom: 10px; }
  .sum > div { background: var(--card); border: 1px solid var(--line); border-radius: 12px; padding: 8px 4px; text-align: center; }
  .sum .n { font-size: 15px; font-weight: 700; }
  .sum .t { font-size: 10px; color: var(--sub); margin-top: 2px; }

  .tl { padding: 0; overflow: hidden; }
  .tl .it { display: flex; align-items: center; gap: 10px; padding: 11px 14px; border-bottom: 1px solid var(--line); cursor: pointer; }
  .tl .it:last-child { border-bottom: none; }
  .tl .tm { width: 50px; font-size: 13px; font-weight: 700; color: var(--accent); flex: none; }
  .tl .ic { font-size: 20px; flex: none; }
  .tl .tx { flex: 1; min-width: 0; }
  .tl .tx .a { font-size: 14px; }
  .tl .tx .b { font-size: 11px; color: var(--sub); margin-top: 1px; }
  .empty { text-align: center; color: var(--sub); padding: 28px 10px; line-height: 1.8; }

  .bars { display: flex; align-items: flex-end; gap: 6px; height: 120px; }
  .bar { flex: 1; display: flex; flex-direction: column; align-items: center; justify-content: flex-end; height: 100%; }
  .bar .v { font-size: 10px; color: var(--sub); margin-bottom: 2px; white-space: nowrap; }
  .bar .b { width: 100%; max-width: 30px; border-radius: 6px 6px 0 0; background: var(--accent); min-height: 2px; }
  .bar .b.blue { background: var(--blue); }
  .bar .b.amber { background: #EF9F27; }
  .bar .l { font-size: 10px; color: var(--sub); margin-top: 4px; }

  .field { margin-bottom: 12px; }
  .field label.l { display: block; font-size: 12px; font-weight: 700; margin-bottom: 5px; color: var(--sub); }
  .field input[type=text], .field input[type=date], .field input[type=number], .field input[type=datetime-local], .field select, .field textarea {
    width: 100%; border: 1px solid var(--line); border-radius: 10px; padding: 11px 12px; font-size: 16px; background: var(--card);
  }
  .field input:focus, .field select:focus, .field textarea:focus { outline: none; border-color: var(--accent); }
  .chips { display: flex; flex-wrap: wrap; gap: 6px; margin-top: 6px; }
  .chips button { border: 1px solid var(--line); background: var(--card); border-radius: 16px; padding: 6px 12px; font-size: 13px; }
  .chips button.on { background: var(--accent-soft); border-color: var(--accent); color: var(--accent-text); font-weight: 700; }
  .seg { display: flex; gap: 6px; }
  .seg button { flex: 1; padding: 12px 4px; border: 1px solid var(--line); background: var(--card); border-radius: 10px; font-size: 15px; font-weight: 600; }
  .seg button.on { background: var(--accent-soft); border-color: var(--accent); color: var(--accent-text); }
  .stepper { display: flex; gap: 8px; align-items: center; }
  .stepper button { width: 48px; height: 48px; border-radius: 12px; border: 1px solid var(--line); background: var(--card); font-size: 22px; font-weight: 700; }
  .stepper input { text-align: center; font-size: 22px !important; font-weight: 700; }
  .btn { padding: 13px; border-radius: 12px; border: none; font-size: 15px; font-weight: 700; }
  .btn.primary { background: var(--accent); color: #fff; }
  .btn.ghost { background: var(--card); border: 1px solid var(--line); }
  .btn.danger { background: var(--card); border: 1px solid var(--danger); color: var(--danger); }
  .btn.wide { width: 100%; }
  .btns { display: flex; gap: 8px; margin-top: 6px; }
  .btns .btn { flex: 1; }
  .btns .btn.primary { flex: 2; }
  .big3 { display: grid; grid-template-columns: 1fr 1fr 1fr; gap: 8px; margin-bottom: 10px; }
  .big3 button { padding: 20px 4px; border-radius: 14px; border: 1px solid var(--line); background: var(--card); font-size: 16px; font-weight: 700; }
  .big3 button:active { background: var(--accent-soft); }
  .err { color: var(--danger); font-size: 12px; min-height: 16px; margin-bottom: 8px; }
  .code { font-size: 28px; font-weight: 700; letter-spacing: 6px; text-align: center; color: var(--accent); padding: 10px 0; }

  .modal-bg { display: none; position: fixed; inset: 0; background: var(--overlay); z-index: 500; align-items: flex-end; justify-content: center; }
  .modal-bg.show { display: flex; }
  .sheet { background: var(--bg); width: 100%; max-width: 560px; max-height: 92vh; overflow-y: auto; border-radius: 18px 18px 0 0; padding: 16px; }
  .sheet h2 { font-size: 16px; color: var(--accent); margin-bottom: 12px; display: flex; justify-content: space-between; align-items: center; }
  .sheet h2 button { background: none; border: none; font-size: 22px; color: var(--sub); }

  .loading { display: none; position: fixed; inset: 0; z-index: 900; background: rgba(0,0,0,0.5); flex-direction: column; align-items: center; justify-content: center; gap: 14px; color: #fff; font-size: 14px; }
  .loading.show { display: flex; }
  .spinner { width: 46px; height: 46px; border: 5px solid rgba(255,255,255,0.3); border-top-color: #fff; border-radius: 50%; animation: spin 0.8s linear infinite; }
  @keyframes spin { to { transform: rotate(360deg); } }
  .toast { position: fixed; left: 50%; bottom: 24px; transform: translateX(-50%); background: #333; color: #fff; padding: 10px 18px; border-radius: 20px; font-size: 13px; z-index: 950; display: none; max-width: 90%; }
  .toast.show { display: block; }
</style>
</head>
<body>

<div id="loading" class="loading show"><div class="spinner"></div><div>불러오는 중…</div></div>
<div id="toast" class="toast"></div>

<div class="top">
  <div class="who">
    <div class="nm" id="babyName">아기 기록</div>
    <div class="age" id="babyAge"></div>
    <div class="me" id="meBadge"></div>
  </div>
  <select id="babySel" style="display:none;"></select>
  <button type="button" id="bell" class="bell" style="display:none;" onclick="togglePush()">🔕 알림</button>
  <a class="home" href="${pageContext.request.contextPath}/">홈</a>
</div>

<div class="wrap">
  <div id="onboard" style="display:none;"></div>

  <div id="main" style="display:none;">
    <div class="tabs" id="tabs">
      <button type="button" data-tab="today" class="on">오늘</button>
      <button type="button" data-tab="stats">통계</button>
      <button type="button" data-tab="growth">성장</button>
      <button type="button" data-tab="set">설정</button>
    </div>

    <section id="tab-today">
      <div class="datenav">
        <button type="button" onclick="moveDay(-1)">‹</button>
        <div class="d" id="dayLabel"></div>
        <button type="button" onclick="moveDay(1)">›</button>
        <button type="button" class="td" onclick="goToday()">오늘</button>
      </div>

      <div class="status">
        <div class="st feed"><div class="l">마지막 수유</div><div class="v" id="stFeed">-</div><div class="s" id="stFeedSub"></div></div>
        <div class="st sleep" id="stSleepBox"><div class="l" id="stSleepLabel">수면</div><div class="v" id="stSleep">-</div><div class="s" id="stSleepSub"></div></div>
      </div>

      <div class="quick">
        <button type="button" onclick="openSheet('FORMULA')"><span class="ic">🍼</span>분유</button>
        <button type="button" onclick="openSheet('BREAST')"><span class="ic">🤱</span>모유</button>
        <button type="button" onclick="openSheet('SOLID')"><span class="ic">🥣</span>이유식</button>
        <button type="button" onclick="openSheet('SLEEP')"><span class="ic" id="sleepIc">😴</span><span id="sleepBtnTxt">수면</span></button>
        <button type="button" onclick="openSheet('DIAPER')"><span class="ic">🧷</span>기저귀</button>
        <button type="button" onclick="openSheet('GROWTH')"><span class="ic">📏</span>성장</button>
        <button type="button" onclick="openSheet('TEMP')"><span class="ic">🌡️</span>체온</button>
        <button type="button" onclick="openSheet('MEDICINE')"><span class="ic">💊</span>투약</button>
      </div>

      <div class="sum" id="sum"></div>
      <div class="card tl" id="timeline"></div>
    </section>

    <section id="tab-stats" style="display:none;"></section>
    <section id="tab-growth" style="display:none;"></section>
    <section id="tab-set" style="display:none;"></section>
  </div>
</div>

<div class="modal-bg" id="sheetBg" onclick="if(event.target===this)closeSheet()">
  <div class="sheet"><h2><span id="sheetTitle"></span><button type="button" onclick="closeSheet()">✕</button></h2><div id="sheetBody"></div></div>
</div>

<script>
var CTX = '${pageContext.request.contextPath}';
var DOW = ['일', '월', '화', '수', '목', '금', '토'];
var TYPES = {
  FORMULA: { ic: '🍼', name: '분유' }, BREAST: { ic: '🤱', name: '모유' }, SOLID: { ic: '🥣', name: '이유식' },
  SLEEP: { ic: '😴', name: '수면' }, DIAPER: { ic: '🧷', name: '기저귀' }, GROWTH: { ic: '📏', name: '성장' },
  TEMP: { ic: '🌡️', name: '체온' }, MEDICINE: { ic: '💊', name: '투약' }
};

var state = { babies: [], baby: null, today: '', date: '', logs: [], summary: null, tab: 'today' };

/* ===== 유틸 ===== */
function pad(n) { return n < 10 ? '0' + n : '' + n; }
function ymd(d) { return d.getFullYear() + '-' + pad(d.getMonth() + 1) + '-' + pad(d.getDate()); }
function parseYmd(s) { var p = s.split('-'); return new Date(+p[0], +p[1] - 1, +p[2]); }
function addDays(s, n) { var d = parseYmd(s); d.setDate(d.getDate() + n); return ymd(d); }
function nowLocalInput() { return toInput(new Date()); }
function toInput(d) { return ymd(d) + 'T' + pad(d.getHours()) + ':' + pad(d.getMinutes()); }
function fromServer(s) { return s ? s.replace(' ', 'T') : ''; }   // yyyy-MM-dd HH:mm -> datetime-local
function toServer(s) { return s ? s.replace('T', ' ') : null; }
function hm(s) { return s.substring(11, 16); }
function el(tag, cls, text) { var e = document.createElement(tag); if (cls) e.className = cls; if (text != null) e.textContent = text; return e; }
function btn(text, cls, fn) { var b = el('button', cls, text); b.type = 'button'; if (fn) b.addEventListener('click', fn); return b; }
function dur(min) { if (min < 60) return min + '분'; var h = Math.floor(min / 60), r = min % 60; return r ? h + '시간 ' + r + '분' : h + '시간'; }
function ago(min) { return min < 1 ? '방금 전' : dur(min) + ' 전'; }
function numStr(v) { return v == null ? '' : (v === Math.floor(v) ? String(v) : String(v)); }

function toast(msg) {
  var t = document.getElementById('toast'); t.textContent = msg; t.classList.add('show');
  clearTimeout(toast.h); toast.h = setTimeout(function() { t.classList.remove('show'); }, 2200);
}
function showLoading() { document.getElementById('loading').classList.add('show'); }
function hideLoading() { document.getElementById('loading').classList.remove('show'); }

function api(url, opts) {
  return fetch(CTX + url, opts).then(function(r) {
    if (r.redirected) { location.reload(); throw new Error('login'); }   // 로그인 만료
    return r.json().catch(function() { return {}; }).then(function(j) {
      if (!r.ok) { var e = new Error((j && j.error) || ('http ' + r.status)); e.status = r.status; e.payload = j; throw e; }
      return j;
    });
  });
}
function post(url, body) { return api(url, { method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify(body) }); }

/* ===== 아기 정보 ===== */
function ageText(birth, today) {
  var b = parseYmd(birth), t = parseYmd(today);
  var days = Math.round((t - b) / 86400000) + 1;   // 태어난 날을 1일로
  var months = (t.getFullYear() - b.getFullYear()) * 12 + (t.getMonth() - b.getMonth());
  if (t.getDate() < b.getDate()) months--;
  var s = '생후 ' + days + '일';
  if (months >= 1) s += ' · ' + months + '개월';
  return s;
}
function paintHeader() {
  var b = state.baby;
  document.getElementById('babyName').textContent = b ? b.name : '아기 기록';
  document.getElementById('babyAge').textContent = b ? ageText(b.birthDate, state.today) : '';
  var who = (b && b.relation ? b.relation + ' ' : '') + (state.meName ? '(' + state.meName + ')' : '');
  document.getElementById('meBadge').textContent = who.trim() ? '👤 접속: ' + who.trim() : '';
  var sel = document.getElementById('babySel');
  sel.innerHTML = '';
  state.babies.forEach(function(x) { var o = document.createElement('option'); o.value = x.babyId; o.textContent = x.name; sel.appendChild(o); });
  sel.style.display = state.babies.length > 1 ? 'inline-block' : 'none';
  if (b) sel.value = b.babyId;
}
document.getElementById('babySel').addEventListener('change', function() { selectBaby(+this.value); });

function selectBaby(id) {
  for (var i = 0; i < state.babies.length; i++) if (state.babies[i].babyId === id) state.baby = state.babies[i];
  try { localStorage.setItem('baby_sel', String(id)); } catch (e) {}
  prefetchGrowth();
  paintHeader();
  state.date = state.today;
  showTab(state.tab);
  loadDay();
}

/* ===== 탭 ===== */
function showTab(name) {
  state.tab = name;
  ['today', 'stats', 'growth', 'set'].forEach(function(t) { document.getElementById('tab-' + t).style.display = t === name ? 'block' : 'none'; });
  Array.prototype.forEach.call(document.querySelectorAll('#tabs button'), function(b) { b.classList.toggle('on', b.dataset.tab === name); });
  if (name === 'stats') loadStats();
  if (name === 'growth') loadGrowth();
  if (name === 'set') renderSettings();
}
Array.prototype.forEach.call(document.querySelectorAll('#tabs button'), function(b) {
  b.addEventListener('click', function() { showTab(this.dataset.tab); });
});

/* ===== 오늘 탭 ===== */
function moveDay(n) { state.date = addDays(state.date, n); loadDay(); }
function goToday() { state.date = state.today; loadDay(); }

function loadDay() {
  if (!state.baby) return Promise.resolve();
  return api('/baby/api/day?babyId=' + state.baby.babyId + '&date=' + state.date).then(function(r) {
    state.logs = r.logs || [];
    state.summary = r.summary;
    paintDay();
  }).catch(function(e) { toast('불러오지 못했습니다.'); });
}

function describe(l) {
  var t = l.logType;
  if (t === 'FORMULA') return '분유 ' + numStr(l.ml) + 'ml';
  if (t === 'BREAST') {
    var side = l.detail === 'L' ? '왼쪽' : l.detail === 'R' ? '오른쪽' : '양쪽';
    var min = l.endAt ? Math.round((new Date(fromServer(l.endAt)) - new Date(fromServer(l.startAt))) / 60000) : 0;
    return '모유 ' + side + (min > 0 ? ' ' + min + '분' : '');
  }
  if (t === 'SOLID') return '이유식' + (l.ml ? ' ' + numStr(l.ml) : '') + (l.memo ? ' ' + l.memo : '');
  if (t === 'SLEEP') {
    if (!l.endAt) return '자는 중';
    var m = Math.round((new Date(fromServer(l.endAt)) - new Date(fromServer(l.startAt))) / 60000);
    return '수면 ' + dur(m) + ' (' + hm(l.startAt) + '~' + hm(l.endAt) + ')';
  }
  if (t === 'DIAPER') return l.detail === 'PEE' ? '소변' : l.detail === 'POOP' ? '대변' : '소변 + 대변';
  if (t === 'GROWTH') {
    var p = [];
    if (l.weightKg != null) p.push('체중 ' + numStr(l.weightKg) + 'kg');
    if (l.heightCm != null) p.push('키 ' + numStr(l.heightCm) + 'cm');
    if (l.headCm != null) p.push('머리 ' + numStr(l.headCm) + 'cm');
    return p.join(' · ');
  }
  if (t === 'TEMP') return '체온 ' + numStr(l.tempC) + '℃';
  if (t === 'MEDICINE') return '투약 ' + (l.memo || '');
  return t;
}

function paintDay() {
  var d = parseYmd(state.date);
  document.getElementById('dayLabel').textContent = (d.getMonth() + 1) + '월 ' + d.getDate() + '일 (' + DOW[d.getDay()] + ')' + (state.date === state.today ? ' · 오늘' : '');

  var s = state.summary, st = s.status;
  // 마지막 수유
  var feed = document.getElementById('stFeed'), feedSub = document.getElementById('stFeedSub');
  if (st.lastFeedAt) {
    feed.textContent = ago(st.lastFeedMinAgo);
    feedSub.textContent = hm(st.lastFeedAt) + ' · ' + (st.lastFeedType === 'FORMULA' ? '분유 ' + numStr(st.lastFeedMl) + 'ml' : '모유');
  } else { feed.textContent = '-'; feedSub.textContent = '기록 없음'; }
  // 수면 상태
  var box = document.getElementById('stSleepBox');
  box.classList.toggle('on', !!st.sleeping);
  document.getElementById('sleepBtnTxt').textContent = st.sleeping ? '깼어요' : '수면';
  document.getElementById('sleepIc').textContent = st.sleeping ? '☀️' : '😴';
  if (st.sleeping) {
    document.getElementById('stSleepLabel').textContent = '자는 중';
    document.getElementById('stSleep').textContent = dur(st.sleepMin);
    document.getElementById('stSleepSub').textContent = hm(st.sleepStartAt) + '부터';
  } else {
    document.getElementById('stSleepLabel').textContent = '깨어 있음';
    document.getElementById('stSleep').textContent = st.awakeMin != null ? dur(st.awakeMin) : '-';
    document.getElementById('stSleepSub').textContent = st.awakeMin != null ? '깬 지 경과' : '기록 없음';
  }

  // 일일 요약
  var sum = document.getElementById('sum'); sum.innerHTML = '';
  function cell(n, t) { var c = el('div'); c.appendChild(el('div', 'n', n)); c.appendChild(el('div', 't', t)); sum.appendChild(c); }
  cell(numStr(s.formulaMl) + 'ml', '분유 ' + s.formulaCount + '회');
  cell(s.feedCount + '회', '수유' + (s.avgFeedGapMin ? ' · 평균 ' + dur(s.avgFeedGapMin) : ''));
  cell(dur(s.sleepMin), '수면 (낮 ' + dur(s.napMin) + ')');
  cell(s.pee + ' / ' + s.poop, '기저귀 소변/대변');

  // 타임라인 (최신순)
  var tl = document.getElementById('timeline'); tl.innerHTML = '';
  if (!state.logs.length) { tl.appendChild(el('div', 'empty', '이 날 기록이 없습니다. 위 버튼으로 기록해 보세요.')); return; }
  var list = state.logs.slice().sort(function(a, b) { return a.startAt < b.startAt ? 1 : a.startAt > b.startAt ? -1 : b.logId - a.logId; });
  list.forEach(function(l) {
    var it = el('div', 'it');
    var sameDay = l.startAt.substring(0, 10) === state.date;
    it.appendChild(el('div', 'tm', sameDay ? hm(l.startAt) : '전날'));
    it.appendChild(el('div', 'ic', TYPES[l.logType].ic));
    var tx = el('div', 'tx');
    tx.appendChild(el('div', 'a', describe(l) + (l.logType !== 'SLEEP' && l.logType !== 'SOLID' && l.logType !== 'MEDICINE' && l.memo ? ' · ' + l.memo : '')));
    tx.appendChild(el('div', 'b', (l.createdByName ? l.createdByName + ' 기록' : '') ));
    it.appendChild(tx);
    it.addEventListener('click', function() { openSheet(l.logType, l); });
    tl.appendChild(it);
  });
}

/* ===== 입력 시트 ===== */
function closeSheet() { document.getElementById('sheetBg').classList.remove('show'); }

/* 입력 위젯: 최대한 선택(칩/버튼/±)으로 입력하고, 글자 입력은 접어 둠 */
function chipPick(options, initial, onPick, multi) {
  var box = el('div', 'chips');
  var sel = multi ? (initial || []).slice() : initial;
  var buttons = [];
  function paint() {
    buttons.forEach(function(x) {
      var on = multi ? sel.indexOf(x.v) >= 0 : sel === x.v;
      x.b.classList.toggle('on', on);
    });
  }
  options.forEach(function(o) {
    var v = o[0], b = btn(o[1], '', function() {
      if (multi) { var i = sel.indexOf(v); if (i >= 0) sel.splice(i, 1); else sel.push(v); }
      else sel = (sel === v && o[2] === 'toggle') ? null : v;
      paint(); if (onPick) onPick(sel);
    });
    buttons.push({ v: v, b: b }); box.appendChild(b);
  });
  paint();
  box.get = function() { return sel; };
  box.set = function(v) { sel = v; paint(); if (onPick) onPick(sel); };
  return box;
}

function stepperInput(parent, label, init, step, presets, suffix) {
  var wrap = el('div', 'field'); wrap.appendChild(el('label', 'l', label));
  var st = el('div', 'stepper');
  var inp = document.createElement('input'); inp.type = 'number'; inp.inputMode = 'decimal'; inp.step = String(step); inp.value = init == null ? '' : init;
  function bump(d) {
    var cur = parseFloat(inp.value); if (isNaN(cur)) cur = init == null ? 0 : init;
    var v = Math.round((cur + d) * 100) / 100; if (v < 0) v = 0; inp.value = v;
  }
  st.appendChild(btn('−', '', function() { bump(-step); }));
  st.appendChild(inp);
  st.appendChild(btn('+', '', function() { bump(step); }));
  wrap.appendChild(st);
  if (presets && presets.length) {
    var chips = el('div', 'chips');
    presets.forEach(function(v) { chips.appendChild(btn(String(v) + (suffix || ''), '', function() { inp.value = v; })); });
    wrap.appendChild(chips);
  }
  parent.appendChild(wrap);
  return inp;
}

/* 메모는 기본적으로 접어 두고 필요할 때만 입력 */
function memoToggle(parent, initial, label) {
  var holder = el('div', 'field');
  var inp = document.createElement('input'); inp.type = 'text'; inp.maxLength = 300; inp.value = initial || '';
  var open = btn('＋ ' + (label || '메모 남기기'), 'btn ghost', null); open.style.cssText = 'padding:8px 12px;font-size:13px;';
  inp.style.display = initial ? 'block' : 'none'; open.style.display = initial ? 'none' : 'inline-block';
  open.addEventListener('click', function() { open.style.display = 'none'; inp.style.display = 'block'; inp.focus(); });
  holder.appendChild(open); holder.appendChild(inp); parent.appendChild(holder);
  return inp;
}

function openSheet(type, log) {
  var body = document.getElementById('sheetBody'); body.innerHTML = '';
  var editing = !!log;
  var open = state.summary && state.summary.status ? state.summary.status : {};
  // 수면: 자는 중이면 "깼어요"로 진행(진행 중인 수면 기록을 완성)
  var sleepWake = false;
  if (type === 'SLEEP' && !editing && open.sleeping) { sleepWake = true; }
  document.getElementById('sheetTitle').textContent = TYPES[type].ic + ' ' + TYPES[type].name + (editing ? ' 수정' : sleepWake ? ' · 깼어요' : ' 기록');

  var f = { startAt: log ? fromServer(log.startAt) : nowLocalInput(), endAt: log && log.endAt ? fromServer(log.endAt) : '' };
  var err = el('div', 'err');

  function timeField(label, key, withQuick) {
    var wrap = el('div', 'field');
    wrap.appendChild(el('label', 'l', label));
    var inp = document.createElement('input'); inp.type = 'datetime-local'; inp.value = f[key];
    inp.addEventListener('change', function() { f[key] = this.value; });
    wrap.appendChild(inp);
    if (withQuick) {
      var chips = el('div', 'chips');
      [['지금', 0], ['10분 전', 10], ['30분 전', 30], ['1시간 전', 60], ['2시간 전', 120]].forEach(function(q) {
        chips.appendChild(btn(q[0], '', function() { inp.value = toInput(new Date(Date.now() - q[1] * 60000)); f[key] = inp.value; }));
      });
      wrap.appendChild(chips);
    }
    body.appendChild(wrap);
    return inp;
  }
  function num(i) { var v = parseFloat(i.value); return isNaN(v) ? null : v; }
  function labelBox(text) { var w = el('div', 'field'); w.appendChild(el('label', 'l', text)); body.appendChild(w); return w; }

  var collect = null;

  if (type === 'FORMULA') {
    timeField('먹인 시간', 'startAt', true);
    var def = 120;
    for (var k = state.logs.length - 1; k >= 0; k--) if (state.logs[k].logType === 'FORMULA' && state.logs[k].ml) { def = state.logs[k].ml; break; }
    var ml = stepperInput(body, '분유량 (ml)', log ? log.ml : def, 10, [60, 80, 100, 120, 140, 160, 180, 200], '');
    var memo = memoToggle(body, log ? log.memo : '');
    collect = function() { return { ml: num(ml), memo: memo.value }; };
  } else if (type === 'BREAST') {
    timeField('시작 시간', 'startAt', true);
    var side = log ? log.detail : 'L';
    var sideBox = labelBox('수유한 쪽');
    var sideSeg = chipPick([['L', '왼쪽'], ['R', '오른쪽'], ['B', '양쪽']], side, function(v) { side = v; });
    sideSeg.className = 'seg'; sideBox.appendChild(sideSeg);
    var minutes = log && log.endAt ? Math.round((new Date(fromServer(log.endAt)) - new Date(fromServer(log.startAt))) / 60000) : 10;
    var mi = stepperInput(body, '수유 시간 (분)', minutes, 5, [5, 10, 15, 20, 25, 30], '분');
    var memoB = memoToggle(body, log ? log.memo : '');
    collect = function() {
      var m = num(mi) || 0;
      var end = m > 0 && f.startAt ? toInput(new Date(new Date(f.startAt).getTime() + m * 60000)) : '';
      return { detail: side, endAt: end, memo: memoB.value };
    };
  } else if (type === 'SOLID') {
    timeField('먹인 시간', 'startAt', true);
    var amt = stepperInput(body, '먹은 양 (g 또는 ml)', log && log.ml ? log.ml : 50, 10, [30, 50, 80, 100, 150, 200], '');
    var foods = ['쌀미음', '쌀죽', '채소죽', '소고기죽', '닭죽', '과일', '간식'];
    var cur = log && log.memo ? log.memo.split(', ') : [];
    var picked = cur.filter(function(x) { return foods.indexOf(x) >= 0; });
    var extra = cur.filter(function(x) { return foods.indexOf(x) < 0; }).join(', ');
    var foodBox = labelBox('먹인 음식 (여러 개 선택 가능)');
    var foodChips = chipPick(foods.map(function(x) { return [x, x]; }), picked, null, true); foodBox.appendChild(foodChips);
    var memoS = memoToggle(body, extra, '직접 입력');
    collect = function() {
      var parts = foodChips.get().slice(); if (memoS.value.trim()) parts.push(memoS.value.trim());
      return { ml: num(amt), memo: parts.join(', ') };
    };
  } else if (type === 'SLEEP') {
    if (sleepWake) {
      f.startAt = fromServer(open.sleepStartAt);
      body.appendChild(el('div', 'muted', hm(open.sleepStartAt) + '에 잠들었어요. 깬 시간을 확인해 주세요.'));
      f.endAt = nowLocalInput();
      timeField('깬 시간', 'endAt', true);
      collect = function() { return { _wake: true }; };
    } else {
      timeField('잠든 시간', 'startAt', true);
      var endWrap = timeField('깬 시간 (비워 두면 자는 중)', 'endAt', false);
      if (!editing) {
        var chipsE = el('div', 'chips'); chipsE.appendChild(btn('지금 깼어요', '', function() { endWrap.value = nowLocalInput(); f.endAt = endWrap.value; }));
        endWrap.parentNode.appendChild(chipsE);
      }
      collect = function() { return {}; };
    }
  } else if (type === 'DIAPER') {
    timeField('시간', 'startAt', true);
    var conds = ['정상', '묽음', '단단함', '노란색', '녹색', '갈색'];
    var curD = log && log.memo ? log.memo.split(', ') : [];
    var condBox = labelBox('상태 (선택, 여러 개 가능)');
    var condChips = chipPick(conds.map(function(x) { return [x, x]; }), curD.filter(function(x) { return conds.indexOf(x) >= 0; }), null, true); condBox.appendChild(condChips);
    var tBox = labelBox(editing ? '종류를 누르면 바로 저장됩니다' : '종류를 누르면 바로 저장됩니다');
    var big = el('div', 'big3');
    [['PEE', '💧 소변'], ['POOP', '💩 대변'], ['BOTH', '둘 다']].forEach(function(o) {
      big.appendChild(btn(o[1], '', function() { doSave({ detail: o[0], memo: condChips.get().join(', ') }); }));
    });
    tBox.appendChild(big);
    collect = null;
  } else if (type === 'GROWTH') {
    timeField('측정 시간', 'startAt', false);
    var lg = state.lastGrowth || {};
    var w = stepperInput(body, '체중 (kg)', log ? log.weightKg : (lg.weightKg != null ? lg.weightKg : 3.5), 0.1, null);
    var h = stepperInput(body, '키 (cm)', log ? log.heightCm : (lg.heightCm != null ? lg.heightCm : 50), 0.5, null);
    var hd = stepperInput(body, '머리둘레 (cm)', log ? log.headCm : (lg.headCm != null ? lg.headCm : 34), 0.5, null);
    body.appendChild(el('div', 'muted', '바뀐 값만 ＋/－로 맞춰 주세요. 지난 기록 값에서 시작합니다.'));
    var memoG = memoToggle(body, log ? log.memo : '');
    collect = function() { return { weightKg: num(w), heightCm: num(h), headCm: num(hd), memo: memoG.value }; };
  } else if (type === 'TEMP') {
    timeField('측정 시간', 'startAt', true);
    var tp = stepperInput(body, '체온 (℃)', log ? log.tempC : 36.8, 0.1, [36.5, 36.8, 37.0, 37.5, 38.0, 38.5, 39.0], '');
    var memoT = memoToggle(body, log ? log.memo : '');
    collect = function() { return { tempC: num(tp), memo: memoT.value }; };
  } else if (type === 'MEDICINE') {
    timeField('먹인 시간', 'startAt', true);
    var meds = ['해열제(아세트아미노펜)', '해열제(이부프로펜)', '유산균', '비타민D', '감기약', '기타'];
    var medBox = labelBox('약 종류');
    var curM = log && log.memo ? log.memo : '';
    var pickedM = null, typed = '';
    meds.forEach(function(x) { if (curM === x) pickedM = x; });
    if (!pickedM && curM) { pickedM = '기타'; typed = curM; }
    var medText = document.createElement('input'); medText.type = 'text'; medText.maxLength = 100; medText.placeholder = '약 이름 입력'; medText.value = typed;
    medText.style.cssText = 'margin-top:8px;display:' + (pickedM === '기타' ? 'block' : 'none') + ';';
    var medChips = chipPick(meds.map(function(x) { return [x, x]; }), pickedM, function(v) { medText.style.display = v === '기타' ? 'block' : 'none'; if (v === '기타') medText.focus(); });
    medBox.appendChild(medChips); medBox.appendChild(medText);
    collect = function() { var v = medChips.get(); return { memo: v === '기타' ? medText.value : (v || '') }; };
  }

  body.appendChild(err);

  function doSave(extra) {
    var rec = { logId: log ? log.logId : 0, babyId: state.baby.babyId, logType: type, startAt: toServer(f.startAt), endAt: toServer(f.endAt) || null };
    for (var k2 in extra) if (extra.hasOwnProperty(k2) && k2.charAt(0) !== '_') rec[k2] = extra[k2];
    if (extra._wake) {   // 진행 중인 수면 기록에 끝 시간만 채움
      rec.logId = open.sleepLogId; rec.startAt = toServer(f.startAt); rec.endAt = toServer(f.endAt);
    } else if (extra.endAt !== undefined) {
      rec.endAt = toServer(extra.endAt) || null;
    }
    if (!rec.startAt) { err.textContent = '시간을 입력해 주세요.'; return; }
    err.textContent = '';
    showLoading();
    post('/baby/api/log/save', rec).then(function() {
      closeSheet(); toast('저장했습니다.');
      return loadDay().then(function() { if (state.tab === 'stats') loadStats(); if (state.tab === 'growth') loadGrowth(); prefetchGrowth(); });
    }).catch(function(e) { err.textContent = e.message && e.message.indexOf('http') !== 0 ? e.message : '저장에 실패했습니다.'; }).then(hideLoading);
  }
  function doDelete() {
    if (!confirm('이 기록을 삭제할까요?')) return;
    showLoading();
    post('/baby/api/log/delete', { babyId: state.baby.babyId, logId: log.logId }).then(function() { closeSheet(); toast('삭제했습니다.'); return loadDay(); })
      .catch(function() { toast('삭제에 실패했습니다.'); }).then(hideLoading);
  }

  var btns = el('div', 'btns');
  if (editing) btns.appendChild(btn('삭제', 'btn danger', doDelete));
  btns.appendChild(btn('취소', 'btn ghost', closeSheet));
  if (collect) btns.appendChild(btn('저장', 'btn primary', function() { doSave(collect()); }));
  body.appendChild(btns);
  document.getElementById('sheetBg').classList.add('show');
}

/* 성장 기록 입력 시 지난 값에서 시작하도록 미리 불러 둠 */
function prefetchGrowth() {
  if (!state.baby) return;
  api('/baby/api/growth?babyId=' + state.baby.babyId).then(function(list) {
    var last = {};
    list.forEach(function(l) { ['weightKg', 'heightCm', 'headCm'].forEach(function(k) { if (l[k] != null) last[k] = l[k]; }); });
    state.lastGrowth = last;
  }).catch(function() {});
}

/* ===== 통계 탭 ===== */
function loadStats() {
  var box = document.getElementById('tab-stats'); box.innerHTML = '';
  api('/baby/api/week?babyId=' + state.baby.babyId + '&end=' + state.today).then(function(days) {
    function chart(title, key, fmt, cls, unit) {
      var card = el('div', 'card'); card.appendChild(el('h3', null, title));
      var max = 1; days.forEach(function(d) { max = Math.max(max, d[key]); });
      var bars = el('div', 'bars');
      days.forEach(function(d) {
        var col = el('div', 'bar');
        col.appendChild(el('div', 'v', d[key] ? fmt(d[key]) : ''));
        var b = el('div', 'b ' + cls); b.style.height = Math.max(2, Math.round(d[key] / max * 90)) + 'px';
        col.appendChild(b);
        var p = d.date.split('-'); var dt = new Date(+p[0], +p[1] - 1, +p[2]);
        col.appendChild(el('div', 'l', (+p[2]) + '(' + DOW[dt.getDay()] + ')'));
        bars.appendChild(col);
      });
      card.appendChild(bars);
      var tot = 0, cnt = 0; days.forEach(function(d) { tot += d[key]; if (d[key]) cnt++; });
      card.appendChild(el('div', 'muted', cnt ? '기록된 날 평균 ' + fmt(Math.round(tot / cnt * 10) / 10) + unit : '기록이 없습니다.'));
      box.appendChild(card);
    }
    days.forEach(function(d) { d.diaper = d.pee + d.poop; });
    chart('분유량 (최근 7일)', 'formulaMl', function(v) { return numStr(Math.round(v)); }, '', 'ml');
    chart('수유 횟수 (분유 + 모유)', 'feedCount', function(v) { return String(Math.round(v)); }, 'blue', '회');
    chart('수면 시간', 'sleepMin', function(v) { return (Math.round(v / 6) / 10) + 'h'; }, 'amber', '');
    chart('기저귀 횟수', 'diaper', function(v) { return String(Math.round(v)); }, 'blue', '회');
  }).catch(function() { box.appendChild(el('div', 'empty', '통계를 불러오지 못했습니다.')); });
}

/* ===== 성장 탭 ===== */
function lineChart(title, pts, unit) {
  var card = el('div', 'card'); card.appendChild(el('h3', null, title));
  if (pts.length < 2) { card.appendChild(el('div', 'muted', pts.length ? '최근 ' + numStr(pts[0].v) + unit + ' (두 번 이상 기록하면 그래프가 나옵니다)' : '기록이 없습니다.')); return card; }
  var W = 300, H = 110, pl = 8, pr = 8, pt = 14, pb = 18;
  var xs = pts.map(function(p) { return p.t; }), ys = pts.map(function(p) { return p.v; });
  var x0 = Math.min.apply(null, xs), x1 = Math.max.apply(null, xs), y0 = Math.min.apply(null, ys), y1 = Math.max.apply(null, ys);
  if (y1 === y0) { y1 += 1; y0 -= 1; }
  function X(t) { return pl + (x1 === x0 ? 0 : (t - x0) / (x1 - x0)) * (W - pl - pr); }
  function Y(v) { return pt + (1 - (v - y0) / (y1 - y0)) * (H - pt - pb); }
  var ns = 'http://www.w3.org/2000/svg';
  var svg = document.createElementNS(ns, 'svg'); svg.setAttribute('viewBox', '0 0 ' + W + ' ' + H); svg.style.width = '100%';
  var path = pts.map(function(p, i) { return (i ? 'L' : 'M') + X(p.t).toFixed(1) + ' ' + Y(p.v).toFixed(1); }).join(' ');
  var line = document.createElementNS(ns, 'path'); line.setAttribute('d', path); line.setAttribute('fill', 'none'); line.setAttribute('stroke', '#D4537E'); line.setAttribute('stroke-width', '2'); svg.appendChild(line);
  pts.forEach(function(p, i) {
    var c = document.createElementNS(ns, 'circle'); c.setAttribute('cx', X(p.t)); c.setAttribute('cy', Y(p.v)); c.setAttribute('r', 3.5); c.setAttribute('fill', '#D4537E'); svg.appendChild(c);
    if (i === 0 || i === pts.length - 1) {
      var tx = document.createElementNS(ns, 'text'); tx.setAttribute('x', Math.min(W - 24, Math.max(10, X(p.t)))); tx.setAttribute('y', Y(p.v) - 7); tx.setAttribute('text-anchor', 'middle');
      tx.setAttribute('font-size', '10'); tx.setAttribute('fill', 'currentColor'); tx.textContent = numStr(p.v); svg.appendChild(tx);
    }
  });
  card.appendChild(svg);
  var first = pts[0], last = pts[pts.length - 1];
  card.appendChild(el('div', 'muted', numStr(first.v) + unit + ' → ' + numStr(last.v) + unit + ' (' + (last.v >= first.v ? '+' : '') + (Math.round((last.v - first.v) * 100) / 100) + unit + ')'));
  return card;
}
function loadGrowth() {
  var box = document.getElementById('tab-growth'); box.innerHTML = '';
  var add = btn('+ 성장 기록 추가', 'btn primary wide', function() { openSheet('GROWTH'); }); box.appendChild(add); add.style.marginBottom = '10px';
  api('/baby/api/growth?babyId=' + state.baby.babyId).then(function(list) {
    function series(key) {
      return list.filter(function(l) { return l[key] != null; }).map(function(l) { return { t: new Date(fromServer(l.startAt)).getTime(), v: l[key] }; });
    }
    box.appendChild(lineChart('체중 (kg)', series('weightKg'), 'kg'));
    box.appendChild(lineChart('키 (cm)', series('heightCm'), 'cm'));
    box.appendChild(lineChart('머리둘레 (cm)', series('headCm'), 'cm'));
    var card = el('div', 'card tl'); box.appendChild(card);
    if (!list.length) { card.appendChild(el('div', 'empty', '성장 기록이 없습니다.')); return; }
    list.slice().reverse().forEach(function(l) {
      var it = el('div', 'it');
      it.appendChild(el('div', 'tm', l.startAt.substring(5, 10)));
      it.appendChild(el('div', 'ic', '📏'));
      var tx = el('div', 'tx'); tx.appendChild(el('div', 'a', describe(l))); it.appendChild(tx);
      it.addEventListener('click', function() { openSheet('GROWTH', l); });
      card.appendChild(it);
    });
  }).catch(function() { box.appendChild(el('div', 'empty', '성장 기록을 불러오지 못했습니다.')); });
}

/* ===== 설정 탭 ===== */
function renderSettings() {
  var box = document.getElementById('tab-set'); box.innerHTML = '';
  var b = state.baby, owner = b.isOwner === 1;

  // 아기 정보
  var c1 = el('div', 'card'); c1.appendChild(el('h3', null, '아기 정보' + (owner ? '' : ' (보호자 대표만 수정할 수 있어요)')));
  function field(parent, label, input) { var w = el('div', 'field'); w.appendChild(el('label', 'l', label)); w.appendChild(input); parent.appendChild(w); }
  var nm = document.createElement('input'); nm.type = 'text'; nm.maxLength = 50; nm.value = b.name; nm.disabled = !owner;
  var bd = document.createElement('input'); bd.type = 'date'; bd.value = b.birthDate; bd.disabled = !owner;
  var gd = document.createElement('select'); [['', '선택 안 함'], ['F', '여아'], ['M', '남아']].forEach(function(o) { var op = document.createElement('option'); op.value = o[0]; op.textContent = o[1]; gd.appendChild(op); }); gd.value = b.gender || ''; gd.disabled = !owner;
  var rm = document.createElement('select');
  [[0, '끄기'], [1.5, '1시간 30분'], [2, '2시간'], [2.5, '2시간 30분'], [3, '3시간'], [3.5, '3시간 30분'], [4, '4시간'], [5, '5시간'], [6, '6시간']].forEach(function(o) { var op = document.createElement('option'); op.value = o[0]; op.textContent = o[1]; rm.appendChild(op); });
  rm.value = String(b.feedRemindHours || 0); rm.disabled = !owner;
  field(c1, '이름', nm); field(c1, '생년월일', bd); field(c1, '성별', gd); field(c1, '수유 간격 알림 (마지막 수유 후)', rm);
  var e1 = el('div', 'err'); c1.appendChild(e1);
  if (owner) c1.appendChild(btn('저장', 'btn primary wide', function() {
    showLoading();
    post('/baby/api/baby/update', { babyId: b.babyId, name: nm.value, birthDate: bd.value, gender: gd.value, feedRemindHours: parseFloat(rm.value) || 0 })
      .then(function() { toast('저장했습니다.'); return reloadBabies(); }).catch(function(e) { e1.textContent = e.message; }).then(hideLoading);
  }));
  box.appendChild(c1);

  // 보호자
  var c2 = el('div', 'card'); c2.appendChild(el('h3', null, '함께 기록하는 보호자'));
  var memBox = el('div'); c2.appendChild(memBox);
  api('/baby/api/members?babyId=' + b.babyId).then(function(ms) {
    ms.forEach(function(m) {
      var r = el('div', 'row'); r.style.padding = '6px 0';
      r.appendChild(el('div', 'grow', (m.relation || '보호자') + ' (' + (m.nickname || '') + ')' + (m.isOwner === 1 ? ' · 대표' : '')));
      memBox.appendChild(r);
    });
  });
  var inv = el('div'); inv.style.marginTop = '8px';
  var codeBox = el('div'); inv.appendChild(codeBox);
  inv.appendChild(btn('초대 코드 만들기', 'btn ghost wide', function() {
    post('/baby/api/invite', { babyId: b.babyId }).then(function(r) {
      codeBox.innerHTML = '';
      codeBox.appendChild(el('div', 'code', r.code));
      codeBox.appendChild(el('div', 'muted', r.hours + '시간 동안, 한 번만 사용할 수 있어요. 배우자에게 코드를 알려 주고 "초대 코드로 참여"에서 입력하게 해 주세요.'));
    }).catch(function(e) { toast(e.message); });
  }));
  c2.appendChild(inv); box.appendChild(c2);

  // 내 알림 설정
  var c3 = el('div', 'card'); c3.appendChild(el('h3', null, '내 설정'));
  var rl = document.createElement('input'); rl.type = 'text'; rl.maxLength = 20; rl.value = b.relation || ''; rl.placeholder = '예) 엄마, 아빠';
  field(c3, '나의 호칭 (기록에 표시돼요)', rl);
  function check(label, checked) { var l = el('label'); l.style.cssText = 'display:flex;align-items:center;gap:8px;margin-bottom:10px;font-size:14px;'; var i = document.createElement('input'); i.type = 'checkbox'; i.checked = checked; i.style.cssText = 'width:20px;height:20px;accent-color:#D4537E;'; l.appendChild(i); l.appendChild(document.createTextNode(label)); c3.appendChild(l); return i; }
  var na = check('다른 보호자가 무언가 기록하면 알림 받기', b.notifyActivity === 'Y');
  var nr = check('수유 간격 알림 받기', b.notifyRemind === 'Y');
  var wk = check('화면 항상 켜두기 (냉장고에 두고 쓸 때)', wakeWanted());
  wk.addEventListener('change', function() { try { localStorage.setItem('baby_awake', wk.checked ? '1' : '0'); } catch (e) {} applyWakeLock(); toast(wk.checked ? '화면이 꺼지지 않게 합니다.' : '화면 항상 켜두기를 껐습니다.'); });
  c3.appendChild(btn('저장', 'btn primary wide', function() {
    post('/baby/api/member/update', { babyId: b.babyId, relation: rl.value, notifyActivity: na.checked ? 'Y' : 'N', notifyRemind: nr.checked ? 'Y' : 'N' })
      .then(function() { toast('저장했습니다.'); return reloadBabies(); }).catch(function(e) { toast(e.message); });
  }));
  c3.appendChild(el('div', 'muted', '알림은 이 기기에서 켜야 받을 수 있어요. 화면 위쪽의 알림 버튼을 눌러 주세요.'));
  box.appendChild(c3);

  // 아기 추가/참여/탈퇴
  var c4 = el('div', 'card'); c4.appendChild(el('h3', null, '기타'));
  c4.appendChild(btn('다른 아기 추가 / 초대 코드로 참여', 'btn ghost wide', function() { showOnboard(true); }));
  var lv = btn('이 아기에서 나가기', 'btn danger wide', function() {
    if (!confirm('이 아기의 보호자에서 나갈까요? 다른 보호자에게는 기록이 그대로 남아 있어요.')) return;
    post('/baby/api/leave', { babyId: b.babyId }).then(function() { toast('나갔습니다.'); return reloadBabies(); }).catch(function(e) { toast(e.message); });
  }); lv.style.marginTop = '8px'; c4.appendChild(lv);
  box.appendChild(c4);
}

/* ===== 처음 사용 / 아기 추가 / 코드 참여 ===== */
function showOnboard(canCancel) {
  var box = document.getElementById('onboard'); box.innerHTML = '';
  document.getElementById('main').style.display = 'none';
  box.style.display = 'block';

  var c1 = el('div', 'card'); c1.appendChild(el('h3', null, '아기 등록'));
  function field(parent, label, input) { var w = el('div', 'field'); w.appendChild(el('label', 'l', label)); w.appendChild(input); parent.appendChild(w); }
  var nm = document.createElement('input'); nm.type = 'text'; nm.maxLength = 50; nm.placeholder = '아기 이름 (애칭도 좋아요)';
  var bd = document.createElement('input'); bd.type = 'date'; bd.value = state.today || ymd(new Date());
  var gd = document.createElement('select'); [['', '선택 안 함'], ['F', '여아'], ['M', '남아']].forEach(function(o) { var op = document.createElement('option'); op.value = o[0]; op.textContent = o[1]; gd.appendChild(op); });
  var rl = document.createElement('input'); rl.type = 'text'; rl.maxLength = 20; rl.placeholder = '예) 엄마, 아빠';
  field(c1, '이름', nm); field(c1, '생년월일', bd); field(c1, '성별', gd); field(c1, '나의 호칭', rl);
  var e1 = el('div', 'err'); c1.appendChild(e1);
  c1.appendChild(btn('아기 등록하기', 'btn primary wide', function() {
    showLoading();
    post('/baby/api/baby/create', { name: nm.value, birthDate: bd.value, gender: gd.value, relation: rl.value }).then(function(r) {
      try { localStorage.setItem('baby_sel', String(r.babyId)); } catch (e) {}
      return reloadBabies();
    }).catch(function(e) { e1.textContent = e.message; }).then(hideLoading);
  }));
  box.appendChild(c1);

  var c2 = el('div', 'card'); c2.appendChild(el('h3', null, '초대 코드로 참여 (배우자가 먼저 등록한 경우)'));
  var cd = document.createElement('input'); cd.type = 'text'; cd.maxLength = 12; cd.placeholder = '초대 코드 6자리'; cd.style.textTransform = 'uppercase';
  var rl2 = document.createElement('input'); rl2.type = 'text'; rl2.maxLength = 20; rl2.placeholder = '예) 엄마, 아빠';
  field(c2, '초대 코드', cd); field(c2, '나의 호칭', rl2);
  var e2 = el('div', 'err'); c2.appendChild(e2);
  c2.appendChild(btn('참여하기', 'btn primary wide', function() {
    showLoading();
    post('/baby/api/join', { code: cd.value, relation: rl2.value }).then(function(r) {
      try { localStorage.setItem('baby_sel', String(r.babyId)); } catch (e) {}
      return reloadBabies();
    }).catch(function(e) { e2.textContent = e.message; }).then(hideLoading);
  }));
  box.appendChild(c2);
  if (canCancel) { var cb = btn('돌아가기', 'btn ghost wide', function() { box.style.display = 'none'; document.getElementById('main').style.display = 'block'; }); box.appendChild(cb); }
}

/* ===== 시작 ===== */
function reloadBabies() {
  return api('/baby/api/babies').then(function(r) {
    state.today = r.today; state.babies = r.babies || []; state.meName = r.meName || '';
    if (!state.date) state.date = state.today;
    if (!state.babies.length) {
      state.baby = null; paintHeader(); showOnboard(false); return;
    }
    var want = 0; try { want = +localStorage.getItem('baby_sel') || 0; } catch (e) {}
    var found = null;
    state.babies.forEach(function(x) { if (x.babyId === want) found = x; });
    state.baby = found || state.babies[0];
    prefetchGrowth();
    document.getElementById('onboard').style.display = 'none';
    document.getElementById('main').style.display = 'block';
    paintHeader();
    state.date = state.today;
    showTab(state.tab === 'set' ? 'set' : 'today');
    return loadDay();
  });
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
  var bl = document.getElementById('bell');
  bl.textContent = pushSub ? '🔔 알림 켜짐' : '🔕 알림 켜기';
  bl.className = 'bell' + (pushSub ? ' on' : '');
}
function registerSW() {
  if (!('serviceWorker' in navigator)) return Promise.reject(new Error('no sw'));
  return navigator.serviceWorker.register(CTX + '/baby/sw.js', { scope: CTX + '/baby/' }).then(function() { return navigator.serviceWorker.ready; });
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
    pushSub.unsubscribe().then(function() { return post('/baby/push/unsubscribe', { endpoint: ep }); })
      .then(function() { pushSub = null; updateBell(); }).catch(function() { alert('알림 해제에 실패했습니다.'); });
    return;
  }
  Notification.requestPermission().then(function(perm) {
    if (perm !== 'granted') { alert('알림 권한이 허용되지 않았습니다.\n브라우저(사이트) 설정에서 알림을 허용해 주세요.'); return; }
    return registerSW().then(function(reg) {
      return api('/baby/push/key').then(function(r) { return reg.pushManager.subscribe({ userVisibleOnly: true, applicationServerKey: b64ToU8(r.key) }); });
    }).then(function(sub) {
      return post('/baby/push/subscribe', sub.toJSON()).then(function(r) {
        if (!r.ok) throw new Error('subscribe failed');
        pushSub = sub; updateBell();
        return post('/baby/push/test', {});
      });
    });
  }).catch(function() { alert('알림 설정에 실패했습니다. (HTTPS 접속인지 확인해 주세요)'); });
}

/* ===== 냉장고에 두고 쓸 때: 자동 새로고침 / 화면 켜두기 ===== */
var wakeLock = null;
function wakeWanted() { try { return localStorage.getItem('baby_awake') === '1'; } catch (e) { return false; } }
function applyWakeLock() {
  if (!('wakeLock' in navigator)) return;
  if (!wakeWanted()) { if (wakeLock) { wakeLock.release(); wakeLock = null; } return; }
  if (wakeLock || document.hidden) return;
  navigator.wakeLock.request('screen').then(function(l) { wakeLock = l; l.addEventListener('release', function() { wakeLock = null; }); }).catch(function() {});
}
// 1분마다: 날짜가 바뀌었으면 오늘로 갱신, 아니면 다른 보호자의 기록을 반영 (입력창이 열려 있으면 건너뜀)
setInterval(function() {
  if (document.hidden || !state.baby) return;
  if (document.getElementById('sheetBg').classList.contains('show')) return;
  if (ymd(new Date()) !== state.today) { reloadBabies(); return; }
  if (state.tab === 'today') loadDay();
}, 60000);
document.addEventListener('visibilitychange', applyWakeLock);
applyWakeLock();

document.addEventListener('keydown', function(e) { if (e.key === 'Escape') closeSheet(); });
// 화면으로 돌아왔을 때 다른 보호자의 기록을 반영
document.addEventListener('visibilitychange', function() { if (!document.hidden && state.baby && state.tab === 'today') loadDay(); });

reloadBabies().catch(function() { toast('불러오지 못했습니다. 새로고침해 주세요.'); }).then(hideLoading);
initPush();
</script>
</body>
</html>
