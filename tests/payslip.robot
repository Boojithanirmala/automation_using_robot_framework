# *** Settings ***
# Documentation       Payslip form UI smoke tests.

# Resource            ../resources/common.resource
# Resource            ../resources/pages/login_page.resource
# Resource            ../resources/pages/dashboard.resource
# Resource            ../resources/pages/payslip_page.resource

# Suite Setup         Start Browser
# Suite Teardown      Close Browser
# Test Setup          Open Payslip Form
# Test Teardown       Close Test Context


# *** Variables ***
# ${PAYSLIP_MONTH}        October
# ${PAYSLIP_YEAR}         2026
# ${TEST_REMARKS}         Automation test remarks

# *** Keywords ***
# Open Payslip Form
#     Open Fresh Page
#     Login With Credentials    ${VALID_USERNAME}    ${VALID_PASSWORD}
#     Dashboard Should Be Open
#     Go To Page    /dynamicformadd/payslipForm

# *** Test Cases ***

# Verify Payslip Form Fields Are Visible
#     [Documentation]    Verify the main Payslip form controls are available.
#     [Tags]    payslip    smoke

#     Wait For Elements State    ${PAYSLIP_NO_INPUT}    visible
#     Wait For Elements State    ${PAYSLIP_PAYABLE_MONTH_INPUT}    visible
#     Wait For Elements State    ${PAYSLIP_REMARKS_TEXTAREA}    visible
#     Wait For Elements State    ${PAYSLIP_EMPLOYEES_DROPDOWN}    visible
#     Wait For Elements State    ${PAYSLIP_SALARY_GROUP_DROPDOWN}    visible
#     Wait For Elements State    ${PAYSLIP_PAYMENT_THROUGH_DROPDOWN}    visible

# Verify Payable Month Can Be Selected
#     [Documentation]    Verify the month picker selects October 2026.
#     [Tags]    payslip    payable-month

#     Select Payslip Payable Month    ${PAYSLIP_MONTH}    ${PAYSLIP_YEAR}

# Verify Remarks Can Be Entered
#     [Documentation]    Verify remarks can be entered and read back.
#     [Tags]    payslip    remarks

#     Enter Payslip Remarks    ${TEST_REMARKS}

# Verify Salary Group Dropdown Can Be Opened
#     [Documentation]    Verify the Salary Group dropdown opens.
#     [Tags]    payslip    dropdown

#     Open Dropdown    ${PAYSLIP_SALARY_GROUP_DROPDOWN}
#     Wait For Elements State
#     ...    ${PAYSLIP_SALARY_GROUP_DROPDOWN}
#     ...    visible

#     Click    ${PAYSLIP_SALARY_GROUP_DROPDOWN}

# Verify Payment Through Dropdown Can Be Opened
#     [Documentation]    Verify the Payment Through dropdown opens.
#     [Tags]    payslip    dropdown

#     Open Dropdown    ${PAYSLIP_PAYMENT_THROUGH_DROPDOWN}
#     Wait For Elements State
#     ...    ${PAYSLIP_PAYMENT_THROUGH_DROPDOWN}
#     ...    visible

#     Click    ${PAYSLIP_PAYMENT_THROUGH_DROPDOWN}




*** Settings ***
Documentation       Payslip form UI and business-rule tests.
...
...                 Tests tagged "data" CREATE payslips (Save) and pick the employee dynamically
...                 from the dropdown, so each run uses up one available employee for the month
...                 used by that scenario. Change the SCENARIO_* months below when they run out.

Resource            ../resources/common.resource
Resource            ../resources/pages/login_page.resource
Resource            ../resources/pages/dashboard.resource
Resource            ../resources/pages/payslip_page.resource
Resource            ../resources/components/dropdown.resource
Resource            ../resources/components/textarea.resource
Resource            ../resources/components/date_picker.resource
Resource            ../resources/components/common_form_actions.resource

Suite Setup         Start Browser
Suite Teardown      Close Browser
Test Setup          Open Payslip Form
Test Teardown       Close Test Context


*** Variables ***
${PAYSLIP_MONTH}          October
${PAYSLIP_YEAR}           2026
${TEST_REMARKS}           Automation test remarks

# Salary group used by the filter scenarios. Leave empty to use the first option of the dropdown.
${SALARY_GROUP}           ${EMPTY}

# One month per create scenario so the scenarios never consume each other's employees.
${SCENARIO_A_MONTH}       January
${SCENARIO_A_YEAR}        2027
${SCENARIO_B_MONTH}       February
${SCENARIO_B_YEAR}        2027
${SCENARIO_C_MONTH}       March
${SCENARIO_C_YEAR}        2027
# A month in which scenario A's employee still has no payslip.
${OTHER_MONTH}            December
${OTHER_YEAR}             2027


*** Keywords ***
Open Payslip Form
    Open Fresh Page
    Login With Credentials    ${VALID_USERNAME}    ${VALID_PASSWORD}
    Dashboard Should Be Open
    Go To Page    /dynamicformadd/payslipForm
    Wait For Elements State    ${PAYSLIP_NO_INPUT}    visible

Reopen Payslip Form
    [Documentation]    Fresh, empty form (used after a payslip was saved).
    Go To Page    /dynamicformadd/payslipForm
    Wait For Elements State    ${PAYSLIP_NO_INPUT}    visible

Get Salary Group To Use
    [Documentation]    ${SALARY_GROUP} or, when empty, the first option. Call after the month is selected.
    IF    '${SALARY_GROUP}' != ''
        RETURN    ${SALARY_GROUP}
    END
    ${groups}=    Get Payslip Salary Group Options
    Should Not Be Empty    ${groups}    No salary group available.
    RETURN    ${groups}[0]

Save Payslip And Expect Success
    Click Save Button
    Data Created Toast Should Be Visible

Create Payslip With Month And Employee Only
    [Documentation]    Scenario A: payable month + employee, no salary group.
    [Arguments]    ${month}    ${year}
    Select Payslip Payable Month    ${month}    ${year}
    ${employee}=    Get First Payslip Employee Option
    Select Payslip Employees    ${employee}
    Save Payslip And Expect Success
    RETURN    ${employee}

Create Payslip With Month And Salary Group
    [Documentation]    Scenario C: payable month + salary group + employee (employee comes from the group).
    [Arguments]    ${month}    ${year}
    Select Payslip Payable Month    ${month}    ${year}
    ${group}=    Get Salary Group To Use
    Select Payslip Salary Groups    ${group}
    ${employee}=    Get First Payslip Employee Option
    Select Payslip Employees    ${employee}
    Save Payslip And Expect Success
    RETURN    ${employee}    ${group}

Create Payslip For Group Employee Without Group
    [Documentation]    Scenario B: the employee is taken from the salary group list, then the group is
    ...                removed and the payslip is saved with payable month + employee only.
    [Arguments]    ${month}    ${year}
    Select Payslip Payable Month    ${month}    ${year}
    ${group}=    Get Salary Group To Use
    Select Payslip Salary Groups    ${group}
    ${employee}=    Get First Payslip Employee Option
    Deselect All Dropdown Options    ${PAYSLIP_SALARY_GROUP_DROPDOWN}
    Wait For Payslip Employees To Reload
    Select Payslip Employees    ${employee}
    Save Payslip And Expect Success
    RETURN    ${employee}    ${group}

Select Two Employees For Preview
    [Documentation]    Month selected, then the first two available employees are chosen.
    Select Payslip Payable Month    ${PAYSLIP_MONTH}    ${PAYSLIP_YEAR}
    ${options}=    Get Payslip Employee Options
    ${count}=    Get Length    ${options}
    Skip If    ${count} < 2    At least two available employees are needed in ${PAYSLIP_MONTH} ${PAYSLIP_YEAR}.
    Select Payslip Employees    ${options}[0]    ${options}[1]
    RETURN    ${options}[0]    ${options}[1]


*** Test Cases ***
# ===========================================================================
# Form fields
# ===========================================================================
Verify Payslip Form Fields Are Visible
    [Documentation]    Verify the main Payslip form controls are available.
    [Tags]    payslip    smoke

    Wait For Elements State    ${PAYSLIP_NO_INPUT}    visible
    Month Picker Should Be Visible    ${PAYSLIP_PAYABLE_MONTH_INPUT}
    Wait For Elements State    ${PAYSLIP_REMARKS_TEXTAREA}    visible
    Wait For Elements State    ${PAYSLIP_EMPLOYEES_DROPDOWN}    visible
    Wait For Elements State    ${PAYSLIP_SALARY_GROUP_DROPDOWN}    visible
    Wait For Elements State    ${PAYSLIP_PAYMENT_THROUGH_DROPDOWN}    visible
    Form Action Buttons Should Be Visible

Verify Payslip Number Is Not Editable
    [Documentation]    1. Payslip No is generated by the system, so the user cannot type in it.
    [Tags]    payslip    payslip-no

    Payslip No Should Not Be Editable

# ===========================================================================
# 2. Payable month (month picker)
# ===========================================================================
Verify Payable Month Picker Properties
    [Documentation]    The picker is a required, readonly input with a calendar icon.
    [Tags]    payslip    payable-month

    Month Picker Should Be Readonly    ${PAYSLIP_PAYABLE_MONTH_INPUT}
    Month Picker Should Be Required    ${PAYSLIP_PAYABLE_MONTH_INPUT}
    Month Picker Placeholder Should Be    ${PAYSLIP_PAYABLE_MONTH_INPUT}    Select Payable Month
    Month Picker Icon Should Be Visible    ${PAYSLIP_PAYABLE_MONTH_INPUT}

Verify Payable Month Can Be Selected
    [Documentation]    Verify the month picker selects October 2026.
    [Tags]    payslip    payable-month

    Select Payslip Payable Month    ${PAYSLIP_MONTH}    ${PAYSLIP_YEAR}
    Month Picker Value Should Match Format    ${PAYSLIP_PAYABLE_MONTH_INPUT}
    Month Picker Title Should Be    ${PAYSLIP_PAYABLE_MONTH_INPUT}    ${PAYSLIP_YEAR}-10

Verify Month Picker Opens From Calendar Icon And Shows All Months
    [Tags]    payslip    payable-month

    Open Month Picker Using Icon    ${PAYSLIP_PAYABLE_MONTH_INPUT}
    Month Picker Should Show All Months    ${PAYSLIP_PAYABLE_MONTH_INPUT}
    Month Picker Month Names Should Be Jan To Dec    ${PAYSLIP_PAYABLE_MONTH_INPUT}
    Close Month Picker

Verify Payable Month Can Be Changed
    [Documentation]    The month can be changed after a first selection (month and year).
    [Tags]    payslip    payable-month

    Select Payslip Payable Month    January    2026
    Month Picker Value Should Be    ${PAYSLIP_PAYABLE_MONTH_INPUT}    2026-01
    Select Payslip Payable Month    August    2026
    Month Picker Value Should Be    ${PAYSLIP_PAYABLE_MONTH_INPUT}    2026-08
    Select Payslip Payable Month    March    2027
    Month Picker Value Should Be    ${PAYSLIP_PAYABLE_MONTH_INPUT}    2027-03

Verify Selected Month Is Highlighted In The Panel
    [Tags]    payslip    payable-month

    Select Payslip Payable Month    ${PAYSLIP_MONTH}    ${PAYSLIP_YEAR}
    Month Picker Selected Month Should Be    ${PAYSLIP_PAYABLE_MONTH_INPUT}    ${PAYSLIP_MONTH}
    Close Month Picker

Verify Year Can Be Changed With Arrows
    [Documentation]    Year arrow up/down and the < > buttons of the picker.
    [Tags]    payslip    payable-month

    Open Month Picker    ${PAYSLIP_PAYABLE_MONTH_INPUT}
    Set Month Picker Year    ${PAYSLIP_PAYABLE_MONTH_INPUT}    2026
    Increase Month Picker Year    ${PAYSLIP_PAYABLE_MONTH_INPUT}
    Decrease Month Picker Year    ${PAYSLIP_PAYABLE_MONTH_INPUT}    2
    Go To Next Month Picker Year    ${PAYSLIP_PAYABLE_MONTH_INPUT}
    Go To Previous Month Picker Year    ${PAYSLIP_PAYABLE_MONTH_INPUT}
    Close Month Picker

Verify Payable Month Can Be Cleared
    [Documentation]    The (x) next to the picker removes the selected month.
    [Tags]    payslip    payable-month

    Select Payslip Payable Month    ${PAYSLIP_MONTH}    ${PAYSLIP_YEAR}
    Month Picker Clear Button Should Be Visible    ${PAYSLIP_PAYABLE_MONTH_INPUT}
    Clear Payslip Payable Month
    Month Picker Value Should Be Empty    ${PAYSLIP_PAYABLE_MONTH_INPUT}

# ===========================================================================
# 3 / 4 / 5 / 6. Dropdown types and remarks
# ===========================================================================
Verify Dropdown Types
    [Documentation]    3. Salary group and 4. Employees are multi select; 5. Payment through is single select.
    [Tags]    payslip    dropdown

    Dropdown Should Be Multi Select    ${PAYSLIP_SALARY_GROUP_DROPDOWN}
    Dropdown Should Be Multi Select    ${PAYSLIP_EMPLOYEES_DROPDOWN}
    Dropdown Should Be Single Select    ${PAYSLIP_PAYMENT_THROUGH_DROPDOWN}

Verify Salary Group Dropdown Can Be Opened
    [Documentation]    Verify the Salary Group dropdown opens once the payable month is chosen.
    [Tags]    payslip    dropdown

    Select Payslip Payable Month    ${PAYSLIP_MONTH}    ${PAYSLIP_YEAR}
    Open Dropdown    ${PAYSLIP_SALARY_GROUP_DROPDOWN}
    Dropdown Should Be Open    ${PAYSLIP_SALARY_GROUP_DROPDOWN}
    Close Dropdown    ${PAYSLIP_SALARY_GROUP_DROPDOWN}

Verify Payment Through Dropdown Can Be Opened
    [Documentation]    Verify the Payment Through dropdown opens.
    [Tags]    payslip    dropdown

    Open Dropdown    ${PAYSLIP_PAYMENT_THROUGH_DROPDOWN}
    Dropdown Should Be Open    ${PAYSLIP_PAYMENT_THROUGH_DROPDOWN}
    Close Dropdown    ${PAYSLIP_PAYMENT_THROUGH_DROPDOWN}

Verify Payment Through Allows Only One Value
    [Tags]    payslip    dropdown

    ${options}=    Get Dropdown Options    ${PAYSLIP_PAYMENT_THROUGH_DROPDOWN}
    ${count}=    Get Length    ${options}
    Skip If    ${count} < 2    Need at least two payment methods.
    Select Payslip Payment Through    ${options}[0]
    Select Payslip Payment Through    ${options}[1]
    Dropdown Selected Value Count Should Be    ${PAYSLIP_PAYMENT_THROUGH_DROPDOWN}    1
    Dropdown Selected Value Should Be    ${PAYSLIP_PAYMENT_THROUGH_DROPDOWN}    ${options}[1]

Verify Remarks Can Be Entered
    [Documentation]    Verify remarks can be entered and read back.
    [Tags]    payslip    remarks

    Enter Payslip Remarks    ${TEST_REMARKS}
    Textarea Value Should Be    ${PAYSLIP_REMARKS_TEXTAREA}    ${TEST_REMARKS}

Verify Remarks Can Be Cleared
    [Tags]    payslip    remarks

    Enter Payslip Remarks    ${TEST_REMARKS}
    Clear Textarea    ${PAYSLIP_REMARKS_TEXTAREA}

# ===========================================================================
# 8. Warning when salary group is used without a payable month
# ===========================================================================
Verify Warning When Salary Group Is Selected Without Payable Month
    [Documentation]    8. Touching Salary Group with no payable month shows "Please fill the payable month."
    ...                (Adjust if the warning appears only after an option is clicked.)
    [Tags]    payslip    validation

    Month Picker Value Should Be Empty    ${PAYSLIP_PAYABLE_MONTH_INPUT}
    Click    ${PAYSLIP_SALARY_GROUP_DROPDOWN}
    Payable Month Warning Should Be Visible

# ===========================================================================
# 7 / 9 / 10. Employee list depends on payable month and salary group
# ===========================================================================
Verify Salary Group Filters The Employee List
    [Documentation]    10. With a salary group the list is a subset of the month's list;
    ...                removing the group brings back the full list.
    [Tags]    payslip    employees    filter

    Select Payslip Payable Month    ${PAYSLIP_MONTH}    ${PAYSLIP_YEAR}
    ${all_employees}=    Get Payslip Employee Options
    ${group}=    Get Salary Group To Use
    Select Payslip Salary Groups    ${group}
    ${group_employees}=    Get Payslip Employee Options
    ${is_subset}=    Evaluate    set($group_employees).issubset(set($all_employees))
    Should Be True    ${is_subset}    Group employees ${group_employees} are not part of ${all_employees}
    Deselect All Dropdown Options    ${PAYSLIP_SALARY_GROUP_DROPDOWN}
    Wait For Payslip Employees To Reload
    ${after_clear}=    Get Payslip Employee Options
    Lists Should Be Equal    ${after_clear}    ${all_employees}    ignore_order=True

Verify Employee List Has No Duplicates
    [Tags]    payslip    employees

    Select Payslip Payable Month    ${PAYSLIP_MONTH}    ${PAYSLIP_YEAR}
    Dropdown Options Should Not Have Duplicates    ${PAYSLIP_EMPLOYEES_DROPDOWN}

# ===========================================================================
# 9 / 11. Employee with a payslip disappears for that month only (data)
# ===========================================================================
Verify Employee With Payslip Is Hidden For The Same Month Only
    [Documentation]    7, 9, 11. After a payslip for month + employee: the employee is not offered again
    ...                for that month, but is still offered for another month.
    [Tags]    payslip    employees    data

    ${employee}=    Create Payslip With Month And Employee Only    ${SCENARIO_A_MONTH}    ${SCENARIO_A_YEAR}
    Reopen Payslip Form
    Select Payslip Payable Month    ${SCENARIO_A_MONTH}    ${SCENARIO_A_YEAR}
    Payslip Employee Should Not Be Available    ${employee}
    Select Payslip Payable Month    ${OTHER_MONTH}    ${OTHER_YEAR}
    Payslip Employee Should Be Available    ${employee}

# ===========================================================================
# 12. Payslip by month + employee, then month + salary group (data)
# ===========================================================================
Verify Employee Is Hidden For Month Plus Salary Group After Month Plus Employee Payslip
    [Documentation]    12. Payslip created with month + employee (no group): the same month + the
    ...                employee's salary group must not offer that employee either.
    [Tags]    payslip    employees    data

    ${employee}    ${group}=    Create Payslip For Group Employee Without Group    ${SCENARIO_B_MONTH}    ${SCENARIO_B_YEAR}
    Reopen Payslip Form
    Select Payslip Payable Month    ${SCENARIO_B_MONTH}    ${SCENARIO_B_YEAR}
    Select Payslip Salary Groups    ${group}
    Payslip Employee Should Not Be Available    ${employee}

# ===========================================================================
# 13. Payslip by month + salary group, then month only (data)
# ===========================================================================
Verify Employee Is Hidden For Month Only After Month Plus Salary Group Payslip
    [Documentation]    13. Payslip created with month + salary group: selecting only the month must
    ...                not offer that employee again.
    [Tags]    payslip    employees    data

    ${employee}    ${group}=    Create Payslip With Month And Salary Group    ${SCENARIO_C_MONTH}    ${SCENARIO_C_YEAR}
    Reopen Payslip Form
    Select Payslip Payable Month    ${SCENARIO_C_MONTH}    ${SCENARIO_C_YEAR}
    Payslip Employee Should Not Be Available    ${employee}
    Select Payslip Salary Groups    ${group}
    Payslip Employee Should Not Be Available    ${employee}

# ===========================================================================
# 14 / 15 / 16. Payslip Preview
# ===========================================================================
Verify Preview Shows Only Selected Employees
    [Documentation]    14. Only the selected employee appears in the preview, not every available one.
    [Tags]    payslip    preview

    Select Payslip Payable Month    ${PAYSLIP_MONTH}    ${PAYSLIP_YEAR}
    ${employee}=    Get First Payslip Employee Option
    Select Payslip Employees    ${employee}
    Payslip Preview Employees Should Be    ${employee}
    Payslip Preview Row Count Should Be    1

Verify Preview Updates When Employees Are Selected And Deselected
    [Documentation]    15. Select two employees, then deselect them one by one.
    [Tags]    payslip    preview

    ${first}    ${second}=    Select Two Employees For Preview
    Payslip Preview Employees Should Be    ${first}    ${second}
    Remove Payslip Employee    ${first}
    Payslip Preview Employees Should Be    ${second}
    Payslip Preview Should Not Contain Employee    ${first}
    Select Payslip Employees    ${first}
    Payslip Preview Employees Should Be    ${first}    ${second}

Verify Preview Is Empty When Last Employee Is Deselected
    [Documentation]    16. With no employee selected nothing is shown in the preview.
    [Tags]    payslip    preview

    ${first}    ${second}=    Select Two Employees For Preview
    Remove Payslip Employee    ${first}
    Remove Payslip Employee    ${second}
    Dropdown Should Have No Selected Value    ${PAYSLIP_EMPLOYEES_DROPDOWN}
    Payslip Preview Should Be Empty

Verify Preview Is Empty When All Employees Are Cleared At Once
    [Tags]    payslip    preview

    ${first}    ${second}=    Select Two Employees For Preview
    Clear Payslip Employees
    Payslip Preview Should Be Empty

Verify Preview Has No Employee Before Selection
    [Tags]    payslip    preview

    Payslip Preview Should Be Empty
