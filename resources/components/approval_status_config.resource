*** Settings ***
Documentation    Reusable keywords for the "Approval Status Name" modal (dynamic display names per level).
Library          Browser
Library          String
Library          Collections


*** Variables ***
${STATUS_MODAL}                 xpath=//button[@title='Approval Status Name Details']
${STATUS_LEVEL_DROPDOWN}        ${STATUS_MODAL} >> text=Select Level
${STATUS_DISPLAY_NAME_INPUT}    ${STATUS_MODAL} >> css=input[placeholder="Enter Display Name"]
${STATUS_SAVE_BTN}              ${STATUS_MODAL} >> xpath=.//button[@type='submit' and normalize-space()='Save']
${STATUS_RESET_BTN}             ${STATUS_MODAL} >> xpath=.//button[@type='button' and normalize-space()='Reset']
${STATUS_CLOSE_BTN}             ${STATUS_MODAL} >> css=button.btn-close

${STATUS_GRID_LEVEL_CELLS}      ${STATUS_MODAL} >> css=[role="row"] [col-id="level"]
${STATUS_GRID_NAME_CELLS}       ${STATUS_MODAL} >> css=[role="row"] [col-id="displayName"]


*** Keywords ***
Open Approval Status Modal
    [Documentation]    Clicks the trigger that opens the status name modal for the approval workflow record.
    [Arguments]    ${trigger_locator}
    Click    ${trigger_locator}
    Wait For Elements State    ${STATUS_MODAL}    visible


Close Approval Status Modal
    [Documentation]    Closes the status name modal.
    Click    ${STATUS_CLOSE_BTN}
    Wait For Elements State    ${STATUS_MODAL}    hidden


Select Status Level
    [Documentation]    Selects a level in the modal's Levels dropdown.
    [Arguments]    ${level}
    Click    ${STATUS_LEVEL_DROPDOWN}
    Click    css=[role="option"]:text-is("${level}")


Set Approval Status Display Name
    [Documentation]    Sets the display name for a level and saves it, then verifies it appears in the grid.
    [Arguments]    ${level}    ${display_name}
    Select Status Level    ${level}
    Fill Text    ${STATUS_DISPLAY_NAME_INPUT}    ${display_name}
    Click    ${STATUS_SAVE_BTN}
    Approval Status Display Name Should Be    ${level}    ${display_name}


Reset Approval Status Form
    [Documentation]    Clicks Reset to clear the level and display name inputs.
    Click    ${STATUS_RESET_BTN}
    Get Property    ${STATUS_DISPLAY_NAME_INPUT}    value    ==    ${EMPTY}


Get Configured Display Names
    [Documentation]    Reads the modal grid and returns a dictionary {LEVEL: display name}.
    ...                Level keys are upper-cased (L1, L2, DRAFT, APPROVED) so they match the level names used in tests.
    ${count}=    Get Element Count    ${STATUS_GRID_LEVEL_CELLS}
    ${names}=    Create Dictionary
    FOR    ${i}    IN RANGE    ${count}
        ${level}=    Get Text    ${STATUS_GRID_LEVEL_CELLS} >> nth=${i}
        ${name}=     Get Text    ${STATUS_GRID_NAME_CELLS} >> nth=${i}
        ${key}=      Convert To Upper Case    ${level}
        Set To Dictionary    ${names}    ${key}=${name}
    END
    RETURN    ${names}


Approval Status Display Name Should Be
    [Documentation]    Verifies the grid shows the expected display name for the level.
    [Arguments]    ${level}    ${expected_name}
    ${names}=    Get Configured Display Names
    ${key}=    Convert To Upper Case    ${level}
    Dictionary Should Contain Key    ${names}    ${key}
    Should Be Equal    ${names}[${key}]    ${expected_name}


Approval Status Level Should Not Be Configured
    [Documentation]    Verifies the level has no row in the grid (so the default level name is used).
    [Arguments]    ${level}
    ${names}=    Get Configured Display Names
    ${key}=    Convert To Upper Case    ${level}
    Dictionary Should Not Contain Key    ${names}    ${key}