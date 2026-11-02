*** Settings ***
Documentation       Test-data factory for the Payslip module.
...
...                 Location: resources/pages/payslip_fixture.resource
...                 (all Resource paths below are relative to THIS file's folder)
...
...                 Other suites (Salary Account, ...) call "Create Payslip Fixture" to get a REAL payslip
...                 and receive everything about it back as one dictionary:
...                     no, month, year, groups, payment, employees, employee_count, remarks
...
...                 Today the payslip is created through the UI. Later, ONLY the body of
...                 "Create Payslip Fixture" / "Delete Test Payslips" has to be replaced by API calls.
Library             Browser
Library             Collections
Resource            ../common.resource
Resource            payslip_page.resource
Resource            ../components/dropdown.resource
Resource            ../components/common_form_actions.resource


*** Variables ***
${PAYSLIP_FORM_PATH}            /dynamicformadd/payslipForm
${PAYSLIP_LIST_PATH}            /dynamiclist/payslipForm
# Month search for fixtures: starts here and walks forward month by month.
${FIXTURE_START_YEAR}           2028
${FIXTURE_MAX_MONTH_TRIES}      36

# TODO: confirm against the real delete confirmation popup of your app.
${CONFIRM_DELETE_BUTTON}        xpath=//button[contains(@class,'swal2-confirm') or normalize-space(.)='Yes' or normalize-space(.)='Delete']


*** Keywords ***
Reopen Payslip Form
    Go To Page    ${PAYSLIP_FORM_PATH}
    Wait For Elements State    ${PAYSLIP_NO_INPUT}    visible

Get First Salary Group
    ${groups}=    Get Payslip Salary Group Options
    Should Not Be Empty    ${groups}    No salary group available for the selected month.
    RETURN    ${groups}[0]

Get Free Employee Options
    [Documentation]    Employee options of the form (after month + group are selected).
    ...                An EMPTY list is a valid answer: ng-select shows only "No items found" (it has no
    ...                role="option"), so a keyword that waits for an option would hang for 15 s.
    ...                The component keyword "Get Dropdown Options" handles the empty list in 3 s.
    Wait Until Dropdown Is Loaded    ${PAYSLIP_EMPLOYEES_DROPDOWN}    20s
    ${options}=    Get Dropdown Options    ${PAYSLIP_EMPLOYEES_DROPDOWN}
    IF    not $options
        # one more try in case the list was still loading
        Wait Until Dropdown Is Loaded    ${PAYSLIP_EMPLOYEES_DROPDOWN}    20s
        ${options}=    Get Dropdown Options    ${PAYSLIP_EMPLOYEES_DROPDOWN}
    END
    RETURN    ${options}

Count Free Employees In Month
    [Documentation]    Opens a fresh form, selects the month + first salary group and returns how many
    ...                employees (without a payslip) are offered. 0 when the month has no group / employees.
    [Arguments]    ${month}    ${year}
    TRY
        Reopen Payslip Form
        Select Payslip Payable Month    ${month}    ${year}
        ${has_group}=    Run Keyword And Return Status    Get First Salary Group
        IF    not $has_group    RETURN    ${0}
        ${group}=    Get First Salary Group
        Select Payslip Salary Groups    ${group}
        ${options}=    Get Free Employee Options
    EXCEPT    AS    ${error}
        Run Keyword And Ignore Error    Take Screenshot
        Fail    Could not read the employees of ${month} ${year}: ${error}
    END
    ${count}=    Get Length    ${options}
    RETURN    ${count}

Find Free Payslip Month
    [Documentation]    Walks forward from FIXTURE_START_YEAR and returns the first month + year where the first
    ...                salary group still has at least ${employees_needed} employees without a payslip.
    ...                It STOPS at the first month that fits, so the month it returns is the one the
    ...                payslip is created in. Months listed in @{exclude} (format Month-Year) are skipped.
    ...                Progress is printed to the console, one line per month checked.
    [Arguments]    ${employees_needed}    @{exclude}
    @{names}=    Create List    January    February    March    April    May    June
    ...    July    August    September    October    November    December
    FOR    ${i}    IN RANGE    ${FIXTURE_MAX_MONTH_TRIES}
        ${year}=    Evaluate    ${FIXTURE_START_YEAR} + ${i} // 12
        ${index}=    Evaluate    ${i} % 12
        ${month}=    Set Variable    ${names}[${index}]
        ${key}=    Set Variable    ${month}-${year}
        IF    $key in $exclude    CONTINUE
        ${count}=    Count Free Employees In Month    ${month}    ${year}
        Log To Console    \n[fixture] ${key}: ${count} free employees (need ${employees_needed})
        IF    ${count} >= ${employees_needed}    RETURN    ${month}    ${year}
    END
    Fail    No month with ${employees_needed} free employees found in ${FIXTURE_MAX_MONTH_TRIES} months from ${FIXTURE_START_YEAR}. Delete old test payslips or raise FIXTURE_START_YEAR.

Select Fixture Employees
    [Documentation]    Clicks every employee in the open list. It does NOT type the long "code | name" text
    ...                into the search box (the filtered list is re-rendered asynchronously, so an immediate
    ...                check finds 0 options). Verification is done in the panel at the end, because the chips
    ...                collapse into "+N More..." and cannot be used to check the later employees.
    [Arguments]    @{employees}
    FOR    ${employee}    IN    @{employees}
        Ensure Dropdown Is Open    ${PAYSLIP_EMPLOYEES_DROPDOWN}
        ${option}=    Set Variable    ${DROPDOWN_ENABLED_OPTION}:has-text("${employee}")
        Wait For Elements State    ${option}    visible    timeout=10s
        Click    ${option}
    END
    Ensure Dropdown Is Open    ${PAYSLIP_EMPLOYEES_DROPDOWN}
    FOR    ${employee}    IN    @{employees}
        Wait For Elements State    ${DROPDOWN_SELECTED_OPTION}:has-text("${employee}")    visible    timeout=10s
    END
    Ensure Dropdown Is Closed    ${PAYSLIP_EMPLOYEES_DROPDOWN}

Create Payslip Fixture
    [Documentation]    Creates one payslip (month + first salary group + the first N free employees) and
    ...                returns its details as a dictionary.
    ...                payment=AUTO picks the first Payment Through option, empty leaves it blank.
    [Arguments]    ${month}    ${year}    ${employee_count}=1    ${payment}=${EMPTY}    ${remarks}=${EMPTY}
    TRY
        Reopen Payslip Form
        Select Payslip Payable Month    ${month}    ${year}
        ${group}=    Get First Salary Group
        Select Payslip Salary Groups    ${group}
        ${options}=    Get Free Employee Options
        ${available}=    Get Length    ${options}
        Should Be True    ${available} >= ${employee_count}
        ...    Only ${available} free employees in ${month} ${year}, ${employee_count} needed.
        ${employees}=    Get Slice From List    ${options}    0    ${employee_count}
        Select Fixture Employees    @{employees}
        IF    $payment == 'AUTO'
            ${payment_options}=    Get Dropdown Options    ${PAYSLIP_PAYMENT_THROUGH_DROPDOWN}
            ${payment}=    Set Variable    ${payment_options}[0]
        END
        IF    $payment != ''
            Select Payslip Payment Through    ${payment}
        END
        IF    $remarks != ''
            Enter Payslip Remarks    ${remarks}
        END
        # Payslip No is generated by the system - capture it before saving.
        # (If your app generates it only on save, read it from the first row of the payslip list instead.)
        ${payslip_no}=    Get Property    ${PAYSLIP_NO_INPUT}    value
        Should Not Be Empty    ${payslip_no}
        Click Save Button
        Data Created Toast Should Be Visible
    EXCEPT    AS    ${error}
        Run Keyword And Ignore Error    Take Screenshot
        Fail    Creating the payslip fixture for ${month} ${year} failed: ${error}
    END
    @{groups}=    Create List    ${group}
    &{fixture}=    Create Dictionary
    ...    no=${payslip_no}    month=${month}    year=${year}    groups=${groups}
    ...    payment=${payment}    employees=${employees}    employee_count=${employee_count}
    ...    remarks=${remarks}
    Log    Payslip fixture created: ${fixture}
    Log To Console    \n[fixture] created ${payslip_no} in ${month} ${year}: ${employee_count} employee(s)
    RETURN    ${fixture}

# ===========================================================================
# Cleanup (optional - month discovery already keeps re-runs working)
# ===========================================================================
Delete Row From List Page
    [Documentation]    SAFETY: an empty row text would match the FIRST row of the list (contains(...,'') is
    ...                always true) and delete real data, so empty text is refused.
    [Arguments]    ${list_path}    ${row_text}
    IF    $row_text.strip() == ''
        Log    Empty row text - nothing deleted.    level=WARN
        RETURN
    END
    Go To Page    ${list_path}
    Click Delete Button In Row    ${row_text}
    Click    ${CONFIRM_DELETE_BUTTON}

Delete Test Payslips
    [Documentation]    Delete the salary accounts first (they depend on the payslips), then the payslips.
    [Arguments]    ${salary_list_path}    ${salary_account_nos}    ${payslip_nos}
    FOR    ${account_no}    IN    @{salary_account_nos}
        Run Keyword And Ignore Error    Delete Row From List Page    ${salary_list_path}    ${account_no}
    END
    FOR    ${payslip_no}    IN    @{payslip_nos}
        Run Keyword And Ignore Error    Delete Row From List Page    ${PAYSLIP_LIST_PATH}    ${payslip_no}
    END
