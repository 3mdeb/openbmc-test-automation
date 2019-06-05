*** Settings ***
Documentation       Inventory of hardware FRUs under redfish/systems.

Resource            ../../lib/bmc_redfish_resource.robot
Resource            ../../lib/bmc_redfish_utils.robot
Resource            ../../lib/openbmc_ffdc.robot
Library             ../../lib/gen_robot_valid.py

Suite Setup         Suite Setup Execution
Suite Teardown      Suite Teardown Execution
Test Teardown       Test Teardown Execution

*** Variables ***

# The passing criteria.  Must have at least this many.
${min_num_dimms}   2
${min_num_cpus}    1


*** Test Cases ***

Get Processor Inventory Via Redfish And Verify
    [Documentation]  Get the number of CPUs that are functional and enabled.
    [Tags]  Get_Processor_Inventory_Via_Redfish_And_Verify

    Verify FRU Inventory Minimums  Processors  ${min_num_cpus}


Get Memory Inventory Via Redfish And Verify
    [Documentation]  Get the number of DIMMs that are functional and enabled.
    [Tags]  Get_Memory_Inventory_Via_Redfish_And_Verify

    Verify FRU Inventory Minimums  Memory  ${min_num_dimms}


Get Serial And Verify Populated
    [Documentation]  Check that the SerialNumber is non-blank.
    [Tags]  Get_Serial_And_Verify_Populated

    ${serial_number}=  Redfish.Get Attribute  ${SYSTEM_BASE_URI}  SerialNumber
    Rvalid Value  serial_number
    Rprint Vars  serial_number


Get Model And Verify Populated
    [Documentation]  Check that the Model is non-blank.
    [Tags]  Get_Model_And_Verify_Populated

    ${model}=  Redfish.Get Attribute  ${SYSTEM_BASE_URI}  Model
    Rvalid Value  model
    Rprint Vars  model


*** Keywords ***


Verify FRU Inventory Minimums
    [Documentation]  Verify a minimun number of FRUs.
    [Arguments]  ${fru_type}  ${min_num_frus}

    # Description of Argument(s):
    # fru_type      The type of FRU (e.g. "Processors", "Memory", etc.).
    # min_num_frus  The minimum acceptable number of FRUs found.

    # A valid FRU  will have a "State" key of "Enabled" and a "Health" key
    # of "OK".

    ${status}  ${num_valid_frus}=  Run Key U  Get Num Valid FRUs \ ${fru_type}

    Return From Keyword If  ${num_valid_frus} >= ${min_num_frus}
    Fail  Too few "${fru_type}" FRUs found, found only ${num_valid_frus}.


Suite Teardown Execution
    [Documentation]  Do the post suite teardown.

    Redfish.Logout


Suite Setup Execution
    [Documentation]  Do test case setup tasks.

    Redfish.Login
    Printn


Test Teardown Execution
    [Documentation]  Do the post test teardown.

    FFDC On Test Case Fail
