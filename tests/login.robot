*** Settings ***
Documentation     Login page tests 
Resource          ../resources/common.resource
Resource          ../resources/pages/login_page.resource
Resource          ../resources/pages/dashboard.resource
Suite Setup       Start Browser
Suite Teardown    Close Browser
Test Setup        Open Fresh Page
Test Teardown     Close Test Context
Test Tags        login


*** Test Cases ***
Valid Username And Valid Password Logs In
    [Tags]    smoke
    Login With Credentials    ${VALID_USERNAME}    ${VALID_PASSWORD}
    Dashboard Should Be Open

Valid Username And Invalid Password Is Rejected
    [Tags]    regression    negative
    Login With Credentials    ${VALID_USERNAME}    ${INVALID_PASSWORD}
    Login Error Should Contain    ${MSG_INVALID_PASSWORD}

Invalid Username And Valid Password Is Rejected
    [Tags]    regression    negative
    Login With Credentials    ${INVALID_USERNAME}    ${VALID_PASSWORD}
    Login Error Should Contain    ${MSG_INVALID_USERNAME}

Invalid Username And Invalid Password Is Rejected
    [Tags]    regression    negative
    Login With Credentials    ${INVALID_USERNAME}    ${INVALID_PASSWORD}
    Login Error Should Contain    ${MSG_INVALID_CREDENTIALS}

Locked Out User Cannot Login
    [Tags]    regression    negative
    Login With Credentials    ${LOCKED_USERNAME}    ${VALID_PASSWORD}
    Login Error Should Contain    ${MSG_LOCKED_OUT}

Empty Username Shows Error
    [Tags]    regression    negative
    Login With Credentials    ${EMPTY}    ${VALID_PASSWORD}
    Login Error Should Contain    ${MSG_USERNAME_REQUIRED}

Empty Password Shows Error
    [Tags]    regression    negative
    Login With Credentials    ${VALID_USERNAME}    ${EMPTY}
    Login Error Should Contain    ${MSG_PASSWORD_REQUIRED}
