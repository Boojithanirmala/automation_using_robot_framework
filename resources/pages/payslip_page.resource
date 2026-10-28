# *** Settings ***
# Documentation     Payslip creation form locators observed in the QA ERP DOM.
# Library           Browser
# Library           Collections
# Resource          ../components/dropdown.resource
# Resource          ../components/textarea.resource
# Resource          ../components/common_form_actions.resource

# *** Variables ***
# ${PAYSLIP_NO_INPUT}                    css=input[name="payslipNo"]
# ${PAYSLIP_PAYABLE_MONTH_INPUT}         input[name="payableMonth"]
# ${PAYSLIP_REMARKS_TEXTAREA}            textarea[placeholder="Enter Remarks"]     
# ${PAYSLIP_EMPLOYEES_DROPDOWN}          css=ng-select.employee-select-custom
# ${PAYSLIP_EMPLOYEES_SEARCH_INPUT}      css=ng-select.employee-select-custom .ng-input input
# ${PAYSLIP_SALARY_GROUP_DROPDOWN}       css=div.flex-column:has(> label:text-is("Salary Group")) ng-select
# ${PAYSLIP_SALARY_GROUP_SEARCH_INPUT}   css=div.flex-column:has(> label:text-is("Salary Group")) ng-select .ng-input input
# ${PAYSLIP_PAYMENT_THROUGH_DROPDOWN}    css=div.flex-column:has(> label:text-is("Payment Through")) ng-select
# ${PAYSLIP_PAYMENT_THROUGH_SEARCH_INPUT}    css=div.flex-column:has(> label:text-is("Payment Through")) ng-select .ng-input input

# ${PAYSLIP_BACK_BUTTON}                 role=button[name=/Back/]
# ${PAYSLIP_RESET_BUTTON}                role=button[name="Reset"]
# ${PAYSLIP_SAVE_BUTTON}                 role=button[name="Save"]
# ${PAYSLIP_CANCEL_CONTROL}              text=Cancel

# ${PAYSLIP_MONTH_PICKER_YEAR}           role=spinbutton[name="Year"]
# ${PAYSLIP_MONTH_PICKER_MONTHS}         css=.flatpickr-calendar.open .flatpickr-monthSelect-month[aria-label]
# ${PAYSLIP_MONTH_PICKER_PREVIOUS}       css=.flatpickr-calendar.open .flatpickr-prev-month
# ${PAYSLIP_MONTH_PICKER_NEXT}           css=.flatpickr-calendar.open .flatpickr-next-month

# &{PAYSLIP_MONTH_NUMBERS}                January=01    February=02    March=03    April=04    May=05    June=06    July=07    August=08    September=09    October=10    November=11    December=12


# *** Keywords ***

# Open Payslip Payable Month Picker
#     Click    ${PAYSLIP_PAYABLE_MONTH_INPUT}
#     Wait For Elements State    ${PAYSLIP_MONTH_PICKER_YEAR}    visible

# Select Payslip Payable Month
#     [Arguments]    ${month}    ${year}
#     Open Payslip Payable Month Picker
#     Fill Text    ${PAYSLIP_MONTH_PICKER_YEAR}    ${year}
#     ${month_number}=    Get From Dictionary    ${PAYSLIP_MONTH_NUMBERS}    ${month}
#     ${month_abbreviation}=    Evaluate    $month[:3]
#     ${month_option}=    Set Variable    css=.flatpickr-calendar.open .flatpickr-monthSelect-month[aria-label]:has-text("${month_abbreviation}")
#     Click    ${month_option}
#     ${expected_month}=    Set Variable    ${year}-${month_number}
#     ${actual_month}=    Get Property    ${PAYSLIP_PAYABLE_MONTH_INPUT}    value
#     Should Be Equal    ${actual_month}    ${expected_month}

# Select Payslip Salary Group
#     [Arguments]    ${salary_group}    ${search_text}=${EMPTY}
#     Select Payslip Dropdown Value    ${PAYSLIP_SALARY_GROUP_DROPDOWN}    ${salary_group}    ${search_text}

# Select Payslip Payment Through
#     [Arguments]    ${payment_method}    ${search_text}=${EMPTY}
#     Select Payslip Dropdown Value    ${PAYSLIP_PAYMENT_THROUGH_DROPDOWN}    ${payment_method}    ${search_text}

# Select Payslip Employees
#     [Arguments]    @{employees}
#     Open Dropdown    ${PAYSLIP_EMPLOYEES_DROPDOWN}
#     FOR    ${employee}    IN    @{employees}
#         Search Dropdown Options    ${PAYSLIP_EMPLOYEES_DROPDOWN}    ${employee}
#         Dropdown Options Should Be Visible    ${employee}
#         ${employee_option}=    Set Variable    css=ng-dropdown-panel[role="listbox"] [role="option"]:has-text("${employee}")
#         Click    ${employee_option}
#         ${selected_employee}=    Set Variable    ${PAYSLIP_EMPLOYEES_DROPDOWN} .ng-value-label:has-text("${employee}")
#         Wait For Elements State    ${selected_employee}    visible
#     END
#     Click    ${PAYSLIP_EMPLOYEES_DROPDOWN}

# Enter Payslip Remarks
#     [Arguments]    ${remarks}
#     Fill Textarea    ${PAYSLIP_REMARKS_TEXTAREA}    ${remarks}
  
# Fill Payslip Form
#     [Arguments]    ${month}    ${year}    ${salary_group}    ${payment_through}    ${remarks}=${EMPTY}    @{employees}
#     Select Payslip Payable Month    ${month}    ${year}
#     Select Payslip Salary Group    ${salary_group}    ${salary_group}
#     Select Payslip Payment Through    ${payment_through}    ${payment_through}
#     IF    $employees
#         Select Payslip Employees    @{employees}
#     END
#     IF    $remarks != ''
#         Enter Payslip Remarks    ${remarks}
#     END

# Select Payslip Dropdown Value
#     [Arguments]    ${dropdown_locator}    ${option_text}    ${search_text}=${EMPTY}
#     Open Dropdown    ${dropdown_locator}
#     IF    $search_text != ''
#         Search Dropdown Options    ${dropdown_locator}    ${search_text}
#     END
#     Dropdown Options Should Be Visible    ${option_text}
#     ${option_locator}=    Set Variable    css=ng-dropdown-panel[role="listbox"] [role="option"]:has-text("${option_text}")
#     Click    ${option_locator}
#     ${selected_value_locator}=    Set Variable    ${dropdown_locator} .ng-value-label:has-text("${option_text}")
#     Wait For Elements State    ${selected_value_locator}    visible



*** Settings ***
Documentation     Payslip creation form locators and keywords observed in the QA ERP DOM.
Library           Browser
Library           Collections
Library           String
Resource          ../components/dropdown.resource
Resource          ../components/textarea.resource
Resource          ../components/date_picker.resource
Resource          ../components/common_form_actions.resource

*** Variables ***
${PAYSLIP_NO_INPUT}                    css=input[name="payslipNo"]
${PAYSLIP_PAYABLE_MONTH_INPUT}         input[name="payableMonth"]
${PAYSLIP_REMARKS_TEXTAREA}            textarea[placeholder="Enter Remarks"]
${PAYSLIP_EMPLOYEES_DROPDOWN}          css=ng-select.employee-select-custom
${PAYSLIP_EMPLOYEES_SEARCH_INPUT}      css=ng-select.employee-select-custom .ng-input input
${PAYSLIP_SALARY_GROUP_DROPDOWN}       css=div.flex-column:has(> label:text-is("Salary Group")) ng-select
${PAYSLIP_SALARY_GROUP_SEARCH_INPUT}   css=div.flex-column:has(> label:text-is("Salary Group")) ng-select .ng-input input
${PAYSLIP_PAYMENT_THROUGH_DROPDOWN}    css=div.flex-column:has(> label:text-is("Payment Through")) ng-select
${PAYSLIP_PAYMENT_THROUGH_SEARCH_INPUT}    css=div.flex-column:has(> label:text-is("Payment Through")) ng-select .ng-input input

${PAYSLIP_BACK_BUTTON}                 role=button[name=/Back/]
${PAYSLIP_RESET_BUTTON}                role=button[name="Reset"]
${PAYSLIP_SAVE_BUTTON}                 role=button[name="Save"]
${PAYSLIP_CANCEL_CONTROL}              text=Cancel

# --- Warning shown when salary group is touched before the payable month -----
${PAYSLIP_PAYABLE_MONTH_WARNING}       Please fill the payable month.

# --- Payslip Preview card ------------------------------------------------------
${PAYSLIP_PREVIEW_CARD}                css=div.card:has(h5:text-is("Payslip Preview"))
${PAYSLIP_PREVIEW_TITLE}               ${PAYSLIP_PREVIEW_CARD} >> h5
${PAYSLIP_PREVIEW_HEADERS}             ${PAYSLIP_PREVIEW_CARD} >> thead th
# Employee rows carry ng-star-inserted; the blank spacer row at the end does not.
${PAYSLIP_PREVIEW_ROWS}                ${PAYSLIP_PREVIEW_CARD} >> tbody tr.ng-star-inserted
${PAYSLIP_PREVIEW_EMPLOYEE_CELLS}      ${PAYSLIP_PREVIEW_CARD} >> tbody tr.ng-star-inserted >> td:first-child
${PAYSLIP_PREVIEW_TOTALS_ROW}          ${PAYSLIP_PREVIEW_CARD} >> tfoot tr.table-light
${PAYSLIP_PREVIEW_NET_PAYABLE}         ${PAYSLIP_PREVIEW_CARD} >> tfoot td.fs-5


*** Keywords ***
# ===========================================================================
# 1. Payslip No
# ===========================================================================
Payslip No Should Not Be Editable
    [Documentation]    The number is generated by the system: the input is disabled or readonly.
    ${disabled}=    Get Property    ${PAYSLIP_NO_INPUT}    disabled
    ${readonly}=    Get Property    ${PAYSLIP_NO_INPUT}    readOnly
    Should Be True    ${disabled} or ${readonly}    Payslip No must not be editable.

# ===========================================================================
# 2. Payable month (uses date_picker.resource)
# ===========================================================================
Open Payslip Payable Month Picker
    Open Month Picker    ${PAYSLIP_PAYABLE_MONTH_INPUT}

Select Payslip Payable Month
    [Documentation]    Picks the month/year and waits for the employee list to reload.
    [Arguments]    ${month}    ${year}
    Select Month Picker Month    ${PAYSLIP_PAYABLE_MONTH_INPUT}    ${month}    ${year}
    Wait For Payslip Employees To Reload

Clear Payslip Payable Month
    Clear Month Picker    ${PAYSLIP_PAYABLE_MONTH_INPUT}
    Wait For Payslip Employees To Reload

Wait For Payslip Employees To Reload
    [Documentation]    Employees / salary group are loaded from the server after the month or
    ...                salary group changes. Needs Browser library with "Wait Until Network Is Idle";
    ...                the error is ignored on older versions.
    click    ${PAYSLIP_EMPLOYEES_DROPDOWN}
    Run Keyword And Ignore Error    Wait Until Network Is Idle    timeout=10s

# ===========================================================================
# 3. Salary group (multi select) / Payment through (single select)
# ===========================================================================
Select Payslip Salary Groups
    [Documentation]    Multi select: picks every group, closes the panel and waits for the employee reload.
    [Arguments]    @{salary_groups}
    Select Multiple Dropdown Options    ${PAYSLIP_SALARY_GROUP_DROPDOWN}    @{salary_groups}
    Wait For Payslip Employees To Reload

Select Payslip Salary Group
    [Arguments]    ${salary_group}
    Select Payslip Salary Groups    ${salary_group}

Clear Payslip Salary Groups
    Clear Dropdown Selection    ${PAYSLIP_SALARY_GROUP_DROPDOWN}
    Wait For Payslip Employees To Reload

Get Payslip Salary Group Options
    ${options}=    Get Dropdown Options    ${PAYSLIP_SALARY_GROUP_DROPDOWN}
    RETURN    ${options}

Select Payslip Payment Through
    [Arguments]    ${payment_method}    ${search_text}=${EMPTY}
    Select Payslip Dropdown Value    ${PAYSLIP_PAYMENT_THROUGH_DROPDOWN}    ${payment_method}    ${search_text}

# ===========================================================================
# 4. Employees (multi select)
# ===========================================================================
Select Payslip Employees
    [Arguments]    @{employees}
    Open Dropdown    ${PAYSLIP_EMPLOYEES_DROPDOWN}
    FOR    ${employee}    IN    @{employees}
        Search Dropdown Options    ${PAYSLIP_EMPLOYEES_DROPDOWN}    ${employee}
        Dropdown Options Should Be Visible    ${employee}
        ${employee_option}=    Set Variable    css=ng-dropdown-panel[role="listbox"] [role="option"]:has-text("${employee}")
        Click    ${employee_option}
        ${selected_employee}=    Set Variable    ${PAYSLIP_EMPLOYEES_DROPDOWN} .ng-value-label:has-text("${employee}")
        Wait For Elements State    ${selected_employee}    visible
    END
    Click    ${PAYSLIP_EMPLOYEES_DROPDOWN}

Remove Payslip Employee
    [Documentation]    Deselects one employee with the (x) on its chip.
    [Arguments]    ${employee}
    Remove Selected Value    ${PAYSLIP_EMPLOYEES_DROPDOWN}    ${employee}
    Dropdown Should Not Have Selected Value    ${PAYSLIP_EMPLOYEES_DROPDOWN}    ${employee}

Clear Payslip Employees
    [Documentation]    Deselects every employee with the clear (x) button.
    Clear Dropdown Selection    ${PAYSLIP_EMPLOYEES_DROPDOWN}

Get Payslip Employee Options
    [Documentation]    Employee names currently offered by the dropdown.
    ${options}=    Get Dropdown Options    ${PAYSLIP_EMPLOYEES_DROPDOWN}
    RETURN    ${options}

Get First Payslip Employee Option
    ${options}=    Get Payslip Employee Options
    Should Not Be Empty    ${options}    No employee is available in the dropdown for the chosen month / salary group.
    RETURN    ${options}[0]

Payslip Employee Should Be Available
    [Arguments]    ${employee}
    Dropdown Options Should Contain    ${PAYSLIP_EMPLOYEES_DROPDOWN}    ${employee}

Payslip Employee Should Not Be Available
    [Arguments]    ${employee}
    Dropdown Options Should Not Contain    ${PAYSLIP_EMPLOYEES_DROPDOWN}    ${employee}

# ===========================================================================
# 5. Remarks / warning
# ===========================================================================
Enter Payslip Remarks
    [Arguments]    ${remarks}
    Fill Textarea    ${PAYSLIP_REMARKS_TEXTAREA}    ${remarks}

Payable Month Warning Should Be Visible
    Toast Message Should Be Visible    ${PAYSLIP_PAYABLE_MONTH_WARNING}

# ===========================================================================
# 6. Fill the whole form
# ===========================================================================
Fill Payslip Form
    [Arguments]    ${month}    ${year}    ${salary_group}    ${payment_through}    ${remarks}=${EMPTY}    @{employees}
    Select Payslip Payable Month    ${month}    ${year}
    IF    '${salary_group}' != ''
        Select Payslip Salary Group    ${salary_group}
    END
    IF    '${payment_through}' != ''
        Select Payslip Payment Through    ${payment_through}    ${payment_through}
    END
    IF    $employees
        Select Payslip Employees    @{employees}
    END
    IF    $remarks != ''
        Enter Payslip Remarks    ${remarks}
    END

Select Payslip Dropdown Value
    [Arguments]    ${dropdown_locator}    ${option_text}    ${search_text}=${EMPTY}
    Open Dropdown    ${dropdown_locator}
    IF    $search_text != ''
        Search Dropdown Options    ${dropdown_locator}    ${search_text}
    END
    Dropdown Options Should Be Visible    ${option_text}
    ${option_locator}=    Set Variable    css=ng-dropdown-panel[role="listbox"] [role="option"]:has-text("${option_text}")
    Click    ${option_locator}
    ${selected_value_locator}=    Set Variable    ${dropdown_locator} .ng-value-label:has-text("${option_text}")
    Wait For Elements State    ${selected_value_locator}    visible

# ===========================================================================
# 7. Payslip Preview
# ===========================================================================
Payslip Preview Should Be Visible
    Wait For Elements State    ${PAYSLIP_PREVIEW_CARD}    visible

Payslip Preview Column Headers Should Be
    [Arguments]    @{expected_headers}
    ${elements}=    Get Elements    ${PAYSLIP_PREVIEW_HEADERS}
    ${headers}=    Create List
    FOR    ${element}    IN    @{elements}
        ${text}=    Get Text    ${element}
        Append To List    ${headers}    ${text.strip()}
    END
    Lists Should Be Equal    ${headers}    ${expected_headers}

Get Payslip Preview Employees
    [Documentation]    Employee names shown in the preview rows (empty list when no rows / no card).
    ${count}=    Get Element Count    ${PAYSLIP_PREVIEW_ROWS}
    ${names}=    Create List
    IF    ${count} > 0
        ${elements}=    Get Elements    ${PAYSLIP_PREVIEW_EMPLOYEE_CELLS}
        FOR    ${element}    IN    @{elements}
            ${text}=    Get Text    ${element}
            ${text}=    Evaluate    ' '.join($text.split())
            Append To List    ${names}    ${text}
        END
    END
    RETURN    ${names}

Payslip Preview Employees Should Be
    [Documentation]    Exact set of employees in the preview, order ignored.
    [Arguments]    @{expected_employees}
    ${actual}=    Get Payslip Preview Employees
    ${expected}=    Evaluate    [' '.join(name.split()) for name in $expected_employees]
    Lists Should Be Equal    ${actual}    ${expected}    ignore_order=True

Payslip Preview Should Contain Employee
    [Arguments]    ${employee}
    ${actual}=    Get Payslip Preview Employees
    ${name}=    Evaluate    ' '.join($employee.split())
    List Should Contain Value    ${actual}    ${name}

Payslip Preview Should Not Contain Employee
    [Arguments]    ${employee}
    ${actual}=    Get Payslip Preview Employees
    ${name}=    Evaluate    ' '.join($employee.split())
    List Should Not Contain Value    ${actual}    ${name}

Payslip Preview Should Be Empty
    [Documentation]    No employee row is shown (works whether the card is hidden or just has no rows).
    Get Element Count    ${PAYSLIP_PREVIEW_ROWS}    ==    0

Payslip Preview Row Count Should Be
    [Arguments]    ${expected_count}
    Get Element Count    ${PAYSLIP_PREVIEW_ROWS}    ==    ${expected_count}

Get Payslip Preview Net Payable Amount
    ${text}=    Get Text    ${PAYSLIP_PREVIEW_NET_PAYABLE}
    RETURN    ${text.strip()}
