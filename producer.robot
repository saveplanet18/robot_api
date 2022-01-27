*** Settings ***
Documentation       Artificial Intelligence System robot.
...                 Author Manjunath Kannur
...                 Produces traffic data work items.

Library             RPA.HTTP
Library             RPA.JSON
Library             RPA.Tables
Library             Collections
Resource            shared.robot

*** Variables ***
${url_link}         https://github.com/robocorp/inhuman-insurance-inc/raw/main/RS_198.json
${json_file}        ${OUTPUT_DIR}${/}Data.json
${max_rate}=        ${5.0}
${both_genders}=    BTSX
${COUNTRY_KEY}=     SpatialDim
${GENDER_KEY}=      Dim1
${RATE_KEY}=        NumericValue
${YEAR_KEY}=        TimeDim


*** Tasks ***
Produce traffic data work items
    Download traffic data
    ${traffic_data}         Load Traffic data as table
    # Write table to CSV  ${Traffic_Data}     Data.CSV
    ${Filter_Data}          Filter and sort traffic data                ${traffic_data} 
    ${Get_Data}             Get latest data by country                  ${Filter_Data}
    ${payloads}=            Create work item payloads                   ${Get_Data} 
    Save work item payloads    ${payloads}



*** Keywords ***
Download traffic data
    Download
    ...         ${url_link}
    ...         ${json_file}
    ...         overwrite=True

*** Keywords ***
Load Traffic data as table
    ${json}=    Load JSON from file    ${json_file}
    ${Data_table}=    Create Table    ${json}[value]
    [Return]    ${Data_table}


*** Keywords ***
Filter and sort traffic data
    [Arguments]     ${table}
    Filter Table By Column      ${table}        ${RATE_KEY}    <    ${max_rate}
    Filter Table By Column      ${table}        ${GENDER_KEY}      ==    ${both_genders}
    Sort Table By Column        ${table}        ${YEAR_KEY}     False
    [Return]    ${table}


*** Keywords ***
Get latest data by country
    [Arguments]    ${table}
    ${table}=    Group Table By Column    ${table}    ${country_key}
    ${latest_data_by_country}=    Create List
    FOR    ${group}    IN    @{table}
        ${first_row}=    Pop Table Row    ${group}
        Append To List    ${latest_data_by_country}    ${first_row}
    END
    [Return]    ${latest_data_by_country}

*** Keywords ***
Create work item payloads
    [Arguments]    ${traffic_data}
    ${payloads}=    Create List
    FOR    ${row}    IN    @{traffic_data}
        ${payload}=
        ...    Create Dictionary
        ...    country=${row}[SpatialDim]
        ...    year=${row}[TimeDim]
        ...    rate=${row}[NumericValue]
        Append To List    ${payloads}    ${payload}
    END
    [Return]    ${payloads}

*** Keywords ***
Save work item payloads
    [Arguments]    ${payloads}
    FOR    ${payload}    IN    @{payloads}
        Save work item payload    ${payload}
    END

*** Keywords ***
Save work item payload
    [Arguments]    ${payload}
    Create Output Work Item
    Set Work Item Variable    ${WORK_ITEM_NAME}    ${payload}
    Save Work Item