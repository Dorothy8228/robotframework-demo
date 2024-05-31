*** Settings ***
Library    RequestsLibrary
Documentation   Test suite for demo purposes: (1) Verify HTTP Methods
*** Variables ***
#${baseURL}      http://localhost
${baseURL}      https://httpbin.org
*** Test Cases ***
TC1: Verify for HTTP Method - DELETE
    verifyByMethod   delete
TC2: Verify for HTTP Method - GET
    verifyByMethod   get
TC3: Verify for HTTP Method - PATCH
    verifyByMethod   patch
TC4: Verify for HTTP Method - POST
    verifyByMethod   post
TC5: Verify for HTTP Method - POST
    verifyByMethod   put

*** Keywords ***
verifyByMethod
    [Arguments]     ${method}
    ${method}=    Set Variable    ${method}
    ${response}=    Run Keyword If    '${method}' == 'delete'   Delete         ${baseURL}/delete
    ...             ELSE IF    '${method}' == 'get'      Get            ${baseURL}/get
    ...             ELSE IF    '${method}' == 'patch'    Patch          ${baseURL}/patch
    ...             ELSE IF    '${method}' == 'post'     Post           ${baseURL}/post
    ...             ELSE IF    '${method}' == 'put'      Put            ${baseURL}/put
    
    Should Be Equal As Strings    ${response.status_code}    200
    Should Be Equal As Strings    ${response.headers['Content-Type']}    application/json
    Should Be Equal As Strings    ${response.json()['url']}    ${baseURL}/${method}
    Should Be Equal As Strings    ${response.json()['json']}    None