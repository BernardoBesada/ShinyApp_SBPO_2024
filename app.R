library(shiny)
library(shinyjs)
library(DT)
library(purrr)
library(markdown)
library(knitr)
source("methods.R")
source("plots.R")

data_research <- read.csv("www/research_data.csv", check.names = FALSE)
data_cols <- colnames(data_research)
data_numeric <- !data_cols %in% c("Municipality", "Code")
data_norm <- c(FALSE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, FALSE)
data_results <- calculate_scores(data_research[, data_numeric], data_norm)
data_criteria <- data_results$Criteria
data_weights <- data_results$Weights
data_scores <- data_results$Scores

ui <- tagList(
    useShinyjs(),
    navbarPage(

    "An Objective Site Selection Framework for Wind Farms from a Sustainable Development Standpoint",

    tabPanel("User guide",
        uiOutput("user_guide"),
    ),

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
            ),
            conditionalPanel(condition = "output.file_uploaded",
                fluidRow(
                    column(4,
                        wellPanel(
                            downloadButton('download_results', 'Download results'),
                            tableOutput('input_weights'),
                        )
                    ),
                    column(8,
                        conditionalPanel(condition = "output.shp_uploaded",
                            wellPanel(
                                leafletOutput('input_plot'),
                            )
                        )
                    )
                ),
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
                            "Select the ones that are cost-type criteria:",
                            choices = data_cols[data_numeric],
                            selected = data_cols[data_numeric][data_norm],
                        )
                    ))
                ),
            ),
            DTOutput("table_research")
        ),
        conditionalPanel(condition = "input.use_research_data == 'No'",
            fluidRow(
                column(4,
                    wellPanel(
                        fileInput("file_input", "Upload CSV", accept = "text/csv"),
                    )
                ),
                column(4,
                    wellPanel(
                        radioButtons("plot_map", "Upload shapefile?",
                            choices = list("Yes", "No"),
                            selected = "No"
                        ),
                        conditionalPanel(condition = "input.plot_map == 'Yes'",
                            fileInput("shp_input", "Upload SHP", accept = c(".cpg", ".dbf", ".prj", ".shp", ".shx"), multiple = TRUE),
                        )
                    ),
                ),
            ),
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
    tags$style(HTML(".navbar-header { width:100% }
                   .navbar-brand { width: 100%; text-align: center }"))))
)


server <- function(input,output,session){

    output$user_guide <- renderUI({
        HTML(markdown::markdownToHTML(knit('www/user_guide.md', quiet = TRUE), fragment.only = TRUE))
    })

    output$table_research <- renderDataTable(
        data_research,
        options = list(paging =TRUE, pageLength =  5)
    )

    output$research_weights <- renderTable(
        data.frame(
            Criteria = data_criteria,
            Weights = unname(data_weights)
        ),
        options = list(paging =TRUE, pageLength =  5)
    )

    output$research_plot <- renderLeaflet(
        create_map_research(data_research, data_scores),
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

    output$shp_uploaded <- reactive({
        val <- !is.null(input$shp_input)
    })
    outputOptions(output, 'shp_uploaded', suspendWhenHidden = FALSE)

    data_ <- reactive({
        req(input$file_input)
        return(read.csv(input$file_input$datapath, check.names = FALSE))
    })

    results_ <- reactive({
        data_input <- data_()
        data_cols <- colnames(data_input)
        data_numeric <- !data_cols %in% c(input$places_names, input$places_id)
        data_norm_inputs <- data_cols[data_numeric] %in% as.vector(input$input_costs)
        data_results <- calculate_scores(data_input[, data_numeric], data_norm_inputs)
        return(data_results)
    })

    output$table_upload <- renderDataTable({
        data_()},
        options = list(paging =TRUE, pageLength =  5)
    )

    output$input_weights <- renderTable({
        data_results <- results_()
        data_weights <- data_results$Weights
        data_criteria <- data_results$Criteria

        data.frame(
            Criteria = data_criteria,
            Weights = unname(data_weights)
        )
        },
        options = list(paging =TRUE, pageLength =  5)
    )

    read_shapefile <- function(shp_path) {
        infiles <- shp_path$datapath # get the location of files
        dir <- unique(dirname(infiles)) # get the directory
        outfiles <- file.path(dir, shp_path$name) # create new path name
        name <- strsplit(shp_path$name[1], "\\.")[[1]][1] # strip name 
        purrr::walk2(infiles, outfiles, ~file.rename(.x, .y)) # rename files
        x <- read_sf(file.path(dir, paste0(name, ".shp"))) # read-in shapefile
        return(x)
    }

    output$input_plot <- renderLeaflet({
        req(input$shp_input)
        shp_ <- read_shapefile(input$shp_input)
        input_results <- results_()
        scores <- input_results$Scores
        input_data <- data_()
        m <- create_map(input_data, scores, shp_, input$places_id, input$places_names)
        return(m)
    }
    )

    df_results <- reactive({
        input_results <- results_()
        scores <- input_results$Scores
        input_data <- data_()
        out_dt <- data.frame(Names = input_data[, input$places_names], Ids = input_data[, input$places_id], Scores = scores)
        colnames(out_dt) <- c(input$places_names, input$places_id, "Scores")
        return(out_dt)
    })

    output$download_results <- downloadHandler(
        filename = function(){
            "scores.csv"
        }, 
        content = function(fname){
            return(write.csv(df_results(), fname))
        }
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

    output$wip <- renderText("The user guide isn't finished yet.")

}

shinyApp(ui, server)
