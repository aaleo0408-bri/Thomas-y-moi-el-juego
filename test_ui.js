const { chromium } = require('playwright');
const fs = require('fs');
const path = require('path');

(async () => {
  const browser = await chromium.launch({ headless: true });
  const context = await browser.newContext();
  const page = await context.newPage();

  // Assuming the game is served locally on port 8000
  await page.goto('http://localhost:8000');

  // Wait for the canvas to be ready
  await page.waitForSelector('#game');

  // Take a screenshot of the initial state
  await page.screenshot({ path: 'screenshot_initial.png' });
  console.log('Screenshot taken: screenshot_initial.png');

  // Verify UI elements based on the game state (e.g., Title screen)
  const title = await page.evaluate(() => {
    return document.querySelector('canvas') ? 'Canvas Found' : 'Canvas Not Found';
  });
  console.log(title);

  await browser.close();
})();
