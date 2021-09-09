*** Settings ***
Documentation     Orders robots from RobotSpareBin Industries Inc.
...               Saves the order HTML receipt as a PDF file.
...               Saves the screenshot of the ordered robot.
...               Embeds the screenshot of the robot to the PDF receipt.
...               Creates ZIP archive of the receipts and the images.

Library           RPA.Browser.Selenium
Library           RPA.HTTP
Library           RPA.Tables
Library           RPA.PDF
Library           Collections

Suite Teardown    Close All Browsers


*** Variables ***
${order_url}    https://robotsparebinindustries.com/#/robot-order
${csv_url}      https://robotsparebinindustries.com/orders.csv
${csv_file}     ${OUTPUT_DIR}${/}orders.csv


*** Keywords ***
Open the robot order website
    Open Available Browser    ${order_url}

Close consent modal
    Wait Until Element Is Visible    class:modal-content
    Click Button    class:btn-dark

Get orders
    Download    ${csv_url}    ${csv_file}    overwrite=True
    ${table}=    Read table from CSV    ${csv_file}
    [Return]    ${table}

Fill the form
    [Arguments]    ${row}
    Select From List By Value    name:head    ${row}[Head]
    Select Radio Button    body    ${row}[Body]
    Input Text    xpath://input[@type="number"]    ${row}[Legs]
    Input Text    name:address    ${row}[Address]

Preview the robot
    Click Button    id:preview

Submit the order
    Click Button    id:order
    FOR    ${i}    IN RANGE    9999999
        ${success}=    Is Element Visible    id:receipt
        Exit For Loop If    ${success}
        Click Button    id:order
    END
    Click Button    id:order-another


*** Tasks ***
Order robots from RobotSpareBin Industries Inc
    Open the robot order website
    Close consent modal

    ${orders} =    Get orders
    FOR    ${row}    IN    @{orders}
        Fill the form    ${row}
        Preview the robot
        Submit the order
        Close consent modal
    #     ${pdf}=    Store the receipt as a PDF file    ${row}[Order number]
    #     ${screenshot}=    Take a screenshot of the robot    ${row}[Order number]
    #     Embed the robot screenshot to the receipt PDF file    ${screenshot}    ${pdf}
        # Go to order another robot
    END
    # Create a ZIP file of the receipts
