*** Settings ***
Documentation    Reusable keywords for SweetAlert2 confirmation popups (used app-wide).
Library          Browser


*** Variables ***
${SWAL_POPUP}           css=.swal2-container .swal2-popup
${SWAL_WARNING_POPUP}   css=.swal2-container .swal2-popup.swal2-icon-warning
${SWAL_TITLE}           ${SWAL_POPUP} >> css=.swal2-title
${SWAL_MESSAGE}         ${SWAL_POPUP} >> css=.swal2-html-container
${SWAL_CONFIRM_BTN}     ${SWAL_POPUP} >> css=button.swal2-confirm
${SWAL_CANCEL_BTN}      ${SWAL_POPUP} >> css=button.swal2-cancel


*** Keywords ***
Swal Popup Is Shown
    [Documentation]    Returns True if a warning/confirmation popup becomes visible within the timeout.
    [Arguments]    ${timeout}=3s
    ${shown}=    Run Keyword And Return Status
    ...    Wait For Elements State    ${SWAL_WARNING_POPUP}    visible    timeout=${timeout}
    RETURN    ${shown}


Get Swal Title
    [Documentation]    Returns the popup title, e.g. "Are you sure?" or "Final Approval".
    ${title}=    Get Text    ${SWAL_TITLE}
    RETURN    ${title}


Get Swal Message
    [Documentation]    Returns the popup message text.
    ${message}=    Get Text    ${SWAL_MESSAGE}
    RETURN    ${message}


Swal Message Should Contain
    [Documentation]    Verifies the popup message contains the text.
    [Arguments]    ${expected_text}
    Get Text    ${SWAL_MESSAGE}    *=    ${expected_text}


Confirm Swal Popup
    [Documentation]    Clicks the confirm button, whatever its text is.
    Click    ${SWAL_CONFIRM_BTN}


Cancel Swal Popup
    [Documentation]    Clicks Cancel and verifies the popup closes.
    Click    ${SWAL_CANCEL_BTN}
    Wait For Elements State    ${SWAL_WARNING_POPUP}    hidden