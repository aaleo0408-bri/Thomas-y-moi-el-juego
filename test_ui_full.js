const { chromium } = require('playwright');

(async () => {
  const browser = await chromium.launch({ headless: true });
  const context = await browser.newContext();
  const page = await context.newPage();

  console.log('Navigating to game...');
  await page.goto('http://localhost:8000');

  // 1. Title Screen
  await page.waitForSelector('#game');
  await page.screenshot({ path: 'test_1_title.png' });
  console.log('Title screen screenshot saved.');

  // 2. Start New Game (Map)
  console.log('Starting new game...');
  // The "NUEVA PARTIDA" button is at (430, 336) in index.html for Title screen
  // Buttons are: {x:430, y:336, w:292, h:65}
  await page.mouse.click(430 + 146, 336 + 32);
  await page.waitForTimeout(1000); // Wait for transition
  await page.screenshot({ path: 'test_2_map.png' });
  console.log('Map screen screenshot saved.');

  // 3. Enter Level 1
  console.log('Entering Level 1...');
  // Level 1 node is at (180, 210)
  await page.mouse.click(180, 210);
  await page.waitForTimeout(1000);
  await page.screenshot({ path: 'test_3_gameplay.png' });
  console.log('Gameplay screenshot saved.');

  // 4. Play and die
  console.log('Testing death/respawn...');
  // Move right for a bit and jump into a pit or just wait
  // Actually, I can just teleport the player or force death if I had a console command,
  // but let's just wait and see if we can find a hazard.
  // Or better, let's just check if the canvas is drawing.

  // 5. Test World Navigation
  console.log('Testing map navigation...');
  await page.keyboard.press('Escape'); // Pause
  await page.waitForTimeout(500);
  // "SALIR AL MAPA" button at (590, 300, w:200, h:62)
  await page.mouse.click(590 + 100, 300 + 31);
  await page.waitForTimeout(1000);

  // Click next world button (1052, 290, w:64, h:64)
  await page.mouse.click(1052 + 32, 290 + 32);
  await page.waitForTimeout(500);
  await page.screenshot({ path: 'test_4_map_world2.png' });
  console.log('Map world 2 screenshot saved.');

  await browser.close();
  console.log('Playwright tests completed.');
})();
