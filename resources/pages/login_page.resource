*** Settings ***
Documentation     Login page: locators and actions. If the UI changes, fix it HERE only.
Library           Browser


*** Variables ***
# Priority: data-testid / data-test  >  role / label / text  >  id  >  css  >  xpath
${USERNAME_INPUT}     [id="signin-username"]
${PASSWORD_INPUT}     [id="signin-password"]
${LOGIN_BUTTON}       button[type="submit"]
${ERROR_MESSAGE}      [id="toast-container"]x`


*** Keywords ***
Login With Credentials
    [Documentation]    Fills the form and clicks Login. Does NOT check the result.
    [Arguments]    ${username}    ${password}
    Fill Text    ${USERNAME_INPUT}    ${username}
    Fill Text    ${PASSWORD_INPUT}    ${password}
    Click        ${LOGIN_BUTTON}

Login Error Should Contain
    [Documentation]    Error is shown and we are still on the login form.
    [Arguments]    ${expected_message}
    Get Text                   ${ERROR_MESSAGE}     contains    ${expected_message}
    Wait For Elements State    ${PASSWORD_INPUT}    visible
