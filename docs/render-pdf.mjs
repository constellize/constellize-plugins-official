import { chromium } from 'playwright';
import { fileURLToPath } from 'url';
import { dirname, join } from 'path';

const __dirname = dirname(fileURLToPath(import.meta.url));

const browser = await chromium.launch();
const page = await browser.newPage();

await page.setViewportSize({ width: 1056, height: 1368 });
await page.goto(`file://${join(__dirname, 'constellize-skills-infographic.html')}`, { waitUntil: 'networkidle' });

// Wait for fonts
await page.waitForTimeout(1000);

await page.pdf({
  path: join(__dirname, 'constellize-skills-infographic.pdf'),
  width: '1056px',
  height: '1368px',
  printBackground: true,
  margin: { top: 0, bottom: 0, left: 0, right: 0 },
});

console.log('PDF saved to docs/constellize-skills-infographic.pdf');
await browser.close();
