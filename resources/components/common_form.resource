*** Settings ***
Documentation     Locators and keywords common to every add / edit form:
...               Save, Update, Reset, Cancel, Back buttons and the toast messages.
Library           Browser


*** Variables ***
# --- Buttons ---------------------------------------------------------------
${FORM_SAVE_BUTTON}               role=button[name="Save"]
# TODO: confirm the button text used on edit forms
${FORM_UPDATE_BUTTON}             role=button[name="Edit"]
${FORM_RESET_BUTTON}              role=button[name="Reset"]
${FORM_CANCEL_BUTTON}             role=button[name="Cancel"]
${FORM_BACK_BUTTON}               role=button[name=/Back/]

# --- Toast -----------------------------------------------------------------
${TOAST_CONTAINER}                css=#toast-container
# Regex tolerant of "success" / "succes" spelling: Data created successfully
${TOAST_CREATED_PATTERN}          /Data created succ?ess?fully/i
${TOAST_UPDATED_PATTERN}          /Data updated succ?ess?fully/i


*** Keywords ***
# ===========================================================================
# Buttons
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

# ===========================================================================
# Toast messages
# ===========================================================================
Toast Message Should Be Visible
    [Documentation]    Accepts plain text or a regex such as /Data created .../i
    [Arguments]    ${message}
    Wait For Elements State    ${TOAST_CONTAINER} >> text=${message}    visible

Data Created Toast Should Be Visible
    Toast Message Should Be Visible    ${TOAST_CREATED_PATTERN}

Data Updated Toast Should Be Visible
    Toast Message Should Be Visible    ${TOAST_UPDATED_PATTERN}