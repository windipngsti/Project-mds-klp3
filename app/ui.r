library(shiny)
library(shinydashboard)
library(tidyverse)
library(DBI)
library(RMySQL)
library(ggplot2)
library(plotly)
library(DT)
library(bs4Dash)

ui <- dashboardPage(
  dark = NULL,
  help = NULL,
  fullscreen = TRUE, 
  
  title = "Rotten Story",
  header = dashboardHeader(title = span(
    tags$img(src = "logo.jpg", height = "30px", style = "margin-right: 10px;"),
    "Rotten Story", style = "font-family: 'Poppins', sans-serif; color: #C3BFD8; font-weight: bold;")),
  sidebar = dashboardSidebar(
    sidebarMenu(
      menuItem("Homepage", tabName = "home", icon = icon("house")),
      menuItem("Novel", tabName = "novel", icon = icon("book")),
      menuItem("Penulis", tabName = "penulis", icon = icon("pen")),
      menuItem("Review", tabName = "review", icon = icon("star")),
      menuItem("Team", tabName = "team", icon = icon("person"))
    )
  ),
  controlbar = dashboardControlbar(),
  footer = dashboardFooter("© 2025 Rotten story"),
  
  body = dashboardBody(
    # ✨ Styling CSS langsung di UI
    
    tags$style(HTML("
    .slick-slide img {
      height: 250px !important; 
      width: 150px !important;
      object-fit: cover;
    }
  ")),
    
    tags$head(tags$style(HTML('
      @import url("https://fonts.googleapis.com/css2?family=Inter:wght@400;700&display=swap");

      body { 
        background-color: #F9F5F2; /* Warna lebih soft */
        color: #013D5A; 
        font-family: "Inter", sans-serif; 
      }

      h2, h3, h4 { 
        color: #013D5A; 
        font-weight: 700; 
      }

      /* Kotak dan tabel */
      .box, .dataTables_wrapper { 
        background: linear-gradient(135deg, #FFFFFF, #F3E9DC); 
        border-radius: 15px; 
        box-shadow: 0px 4px 10px rgba(0, 0, 0, 0.1);
        color: #013D5A !important;
      }

      /* Value Box */
      .value-box { 
        background: linear-gradient(135deg, #FAA258, #F57F17); 
        color: #FFF !important; 
        border-radius: 12px; 
        font-weight: bold;
        box-shadow: 0px 4px 8px rgba(0, 0, 0, 0.15);
      }

      /* Sidebar */
      .main-sidebar { 
        background: linear-gradient(180deg, #1B2A41, #0F172A) !important; 
        border-right: 2px solid #FAA258;
      }

      /* Sidebar Menu */
      .sidebar-menu > li > a { 
        color: #ECF0F1 !important;
        font-weight: 600;
      }

      /* Aktif dan Hover di Sidebar */
      .sidebar-menu > li.active > a { 
        background-color: #FAA258 !important; 
        color: #1B2A41 !important;
      }

      .sidebar-menu > li > a:hover { 
        background-color: rgba(250, 162, 88, 0.2) !important; 
        color: #FAA258 !important; 
        transition: 0.3s;
      }

      /* Header */
      .main-header .logo { 
        background-color: #013D5A; 
        color: #FCF3E3; 
        font-weight: bold; 
      }

      /* Footer */
      .main-footer { 
        background: linear-gradient(90deg, #3B6790, #013D5A); 
        color: #F1F0E9; 
        text-align: center; 
        padding: 14px; 
        font-size: 14px; 
        font-weight: bold;
      }

      /* Komentar Khusus */
      .custom-comment { 
        background-color: #708C69; 
        padding: 14px; 
        border-left: 6px solid #FAA258; 
        border-radius: 12px; 
        margin-top: 12px; 
        font-style: italic; 
        color: #FCF3E3; 
        box-shadow: 0px 3px 6px rgba(0, 0, 0, 0.1);
      }
')))
    ,
    
    tabItems(
      tabItem("home",
              h2("📚 Novel Seru, Cerita Tak Terbatas – Temukan Dunia Baru Bersama ROTTEN STORY!", 
                 style = "text-align: center; font-weight: bold; color: #013D5A; margin-bottom: 16px;"),
              
              fluidRow(
                valueBoxOutput("totalNovel", width = 4),
                valueBoxOutput("totalPenulis", width = 4),
                valueBoxOutput("averageRating", width = 4)
              ),
              
            
              fluidRow(
                box(
                  title = div("📖 Rotten Story", style = "font-size: 16px; font-weight: bold; color: #013D5A;"),
                  width = 12, status = "warning", solidHeader = TRUE, collapsible = TRUE,
                  div(style = "display: flex; align-items: center;",
                      p("Rotten Story adalah platform untuk menemukan dan menjelajahi berbagai novel. 
            Dengan database yang lengkap, pengguna bisa mencari novel berdasarkan genre, 
            tahun rilis, atau rating. Tempat yang pas buat kamu yang ingin menemukan bacaan seru dan sesuai selera. 🚀🍿✨",
                        style = "font-size: 16px; color: #444;")
                  )
                )
              ),
              
              fluidRow(
                box(
                  title = div("📚 Novel pilhan pengguna",style = "font-size: 16px; font-weight: bold; color: #013D5A;"),
                  width = 12,
                  status = "warning",
                  solidHeader = TRUE,
                  slickR::slickROutput("novelSlider", height = "260px")  # Output slider
                )
                
                
              ),
              
              fluidRow(
                box(
                  title = div("📊 Distribusi Genre", style = "font-size: 16px; font-weight: bold; color: #013D5A;"),
                  width = 6, solidHeader = TRUE, collapsible = TRUE, status = "warning",
                  plotlyOutput("genrePlot")
                ),
                box(
                  title = div("⭐ Distribusi Rating Novel", style = "font-size: 18; font-weight: bold; color: #013D5A;"),
                  width = 6, solidHeader = TRUE, collapsible = TRUE, status = "warning",
                  plotlyOutput("ratingPlot")
                )
              )
              
              
      )
      ,
      
      
      tabItem("novel",
              h2("🎥 Daftar Novel"),
              fluidRow(
                column(4, selectInput("selectedNovelTitle", "Pilih Judul:", choices = c("Semua"), selected = "Semua")),
                column(4, selectInput("selectedRating", "Pilih Kategori Rating:", choices = c("Semua", "Above 4","Below 4"), selected = "Semua"))
              ),
              box(width = 12, dataTableOutput("NovelTable"))
      ),
      
      tabItem("penulis",
              h2("🎥 Cari data penulis"),
              fluidRow(
                column(4, selectInput("selectedAuthor", "Cari Biodata Penulis:", choices = c("Semua"), selected = "Semua")),
              ),
              box(width = 12, dataTableOutput("AuthorTable"))
      ),
      
      
      tabItem("genre",
              h2("📂 Cari Film Berdasarkan Genre"),
              fluidRow(
                column(6, selectInput("selectedGenre", "Pilih Genre:", choices = c("Semua"), selected = "Semua")),
                column(6, selectInput("selectedYear", "Pilih Tahun:", choices = c("Semua"), selected = "Semua"))
              ),
              box(width = 12, dataTableOutput("genreTable")),
              fluidRow(
                box(title = "🎭 Distribusi Film Berdasarkan Genre", width = 6, solidHeader = TRUE, plotlyOutput("genreDistPlot")),
                box(title = "📆 Distribusi Film Berdasarkan Tahun", width = 6, solidHeader = TRUE, plotlyOutput("yearDistPlot"))
              )
      ),
      
      tabItem("review",
              h2("💬 Ulasan Film"),
              fluidRow(selectInput("selectedReviewNovel", "Pilih Film:", choices = c("Semua"), selected = "Semua")),
              fluidRow(valueBoxOutput("totalReviews"), valueBoxOutput("averageReviewRating")),
              box(width = 12, dataTableOutput("reviewTable"))
      ),
      
      tabItem("top_movie",
              h2("🌟 Film dengan Rating Tertinggi"),
              uiOutput("topMovieBox"),
              box(title = "🏆 5 Film Teratas", width = 12, dataTableOutput("topMovieTable"))
      ),
      
      tabItem("team",
              h2("👥 Kenalan dengan Tim Rotten Story Yuk!!"),
              fluidRow(
                box(title = "Database Manager", width = 12, align = "center", imageOutput("uccang", width = "100%", height = "100%"))
              ),
              fluidRow(
                box(title = "Front End Developer", width = 12, align = "center", imageOutput("abil", width = "100%", height = "100%"))
              ),
              fluidRow(
                box(title = "Back End Developer", width = 12, align = "center", imageOutput("dilla", width = "100%", height = "100%"))
              ),
              fluidRow(
                box(title = "Designer Database", width = 12, align = "center", imageOutput("aini", width = "100%", height = "100%"))
              )
      )
    )
  )
)