library(shiny)
library(shinydashboard)
library(shinythemes)
library(DT)
library(slickR)
library(plotly)
library(DBI)
library(RPostgreSQL) 
library(rsconnect)
library(dygraphs)
library(fmsb)
library(modules)
library(rworldmap)
library(shiny.fluent)
library(shiny.router)
library(shinythemes)
library(echarts4r)
#library(echarts4r.maps)
library(ggplot2)
library(bs4Dash)
library(googlesheets4)
library(tidyverse)
library(highcharter)
library(waiter)
library(tidytext)
library(ggwordcloud)
library(jsonlite)
library(hackeRnews)
library(urltools)
library(wordcloud)
library(tm)
library(dplyr)
library(shinyWidgets)
library(stopwords)
library(RColorBrewer)

getChoices <- function(query) {
  con <- dbConnect(MySQL(),
                   host = "127.0.0.1",
                   port = 3306,
                   user = "root",
                   password = "",
                   dbname = "rotten_story")
  
  data <- dbGetQuery(con, query)
  dbDisconnect(con)
  
  if (nrow(data) == 0) {
    return(NULL)  
  }
  return(data[[1]])
}

ui <- dashboardPage(
  dashboardHeader(title = div(tags$img(src = "https://github.com/windipngsti/Project-mds-klp3/blob/front-end/Logo.jpg", height = "30px"), "Rotten Story"),
                  titleWidth = 250),
  
  dashboardSidebar(
    sidebarMenu(
      menuItem("Beranda", tabName = "beranda", icon = icon("home")),
      menuItem("Daftar Buku", tabName = "daftar_buku", icon = icon("book")),
      menuItem("Data Penulis", tabName = "data_penulis", icon = icon("user")),
      menuItem("Data Penerbit", tabName = "data_penerbit", icon = icon("building")),
      menuItem("Ulasan Buku", tabName = "ulasan_buku", icon = icon("star"))
    )
  ),
  
  dashboardBody(
    tags$head(
      tags$link(href="https://fonts.googleapis.com/css?family=Roboto:400,700&display=swap", rel="stylesheet"),
      tags$style(HTML("
      .content-wrapper, .right-side, .main-footer, .main-header .logo, .main-header .navbar, .sidebar-menu > li.active > a {
        background-color: #FFFFFF; 
      }
      .box {
        border-top-color: #DB7C26; 
      }
      h1, h2, h3, h4, h5, h6, .h1, .h2, .h3, .h4, .h5, .h6 {
        font-family: 'Garamond', sans-serif; 
      }
      h1 {
        font-size: 36px; 
        font-weight: bold; 
      }
      .welcome-box {
        background-color: #DB7C26; 
        color: #000000; 
        display: flex; 
        align-items: center; 
        justify-content: start; 
        padding: 40px; 
        margin-bottom: 20px;
        min-height: 200px;
      }
      .welcome-box h1 {
        font-size: 48px; 
        margin: 0; 
      }
      .welcome-box img {
        height: auto; 
        width: auto; 
        max-height: 150px;
        max-width: 150px; 
        margin-right: 20px; 
      }
      .welcome-box h1, .welcome-box p {
        margin-left: 20px;
      }
      .welcome-box p {
        font-size: 20px; 
        margin: 0; 
      }
      @media (max-width: 991px) {
        .welcome-box {
          flex-direction: column; 
          text-align: center; 
        }
        .welcome-box img {
          margin-bottom: 20px; 
        }
      }
      
      .dataTables_wrapper {
        background-color: #f8f9fa; 
        border-radius: 4px;
        padding: 10px;
      }

      .dataTables_wrapper .dataTables_processing {
        z-index: 1;
      }

      table.dataTable {
        border-collapse: separate;
        margin: 0 0 20px;
        background-color: #FFFFFF; 
        color: #212529; 
        border-radius: 4px;
        box-shadow: 0 2px 3px rgba(0,0,0,0.1); 
      }

      table.dataTable thead {
        background-color: #00477f; 
        color: #FFFFFF; 
      }

      table.dataTable thead th {
        background-color: #007bff;
        color: white;
      }

      table.dataTable tbody tr {
        background-color: white; 
      }

      .input-group .form-control {
        border: 1px solid #ced4da; 
        color: #495057;
      }
      
      .input-group-btn .btn {
        background-color: #007bff; 
        color: white;
      }
      
      table.dataTable tbody tr:nth-child(odd) {
        background-color: #F9F9F9; 
      }
      .dataTables_paginate .pagination li a {
        color: #007bff; 
      }

      @media (max-width: 767px) {
        .dataTables_wrapper .dataTables_paginate {
          float: none;
          text-align: center;
        }
      }
    "))
    ),
    
    
    tabItems(
      tabItem(tabName = "beranda",
              fluidRow(
                box(
                  width = 12,
                  div(
                    class = "welcome-box",
                    status = "warning", solidHeader = TRUE,
                    h2("ROTTEN STORY", align = "center"),
                    h3("Smoothing Your Lovely", align = "center"),
                    h4("Kelompok 3", align = "center"),
                    tags$img(src = "logo.png", height = "30px"),
                    #slickROutput("carousel"),
                    h5("Rotten menyediakan database komprehensif untuk memudahkan para pembaca dan pecinta novel menemukan buku yang dibutuhkan hanya dengan jemari Anda."),
                  )
                )
              ),
              fluidRow(
                box(
                  title = "Buku Rating Tertinggi", status = "primary", solidHeader = TRUE, 
                  collapsible = TRUE, width = 12,
                  div(
                    class = "container-fluid",
                    # Use a loop to render books
                    uiOutput("top_books")
                  )
                )
              ),
              fluidRow(
                box(
                  title = "Manfaat dari Membaca", status = "info", solidHeader = TRUE, 
                  collapsible = TRUE, width = 12,
                  "Membaca dapat meningkatkan pengetahuan, meningkatkan konsentrasi, dan memupuk imajinasi. Selami dunia buku dan biarkan pikiran Anda menjelajahi batas-batas realitas."
                )
              ),
              fluidRow(
                box(
                  title = "Cara Penggunaan", status = "success", solidHeader = TRUE, 
                  collapsible = TRUE, width = 12,
                  "Cukup masukkan judul, penulis, atau kata kunci ke dalam kolom pencarian untuk memulai pencarian Anda melalui koleksi literatur kami yang luas."
                )
              ),
      ),
      
      tabItem(tabName = "daftar_buku",
              h2("Daftar Buku"),
              fluidRow(
                column(12, DTOutput("table_buku"))
              )
      ),
      
      tabItem(tabName = "data_penulis",
              h2("Data Penulis"),
              fluidRow(
                column(12, DTOutput("table_penulis"))
              )
      ),
      
      tabItem(tabName = "data_penerbit",
              h2("Data Penerbit"),
              fluidRow(
                column(12, DTOutput("table_penerbit"))
              )
      ),
      
      tabItem(tabName = "ulasan_buku",
              h2("Ulasan Buku"),
              fluidRow(
                column(12, DTOutput("table_ulasan"))
              )
      ),
      tabItem(tabName = "stat_penulis",
              h2("Statistik Penulis"),
              fluidRow(
                box(
                  title = "Jumlah Buku per Penulis",
                  status = "primary",
                  solidHeader = TRUE,
                  collapsible = TRUE,
                  width = 12,
                  plotlyOutput("bar_penulis")
                )
              )
      )
    )
  )
)

server <- function(input, output, session) {
  output$top_books <- renderUI({
    books <- data.frame(
      title = c("Bumi Manusia", "Laskar Pelangi", "Anak Semua Bangsa", "Ronggeng Dukuh Paruk", "Negeri 5 Menara"),
      author = c("Pramoedya Ananta Toer", "Andrea Hirata", "Pramoedya Ananta Toer", "Ahmad Tohari", "Ahmad Fuadi"),
      img_src = c("https://github.com/windipngsti/Project-mds-klp3/blob/front-end/novel1.jpg",
                  "https://github.com/windipngsti/Project-mds-klp3/blob/front-end/novel2.jpg",
                  "https://github.com/windipngsti/Project-mds-klp3/blob/front-end/novel3.jpg",
                  "https://github.com/windipngsti/Project-mds-klp3/blob/front-end/novel4.jpg",
                  "https://github.com/windipngsti/Project-mds-klp3/blob/front-end/novel5.jpg"),
      stringsAsFactors = FALSE
    )
    
    book_list <- lapply(1:nrow(books), function(i) {
      tags$div(
        class = "book-card",
        style = "display: inline-block; width: 200px; margin: 10px; text-align: center;",
        tags$img(
          src = books$img_src[i],
          height = "150px",
          style = "border-radius: 10px;"),
        tags$h4(books$title[i]),
        tags$p(paste("by", books$author[i])),
        actionButton(paste0("btn_", i), "Lihat Detail", class = "btn-primary")
      )
    })
    tagList(book_list)
  })
  
  output$table_buku <- renderDT({
    query <- "SELECT * FROM novel"
    novel <- dbGetQuery(con, query)
    datatable(novel)
  })
  
  output$table_penulis <- renderDT({
    query <- "SELECT * FROM penulis"
    penulis <- dbGetQuery(con, query)
    datatable(penulis)
  })
  
  output$table_penerbit <- renderDT({
    query <- "SELECT * FROM penerbit"
    penerbit <- dbGetQuery(con, query)
    datatable(penerbit)
  })
  
  output$table_ulasan <- renderDT({
    query <- "SELECT * FROM ulasan"
    ulasan <- dbGetQuery(con, query)
    datatable(ulasan)
  })
  output$bar_penulis <- renderPlotly({
    con <- dbConnect(MySQL(),
                     host = "127.0.0.1",
                     port = 3306,
                     user = "root",
                     password = "",
                     dbname = "rotten_story")
    query <- "SELECT penulis, COUNT * as jumlah_buku FROM novel GROUP BY penulis ORDER BY jumlah_buku DESC"
    data <- dbGetQuery(con, query)
    dbDisconnect(con)
    
    plot_ly(data, x = ~penulis, y = ~jumlah_buku, type = 'bar', marker = list(color = 'blue')) %>%
      layout(title = "Jumlah Buku per Penulis", xaxis = list(title = "Penulis"), yaxis = list(title = "Jumlah Buku"))
  })
}

shinyApp(ui, server)
