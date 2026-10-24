*** Settings ***
Documentation     Common action buttons shared by every form / list page.
...               Save, Reset, Cancel (form page)
...               Add New, Edit, Delete (list page)
Library           Browser


*** Variables ***
# ---------- Form page buttons ----------
${BTN_SAVE}              css=button[type="submit"].btn-success
${BTN_RESET}             css=button.btn-warning:has-text("Reset")
${BTN_CANCEL}            css=a.btn-danger:has-text("Cancel")

# ---------- List page buttons ----------
${BTN_ADD_NEW}           css=button.btn-primary:has-text("Add New")
${BTN_EDIT}              css=button[title="Edit"]
${BTN_DELETE}            css=button[title="Delete"]

# ---------- Delete confirmation popup (ASSUMPTION - verify in DevTools) ----------
${BTN_CONFIRM_YES}       css=.swal2-confirm
${BTN_CONFIRM_NO}        css=.swal2-cancel

${BTN_TIMEOUT}           10s


*** Keywords ***
# =====================================================================
# FORM PAGE : Save / Reset / Cancel
# =====================================================================
Click Save
    [Documentation]    Click the Save (submit) button of the current form.
    Wait For Elements State    ${BTN_SAVE}    visible    timeout=${BTN_TIMEOUT}
    Click    ${BTN_SAVE}

Click Reset
    [Documentation]    Click the Reset button of the current form.
    Wait For Elements State    ${BTN_RESET}    visible    timeout=${BTN_TIMEOUT}
    Click    ${BTN_RESET}

Click Cancel
    [Documentation]    Click Cancel 
    Wait For Elements State    ${BTN_CANCEL}    visible    timeout=${BTN_TIMEOUT}
    Click    ${BTN_CANCEL}

# =====================================================================
# LIST PAGE : Add New
# =====================================================================
Click Add New
    [Documentation]    Click the "Add New ..." button. 
    [Arguments]    ${label}=${EMPTY}
    IF    '${label}' == '${EMPTY}'
        ${locator}=    Set Variable    ${BTN_ADD_NEW}
    ELSE
        ${locator}=    Set Variable    css=button.btn-primary:has-text("Add New ${label}")
    END
    Wait For Elements State    ${locator}    visible    timeout=${BTN_TIMEOUT}
    Click    ${locator}

# =====================================================================
# LIST PAGE : Edit / Delete (row-based)
# =====================================================================
Click Edit In Row
    [Documentation]    Click Edit in the table row 
    [Arguments]    ${row_text}
    ${locator}=    Set Variable    css=tr:has-text("${row_text}") >> button[title="Edit"]
    Wait For Elements State    ${locator}    visible    timeout=${BTN_TIMEOUT}
    Click    ${locator}

Click Delete In Row
    [Documentation]    Click Delete in the row 
    [Arguments]    ${row_text}
    ${locator}=    Set Variable    css=tr:has-text("${row_text}") >> button[title="Delete"]
    Wait For Elements State    ${locator}    visible    timeout=${BTN_TIMEOUT}
    Click    ${locator}

Delete Record In Row
    [Documentation]    Click Delete in the row AND confirm the popup.
    [Arguments]    ${row_text}
    Click Delete In Row    ${row_text}
    Confirm Delete

# =====================================================================
# LIST PAGE : Edit / Delete (record-id based)
# onclick="onEdit('invoiceForm','<id>')" / onclick="DeleteClick('<id>')"
# =====================================================================
Click Edit By Record Id
    [Arguments]    ${record_id}
    ${locator}=    Set Variable    css=button[title="Edit"][onclick*="${record_id}"]
    Wait For Elements State    ${locator}    visible    timeout=${BTN_TIMEOUT}
    Click    ${locator}

Click Delete By Record Id
    [Arguments]    ${record_id}
    ${locator}=    Set Variable    css=button[title="Delete"][onclick*="${record_id}"]
    Wait For Elements State    ${locator}    visible    timeout=${BTN_TIMEOUT}
    Click    ${locator}

# =====================================================================
# DELETE CONFIRMATION POPUP
# =====================================================================
Confirm Delete
    [Documentation]    Click Yes on the delete confirmation popup.
    Wait For Elements State    ${BTN_CONFIRM_YES}    visible    timeout=${BTN_TIMEOUT}
    Click    ${BTN_CONFIRM_YES}

Cancel Delete
    [Documentation]    Click No / Cancel on the delete confirmation popup.
    Wait For Elements State    ${BTN_CONFIRM_NO}    visible    timeout=${BTN_TIMEOUT}
    Click    ${BTN_CONFIRM_NO}

# =====================================================================
# ASSERTIONS (visibility / state) - useful for stage-wise & role tests
# =====================================================================
Save Button Should Be Visible
    Wait For Elements State    ${BTN_SAVE}    visible    timeout=${BTN_TIMEOUT}

Save Button Should Not Be Visible
    Wait For Elements State    ${BTN_SAVE}    detached    timeout=${BTN_TIMEOUT}

Reset Button Should Be Visible
    Wait For Elements State    ${BTN_RESET}    visible    timeout=${BTN_TIMEOUT}

Cancel Button Should Be Visible
    Wait For Elements State    ${BTN_CANCEL}    visible    timeout=${BTN_TIMEOUT}

Save Button Should Be Disabled
    Wait For Elements State    ${BTN_SAVE}    disabled    timeout=${BTN_TIMEOUT}

Save Button Should Be Enabled
    Wait For Elements State    ${BTN_SAVE}    enabled    timeout=${BTN_TIMEOUT}

Add New Button Should Be Visible
    [Arguments]    ${label}=${EMPTY}
    IF    '${label}' == '${EMPTY}'
        ${locator}=    Set Variable    ${BTN_ADD_NEW}
    ELSE
        ${locator}=    Set Variable    css=button.btn-primary:has-text("Add New ${label}")
    END
    Wait For Elements State    ${locator}    visible    timeout=${BTN_TIMEOUT}

Add New Button Should Not Be Visible
    [Documentation]    For permission tests (user without create access).
    Wait For Elements State    ${BTN_ADD_NEW}    detached    timeout=${BTN_TIMEOUT}

Edit Button Should Not Be Visible In Row
    [Arguments]    ${row_text}
    Wait For Elements State    css=tr:has-text("${row_text}") >> button[title="Edit"]
    ...    detached    timeout=${BTN_TIMEOUT}

Delete Button Should Not Be Visible In Row
    [Arguments]    ${row_text}
    Wait For Elements State    css=tr:has-text("${row_text}") >> button[title="Delete"]
    ...    detached    timeout=${BTN_TIMEOUT}