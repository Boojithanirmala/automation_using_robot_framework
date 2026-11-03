*** Settings ***
Documentation    Reusable keywords for the "Approval Log" history modal (any form).
Library          Browser
Library          String
Library          Collections


*** Variables ***
${LOG_MODAL}              id=exampleModalLabel1
${LOG_HEADER_CLOSE_BTN}   ${LOG_MODAL} >> css=button[aria-label="Close"]
${LOG_TABLE}              ${LOG_MODAL} >> css=table.table
${LOG_ROWS}               ${LOG_MODAL} >> css=table tbody tr
${LOG_LATEST_ROW}         ${LOG_ROWS} >> nth=-1


*** Keywords ***
Approval Log Button Locator
    [Documentation]    Builds the Approval Log button locator for one record.
    [Arguments]    ${record_id}
    RETURN    css=button[title="Approval Log"][onclick*="${record_id}"]


Open Approval Log
    [Documentation]    Opens the approval log history modal of the record.
    [Arguments]    ${record_id}
    ${locator}=    Approval Log Button Locator    ${record_id}
    Click    ${locator}
    Wait For Elements State    ${LOG_TABLE}    visible


Close Approval Log
    [Documentation]    Closes the approval log modal using the header close icon.
    Click    ${LOG_HEADER_CLOSE_BTN}
    Wait For Elements State    ${LOG_TABLE}    hidden


Get Approval Log Row Count
    [Documentation]    Returns the number of log rows (modal must be open).
    ${count}=    Get Element Count    ${LOG_ROWS}
    RETURN    ${count}


Get Latest Approval Log Entry
    [Documentation]    Returns the latest log row as a dictionary: status, employee, remarks, datetime (modal must be open).
    ${status}=      Get Text    ${LOG_LATEST_ROW} >> css=td:nth-child(2)
    ${employee}=    Get Text    ${LOG_LATEST_ROW} >> css=td:nth-child(3)
    ${remarks}=     Get Text    ${LOG_LATEST_ROW} >> css=td:nth-child(4)
    ${datetime}=    Get Text    ${LOG_LATEST_ROW} >> css=td:nth-child(5)
    ${entry}=    Create Dictionary    status=${status.strip()}    employee=${employee.strip()}
    ...    remarks=${remarks.strip()}    datetime=${datetime.strip()}
    RETURN    ${entry}


Latest Approval Log Should Be Approval
    [Documentation]    Opens the log and verifies the latest entry is an approval (green down-arrow badge).
    [Arguments]    ${record_id}
    Open Approval Log    ${record_id}
    Wait For Elements State    ${LOG_LATEST_ROW} >> css=span.badge.bg-success    visible
    Close Approval Log


Latest Approval Log Should Be Rejection
    [Documentation]    Opens the log and verifies the latest entry is a rejection (red up-arrow badge), optionally with remarks.
    [Arguments]    ${record_id}    ${expected_remarks}=${EMPTY}
    Open Approval Log    ${record_id}
    Wait For Elements State    ${LOG_LATEST_ROW} >> css=span.badge.bg-danger    visible
    IF    '${expected_remarks}' != '${EMPTY}'
        ${entry}=    Get Latest Approval Log Entry
        Should Be Equal    ${entry}[remarks]    ${expected_remarks}
    END
    Close Approval Log


Latest Approval Log Should Show Transition
    [Documentation]    Verifies the latest entry shows "<from status> -> <to status>"
    [Arguments]    ${record_id}    ${from_status}    ${to_status}
    Open Approval Log    ${record_id}
    ${entry}=    Get Latest Approval Log Entry
    ${actual}=    Convert To Lower Case    ${entry}[status]
    ${expected}=    Convert To Lower Case    ${from_status} -> ${to_status}
    Should Contain    ${actual}    ${expected}
    Close Approval Log


Latest Approval Log Employee Should Be
    [Documentation]    Verifies who performed the latest action.
    [Arguments]    ${record_id}    ${expected_employee}
    Open Approval Log    ${record_id}
    ${entry}=    Get Latest Approval Log Entry
    Should Contain    ${entry}[employee]    ${expected_employee}
    Close Approval Log