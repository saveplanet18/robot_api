*** Settings ***
Documentation       Artificial Intelligence System robot.
...                 Author Manjunath Kannur
...                 Produces traffic data work items.


Resource          shared.robot

*** Tasks ***
Consumer traffic data work items
    For Each Input Work Item    Process traffic data


*** Keywords ***
Process traffic data
    ${payload}=    Get Work Item Payload
    ${traffic_data}=    Set Variable    ${payload}[${WORK_ITEM_NAME}]