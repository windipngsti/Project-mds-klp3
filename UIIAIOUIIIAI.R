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
  dashboardHeader(title = div(tags$img(src = "Logo.JPG", height = "30px"), "Rotten Story"),
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
                    h2("Selamat Datang di Dashboard Rotten Story", align = "center"),
                    p("Kelompok 3", align = "center"),
                    slickROutput("carousel")
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
                  title = "Tentang Rotten Story", status = "warning", solidHeader = TRUE, 
                  collapsible = TRUE, width = 6,
                  "Elit menyediakan database komprehensif untuk memudahkan para pembaca dan cendekiawan menemukan buku yang dibutuhkan hanya dengan ujung jari Anda."
                ),
                box(
                  title = "Manfaat dari Membaca", status = "info", solidHeader = TRUE, 
                  collapsible = TRUE, width = 6,
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
              fluidRow(
                box(
                  title = "Ulasan Pengguna", status = "danger", solidHeader = TRUE, 
                  collapsible = TRUE, width = 12,
                  tags$ul(
                    tags$li(
                      tags$div(
                        "“Sangat membantu saya dalam menemukan buku untuk penelitian saya!” - Jasmin",
                        tags$div(class = "star-rating",
                                 icon("star"), icon("star"), icon("star"), icon("star"), icon("star")
                        )
                      )
                    ),
                    tags$li(
                      tags$div(
                        "“Solusi utama untuk pencarian dan referensi buku dengan cepat.” - Windi",
                        tags$div(class = "star-rating",
                                 icon("star"), icon("star"), icon("star"), icon("star"), icon("star")
                                 
                        )
                      )
                    )
                  )
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
      )
    )
  )
)

server <- function(input, output, session) {
  output$carousel <- renderSlickR({
    slickR(
      list("Buku1.jpg", "Buku2.jpg", "Buku3.jpg"),
      height = 250  # Sesuaikan tinggi gambar
    ) + settings(
      slidesToShow = 1,  # Menampilkan satu gambar per slide
      slidesToScroll = 1,
      centerMode = TRUE,
      dots = TRUE  # Menambahkan indikator di bawah carousel
    )
  })
  output$top_books <- renderUI({
    # Contoh daftar buku yang bisa diklik
    books <- data.frame(
      title = c("Buku Ajar Statistik Deskriptif", "Kesehatan Perkawinan di Indonesia"),
      author = c("Arofat", "Charles Suryadi"),
      img_src = c("Buku1.jpg", "Buku2.jpg"),
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
    
    tagList(book_list) # Pastikan `tagList` digunakan untuk mengembalikan UI yang valid
  })
  
  output$table_buku <- renderDT({
    query <- "SELECT * FROM novel"
    data_produk <- dbGetQuery(con, query)
    datatable(novel)
  })
  
  output$table_penulis <- renderDT({
    query <- "SELECT * FROM penulis"
    data_stock <- dbGetQuery(con, query)
    datatable(penulis)
  })
  
  output$table_penerbit <- renderDT({
    query <- "SELECT * FROM penerbit"
    data_stock <- dbGetQuery(con, query)
    datatable(penulis)
  })
  
  output$table_ulasan <- renderDT({
    query <- "SELECT * FROM ulasan"
    data_stock <- dbGetQuery(con, query)
  })
}

shinyApp(ui, server)
