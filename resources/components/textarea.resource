*** Settings ***
Documentation    Reusable keywords for <textarea> fields in the dynamic forms
Library          Browser


*** Keywords ***
Fill Textarea
    [Documentation]    Replaces the textarea value with the supplied text and verifies it.
    [Arguments]    ${textarea_locator}    ${text}
    Fill Text    ${textarea_locator}    ${text}
    Textarea Value Should Be    ${textarea_locator}    ${text}


Clear Textarea
    [Documentation]    Clears the textarea and verifies that it is empty.
    [Arguments]    ${textarea_locator}
    Clear Text    ${textarea_locator}
    Textarea Value Should Be Empty    ${textarea_locator}


Get Textarea Value
    [Documentation]    Returns the textarea's current value.
    [Arguments]    ${textarea_locator}
    ${value}=    Get Property    ${textarea_locator}    value
    RETURN    ${value}


Textarea Value Should Be
    [Documentation]    Verifies that the textarea value exactly matches the expected text.
    [Arguments]    ${textarea_locator}    ${expected}
    Get Property    ${textarea_locator}    value    ==    ${expected}


Textarea Value Should Be Empty
    [Documentation]    Verifies that the textarea value is empty.
    [Arguments]    ${textarea_locator}
    Get Property    ${textarea_locator}    value    ==    ${EMPTY}


Textarea Value Should Not Be Empty
    [Documentation]    Verifies that the textarea contains at least one character.
    [Arguments]    ${textarea_locator}
    ${value}=    Get Textarea Value    ${textarea_locator}
    Should Not Be Empty    ${value}


Textarea Value Should Contain
    [Documentation]    Verifies that the textarea value contains the expected text.
    [Arguments]    ${textarea_locator}    ${expected_text}
    Get Property    ${textarea_locator}    value    *=    ${expected_text}


Textarea Should Be Visible
    [Documentation]    Waits until the textarea is visible.
    [Arguments]    ${textarea_locator}
    Wait For Elements State    ${textarea_locator}    visible


Textarea Should Not Be Visible
    [Documentation]    Waits until the textarea is hidden.
    [Arguments]    ${textarea_locator}
    Wait For Elements State    ${textarea_locator}    hidden


Textarea Should Be Enabled
    [Documentation]    Verifies that the textarea is enabled.
    [Arguments]    ${textarea_locator}
    Get Property    ${textarea_locator}    disabled    ==    ${False}


Textarea Should Be Disabled
    [Documentation]    Verifies that the textarea is disabled.
    [Arguments]    ${textarea_locator}
    Get Property    ${textarea_locator}    disabled    ==    ${True}


Textarea Should Be Required
    [Documentation]    Verifies that the textarea has the HTML required property.
    [Arguments]    ${textarea_locator}
    Get Property    ${textarea_locator}    required    ==    ${True}
