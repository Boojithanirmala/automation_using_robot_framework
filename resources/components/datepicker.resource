*** Settings ***
Documentation     Reusable keywords for the flatpickr month picker (monthSelect plugin).
Library           Browser
Library           Collections
Library           String


*** Variables ***
# --- Calendar panel (global, only the open one) ------------------------------
${DATEPICKER_PANEL}               css=.flatpickr-calendar.open
${DATEPICKER_YEAR_INPUT}          css=.flatpickr-calendar.open input.cur-year
${DATEPICKER_YEAR_UP}             css=.flatpickr-calendar.open .numInputWrapper .arrowUp
${DATEPICKER_YEAR_DOWN}           css=.flatpickr-calendar.open .numInputWrapper .arrowDown
${DATEPICKER_PREVIOUS}            css=.flatpickr-calendar.open .flatpickr-prev-month
${DATEPICKER_NEXT}                css=.flatpickr-calendar.open .flatpickr-next-month
${DATEPICKER_MONTH}               css=.flatpickr-calendar.open .flatpickr-monthSelect-month
${DATEPICKER_SELECTED_MONTH}      css=.flatpickr-calendar.open .flatpickr-monthSelect-month.selected
${DATEPICKER_TODAY_MONTH}         css=.flatpickr-calendar.open .flatpickr-monthSelect-month.today
${DATEPICKER_DISABLED_MONTH}      css=.flatpickr-calendar.open .flatpickr-monthSelect-month.flatpickr-disabled

# --- Elements around the input (scoped: picker >> group >> element) ----------
${DATEPICKER_GROUP}               xpath=ancestor::div[contains(@class,'input-group')][1]
${DATEPICKER_ICON}                .ri-calendar-line
${DATEPICKER_CLEAR_BUTTON}        .input-group-text:has(i.bi-x)

&{MONTH_NUMBERS}                  Jan=01    Feb=02    Mar=03    Apr=04    May=05    Jun=06
...                               Jul=07    Aug=08    Sep=09    Oct=10    Nov=11    Dec=12


*** Keywords ***
# ===========================================================================
# 1. Open / close
# ===========================================================================
Open Month Picker
    [Arguments]    ${picker_locator}
    Click    ${picker_locator}
    Wait For Elements State    ${DATEPICKER_PANEL}    visible

Open Month Picker Using Icon
    [Arguments]    ${picker_locator}
    Click    ${picker_locator} >> ${DATEPICKER_GROUP} >> ${DATEPICKER_ICON}
    Wait For Elements State    ${DATEPICKER_PANEL}    visible

Ensure Month Picker Is Open
    [Documentation]    Opens the picker only when it is closed.
    [Arguments]    ${picker_locator}
    ${open}=    Get Element Count    ${DATEPICKER_PANEL}
    IF    ${open} == 0
        Open Month Picker    ${picker_locator}
    END

Close Month Picker
    [Documentation]    Clicks outside the picker (body top-left) to close the panel.
    Click With Options    css=body    position_x=1    position_y=1
    Wait For Elements State    ${DATEPICKER_PANEL}    hidden

Ensure Month Picker Is Closed
    ${open}=    Get Element Count    ${DATEPICKER_PANEL}
    IF    ${open} > 0
        Close Month Picker
    END

Month Picker Should Be Open
    Wait For Elements State    ${DATEPICKER_PANEL}    visible

Month Picker Should Be Closed
    Wait For Elements State    ${DATEPICKER_PANEL}    hidden

# ===========================================================================
# 2. Select a month
# ===========================================================================
Select Month Picker Month
    [Documentation]    Month may be the full name or the 3-letter short name. When a year is given
    ...                it is set first and the resulting value (YYYY-MM) is verified.
    [Arguments]    ${picker_locator}    ${month}    ${year}=${EMPTY}
    Ensure Month Picker Is Open    ${picker_locator}
    IF    '${year}' != ''
        Set Month Picker Year    ${picker_locator}    ${year}
        # Fill Text    ${DATEPICKER_YEAR_INPUT}    ${year}
        # ${year_after_fill}=    Get Property    ${DATEPICKER_YEAR_INPUT}    value
        # Log    Year after setting: ${year_after_fill}
    END
    ${short}=    Evaluate    $month[:3].title()
    Click    ${DATEPICKER_MONTH}:text-is("${short}")
    IF    '${year}' != ''
        ${number}=    Get From Dictionary    ${MONTH_NUMBERS}    ${short}
        Month Picker Value Should Be    ${picker_locator}    ${year}-${number}
    END

Select Month Picker Month By Number
    [Documentation]    Number 1-12.
    [Arguments]    ${picker_locator}    ${month_number}    ${year}=${EMPTY}
    ${short}=    Evaluate    ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'][int($month_number) - 1]
    Select Month Picker Month    ${picker_locator}    ${short}    ${year}

Select Current Month In Month Picker
    [Documentation]    Clicks the month highlighted as "today" in the panel (needs the current year shown).
    [Arguments]    ${picker_locator}
    Ensure Month Picker Is Open    ${picker_locator}
    Click    ${DATEPICKER_TODAY_MONTH}

# ===========================================================================
# 3. Year navigation
# ===========================================================================
Get Month Picker Displayed Year
    [Documentation]    Year currently shown in the open panel.
    [Arguments]    ${picker_locator}
    Ensure Month Picker Is Open    ${picker_locator}
    ${year}=    Get Property    ${DATEPICKER_YEAR_INPUT}    value
    RETURN    ${year}

Set Month Picker Year
    [Arguments]    ${picker_locator}    ${year}
    Ensure Month Picker Is Open    ${picker_locator}
    # Fill Text    ${DATEPICKER_YEAR_INPUT}    ${year}
    # Press Keys    ${DATEPICKER_YEAR_INPUT}    Tab
    # Month Picker Displayed Year Should Be    ${picker_locator}    ${year}
    Click    ${DATEPICKER_YEAR_INPUT}
    Press Keys    ${DATEPICKER_YEAR_INPUT}    Control+a
    Type Text    ${DATEPICKER_YEAR_INPUT}    ${year}    delay=100ms    clear=False
    ${typed}=    Get Property    ${DATEPICKER_YEAR_INPUT}    value
    Log    Year after typing: ${typed}
    Should Be Equal As Strings    ${typed}    ${year}

    # ${year_after_fill}=    Get Property    ${DATEPICKER_YEAR_INPUT}    value
    # Log    Year after fill: ${year_after_fill}
    # Press Keys    ${DATEPICKER_YEAR_INPUT}    Tab
    # ${year_after_enter}=    Get Property    ${DATEPICKER_YEAR_INPUT}    value
    # Log    Year after Enter: ${year_after_enter}


Increase Month Picker Year
    [Documentation]    Clicks the year arrow-up the given number of times and verifies the year.
    [Arguments]    ${picker_locator}    ${times}=1
    ${start}=    Get Month Picker Displayed Year    ${picker_locator}
    FOR    ${index}    IN RANGE    ${times}
        Click    ${DATEPICKER_YEAR_UP}
    END
    ${expected}=    Evaluate    int($start) + int($times)
    Month Picker Displayed Year Should Be    ${picker_locator}    ${expected}

Decrease Month Picker Year
    [Arguments]    ${picker_locator}    ${times}=1
    ${start}=    Get Month Picker Displayed Year    ${picker_locator}
    FOR    ${index}    IN RANGE    ${times}
        Click    ${DATEPICKER_YEAR_DOWN}
    END
    ${expected}=    Evaluate    int($start) - int($times)
    Month Picker Displayed Year Should Be    ${picker_locator}    ${expected}

Go To Previous Month Picker Year
    [Documentation]    The "<" arrow of the month picker moves one year back.
    [Arguments]    ${picker_locator}
    ${start}=    Get Month Picker Displayed Year    ${picker_locator}
    Click    ${DATEPICKER_PREVIOUS}
    ${expected}=    Evaluate    int($start) - 1
    Month Picker Displayed Year Should Be    ${picker_locator}    ${expected}

Go To Next Month Picker Year
    [Documentation]    The ">" arrow of the month picker moves one year forward.
    [Arguments]    ${picker_locator}
    ${start}=    Get Month Picker Displayed Year    ${picker_locator}
    Click    ${DATEPICKER_NEXT}
    ${expected}=    Evaluate    int($start) + 1
    Month Picker Displayed Year Should Be    ${picker_locator}    ${expected}

Month Picker Displayed Year Should Be
    [Arguments]    ${picker_locator}    ${expected_year}
    ${year}=    Get Month Picker Displayed Year    ${picker_locator}
    Should Be Equal As Integers    ${year}    ${expected_year}

# ===========================================================================
# 4. Value of the input
# ===========================================================================
Get Month Picker Value
    [Documentation]    Returns the input value, e.g. 2026-12 (empty string when nothing is selected).
    [Arguments]    ${picker_locator}
    ${value}=    Get Property    ${picker_locator}    value
    RETURN    ${value}

Month Picker Value Should Be
    [Arguments]    ${picker_locator}    ${expected_value}
    Get Property    ${picker_locator}    value    ==    ${expected_value}

Month Picker Value Should Be Month
    [Documentation]    E.g. Month Picker Value Should Be Month    ${picker}    December    2026
    [Arguments]    ${picker_locator}    ${month}    ${year}
    ${short}=    Evaluate    $month[:3].title()
    ${number}=    Get From Dictionary    ${MONTH_NUMBERS}    ${short}
    Month Picker Value Should Be    ${picker_locator}    ${year}-${number}

Month Picker Value Should Be Empty
    [Arguments]    ${picker_locator}
    Get Property    ${picker_locator}    value    ==    ${EMPTY}

Month Picker Value Should Not Be Empty
    [Arguments]    ${picker_locator}
    ${value}=    Get Month Picker Value    ${picker_locator}
    Should Not Be Empty    ${value}

Month Picker Value Should Match Format
    [Documentation]    YYYY-MM with a month between 01 and 12.
    [Arguments]    ${picker_locator}
    ${value}=    Get Month Picker Value    ${picker_locator}
    Should Match Regexp    ${value}    ^\\d{4}-(0[1-9]|1[0-2])$

Get Month Picker Selected Month Name
    [Documentation]    Month highlighted as selected in the open panel, e.g. "December".
    [Arguments]    ${picker_locator}
    Ensure Month Picker Is Open    ${picker_locator}
    ${label}=    Get Attribute    ${DATEPICKER_SELECTED_MONTH}    aria-label
    ${name}=    Evaluate    $label.split()[0]
    RETURN    ${name}

Month Picker Selected Month Should Be
    [Documentation]    Checks the highlight in the open panel (month = full or short name).
    [Arguments]    ${picker_locator}    ${month}
    Ensure Month Picker Is Open    ${picker_locator}
    ${short}=    Evaluate    $month[:3].title()
    Wait For Elements State    ${DATEPICKER_SELECTED_MONTH}:text-is("${short}")    visible

Month Picker Should Have No Selected Month
    [Arguments]    ${picker_locator}
    Ensure Month Picker Is Open    ${picker_locator}
    Get Element Count    ${DATEPICKER_SELECTED_MONTH}    ==    0

# ===========================================================================
# 5. Panel content
# ===========================================================================
Month Picker Should Show All Months
    [Arguments]    ${picker_locator}
    Ensure Month Picker Is Open    ${picker_locator}
    Get Element Count    ${DATEPICKER_MONTH}    ==    12

Get Month Picker Month Names
    [Documentation]    Short names shown in the open panel (Jan ... Dec).
    [Arguments]    ${picker_locator}
    Ensure Month Picker Is Open    ${picker_locator}
    ${elements}=    Get Elements    ${DATEPICKER_MONTH}
    ${names}=    Create List
    FOR    ${element}    IN    @{elements}
        ${text}=    Get Text    ${element}
        ${text}=    Strip String    ${text}
        Append To List    ${names}    ${text}
    END
    RETURN    ${names}

Month Picker Month Names Should Be Jan To Dec
    [Arguments]    ${picker_locator}
    ${names}=    Get Month Picker Month Names    ${picker_locator}
    ${expected}=    Create List    Jan    Feb    Mar    Apr    May    Jun    Jul    Aug    Sep    Oct    Nov    Dec
    Lists Should Be Equal    ${names}    ${expected}

Month Picker Today Should Be Highlighted
    [Documentation]    The current month carries the "today" marker when the current year is shown.
    [Arguments]    ${picker_locator}    ${month}
    Ensure Month Picker Is Open    ${picker_locator}
    ${short}=    Evaluate    $month[:3].title()
    Wait For Elements State    ${DATEPICKER_TODAY_MONTH}:text-is("${short}")    visible

Month Picker Month Should Be Enabled
    [Arguments]    ${picker_locator}    ${month}
    Ensure Month Picker Is Open    ${picker_locator}
    ${short}=    Evaluate    $month[:3].title()
    Get Element Count    ${DATEPICKER_DISABLED_MONTH}:text-is("${short}")    ==    0

Month Picker Month Should Be Disabled
    [Arguments]    ${picker_locator}    ${month}
    Ensure Month Picker Is Open    ${picker_locator}
    ${short}=    Evaluate    $month[:3].title()
    Wait For Elements State    ${DATEPICKER_DISABLED_MONTH}:text-is("${short}")    visible

# ===========================================================================
# 6. Clear (x button)
# ===========================================================================
Clear Month Picker
    [Documentation]    Clicks the (x) button next to the input and checks the value is empty.
    [Arguments]    ${picker_locator}
    Click    ${picker_locator} >> ${DATEPICKER_GROUP} >> ${DATEPICKER_CLEAR_BUTTON}
    Month Picker Value Should Be Empty    ${picker_locator}

Ensure Month Picker Is Cleared
    [Documentation]    Clears only when a value is present.
    [Arguments]    ${picker_locator}
    ${value}=    Get Month Picker Value    ${picker_locator}
    IF    '${value}' != ''
        Clear Month Picker    ${picker_locator}
    END

Month Picker Clear Button Should Be Visible
    [Arguments]    ${picker_locator}
    Wait For Elements State    ${picker_locator} >> ${DATEPICKER_GROUP} >> ${DATEPICKER_CLEAR_BUTTON}    visible

Month Picker Clear Button Should Not Be Visible
    [Arguments]    ${picker_locator}
    Wait For Elements State    ${picker_locator} >> ${DATEPICKER_GROUP} >> ${DATEPICKER_CLEAR_BUTTON}    hidden

# ===========================================================================
# 7. State (visible, enabled, readonly, required, placeholder, icon)
# ===========================================================================
Month Picker Should Be Visible
    [Arguments]    ${picker_locator}
    Wait For Elements State    ${picker_locator}    visible

Month Picker Should Not Be Visible
    [Arguments]    ${picker_locator}
    Wait For Elements State    ${picker_locator}    hidden

Month Picker Should Be Enabled
    [Arguments]    ${picker_locator}
    Get Property    ${picker_locator}    disabled    ==    ${False}

Month Picker Should Be Disabled
    [Arguments]    ${picker_locator}
    Get Property    ${picker_locator}    disabled    ==    ${True}

Month Picker Should Be Readonly
    [Documentation]    The input is readonly: the month can only be chosen from the panel.
    [Arguments]    ${picker_locator}
    Get Property    ${picker_locator}    readOnly    ==    ${True}

Month Picker Should Be Required
    [Arguments]    ${picker_locator}
    Get Property    ${picker_locator}    required    ==    ${True}

Month Picker Should Not Be Required
    [Arguments]    ${picker_locator}
    Get Property    ${picker_locator}    required    ==    ${False}

Month Picker Placeholder Should Be
    [Arguments]    ${picker_locator}    ${expected_text}
    Get Attribute    ${picker_locator}    placeholder    ==    ${expected_text}

Month Picker Title Should Be
    [Documentation]    The title attribute mirrors the selected value (e.g. 2026-12).
    [Arguments]    ${picker_locator}    ${expected_text}
    Get Attribute    ${picker_locator}    title    ==    ${expected_text}

Month Picker Icon Should Be Visible
    [Arguments]    ${picker_locator}
    Wait For Elements State    ${picker_locator} >> ${DATEPICKER_GROUP} >> ${DATEPICKER_ICON}    visible
