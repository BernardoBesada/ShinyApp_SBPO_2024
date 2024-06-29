---
output: html_document
---
<style type="text/css">
  body{
  font-size: 12pt;
}
</style>

## About

This webapp was developed for the 56th Brazilian Symposium on Operations Research as a way to make it easier for users to apply the proposed method in the paper titled "An Objective Site Selection Framework for Wind Farms from a Sustainable Development Standpoint".

The webapp is divided in three sections:

### 1. User guide

This section describes the use of the webapp. It defines the expected user input as well as how the results are displayed.

### 2. Results

This section shows the results of the method application. On the left it shows the weights assigned to each criterion and on the right a choropleth map where it's possible to hover to see the score assigned by the model to each alternative.

Initially it shows the results for the data used in the paper, but if the user provides their own data it will show the weights for each criterion provided by the user and an option to download a CSV with the scores for each alternative. If the user also provides a shapefile, the webapp will also plot the choropleth map.

![results screen](www/results_screen.png){width=70%}

### 3. Data

This section is where the data used in the paper is shown and the user can upload their own data.

Here the user can choose whether they want to use the data used in the research or input their own data. If they choose to use the research data, the options will be blocked and the results tab will show the results for the research data.

![research data](www/research_data_data_screen.png){width=70%}

If they choose to not use the research data, they will be prompted to upload a CSV. The separator on the CSV must be a comma and the decimal separator of numeric values must be a point and they can't have thousand separators. There will also be a prompt asking if the user wishes to upload a shapefile, if they do, a space to upload it will appear.

![upload files](www/upload_files.png){width=70%}

After uploading the CSV, the user will have to select the name of the column containing the name of the alternatives and the name of the column containing the id of the alternatives. For example, in the research data each municipality has a name and an associated numeric id, because there can be multiple municipalities with the same name. Those two columns can be equal, however if a shapefile was uploaded the id column name must have a column with the same name and same values in it.

There is also a space where the user can select the cost-type attributes, in other words, the criteria which are meant to be minimized. As an example, in the research, alternatives with more employment are desired, so the box for the employed population criterion is ticked. On the other side, alternatives with higher wind speeds are considered better, so the box with wind speed criterion is not ticked.

In the end of the section there is also a table displaying the data being used.

![user choices](www/data_names_choices.png){width=70%}
