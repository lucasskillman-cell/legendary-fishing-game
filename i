let gold = 0, accountGold = 0, serverLuck = 1.0;
let isOnline = true, inMiniGame = false, garyX = 0, reelX = 0;
let progress = 0, adminInput, bait = 5, reelSpeed = 5;
let fishType = {name: "Common", col: [0, 150, 255], speed: 1, val: 50};

function setup() {
  createCanvas(400, 400);
  adminInput = createInput('').size(50).position(340, 10);
  
  // Shop Buttons
  let b1 = createButton('UPGRADE REEL (500g)').position(10, 370);
  b1.mousePressed(() => { if(accountGold >= 500) { accountGold -= 500; reelSpeed += 1; } });
  
  let b2 = createButton('LUCK CHARM (1000g)').position(200, 370);
  b2.mousePressed(() => { if(accountGold >= 1000) { accountGold -= 1000; serverLuck += 0.5; } });
}

function draw() {
  background(isOnline ? 120 : 40);
  
  // Internet & Bait Restock
  if (frameCount % 180 === 0) {
    isOnline = random(100) > 8;
    if (isOnline && bait < 5) {
        bait++;
        console.log("Internet restocked 1 bait.");
    }
  }

  // UI
  fill(0, 100, 200); rect(0, 150, 400, 250);
  fill(255); textSize(11);
  text("Status: " + (isOnline ? "🟢 ONLINE" : "🔴 OFFLINE"), 10, 20);
  text("🪱 Bait: " + bait + "/5", 10, 40);
  text("⚙️ Reel Spd: " + reelSpeed, 10, 60);
  fill(255, 215, 0); text("Account: " + accountGold + "g", 10, 80);

  if (!inMiniGame) {
    runMainGame();
  } else {
    runMiniGame();
  }
}

function runMainGame() {
  if (!isOnline) {
    textAlign(CENTER); fill(255); text("WAITING FOR CONNECTION...", 200, 250); textAlign(LEFT);
    return;
  }

  // Draw Line
  stroke(255, 255, 0); line(mouseX, 0, mouseX, mouseY + 50);
  
  // Draw Random Fish
  noStroke(); fill(fishType.col); 
  ellipse(200, 250, 30, 15);
  fill(255); textSize(10); text(fishType.name, 185, 275);

  if (mouseIsPressed && dist(mouseX, mouseY, 200, 250) < 40) {
    if (bait > 0) {
      bait--;
      inMiniGame = true; progress = 0; garyX = 100; reelX = 100;
    } else {
      fill(255, 0, 0); text("OUT OF BAIT! WAIT FOR INTERNET.", 120, 140);
    }
  }
}

function runMiniGame() {
  fill(0, 150); rect(0, 0, 400, 400);
  fill(60); stroke(255); rect(100, 180, 200, 40);
  
  // Gary moves based on fish type + luck
  garyX = 100 + sin(frameCount * 0.1 * fishType.speed * (serverLuck/2)) * 90 + 90;
  
  // Controls
  if (keyIsDown(LEFT_ARROW) || (mouseIsPressed && mouseX < 200)) reelX -= reelSpeed;
  if (keyIsDown(RIGHT_ARROW) || (mouseIsPressed && mouseX > 200)) reelX += reelSpeed;
  reelX = constrain(reelX, 100, 250);
  
  let on = abs((reelX + 25) - (garyX + 10)) < 25;
  progress += on ? 1.0 : -0.5;
  progress = constrain(progress, 0, 100);
  
  noStroke(); fill(0, 255, 0, 100); rect(reelX, 185, 50, 30);
  fill(fishType.col); rect(garyX, 190, 20, 20);
  
  fill(255); rect(100, 240, 200, 10);
  fill(0, 255, 0); rect(100, 240, progress * 2, 10);
  
  if (progress >= 100) {
    accountGold += fishType.val;
    inMiniGame = false;
    // Reroll next fish
    let r = random(100);
    if (r < 5) { fishType = {name: "SECRET", col: [255, 0, 255], speed: 4, val: 5000}; }
    else if (r < 20) { fishType = {name: "LEGENDARY", col: [255, 215, 0], speed: 2.5, val: 500}; }
    else { fishType = {name: "Common", col: [0, 150, 255], speed: 1.2, val: 50}; }
  }
}
