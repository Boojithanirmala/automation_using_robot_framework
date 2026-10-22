# Robot Framework + Browser library: login suite

## Prerequisites
1. Python 3.9 or higher       -> python --version
2. Node.js (LTS version)      -> node --version   (the Browser library runs on Playwright, which needs Node)
3. Internet access for the first setup (downloads Node packages + browsers)
4. Recommended editor: VS Code + "RobotCode" extension

## Setup (one time)
    python -m venv .venv
    .venv\Scripts\activate            # Windows
    source .venv/bin/activate         # Mac / Linux
    pip install -r requirements.txt
    rfbrowser init                    # downloads Playwright + browsers
    # only need Chrome-type browser?   rfbrowser init chromium

## Run
    robot -d results tests/                          # all tests, visible browser
    robot -d results -v HEADLESS:True tests/         # headless (use this in CI)
    robot -d results -i smoke tests/                 # only smoke tests
    robot -d results -i negative tests/              # only negative tests
    robot -d results --test "Valid*" tests/          # tests matching a name
    robot -d results -v BASE_URL:https://qa.myapp.com tests/

## Results (in results/)
    report.html   summary for managers
    log.html      step-by-step log, with screenshots of failures
    output.xml    machine-readable (used by CI tools)

## Corporate network / proxy problems?
`rfbrowser init` downloads from npm and the Playwright CDN. If it fails:
set HTTP_PROXY / HTTPS_PROXY, or ask IT to allow npmjs.org and the Playwright download host.
