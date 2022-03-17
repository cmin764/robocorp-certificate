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
Library           OperatingSystem
Library           RPA.Archive
Library           RPA.Dialogs
Library           RPA.Robocorp.Vault

Suite Teardown    Close All Browsers


*** Variables ***
# ${robot_order_url}       https://robotsparebinindustries.com/#/robot-order
${orders_url}         https://robotsparebinindustries.com/orders.csv
${orders_file}        ${OUTPUT_DIR}${/}orders.csv
${receipts_dir}    ${OUTPUT_DIR}${/}receipts${/}
${receipts_zip}    ${OUTPUT_DIR}${/}receipts.zip


*** Keywords ***
Open the robot order website
    ${urls} =    Get Secret    urls
    Open Available Browser    ${urls}[robot_order]

Close consent modal
    Wait Until Element Is Visible    class:modal-content
    Click Button    class:btn-dark

Get or download orders
    Add icon    Warning
    Add heading    Use existing orders file or download new one?
    Add text input    orders_file
    ...    label=Orders CSV File
    ...    placeholder=${orders_file}
    Add submit buttons    buttons=Existing,Download    default=Existing
    
    ${result} =    Run dialog
    IF   "${result.submit}" == "Existing"
        ${input_file} =     Set Variable If    "${result.orders_file}" != ""    ${result.orders_file}    ${orders_file}
        Set Test Variable    ${orders_file}    ${input_file}
    ELSE
        Download    ${orders_url}    ${orders_file}    overwrite=True
    END

    ${table} =    Read table from CSV    ${orders_file}
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
        ${success} =    Is Element Visible    id:receipt
        Exit For Loop If    ${success}
        Click Button    id:order
    END

Go to order another robot
    Click Button    id:order-another
    Close consent modal


*** Keywords ***
Store the receipt as a PDF file
    [Arguments]    ${order_nr}
    ${pdf_path} =    Set Variable    ${receipts_dir}${order_nr}.pdf
    Wait Until Element Is Visible    id:receipt
    ${receipt_html} =    Get Element Attribute    id:receipt    outerHTML
    Html To Pdf    ${receipt_html}    ${pdf_path}
    [Return]    ${pdf_path}

Take a screenshot of the robot
    [Arguments]    ${order_nr}
    ${ss_path} =    Set Variable    ${receipts_dir}${order_nr}.png
    Screenshot    locator=id:robot-preview-image    filename=${ss_path}
    [Return]    ${ss_path}

Embed the robot screenshot to the receipt PDF file
    [Arguments]    ${ss}    ${pdf}
    ${files} =    Create List
    ...    ${ss}
    Add Files To PDF    ${files}    ${pdf}    append=True
    Close All Pdfs
    Remove File    ${ss}

Create a ZIP file of the receipts
    Archive Folder With Zip    ${receipts_dir}    ${receipts_zip}


*** Tasks ***
Test
    # Embed the robot screenshot to the receipt PDF file    ${receipts_dir}1.png    ${receipts_dir}1.pdf
    # Create a ZIP file of the receipts
    Log    Done

Order robots from RobotSpareBin Industries Inc
    ${orders} =    Get or download orders

    Open the robot order website
    Close consent modal

    FOR    ${row}    IN    @{orders}
        Fill the form    ${row}
        Preview the robot
        Submit the order
        ${pdf} =    Store the receipt as a PDF file    ${row}[Order number]
        ${screenshot} =    Take a screenshot of the robot    ${row}[Order number]
        Embed the robot screenshot to the receipt PDF file    ${screenshot}    ${pdf}
        Go to order another robot
        # Exit For Loop    # debugging reasons
    END
    Create a ZIP file of the receipts
