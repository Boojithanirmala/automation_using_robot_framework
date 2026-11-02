*** Settings ***
Documentation       Salary Account E2E: ONE test that walks the whole business flow.
...
...                 Payslip (created by the fixture) -> Salary Account form -> month picker ->
...                 payslip dropdown -> auto patched fields + preview -> non editable -> save ->
...                 duplicate payslip is no longer listed.
...
...                 Run this first. If it passes, the fixture, the page keywords and the components
...                 all work together, and the full test case file is safe to run.
Library             Browser
Library             Collections
Library             String
Resource            ../resources/common.resource
Resource            ../resources/pages/login_page.resource
Resource            ../resources/pages/dashboard.resource
Resource            ../resources/pages/salaryAccount_page.resource
Resource            ../resources/pages/payslip_fixture.resource
Resource            ../resources/components/dropdown.resource
Resource            ../resources/components/datepicker.resource
Resource            ../resources/components/common_form_actions.resource

Test Tags           salary_account    e2e
Suite Setup         Prepare E2E Data
Suite Teardown      Clean Up E2E Data
Test Setup          Open Salary Account Form
Test Teardown       Finish Test


*** Variables ***
${SALARY_ACCOUNT_FORM_PATH}     /dynamicformadd/salaryAccountForm
${SALARY_ACCOUNT_LIST_PATH}     /dynamiclist/salaryAccountForm
${CLEANUP_TEST_DATA}            ${True}
${FIXTURES_READY}              ${False}

${PICKER}                       ${SALARY_ACCOUNT_PAYABLE_MONTH_INPUT}
${PAYSLIP_DD}                   ${SALARY_ACCOUNT_PAYSLIP_NO_DROPDOWN}
${GROUP_DD}                     ${SALARY_ACCOUNT_SALARY_GROUP_DROPDOWN}
${PAYMENT_DD}                   ${SALARY_ACCOUNT_PAYMENT_THROUGH_DROPDOWN}
${EMPLOYEE_DD}                  ${SALARY_ACCOUNT_EMPLOYEES_DROPDOWN}

@{CREATED_SALARY_ACCOUNT_NOS}
${E2E_PS}
${E2E_OTHER}


*** Test Cases ***
E2E Payslip To Salary Account Flow
    [Documentation]    E2E_PS    = payslip of month A (2 employees, payment through, remarks)
    ...                E2E_OTHER = payslip of month B (used to prove the month change refreshes the list)
    [Tags]    e2e    smoke

    Log Step    1. Payslip fixtures were created in Suite Setup
    Should Not Be Empty    ${E2E_PS}[no]
    Should Not Be Empty    ${E2E_OTHER}[no]
    Log    E2E_PS: ${E2E_PS}
    Log    E2E_OTHER: ${E2E_OTHER}

    Log Step    2. Salary Account form opens, account no is auto generated and read only
    Salary Account Form Should Be Visible
    Form Action Buttons Should Be Visible
    ${old_account_no}=    Get Salary Account Number
    Should Not Be Empty    ${old_account_no}
    Salary Account Number Should Match Pattern
    Salary Account Number Should Be Read Only
    Auto Populated Fields Should Be Empty

    Log Step    3. Select the payable month with the month picker
    Select Month Picker Month    ${PICKER}    ${E2E_PS}[month]    ${E2E_PS}[year]
    Month Picker Value Should Be Month    ${PICKER}    ${E2E_PS}[month]    ${E2E_PS}[year]
    Month Picker Value Should Match Format    ${PICKER}

    Log Step    4. Payslip dropdown lists only the payslips of that month
    Salary Account Payslip No Options Should Contain    ${E2E_PS}[no]
    Salary Account Payslip No Options Should Not Contain    ${E2E_OTHER}[no]

    Log Step    5. Change the payable month - the payslip list refreshes, then come back
    Select Month Picker Month    ${PICKER}    ${E2E_OTHER}[month]    ${E2E_OTHER}[year]
    Salary Account Payslip No Options Should Contain    ${E2E_OTHER}[no]
    Salary Account Payslip No Options Should Not Contain    ${E2E_PS}[no]
    Select Month Picker Month    ${PICKER}    ${E2E_PS}[month]    ${E2E_PS}[year]
    Salary Account Payslip No Options Should Contain    ${E2E_PS}[no]

    Log Step    6. Select the payslip - details and preview are patched from the payslip
    Select Salary Account Payslip No    ${E2E_PS}[no]    ${E2E_PS}[no]
    Salary Account Should Show Details Of Payslip    ${E2E_PS}

    Log Step    7. Auto patched fields are not editable
    Salary Account Auto Populated Fields Should Be Non Editable

    Log Step    8. Save the salary account
    Append To List    ${CREATED_SALARY_ACCOUNT_NOS}    ${old_account_no}
    Click Save Button
    Wait For Elements State    text="Payslip Generated Successfully"    visible

    Log Step    9. New form: next account no, and the saved payslip is not listed again
    Reopen Salary Account Form
    ${new_account_no}=    Get Salary Account Number
    Should Not Be Equal    ${new_account_no}    ${old_account_no}
    Select Month Picker Month    ${PICKER}    ${E2E_PS}[month]    ${E2E_PS}[year]
    Salary Account Payslip No Options Should Not Contain    ${E2E_PS}[no]
    Dropdown Search Should Return No Options    ${PAYSLIP_DD}    ${E2E_PS}[no]

    Log Step    10. Payslip of another month is not affected
    Select Month Picker Month    ${PICKER}    ${E2E_OTHER}[month]    ${E2E_OTHER}[year]
    Salary Account Payslip No Options Should Contain    ${E2E_OTHER}[no]


*** Keywords ***
Log Step
    [Arguments]    ${text}
    Log To Console    \n>>> ${text}
    Log    ${text}

# ===========================================================================
# Suite / test setup
# ===========================================================================
Prepare E2E Data
    Start Browser
    Open Fresh Page
    Login With Credentials    ${VALID_USERNAME}    ${VALID_PASSWORD}
    Dashboard Should Be Open
    ${month_a}    ${year_a}=    Find Free Payslip Month    2
    ${ps}=    Create Payslip Fixture    ${month_a}    ${year_a}    employee_count=2
    ...    payment=AUTO    remarks=E2E fixture remarks
    ${key_a}=    Set Variable    ${month_a}-${year_a}
    ${month_b}    ${year_b}=    Find Free Payslip Month    1    ${key_a}
    ${other}=    Create Payslip Fixture    ${month_b}    ${year_b}    employee_count=1
    Set Suite Variable    ${E2E_PS}    ${ps}
    Set Suite Variable    ${E2E_OTHER}    ${other}
    Set Suite Variable    ${FIXTURES_READY}    ${True}
    Close Test Context

Clean Up E2E Data
    Run Keyword And Ignore Error    Close Test Context
    IF    ${CLEANUP_TEST_DATA} and ${FIXTURES_READY}
        Run Keyword And Ignore Error    Delete E2E Data
    END
    Close Browser

Delete E2E Data
    Open Fresh Page
    Login With Credentials    ${VALID_USERNAME}    ${VALID_PASSWORD}
    Dashboard Should Be Open
    @{payslip_nos}=    Create List    ${E2E_PS}[no]    ${E2E_OTHER}[no]
    Delete Test Payslips    ${SALARY_ACCOUNT_LIST_PATH}    ${CREATED_SALARY_ACCOUNT_NOS}    ${payslip_nos}
    Close Test Context

Open Salary Account Form
    Open Fresh Page
    Login With Credentials    ${VALID_USERNAME}    ${VALID_PASSWORD}
    Dashboard Should Be Open
    Reopen Salary Account Form

Reopen Salary Account Form
    Go To Page    ${SALARY_ACCOUNT_FORM_PATH}
    Salary Account Form Should Be Visible

Finish Test
    Run Keyword If Test Failed    Take Screenshot
    Close Test Context

# ===========================================================================
# Helpers
# ===========================================================================
Salary Account Should Show Details Of Payslip
    [Documentation]    Checks every auto patched field and the preview against one payslip dictionary.
    [Arguments]    ${payslip}
    Salary Account Details Should Be Populated
    Salary Account Payslip No Should Be    ${payslip}[no]
    ${group_count}=    Get Length    ${payslip}[groups]
    Dropdown Total Selected Count Should Be    ${GROUP_DD}    ${group_count}
    Verify Payment Through    ${payslip}[payment]
    Dropdown Total Selected Count Should Be    ${EMPLOYEE_DD}    ${payslip}[employee_count]
    Salary Account Remarks Should Be    ${payslip}[remarks]
    Salary Account Preview Should Be Visible
    ${employees}=    Set Variable    ${payslip}[employees]
    Salary Account Preview Should Contain Employees    @{employees}
    Preview Row Count Should Be    ${payslip}[employee_count]

Verify Payment Through
    [Arguments]    ${expected}
    IF    $expected == ''
        Dropdown Should Have No Selected Value    ${PAYMENT_DD}
    ELSE
        Salary Account Payment Through Should Be    ${expected}
    END

Auto Populated Fields Should Be Empty
    Dropdown Should Have No Selected Value    ${GROUP_DD}
    Dropdown Should Have No Selected Value    ${PAYMENT_DD}
    Dropdown Should Have No Selected Value    ${EMPLOYEE_DD}
    Salary Account Remarks Should Be    ${EMPTY}

Preview Row Count Should Be
    [Arguments]    ${expected}
    Wait Until Keyword Succeeds    10s    500ms    Verify Preview Row Count    ${expected}

Verify Preview Row Count
    [Arguments]    ${expected}
    ${count}=    Get Salary Account Preview Row Count
    Should Be Equal As Integers    ${count}    ${expected}