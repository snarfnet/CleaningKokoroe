const { chromium } = require('playwright');
const path = require('path');

async function capture() {
    const browser = await chromium.launch();
    const page = await browser.newPage();

    const htmlPath = path.resolve(__dirname, 'generate.html');
    await page.goto(`file://${htmlPath}`);
    await page.waitForTimeout(1000);

    const phones = await page.locator('.phone').all();
    const names = ['01_main', '02_timer', '03_search', '04_feature'];

    for (let i = 0; i < phones.length; i++) {
        const outPath = path.resolve(__dirname, `${names[i]}.png`);
        // Capture at 3x for 1290x2796 (iPhone 6.7")
        // Phone element is 430x932, so we need to scale
        await phones[i].screenshot({ path: outPath, type: 'png' });
        console.log(`Captured: ${outPath}`);
    }

    await browser.close();
    console.log('Done!');
}

capture().catch(e => { console.error(e); process.exit(1); });
