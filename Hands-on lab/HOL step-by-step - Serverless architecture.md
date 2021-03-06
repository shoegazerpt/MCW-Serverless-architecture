![Microsoft Cloud Workshops](https://github.com/Microsoft/MCW-Template-Cloud-Workshop/raw/master/Media/ms-cloud-workshop.png 'Microsoft Cloud Workshops')

<div class="MCWHeader1">
Serverless architecture
</div>

<div class="MCWHeader2">
Hands-on lab step-by-step
</div>

<div class="MCWHeader3">
November 2019
</div>

Information in this document, including URL and other Internet Web site references, is subject to change without notice. Unless otherwise noted, the example companies, organizations, products, domain names, e-mail addresses, logos, people, places, and events depicted herein are fictitious, and no association with any real company, organization, product, domain name, e-mail address, logo, person, place or event is intended or should be inferred. Complying with all applicable copyright laws is the responsibility of the user. Without limiting the rights under copyright, no part of this document may be reproduced, stored in or introduced into a retrieval system, or transmitted in any form or by any means (electronic, mechanical, photocopying, recording, or otherwise), or for any purpose, without the express written permission of Microsoft Corporation.

Microsoft may have patents, patent applications, trademarks, copyrights, or other intellectual property rights covering subject matter in this document. Except as expressly provided in any written license agreement from Microsoft, the furnishing of this document does not give you any license to these patents, trademarks, copyrights, or other intellectual property.

The names of manufacturers, products, or URLs are provided for informational purposes only and Microsoft makes no representations and warranties, either expressed, implied, or statutory, regarding these manufacturers or the use of the products with any Microsoft technologies. The inclusion of a manufacturer or product does not imply endorsement of Microsoft of the manufacturer or product. Links may be provided to third party sites. Such sites are not under the control of Microsoft and Microsoft is not responsible for the contents of any linked site or any link contained in a linked site, or any changes or updates to such sites. Microsoft is not responsible for webcasting or any other form of transmission received from any linked site. Microsoft is providing these links to you only as a convenience, and the inclusion of any link does not imply endorsement of Microsoft of the site or the products contained therein.

© 2019 Microsoft Corporation. All rights reserved.

Microsoft and the trademarks listed at <https://www.microsoft.com/legal/intellectualproperty/Trademarks/Usage/General.aspx> are trademarks of the Microsoft group of companies. All other trademarks are property of their respective owners.

**Contents**

<!-- TOC -->

- [Serverless architecture hands-on lab step-by-step](#serverless-architecture-hands-on-lab-step-by-step)
  - [Abstract and learning objectives](#abstract-and-learning-objectives)
  - [Overview](#overview)
  - [Solution architecture](#solution-architecture)
  - [Exercise 1: Azure data, storage, and serverless environment setup](#exercise-1-azure-data-storage-and-serverless-environment-setup)
    - [Task 1: Verify resources are created](#task-1-verify-resources-are-created)
    
  - [Exercise 2: Develop and publish the photo processing and data export functions](#exercise-2-develop-and-publish-the-photo-processing-and-data-export-functions)
  - [Exercise 3: Create functions in the portal](#exercise-3-create-functions-in-the-portal)
    - [Task 1: Create function to save license plate data to Azure Cosmos DB](#task-1-create-function-to-save-license-plate-data-to-azure-cosmos-db)
    - [Task 2: Add an Event Grid subscription to the SavePlateData function](#task-2-add-an-event-grid-subscription-to-the-saveplatedata-function)
    - [Task 3: Add an Azure Cosmos DB output to the SavePlateData function](#task-3-add-an-azure-cosmos-db-output-to-the-saveplatedata-function)
    - [Task 4: Create function to save manual verification info to Azure Cosmos DB](#task-4-create-function-to-save-manual-verification-info-to-azure-cosmos-db)
    - [Task 5: Add an Event Grid subscription to the QueuePlateForManualCheckup function](#task-5-add-an-event-grid-subscription-to-the-queueplateformanualcheckup-function)
    - [Task 6: Add an Azure Cosmos DB output to the QueuePlateForManualCheckup function](#task-6-add-an-azure-cosmos-db-output-to-the-queueplateformanualcheckup-function)
    - [Task 7: Configure custom event types for the new Event Grid subscriptions](#task-7-configure-custom-event-types-for-the-new-event-grid-subscriptions)
  - [Exercise 4: Monitor your functions with Application Insights](#exercise-4-monitor-your-functions-with-application-insights)
    - [Task 1: Provision an Application Insights instance](#task-1-provision-an-application-insights-instance)
    - [Task 2: Enable Application Insights integration in your Function Apps](#task-2-enable-application-insights-integration-in-your-function-apps)
    - [Task 3: Use the Live Metrics Stream to monitor functions in real time](#task-3-use-the-live-metrics-stream-to-monitor-functions-in-real-time)
    - [Task 4: Observe your functions dynamically scaling when resource-constrained](#task-4-observe-your-functions-dynamically-scaling-when-resource-constrained)
  - [Exercise 5: Explore your data in Azure Cosmos DB](#exercise-5-explore-your-data-in-azure-cosmos-db)
    - [Task 1: Use the Azure Cosmos DB Data Explorer](#task-1-use-the-azure-cosmos-db-data-explorer)
  - [Exercise 6: Create the data export workflow](#exercise-6-create-the-data-export-workflow)
    - [Task 1: Create the Logic App](#task-1-create-the-logic-app)
  - [Exercise 8: Rerun the workflow and verify data export](#exercise-8-rerun-the-workflow-and-verify-data-export)
    - [Task 1: Run the Logic App](#task-1-run-the-logic-app)
    - [Task 2: View the exported CSV file](#task-2-view-the-exported-csv-file)

<!-- /TOC -->



# Serverless architecture hands-on lab step-by-step

## Abstract and learning objectives

In this hand-on lab, you will be challenged to implement an end-to-end scenario using a supplied sample that is based on Microsoft Azure Functions, Azure Cosmos DB, Event Grid, and related services. The scenario will include implementing compute, storage, workflows, and monitoring, using various components of Microsoft Azure. The hands-on lab can be implemented on your own, but it is highly recommended to pair up with other members at the lab to model a real-world experience and to allow each member to share their expertise for the overall solution.

At the end of the hands-on-lab, you will have confidence in designing, developing, and monitoring a serverless solution that is resilient, scalable, and cost-effective.

## Overview

Contoso Ltd. is rapidly expanding their toll booth management business to operate in a much larger area. As this is not their primary business, which is online payment services, they are struggling with scaling up to meet the upcoming demand to extract license plate information from a large number of new tollbooths, using photos of vehicles uploaded to cloud storage. Currently, they have a manual process where they send batches of photos to a 3rd-party who manually transcodes the license plates to CSV files that they send back to Contoso to upload to their online processing system. They want to automate this process in a way that is cost effective and scalable. They believe serverless is the best route for them, but do not have the expertise to build the solution.

## Solution architecture

Below is a diagram of the solution architecture you will build in this lab. Please study this carefully, so you understand the whole of the solution as you are working on the various components.

![The Solution diagram is described in the text following this diagram.](../Whiteboard%20design%20session/media/preferred-solution.png 'Solution diagram')

The solution begins with vehicle photos being uploaded to an Azure Storage blobs container, as they are captured. An Event Grid subscription is created against the Blob storage create event, calling the photo processing **Azure Function** endpoint (on the side of the diagram), which in turn sends the photo to the **Cognitive Services Computer Vision API OCR** service to extract the license plate data. If processing was successful and the license plate number was returned, the function submits a new Event Grid event, along with the data, to an Event Grid topic with an event type called "savePlateData". However, if the processing was unsuccessful, the function submits an Event Grid event to the topic with an event type called "queuePlateForManualCheckup". Two separate functions are configured to trigger when new events are added to the Event Grid topic, each filtering on a specific event type, both saving the relevant data to the appropriate **Azure Cosmos DB** collection for the outcome, using the Cosmos DB output binding. A **Logic App** that runs on a 15-minute interval executes an Azure Function via its HTTP trigger, which is responsible for obtaining new license plate data from Cosmos DB and exporting it to a new CSV file saved to Blob storage. If no new license plate records are found to export, the Logic App sends an email notification to the Customer Service department via their Office 365 subscription. **Application Insights** is used to monitor all of the Azure Functions in real-time as data is being processed through the serverless architecture. This real-time monitoring allows you to observe dynamic scaling first-hand and configure alerts when certain events take place. **Azure Key Vault** is used to securely store secrets, such as connection strings and access keys. Key Vault is accessed by the Function Apps through an access policy within Key Vault, assigned to each Function App's system-assigned managed identity.

## Exercise 1: Azure data, storage, and serverless environment setup

These should have been pre-provisioned by the deployment script.

### Task 1: Verify resources are created

In the Azure Portal, navigate to the resource group where all of the resources have been deployed. It should look similar to the screenshot below.

**Note**: The specific names of the resources will be slightly different than what you see in the screenshot based on the unique identities assigned.

![](2020-01-19-17-08-22.png)

## Exercise 2: Develop and publish the photo processing and data export functions

Your function, application settings and managed identity have already been deployed.

1. Using a new tab or instance of your browser navigate to the Azure portal, <http://portal.azure.com>.

2. Open the **ServerlessArchitecture** resource group, then select the Azure Function App to which you just published.

3. Expand the functions underneath your Function App in the menu. You should see both functions you just published from the Visual Studio solution listed.

    ![In the TollBoothFunctionApp blade, in the pane, both TollBoothFunctionApp, and Functions (Read Only) are expanded. Below Functions, two functions (ExportLicensePlates and ProcessImage) are called out.](media/image42.png 'TollBoothFunctionApp blade')

4. Now we need to add an Event Grid subscription to the ProcessImage function, so the function is triggered when new images are added to blob storage. Select the **ProcessImage** function, then select **Add Event Grid subscription**.

    ![The ProcessImage function and the Add Event Grid subscription items are highlighted.](media/processimage-add-eg-sub.png 'ProcessImage function')

5. On the **Create Event Subscription** blade, specify the following configuration options:

    a. **Name**: Unique value for the App name similar to **processimagesub** (ensure the green check mark appears).

    b. **Event Schema**: Select Event Grid Schema.

    c. For **Topic Type**, select **Storage Accounts**.

    d. Select your **subscription** and **ServerlessArchitecture** resource group.

    e. For resource, select your recently created storage account.

    f. Select only the **Blob Created** from the event types dropdown list.

    g. Leave Web Hook as the Endpoint Type.

6. Leave the remaining fields at their default values and select **Create**.

    ![In the Create Event Subscription blade, fields are set to the previously defined settings.](media/processimage-eg-sub.png)

## Exercise 3: Create functions in the portal

Create two new Azure Functions written in Node.js, using the Azure portal. These will be triggered by Event Grid and output to Azure Cosmos DB to save the results of license plate processing done by the ProcessImage function.

### Help references

|                                                                   |                                                                                                         |
| ----------------------------------------------------------------- | :-----------------------------------------------------------------------------------------------------: |
| **Description**                                                   |                                                **Links**                                                |
| Create your first function in the Azure portal                    |        <https://docs.microsoft.com/azure/azure-functions/functions-create-first-azure-function>         |
| Store unstructured data using Azure Functions and Azure Cosmos DB | <https://docs.microsoft.com/azure/azure-functions/functions-integrate-store-unstructured-data-cosmosdb> |

### Task 1: Create function to save license plate data to Azure Cosmos DB

In this task, you will create a new Node.js function triggered by Event Grid and that outputs successfully processed license plate data to Azure Cosmos DB.

1. Using a new tab or instance of your browser navigate to the Azure portal, <http://portal.azure.com>.

2. Open the **ServerlessArchitecture** resource group, then select the Azure Function App you created whose name ends with **Events**. If you did not use this naming convention, make sure you select the Function App that you _did not_ deploy to in the previous exercise.

3. In the blade menu, select **Functions**, the select **+ New Function**.

    ![In the TollBoothEvents2 blade, in the pane under Function Apps, TollBoothEvents2 is expanded, and Functions is selected. In the pane, the + New function button is selected.](media/function-app-events-overview.png 'TollBoothEvents2 blade')

4. Select **In-portal** within the _Choose a development environment_ step, then select **Continue**.

    ![The In-portal option and Continue button are highlighted.](media/new-function-in-portal.png "Azure Functions for JavaScript blade")

5. Select **More templates...** within the _Create a function_ step, then select **Finish and view templates**.

    ![The More templates option and Finish and view templates button are higlighted.](media/new-function-more-templates.png "Azure Functions for JavaScript blade")

6. Enter **event grid** into the template search form, then select the **Azure Event Grid trigger** template.

    ![In the Template search form, event grid is typed in the search field. Below, the Event Grid trigger function option displays.](media/new-function-event-grid-trigger-template.png "Template search form")

    a. If prompted to install the Azure Event Grid trigger extension, select **Install** and wait for the extension to install.

    ![Install azure extension form.](media/install-function-extension.png 'Template search form')

    b. Select **Continue**.

7. In the _New Function_ form, enter `SavePlateData` for the **Name**, then select **Create**.

    ![SavePlateData is entered in the Name field and the Create button is highlighted.](media/new-function-saveplatedata.png "New Function form")

8. Replace the code in the new SavePlateData function with the following:

    ```javascript
    module.exports = function(context, eventGridEvent) {
    context.log(typeof eventGridEvent);
    context.log(eventGridEvent);

    context.bindings.outputDocument = {
        fileName: eventGridEvent.data['fileName'],
        licensePlateText: eventGridEvent.data['licensePlateText'],
        timeStamp: eventGridEvent.data['timeStamp'],
        exported: false
    };

    context.done();
    };
    ```

9. Select **Save**.

### Task 2: Add an Event Grid subscription to the SavePlateData function

In this task, you will add an Event Grid subscription to the SavePlateData function. This will ensure that the events sent to the Event Grid topic containing the savePlateData event type are routed to this function.

1. With the SavePlateData function open, select **Add Event Grid subscription**.

    ![In the SavePlateData blade, the Add Event Grid subscription link is selected.](media/saveplatedata-add-eg-sub.png 'SavePlateData blade')

2. On the **Create Event Subscription** blade, specify the following configuration options:

    a. **Name**: Unique value for the App name similar to **saveplatedatasub** (ensure the green check mark appears).

    b. **Event Schema**: Select **Event Grid Schema**.

    c. For **Topic Type**, select **Event Grid Topics**.

    d. Select your **subscription** and **ServerlessArchitecture** resource group.

    e. For resource, select your recently created Event Grid.

    f. For Event Types, select **Add Event Type**.

    g. Enter `savePlateData` for the new event type value. This will ensure this function is only triggered by this Event Grid type.

    h. Leave Web Hook as the Endpoint Type.

3. Leave the remaining fields at their default values and select **Create**.

    ![In the Create Event Subscription blade, fields are set to the previously defined settings.](media/saveplatedata-eg-sub.png "Create Event Subscription")

### Task 3: Add an Azure Cosmos DB output to the SavePlateData function

In this task, you will add an Azure Cosmos DB output binding to the SavePlateData function, enabling it to save its data to the Processed collection.

1. Expand the **SavePlateData** function in the menu, then select **Integrate**.

2. Under Outputs, select **+ New Output**, select **Azure Cosmos DB** from the list of outputs, then choose **Select**.

    ![In the SavePlateData blade, in the pane under Function Apps, TollBoothEvents2, Functions, and SavePlateData are expanded, and Integrate is selected. In the pane, + New Output is selected under Outputs. In the list of outputs, the Azure Cosmos DB tile is selected.](media/image48.png 'SavePlateData blade')

3. In the Azure Cosmos DB output form, select **new** next to the Azure Cosmos DB account connection field.

    ![The New button is selected next to the Azure Cosmos DB account connection field.](media/image49.png 'New button')

    > **Note**: If you see a notice for "Extensions not installed", select **Install**.

    ![Cosmos Extension needed.](media/cosmos-extension-install.png 'New button')

4. Select your Cosmos DB account from the list that appears.

5. Specify the following configuration options in the Azure Cosmos DB output form:

    a. For database name, type **LicensePlates**.

    b. For the collection name, type **Processed**.

    ![Under Azure Cosmos DB output the following field values display: Document parameter name, outputDocument; Collection name, Processed; Database name, LicensePlates; Azure Cosmos DB account conection, tollbooths_DOCUMENTDB.](media/saveplatedata-cosmos-integration.png 'Azure Cosmos DB output section')

6. Select **Save**.

    > **Note**: you should wait for the template dependency to install if you were prompted earlier.

### Task 4: Create function to save manual verification info to Azure Cosmos DB

In this task, you will create a new function triggered by Event Grid and outputs information about photos that need to be manually verified to Azure Cosmos DB.

1. Select the **+** button to the right of **Functions** in the left-hand menu to create a new function.

    ![The Add new function button is highlighted next to Functions in the left-hand menu.](media/new-function-button.png "TollBoothEvents blade")

2. Enter **event grid** into the template search form, then select the **Azure Event Grid trigger** template.

    a. If prompted, select **Install** and wait for the extension to install.

    b. Select **Continue**.

    ![Event grid displays in the choose a template search field, and in the results, Event Grid trigger displays.](media/image44.png 'Event grid trigger')

3. In the **New Function** form, fill out the following properties:

    a. For name, type **QueuePlateForManualCheckup**.

    ![In the New Function form, JavaScript is selected from the Language drop-down menu, and QueuePlateForManualCheckup is typed in the Name field.](media/image51.png 'Event Grid trigger, New Function form')

4. Select **Create**.

5. Replace the code in the new QueuePlateForManualCheckup function with the following:

    ```javascript
    module.exports = async function(context, eventGridEvent) {
    context.log(typeof eventGridEvent);
    context.log(eventGridEvent);

    context.bindings.outputDocument = {
        fileName: eventGridEvent.data['fileName'],
        licensePlateText: '',
        timeStamp: eventGridEvent.data['timeStamp'],
        resolved: false
    };

    context.done();
    };
    ```

6. Select **Save**.

### Task 5: Add an Event Grid subscription to the QueuePlateForManualCheckup function

In this task, you will add an Event Grid subscription to the QueuePlateForManualCheckup function. This will ensure that the events sent to the Event Grid topic containing the queuePlateForManualCheckup event type are routed to this function.

1. With the QueuePlateForManualCheckup function open, select **Add Event Grid subscription**.

    ![In the QueuePlateForManualCheckup blade, the Add Event Grid subscription link is selected.](media/manualcheckup-add-eg-sub.png 'QueuePlateForManualCheckup blade')

2. On the **Create Event Subscription** blade, specify the following configuration options:

    a. **Name**: Unique value for the App name similar to **queueplateformanualcheckupsub** (ensure the green check mark appears).

    b. **Event Schema**: Select **Event Grid Schema**.

    c. For **Topic Type**, select **Event Grid Topics**.

    d. Select your **subscription** and **ServerlessArchitecture** resource group.

    e. For resource, select your recently created Event Grid.

    f. For Event Types, select **Add Event Type**.

    g. Enter `queuePlateForManualCheckup` for the new event type value. This will ensure this function is only triggered by this Event Grid type.

    h. Leave Web Hook as the Endpoint Type.

3. Leave the remaining fields at their default values and select **Create**.

    ![In the Create Event Subscription blade, fields are set to the previously defined settings.](media/manualcheckup-eg-sub.png)

### Task 6: Add an Azure Cosmos DB output to the QueuePlateForManualCheckup function

In this task, you will add an Azure Cosmos DB output binding to the QueuePlateForManualCheckup function, enabling it to save its data to the NeedsManualReview collection.

1. Expand the QueuePlateForManualCheckup function in the menu, the select **Integrate**.

2. Under Outputs, select **+ New Output** then select **Azure Cosmos DB** from the list of outputs, then choose **Select**.

    ![In the blade, in the pane under Function Apps, TollBoothEvents2\ Functions\QueuePlateForManualCheckup are expanded, and Integrate is selected. In the pane, + New Output is selected under Outputs. In the list of outputs, the Azure Cosmos DB tile is selected.](media/image54.png)

3. Specify the following configuration options in the Azure Cosmos DB output form:

    a. For database name, enter **LicensePlates**.

    b. For collection name, enter **NeedsManualReview**.

    c. Select the **Azure Cosmos DB account connection** you created earlier.

    ![In the Azure Cosmos DB output form, the following field values display: Document parameter name, outputDocument; Collection name, NeedsManualReview; Database name, LicensePlates; Azure Cosmos DB account connection, tollbooths_DOCUMENTDB.](media/manualcheckup-cosmos-integration.png 'Azure Cosmos DB output form')

4. Select **Save**.

## Exercise 4: Monitor your functions with Application Insights

Application Insights can be integrated with Azure Function Apps to provide robust monitoring for your functions. In this exercise, you will provision a new Application Insights account and configure your Function Apps to send telemetry to it.

### Help references

|                                                               |                                                                                  |
| ------------------------------------------------------------- | :------------------------------------------------------------------------------: |
| **Description**                                               |                                    **Links**                                     |
| Monitor Azure Functions using Application Insights            |     <https://docs.microsoft.com/azure/azure-functions/functions-monitoring>      |
| Live Metrics Stream: Monitor & Diagnose with 1-second latency | <https://docs.microsoft.com/azure/application-insights/app-insights-live-stream> |

### Task 1: Provision an Application Insights instance

1. Navigate to the Azure portal, <http://portal.azure.com>.

2. Select **+ Create a resource**, then type **application insights** into the search box on top. Select **Application Insights** from the results.

    ![In the Azure Portal menu pane, Create a resource is selected. In the New blade, application insights is typed in the search box, and Application insights is selected from the search results.](media/new-application-insights.png 'Azure Portal')

3. Select the **Create** button on the **Application Insights overview** blade.

4. On the **Application Insights** blade, specify the following configuration options:

    a. **Name**: Unique value for the App name similar to **TollboothMonitor** (ensure the green check mark appears).

    b. Specify the **Resource Group** **ServerlessArchitecture**.

    c. Select the same **location** as your Resource Group.

    ![Fields in the Application Insights blade are set to the previously defined settings.](media/application-insights-form.png 'Application Insights blade')

5. Select **Review + Create**, then choose **Create**.

### Task 2: Enable Application Insights integration in your Function Apps

Both of the Function Apps need to be updated with the Application Insights instrumentation key so they can start sending telemetry to your new instance.

1. After the Application Insights account has completed provisioning, open the instance by opening the **ServerlessArchitecture** resource group, and then selecting the your recently created application insights instance.

2. Copy the **instrumentation key** from the Essentials section of the **Overview** blade.

    > **Note**: You may need to expand the **Essentials** section.

    ![In the pane of the TollBoothMonitor blade, Overview is selected. In the pane, the copy button next to the Instrumentation key is selected.](media/app-insights-key.png 'TollBoothMonitor blade')

3. Open the Azure Function App you created whose name ends with **FunctionApp**, or the name you specified for the Function App containing the ProcessImage function.

4. Select **Configuration** on the **Overview** pane.

5. Scroll down to the **Application settings** section. Use the **+ Add new setting** link and name the new setting **APPINSIGHTS_INSTRUMENTATIONKEY**. Paste the copied instrumentation key into its value field.

    ![In the TollBoothFunctionApp blade, the + Add new setting link is selected. In the list of application settings, APPINSIGHTS_INSTRUMENTATIONKEY is selected.](media/app-insights-key-app-setting.png "Application settings")

6. Select **OK**.

7. Select **Save**.

    ![Screenshot of the Save icon.](media/image36.png 'Save icon')

8. Follow the steps above to add the APPINSIGHTS_INSTRUMENTATIONKEY setting to the function app that ends in **Events**.

### Task 3: Use the Live Metrics Stream to monitor functions in real time

Now that Application Insights has been integrated into your Function Apps, you can use the Live Metrics Stream to see the functions' telemetry in real time.

1. Open the Azure Function App you created whose name ends with **FunctionApp**, or the name you specified for the Function App containing the ProcessImage function.

2. Select **Application Insights** on the Overview pane.

    > **Note**: It may take a few minutes for this link to display. Try refreshing the page after a few moments.

    ![In the TollBoothFunctionApp blade, under Configured features, the Application Insights link is selected.](media/image64.png 'TollBoothFunctionApp blade')

3. In Application Insights, select **Live Metrics Stream** underneath Investigate in the menu.

    ![In the TollBoothMonitor blade, in the pane under Investigate, Live Metrics Stream is selected. ](media/image65.png 'TollBoothMonitor blade')

4. Leave the Live Metrics Stream open.

5. Go back to your cloud shell and make sure you are on the root folder by typing `cd ~`. There should be a file called uploadImages.sh. Run it by typing `./uploadImages.sh`

6. When the console window appears, enter **1** and press **ENTER**. This uploads a handful of car photos to the images container of your Blob storage account.

    ![A Command prompt window displays, showing images being uploaded.](media/image69.png 'Command prompt window')

7. Switch back to your browser window with the Live Metrics Stream still open within Application Insights. You should start seeing new telemetry arrive, showing the number of servers online, the incoming request rate, CPU process amount, etc. You can select some of the sample telemetry in the list to the side to view output data.

    ![The Live Metrics Stream window displays information for the two online servers. Displaying line and point graphs include incoming requests, outgoing requests, and overvall health. To the side is a list of Sample Telemetry information. ](media/image70.png 'Live Metrics Stream window')

8. Leave the Live Metrics Stream window open once again, and close the console window for the image upload. Debug the UploadImages project again, then enter **2** and press **ENTER**. This will upload 1,000 new photos.

    ![the Command prompt window displays with image uploading information.](media/image71.png 'Command prompt window')

9. Switch back to the Live Metrics Stream window and observe the activity as the photos are uploaded. It is possible that the process will run so efficiently that no more than two servers will be allocated at a time. You should also notice things such as a steady cadence for the Request Rate monitor, the Request Duration hovering below \~500ms second, and the Process CPU percentage roughly matching the Request Rate.

    ![In the Live Metrics Stream window, two servers are online. Under Incoming Requests. the Request Rate heartbeat line graph is selected, as is the Request Duration dot graph. Under Overall Health, the Process CPU heartbeat line graph is also selected, and a bi-directional dotted line points out the similarities between this graph and the Request Rate graph under Incoming Requests.](media/image72.png 'Live Metrics Stream window ')

10. After this has run for a while, close the image uploader console window once again, but leave the Live Metrics Stream window open.

### Task 4: Observe your functions dynamically scaling when resource-constrained

In this task, you will change the Computer Vision API to the Free tier. This will limit the number of requests to the OCR service to 10 per minute. Once changed, run the UploadImages console app to upload 1,000 images again. The resiliency policy programmed into the FindLicensePlateText.MakeOCRRequest method of the ProcessImage function will begin exponentially backing off requests to the Computer Vision API, allowing it to recover and lift the rate limit. This intentional delay will greatly increase the function's response time, thus causing the Consumption plan's dynamic scaling to kick in, allocating several more servers. You will watch all of this happen in real time using the Live Metrics Stream view.

1. Open your Computer Vision API service by opening the **ServerlessArchitecture** resource group, and then selecting the **Cognitive Services** service name.

2. Select **Pricing tier** under Resource Management in the menu. Select the **F0 Free** pricing tier, then choose **Select**.

    > **Note**: If you already have an **F0** free pricing tier instance, you will not be able to create another one.

    ![In the TollboothOCR blade, under Resource Management, Pricing tier is selected. In the Choose your pricing tier blade, the F0 Free option is selected.](media/image73.png 'TollboothOCR and Choose your pricing tier blades')

3. Switch to Visual Studio, debug the **UploadImages** project again, then enter **2** and press **ENTER**. This will upload 1,000 new photos.

    ![the Command prompt window displays image uploading information.](media/image71.png 'Command Prompt window')

4. Switch back to the Live Metrics Stream window and observe the activity as the photos are uploaded. After running for a couple of minutes, you should start to notice a few things. The Request Duration will start to increase over time. As this happens, you should notice more servers being brought online. Each time a server is brought online, you should see a message in the Sample Telemetry stating that it is "Generating 2 job function(s)", followed by a Starting Host message. You should also see messages logged by the resilience policy that the Computer Vision API server is throttling the requests. This is known by the response codes sent back from the service (429). A sample message is "Computer Vision API server is throttling our requests. Automatically delaying for 32000ms".

    > **Note**: If you do not see data flow after a short period, consider restarting the Function App.

    ![In the Live Metrics Stream window, 11 servers are now online.](media/image74.png 'Live Metrics Stream window ')

5. After this has run for some time, close the UploadImages console to stop uploading photos.

6. Navigate back to the **Computer Vision** API and set the pricing tier back to **S1 Standard**.

## Exercise 5: Explore your data in Azure Cosmos DB

In this exercise, you will use the Azure Cosmos DB Data Explorer in the portal to view saved license plate data.

### Help references

|                       |                                                           |
| --------------------- | :-------------------------------------------------------: |
| **Description**       |                         **Links**                         |
| About Azure Cosmos DB | <https://docs.microsoft.com/azure/cosmos-db/introduction> |

### Task 1: Use the Azure Cosmos DB Data Explorer

1. Open your Azure Cosmos DB account by opening the **ServerlessArchitecture** resource group, and then selecting the **Azure Cosmos DB account** name.

2. Select **Data Explorer** from the menu.

    ![In the Tollbooth - Data Explorer blade, Data Explorer is selected.](media/data-explorer-link.png 'Tollbooth - Data Explorer blade')

3. Expand the **Processed** collection, then select **Items**. This will list each of the JSON documents added to the collection.

4. Select one of the documents to view its contents. The first four properties are ones that were added by your functions. The remaining properties are standard and are assigned by Cosmos DB.

    ![Under Collections, Processed is expanded, and Documents is selected. On the Documents tab, a document is selected, and to the side, the first four properties of the document (fileName, licencePlateText, timeStamp, and exported) are circled.](media/data-explorer-processed.png 'Tollbooth - Data Explorer blade')

5. Expand the **NeedsManualReview** collection, then select **Items**.

6. Select one of the documents to view its contents. Notice that the filename is provided, as well as a property named "resolved". While this is out of scope for this lab, those properties can be used together to provide a manual process for viewing the photo and entering the license plate.

    ![Under Collections, NeedsManualReview is expanded, and Documents is selected. On the Documents tab, a document is selected, and to the side, the first four properties of the document (fileName, licencePlateText, timeStamp, and resolved) are circled.](media/data-explorer-needsreview.png 'Tollbooth - Data Explorer blade')

7. Right-click on the **Processed** collection and select **New SQL Query**.

    ![Under Collections, LicencePlates is expanded, and Processed is selected. From its right-click menu, New SQL Query is selected.](media/data-explorer-new-sql-query.png 'Tollbooth - Data Explorer blade')

8. Modify the SQL query to count the number of processed documents that have not been exported:

    ```sql
    SELECT VALUE COUNT(1) FROM c WHERE c.exported = false
    ```

9. Execute the query and observe the results. In our case, we have 1,369 processed documents that need to be exported.

    ![On the Query 1 tab, under Execute Query, the previously defined SQL query displays. Under Results, the number 1369 is highlighted.](media/cosmos-query-results.png 'Query 1 tab')

## Exercise 6: Create the data export workflow

In this exercise, you create a new Logic App for your data export workflow. This Logic App will execute periodically and call your ExportLicensePlates function, then conditionally send an email if there were no records to export.

### Help references

|                                      |                                                                                                                 |
| ------------------------------------ | :-------------------------------------------------------------------------------------------------------------: |
| **Description**                      |                                                    **Links**                                                    |
| What are Logic Apps?                 |                  <https://docs.microsoft.com/azure/logic-apps/logic-apps-what-are-logic-apps>                   |
| Call Azure Functions from logic apps | <https://docs.microsoft.com/azure/logic-apps/logic-apps-azure-functions%23call-azure-functions-from-logic-apps> |

### Task 1: Create the Logic App

1. Navigate to the Azure portal, <http://portal.azure.com>.

2. Select **+ Create a resource**, then enter **logic app** into the search box on top. Select **Logic App** from the results.

    ![In the Azure Portal, in the menu, Create a resource is selected. In the New blade, logic ap is typed in the search field, and Logic App is selected in the search results.](media/new-logic-app.png 'Azure Portal')

3. Select the **Create** button on the Logic App overview blade.

4. On the **Create Logic App** blade, specify the following configuration options:

    a. For Name, type a unique value for the App name similar to **TollBoothLogic** (ensure the green check mark appears).

    b. Specify the Resource Group **ServerlessArchitecture**.

    c. Select the same **location** as your Resource Group.

    d. Select **Off** underneath Log Analytics.

    ![In the Create logic app blade, fields are set to the previously defined settings.](media/image81.png 'Create logic app blade')

5. Select **Create**. Open the Logic App once it has been provisioned.

6. In the Logic App Designer, scroll through the page until you locate the _Start with a common trigger_ section. Select the **Recurrence** trigger.

    ![The Recurrence tile is selected in the Logic App Designer.](media/image82.png 'Logic App Designer')

7. Enter **1** into the **Interval** box, and make sure Frequency is set to **Minute**. This can be set to an hour or some other interval, depending on business requirements.

    ![Under Recurrence, the Interval field is set to 15, and the + New step button is selected.](2020-01-21-10-13-20.png 'Logic App Designer Recurrence section')

8. Select **+ New step**.

9. Enter **Functions** in the filter box, then select the **Azure Functions** connector.

    ![Under Choose an action, Functions is typed in the search box. Under Connectors, Azure Functions is selected.](media/image85.png 'Logic App Designer Choose an action section')

10. Select your Function App whose name ends in **FunctionApp**, or contains the ExportLicensePlates function.

    ![Under Azure Functions, in the search results list, Azure Functions (TollBoothFunctionApp) is selected.](media/image86.png 'Logic App Designer Azure Functions section')

11. Select the **ExportLicensePlates** function from the list.

    ![Under Azure Functions, under Actions (2), Azure Functions (ExportLicensePlates) is selected.](media/logic-app-select-export-function.png 'Logic App Designer Azure Functions section')

12. This function does not require any parameters that need to be sent when it gets called. Select **+ New step**, then search for **condition**. Select the **Condition** Control option from the Actions search result.

    ![Under ExportLicensePlates, the field is blank. Under the + New step button, Add a condition is selected.](media/logicapp-add-condition.png 'Logic App Designer ExportLicensePlates section')

13. For the **value** field, select the **Status code** parameter. Make sure the operator is set to **is equal to**, then enter **200** in the second value field.

    > **Note**: This evaluates the status code returned from the ExportLicensePlates function, which will return a 200 code when license plates are found and exported. Otherwise, it sends a 204 (NoContent) status code when no license plates were discovered that need to be exported. We will conditionally send an email if any response other than 200 is returned.

    ![The first Condition field displays Status code. The second, drop-down menu field displays is equal to, and the third field is set to 200.](media/logicapp-condition.png 'Condition fields')

14. We will ignore the If true condition because we don't want to perform an action if the license plates are successfully exported. Select **Add an action** within the **If false** condition block.

    ![Under the Conditions field is an If true (green checkmark) section, and an if false (red x) section. In the If false section, Add an action is selected.](media/logicapp-condition-false-add.png 'Logic App Designer Condition fields if true/false ')

15. Enter **Send an email** in the filter box, then select the **Send an email** action for Office 365 Outlook.

    ![From the Actions list, Office 365 Outlook (Send an email) is selected.](media/logicapp-send-email.png 'Office 365 Outlook Actions list')

16. Select **Sign in** and sign into your Office 365 Outlook account.

    ![In the Office 365 Outlook - Send an email prompt, the Sign in button is selected.](media/image93.png 'Office 365 Outlook Sign in prompt')

17. In the Send an email form, provide the following values:

    a. Enter your email address in the **To** box.

    b. Provide a **subject**, such as **Toll Booth license plate export failed**.

    c. Enter a message into the **body**, and select the **Status code** from the ExportLicensePlates function so that it is added to the email body.

    ![Under Send an email, fields are set to the previously defined settings. ](media/logicapp-send-email-form.png 'Logic App Designer , Send an email fields')

18. Select **Save** in the tool bar to save your Logic App.

19. Select **Run** to execute the Logic App. You should start receiving email alerts because some of the license plate data is not being exported.

    ![The Run button is selected on the Logic Apps Designer blade toolbar.](media/logicapp-start.png 'Logic Apps Designer blade')

20. While in the Logic Apps Designer, you will see the run result of each step of your workflow. A green checkmark is placed next to each step that successfully executed, showing the execution time to complete. This can be used to see how each step is working, and you can select the executed step and see the raw output.

    ![In the Logic App Designer, green check marks display next to Recurrence, ExportLicensePlates, Condition, and Send an email.](media/image96.png 'Logic App Designer ')

21. The Logic App will continue to run in the background, executing every minute (or whichever interval you set) until you disable it. 

## Exercise 8: Verify data export

Verify that the files are successfully exported.

### Task 1: Run the Logic App

1. Open your ServerlessArchitecture resource group in the Azure portal, then select your Logic App.

2. From the **Overview** blade, view **Runs History**.

    ![In the TollBoothLogic, Runs History.](2020-01-21-10-10-38.png 'TollBoothLogic blade')

4. Select the **Refresh** button next to the Run Trigger button to refresh your run history. Select the latest run history item. If the expression result for the condition is **true**, then that means the CSV file should've been exported to Blob storage. Be sure to disable the Logic App so it doesn't keep sending you emails every minute. Please note that it may take longer than expected to start running, in some cases.

    ![In Logic App Designer, in the Condition section, under Inputs, true is circled.](media/image115.png 'Logic App Designer ')

### Task 2: View the exported CSV file

1. Open your ServerlessArchitecture resource group in the Azure portal, then select your **Storage account** you had provisioned to store uploaded photos and exported CSV files.

2. In the Overview pane of your storage account, select **Blobs**.

    ![Under Services, Blobs is selected.](media/image116.png 'Services section')

3. Select the **export** container.

    ![Export is selected under Name.](media/image117.png 'Export option')

4. You should see at least one recently uploaded CSV file. Select the filename to view its properties.

    ![In the Export blade, under name, a .csv file is selected.](media/blob-export.png 'Export blade')

5. Select **Download** in the blob properties window.

    ![In the Blob properties blade, the Download button is selected.](media/blob-download.png 'Blob properties blade')

    The CSV file should look similar to the following:

    ![A CSV file displays with the following columns: FileName, LicensePlateText, TimeStamp, and LicensePlateFound.](media/csv.png 'CSV file')

6. The ExportLicensePlates function updates all of the records it exported by setting the exported value to true. This makes sure that only new records since the last export are included in the next one. Verify this by re-executing the script in Azure Cosmos DB that counts the number of documents in the Processed collection where exported is false. It should return 0 unless you've subsequently uploaded new photos.
