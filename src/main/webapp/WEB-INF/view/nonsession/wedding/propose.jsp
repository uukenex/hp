<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>💌</title>
    <link href="https://fonts.googleapis.com/css2?family=Noto+Serif+KR:wght@300;400;600&family=Dancing+Script:wght@400;700&family=Cormorant+Garamond:ital,wght@0,300;1,300&display=swap" rel="stylesheet">
    <style>
        *, *::before, *::after { margin: 0; padding: 0; box-sizing: border-box; }

        body {
            min-height: 100vh;
            background: radial-gradient(ellipse at 35% 45%, #fdf8f0 0%, #f6ecdc 55%, #ede0c8 100%);
            display: flex;
            align-items: center;
            justify-content: center;
            font-family: 'Noto Serif KR', serif;
            overflow: hidden;
        }

        /* YES overlay — 100초에 걸쳐 서서히 */
        #yesOverlay {
            position: fixed;
            inset: 0;
            opacity: 0;
            background: linear-gradient(135deg, #1a3d25 0%, #254d34 40%, #305e42 70%, #1f4a2e 100%);
            transition: opacity 100s linear;
            z-index: 0;
            pointer-events: none;
        }

        /* 꽃잎 파티클 */
        .particles {
            position: fixed;
            inset: 0;
            pointer-events: none;
            z-index: 1;
        }
        .particle {
            position: absolute;
            border-radius: 50% 0;
            opacity: 0;
            animation: floatPetal linear infinite;
        }
        @keyframes floatPetal {
            0%   { transform: translateY(110vh) rotate(0deg);   opacity: 0; }
            8%   { opacity: 0.45; }
            92%  { opacity: 0.18; }
            100% { transform: translateY(-60px) rotate(600deg); opacity: 0; }
        }

        /* 내비게이션 */
        .nav-btn {
            position: fixed;
            top: 50%;
            transform: translateY(-50%);
            background: rgba(255, 255, 255, 0.28);
            backdrop-filter: blur(10px);
            -webkit-backdrop-filter: blur(10px);
            border: 1px solid rgba(184, 146, 46, 0.25);
            color: #9a7430;
            font-size: 22px;
            width: 42px;
            height: 42px;
            border-radius: 50%;
            cursor: pointer;
            display: flex;
            align-items: center;
            justify-content: center;
            transition: background 0.2s, border-color 0.2s, opacity 0.3s;
            z-index: 100;
        }
        .nav-btn:hover  { background: rgba(255,255,255,0.50); border-color: rgba(184,146,46,0.45); }
        .nav-btn:disabled { opacity: 0; pointer-events: none; }
        .nav-btn.prev { left: 14px; }
        .nav-btn.next { right: 14px; }

        .page-dots {
            position: fixed;
            bottom: 22px;
            left: 50%;
            transform: translateX(-50%);
            display: flex;
            gap: 8px;
            z-index: 100;
        }
        .dot {
            width: 6px; height: 6px;
            border-radius: 50%;
            background: rgba(184, 146, 46, 0.26);
            transition: background 0.35s, transform 0.35s;
        }
        .dot.active {
            background: rgba(130, 92, 36, 0.85);
            transform: scale(1.55);
        }

        /* 책 씬 */
        .book-scene {
            position: relative;
            z-index: 2;
            width: min(380px, 92vw);
            height: min(610px, 88vh);
        }
        .book-container {
            position: relative;
            width: 100%;
            height: 100%;
            perspective: 1800px;
        }

        /* 페이지 */
        .page {
            position: absolute;
            inset: 0;
            transform-origin: left center;
            transform-style: preserve-3d;
            border-radius: 2px 16px 16px 2px;
            box-shadow: 4px 4px 28px rgba(140,100,50,0.17), 10px 10px 48px rgba(0,0,0,0.09);
        }
        .page-face {
            position: absolute;
            inset: 0;
            backface-visibility: hidden;
            -webkit-backface-visibility: hidden;
            border-radius: 2px 16px 16px 2px;
            overflow: hidden;
        }
        .page-back {
            transform: rotateY(180deg);
            background: linear-gradient(145deg, #f8f2e2 0%, #eee3c8 100%);
        }
        .page-back-inner {
            width: 100%;
            height: 100%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 56px;
            background-image: repeating-linear-gradient(
                45deg, transparent, transparent 18px,
                rgba(184,146,46,0.06) 18px, rgba(184,146,46,0.06) 36px
            );
        }
        /* 제본선 그림자 */
        .page-face::before {
            content: '';
            position: absolute;
            top: 0; left: 0; bottom: 0; width: 18px;
            background: linear-gradient(to right, rgba(120,85,40,0.11), transparent);
            z-index: 2;
            pointer-events: none;
        }

        /* 초대장 이중 테두리 */
        .invite-frame {
            position: absolute;
            inset: 16px;
            border: 1px solid rgba(184, 146, 46, 0.32);
            border-radius: 2px;
            pointer-events: none;
            z-index: 0;
        }
        .invite-frame::before {
            content: '';
            position: absolute;
            inset: 6px;
            border: 1px solid rgba(184, 146, 46, 0.14);
            border-radius: 1px;
        }

        /* ===== 커버 (1장) ===== */
        .p1-front {
            background: linear-gradient(160deg, #f6ebda 0%, #eddfc3 50%, #e5d3ad 100%);
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: space-between;
            padding: 32px 36px 36px;
            /* position: relative 제거 — page-face의 absolute를 유지해야 높이가 맞음 */
        }

        .p1-top {
            display: flex;
            flex-direction: column;
            align-items: center;
            width: 100%;
        }

        .p1-heart {
            font-size: 54px;
            animation: heartbeat 1.8s ease-in-out infinite;
            margin-bottom: 12px;
        }
        @keyframes heartbeat {
            0%, 100% { transform: scale(1); }
            50%       { transform: scale(1.13); }
        }

        .p1-title {
            font-family: 'Dancing Script', cursive;
            font-size: 44px;
            color: #7a4f2e;
            text-shadow: 0 2px 18px rgba(255,255,255,0.65);
            margin-bottom: 4px;
            line-height: 1.1;
        }

        .p1-subtitle {
            font-size: 8.5px;
            color: rgba(120, 80, 40, 0.50);
            letter-spacing: 4.5px;
            text-transform: uppercase;
            margin-bottom: 18px;
        }

        /* 구분선 */
        .p1-rule {
            width: 100%;
            display: flex;
            align-items: center;
            gap: 12px;
            margin-bottom: 18px;
        }
        .p1-rule::before,
        .p1-rule::after {
            content: '';
            flex: 1;
            height: 1px;
            background: linear-gradient(to right, transparent, rgba(184,146,46,0.42), transparent);
        }
        .p1-rule-gem { font-size: 10px; color: rgba(184,146,46,0.65); }

        /* 인용구 */
        .p1-quote {
            font-family: 'Cormorant Garamond', 'Noto Serif KR', serif;
            font-style: italic;
            font-size: 13px;
            color: rgba(105, 72, 34, 0.62);
            text-align: center;
            line-height: 2;
            margin-bottom: 20px;
        }

        .p1-form { width: 100%; display: flex; flex-direction: column; gap: 14px; }

        .p1-label {
            display: block;
            font-size: 8.5px;
            color: rgba(120, 80, 40, 0.56);
            letter-spacing: 2.5px;
            text-transform: uppercase;
            margin-bottom: 7px;
        }

        .p1-input {
            width: 100%;
            padding: 12px 16px;
            background: rgba(255, 255, 255, 0.52);
            border: 1px solid rgba(184, 146, 46, 0.26);
            border-radius: 6px;
            color: #6b4c2c;
            font-size: 13px;
            font-family: 'Noto Serif KR', serif;
            outline: none;
            transition: border-color 0.3s, background 0.3s;
        }
        .p1-input:focus {
            border-color: rgba(184, 146, 46, 0.52);
            background: rgba(255, 255, 255, 0.78);
        }
        .p1-input::placeholder { color: rgba(150, 110, 65, 0.30); font-size: 12px; }

        .p1-btn {
            width: 100%;
            padding: 14px;
            background: linear-gradient(135deg, #c49668, #9a7040);
            border: none;
            border-radius: 6px;
            color: rgba(255,255,255,0.94);
            font-size: 13px;
            letter-spacing: 1px;
            font-family: 'Noto Serif KR', serif;
            cursor: pointer;
            box-shadow: 0 4px 18px rgba(154,112,64,0.36), inset 0 1px 0 rgba(255,255,255,0.14);
            transition: transform 0.2s, box-shadow 0.2s;
            margin-top: 4px;
        }
        .p1-btn:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 26px rgba(154,112,64,0.50);
        }

        .p1-hint {
            position: absolute;
            bottom: 14px;
            font-size: 8.5px;
            color: rgba(140, 100, 50, 0.34);
            letter-spacing: 2.5px;
        }

        /* ===== 사진 페이지 ===== */
        .photo-page {
            background: linear-gradient(150deg, #fefaf4 0%, #f8f2e5 50%, #f3ecd7 100%);
            padding: 22px 18px 14px;
            display: flex;
            flex-direction: column;
            gap: 9px;
        }
        .photo-page-label {
            text-align: center;
            font-size: 8px;
            color: rgba(154,112,64,0.70);
            letter-spacing: 5px;
            text-transform: uppercase;
        }
        .photo-grid-2 {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 8px;
            flex: 1;
            min-height: 0;
        }
        .photo-slot {
            background: #ede5d5;
            border-radius: 8px;
            overflow: hidden;
            width: 100%; height: 100%;
            box-shadow: 0 2px 10px rgba(0,0,0,0.08), inset 0 0 0 1px rgba(184,146,46,0.20);
        }
        .photo-slot img { width: 100%; height: 100%; object-fit: cover; display: block; }

        .photo-slot-large {
            background: #ede5d5;
            border-radius: 8px;
            overflow: hidden;
            flex: 1; min-height: 0;
            box-shadow: 0 2px 10px rgba(0,0,0,0.08), inset 0 0 0 1px rgba(184,146,46,0.20);
        }
        .photo-slot-large img { width: 100%; height: 100%; object-fit: cover; display: block; }

        .photo-caption {
            font-family: 'Cormorant Garamond', serif;
            font-style: italic;
            font-size: 11px;
            color: rgba(130, 100, 55, 0.68);
            text-align: center;
            letter-spacing: 0.3px;
        }
        .photo-deco { text-align: center; font-size: 13px; color: rgba(184,146,46,0.50); line-height: 1; }

        /* ===== 프로포즈 페이지 ===== */
        .propose-front {
            background: linear-gradient(155deg, #f6ebda 0%, #eddfc3 50%, #e5d3ad 100%);
            /* position: relative 제거 — page-face의 absolute 유지 */
            transition: background 100s linear;
        }

        #proposeMain {
            position: absolute;
            inset: 0;
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: space-evenly;
            text-align: center;
            padding: 32px 32px 36px;
        }

        .propose-icon {
            font-size: 50px;
            animation: floatIcon 2.5s ease-in-out infinite;
        }
        @keyframes floatIcon {
            0%, 100% { transform: translateY(0); }
            50%       { transform: translateY(-10px); }
        }

        .propose-title {
            font-size: 26px;
            color: #7a4f2e;
            font-weight: 600;
            line-height: 1.4;
        }

        .propose-rule {
            width: 56px; height: 1px;
            background: linear-gradient(to right, transparent, rgba(184,146,46,0.58), transparent);
            margin: 0 auto 16px;
        }

        .propose-msg {
            font-family: 'Cormorant Garamond', 'Noto Serif KR', serif;
            font-size: 15px;
            color: #8b6040;
            line-height: 2.2;
            font-weight: 300;
        }

        .propose-btns { display: flex; gap: 16px; align-items: center; justify-content: center; }

        .btn-yes {
            padding: 13px 32px;
            background: linear-gradient(135deg, #c49668, #9a7040);
            border: none;
            border-radius: 50px;
            color: rgba(255,255,255,0.94);
            font-size: 15px;
            letter-spacing: 0.5px;
            font-family: 'Noto Serif KR', serif;
            cursor: pointer;
            box-shadow: 0 5px 20px rgba(154,112,64,0.40), inset 0 1px 0 rgba(255,255,255,0.16);
            transition: transform 0.25s cubic-bezier(0.34,1.56,0.64,1), box-shadow 0.25s;
        }
        .btn-yes:hover {
            transform: scale(1.07);
            box-shadow: 0 9px 28px rgba(154,112,64,0.58);
        }

        .btn-no {
            padding: 11px 22px;
            background: transparent;
            border: 1px solid rgba(184,146,46,0.42);
            border-radius: 50px;
            color: rgba(155,115,58,0.78);
            font-size: 13px;
            font-family: 'Noto Serif KR', serif;
            cursor: pointer;
            white-space: nowrap;
        }

        /* YES 응답 */
        .yes-response {
            display: none;
            position: absolute;
            inset: 0;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            gap: 20px;
            text-align: center;
        }
        .totoro-img {
            width: 138px; height: 138px;
            object-fit: cover;
            border-radius: 50%;
            border: 3px solid rgba(184,146,46,0.55);
            box-shadow: 0 4px 22px rgba(0,0,0,0.14);
            animation: popIn 0.6s cubic-bezier(0.175,0.885,0.32,1.275);
        }
        @keyframes popIn {
            0%   { transform: scale(0) rotate(-12deg); opacity: 0; }
            100% { transform: scale(1)  rotate(0deg);  opacity: 1; }
        }
        .yes-text { font-size: 22px; color: #f5e8c8; font-weight: 600; }
        .yes-sub {
            font-family: 'Cormorant Garamond', serif;
            font-style: italic;
            font-size: 15px;
            color: #d4c8a0;
            line-height: 1.9;
        }
    </style>
</head>
<body>

<div id="yesOverlay"></div>
<div class="particles" id="particles"></div>

<button class="nav-btn prev" id="prevBtn" onclick="goPrev()" disabled>&#8249;</button>
<button class="nav-btn next" id="nextBtn" onclick="goNext()">&#8250;</button>
<div class="page-dots" id="pageDots"></div>

<div class="book-scene">
  <div class="book-container" id="bookContainer">

    <!-- 1장: 커버 -->
    <div class="page" id="page-0">
      <div class="page-face p1-front">
        <div class="invite-frame"></div>
        <div class="p1-top">
          <div class="p1-heart">🎫</div>
          <div class="p1-title">For You</div>
          <div class="p1-subtitle">A Private Invitation</div>
          <div class="p1-rule"><span class="p1-rule-gem">✦</span></div>
          <div class="p1-quote">
            지금 이 순간도,<br>
            당신과 함께여서 행복합니다
          </div>
        </div>
        <div class="p1-form">
          <div>
            <label class="p1-label">이름</label>
            <input class="p1-input" type="text" placeholder="당신의 이름을 입력해주세요">
          </div>
          <div>
            <label class="p1-label">비밀번호</label>
            <input class="p1-input" type="password" placeholder="••••••••">
          </div>
          <button class="p1-btn" onclick="goNext()">초대장 열기</button>
        </div>
        <div class="p1-hint">✦ &nbsp; 펼쳐서 확인하세요 &nbsp; ✦</div>
      </div>
      <div class="page-face page-back">
        <div class="page-back-inner">🌸</div>
      </div>
    </div>

    <!-- 2장: 사진 -->
    <div class="page" id="page-1">
      <div class="page-face photo-page">
        <div class="photo-page-label">✦ &nbsp; Our Moments &nbsp; ✦</div>
        <div class="photo-grid-2" style="flex:1;min-height:0;">
          <div class="photo-slot"><img src="/img_bom/1.jpg" alt=""></div>
          <div class="photo-slot"><img src="/img_bom/2.jpg" alt=""></div>
        </div>
        <div class="photo-caption">우리가 함께한 소중한 순간들</div>
        <div class="photo-grid-2" style="flex:1;min-height:0;">
          <div class="photo-slot"><img src="/img_bom/3.jpg" alt=""></div>
          <div class="photo-slot"><img src="/img_bom/4.jpg" alt=""></div>
        </div>
        <div class="photo-deco">❧</div>
      </div>
      <div class="page-face page-back">
        <div class="page-back-inner">🌸</div>
      </div>
    </div>

    <!-- 3장: 사진 -->
    <div class="page" id="page-2">
      <div class="page-face photo-page">
        <div class="photo-page-label">✦ &nbsp; More Memories &nbsp; ✦</div>
        <div class="photo-slot-large"><img src="/img_bom/5.jpg" alt=""></div>
        <div class="photo-grid-2" style="height:38%;min-height:0;">
          <div class="photo-slot"><img src="/img_bom/6.jpg" alt=""></div>
          <div class="photo-slot"><img src="/img_bom/7.jpg" alt=""></div>
        </div>
        <div class="photo-deco">❧</div>
      </div>
      <div class="page-face page-back">
        <div class="page-back-inner">🌸</div>
      </div>
    </div>

    <!-- 4장: 프로포즈 -->
    <div class="page" id="page-3">
      <div class="page-face propose-front" id="proposeFront">
        <div class="invite-frame"></div>
        <div id="proposeMain">
          <div class="propose-icon">🗺️</div>
          <div class="propose-title">나와 함께갈래?</div>
          <div class="propose-rule"></div>
          <div class="propose-msg">
            지금 이 시간도, 당신과 있어서<br>
            행복해<br>
            앞으로도 같이<br>
            행복하자<br><br>
            같이 행복할래?
          </div>
          <div class="propose-btns">
            <button class="btn-yes" onclick="onYes()">응, 당연하지! 💛</button>
            <button class="btn-no" id="noBtn">싫어요ㅠ</button>
          </div>
        </div>
        <div class="yes-response" id="yesResponse">
          <img src="/img_bom/totoro.jpg" class="totoro-img" alt="">
          <div class="yes-text">😭💕</div>
          <div class="yes-sub">이제 옆을 봐!</div>
        </div>
      </div>
      <div class="page-face page-back">
        <div class="page-back-inner">🌸</div>
      </div>
    </div>

  </div>
</div>

<script>
(function () {
    // ===== 파티클 =====
    var pc = document.getElementById('particles');
    for (var i = 0; i < 20; i++) {
        var p  = document.createElement('div');
        p.className = 'particle';
        var w  = Math.random() * 10 + 4;
        p.style.cssText = [
            'left:'               + (Math.random() * 100) + 'vw',
            'width:'              + w + 'px',
            'height:'             + (w * (0.45 + Math.random() * 0.5)) + 'px',
            'background:rgba(184,146,46,' + (Math.random() * 0.22 + 0.07) + ')',
            'animation-duration:' + (Math.random() * 13 + 10) + 's',
            'animation-delay:'    + (Math.random() * 12) + 's'
        ].join(';');
        pc.appendChild(p);
    }

    // ===== 페이지 플립 =====
    var TOTAL   = 4;
    var current = 0;
    var busy    = false;
    var pages   = [];

    for (var k = 0; k < TOTAL; k++) {
        var pg = document.getElementById('page-' + k);
        pg.style.zIndex = String(TOTAL - k);
        pages.push(pg);
    }

    var prevBtn = document.getElementById('prevBtn');
    var nextBtn = document.getElementById('nextBtn');
    var dotsEl  = document.getElementById('pageDots');

    for (var d = 0; d < TOTAL; d++) {
        var dot = document.createElement('div');
        dot.className = 'dot' + (d === 0 ? ' active' : '');
        dotsEl.appendChild(dot);
    }
    var dots = dotsEl.querySelectorAll('.dot');

    function updateUI() {
        prevBtn.disabled = (current === 0);
        nextBtn.disabled = (current === TOTAL - 1);
        dots.forEach(function (dt, i) {
            dt.className = 'dot' + (i === current ? ' active' : '');
        });
        // No 버튼은 마우스 근접 시에만 활성화 (여기서 호출 X)
    }

    window.goNext = function () {
        if (current >= TOTAL - 1 || busy) return;
        busy = true;
        var pg = pages[current];
        pg.style.transition = 'transform 0.85s cubic-bezier(0.645,0.045,0.355,1)';
        pg.style.transform   = 'rotateY(-180deg)';
        setTimeout(function () { pg.style.zIndex = '0'; }, 425);
        setTimeout(function () { current++; updateUI(); busy = false; }, 850);
    };

    window.goPrev = function () {
        if (current <= 0 || busy) return;
        busy = true;
        current--;
        var pg = pages[current];
        pg.style.zIndex = String(TOTAL - current);
        setTimeout(function () {
            pg.style.transition = 'transform 0.85s cubic-bezier(0.645,0.045,0.355,1)';
            pg.style.transform   = 'rotateY(0deg)';
        }, 16);
        setTimeout(function () { updateUI(); busy = false; }, 870);
    };

    document.addEventListener('keydown', function (e) {
        if (e.key === 'ArrowRight' || e.key === 'ArrowDown') window.goNext();
        if (e.key === 'ArrowLeft'  || e.key === 'ArrowUp')   window.goPrev();
    });

    var touchX = 0;
    document.addEventListener('touchstart', function (e) { touchX = e.touches[0].clientX; }, { passive: true });
    document.addEventListener('touchend', function (e) {
        var diff = touchX - e.changedTouches[0].clientX;
        if (Math.abs(diff) > 50) diff > 0 ? window.goNext() : window.goPrev();
    });

    updateUI();

    // ===== No 버튼: 물리 충돌 + 벽 튕기기 =====
    var noBtn = document.getElementById('noBtn');
    var nb    = { x: 0, y: 0, vx: 0, vy: 0, live: false };

    function noBtnActivate() {
        if (nb.live || !noBtn || noBtn.style.display === 'none') return;
        var r    = noBtn.getBoundingClientRect();
        nb.x     = r.left;
        nb.y     = r.top;
        var ang  = Math.random() * Math.PI * 2;
        nb.vx    = Math.cos(ang) * 2.8;
        nb.vy    = Math.sin(ang) * 2.8;
        noBtn.style.position   = 'fixed';
        noBtn.style.transition = 'none';
        noBtn.style.margin     = '0';
        noBtn.style.zIndex     = '9998';
        noBtn.style.left       = nb.x + 'px';
        noBtn.style.top        = nb.y + 'px';
        nb.live = true;
        requestAnimationFrame(nbTick);
    }

    function nbTick() {
        if (!nb.live || noBtn.style.display === 'none') return;

        var pad  = 8;
        var bw   = noBtn.offsetWidth;
        var bh   = noBtn.offsetHeight;
        var maxX = window.innerWidth  - bw - pad;
        var maxY = window.innerHeight - bh - pad;

        nb.x += nb.vx;
        nb.y += nb.vy;

        // 벽 충돌 → 반사
        if (nb.x <= pad)  { nb.x = pad;  nb.vx =  Math.abs(nb.vx); }
        if (nb.x >= maxX) { nb.x = maxX; nb.vx = -Math.abs(nb.vx); }
        if (nb.y <= pad)  { nb.y = pad;  nb.vy =  Math.abs(nb.vy); }
        if (nb.y >= maxY) { nb.y = maxY; nb.vy = -Math.abs(nb.vy); }

        // 속도 유지 (너무 느려지면 다시 가속)
        var spd = Math.sqrt(nb.vx * nb.vx + nb.vy * nb.vy);
        if (spd < 1.5) { var a = Math.random() * Math.PI * 2; nb.vx = Math.cos(a) * 2.5; nb.vy = Math.sin(a) * 2.5; }
        if (spd > 16)  { nb.vx = nb.vx / spd * 16; nb.vy = nb.vy / spd * 16; }

        noBtn.style.left = nb.x + 'px';
        noBtn.style.top  = nb.y + 'px';
        requestAnimationFrame(nbTick);
    }

    // 마우스 근접 시: 미활성이면 활성화, 활성이면 반발력 적용
    document.addEventListener('mousemove', function (e) {
        if (current !== TOTAL - 1 || noBtn.style.display === 'none') return;

        if (!nb.live) {
            // 버튼이 아직 정지 상태 — 현재 렌더 위치로 거리 계산
            var r0   = noBtn.getBoundingClientRect();
            var cx0  = r0.left + r0.width  / 2;
            var cy0  = r0.top  + r0.height / 2;
            var d0   = Math.sqrt(Math.pow(e.clientX - cx0, 2) + Math.pow(e.clientY - cy0, 2));
            if (d0 < 120) noBtnActivate();   // 120px 이내에 들어올 때만 시작
            return;
        }

        // 이미 활성 — 반발력
        var cx  = nb.x + noBtn.offsetWidth  / 2;
        var cy  = nb.y + noBtn.offsetHeight / 2;
        var dx  = cx - e.clientX;
        var dy  = cy - e.clientY;
        var dist = Math.sqrt(dx * dx + dy * dy);
        if (dist < 150 && dist > 0) {
            var f = (150 - dist) / 150 * 7;
            nb.vx += dx / dist * f;
            nb.vy += dy / dist * f;
        }
    });

    noBtn.addEventListener('touchstart', function (e) { e.preventDefault(); }, { passive: false });
    noBtn.addEventListener('click',       function (e) { e.preventDefault(); });

    // ===== YES =====
    window.onYes = function () {
        nb.live = false;
        if (noBtn) noBtn.style.display = 'none';

        document.getElementById('proposeMain').style.display = 'none';
        document.getElementById('yesResponse').style.display = 'flex';

        // 100초에 걸쳐 서서히 초록 숲 배경으로
        document.getElementById('yesOverlay').style.opacity = '1';
        document.getElementById('proposeFront').style.background =
            'linear-gradient(155deg, #1e3d28 0%, #274e36 50%, #204030 100%)';

        launchHearts();
    };

    function launchHearts() {
        var sym = ['💕','💖','💗','💓','💝','🌿','✨','🌸','🍃','💚'];
        for (var h = 0; h < 26; h++) {
            (function (idx) {
                setTimeout(function () {
                    var el  = document.createElement('div');
                    var sz  = Math.random() * 18 + 13;
                    var dur = 1.8 + Math.random() * 1.4;
                    el.innerHTML = sym[Math.floor(Math.random() * sym.length)];
                    el.style.cssText = [
                        'position:fixed',
                        'font-size:' + sz + 'px',
                        'left:' + Math.random() * 100 + 'vw',
                        'bottom:0',
                        'z-index:9999',
                        'pointer-events:none',
                        'animation:heartFly ' + dur + 's ease-out forwards'
                    ].join(';');
                    document.body.appendChild(el);
                    setTimeout(function () { el.remove(); }, dur * 1000 + 100);
                }, idx * 75);
            })(h);
        }
    }

    var hfStyle = document.createElement('style');
    hfStyle.textContent = '@keyframes heartFly{0%{transform:translateY(0) scale(1) rotate(0deg);opacity:1}100%{transform:translateY(-100vh) scale(0.4) rotate(380deg);opacity:0}}';
    document.head.appendChild(hfStyle);
})();
</script>
</body>
</html>
