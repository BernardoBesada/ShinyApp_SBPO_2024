library(shiny)
library(shinyjs)
library(DT)
source("methods.R")
source("plots.R")

data_research <- read.csv("www/research_data.csv", check.names = FALSE)
data_cols <- colnames(data_research)
data_numeric <- !data_cols %in% c("Municipality", "Code")
data_norm <- c(FALSE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, FALSE)
data_results <- calculate_scores(data_research[, data_numeric], data_norm)
data_weights <- data_results$Weights
data_scores <- data_results$Scores

ui <- tagList(
    useShinyjs(),
    navbarPage(

    "Page title",

    tabPanel("Results",
        conditionalPanel(condition = "input.use_research_data == 'Yes'",
            fluidRow(
                column(4,
                    wellPanel(
                        tableOutput('research_weights'),
                    )
                ),
                column(8,
                    wellPanel(
                        leafletOutput('research_plot'),
                    )
                ),
            )
        ),
        conditionalPanel(condition = "input.use_research_data == 'No'",
            conditionalPanel(condition = "output.file_not_uploaded",
                textOutput("missing_file"),
            )
        ),
    ),

    tabPanel("Data",
        radioButtons("use_research_data", "Use research data?",
            choices = list("Yes", "No"),
            selected = "Yes"
        ),
        conditionalPanel(condition = "input.use_research_data == 'Yes'",
            fluidRow(
                column(4,
                    wellPanel(
                        disabled(selectInput("locked_names", "Select name column:", choices = "Municipality", selected = "Municipality")),
                        disabled(selectInput("locked_id", "Select id column:", choices = "Code", selected = "Code")),
                    ),
                ), 
                column(4,
                    wellPanel(
                        disabled(checkboxGroupInput(
                            "locked_costs",
                            "Select the ones that are cost-type attributes:",
                            choices = data_cols[data_numeric],
                            selected = data_cols[data_numeric][data_norm],
                        )
                    ))
                ),
            ),
            DTOutput("table_research")
        ),
        conditionalPanel(condition = "input.use_research_data == 'No'",
            fileInput("file_input", "Upload CSV", accept = "text/csv"),
            conditionalPanel(condition = "output.file_uploaded",
                fluidRow(
                    column(4,
                        wellPanel(
                            selectInput("places_names", "Select name column:", choices = "temp", selected = "temp"),
                            selectInput("places_id", "Select id column:", choices = "temp", selected = "temp"),
                        ),
                    ), 
                    column(4,
                        wellPanel(
                            checkboxGroupInput(
                                "input_costs",
                                "Select the ones that are cost-type attributes:",
                                choices = c("temp"),
                            ),
                        ),
                    ),
                ),
                DTOutput("table_upload"),
            )
        ),
    )
))


server <- function(input,output,session){

    output$table_research <- renderDataTable(
        data_research,
        options = list(paging =TRUE, pageLength =  5)
    )

    output$research_weights <- renderTable(
        data.frame(
            Criteria = data_cols[data_numeric],
            Weights = unname(data_weights)
        ),
        options = list(paging =TRUE, pageLength =  5)
    )

    output$research_plot <- renderLeaflet(
        create_map(data_research, data_scores),
    )

    output$missing_file <- renderText("No file uploaded.\nGo to the data section and upload a file or choose to use research data.")

    output$file_uploaded <- reactive({
      val <- !(is.null(input$file_input))
    })
    outputOptions(output, 'file_uploaded', suspendWhenHidden = FALSE)

    output$file_not_uploaded <- reactive({
      val <- is.null(input$file_input)
    })
    outputOptions(output, 'file_not_uploaded', suspendWhenHidden = FALSE)

    data_ <- reactive({
        req(input$file_input)
        read.csv(input$file_input$datapath, check.names = FALSE)
    })

    output$table_upload <- renderDataTable({
        data_()},
        options = list(paging =TRUE, pageLength =  5)
    )

    observe({
        updateSelectInput(session, "places_id", choices = colnames(data_()))
    })

    observe({
        updateSelectInput(session, "places_names", choices = colnames(data_()))
    })

    observe({
        updateCheckboxGroupInput(session, "input_costs", choices = colnames(data_())[!colnames(data_()) %in% c(input$places_names, input$places_id)])
    })

}

shinyApp(ui, server)
