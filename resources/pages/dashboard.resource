*** Settings ***
Library     Browser
Resource    ../common.resource


*** Variables ***
${DASHBOARD_MARKER}        text=Welcome back


*** Keywords ***
Dashboard Should Be Open
    Wait For Elements State    ${DASHBOARD_MARKER}    visible    timeout=20s
    Url Should Be Page         ${DASHBOARD_PATH}