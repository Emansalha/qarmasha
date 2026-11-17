// يلتقط صور شاشات التطبيق (نسخة الويب) بمقاس هاتف.
import { chromium } from 'playwright';
import fs from 'fs';

const base = process.env.BASE_URL || 'http://localhost:8080/';
const screens = ['welcome', 'home', 'menu', 'item', 'cart', 'checkout', 'tracking', 'orders', 'offers', 'profile'];
fs.mkdirSync('shots', { recursive: true });

const browser = await chromium.launch({
  args: ['--use-gl=angle', '--use-angle=swiftshader', '--enable-unsafe-swiftshader', '--ignore-gpu-blocklist'],
});
const page = await browser.newPage({
  viewport: { width: 390, height: 844 },
  deviceScaleFactor: 2,
  isMobile: true,
  hasTouch: true,
});
page.on('console', (m) => { if (m.type() === 'error') console.log('console:', m.text()); });

for (const s of screens) {
  await page.goto(`${base}?screen=${s}`, { waitUntil: 'networkidle' });
  await page.waitForTimeout(s === 'welcome' ? 6000 : 5000);
  await page.screenshot({ path: `shots/${s}.png` });
  console.log('shot', s);
  if (s === 'home') {
    await page.mouse.move(195, 140);
    await page.mouse.wheel(0, 900);
    await page.waitForTimeout(2500);
    await page.screenshot({ path: `shots/home_2.png` });
    await page.mouse.wheel(0, 900);
    await page.waitForTimeout(2500);
    await page.screenshot({ path: `shots/home_3.png` });
    for (let k = 0; k < 4; k++) { await page.mouse.wheel(0, 700); await page.waitForTimeout(600); }
    await page.waitForTimeout(2000);
    await page.screenshot({ path: `shots/home_4.png` });
  }
  if (s === 'item') {
    await page.mouse.move(195, 500);
    await page.mouse.wheel(0, 700);
    await page.waitForTimeout(2000);
    await page.screenshot({ path: `shots/item_2.png` });
  }
}
await browser.close();
