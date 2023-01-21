library(shiny)
library(shinydashboard)
library(factoextra)
library(NbClust)
library(fpc)
library(kernlab)
library(ggplot2)
library(ggthemes)
ui <- shinyUI(
  dashboardPage(
    dashboardHeader(title ="SOCR Clustering Calculator"),
    dashboardSidebar(
      sidebarMenu(
        menuItem("Upload Data",tabName = "upload",icon=icon("table")),
        menuItem("Raw Data",tabName = "raw",icon=icon("table")),
        menuItem("K-means clustering",tabName= "kmeans",icon=icon("users",lib="font-awesome")),
        menuItem("Gaussian Mixture clustering",tabName= "Guassin_Mixture",icon=icon("users",lib="font-awesome")),
        menuItem("Spectral clustering",tabName= "Spectral",icon=icon("users",lib="font-awesome")),
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
                  box(sliderInput("clustnum","Number of clusters",2,8,6))
                )),
        tabItem(tabName = "Guassin_Mixture", h1("Gaussian Mixture clustering"), 
                fluidRow(
                  box(width = 12, plotly::plotlyOutput("Gaussian_clusterchart",width="100%",height = 750)))),
        tabItem(tabName = "Spectral", h1("Spectral clustering"),
                fluidRow(
                  box(width = 12,plotly::plotlyOutput("clusterchart_spectral",width="100%",height = 750)),
                  box(sliderInput("clustnum_spec","Number of clusters",2,8,6))
                  
                )),
        tabItem(tabName = "Cluster_Result", h1("Clustered Data Result"),
                downloadButton('download',"Download the data"),
                fluidRow(column(5,tableOutput("clustered_data"))))
      )))) 