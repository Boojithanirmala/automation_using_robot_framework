*** Settings ***
Documentation     Reusable keywords for ng-select dropdowns (single and multi select)
Library           Browser 
Library           Collections
Library           String


*** Variables ***
# --- Dropdown panel & options (global, rendered outside ng-select) ----------
${DROPDOWN_PANEL}                 css=ng-dropdown-panel[role="listbox"]
${DROPDOWN_PANEL_ITEMS}           css=ng-dropdown-panel .ng-dropdown-panel-items
${DROPDOWN_OPTION}                css=ng-dropdown-panel [role="option"]
${DROPDOWN_ENABLED_OPTION}        css=ng-dropdown-panel [role="option"]:not(.ng-option-disabled)
${DROPDOWN_DISABLED_OPTION}       css=ng-dropdown-panel [role="option"].ng-option-disabled
${DROPDOWN_SELECTED_OPTION}       css=ng-dropdown-panel [role="option"].ng-option-selected
${DROPDOWN_MARKED_OPTION}         css=ng-dropdown-panel [role="option"].ng-option-marked
${DROPDOWN_NO_ITEMS_MESSAGE}      xpath=//div[contains(@class,'ng-option-disabled') and normalize-space(.)='No items found']
${DROPDOWN_SELECT_ALL}            xpath=//div[contains(@class,'d-flex') and .//span[normalize-space()='Select All']]
${DROPDOWN_SELECT_ALL_CHECKBOX}   xpath=//div[.//span[normalize-space()='Select All']]//input[@type='checkbox']

# --- Inner ng-select elements (scoped to dropdown locator) ------------------
${DROPDOWN_CONTAINER}             .ng-select-container
${DROPDOWN_INPUT}                 input
${DROPDOWN_COMBOBOX}              [role="combobox"]
${DROPDOWN_VALUE}                 .ng-value
${DROPDOWN_VALUE_LABEL}           .ng-value-label
${DROPDOWN_VALUE_REMOVE_ICON}     .ng-value-icon
${DROPDOWN_PLACEHOLDER}           .ng-placeholder
${DROPDOWN_CLEAR_BUTTON}          .ng-clear-wrapper
${DROPDOWN_ARROW}                 .ng-arrow-wrapper
${DROPDOWN_MORE_VALUE}            .ng-value:has-text("More")
${DROPDOWN_OPTION_CHECKBOX}       input[type="checkbox"]
${DROPDOWN_LOADING_SPINNER}       .ng-spinner-loader


*** Keywords ***
# 1. Open / close / focus

Open Dropdown
    [Arguments]    ${dropdown_locator}
    Click    ${dropdown_locator}
    Wait For Elements State    ${DROPDOWN_PANEL}    visible

Open Dropdown Using Arrow
    [Arguments]    ${dropdown_locator}
    Click    ${dropdown_locator} >> ${DROPDOWN_ARROW}
    Wait For Elements State    ${DROPDOWN_PANEL}    visible

Open Dropdown Using Keyboard
    [Arguments]    ${dropdown_locator}
    Focus    ${dropdown_locator} >> ${DROPDOWN_INPUT}
    Press Keys    ${dropdown_locator} >> ${DROPDOWN_INPUT}    ArrowDown
    Wait For Elements State    ${DROPDOWN_PANEL}    visible

Ensure Dropdown Is Open
    [Documentation]    Opens the dropdown only when it is closed (a click on an open one would close it).
    [Arguments]    ${dropdown_locator}
    ${expanded}=    Get Attribute    ${dropdown_locator} >> ${DROPDOWN_COMBOBOX}    aria-expanded
    IF    '${expanded}' != 'true'
        Open Dropdown    ${dropdown_locator}
    END

Close Dropdown
    [Arguments]    ${dropdown_locator}
    Press Keys    ${dropdown_locator} >> ${DROPDOWN_INPUT}    Escape
    Wait For Elements State    ${DROPDOWN_PANEL}    hidden

Ensure Dropdown Is Closed
    [Documentation]    Closes the dropdown only when it is open.
    [Arguments]    ${dropdown_locator}
    ${expanded}=    Get Attribute    ${dropdown_locator} >> ${DROPDOWN_COMBOBOX}    aria-expanded
    IF    '${expanded}' == 'true'
        Close Dropdown    ${dropdown_locator}
    END

Close Dropdown By Clicking Outside
    [Documentation]    Clicks outside the dropdown (default: body top-left) to blur and close the panel.
    [Arguments]    ${outside_locator}=css=body
    Click    ${outside_locator}    position={"x": 1, "y": 1}
    Wait For Elements State    ${DROPDOWN_PANEL}    hidden

Focus Dropdown
    [Arguments]    ${dropdown_locator}
    Focus    ${dropdown_locator} >> ${DROPDOWN_INPUT}

Dropdown Should Be Open
    [Arguments]    ${dropdown_locator}
    Get Attribute    ${dropdown_locator} >> ${DROPDOWN_COMBOBOX}    aria-expanded    ==    true
    Wait For Elements State    ${DROPDOWN_PANEL}    visible

Dropdown Should Be Closed
    [Arguments]    ${dropdown_locator}
    Get Attribute    ${dropdown_locator} >> ${DROPDOWN_COMBOBOX}    aria-expanded    ==    false
    Wait For Elements State    ${DROPDOWN_PANEL}    hidden

Dropdown Should Be Focused
    [Arguments]    ${dropdown_locator}
    Dropdown Should Have Class    ${dropdown_locator}    ng-select-focused

Dropdown Should Not Be Focused
    [Arguments]    ${dropdown_locator}
    Dropdown Should Not Have Class    ${dropdown_locator}    ng-select-focused

# ===========================================================================
# 2. Select / Deselect (single and multi)
# ===========================================================================
Select Dropdown Option
    [Arguments]    ${dropdown_locator}    ${option_text}
    Ensure Dropdown Is Open    ${dropdown_locator}
    Click    ${DROPDOWN_ENABLED_OPTION}:has-text("${option_text}")

Select Dropdown Option By Search
    [Documentation]    Types the search text, then clicks the option. search_text defaults to the option text.
    [Arguments]    ${dropdown_locator}    ${option_text}    ${search_text}=${option_text}
    Ensure Dropdown Is Open    ${dropdown_locator}
    Search Dropdown Options    ${dropdown_locator}    ${search_text}
    Dropdown Options Should Be Visible    ${option_text}
    Click    ${DROPDOWN_ENABLED_OPTION}:has-text("${option_text}")

Select Multiple Dropdown Options
    [Documentation]    Multi select: searches and clicks every option, then closes the panel.
    ...                Verify the chips afterwards (extra chips may collapse into "+N More...").
    [Arguments]    ${dropdown_locator}    @{option_texts}
    FOR    ${option_text}    IN    @{option_texts}
        Ensure Dropdown Is Open    ${dropdown_locator}
        Search Dropdown Options    ${dropdown_locator}    ${option_text}
        Dropdown Options Should Be Visible    ${option_text}
        Click    ${DROPDOWN_ENABLED_OPTION}:has-text("${option_text}")
    END
    Close Dropdown    ${dropdown_locator}

Select All Dropdown Options
    [Documentation]    Multi select: clicks "Select All" if available in panel, otherwise selects every option.
    [Arguments]    ${dropdown_locator}
    Ensure Dropdown Is Open    ${dropdown_locator}
    ${has_select_all}=    Get Element Count    ${DROPDOWN_SELECT_ALL}
    IF    ${has_select_all} > 0
        Click    ${DROPDOWN_SELECT_ALL}
        Close Dropdown    ${dropdown_locator}
    ELSE
        ${options}=    Get Dropdown Options    ${dropdown_locator}
        Select Multiple Dropdown Options    ${dropdown_locator}    @{options}
    END

Click Dropdown Select All
    [Documentation]    Multi select: opens dropdown if needed and clicks the "Select All" header / option.
    [Arguments]    ${dropdown_locator}
    Ensure Dropdown Is Open    ${dropdown_locator}
    Click    ${DROPDOWN_SELECT_ALL}

# Click Dropdown Deselect All
#     [Documentation]    Multi select: clicks "Unselect All" / "Select All" to deselect all options.
#     [Arguments]    ${dropdown_locator}
#     Ensure Dropdown Is Open    ${dropdown_locator}
#     ${has_unselect}=    Get Element Count    ${DROPDOWN_UNSELECT_ALL}
#     IF    ${has_unselect} > 0
#         Click    ${DROPDOWN_UNSELECT_ALL}
#     ELSE
#         Click    ${DROPDOWN_SELECT_ALL}
#     END

Click Dropdown Deselect All
    [Documentation]    Clicks the Select All element in the multi-select dropdown.
    [Arguments]    ${dropdown_locator}
    Ensure Dropdown Is Open    ${dropdown_locator}
    Click    ${DROPDOWN_SELECT_ALL}


Deselect Dropdown Option
    [Documentation]    Multi select: unselects an option by clicking it in the open panel.
    [Arguments]    ${dropdown_locator}    ${option_text}
    Ensure Dropdown Is Open    ${dropdown_locator}
    Click    ${DROPDOWN_SELECTED_OPTION}:has-text("${option_text}")

Deselect Dropdown Option By Search
    [Documentation]    Multi select: searches and unselects the option in the open panel.
    [Arguments]    ${dropdown_locator}    ${option_text}    ${search_text}=${option_text}
    Ensure Dropdown Is Open    ${dropdown_locator}
    Search Dropdown Options    ${dropdown_locator}    ${search_text}
    Click    ${DROPDOWN_SELECTED_OPTION}:has-text("${option_text}")

Deselect Multiple Dropdown Options
    [Documentation]    Multi select: searches and deselects every listed option.
    [Arguments]    ${dropdown_locator}    @{option_texts}
    FOR    ${option_text}    IN    @{option_texts}
        Deselect Dropdown Option By Search    ${dropdown_locator}    ${option_text}
    END
    Close Dropdown    ${dropdown_locator}

Deselect All Dropdown Options
    [Documentation]    Multi select: deselects all options using clear button or panel deselect control.
    [Arguments]    ${dropdown_locator}
    ${has_clear}=    Get Element Count    ${dropdown_locator} >> ${DROPDOWN_CLEAR_BUTTON}
    IF    ${has_clear} > 0
        Clear Dropdown Selection    ${dropdown_locator}
    ELSE
        Click Dropdown Deselect All    ${dropdown_locator}
        Close Dropdown    ${dropdown_locator}
    END

Select Dropdown Option By Index
    [Documentation]    Index starts at 0 and ignores the disabled placeholder row. -1 selects the last option.
    [Arguments]    ${dropdown_locator}    ${index}=0
    Ensure Dropdown Is Open    ${dropdown_locator}
    Click    ${DROPDOWN_ENABLED_OPTION} >> nth=${index}

Select First Dropdown Option
    [Arguments]    ${dropdown_locator}
    Select Dropdown Option By Index    ${dropdown_locator}    0

Select Last Dropdown Option
    [Arguments]    ${dropdown_locator}
    Select Dropdown Option By Index    ${dropdown_locator}    -1

Select Dropdown Option Using Keyboard
    [Documentation]    Opens the dropdown, presses ArrowDown the given number of times, then Enter.
    ...                With 0 presses it selects the first (highlighted) option.
    [Arguments]    ${dropdown_locator}    ${arrow_down_count}=0
    Ensure Dropdown Is Open    ${dropdown_locator}
    FOR    ${index}    IN RANGE    ${arrow_down_count}
        Press Keys    ${dropdown_locator} >> ${DROPDOWN_INPUT}    ArrowDown
    END
    Press Keys    ${dropdown_locator} >> ${DROPDOWN_INPUT}    Enter

Select Dropdown Option By Typing
    [Documentation]    Types the text and presses Enter to pick the first match.
    [Arguments]    ${dropdown_locator}    ${text}
    Ensure Dropdown Is Open    ${dropdown_locator}
    Fill Text    ${dropdown_locator} >> ${DROPDOWN_INPUT}    ${text}
    Press Keys    ${dropdown_locator} >> ${DROPDOWN_INPUT}    Enter

# ===========================================================================
# 3. Search
# ===========================================================================
Search Dropdown Options
    [Arguments]    ${dropdown_locator}    ${search_text}
    Fill Text    ${dropdown_locator} >> ${DROPDOWN_INPUT}    ${search_text}
    Wait For Elements State    ${DROPDOWN_PANEL}    visible

Clear Dropdown Search
    [Arguments]    ${dropdown_locator}
    Fill Text    ${dropdown_locator} >> ${DROPDOWN_INPUT}    ${EMPTY}

Get Dropdown Search Text
    [Arguments]    ${dropdown_locator}
    ${text}=    Get Property    ${dropdown_locator} >> ${DROPDOWN_INPUT}    value
    RETURN    ${text}

Dropdown Search Text Should Be Empty
    [Arguments]    ${dropdown_locator}
    ${text}=    Get Dropdown Search Text    ${dropdown_locator}
    Should Be Empty    ${text}

Dropdown Search Text Should Be
    [Arguments]    ${dropdown_locator}    ${expected_text}
    ${text}=    Get Dropdown Search Text    ${dropdown_locator}
    Should Be Equal    ${text}    ${expected_text}

Dropdown Search Should Show Option
    [Arguments]    ${dropdown_locator}    ${search_text}    ${expected_option}
    Ensure Dropdown Is Open    ${dropdown_locator}
    Search Dropdown Options    ${dropdown_locator}    ${search_text}
    Dropdown Options Should Be Visible    ${expected_option}
    Clear Dropdown Search    ${dropdown_locator}
    Close Dropdown    ${dropdown_locator}

Dropdown Search Results Should Match
    [Documentation]    Every option left after searching must contain the search text (case insensitive).
    [Arguments]    ${dropdown_locator}    ${search_text}
    Ensure Dropdown Is Open    ${dropdown_locator}
    Search Dropdown Options    ${dropdown_locator}    ${search_text}
    ${options}=    Get Visible Dropdown Options
    Should Not Be Empty    ${options}
    FOR    ${option}    IN    @{options}
        Should Contain    ${option}    ${search_text}    ignore_case=True
    END
    Clear Dropdown Search    ${dropdown_locator}
    Close Dropdown    ${dropdown_locator}

Dropdown Search Should Return No Options
    [Arguments]    ${dropdown_locator}    ${search_text}
    Ensure Dropdown Is Open    ${dropdown_locator}
    Search Dropdown Options    ${dropdown_locator}    ${search_text}
    Get Element Count    ${DROPDOWN_ENABLED_OPTION}    ==    0
    Clear Dropdown Search    ${dropdown_locator}
    Close Dropdown    ${dropdown_locator}

Dropdown No Items Message Should Be Visible
    [Documentation]    Use while the panel is open after a search with no match.
    Wait For Elements State    ${DROPDOWN_NO_ITEMS_MESSAGE}    visible

Dropdown No Items Message Should Not Be Visible
    Wait For Elements State    ${DROPDOWN_NO_ITEMS_MESSAGE}    hidden

# ===========================================================================
# 4. Read / verify the options
# ===========================================================================
Dropdown Options Should Be Visible
    [Documentation]    Checks the open panel (includes the disabled placeholder row).
    [Arguments]    @{expected_options}
    FOR    ${option}    IN    @{expected_options}
        ${count}=    Get Element Count    ${DROPDOWN_OPTION}:has-text("${option}")
        Should Be True    ${count} > 0
    END

Dropdown Options Should Not Be Visible
    [Documentation]    Checks options are not present in the open panel.
    [Arguments]    @{unexpected_options}
    FOR    ${option}    IN    @{unexpected_options}
        ${count}=    Get Element Count    ${DROPDOWN_OPTION}:has-text("${option}")
        Should Be Equal As Integers    ${count}    0
    END

Get Visible Dropdown Options
    [Documentation]    Returns the enabled option texts of the panel that is currently open.
    ${elements}=    Get Elements    ${DROPDOWN_ENABLED_OPTION}
    ${options}=    Create List
    FOR    ${element}    IN    @{elements}
        ${text}=    Get Text    ${element}
        ${text}=    Strip String    ${text}
        Append To List    ${options}    ${text}
    END
    RETURN    ${options}

Get Dropdown Options
    [Documentation]    Opens the dropdown if needed, returns the enabled option texts and closes it.
    ...                Works when the list is empty (the panel may only hold the disabled placeholder).
    [Arguments]    ${dropdown_locator}
    Ensure Dropdown Is Open    ${dropdown_locator}
    Run Keyword And Ignore Error
    ...    Wait For Elements State    ${DROPDOWN_PANEL}    visible    timeout=3s
    ${options}=    Get Visible Dropdown Options
    Close Dropdown    ${dropdown_locator}
    RETURN    ${options}

Get Dropdown Option Count
    [Arguments]    ${dropdown_locator}
    ${options}=    Get Dropdown Options    ${dropdown_locator}
    ${count}=    Get Length    ${options}
    RETURN    ${count}

Dropdown Option Count Should Be
    [Arguments]    ${dropdown_locator}    ${expected_count}
    ${count}=    Get Dropdown Option Count    ${dropdown_locator}
    Should Be Equal As Integers    ${count}    ${expected_count}

Dropdown Options Should Contain
    [Arguments]    ${dropdown_locator}    @{expected_options}
    ${options}=    Get Dropdown Options    ${dropdown_locator}
    FOR    ${expected}    IN    @{expected_options}
        List Should Contain Value    ${options}    ${expected}
    END

Dropdown Options Should Not Contain
    [Arguments]    ${dropdown_locator}    @{unexpected_options}
    ${options}=    Get Dropdown Options    ${dropdown_locator}
    FOR    ${unexpected}    IN    @{unexpected_options}
        List Should Not Contain Value    ${options}    ${unexpected}
    END

Dropdown Options Should Be Empty
    [Arguments]    ${dropdown_locator}
    ${options}=    Get Dropdown Options    ${dropdown_locator}
    Should Be Empty    ${options}

Dropdown Options Should Not Be Empty
    [Arguments]    ${dropdown_locator}
    ${options}=    Get Dropdown Options    ${dropdown_locator}
    Should Not Be Empty    ${options}

Dropdown Options Should Be
    [Documentation]    Exact list, same order.
    [Arguments]    ${dropdown_locator}    @{expected_options}
    ${options}=    Get Dropdown Options    ${dropdown_locator}
    Lists Should Be Equal    ${options}    ${expected_options}

Dropdown Options Should Be Sorted
    [Documentation]    Ascending (default) or descending, case insensitive.
    [Arguments]    ${dropdown_locator}    ${order}=ascending
    ${options}=    Get Dropdown Options    ${dropdown_locator}
    IF    '${order.lower()}' == 'descending'
        ${is_sorted}=    Evaluate    $options == sorted($options, key=str.lower, reverse=True)
        Should Be True    ${is_sorted}    Options are not sorted descending: ${options}
    ELSE
        ${is_sorted}=    Evaluate    $options == sorted($options, key=str.lower)
        Should Be True    ${is_sorted}    Options are not sorted ascending: ${options}
    END

Dropdown Options Should Not Have Duplicates
    [Arguments]    ${dropdown_locator}
    ${options}=    Get Dropdown Options    ${dropdown_locator}
    ${has_no_duplicates}=    Evaluate    len(set($options)) == len($options)
    Should Be True    ${has_no_duplicates}    Duplicate options found: ${options}

Dropdown Placeholder Option Should Be
    [Documentation]    The disabled first row of the panel, e.g. "Select Salary Group".
    [Arguments]    ${dropdown_locator}    ${expected_text}
    Ensure Dropdown Is Open    ${dropdown_locator}
    ${text}=    Get Text    ${DROPDOWN_DISABLED_OPTION} >> nth=0
    ${text}=    Strip String    ${text}
    Close Dropdown    ${dropdown_locator}
    Should Be Equal    ${text}    ${expected_text}

Dropdown Option Should Exist
    [Documentation]    Opens dropdown if needed and checks that the option exists in the list.
    [Arguments]    ${dropdown_locator}    ${option_text}
    Ensure Dropdown Is Open    ${dropdown_locator}
    Wait For Elements State    ${DROPDOWN_OPTION}:has-text("${option_text}")    visible
    Close Dropdown    ${dropdown_locator}

Dropdown Option Should Not Exist
    [Documentation]    Opens dropdown if needed and checks that the option does not exist in the list.
    [Arguments]    ${dropdown_locator}    ${option_text}
    Ensure Dropdown Is Open    ${dropdown_locator}
    ${count}=    Get Element Count    ${DROPDOWN_OPTION}:has-text("${option_text}")
    Should Be Equal As Integers    ${count}    0
    Close Dropdown    ${dropdown_locator}

Dropdown Option Should Be Enabled
    [Documentation]    Checks that a specific option in the panel is enabled.
    [Arguments]    ${dropdown_locator}    ${option_text}
    Ensure Dropdown Is Open    ${dropdown_locator}
    Wait For Elements State    ${DROPDOWN_ENABLED_OPTION}:has-text("${option_text}")    visible
    Close Dropdown    ${dropdown_locator}

Dropdown Option Should Be Disabled
    [Documentation]    Checks that a specific option in the panel is disabled.
    [Arguments]    ${dropdown_locator}    ${option_text}
    Ensure Dropdown Is Open    ${dropdown_locator}
    Wait For Elements State    ${DROPDOWN_DISABLED_OPTION}:has-text("${option_text}")    visible
    Close Dropdown    ${dropdown_locator}

Dropdown Option Should Be Marked As Selected
    [Documentation]    Checks the highlight on the option inside the open panel.
    [Arguments]    ${dropdown_locator}    ${option_text}
    Ensure Dropdown Is Open    ${dropdown_locator}
    Wait For Elements State    ${DROPDOWN_SELECTED_OPTION}:has-text("${option_text}")    visible
    Close Dropdown    ${dropdown_locator}

Dropdown Option Should Not Be Marked As Selected
    [Documentation]    Checks that the option inside the open panel is not marked as selected.
    [Arguments]    ${dropdown_locator}    ${option_text}
    Ensure Dropdown Is Open    ${dropdown_locator}
    ${count}=    Get Element Count    ${DROPDOWN_SELECTED_OPTION}:has-text("${option_text}")
    Should Be Equal As Integers    ${count}    0
    Close Dropdown    ${dropdown_locator}

Dropdown Option Checkbox Should Be Checked
    [Documentation]    Multi select: checks that the checkbox inside the option is checked.
    [Arguments]    ${dropdown_locator}    ${option_text}
    Ensure Dropdown Is Open    ${dropdown_locator}
    Get Checkbox State    ${DROPDOWN_OPTION}:has-text("${option_text}") >> ${DROPDOWN_OPTION_CHECKBOX}    ==    checked
    Close Dropdown    ${dropdown_locator}

Dropdown Option Checkbox Should Not Be Checked
    [Documentation]    Multi select: checks that the checkbox inside the option is unchecked.
    [Arguments]    ${dropdown_locator}    ${option_text}
    Ensure Dropdown Is Open    ${dropdown_locator}
    Get Checkbox State    ${DROPDOWN_OPTION}:has-text("${option_text}") >> ${DROPDOWN_OPTION_CHECKBOX}    ==    unchecked
    Close Dropdown    ${dropdown_locator}

Scroll Dropdown To Option
    [Documentation]    Scrolls the open panel until the given option is visible (for virtual scroll).
    [Arguments]    ${option_text}
    Scroll To Element    ${DROPDOWN_OPTION}:has-text("${option_text}")
    Wait For Elements State    ${DROPDOWN_OPTION}:has-text("${option_text}")    visible

Scroll Dropdown Panel To Bottom
    [Documentation]    Scrolls the open panel to bottom (useful for lazy loaded options).
    Scroll By    ${DROPDOWN_PANEL_ITEMS}    vertical=100%

Scroll Dropdown Panel To Top
    [Documentation]    Scrolls the open panel back to top.
    Scroll By    ${DROPDOWN_PANEL_ITEMS}    vertical=0

# ===========================================================================
# 5. Selected value(s)
# ===========================================================================
Get Dropdown Selected Value
    [Documentation]    Returns the text of the selected value for single-select dropdowns (or empty string if none).
    [Arguments]    ${dropdown_locator}
    ${count}=    Get Element Count    ${dropdown_locator} >> ${DROPDOWN_VALUE_LABEL}
    IF    ${count} == 0
        RETURN    ${EMPTY}
    END
    ${text}=    Get Text    ${dropdown_locator} >> ${DROPDOWN_VALUE_LABEL} >> nth=0
    ${text}=    Strip String    ${text}
    RETURN    ${text}

Dropdown Selected Value Should Be
    [Documentation]    Exact text check for single-select dropdown.
    [Arguments]    ${dropdown_locator}    ${expected_text}
    ${actual}=    Get Dropdown Selected Value    ${dropdown_locator}
    Should Be Equal    ${actual}    ${expected_text}

Dropdown Selected Value Should Contain
    [Arguments]    ${dropdown_locator}    ${expected_substring}
    ${actual}=    Get Dropdown Selected Value    ${dropdown_locator}
    Should Contain    ${actual}    ${expected_substring}

Dropdown Selected Value Should Not Contain
    [Arguments]    ${dropdown_locator}    ${unexpected_substring}
    ${actual}=    Get Dropdown Selected Value    ${dropdown_locator}
    Should Not Contain    ${actual}    ${unexpected_substring}

Dropdown Should Have Selected Value
    [Arguments]    ${dropdown_locator}    ${expected_text}
    Wait For Elements State    ${dropdown_locator} >> ${DROPDOWN_VALUE_LABEL}:has-text("${expected_text}")    visible

Dropdown Should Not Have Selected Value
    [Arguments]    ${dropdown_locator}    ${text}
    Wait For Elements State    ${dropdown_locator} >> ${DROPDOWN_VALUE_LABEL}:has-text("${text}")    detached

Dropdown Should Have No Selected Value
    [Arguments]    ${dropdown_locator}
    Wait For Elements State    ${dropdown_locator} >> ${DROPDOWN_VALUE_LABEL}    detached

Dropdown Should Have Selected Values
    [Arguments]    ${dropdown_locator}    @{expected_values}
    FOR    ${expected}    IN    @{expected_values}
        Dropdown Should Have Selected Value    ${dropdown_locator}    ${expected}
    END

Get Dropdown Selected Values
    [Documentation]    Texts of the chips / value that are currently shown.
    [Arguments]    ${dropdown_locator}
    ${elements}=    Get Elements    ${dropdown_locator} >> ${DROPDOWN_VALUE_LABEL}
    ${values}=    Create List
    FOR    ${element}    IN    @{elements}
        ${text}=    Get Text    ${element}
        ${text}=    Strip String    ${text}
        Append To List    ${values}    ${text}
    END
    RETURN    ${values}

Dropdown Selected Values Should Be
    [Documentation]    Exact set of shown values, order ignored.
    [Arguments]    ${dropdown_locator}    @{expected_values}
    ${values}=    Get Dropdown Selected Values    ${dropdown_locator}
    Lists Should Be Equal    ${values}    ${expected_values}    ignore_order=True

Get Dropdown Selected Value Count
    [Arguments]    ${dropdown_locator}
    ${count}=    Get Element Count    ${dropdown_locator} >> ${DROPDOWN_VALUE_LABEL}
    RETURN    ${count}

Dropdown Selected Value Count Should Be
    [Arguments]    ${dropdown_locator}    ${expected_count}
    Get Element Count    ${dropdown_locator} >> ${DROPDOWN_VALUE_LABEL}    ==    ${expected_count}

Get Dropdown More Values Count
    [Documentation]    Number from the "+5 More..." chip, or 0 when there is no such chip.
    [Arguments]    ${dropdown_locator}
    ${chips}=    Get Element Count    ${dropdown_locator} >> ${DROPDOWN_MORE_VALUE}
    IF    ${chips} == 0
        RETURN    ${0}
    END
    ${text}=    Get Text    ${dropdown_locator} >> ${DROPDOWN_MORE_VALUE}
    ${number}=    Evaluate    int(re.search(r'\\d+', $text).group())    modules=re
    RETURN    ${number}

Dropdown More Values Count Should Be
    [Arguments]    ${dropdown_locator}    ${expected_count}
    ${count}=    Get Dropdown More Values Count    ${dropdown_locator}
    Should Be Equal As Integers    ${count}    ${expected_count}

Dropdown More Values Chip Should Be Visible
    [Arguments]    ${dropdown_locator}
    Wait For Elements State    ${dropdown_locator} >> ${DROPDOWN_MORE_VALUE}    visible

Dropdown More Values Chip Should Not Be Visible
    [Arguments]    ${dropdown_locator}
    Wait For Elements State    ${dropdown_locator} >> ${DROPDOWN_MORE_VALUE}    hidden

Get Dropdown Total Selected Count
    [Documentation]    Shown chips plus the hidden "+N More..." count.
    [Arguments]    ${dropdown_locator}
    ${shown}=    Get Dropdown Selected Value Count    ${dropdown_locator}
    ${more}=    Get Dropdown More Values Count    ${dropdown_locator}
    ${total}=    Evaluate    ${shown} + ${more}
    RETURN    ${total}

Dropdown Total Selected Count Should Be
    [Arguments]    ${dropdown_locator}    ${expected_count}
    ${total}=    Get Dropdown Total Selected Count    ${dropdown_locator}
    Should Be Equal As Integers    ${total}    ${expected_count}

Get Dropdown Placeholder
    [Arguments]    ${dropdown_locator}
    ${text}=    Get Text    ${dropdown_locator} >> ${DROPDOWN_PLACEHOLDER}
    ${text}=    Strip String    ${text}
    RETURN    ${text}

Dropdown Placeholder Should Be
    [Arguments]    ${dropdown_locator}    ${expected_text}
    Get Text    ${dropdown_locator} >> ${DROPDOWN_PLACEHOLDER}    ==    ${expected_text}

Dropdown Placeholder Should Contain
    [Arguments]    ${dropdown_locator}    ${expected_text}
    ${actual}=    Get Dropdown Placeholder    ${dropdown_locator}
    Should Contain    ${actual}    ${expected_text}

Dropdown Placeholder Should Not Be Visible
    [Arguments]    ${dropdown_locator}
    Wait For Elements State    ${dropdown_locator} >> ${DROPDOWN_PLACEHOLDER}    hidden

# ===========================================================================
# 6. Remove / clear
# ===========================================================================
Remove Selected Value
    [Arguments]    ${dropdown_locator}    ${value_text}
    Click
    ...    ${dropdown_locator} >> ${DROPDOWN_VALUE}:has(${DROPDOWN_VALUE_LABEL}:has-text("${value_text}")) >> ${DROPDOWN_VALUE_REMOVE_ICON}

Remove Selected Values
    [Arguments]    ${dropdown_locator}    @{value_texts}
    FOR    ${value_text}    IN    @{value_texts}
        Remove Selected Value    ${dropdown_locator}    ${value_text}
        Dropdown Should Not Have Selected Value    ${dropdown_locator}    ${value_text}
    END

Press Backspace In Dropdown
    [Documentation]    Removes the last selected value of a multi select.
    [Arguments]    ${dropdown_locator}
    Click    ${dropdown_locator} >> ${DROPDOWN_INPUT}
    Press Keys    ${dropdown_locator} >> ${DROPDOWN_INPUT}    Backspace

Clear Dropdown Selection
    [Documentation]    Clicks the clear (x) button and checks nothing is selected.
    [Arguments]    ${dropdown_locator}
    Hover    ${dropdown_locator}
    Click    ${dropdown_locator} >> ${DROPDOWN_CLEAR_BUTTON}
    Dropdown Should Have No Selected Value    ${dropdown_locator}

Ensure Dropdown Selection Is Cleared
    [Documentation]    Clears selection if any value is selected; does nothing if already empty.
    [Arguments]    ${dropdown_locator}
    ${count}=    Get Element Count    ${dropdown_locator} >> ${DROPDOWN_VALUE_LABEL}
    IF    ${count} > 0
        Clear Dropdown Selection    ${dropdown_locator}
    END

Dropdown Clear Button Should Be Visible
    [Arguments]    ${dropdown_locator}
    Hover    ${dropdown_locator}
    Wait For Elements State    ${dropdown_locator} >> ${DROPDOWN_CLEAR_BUTTON}    visible

Dropdown Clear Button Should Not Be Visible
    [Arguments]    ${dropdown_locator}
    Hover    ${dropdown_locator}
    Wait For Elements State    ${dropdown_locator} >> ${DROPDOWN_CLEAR_BUTTON}    hidden

# ===========================================================================
# 7. State (enabled, disabled, invalid, required, loading, type)
# ===========================================================================
Dropdown Should Have Class
    [Documentation]    Checks a class on the ng-select element itself.
    [Arguments]    ${dropdown_locator}    ${class_name}
    ${classes}=    Get Classes    ${dropdown_locator}
    ${found}=    Evaluate    $class_name in [c for item in $classes for c in item.split()]
    Should Be True    ${found}    ${dropdown_locator} does not have class ${class_name}. Classes: ${classes}

Dropdown Should Not Have Class
    [Arguments]    ${dropdown_locator}    ${class_name}
    ${classes}=    Get Classes    ${dropdown_locator}
    ${found}=    Evaluate    $class_name in [c for item in $classes for c in item.split()]
    Should Not Be True    ${found}    ${dropdown_locator} has class ${class_name}

Dropdown Should Be Visible
    [Arguments]    ${dropdown_locator}
    Wait For Elements State    ${dropdown_locator}    visible

Dropdown Should Not Be Visible
    [Arguments]    ${dropdown_locator}
    Wait For Elements State    ${dropdown_locator}    hidden

Dropdown Should Be Disabled
    [Arguments]    ${dropdown_locator}
    Dropdown Should Have Class    ${dropdown_locator}    ng-select-disabled

Dropdown Should Be Enabled
    [Arguments]    ${dropdown_locator}
    Dropdown Should Not Have Class    ${dropdown_locator}    ng-select-disabled

Dropdown Should Be Invalid
    [Documentation]    Angular form state: required / validation error shown.
    [Arguments]    ${dropdown_locator}
    Dropdown Should Have Class    ${dropdown_locator}    ng-invalid

Dropdown Should Be Valid
    [Arguments]    ${dropdown_locator}
    Dropdown Should Not Have Class    ${dropdown_locator}    ng-invalid

Dropdown Should Be Required
    [Documentation]    Checks if the dropdown or its inner combobox/input has required attribute or aria-required.
    [Arguments]    ${dropdown_locator}
    ${has_required_attr}=    Get Element Count    ${dropdown_locator}[required], ${dropdown_locator} >> input[required]
    ${aria_required}=    Get Attribute    ${dropdown_locator} >> ${DROPDOWN_COMBOBOX}    aria-required
    ${is_required}=    Evaluate    ${has_required_attr} > 0 or '${aria_required}' == 'true'
    Should Be True    ${is_required}    Dropdown ${dropdown_locator} is not marked as required.

Dropdown Should Not Be Required
    [Arguments]    ${dropdown_locator}
    ${has_required_attr}=    Get Element Count    ${dropdown_locator}[required], ${dropdown_locator} >> input[required]
    ${aria_required}=    Get Attribute    ${dropdown_locator} >> ${DROPDOWN_COMBOBOX}    aria-required
    ${is_required}=    Evaluate    ${has_required_attr} > 0 or '${aria_required}' == 'true'
    Should Not Be True    ${is_required}    Dropdown ${dropdown_locator} is marked as required.

Dropdown Should Be Searchable
    [Arguments]    ${dropdown_locator}
    Dropdown Should Have Class    ${dropdown_locator}    ng-select-searchable

Dropdown Should Not Be Searchable
    [Arguments]    ${dropdown_locator}
    Dropdown Should Not Have Class    ${dropdown_locator}    ng-select-searchable

Dropdown Should Be Clearable
    [Arguments]    ${dropdown_locator}
    Dropdown Should Have Class    ${dropdown_locator}    ng-select-clearable

Dropdown Should Not Be Clearable
    [Arguments]    ${dropdown_locator}
    Dropdown Should Not Have Class    ${dropdown_locator}    ng-select-clearable

Dropdown Should Be Multi Select
    [Arguments]    ${dropdown_locator}
    Dropdown Should Have Class    ${dropdown_locator}    ng-select-multiple

Dropdown Should Be Single Select
    [Arguments]    ${dropdown_locator}
    Dropdown Should Have Class    ${dropdown_locator}    ng-select-single

Dropdown Should Be Loading
    [Arguments]    ${dropdown_locator}
    Dropdown Should Have Class    ${dropdown_locator}    ng-select-loading

Dropdown Should Not Be Loading
    [Arguments]    ${dropdown_locator}
    Dropdown Should Not Have Class    ${dropdown_locator}    ng-select-loading

Wait Until Dropdown Is Loaded
    [Documentation]    For dropdowns that load their options from the server.
    [Arguments]    ${dropdown_locator}    ${timeout}=10s
    Wait Until Keyword Succeeds    ${timeout}    200ms
    ...    Dropdown Should Not Have Class    ${dropdown_locator}    ng-select-loading

Wait Until Dropdown Is Enabled
    [Documentation]    For dependent dropdowns that stay disabled until another field is filled.
    [Arguments]    ${dropdown_locator}    ${timeout}=10s
    Wait Until Keyword Succeeds    ${timeout}    200ms
    ...    Dropdown Should Be Enabled    ${dropdown_locator}

Wait Until Dropdown Option Is Available
    [Documentation]    For cascading dropdowns: retries until the option shows up in the list.
    [Arguments]    ${dropdown_locator}    ${option_text}    ${timeout}=10s
    Wait Until Keyword Succeeds    ${timeout}    1s
    ...    Dropdown Options Should Contain    ${dropdown_locator}    ${option_text}

# ===========================================================================
# 8. Keyboard & Highlights
# ===========================================================================
Press Key In Dropdown
    [Documentation]    Any Playwright key, e.g. ArrowDown, ArrowUp, Enter, Escape, Tab, Backspace.
    [Arguments]    ${dropdown_locator}    ${key}
    Press Keys    ${dropdown_locator} >> ${DROPDOWN_INPUT}    ${key}

Get Dropdown Highlighted Option
    [Documentation]    Returns the text of the option marked by keyboard navigation.
    ${text}=    Get Text    ${DROPDOWN_MARKED_OPTION}
    ${text}=    Strip String    ${text}
    RETURN    ${text}

Dropdown Highlighted Option Should Be
    [Documentation]    The option marked by the keyboard (ng-option-marked) in the open panel.
    [Arguments]    ${option_text}
    Wait For Elements State    ${DROPDOWN_MARKED_OPTION}:has-text("${option_text}")    visible