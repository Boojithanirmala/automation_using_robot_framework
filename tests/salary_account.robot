*** Settings ***
Documentation     Salary Account form test suite.
Library           Browser
Resource          ../resources/common.resource
Resource            ../resources/pages/login_page.resource
Resource            ../resources/pages/dashboard.resource
Resource          ../resources/components/dropdown.resource
Resource          ../resources/components/common_form.resource
Resource          ../resources/pages/salaryAccount_page.resource

Suite Setup         Open Application And Login
Suite Teardown      Close Browser
Test Setup          Open Salary Account Page
Test Teardown       Close Test Context

*** Variables ***
# --- Month that HAS payslips ----------------------------------------------
${MONTH}                      May
${YEAR}                       2027
${EXPECTED_MONTH_VALUE}       2027-05
${PAYSLIP_NO}                 PS/2026/0009
# A second payslip in the same month (needed for the "only one payslip" test)
${SECOND_PAYSLIP_NO}          PS/2026/0010

# --- Month that has NO payslips -------------------------------------------
${EMPTY_MONTH}                January
${EMPTY_YEAR}                 2030

# --- Payslip used by the create test (consumed once it is saved) ----------
${CREATE_MONTH}               May
${CREATE_YEAR}                2027
${CREATE_PAYSLIP_NO}          PS/2026/0009

# --- Expected auto populated data for ${PAYSLIP_NO} -------------------------
@{EXPECTED_SALARY_GROUPS}     RTFI    PAUT    WQT    Full Salary    PWHT    DEEM/NDT    Half Salary    Office    NDT
# TODO: set the real Payment Through value of the payslip
${EXPECTED_PAYMENT_THROUGH}   Bank Transfer
${EXPECTED_REMARKS}           ${EMPTY}

# --- Expected preview data ---------------------------------------------------
${EMPLOYEE_1}                 0343 | HARI PRASATH RAJU
${EMPLOYEE_1_NET_SALARY}      500.00
${EMPLOYEE_2}                 0344 | RAJAVEL SUBRAMANIAN
${EMPLOYEE_2_NET_SALARY}      500.00
${EMPLOYEE_3}                 0350 | AHMED SALEM A AL NASHAMA
${EMPLOYEE_3_NET_SALARY}      1,000.00

*** Keywords ***
Open Payslip Form
    Open Fresh Page
    Login With Credentials    ${VALID_USERNAME}    ${VALID_PASSWORD}
    Dashboard Should Be Open
    Go To Page    /dynamicformadd/payslipForm

*** Test Cases ***
# ===========================================================================
# Page load
# ===========================================================================
Verify Salary Account Form Is Displayed
    [Tags]    smoke    ui
    Salary Account Form Should Be Visible

Verify Salary Account Number Is Auto Generated And Read Only
    [Tags]    ui
    Salary Account Number Should Be Read Only
    Salary Account Number Should Match Pattern

# ===========================================================================
# Payable month picker
# ===========================================================================
Verify Month Picker Shows All Months
    [Tags]    month_picker
    Open Salary Account Payable Month Picker
    Salary Account Month Picker Should Show All Months

Verify Payable Month Can Be Selected
    [Tags]    month_picker    smoke
    Select Salary Account Payable Month    ${MONTH}    ${YEAR}
    Salary Account Payable Month Should Be    ${EXPECTED_MONTH_VALUE}

Verify Year Can Be Typed In The Month Picker
    [Tags]    month_picker
    Open Salary Account Payable Month Picker
    Set Salary Account Picker Year    ${YEAR}
    Salary Account Picker Year Should Be    ${YEAR}

Verify Year Can Be Changed Using Keyboard Arrow Keys
    [Tags]    month_picker
    Open Salary Account Payable Month Picker
    Set Salary Account Picker Year    ${YEAR}
    Change Salary Account Picker Year Using Keyboard    Up    2
    ${expected_year}=    Evaluate    int(${YEAR}) + 2
    Salary Account Picker Year Should Be    ${expected_year}
    Change Salary Account Picker Year Using Keyboard    Down    1
    ${expected_year}=    Evaluate    int(${YEAR}) + 1
    Salary Account Picker Year Should Be    ${expected_year}

Verify Year Can Be Changed Using Next And Previous Arrows
    [Tags]    month_picker
    Open Salary Account Payable Month Picker
    Set Salary Account Picker Year    ${YEAR}
    Click Salary Account Picker Next Arrow
    ${expected_year}=    Evaluate    int(${YEAR}) + 1
    Salary Account Picker Year Should Be    ${expected_year}
    Click Salary Account Picker Previous Arrow
    Click Salary Account Picker Previous Arrow
    ${expected_year}=    Evaluate    int(${YEAR}) - 1
    Salary Account Picker Year Should Be    ${expected_year}

# ===========================================================================
# Payslip No dropdown
# ===========================================================================
Verify Payslip Dropdown Lists Payslips Of The Selected Month
    [Tags]    payslip
    Select Salary Account Payable Month    ${MONTH}    ${YEAR}
    Salary Account Payslip No Options Should Contain    ${PAYSLIP_NO}

Verify Payslip Dropdown Is Empty When Month Has No Payslips
    [Tags]    payslip
    Select Salary Account Payable Month    ${EMPTY_MONTH}    ${EMPTY_YEAR}
    Salary Account Payslip No Options Should Be Empty

Verify Payslip Dropdown Search Works
    [Tags]    payslip    dropdown
    Select Salary Account Payable Month    ${MONTH}    ${YEAR}
    Open Dropdown    ${SALARY_ACCOUNT_PAYSLIP_NO_DROPDOWN}
    Search Dropdown Options    ${SALARY_ACCOUNT_PAYSLIP_NO_DROPDOWN}    ${PAYSLIP_NO}
    Dropdown Options Should Be Visible    ${PAYSLIP_NO}

Verify Payslip Options Change When Month Changes
    [Tags]    payslip
    Select Salary Account Payable Month    ${MONTH}    ${YEAR}
    Salary Account Payslip No Options Should Contain    ${PAYSLIP_NO}
    Select Salary Account Payable Month    ${EMPTY_MONTH}    ${EMPTY_YEAR}
    Salary Account Payslip No Options Should Be Empty

Verify Only One Payslip Can Be Selected
    [Documentation]    Needs two payslips in the same month (${PAYSLIP_NO} and ${SECOND_PAYSLIP_NO}).
    [Tags]    payslip
    Select Salary Account Payable Month    ${MONTH}    ${YEAR}
    Select Salary Account Payslip No    ${PAYSLIP_NO}    ${PAYSLIP_NO}
    Select Salary Account Payslip No    ${SECOND_PAYSLIP_NO}    ${SECOND_PAYSLIP_NO}
    Salary Account Payslip No Should Be    ${SECOND_PAYSLIP_NO}
    Dropdown Should Not Have Selected Value    ${SALARY_ACCOUNT_PAYSLIP_NO_DROPDOWN}    ${PAYSLIP_NO}

# ===========================================================================
# Auto populated fields
# ===========================================================================
Verify Details Are Auto Populated After Selecting Payslip
    [Tags]    auto_populate    smoke
    Fill Salary Account Form    ${MONTH}    ${YEAR}    ${PAYSLIP_NO}
    Salary Account Salary Groups Should Be Selected    @{EXPECTED_SALARY_GROUPS}
    Salary Account Payment Through Should Be    ${EXPECTED_PAYMENT_THROUGH}
    Salary Account Remarks Should Be    ${EXPECTED_REMARKS}

Verify Auto Populated Fields Are Not Editable
    [Tags]    auto_populate
    Fill Salary Account Form    ${MONTH}    ${YEAR}    ${PAYSLIP_NO}
    Salary Account Auto Populated Fields Should Be Non Editable

# ===========================================================================
# Preview
# ===========================================================================
Verify Preview Is Displayed After Selecting Payslip
    [Tags]    preview
    Fill Salary Account Form    ${MONTH}    ${YEAR}    ${PAYSLIP_NO}
    Salary Account Preview Should Be Visible
    Salary Account Preview Should Contain Employees    ${EMPLOYEE_1}    ${EMPLOYEE_2}    ${EMPLOYEE_3}

Verify Preview Shows Net Salary For Each Employee
    [Tags]    preview
    Fill Salary Account Form    ${MONTH}    ${YEAR}    ${PAYSLIP_NO}
    Salary Account Preview Net Salary Should Be    ${EMPLOYEE_1}    ${EMPLOYEE_1_NET_SALARY}
    Salary Account Preview Net Salary Should Be    ${EMPLOYEE_2}    ${EMPLOYEE_2_NET_SALARY}
    Salary Account Preview Net Salary Should Be    ${EMPLOYEE_3}    ${EMPLOYEE_3_NET_SALARY}

# ===========================================================================
# Validation
# ===========================================================================
Verify Required Messages On Empty Submit
    [Tags]    validation
    Click Save Button
    Salary Account Payable Month Required Message Should Be Visible
    Salary Account Payslip No Required Message Should Be Visible

Verify Payslip Required Message When Only Month Is Selected
    [Tags]    validation
    Select Salary Account Payable Month    ${MONTH}    ${YEAR}
    Click Save Button
    Salary Account Payslip No Required Message Should Be Visible
    Salary Account Payable Month Required Message Should Not Be Visible

# ===========================================================================
# Reset / navigation
# ===========================================================================
Verify Reset Button Clears The Form
    [Tags]    reset
    Fill Salary Account Form    ${MONTH}    ${YEAR}    ${PAYSLIP_NO}
    Click Reset Button
    Salary Account Form Should Be Reset

Verify Back Button Navigates Away From The Form
    [Tags]    navigation
    Click Back Button
    # Verify the list page here.

# ===========================================================================
# Save + one salary account per payslip
# ===========================================================================
Verify Salary Account Can Be Created For A Payslip
    [Documentation]    Consumes ${CREATE_PAYSLIP_NO}. Use a fresh payslip for every run.
    [Tags]    save    smoke
    Fill Salary Account Form    ${CREATE_MONTH}    ${CREATE_YEAR}    ${CREATE_PAYSLIP_NO}
    Click Save Button
    Data Created Toast Should Be Visible

Verify Saved Payslip Is Not Listed Again For The Same Month
    [Documentation]    One salary account per payslip: after saving, the same month must not
    ...                list the same payslip no. Uses a payslip that was already saved.
    [Tags]    save    business_rule
    Select Salary Account Payable Month    ${CREATE_MONTH}    ${CREATE_YEAR}
    Salary Account Payslip No Options Should Not Contain    ${CREATE_PAYSLIP_NO}


*** Keywords ***
Open Application And Login
    [Documentation]    Replace with your project's existing login keyword.
    New Browser    chromium    headless=False
    New Context    viewport={'width': 1920, 'height': 1080}
    New Page    ${BASE_URL}

Open Salary Account Page
    [Documentation]    Replace with your project's navigation keyword / URL.
    Go To    ${BASE_URL}/salary-account/add
    Salary Account Form Should Be Visible