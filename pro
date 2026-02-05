// --- FISHING EMPIRE v5.0 MASTER TEST ---
var fishes = [];
var catchCount = 0;
var gold = 50;
var accountGold = 0;
var lastCatchRarity = "None";

// Systems
var isOnline = true;
var ping = 24;
var serverLuck = 1.0;
var restartTimer = -1;
var isSyncing = false;
var serverLogs = ["Coral Bay v5.0 Online.", "Cloud Sync Active."];
var leaderboard = [];

// Mini-game & Admin UI
var inMiniGame = false, targetFish = null, captureProgress = 0;
var garyX = 0, garyDir = 2, reelX = 0;
var adminInput, osc, forceMythic = false;

// Cinematic
var inCutscene = false, cutsceneTimer = 0;

function setup() {
  createCanvas(850, 500);
  adminInput = createInput('').position(20, 145).size(100);
  createButton('EXE').position(130, 145).mousePressed(handleAdmin);
  
  osc = new p5.Oscillator('triangle');
  osc.amp(0); osc.start();
  
  for (var i = 0; i < 12; i++) fishes.push(new Fish());
  updateServerLuck();
}

function handleAdmin() {
  let val = adminInput.value().toLowerCase();
  let parts = val.split(' ');
  if (parts[0] === 'luck') { serverLuck = parseFloat(parts[1]); addLog("ADMIN: Luck " + serverLuck + "x"); }
  if (parts[0] === 'gold') { gold += parseInt(parts[1]); saveToCloud(); addLog("ADMIN: +Gold"); }
  if (parts[0] === 'spawn') { forceMythic = true; addLog("ADMIN: Mythic Incoming"); }
  if (parts[0] === 'restart') { restartTimer = 10 * 60; addLog("!!! RESTART IN 10s !!!"); }
  adminInput.value('');
}

class Fish {
  constructor() { this.reset(); }
  reset() {
    this.x = random(-800, -100); this.y = random(220, height - 50);
    this.xSpeed = random(1, 3); this.ySpeed = random(-0.5, 0.5);
    let r = random(1000000);
    if (forceMythic) {
      this.rarity = random() > 0.5 ? "QUANTUM SINGULARITY" : "ORIGIN SOUL";
      this.col = color(0, 255, 255); this.val = 500000; this.difficulty = 8; forceMythic = false;
    } else if (r < 100 * serverLuck) {
      this.rarity = "SECRET"; this.col = color(255, 0, 255); this.val = 25000; this.difficulty = 5;
    } else {
      this.rarity = "COMMON"; this.col = color(255); this.val = 10; this.difficulty = 1.5;
    }
    this.pX = -100; this.pY = -100;
  }
  update() {
    if (inMiniGame || inCutscene || !isOnline) return;
    this.x += this.xSpeed; this.y += this.ySpeed;
    if (this.y < 210 || this.y > height - 20) this.ySpeed *= -1;
    if (this.x > 620) this.reset();
  }
  show() {
    tint(this.col); 
    rect(this.x, this.y, 40, 20, 5); // Simple fish shape for testing
    fill(255); textSize(10); text(this.rarity[0], this.x+5, this.y+15);
    noTint();
  }
}

function draw() {
  if (inCutscene) { runCutscene(); return; }
  background(25);
  
  // Internet & Restart Logic
  if (frameCount % 120 == 0) { isOnline = random(100) > 3; ping = floor(random(20, 80)); }
  if (restartTimer > 0) { restartTimer--; if (restartTimer <= 0) performRestart(); }

  drawHUD();
  
  if (!isOnline) {
    fill(255, 0, 0, 100); rect(0, 200, 650, 300);
    fill(255); textAlign(CENTER); text("OFFLINE: RECONNECTING...", 325, 350); textAlign(LEFT);
  } else {
    fill(0, 80, 150); rect(0, 200, 650, 300); // Water
    inMiniGame ? runMiniGame() : runMainGame();
  }
}

function drawHUD() {
  fill(40); rect(0, 0, width, 200);
  // Status
  fill(isOnline ? color(0, 255, 0) : color(255, 0, 0)); ellipse(30, 30, 10, 10);
  fill(255); textSize(14); text(isOnline ? "ONLINE ("+ping+"ms)" : "OFFLINE", 50, 35);
  if (isSyncing) fill(0, 255, 255); text(isSyncing ? "☁️ SYNCING..." : "", 180, 35);
  
  // Stats
  fill(255); textSize(18); text("💰 Session: " + gold + "g", 20, 70);
  fill(255, 215, 0); text("💎 Account: " + accountGold + "g", 20, 100);
  
  // Logs & Leaderboard
  fill(15); rect(400, 10, 430, 180, 5);
  fill(0, 255, 0); textSize(11);
  for(let i=0; i<serverLogs.length; i++) text("> " + serverLogs[i], 410, 30+(i*18));
  fill(255, 215, 0); text("TOP ANGLERS", 680, 30);
  fill(255);
  for(let i=0; i<min(leaderboard.length, 5); i++) text((i+1)+". "+leaderboard[i].name+": "+leaderboard[i].score, 680, 50+(i*18));
}

function runMainGame() {
  stroke(255, 255, 0); line(mouseX, 0, mouseX, mouseY + 125);
  for (let f of fishes) {
    f.update(); f.show();
    if (isOnline && mouseX > f.x && mouseX < f.x+40 && mouseY+125 > f.y && mouseY+125 < f.y+20) {
      inMiniGame = true; targetFish = f; captureProgress = 0; garyX = 200; reelX = 200;
    }
  }
}

function runMiniGame() {
  fill(0, 150); rect(0, 200, 650, 300);
  fill(60); stroke(255); rect(200, 300, 250, 60);
  garyX += garyDir * targetFish.difficulty;
  if (garyX > 420 || garyX < 205) garyDir *= -1;
  if (keyIsDown(LEFT_ARROW)) reelX -= 5;
  if (keyIsDown(RIGHT_ARROW)) reelX += 5;
  reelX = constrain(reelX, 200, 370);
  let on = abs((reelX+40)-(garyX+15)) < 35;
  captureProgress += on ? 0.8 : -0.5;
  captureProgress = constrain(captureProgress, 0, 100);
  fill(0, 255, 0, 100); rect(reelX, 305, 80, 50);
  fill(targetFish.col); rect(garyX, 320, 30, 20);
  if (captureProgress >= 100) { 
    if (targetFish.val > 1000) { inCutscene = true; } else { finishCatch(); }
  }
}

function runCutscene() {
  background(0); cutsceneTimer++;
  fill(targetFish.col); textAlign(CENTER); textSize(40);
  text("MYTHIC CATCH!", width/2, height/2);
  if (cutsceneTimer > 120) { inCutscene = false; cutsceneTimer = 0; finishCatch(); }
}

function finishCatch() {
  addLog("CATCH: " + targetFish.rarity);
  gold += targetFish.val; accountGold += targetFish.val;
  updateLeaderboard("You", targetFish.val);
  saveToCloud(); inMiniGame = false; targetFish.reset();
}

function addLog(m) { serverLogs.push(m); if (serverLogs.length > 8) serverLogs.shift(); }
function updateLeaderboard(n, s) { 
  let f = leaderboard.find(p => p.name === n);
  if (f) f.score += s; else leaderboard.push({name: n, score: s});
  leaderboard.sort((a,b) => b.score - a.score);
}
function saveToCloud() { isSyncing = true; setTimeout(() => isSyncing = false, 1000); }
function performRestart() { leaderboard = []; gold = 0; addLog("RESTARTED."); updateServerLuck(); restartTimer = -1; }
function updateServerLuck() { serverLuck = random(1, 5).toFixed(1); }
