*** Settings ***
Documentation    Reusable keywords for the dynamic approval workflow (any form, any number of levels, any rejection flow).
...              Page-independent: the calling test passes the record id, the listing path, the levels and the rejection flow.
Library          Browser
Library          String
Library          Collections
Library          ${CURDIR}/../libraries/env_helper.py
Resource         ${CURDIR}/textarea.resource
Resource         ${CURDIR}/approval_log.resource
Resource         ${CURDIR}/../pages/login_page.resource



*** Variables ***
${APPROVE_BTN_ANY}              css=button[title^="Approve ("]

# Shared modal (approve and reject both open app-modalcomponent)
${APP_MODAL}                    css=app-modalcomponent
${APP_MODAL_TITLE}              id=exampleModalLabel1
${APP_MODAL_REMARKS}            ${APP_MODAL} >> css=textarea#text-remarks
${APP_MODAL_CLOSE_BTN}          ${APP_MODAL} >> css=.modal-footer button.btn-secondary
${APP_MODAL_HEADER_CLOSE_BTN}   ${APP_MODAL} >> css=button.btn-close
${REJECTION_CONFIRM_BTN}        ${APP_MODAL} >> css=.modal-footer button.btn-danger
# CHECK: confirm the approve modal's confirm button (assumed btn-success)
${APPROVAL_CONFIRM_BTN}         ${APP_MODAL} >> css=.modal-footer button.btn-success

${PROFILE_MENU_BTN}             xpath=//a[@id='mainHeaderProfile']
${LOGOUT_ACTION}                xpath=//a[contains(@class,'dropdown-item') and normalize-space()='Log Out']

*** Keywords ***
Approve Button Locator
    [Documentation]    Builds the approve button locator for one record.
    ...                Without a display name it matches any level; with one it matches that exact title.
    [Arguments]    ${record_id}    ${display_name}=${EMPTY}
    IF    '${display_name}' == '${EMPTY}'
        ${locator}=    Set Variable    css=button[title^="Approve ("][onclick*="${record_id}"]
    ELSE
        ${locator}=    Set Variable    css=button[title="Approve (${display_name})"][onclick*="${record_id}"]
    END
    RETURN    ${locator}


Reject Button Locator
    [Documentation]    Builds the reject button locator for one record.
    [Arguments]    ${record_id}
    RETURN    css=button[title="Reject"][onclick*="${record_id}"]


Resolve Display Name
    [Documentation]    Returns the configured display name for a level, or the level itself when none is configured.
    [Arguments]    ${level}    ${display_names}=${NONE}
    IF    $display_names is None
        RETURN    ${EMPTY}
    END
    ${name}=    Get From Dictionary    ${display_names}    ${level}    default=${level}
    RETURN    ${name}


Login As Approver
    [Documentation]    Logs in with the credentials of the given level, read from .env (USER_L1 / PASS_L1 ...).
    [Arguments]    ${level}
    ${user}    ${pwd}=    Get Credentials    ${level}
    Login With Credentials    ${user}    ${pwd}


Logout Current User
    [Documentation]    Logs out the current user so the next approver can log in.
    Click    ${PROFILE_MENU_BTN}
    Click    ${LOGOUT_ACTION}


Approve Button Should Be Visible
    [Documentation]    Verifies the approve button (optionally for one display name) is visible for the record.
    [Arguments]    ${record_id}    ${display_name}=${EMPTY}
    ${locator}=    Approve Button Locator    ${record_id}    ${display_name}
    Wait For Elements State    ${locator}    visible


Approve Button Should Not Be Visible
    [Documentation]    Verifies the user cannot approve the record (not the selected employee / designation / wrong level).
    [Arguments]    ${record_id}    ${display_name}=${EMPTY}
    ${locator}=    Approve Button Locator    ${record_id}    ${display_name}
    Get Element Count    ${locator}    ==    0


Reject Button Should Be Visible
    [Documentation]    Verifies the reject button is visible for the record.
    [Arguments]    ${record_id}
    ${locator}=    Reject Button Locator    ${record_id}
    Wait For Elements State    ${locator}    visible


Reject Button Should Not Be Visible
    [Documentation]    Verifies the user cannot reject the record.
    [Arguments]    ${record_id}
    ${locator}=    Reject Button Locator    ${record_id}
    Get Element Count    ${locator}    ==    0


Get Approve Button Title
    [Documentation]    Returns the title of the approve button, e.g. "Approve (AWAITING APPROVAL)".
    [Arguments]    ${record_id}
    ${locator}=    Approve Button Locator    ${record_id}
    ${title}=    Get Attribute    ${locator}    title
    RETURN    ${title}


Approve Button Title Should Be
    [Documentation]    Verifies the approve button title matches the expected display name.
    [Arguments]    ${record_id}    ${expected_display_name}
    ${locator}=    Approve Button Locator    ${record_id}
    Get Attribute    ${locator}    title    ==    Approve (${expected_display_name})


Approval Modal Title Should Contain
    [Documentation]    Verifies the open approve/reject modal title contains the text 
    [Arguments]    ${expected_text}
    Get Text    ${APP_MODAL_TITLE}    *=    ${expected_text}


Close Approval Modal
    [Documentation]    Closes the approve/reject modal with the footer Close button.
    Click    ${APP_MODAL_CLOSE_BTN}
    Wait For Elements State    ${APP_MODAL_TITLE}    hidden


Open Reject Modal
    [Documentation]    Clicks reject for the record and waits for the reject modal.
    [Arguments]    ${record_id}
    ${locator}=    Reject Button Locator    ${record_id}
    Click    ${locator}
    Wait For Elements State    ${APP_MODAL_REMARKS}    visible


Reject Confirm Should Be Disabled
    [Documentation]    Verifies the Reject button in the modal is disabled (remarks are mandatory).
    Get Property    ${REJECTION_CONFIRM_BTN}    disabled    ==    ${True}


Reject Confirm Should Be Enabled
    [Documentation]    Verifies the Reject button in the modal is enabled.
    Get Property    ${REJECTION_CONFIRM_BTN}    disabled    ==    ${False}


Approve Record
    [Documentation]    Clicks approve for the record and confirms every popup that follows
    ...                (normal level popup, final approval, draft sequence conversion).
    ...                Returns the sequence conversion dictionary (empty if no conversion popup appeared).
    [Arguments]    ${record_id}    ${display_name}=${EMPTY}    ${expected_next_status}=${EMPTY}
    ${locator}=    Approve Button Locator    ${record_id}    ${display_name}
    Click    ${locator}
    ${conversion}=    Confirm Approval Popups    ${expected_next_status}
    RETURN    ${conversion}


Reject Record
    [Documentation]    Rejects the record as the current user. Remarks are mandatory (Reject stays disabled without them).
    [Arguments]    ${record_id}    ${remarks}=Rejected by automation
    Open Reject Modal    ${record_id}
    Reject Confirm Should Be Disabled
    Fill Textarea    ${APP_MODAL_REMARKS}    ${remarks}
    Reject Confirm Should Be Enabled
    Click    ${REJECTION_CONFIRM_BTN}
    Wait For Elements State    ${APP_MODAL_TITLE}    hidden


Approve Record As Level
    [Documentation]    Full single step: login as the level approver, open the listing, approve, logout.
    [Arguments]    ${level}    ${listing_path}    ${record_id}    ${display_names}=${NONE}    ${expected_next_status}=${EMPTY}
    ${display_name}=    Resolve Display Name    ${level}    ${display_names}
    Login As Approver    ${level}
    Go To Page    ${listing_path}
    Approve Button Should Be Visible    ${record_id}    ${display_name}
    Approve Record    ${record_id}    ${display_name}    ${expected_next_status}
    Logout Current User


Reject Record As Level
    [Documentation]    Full single step: login as the level approver, open the listing, reject with remarks, logout.
    [Arguments]    ${level}    ${listing_path}    ${record_id}    ${remarks}=Rejected by automation
    Login As Approver    ${level}
    Go To Page    ${listing_path}
    Reject Button Should Be Visible    ${record_id}
    Reject Record    ${record_id}    ${remarks}
    Logout Current User


Approve Through Levels
    [Documentation]    Approves a record through any number of levels, in order (e.g. L1 L2 L3 or L1 L2 L3 L4).
    ...                ${display_names} is an optional dictionary {L1: REQUESTED, ...}; missing levels fall back to the level name.
    [Arguments]    ${listing_path}    ${record_id}    ${display_names}    @{levels}
    FOR    ${level}    IN    @{levels}
        Approve Record As Level    ${level}    ${listing_path}    ${record_id}    ${display_names}
    END


Get Rejection Target Level
    [Documentation]    Expected result of a rejection, from the form's Rejection Flow (business rule, supplied by the test).
    [Arguments]    ${rejection_flow}    ${level}    @{levels}
    ${flow}=    Convert To Upper Case    ${rejection_flow}
    IF    '${flow}' == 'REJECTED'
        RETURN    REJECTED
    END
    ${index}=    Get Index From List    ${levels}    ${level}
    IF    ${index} == 0
        RETURN    DRAFT
    END
    ${previous_index}=    Evaluate    ${index} - 1
    RETURN    ${levels}[${previous_index}]


Verify Rejection Outcome
    [Documentation]    Verifies the result of a rejection made at ${level} according to the rejection flow:
    ...                latest log is a rejection, and the record is either dead REJECTED or back with the previous level's approver.
    [Arguments]    ${listing_path}    ${record_id}    ${rejection_flow}    ${level}    ${display_names}    @{levels}
    ${target}=    Get Rejection Target Level    ${rejection_flow}    ${level}    @{levels}
    IF    '${target}' in ['REJECTED', 'DRAFT']
        Login As Approver    ${level}
    ELSE
        Login As Approver    ${target}
    END
    Go To Page    ${listing_path}
    Latest Approval Log Should Be Rejection    ${record_id}
    IF    '${target}' == 'REJECTED'
        Approve Button Should Not Be Visible    ${record_id}
    ELSE IF    '${target}' != 'DRAFT'
        ${display_name}=    Resolve Display Name    ${target}    ${display_names}
        Approve Button Should Be Visible    ${record_id}    ${display_name}
    END
    Logout Current User


Get Sequence Conversion From Popup
    [Documentation]    Reads the "Draft Sequence Conversion" card: {draft: ..., official: ...}.
    ...                The card has no classes, so the labels are the stable anchor.
    ${draft}=       Get Text    ${SWAL_POPUP} >> xpath=.//div[normalize-space()='Current Draft']/following-sibling::div
    ${official}=    Get Text    ${SWAL_POPUP} >> xpath=.//div[normalize-space()='Official Sequence']/following-sibling::div
    ${conversion}=    Create Dictionary    draft=${draft}    official=${official}
    RETURN    ${conversion}


Confirm Approval Popups
    [Documentation]    Confirms every warning popup after clicking approve, in whatever order they appear:
    ...                "Are you sure?" -> "Final Approval" -> "Draft Sequence Conversion".
    ...                Works for 1 to 3 popups, so it fits any level count and conversion on/off.
    ...                If ${expected_next_status} is given, the first popup message must contain it.
    [Arguments]    ${expected_next_status}=${EMPTY}    ${max_popups}=4
    ${conversion}=    Create Dictionary
    FOR    ${index}    IN RANGE    ${max_popups}
        ${shown}=    Swal Popup Is Shown    3s
        IF    not ${shown}
            Should Be True    ${index} > 0    Approval confirmation popup did not appear
            BREAK
        END
        ${message}=    Get Swal Message
        IF    ${index} == 0 and '${expected_next_status}' != '${EMPTY}'
            Should Contain    ${message}    ${expected_next_status}
        END
        ${has_conversion}=    Run Keyword And Return Status    Should Contain    ${message}    Draft Sequence Conversion
        IF    ${has_conversion}
            ${conversion}=    Get Sequence Conversion From Popup
        END
        Confirm Swal Popup
    END
    Wait For Elements State    ${SWAL_WARNING_POPUP}    hidden
    RETURN    ${conversion}