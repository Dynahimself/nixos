import * as zebar from './vendor/zebar.bundle.js';

const WS_ICONS = {
  '1': '',
  '2': '󰈹',
  '3': '',
  '4': '󰑴',
  '5': '󰙯',
  '6': '󰈙',
  '7': '󰒍',
  '8': '󰚩',
  '9': '󰊴',
  '10': '󰇘',
};

const FLEET_API = 'http://100.68.54.112:8210/api/status';
const CACHE_KEY = 'dyna-mocha-fleet-cache-v1';

const el = (id) => document.getElementById(id);

const providers = zebar.createProviderGroup({
  glazewm: { type: 'glazewm' },
  cpu: { type: 'cpu', refreshInterval: 2500 },
  memory: { type: 'memory', refreshInterval: 5000 },
  battery: { type: 'battery', refreshInterval: 15000 },
  network: { type: 'network', refreshInterval: 5000 },
  audio: { type: 'audio' },
  media: { type: 'media' },
  date: { type: 'date', formatting: 'EEE d MMM · HH:mm', refreshInterval: 1000 },
});

function openUrl(url) {
  zebar.shellExec('cmd', ['/c', 'start', '', url]).catch(() => {});
}

let showSeconds = false;
let pomoState = 'idle'; // idle | running | paused | done
let pomoRemaining = 25 * 60;
let pomoInterval = null;

function formatClock() {
  if (pomoState === 'running' || pomoState === 'paused') {
    const mm = String(Math.floor(pomoRemaining / 60)).padStart(2, '0');
    const ss = String(pomoRemaining % 60).padStart(2, '0');
    const icon = pomoState === 'running' ? '󱎫' : '';
    el('clock-icon').textContent = icon;
    el('clock-text').textContent = `${mm}:${ss}`;
    el('clock-pill').classList.toggle('pomo-run', pomoState === 'running');
    el('clock-pill').classList.remove('pomo-done');
    return;
  }
  if (pomoState === 'done') {
    el('clock-icon').textContent = '✓';
    el('clock-text').textContent = '25:00 done';
    el('clock-pill').classList.remove('pomo-run');
    el('clock-pill').classList.add('pomo-done');
    return;
  }
  el('clock-icon').textContent = '󰥔';
  el('clock-pill').classList.remove('pomo-run', 'pomo-done');
  const now = new Date();
  if (showSeconds) {
    el('clock-text').textContent = now.toLocaleTimeString('en-GB', {
      hour: '2-digit',
      minute: '2-digit',
      second: '2-digit',
    });
  } else {
    const d = providers.outputMap.date?.formatted;
    if (d) {
      el('clock-text').textContent = d;
    } else {
      el('clock-text').textContent = now.toLocaleTimeString('en-GB', {
        hour: '2-digit',
        minute: '2-digit',
      });
    }
  }
}

function togglePomo() {
  if (pomoState === 'done') {
    resetPomo();
    return;
  }
  if (pomoState === 'idle' || pomoState === 'paused') {
    if (pomoState === 'idle') pomoRemaining = 25 * 60;
    pomoState = 'running';
    clearInterval(pomoInterval);
    pomoInterval = setInterval(() => {
      if (pomoState !== 'running') return;
      pomoRemaining -= 1;
      if (pomoRemaining <= 0) {
        pomoRemaining = 0;
        pomoState = 'done';
        clearInterval(pomoInterval);
      }
      formatClock();
    }, 1000);
  } else if (pomoState === 'running') {
    pomoState = 'paused';
  }
  formatClock();
}

function resetPomo() {
  clearInterval(pomoInterval);
  pomoState = 'idle';
  pomoRemaining = 25 * 60;
  formatClock();
}

el('clock-pill').addEventListener('click', () => {
  if (pomoState === 'done') {
    resetPomo();
  } else {
    showSeconds = !showSeconds;
    formatClock();
  }
});

el('clock-pill').addEventListener('contextmenu', (e) => {
  e.preventDefault();
  togglePomo();
});

el('clock-pill').addEventListener('auxclick', (e) => {
  if (e.button === 1) {
    e.preventDefault();
    resetPomo();
  }
});

function getAppIcon(proc = '', title = '') {
  const p = proc.toLowerCase();
  const t = title.toLowerCase();
  if (p.includes('windowsterminal') || p.includes('wt') || p.includes('powershell')) return '';
  if (p.includes('zen') || p.includes('firefox')) return '󰈹';
  if (p.includes('code')) return '󰨞';
  if (p.includes('devenv')) return '';
  if (p.includes('discord')) return '󰙯';
  if (p.includes('spotify')) return '';
  if (p.includes('explorer')) return '';
  if (p.includes('virtualbox')) return '󰢹';
  if (p.includes('steam')) return '';
  if (t.includes('nvim') || p.includes('nvim')) return '';
  return '󰣆';
}

function cleanWindowTitle(proc = '', title = '') {
  if (!title) return proc;
  return title
    .replace(/\s+[—-]\s+Zen Browser$/i, '')
    .replace(/\s+-\s+Visual Studio Code$/i, '')
    .replace(/\s+-\s+Discord$/i, '')
    .trim();
}

function renderGlaze(g) {
  if (!g) return;

  const wsWrap = el('workspaces');
  wsWrap.innerHTML = '';
  for (const ws of g.currentWorkspaces || []) {
    const btn = document.createElement('button');
    btn.className = 'ws-btn' + (ws.isDisplayed ? ' displayed' : '') + (ws.hasFocus ? ' focused' : '');
    const ico = WS_ICONS[ws.name] || '';
    btn.textContent = ico ? `${ws.name} ${ico}` : ws.name;
    btn.title = `Workspace ${ws.name}`;
    btn.addEventListener('click', () => g.runCommand(`focus --workspace ${ws.name}`));
    wsWrap.appendChild(btn);
  }

  const tileBtn = el('btn-tiling');
  tileBtn.textContent = g.tilingDirection === 'horizontal' ? '󰯌' : '󰯍';
  tileBtn.title = `Tiling: ${g.tilingDirection} (click to flip)`;
  tileBtn.onclick = () => g.runCommand('toggle-tiling-direction');

  const modePill = el('mode-pill');
  if (g.isPaused) {
    modePill.className = 'island mode-pill paused';
    modePill.textContent = '󰏤 PAUSED';
    modePill.title = 'GlazeWM paused — click or F24+Shift+P to resume';
    modePill.onclick = () => g.runCommand('wm-toggle-pause');
  } else if (g.bindingModes && g.bindingModes.length > 0) {
    const bm = g.bindingModes[0];
    modePill.className = 'island mode-pill resize';
    modePill.textContent = `󰌌 ${(bm.displayName || bm.name).toUpperCase()}`;
    modePill.title = 'Click or Esc to exit binding mode';
    modePill.onclick = () => g.runCommand(`wm-disable-binding-mode --name ${bm.name}`);
  } else {
    modePill.className = 'island mode-pill hidden';
  }

  const fc = g.focusedContainer;
  const winPill = el('win-pill');
  if (fc && fc.type === 'window' && (fc.title || fc.processName)) {
    el('win-icon').textContent = getAppIcon(fc.processName, fc.title);
    el('win-title').textContent = cleanWindowTitle(fc.processName, fc.title);
    winPill.title = `${fc.processName || ''}: ${fc.title || ''}`;
    winPill.classList.remove('hidden');
  } else {
    winPill.classList.add('hidden');
  }
}

function renderMedia(m) {
  const pill = el('media-pill');
  const sess = m?.currentSession;
  if (!sess || (!sess.title && !sess.artist)) {
    pill.classList.add('hidden');
    return;
  }
  pill.classList.remove('hidden');
  const playing = !!sess.isPlaying;
  pill.classList.toggle('paused', !playing);
  el('media-icon').textContent = playing ? '󰎆' : '';
  const label = sess.artist ? `${sess.artist} — ${sess.title}` : sess.title;
  el('media-text').textContent = label.length > 34 ? label.slice(0, 33) + '…' : label;
  pill.title = `${label}\nLeft: Play/Pause · Right: Next · Middle: Prev`;
  pill.onclick = () => m.togglePlayPause?.();
  pill.oncontextmenu = (e) => {
    e.preventDefault();
    m.next?.();
  };
  pill.onauxclick = (e) => {
    if (e.button === 1) {
      e.preventDefault();
      m.previous?.();
    }
  };
}

function renderTelemetry(out) {
  if (out.cpu) {
    const pct = Math.round(out.cpu.usage);
    const val = el('cpu-val');
    val.textContent = `${pct}%`;
    val.className = pct >= 85 ? 'crit-text' : pct >= 65 ? 'warn-text' : '';
  }

  if (out.memory) {
    const pct = Math.round(out.memory.usage);
    const val = el('mem-val');
    val.textContent = `${pct}%`;
    val.className = pct >= 88 ? 'crit-text' : pct >= 75 ? 'warn-text' : '';
  }

  if (out.audio?.defaultPlaybackDevice) {
    const dev = out.audio.defaultPlaybackDevice;
    const muted = !!dev.isMuted;
    const vol = Math.round(dev.volume ?? 0);
    const ico = el('audio-ico');
    const val = el('audio-val');
    ico.textContent = muted || vol === 0 ? '󰝟' : vol < 40 ? '󰕿' : vol < 75 ? '󰖀' : '󰕾';
    ico.className = 'm-ico audio-ico' + (muted ? ' muted-text' : '');
    val.textContent = muted ? 'MUTE' : `${vol}%`;
    val.className = muted ? 'muted-text' : '';

    const btn = el('audio-item');
    btn.title = `${dev.name || 'Audio'} (${vol}%)\nClick: Mute · Scroll: ±4%`;
    btn.onclick = () => out.audio.setMute?.(!muted);
    btn.onwheel = (e) => {
      e.preventDefault();
      const next = Math.max(0, Math.min(100, vol + (e.deltaY < 0 ? 4 : -4)));
      out.audio.setVolume?.(next);
    };
  }

  if (out.network) {
    const iface = out.network.defaultInterface;
    const gw = out.network.defaultGateway;
    const ico = el('net-ico');
    const val = el('net-val');
    if (iface?.type === 'ethernet') {
      ico.textContent = '󰈀';
      val.textContent = 'ETH';
    } else if (iface?.type === 'wifi') {
      const s = gw?.signalStrength ?? 0;
      ico.textContent = s >= 80 ? '󰤨' : s >= 60 ? '󰤥' : s >= 40 ? '󰤢' : s >= 20 ? '󰤟' : '󰤯';
      const ssid = gw?.ssid || 'Wi-Fi';
      val.textContent = ssid.length > 12 ? ssid.slice(0, 11) + '…' : ssid;
      el('net-item').title = `Wi-Fi: ${ssid} (${s}%)`;
    } else if (iface?.type === 'proprietary_virtual') {
      ico.textContent = '󰦝';
      val.textContent = 'VPN';
    } else {
      ico.textContent = '󰤭';
      val.textContent = 'OFF';
    }
  }

  if (out.battery) {
    el('bat-sep').classList.remove('hidden');
    el('bat-item').classList.remove('hidden');
    const pct = Math.round(out.battery.chargePercent ?? 0);
    const chg = !!out.battery.isCharging;
    const ico = el('bat-ico');
    const val = el('bat-val');
    if (chg) {
      ico.textContent = '󰂄';
    } else if (pct >= 90) {
      ico.textContent = '󰁹';
    } else if (pct >= 70) {
      ico.textContent = '󰂀';
    } else if (pct >= 45) {
      ico.textContent = '󰁾';
    } else if (pct >= 20) {
      ico.textContent = '󰁼';
    } else {
      ico.textContent = '󰂃';
    }
    val.textContent = `${pct}%`;
    const cls = !chg && pct <= 15 ? 'crit-text' : !chg && pct <= 30 ? 'warn-text' : chg ? 'good-text' : '';
    val.className = cls;
    ico.className = 'm-ico bat-ico ' + cls;
    el('bat-item').title = `Battery: ${pct}%${chg ? ' (Charging)' : ''}`;
  }
}

function renderFleetAndHub(data, isLive) {
  const fleetPill = el('fleet-pill');
  const dotsWrap = el('fleet-dots');
  const fleetText = el('fleet-text');
  const hubPill = el('cshub-pill');
  const hubText = el('cshub-text');

  if (!data) {
    dotsWrap.innerHTML = '<span class="dot warn"></span>';
    fleetText.textContent = 'Offline';
    fleetPill.title = 'Tailscale / Pi unreachable — click to open Fleet Startpage';
    hubPill.className = 'island pill cshub-pill offline';
    hubText.textContent = 'Offline';
    return;
  }

  const nodes = data.nodes || [];
  const wanted = [
    { key: 'Raspberry', short: 'Pi' },
    { key: 'TerraMaster', short: 'NAS' },
    { key: 'Desktop', short: 'Desk' },
  ];
  const tipLines = [];
  dotsWrap.innerHTML = '';
  for (const w of wanted) {
    const found = nodes.find((n) => (n.name || '').startsWith(w.key));
    const up = isLive && !!found?.online;
    const span = document.createElement('span');
    span.className = 'dot ' + (up ? 'up' : 'down');
    dotsWrap.appendChild(span);
    tipLines.push(`${w.short}: ${up ? 'UP' : 'DOWN'}`);
  }
  fleetText.textContent = isLive ? (data.pi_temp || 'Pi') : 'Cached';
  const clipLine = data.clip?.preview ? `\nClip [${data.clip.source || '?'}]: ${data.clip.preview}` : '';
  fleetPill.title = `${tipLines.join(' · ')}\nPi RAM: ${data.pi_mem || '?'} · Backup: ${data.backup || '?'}${clipLine}\nClick to open Fleet Startpage`;

  const hub = data.cshub;
  if (!hub) {
    hubPill.className = 'island pill cshub-pill offline';
    hubText.textContent = 'Hub';
    return;
  }

  const today = new Date();
  today.setHours(0, 0, 0, 0);
  const items = (hub.open_items || []).map((it) => {
    let days = null;
    if (it.due_date) {
      const d = new Date(it.due_date.slice(0, 10) + 'T00:00:00');
      if (!Number.isNaN(d.getTime())) {
        days = Math.round((d - today) / 86400000);
      }
    }
    return { ...it, days };
  });

  const overdue = items.filter((i) => i.days !== null && i.days < 0);
  const exams = items.filter((i) => i.kind === 'exam' && i.days !== null && i.days >= 0).sort((a, b) => a.days - b.days);
  const soon = items.filter((i) => i.days !== null && i.days >= 0).sort((a, b) => a.days - b.days);
  const dueTerms = Number(hub.due_count || 0);

  let cls = 'island pill cshub-pill';
  let text = 'Clear';

  if (overdue.length > 0) {
    cls += ' urgent';
    text = `${overdue.length} LATE · ${items.length} open`;
  } else if (exams.length > 0 && exams[0].days <= 7) {
    const d = exams[0].days;
    cls += d <= 2 ? ' urgent' : ' soon';
    const when = d === 0 ? 'TODAY' : d === 1 ? 'TMR' : `${d}d`;
    text = `${when}: ${(exams[0].title || 'Exam').slice(0, 14)}`;
  } else if (soon.length > 0 && soon[0].days <= 3) {
    const d = soon[0].days;
    cls += d === 0 ? ' urgent' : ' soon';
    const when = d === 0 ? 'TODAY' : d === 1 ? 'TMR' : `${d}d`;
    text = `${when}: ${(soon[0].title || 'Due').slice(0, 14)}`;
  } else if (items.length > 0 || dueTerms > 0) {
    const parts = [];
    if (items.length > 0) parts.push(`${items.length} todo`);
    if (dueTerms > 0) parts.push(`${dueTerms} due`);
    text = parts.join(' · ');
  } else {
    cls += ' clear';
    text = 'Clear';
  }
  if (!isLive) text += ' (cache)';

  hubPill.className = cls;
  hubText.textContent = text;
  const hTip = [
    `CS Hub (${isLive ? 'online' : 'cache'})`,
    `Streak: ${hub.streak || 0}d · Today: ${hub.today_minutes || 0}m · Due cards: ${dueTerms}`,
  ];
  for (const it of items.slice(0, 5)) {
    const w = it.days === null ? '' : it.days < 0 ? ` (${Math.abs(it.days)}d late)` : it.days === 0 ? ' (TODAY)' : ` (in ${it.days}d)`;
    hTip.push(`• [${(it.kind || 'item').toUpperCase()}] ${it.title}${w}`);
  }
  hubPill.title = hTip.join('\n');
}

async function pollFleet() {
  const ctrl = new AbortController();
  const timer = setTimeout(() => ctrl.abort(), 2500);
  try {
    const res = await fetch(FLEET_API, { signal: ctrl.signal, cache: 'no-store' });
    clearTimeout(timer);
    if (!res.ok) throw new Error(`HTTP ${res.status}`);
    const data = await res.json();
    try {
      localStorage.setItem(CACHE_KEY, JSON.stringify(data));
    } catch {}
    renderFleetAndHub(data, true);
  } catch {
    clearTimeout(timer);
    let cached = null;
    try {
      cached = JSON.parse(localStorage.getItem(CACHE_KEY) || 'null');
    } catch {}
    renderFleetAndHub(cached, false);
  }
}

el('btn-home').addEventListener('click', () => openUrl('http://100.68.54.112:8210'));
el('fleet-pill').addEventListener('click', () => openUrl('http://100.68.54.112:8210'));
el('cshub-pill').addEventListener('click', () => openUrl('http://100.68.54.112:8200'));

providers.onOutput(() => {
  const out = providers.outputMap;
  renderGlaze(out.glazewm);
  renderMedia(out.media);
  renderTelemetry(out);
  formatClock();
});

formatClock();
pollFleet();
setInterval(pollFleet, 30000);
