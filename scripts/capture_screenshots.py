#!/usr/bin/env python3
from pathlib import Path
import os
from playwright.sync_api import sync_playwright, expect

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / 'media' / 'screenshots'
OUT.mkdir(parents=True, exist_ok=True)
HTML = (ROOT / 'index.html').read_text(encoding='utf-8')
# set_content uses an opaque origin here, so shadow localStorage only inside the capture copy.
_STORAGE_SHIM = '''  const __captureStore = new Map();\n  const localStorage = {\n    getItem(k){k=String(k); return __captureStore.has(k)?__captureStore.get(k):null;},\n    setItem(k,v){__captureStore.set(String(k),String(v));},\n    removeItem(k){__captureStore.delete(String(k));},\n    clear(){__captureStore.clear();}\n  };\n'''
HTML = HTML.replace('  \"use strict\";\n', '  \"use strict\";\n' + _STORAGE_SHIM, 1)

shots = [
    '01-start-screen.png',
    '02-live-desert.png',
    '03-spelling-combat.png',
    '04-word-controls.png',
    '05-grade-report.png',
    '06-student-records.png',
]
for name in shots:
    p = OUT / name
    if p.exists():
        p.unlink()

with sync_playwright() as pw:
    launch = {'headless': True}
    system_chromium = os.environ.get('PLAYWRIGHT_CHROMIUM_EXECUTABLE')
    if system_chromium:
        launch['executable_path'] = system_chromium
        launch['args'] = ['--no-sandbox']
    browser = pw.chromium.launch(**launch)
    page = browser.new_page(viewport={'width': 1440, 'height': 900}, device_scale_factor=1)
    page.set_content(HTML, wait_until='load')
    expect(page.locator('#startPanel')).to_be_visible()
    page.screenshot(path=str(OUT / shots[0]), full_page=True)

    page.locator('#studentName').fill('Demo Student')
    page.locator('#gradeSelect').select_option('grade1')
    page.locator('#startButton').click()
    expect(page.locator('#spellBox')).to_be_visible()
    page.wait_for_timeout(900)
    page.screenshot(path=str(OUT / shots[1]), full_page=True)

    # Complete several correct spells so the live gameplay and report are meaningful.
    for attempt in range(4):
        word = page.locator('#targetWord').inner_text().strip()
        if not word:
            break
        page.keyboard.type(word)
        if attempt == 0:
            page.wait_for_timeout(100)
            page.screenshot(path=str(OUT / shots[2]), full_page=True)
        page.keyboard.press('Enter')
        page.wait_for_timeout(280)

    # Show the in-game custom word controls.
    page.locator('#pauseButton').click()
    expect(page.locator('#pausePanel')).to_be_visible()
    page.locator('#changeWordsButton').click()
    expect(page.locator('#wordsPanel')).to_be_visible()
    page.screenshot(path=str(OUT / shots[3]), full_page=True)

    # Return to pause and end the session so a real grade is stored.
    page.locator('#cancelWordsButton').click()
    expect(page.locator('#pausePanel')).to_be_visible()
    page.locator('#quitButton').click()
    expect(page.locator('#endPanel')).to_be_visible()
    page.screenshot(path=str(OUT / shots[4]), full_page=True)

    page.locator('#endRecordsButton').click()
    expect(page.locator('#recordsPanel')).to_be_visible()
    expect(page.locator('#recordsTable')).to_be_visible()
    page.screenshot(path=str(OUT / shots[5]), full_page=True)

    browser.close()

for name in shots:
    p = OUT / name
    if not p.exists() or p.stat().st_size < 10_000:
        raise SystemExit(f'bad screenshot: {p}')
    print(f'OK {name} {p.stat().st_size} bytes')
