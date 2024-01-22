*** Settings ***
Library     SeleniumLibrary
Library     OperatingSystem
Library     ExcelLibrary
Library     String
Library     Collections
Library     AutoRecorder      mode=suite  #suite,test
#Library     Process
#Library     RPA.Excel.Files
#Resource    CommonKeywords.robot

Test Setup       Open Test page
Test Teardown    Teardown
*** Variables ***
${ExcelFile}        ./Template_ScreenName.xlsx    
${msg_css}          css=.hs-error-msg
${SheetName}        Define
${maxnum}           20

*** Test Cases ***
TC01
    [Documentation]  This script is used to get locators of items defined in excel file. Depends on checkType, 
    ...     execute validation check then return result to excel file
    Validation check for items in excel file
    
    [Teardown]  Run Keywords  Close Browser     Close All Excel Documents
*** Keywords ***
Open Test page
    Open Excel file     ${ExcelFile}
    ${rd}   Get data row from Excel file    1
    #Record Video
    Open Browser     ${rd}[1]    chrome      #headless
    Maximize Browser Window
Open Excel file
    [Arguments]     ${ExcelFile} 
    ${i}=  generate random string  1  [NUMBERS]
    ${doc_id}   Open Excel Document  ${ExcelFile}     doc_id=docid${i}
    [Return]    ${doc_id}

Get data row from Excel file
    [Arguments]     ${rowNum}
    ${rd}=	Read Excel Row	    row_num=${rowNum}	max_num=${maxnum}	sheet_name=${SheetName}
    [Return]    ${rd}

Get data col from Excel file
    [Arguments]     ${colNum}
    ${cd}=	Read Excel Column	col_num=${colNum}	max_num=${maxnum}	sheet_name=${SheetName}
    [Return]    ${cd}

Execute Function by checkType
    [Arguments]     ${i}
    #Get Testing data row
    ${rd}   Get data row from Excel file    ${i}
    #${list}    Create List    required    maxlength     Dateformat
    ${element}=    Set Variable    ${rd}[3]
    Run Keyword If  '${element}' == 'required'      Run Keyword       Verify Required Check     ${i}
    ...    ELSE IF  '${element}' == 'maxlength'     Run Keyword       Write and save to Excel     ${i}    Function_maxlength is Executed     10   #write result to column Note
    ...    ELSE IF  '${element}' == 'Dateformat'    Run Keyword       Log    Function3 is Executed
    ...    ELSE    Log    Function is not defined

Verify required Check
    [Documentation]  This test case validates Required Check for item in row(i) in excel file
    [Arguments]     ${i}
    #Get Testing data row
    ${rd}   Get data row from Excel file    ${i}
    #Get Testing data col
    ${cd}   Get data col from Excel file    2
    Click Element       ${rd}[1]    #txtbox firstname
    Click Button        ${cd}[14]   #bt Submit
    ${actualText}    Get Text    ${msg_css}
    #Should Be Equal As Strings    ${message}    ${rd}[7]
    ${expectedText}    Set Variable    ${rd}[7]
    Run Keyword If    "${actualText}" == "${expectedText}"
    ...    Write and save to Excel      ${i}    OK    9     #write result to column Result 
    ...    ELSE
    ...    Result is NG      ${i}   ${actualText}

Write and save to Excel
    [Arguments]     ${i}    ${value}    ${colNum}
    ${rowOffset}    Evaluate    ${i}-1
    Write Excel Column    col_num=${colNum}    row_offset=${rowOffset}      col_data=['${value}']      sheet_name=${SheetName}
    Save Excel Document	    filename=${ExcelFile}

Result is NG
    [Arguments]     ${i}    ${actualText}
    Write and save to Excel     ${i}    NG          9    #write result to column Result
    ${note}     Set Variable    Actual Text: ${actualText}
    Write and save to Excel     ${i}    ${note}     10   #write result to column Note
    ${Img}     Capture Page Screenshot
    Write and save to Excel     ${i}    ${Img}      11   #write Img path to column Note
    #Log    NG: Expected Text: ${expectedText}, Actual Text: ${actualText}
Remove None
    [Arguments]     ${original_list}
    ${filtered_list} =    Remove values from list    ${original_list}    ${None}
    [Return]        ${original_list}
Verify maxlength Check
    [Arguments]     ${i}
    Input Text      ${locator}[0]      ${inputText}

Validation check for items in excel file
    ${list_to_check}   Get data col from Excel file    2    #column:itemName
    FOR    ${index}    IN RANGE    2    ${list_to_check.__len__()}
        ${value}    Set Variable    ${list_to_check}[${index}]
        Run Keyword If    "${value}" != "None"    Execute Function by checkType   ${index}
        ...    ELSE    Exit For Loop
    END
