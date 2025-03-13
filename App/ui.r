library(shiny)
library(shinydashboard)
library(tidyverse)
library(DBI)
library(RMySQL)
library(ggplot2)
library(plotly)
library(DT)
library(bs4Dash)
install.packages("base64enc")
library(base64enc)

ui <- dashboardPage(
  dark = NULL,
  help = NULL,
  fullscreen = TRUE, 
  
  title = "Rotten Story",
  header = dashboardHeader(title = span(
    tags$img(src = "3.png", height = "80px", style = "margin-right: 10px;"),
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
  tags$style(HTML("
  .tab-header {
    background-color: #4A90E2; /* Ganti dengan warna yang diinginkan */
    color: white; /* Warna teks */
    padding: 10px;
    border-radius: 5px;
  }
")
             ),
  
  controlbar = dashboardControlbar(),
  footer = dashboardFooter("© 2025 Rotten story"),
  
  body = dashboardBody(
    tags$head(tags$script(HTML("
  function toggleText(id) {
    var shortText = document.getElementById('short_' + id);
    var fullText = document.getElementById('full_' + id);
    var toggleLink = document.getElementById('toggle_' + id);
    
    if (shortText.style.display === 'none') {
      shortText.style.display = 'inline';
      fullText.style.display = 'none';
      toggleLink.innerHTML = 'Read More';
    } else {
      shortText.style.display = 'none';
      fullText.style.display = 'inline';
      toggleLink.innerHTML = 'Show Less';
    }
  }
"))),
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
        background: linear-gradient(135deg, #FFFFFF, #FFFFFF); 
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
                  title = div("🚀 Rotten Story: Surga bagi Pecinta Novel! 📚✨", style = "font-size: 16px; font-weight: bold; color: #013D5A;"),
                  width = 12, status = "warning", solidHeader = TRUE, collapsible = TRUE,
                  div(style = "display: flex; align-items: center;", #gambar di tengah
                      tags$img(src = "2.png", height = "100px", style = "margin-right: 15px;"),  # Gambar di kiri
                      p("Mau nemuin novel yang bikin nagih? Di Rotten Story, kamu bisa menjelajahi ribuan cerita seru berdasarkan genre, 
                        tahun rilis, atau rating! Dari romansa yang bikin baper hingga thriller yang bikin deg-degan—semua ada di sini! Siap menemukan bacaan favoritmu? 🔥📖💫",
                        style = "font-size: 16px; color: #444;")
                  )
                )
              ),
              
              fluidRow(
                box(
                  title = div("💖📖 Novel Pilhan Pengguna",style = "font-size: 16px; font-weight: bold; color: #013D5A;"),
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
              h2("📚 Daftar Novel"),
              fluidRow(
                column(4, selectInput("selectedNovelTitle", "Pilih Judul:", choices = c("Semua"), selected = "Semua")),
                column(4, selectInput("selectedRating", "Pilih Kategori Rating:", choices = c("Semua", "Above 4","Below 4"), selected = "Semua"))
              ),
              box(width = 12, dataTableOutput("NovelTable"))
      ),
      
      tabItem("penulis",
              h2("✒️ Cari Data Penulis"),
              fluidRow(
                column(4, selectInput("selectedAuthor", "Cari Biodata Penulis:", choices = c("Semua"), selected = "Semua")),
              ),
              box(width = 12, dataTableOutput("AuthorTable"))
      ),
      
      
      tabItem("genre",
              h2("🎭 Cari Novel Berdasarkan Genre"),
              fluidRow(
                column(6, selectInput("selectedGenre", "Pilih Genre:", choices = c("Semua"), selected = "Semua")),
                column(6, selectInput("selectedYear", "Pilih Tahun:", choices = c("Semua"), selected = "Semua"))
              ),
              box(width = 12, dataTableOutput("genreTable")),
              fluidRow(
                box(title = "🎭 Distribusi Novel Berdasarkan Genre", width = 6, solidHeader = TRUE, plotlyOutput("genreDistPlot")),
                box(title = "📆 Distribusi Novel Berdasarkan Tahun", width = 6, solidHeader = TRUE, plotlyOutput("yearDistPlot"))
              )
      ),
      
      tabItem("review",
              h2("💬 Ulasan Novel"),
              fluidRow(selectInput("selectedReviewNovel", "Pilih Novel:", choices = c("Semua"), selected = "Semua")),
              fluidRow(
                column(width = 6, 
                       infoBox("Total Ulasan", 245, icon = icon("comments"), color = "purple", width = NULL)
                ),
                column(width = 6, 
                       infoBox("Rata-Rata Rating", 4.04, icon = icon("star"), color = "teal", width = NULL)
                )
              ),
              box(width = 12, dataTableOutput("reviewTable"))
      ),
      
      tabItem("top_movie",
              h2("🌟 Novel dengan Rating Tertinggi"),
              uiOutput("topMovieBox"),
              box(title = "🏆 5 Novel Teratas", width = 12, dataTableOutput("topMovieTable"))
      ),
      
      tabItem("team",
              h2("🤓 Meet Our Rotten Story Team!!!", 
                 style = "text-align: center; font-weight: bold; color: #013D5A; margin-bottom: 16px;"),
              
              # Grid container untuk 2x2 layout, dengan posisi lebih ke tengah
              div(style = "display: grid; grid-template-columns: repeat(2, 1fr); 
               gap: 10px; justify-content: center; align-items: center;",
                  
                  # Database Manager
                  div(style = "display: flex; justify-content: center; align-items: center;",
                      tags$img(src = "Jasmin.png", width = "400px", height = "400px", 
                               style = "object-fit: cover; border-radius: 10px;")
                  ),
                  
                  # Front End Developer
                  div(style = "display: flex; justify-content: center; align-items: center;",
                      tags$img(src = "Yeky.png", width = "400px", height = "400px", 
                               style = "object-fit: cover; border-radius: 10px;")
                  ),
                  
                  # Back End Developer
                  div(style = "display: flex; justify-content: center; align-items: center;",
                      tags$img(src = "Qeis.png", width = "400px", height = "400px", 
                               style = "object-fit: cover; border-radius: 10px;")
                  ),
                  
                  # Designer Database
                  div(style = "display: flex; justify-content: center; align-items: center;",
                      tags$img(src = "Windi.png", width = "400px", height = "400px", 
                               style = "object-fit: cover; border-radius: 10px;")
                  )
              )
      )
      
      
      
    )
  )
)