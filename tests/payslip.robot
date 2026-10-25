*** Settings ***
Documentation       Payslip form UI smoke tests.

Resource            ../resources/common.resource
Resource            ../resources/pages/login_page.resource
Resource            ../resources/pages/dashboard.resource
Resource            ../resources/pages/payslip_page.resource

Suite Setup         Start Browser
Suite Teardown      Close Browser
Test Setup          Open Payslip Form
Test Teardown       Close Test Context


*** Variables ***
${PAYSLIP_MONTH}        October
${PAYSLIP_YEAR}         2026
${TEST_REMARKS}         Automation test remarks

*** Keywords ***
Open Payslip Form
    Open Fresh Page
    Login With Credentials    ${VALID_USERNAME}    ${VALID_PASSWORD}
    Dashboard Should Be Open
    Go To Page    /dynamicformadd/payslipForm

*** Test Cases ***

Verify Payslip Form Fields Are Visible
    [Documentation]    Verify the main Payslip form controls are available.
    [Tags]    payslip    smoke

    Wait For Elements State    ${PAYSLIP_NO_INPUT}    visible
    Wait For Elements State    ${PAYSLIP_PAYABLE_MONTH_INPUT}    visible
    Wait For Elements State    ${PAYSLIP_REMARKS_TEXTAREA}    visible
    Wait For Elements State    ${PAYSLIP_EMPLOYEES_DROPDOWN}    visible
    Wait For Elements State    ${PAYSLIP_SALARY_GROUP_DROPDOWN}    visible
    Wait For Elements State    ${PAYSLIP_PAYMENT_THROUGH_DROPDOWN}    visible

Verify Payable Month Can Be Selected
    [Documentation]    Verify the month picker selects October 2026.
    [Tags]    payslip    payable-month

    Select Payslip Payable Month    ${PAYSLIP_MONTH}    ${PAYSLIP_YEAR}

Verify Remarks Can Be Entered
    [Documentation]    Verify remarks can be entered and read back.
    [Tags]    payslip    remarks

    Enter Payslip Remarks    ${TEST_REMARKS}

Verify Salary Group Dropdown Can Be Opened
    [Documentation]    Verify the Salary Group dropdown opens.
    [Tags]    payslip    dropdown

    Open Dropdown    ${PAYSLIP_SALARY_GROUP_DROPDOWN}
    Wait For Elements State
    ...    ${PAYSLIP_SALARY_GROUP_DROPDOWN}
    ...    visible

    Click    ${PAYSLIP_SALARY_GROUP_DROPDOWN}

Verify Payment Through Dropdown Can Be Opened
    [Documentation]    Verify the Payment Through dropdown opens.
    [Tags]    payslip    dropdown

    Open Dropdown    ${PAYSLIP_PAYMENT_THROUGH_DROPDOWN}
    Wait For Elements State
    ...    ${PAYSLIP_PAYMENT_THROUGH_DROPDOWN}
    ...    visible

    Click    ${PAYSLIP_PAYMENT_THROUGH_DROPDOWN}
