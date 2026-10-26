*** Settings ***
Documentation     Locators and keywords common to every dynamic form and list page:
...               - Form buttons: Save, Update, Reset, Cancel, Back
...               - List page buttons: Add New, Edit, Delete
...               - Toast messages (#toast-container)
Library           Browser


*** Variables ***
# --- Form buttons (same text on every form) -----------------------------------
${FORM_SAVE_BUTTON}        xpath=//button[contains(@class,'btn')][normalize-space(.)='Save']
${FORM_UPDATE_BUTTON}      xpath=//button[contains(@class,'btn')][normalize-space(.)='Update']
${FORM_RESET_BUTTON}       xpath=//button[contains(@class,'btn')][normalize-space(.)='Reset']
${FORM_CANCEL_BUTTON}      xpath=//a[contains(@class,'btn')][normalize-space(.)='Cancel']
${FORM_BACK_BUTTON}        xpath=//button[contains(@class,'btn')][normalize-space(.)='Back']

# --- List page buttons ---------------------------------------------------------
${LIST_ADD_NEW_BUTTON}     xpath=//button[contains(@class,'btn')][starts-with(normalize-space(.),'Add New')]
${LIST_EDIT_BUTTON}        css=button[title="Edit"]
${LIST_DELETE_BUTTON}      css=button[title="Delete"]

# --- Toast ---------------------------------------------------------------------
${TOAST_CONTAINER}         css=#toast-container
${TOAST_ITEM}              xpath=//div[@id='toast-container']/*
${TOAST_CREATED_MESSAGE}   Data created successfully
${TOAST_UPDATED_MESSAGE}   Data updated successfully


*** Keywords ***
# ===========================================================================
# 1. Form buttons
# ===========================================================================
Click Save Button
    Click    ${FORM_SAVE_BUTTON}

Click Update Button
    Click    ${FORM_UPDATE_BUTTON}

Click Reset Button
    Click    ${FORM_RESET_BUTTON}

Click Cancel Button
    Click    ${FORM_CANCEL_BUTTON}

Click Back Button
    Click    ${FORM_BACK_BUTTON}

Save Button Should Be Visible
    Wait For Elements State    ${FORM_SAVE_BUTTON}    visible

Update Button Should Be Visible
    Wait For Elements State    ${FORM_UPDATE_BUTTON}    visible

Reset Button Should Be Visible
    Wait For Elements State    ${FORM_RESET_BUTTON}    visible

Cancel Button Should Be Visible
    Wait For Elements State    ${FORM_CANCEL_BUTTON}    visible

Back Button Should Be Visible
    Wait For Elements State    ${FORM_BACK_BUTTON}    visible

Form Action Buttons Should Be Visible
    [Documentation]    Save, Reset, Cancel and Back of an add form.
    Save Button Should Be Visible
    Reset Button Should Be Visible
    Cancel Button Should Be Visible
    Back Button Should Be Visible

Save Button Should Be Enabled
    Get Property    ${FORM_SAVE_BUTTON}    disabled    ==    ${False}

Save Button Should Be Disabled
    Get Property    ${FORM_SAVE_BUTTON}    disabled    ==    ${True}

Update Button Should Be Enabled
    Get Property    ${FORM_UPDATE_BUTTON}    disabled    ==    ${False}

Update Button Should Be Disabled
    Get Property    ${FORM_UPDATE_BUTTON}    disabled    ==    ${True}

# ===========================================================================
# 2. List page buttons
# ===========================================================================
Click Add New Button
    [Documentation]    No argument: the first "Add New ..." button. With the page name,
    ...                e.g. Click Add New Button    Payslip, only "Add New Payslip".
    [Arguments]    ${name}=${EMPTY}
    IF    $name == ''
        Click    ${LIST_ADD_NEW_BUTTON}
    ELSE
        Click    xpath=//button[contains(@class,'btn')][normalize-space(.)='Add New ${name}']
    END

Add New Button Should Be Visible
    [Arguments]    ${name}=${EMPTY}
    IF    $name == ''
        Wait For Elements State    ${LIST_ADD_NEW_BUTTON}    visible
    ELSE
        Wait For Elements State
        ...    xpath=//button[contains(@class,'btn')][normalize-space(.)='Add New ${name}']    visible
    END

Click Edit Button In Row
    [Documentation]    The row text must be unique, e.g. a payslip number.
    [Arguments]    ${row_text}
    Click    xpath=//tr[contains(normalize-space(.),'${row_text}')]//button[@title='Edit']

Click Delete Button In Row
    [Arguments]    ${row_text}
    Click    xpath=//tr[contains(normalize-space(.),'${row_text}')]//button[@title='Delete']

Click Edit Button By Index
    [Documentation]    Index starts at 1.
    [Arguments]    ${index}=1
    Click    xpath=(//button[@title='Edit'])[${index}]

Click Delete Button By Index
    [Documentation]    Index starts at 1.
    [Arguments]    ${index}=1
    Click    xpath=(//button[@title='Delete'])[${index}]

Edit And Delete Buttons Should Be Visible In Row
    [Arguments]    ${row_text}
    Wait For Elements State
    ...    xpath=//tr[contains(normalize-space(.),'${row_text}')]//button[@title='Edit']    visible
    Wait For Elements State
    ...    xpath=//tr[contains(normalize-space(.),'${row_text}')]//button[@title='Delete']    visible

# ===========================================================================
# 3. Toast messages
# ===========================================================================
Toast Message Should Be Visible
    [Documentation]    Matches the toast text exactly, whatever classes the toast uses.
    [Arguments]    ${message}
    Wait For Elements State
    ...    xpath=//div[@id='toast-container']//*[normalize-space(text())='${message}']    visible

Toast Message Should Not Be Visible
    [Arguments]    ${message}
    Wait For Elements State
    ...    xpath=//div[@id='toast-container']//*[normalize-space(text())='${message}']    hidden

Data Created Toast Should Be Visible
    Toast Message Should Be Visible    ${TOAST_CREATED_MESSAGE}

Data Updated Toast Should Be Visible
    Toast Message Should Be Visible    ${TOAST_UPDATED_MESSAGE}

No Toast Should Be Visible
    [Documentation]    E.g. after a failed validation, nothing must be saved.
    Get Element Count    ${TOAST_ITEM}    ==    0

Wait Until Toast Disappears
    [Arguments]    ${timeout}=15s
    Wait For Elements State    ${TOAST_ITEM}    detached    timeout=${timeout}