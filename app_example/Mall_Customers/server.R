library(shiny)
library(shinydashboard)
library(factoextra)
library(NbClust)
library(fpc)
library(ggplot2)
library(ggthemes)
library(mclust)

ui <- shinyUI(
  dashboardPage(
    dashboardHeader(title ="SOCR Clustering Calculator"),
    dashboardSidebar(
      sidebarMenu(
        menuItem("Upload Data",tabName = "upload",icon=icon("table")),
        menuItem("Raw Data",tabName = "raw",icon=icon("table")),
        menuItem("K-means clustering",tabName= "kmeans",icon=icon("users",lib="font-awesome")),
        menuItem("Gaussian Mixture clustering",tabName= "Guassin_Mixture",icon=icon("users",lib="font-awesome")),
        menuItem("Clustered Results", tabName = "Cluster_Result",icon=icon("table"))
      )),
    dashboardBody(
      tabItems(
        tabItem(tabName = "upload", h1("Upload your csv files"),fileInput("csv_file", "Choose CSV File (last two columns used for clustering)",
                                                                                         multiple = FALSE,
                                                                                         accept = c("text/csv",
                                                                                                    "text/comma-separated-values,text/plain",
                                                                                                    ".csv"))),
        tabItem(tabName = "raw",h1("Customer Data"),fluidRow(column(5,tableOutput("rawdata")))),
        tabItem(tabName = "kmeans",h1("K-means clustering"),
                fluidRow(
                  box(width = 12,plotOutput("clusterchart", width="100%",height = 750)),
                  box(sliderInput("clustnum","Number of clusters",2,10,6))
                )),
        tabItem(tabName = "Guassin_Mixture", h1("Gaussian Mixture clustering"), 
                fluidRow(box(width = 12, plotOutput("Gaussian_clusterchart",width="100%",height = 750)))),
        tabItem(tabName = "Cluster_Result", h1("Clustered Data Result"),fluidRow(column(5,tableOutput("clustered_data"))))
      )))) 

server <- shinyServer(function(input,output){
  df <- reactive({
    if (is.null(input$csv_file))
        return(read.csv("Mall_Customers.csv"))
    data<-read.csv(input$csv_file$datapath)
        return(data)})
  output$rawdata <- renderTable(df())
  output$Gaussian_clusterchart <- renderPlot({plot(Mclust(df()[tail(names(df()), 2)]), what=c("classification"))})
  output$clusterchart <- renderPlot({
    fviz_cluster((eclust(df()[tail(names(df()), 2)], "kmeans", k= input$clustnum, nstart = 25, graph = FALSE)), geom = "point", ellipse.type = "norm",
                 palette = "jco", ggtheme = theme_minimal())
    
  })
  result <- reactive({
    data <- df()
    result <- as.integer(Mclust(df()[tail(names(df()), 2)])["classification"]$classification)
    data$Gaussian_result <- result
    return(data)
  })
  output$clustered_data <- renderTable(result())
})
shinyApp(ui = ui, server = server)