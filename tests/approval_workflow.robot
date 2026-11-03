*** Settings ***
Documentation     Tests for the approval workflow component itself (form-independent).
...               Rejection flow is a business rule supplied per run:
...               robot --variable REJECTION_FLOW:"Decrease Levels" tests/approval_workflow.robot
...               robot --variable REJECTION_FLOW:Rejected          tests/approval_workflow.robot
Resource          ${CURDIR}/../resources/common.resource
Resource          ${CURDIR}/../resources/components/approval_workflow.resource
Resource          ${CURDIR}/../resources/components/approval_log.resource
Resource          ${CURDIR}/../resources/components/approval_status_config.resource
Resource          ${CURDIR}/common_form_actions.resources
Suite Setup       Start Browser
Test Setup        Open Fresh Page
Test Teardown     Close Test Context


*** Variables ***
# The only things a test has to supply: where, which record, which levels, which rejection rule
${LISTING_PATH}          /payslip/list                       # CHECK: real listing path
${STATUS_MODAL_TRIGGER}  css=button[title="Approval Status Name"]    # CHECK
${RECORD_ID}             ${EMPTY}                            # id of a record created by the page's own keyword
${REJECTION_FLOW}        Decrease Levels                     # or: Rejected (from the business requirement)
@{LEVELS}                L1    L2    L3


*** Test Cases ***
Configured Display Names Appear On Approve Buttons
    [Documentation]    Dynamic status names: whatever is configured in the modal is what the button title shows.
    [Tags]    approval    status-name
    Login As Approver    L1
    Go To Page    ${LISTING_PATH}
    Open Approval Status Modal    ${STATUS_MODAL_TRIGGER}
    ${names}=    Get Configured Display Names
    Close Approval Status Modal
    ${expected}=    Resolve Display Name    L1    ${names}
    Approve Button Title Should Be    ${RECORD_ID}    ${expected}


Record Goes Through Every Level
    [Documentation]    Works for 1, 2, 3 or 4 levels, just change @{LEVELS}.
    [Tags]    approval    flow
    Login As Approver    L1
    Go To Page    ${LISTING_PATH}
    Open Approval Status Modal    ${STATUS_MODAL_TRIGGER}
    ${names}=    Get Configured Display Names
    Close Approval Status Modal
    Logout Current User
    Approve Through Levels    ${LISTING_PATH}    ${RECORD_ID}    ${names}    @{LEVELS}


Non Selected Employee Cannot Approve
    [Documentation]    L2 user must not see the L1 approve button.
    [Tags]    approval    negative
    Login As Approver    L2
    Go To Page    ${LISTING_PATH}
    Approve Button Should Not Be Visible    ${RECORD_ID}    L1


Reject Needs Remarks
    [Documentation]    Reject modal opens, Reject stays disabled until remarks are typed, Close works.
    [Tags]    approval    reject
    Login As Approver    L2
    Go To Page    ${LISTING_PATH}
    Open Reject Modal    ${RECORD_ID}
    Approval Modal Title Should Contain    Reject
    Reject Confirm Should Be Disabled
    Fill Textarea    ${APP_MODAL_REMARKS}    some remarks
    Reject Confirm Should Be Enabled
    Close Approval Modal


Rejection Follows Configured Flow
    [Documentation]    Reject at L2, then verify per rejection flow (Decrease Levels = back one level, Rejected = dead record).
    [Tags]    approval    reject
    Reject Record As Level    L2    ${LISTING_PATH}    ${RECORD_ID}    reject remarks
    Verify Rejection Outcome    ${LISTING_PATH}    ${RECORD_ID}    ${REJECTION_FLOW}    L2    ${NONE}    @{LEVELS}


Approval Log Records Rejection
    [Documentation]    Latest log entry shows who rejected and the remarks.
    [Tags]    approval    log
    Login As Approver    L2
    Go To Page    ${LISTING_PATH}
    Latest Approval Log Should Be Rejection    ${RECORD_ID}    reject remarks

Get Record Actions
    [Documentation]    Returns the sorted action names the current user gets on a record, e.g.
    ...                ['Approval Log', 'Approve', 'Delete', 'Edit', 'Reject'].
    ...                "Approve (<any status name>)" is normalised to "Approve", so dynamic status names don't matter.
    ...                The row is found through the record id, so the record's Approval Log button must be visible.
    [Arguments]    ${record_id}
    ${buttons}=    Set Variable    xpath=//tr[.//button[contains(@onclick,'${record_id}')]]//button[@title]
    Wait For Elements State    ${buttons} >> nth=0    visible
    ${count}=    Get Element Count    ${buttons}
    ${actions}=    Create List
    FOR    ${i}    IN RANGE    ${count}
        ${title}=    Get Attribute    ${buttons} >> nth=${i}    title
        ${name}=    Replace String Using Regexp    ${title}    ^Approve \\(.*\\)$    Approve
        Append To List    ${actions}    ${name}
    END
    Sort List    ${actions}
    RETURN    ${actions}


Get Record Id By Row Text
    [Documentation]    Returns the record id of the row containing the text, read from the Approval Log button's onclick.
    [Arguments]    ${row_text}
    ${log_btn}=    Set Variable    xpath=//tr[contains(normalize-space(.),'${row_text}')]//button[@title='Approval Log']
    Wait For Elements State    ${log_btn}    visible
    ${onclick}=    Get Attribute    ${log_btn}    onclick
    ${ids}=    Get Regexp Matches    ${onclick}    '([0-9a-f]{24})'    1
    RETURN    ${ids}[0]