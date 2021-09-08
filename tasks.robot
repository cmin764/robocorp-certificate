*** Settings ***
Documentation     Orders robots from RobotSpareBin Industries Inc.
...               Saves the order HTML receipt as a PDF file.
...               Saves the screenshot of the ordered robot.
...               Embeds the screenshot of the robot to the PDF receipt.
...               Creates ZIP archive of the receipts and the images.

Library           RPA.Browser.Selenium
Suite Teardown    Close All Browsers


*** Variables ***
${order_url}    https://robotsparebinindustries.com/#/robot-order


*** Keywords ***
Open the robot order website
    Open Available Browser    ${order_url}
    Wait Until Element Is Visible    class:modal-content
    Click Button    class:btn-dark


*** Tasks ***
Order robots from RobotSpareBin Industries Inc
    Open the robot order website
    # ${orders}=    Get orders
    # FOR    ${row}    IN    @{orders}
    #     Close the annoying modal
    #     Fill the form    ${row}
    #     Preview the robot
    #     Submit the order
    #     ${pdf}=    Store the receipt as a PDF file    ${row}[Order number]
    #     ${screenshot}=    Take a screenshot of the robot    ${row}[Order number]
    #     Embed the robot screenshot to the receipt PDF file    ${screenshot}    ${pdf}
    #     Go to order another robot
    # END
    # Create a ZIP file of the receipts
