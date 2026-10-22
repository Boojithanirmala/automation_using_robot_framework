*** Settings ***
Documentation     Browser start/stop and URL helpers shared by every suite.
Library           Browser
Variables         ${CURDIR}/../config/config.py


*** Keywords ***
Start Browser
    New Browser    browser=${BROWSER}    headless=${HEADLESS}

Open Fresh Page
    [Documentation]    New clean context, then open the login page (base URL + login path).
    New Context    viewport={'width': 1366, 'height': 768}
    New Page
    Go To Page     ${LOGIN_PATH}

Close Test Context
    Close Context

Go To Page
    [Documentation]    Navigate to ANY page: base URL + that page's path.
    [Arguments]    ${path}
    Go To    ${BASE_URL}${path}

Url Should Be Page
    [Documentation]    Assert the current URL is base URL + that page's path.
    [Arguments]    ${path}
    Get Url    contains    ${BASE_URL}${path}