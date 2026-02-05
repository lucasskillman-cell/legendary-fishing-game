var fishes = [];
var catchCount = 0;
var gold = 50;
var lastCatchRarity = "None";

// Mini-game Variables
var inMiniGame = false;
var targetFish = null;
var captureProgress = 0;
var garyX = 100;
var garyDir = 2;
var reelX = 100;
var osc; 

// Cinematic Variables
var inCutscene = false;
var cutsceneTimer = 0;

function setup() {
  createCanvas(700, 400);
  for (var i = 0; i < 12; i++) {
    fishes.push(new Fish());
  }
  osc = new p5.Oscillator('triangle');
  osc.amp(0);
  osc.start();
}

class Fish {
  constructor() { this.reset(); }
  reset() {
    this.x = random(-600, -100);
    this.y = random(150, height - 50);  
    this.xSpeed = random(1, 3);
    this.ySpeed = random(-0.5, 0.5);
    
    // Rarity Logic
    let r = random(1000);
    if (r < 10) { // 1% Secret Spawn
        this.rarity = "SECRET"; 
        this.col = color(255, 0, 255); 
        this.val = 25000; 
        this.difficulty = 5.5; 
    }
    else if (r < 50) { 
        this.rarity = "LEGENDARY"; 
        this.col = color(255, 215, 0); 
        this.val = 500; 
        this.difficulty = 4; 
    }
    else if (r < 200) { 
        this.rarity = "RARE"; 
        this.col = color(155, 89, 182); 
        this.val = 100; 
        this.difficulty = 2.5; 
    }
    else { 
        this.rarity = "COMMON"; 
        this.col = color(255); 
        this.val = 10; 
        this.difficulty = 1.5; 
    }
    this.pileX = -400; this.pileY = -400;
  }
  move() {
    if (inMiniGame || inCutscene) return; 
    this.x += this.xSpeed;
    this.y += this.ySpeed;
    if (this.y < 140 || this.y > height - 20) this.ySpeed *= -1;
    if (this.x > width + 150) this.reset();
  }
  display() {
    tint(this.col);
    image(fishImg, this.x, this.y, 110, 46);
    image(fishImg, this.pileX, this.pileY, 60, 25);
    noTint();
    
    // Rarity "!" Logic
    let d = dist(mouseX, mouseY + 125, this.x + 55, this.y + 23);
    if (d < 100 && this.x > 0 && !inMiniGame && !inCutscene) {
      fill(this.col); textSize(30); textStyle(BOLD);
      text("!", this.x + 45, this.y - 10); textStyle(NORMAL);
    }
  }
}

function draw() {
  if (inCutscene) {
    runCutscene();
    return;
  }

  background(123, 215, 132); 
  noStroke(); fill(0, 176, 255); rect(0, 120, width, height - 120);

  // Check for Secret Broadcast
  for(let f of fishes) {
    if (f.rarity === "SECRET" && f.x > 0 && f.x < width) {
       fill(255, 0, 255); textAlign(CENTER); textSize(14);
       text("🌌 A RIFT IN REALITY HAS OPENED! SECRET FISH DETECTED!", width/2, 110);
       textAlign(LEFT);
    }
  }

  // HUD
  fill(255); rect(10, 10, 200, 80, 10);
  fill(0); textSize(16);
  text('Total Caught: ' + catchCount, 20, 35);
  text('Gold: ' + gold + 'g', 20, 55);
  text('Last: ' + lastCatchRarity, 20, 75);

  if (!inMiniGame) {
    displayMainGame();
  } else {
    displayMiniGame();
  }
}

function displayMainGame() {
  noFill(); strokeWeight(3); stroke(0);
  arc(mouseX, mouseY + 95, 30, 60, 0, HALF_PI);
  stroke(255, 255, 0);
  line(mouseX, mouseY - 700, mouseX, mouseY + 125);
  
  image(bucketImg, 600, 40, bucketImg.width / 18, bucketImg.height / 18);
  
  for (let f of fishes) {
    f.move();
    f.display();
    if (mouseX > f.x && mouseX < f.x + 110 && 
        mouseY + 125 > f.y && mouseY + 125 < f.y + 46) {
      inMiniGame = true;
      targetFish = f;
      captureProgress = 0;
      garyX = 150;
      reelX = 150;
    }
  }
}

function displayMiniGame() {
  fill(0, 0, 0, 180); rect(0, 0, width, height);
  fill(50); stroke(255); strokeWeight(4); rect(150, 150, 400, 100, 10);
  
  garyX += garyDir * targetFish.difficulty;
  if (garyX > 510 || garyX < 160) garyDir *= -1;
  
  if (keyIsDown(LEFT_ARROW)) reelX -= 5;
  if (keyIsDown(RIGHT_ARROW)) reelX += 5;
  reelX = constrain(reelX, 150, 470);
  
  let distance = abs((reelX + 40) - (garyX + 15));
  if (distance < 45) {
    captureProgress += 0.7;
    osc.freq(400 + captureProgress * 2);
    osc.amp(0.1, 0.05);
  } else {
    captureProgress -= 0.5;
    osc.amp(0);
  }
  captureProgress = constrain(captureProgress, 0, 100);
  
  // Visuals
  noStroke(); fill(46, 204, 113, 150); rect(reelX, 160, 80, 80, 5);
  fill(targetFish.col); rect(garyX, 185, 30, 30, 5);
  
  fill(100); rect(200, 270, 300, 20);
  fill(46, 204, 113); rect(200, 270, map(captureProgress, 0, 100, 0, 300), 20);
  
  if (captureProgress >= 100) {
    if (targetFish.rarity === "SECRET") {
        inCutscene = true;
        cutsceneTimer = 0;
        inMiniGame = false;
    } else {
        finishCatch();
    }
  }
}

function runCutscene() {
  background(0);
  cutsceneTimer++;
  
  let alpha = map(sin(frameCount * 0.1), -1, 1, 100, 255);
  fill(255, 0, 255, alpha);
  textAlign(CENTER);
  textSize(40);
  text("LEGENDARY CATCH!", width/2, height/2 - 20);
  
  textSize(20);
  fill(255);
  text("You pulled a SECRET fish from the rift...", width/2, height/2 + 30);
  
  if (cutsceneTimer > 180) { // 3 seconds
    inCutscene = false;
    finishCatch();
  }
}

function finishCatch() {
  inMiniGame = false;
  catchCount++;
  gold += targetFish.val;
  lastCatchRarity = targetFish.rarity;
  targetFish.pileX = 610 + random(20);
  targetFish.pileY = 50 + random(30);
  osc.amp(0);
  let f = targetFish;
  setTimeout(() => { f.reset(); }, 3000);
  targetFish.x = -500;
}

function preload() {
  fishImg = loadImage('https://upload.wikimedia.org/wikipedia/commons/7/73/Flat_fish_icon.png');
  bucketImg = loadImage('https://cdn-icons-png.flaticon.com/512/305/305981.png');
}
