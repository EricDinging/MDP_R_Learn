library(Spectrum)
library(shiny)
library(shinydashboard)
library(factoextra)
library(NbClust)
library(fpc)
library(ggplot2)
library(ggthemes)
library(mclust)
library(kernlab)

ui <- shinyUI(
  dashboardPage(
    dashboardHeader(title ="SOCR Clustering Calculator"),
    dashboardSidebar(
      sidebarMenu(
        menuItem("Upload Data",tabName = "upload",icon=icon("table")),
        menuItem("Raw Data",tabName = "raw",icon=icon("table")),
        menuItem("K-means clustering",tabName= "kmeans",icon=icon("users",lib="font-awesome")),
        menuItem("Gaussian Mixture clustering",tabName= "Guassin_Mixture",icon=icon("users",lib="font-awesome")),
        menuItem("Spectral",tabName= "Spectral",icon=icon("users",lib="font-awesome")),
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
                  box(width = 12,plotly::plotlyOutput("clusterchart", width="100%",height = 750)),
                  box(sliderInput("clustnum","Number of clusters",2,9,6))
                )),
        tabItem(tabName = "Guassin_Mixture", h1("Gaussian Mixture clustering"),
                fluidRow(
                  box(width = 12,plotly::plotlyOutput("Gaussian_clusterchart",width="100%",height = 750)))),
        tabItem(tabName = "Spectral", h1("Spectral clustering"),
                fluidRow(
                  box(width = 12,plotly::plotlyOutput("clusterchart_spectral",width="100%",height = 750)),
                  box(sliderInput("clustnum_spec","Number of clusters",2,9,6))
                )),
        
        
        tabItem(tabName = "Cluster_Result", h1("Clustered Data Result"),
                downloadButton('download',"Download the data"),
                
                fluidRow(column(5,tableOutput("clustered_data"))))
      ))))

server <- shinyServer(function(input,output){
  df <- reactive({
    if (is.null(input$csv_file))
      return(read.csv("Mall_Customers.csv"))
    data<-read.csv(input$csv_file$datapath)
    return(data)})
  output$rawdata <- renderTable(df())
  output$Gaussian_clusterchart <-
    plotly::renderPlotly({(fviz_cluster((Mclust(df()[tail(names(df()), 2)])), stand=FALSE,geom = "point", ellipse.type = "norm",
                                        palette = "jco", ggtheme = theme_minimal()))})
  output$clusterchart <- plotly::renderPlotly({
    data_input <-df()
    data_input <- data_input[tail(names(data_input),2)]
    names(data_input)[1] <- "X1"
    names(data_input)[2] <- "X2"
    spec_group <- kkmeans(data.matrix(data_input),centers=input$clustnum)[1:nrow(data_input)]
    data_input$group <- spec_group
    names(data_input)[3] <- "group"
    ggplot(data=data_input, mapping=aes(x=data_input$X1, y=data_input$X2,color=as.factor(data_input$group))) + geom_point(size=2) + labs(x="input data last column", y = "input data last but second column", colour = "Clusters")
    })
  
  output$clusterchart_spectral <- plotly::renderPlotly({
    data_input <-df()
    data_input <- data_input[tail(names(data_input),2)]
    names(data_input)[1] <- "X1"
    names(data_input)[2] <- "X2"
    spec_group <- specc(data.matrix(data_input),centers=input$clustnum_spec)[1:nrow(data_input)]
    data_input$group <- spec_group
    names(data_input)[3] <- "group"
    ggplot(data=data_input, mapping=aes(x=data_input$X1, y=data_input$X2,color=as.factor(data_input$group))) + geom_point(size=2) + labs(x="input data last column", y = "input data last but second column", colour = "Clusters")
  })
  result <- reactive({
    data_input <- df()
    result <- as.integer(Mclust(df()[tail(names(df()), 2)])["classification"]$classification)
    result_kmean <- kkmeans(data.matrix(df()[tail(names(df()), 2)]), centers = input$clustnum)
    result_spec <- specc(data.matrix(df()[tail(names(df()), 2)]), centers = input$clustnum_spec)
    data_input$Gaussian_result <- result
    data_input$Kmean_result <- result_kmean[1:nrow(data_input)]
    data_input$Spectral_result <- result_spec[1:nrow(data_input)]
    return(data_input)
  })
  output$clustered_data <- renderTable(result())
  
  output$download <- downloadHandler(
    filename = function(){"processed.csv"},
    content = function(fname){
      write.csv(result(), fname)
    }
  )
  
  
})
shinyApp(ui = ui, server = server)