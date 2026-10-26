*** Settings ***
Documentation     Payslip creation form locators observed in the QA ERP DOM.
Library           Browser
Library           Collections
Resource          ../components/dropdown.resource
Resource          ../components/textarea.resource

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

${PAYSLIP_MONTH_PICKER_YEAR}           role=spinbutton[name="Year"]
${PAYSLIP_MONTH_PICKER_MONTHS}         css=.flatpickr-calendar.open .flatpickr-monthSelect-month[aria-label]
${PAYSLIP_MONTH_PICKER_PREVIOUS}       css=.flatpickr-calendar.open .flatpickr-prev-month
${PAYSLIP_MONTH_PICKER_NEXT}           css=.flatpickr-calendar.open .flatpickr-next-month

&{PAYSLIP_MONTH_NUMBERS}                January=01    February=02    March=03    April=04    May=05    June=06    July=07    August=08    September=09    October=10    November=11    December=12


*** Keywords ***

Open Payslip Payable Month Picker
    Click    ${PAYSLIP_PAYABLE_MONTH_INPUT}
    Wait For Elements State    ${PAYSLIP_MONTH_PICKER_YEAR}    visible

Select Payslip Payable Month
    [Arguments]    ${month}    ${year}
    Open Payslip Payable Month Picker
    Fill Text    ${PAYSLIP_MONTH_PICKER_YEAR}    ${year}
    ${month_number}=    Get From Dictionary    ${PAYSLIP_MONTH_NUMBERS}    ${month}
    ${month_abbreviation}=    Evaluate    $month[:3]
    ${month_option}=    Set Variable    css=.flatpickr-calendar.open .flatpickr-monthSelect-month[aria-label]:has-text("${month_abbreviation}")
    Click    ${month_option}
    ${expected_month}=    Set Variable    ${year}-${month_number}
    ${actual_month}=    Get Property    ${PAYSLIP_PAYABLE_MONTH_INPUT}    value
    Should Be Equal    ${actual_month}    ${expected_month}

Select Payslip Salary Group
    [Arguments]    ${salary_group}    ${search_text}=${EMPTY}
    Select Payslip Dropdown Value    ${PAYSLIP_SALARY_GROUP_DROPDOWN}    ${salary_group}    ${search_text}

Select Payslip Payment Through
    [Arguments]    ${payment_method}    ${search_text}=${EMPTY}
    Select Payslip Dropdown Value    ${PAYSLIP_PAYMENT_THROUGH_DROPDOWN}    ${payment_method}    ${search_text}

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

Enter Payslip Remarks
    [Arguments]    ${remarks}
    Fill Textarea    ${PAYSLIP_REMARKS_TEXTAREA}    ${remarks}
  
Fill Payslip Form
    [Arguments]    ${month}    ${year}    ${salary_group}    ${payment_through}    ${remarks}=${EMPTY}    @{employees}
    Select Payslip Payable Month    ${month}    ${year}
    Select Payslip Salary Group    ${salary_group}    ${salary_group}
    Select Payslip Payment Through    ${payment_through}    ${payment_through}
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

