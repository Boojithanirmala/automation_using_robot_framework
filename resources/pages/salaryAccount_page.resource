*** Settings ***
Documentation     Salary Account page: locators and keywords.
...
...               Form behaviour:
...               - Salary Account No is auto generated (read only).
...               - Payable Month uses a month picker (year can be typed, changed with
...                 keyboard arrow keys, or with the previous / next arrows).
...               - Select Payslip No lists only the payslips of the selected month.
...                 Only one payslip can be chosen. A payslip that already has a
...                 salary account is not listed again.
...               - Salary Group, Payment Through, Employees and Remarks are auto
...                 populated from the selected payslip and are NOT editable.
...               - Salary Account Preview shows Employee and Net Salary.
Library           Browser
Library           Collections
Library           String
Resource          ../components/dropdown.resource
Resource          ../components/common_form.resource


*** Variables ***
${SALARY_ACCOUNT_NO_INPUT}                    css=input[name="salaryAccountNo"]
${SALARY_ACCOUNT_PAYABLE_MONTH_INPUT}         input[name="payableMonth"]
${SALARY_ACCOUNT_EMPLOYEES_DROPDOWN}          css=ng-select.employee-select-custom
${SALARY_ACCOUNT_EMPLOYEES_SEARCH_INPUT}      css=ng-select.employee-select-custom .ng-input input
${SALARY_ACCOUNT_PAYSLIP_NO_DROPDOWN}         css=div.flex-column:has(> label:text-is("Select Payslip No")) ng-select
${SALARY_ACCOUNT_PAYSLIP_NO_SEARCH_INPUT}     css=div.flex-column:has(> label:text-is("Select Payslip No")) ng-select .ng-input input
${SALARY_ACCOUNT_SALARY_GROUP_DROPDOWN}       css=div.flex-column:has(> label:text-is("Salary Group")) ng-select
${SALARY_ACCOUNT_SALARY_GROUP_SEARCH_INPUT}   css=div.flex-column:has(> label:text-is("Salary Group")) ng-select .ng-input input
${SALARY_ACCOUNT_PAYMENT_THROUGH_DROPDOWN}    css=div.flex-column:has(> label:text-is("Payment Through")) ng-select
${SALARY_ACCOUNT_PAYMENT_THROUGH_SEARCH_INPUT}    css=div.flex-column:has(> label:text-is("Payment Through")) ng-select .ng-input input
${SALARY_ACCOUNT_REMARKS_TEXTAREA}            textarea[placeholder="Enter Remarks"]
${SALARY_ACCOUNT_PAYABLE_MONTH_REQUIRED_MESSAGE}    text=Payable Month is required.
${SALARY_ACCOUNT_PAYSLIP_NO_REQUIRED_MESSAGE}       text=Select Payslip No is required.
                                                    

${SALARY_ACCOUNT_BACK_BUTTON}                 role=button[name=/Back/]
${SALARY_ACCOUNT_RESET_BUTTON}                role=button[name="Reset"]
${SALARY_ACCOUNT_SAVE_BUTTON}                 role=button[name="Save"]
${SALARY_ACCOUNT_CANCEL_CONTROL}              text=Cancel

${SALARY_ACCOUNT_MONTH_PICKER_YEAR}           role=spinbutton[name="Year"]
${SALARY_ACCOUNT_MONTH_PICKER_MONTHS}         css=.flatpickr-calendar.open .flatpickr-monthSelect-month[aria-label]
${SALARY_ACCOUNT_MONTH_PICKER_PREVIOUS}       css=.flatpickr-calendar.open .flatpickr-prev-month
${SALARY_ACCOUNT_MONTH_PICKER_NEXT}           css=.flatpickr-calendar.open .flatpickr-next-month

&{SALARY_ACCOUNT_MONTH_NUMBERS}                January=01    February=02    March=03    April=04    May=05    June=06    July=07    August=08    September=09    October=10    November=11    December=12

${SALARY_ACCOUNT_PAGE_TITLE}                  text=Salary Account
${SALARY_ACCOUNT_PREVIEW_TITLE}               text=Salary Account Preview
${SALARY_ACCOUNT_PREVIEW_EMPLOYEE_HEADER}     text=Employee
${SALARY_ACCOUNT_PREVIEW_NET_SALARY_HEADER}   text=Net Salary


# TODO: confirm this row locator against the real preview markup.
${SALARY_ACCOUNT_PREVIEW_ROWS}                css=tbody tr

*** Keywords ***
# ===========================================================================
# Payable month picker
# ===========================================================================
Open Salary Account Payable Month Picker
    Click    ${SALARY_ACCOUNT_PAYABLE_MONTH_INPUT}
    Wait For Elements State    ${SALARY_ACCOUNT_MONTH_PICKER_YEAR}    visible

Set Salary Account Picker Year
    [Documentation]    Types the year into the picker's year field.
    [Arguments]    ${year}
    Fill Text    ${SALARY_ACCOUNT_MONTH_PICKER_YEAR}    ${year}

Get Salary Account Picker Year
    ${year}=    Get Property    ${SALARY_ACCOUNT_MONTH_PICKER_YEAR}    value
    RETURN    ${year}

Change Salary Account Picker Year Using Keyboard
    [Documentation]    direction = Up or Down. Presses the arrow key the given number of times.
    [Arguments]    ${direction}    ${steps}=1
    Click    ${SALARY_ACCOUNT_MONTH_PICKER_YEAR}
    FOR    ${index}    IN RANGE    ${steps}
        Press Keys    ${SALARY_ACCOUNT_MONTH_PICKER_YEAR}    Arrow${direction}
    END

Click Salary Account Picker Next Arrow
    Click    ${SALARY_ACCOUNT_MONTH_PICKER_NEXT}

Click Salary Account Picker Previous Arrow
    Click    ${SALARY_ACCOUNT_MONTH_PICKER_PREVIOUS}

Click Salary Account Picker Month
    [Arguments]    ${month}
    ${month_abbreviation}=    Evaluate    $month[:3]
    Click    ${SALARY_ACCOUNT_MONTH_PICKER_MONTHS}:has-text("${month_abbreviation}")

Select Salary Account Payable Month
    [Arguments]    ${month}    ${year}
    Open Salary Account Payable Month Picker
    Set Salary Account Picker Year    ${year}
    Click Salary Account Picker Month    ${month}
    ${month_number}=    Get From Dictionary    ${SALARY_ACCOUNT_MONTH_NUMBERS}    ${month}
    Salary Account Payable Month Should Be    ${year}-${month_number}

Get Salary Account Payable Month
    ${value}=    Get Property    ${SALARY_ACCOUNT_PAYABLE_MONTH_INPUT}    value
    RETURN    ${value}

Salary Account Payable Month Should Be
    [Documentation]    Input value format is YYYY-MM, e.g. 2027-05
    [Arguments]    ${expected}
    ${actual}=    Get Salary Account Payable Month
    Should Be Equal    ${actual}    ${expected}

Salary Account Payable Month Should Be Empty
    ${actual}=    Get Salary Account Payable Month
    Should Be Empty    ${actual}

Salary Account Picker Year Should Be
    [Arguments]    ${expected}
    ${actual}=    Get Salary Account Picker Year
    Should Be Equal As Strings    ${actual}    ${expected}

Salary Account Month Picker Should Show All Months
    Get Element Count    ${SALARY_ACCOUNT_MONTH_PICKER_MONTHS}    ==    12

# ===========================================================================
# Payslip No dropdown (single select, depends on payable month)
# ===========================================================================
Select Salary Account Payslip No
    [Arguments]    ${payslip_no}    ${search_text}=${EMPTY}
    IF    $search_text == ''
        Select Dropdown Option    ${SALARY_ACCOUNT_PAYSLIP_NO_DROPDOWN}    ${payslip_no}
    ELSE
        Open Dropdown    ${SALARY_ACCOUNT_PAYSLIP_NO_DROPDOWN}
        Search Dropdown Options    ${SALARY_ACCOUNT_PAYSLIP_NO_DROPDOWN}    ${search_text}
        Dropdown Options Should Be Visible    ${payslip_no}
        Click    ${DROPDOWN_ENABLED_OPTION}:has-text("${payslip_no}")
    END
    Salary Account Payslip No Should Be    ${payslip_no}

Salary Account Payslip No Options Should Contain
    [Arguments]    @{payslip_nos}
    Dropdown Options Should Contain    ${SALARY_ACCOUNT_PAYSLIP_NO_DROPDOWN}    @{payslip_nos}

Salary Account Payslip No Options Should Not Contain
    [Arguments]    @{payslip_nos}
    Dropdown Options Should Not Contain    ${SALARY_ACCOUNT_PAYSLIP_NO_DROPDOWN}    @{payslip_nos}

Salary Account Payslip No Options Should Be Empty
    Dropdown Options Should Be Empty    ${SALARY_ACCOUNT_PAYSLIP_NO_DROPDOWN}

Salary Account Payslip No Should Be
    [Arguments]    ${expected}
    Dropdown Should Have Selected Value    ${SALARY_ACCOUNT_PAYSLIP_NO_DROPDOWN}    ${expected}

# ===========================================================================
# Auto populated fields (Salary Group, Payment Through, Employees, Remarks)
# ===========================================================================
Salary Account Details Should Be Populated
    [Documentation]    Waits until the payslip data has been patched into the form.
    Wait For Elements State    ${SALARY_ACCOUNT_EMPLOYEES_DROPDOWN} .ng-value    visible
    Wait For Elements State    ${SALARY_ACCOUNT_SALARY_GROUP_DROPDOWN} .ng-value    visible

Salary Account Salary Groups Should Be Selected
    [Arguments]    @{salary_groups}
    FOR    ${salary_group}    IN    @{salary_groups}
        Dropdown Should Have Selected Value    ${SALARY_ACCOUNT_SALARY_GROUP_DROPDOWN}    ${salary_group}
    END

Salary Account Payment Through Should Be
    [Arguments]    ${expected}
    Dropdown Should Have Selected Value    ${SALARY_ACCOUNT_PAYMENT_THROUGH_DROPDOWN}    ${expected}

Salary Account Employees Should Be Selected
    [Documentation]    The field collapses extra chips into "+N More...", so use this for
    ...                the visible chips only. Use the preview keywords for the full list.
    [Arguments]    @{employees}
    FOR    ${employee}    IN    @{employees}
        Dropdown Should Have Selected Value    ${SALARY_ACCOUNT_EMPLOYEES_DROPDOWN}    ${employee}
    END

Salary Account Remarks Should Be
    [Arguments]    ${expected}
    ${actual}=    Get Property    ${SALARY_ACCOUNT_REMARKS_TEXTAREA}    value
    Should Be Equal    ${actual}    ${expected}

# --- Non editable checks ---------------------------------------------------
Salary Account Number Should Be Read Only
    ${read_only}=    Get Property    ${SALARY_ACCOUNT_NO_INPUT}    readOnly
    ${disabled}=     Get Property    ${SALARY_ACCOUNT_NO_INPUT}    disabled
    Should Be True    ${read_only} or ${disabled}    Salary Account No should not be editable.

Salary Account Remarks Should Be Read Only
    ${read_only}=    Get Property    ${SALARY_ACCOUNT_REMARKS_TEXTAREA}    readOnly
    ${disabled}=     Get Property    ${SALARY_ACCOUNT_REMARKS_TEXTAREA}    disabled
    Should Be True    ${read_only} or ${disabled}    Remarks should not be editable.

Salary Account Auto Populated Fields Should Be Non Editable
    Salary Account Number Should Be Read Only
    Dropdown Should Be Disabled    ${SALARY_ACCOUNT_SALARY_GROUP_DROPDOWN}
    Dropdown Should Be Disabled    ${SALARY_ACCOUNT_PAYMENT_THROUGH_DROPDOWN}
    Dropdown Should Be Disabled    ${SALARY_ACCOUNT_EMPLOYEES_DROPDOWN}
    Salary Account Remarks Should Be Read Only

# ===========================================================================
# Form state / actions
# ===========================================================================
Salary Account Form Should Be Visible
    Wait For Elements State    ${SALARY_ACCOUNT_NO_INPUT}                    visible
    Wait For Elements State    ${SALARY_ACCOUNT_PAYABLE_MONTH_INPUT}         visible
    Wait For Elements State    ${SALARY_ACCOUNT_PAYSLIP_NO_DROPDOWN}         visible
    Wait For Elements State    ${SALARY_ACCOUNT_SALARY_GROUP_DROPDOWN}       visible
    Wait For Elements State    ${SALARY_ACCOUNT_PAYMENT_THROUGH_DROPDOWN}    visible
    Wait For Elements State    ${SALARY_ACCOUNT_EMPLOYEES_DROPDOWN}          visible
    Wait For Elements State    ${SALARY_ACCOUNT_REMARKS_TEXTAREA}            visible
    Wait For Elements State    ${FORM_SAVE_BUTTON}                           visible

Get Salary Account Number
    ${account_no}=    Get Property    ${SALARY_ACCOUNT_NO_INPUT}    value
    RETURN    ${account_no}

Salary Account Number Should Match Pattern
    [Arguments]    ${pattern}=^[A-Z]+-SA\\d{4}/\\d+$
    ${account_no}=    Get Salary Account Number
    Should Match Regexp    ${account_no}    ${pattern}

Fill Salary Account Form
    [Documentation]    Only Payable Month and Payslip No are user inputs.
    ...                The other fields are patched from the payslip.
    [Arguments]    ${month}    ${year}    ${payslip_no}
    Select Salary Account Payable Month    ${month}    ${year}
    Select Salary Account Payslip No    ${payslip_no}    ${payslip_no}
    Salary Account Details Should Be Populated

# ===========================================================================
# Validation
# ===========================================================================
Salary Account Payable Month Required Message Should Be Visible
    Wait For Elements State    ${SALARY_ACCOUNT_PAYABLE_MONTH_REQUIRED_MESSAGE}    visible

Salary Account Payable Month Required Message Should Not Be Visible
    Wait For Elements State    ${SALARY_ACCOUNT_PAYABLE_MONTH_REQUIRED_MESSAGE}    detached

Salary Account Payslip No Required Message Should Be Visible
    Wait For Elements State    ${SALARY_ACCOUNT_PAYSLIP_NO_REQUIRED_MESSAGE}    visible

Salary Account Payslip No Required Message Should Not Be Visible
    Wait For Elements State    ${SALARY_ACCOUNT_PAYSLIP_NO_REQUIRED_MESSAGE}    detached

Salary Account Form Should Be Reset
    Salary Account Payable Month Should Be Empty
    Dropdown Should Have No Selected Value    ${SALARY_ACCOUNT_PAYSLIP_NO_DROPDOWN}
    Dropdown Should Have No Selected Value    ${SALARY_ACCOUNT_SALARY_GROUP_DROPDOWN}
    Dropdown Should Have No Selected Value    ${SALARY_ACCOUNT_PAYMENT_THROUGH_DROPDOWN}
    Dropdown Should Have No Selected Value    ${SALARY_ACCOUNT_EMPLOYEES_DROPDOWN}
    Salary Account Remarks Should Be    ${EMPTY}

# ===========================================================================
# Salary Account Preview
# ===========================================================================
Salary Account Preview Should Be Visible
    Wait For Elements State    ${SALARY_ACCOUNT_PREVIEW_TITLE}                visible
    Wait For Elements State    ${SALARY_ACCOUNT_PREVIEW_EMPLOYEE_HEADER}      visible
    Wait For Elements State    ${SALARY_ACCOUNT_PREVIEW_NET_SALARY_HEADER}    visible

Get Salary Account Preview Row Count
    ${count}=    Get Element Count    ${SALARY_ACCOUNT_PREVIEW_ROWS}
    RETURN    ${count}

Salary Account Preview Should Contain Employees
    [Arguments]    @{employees}
    FOR    ${employee}    IN    @{employees}
        Wait For Elements State    ${SALARY_ACCOUNT_PREVIEW_ROWS}:has-text("${employee}")    visible
    END

Salary Account Preview Net Salary Should Be
    [Arguments]    ${employee}    ${net_salary}
    Get Text    ${SALARY_ACCOUNT_PREVIEW_ROWS}:has-text("${employee}") >> td >> nth=-1    ==    ${net_salary}