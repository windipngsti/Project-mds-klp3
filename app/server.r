library(shiny)
library(shinydashboard)
library(tidyverse)
library(DBI)
library(RMySQL)
library(ggplot2)
library(plotly)
library(DT)
library(bs4Dash)

# Server
server <- function(input, output, session) {
  
  # Koneksi Tunggal ke Database
  con <- dbConnect(
    RMySQL::MySQL(), 
    dbname = "rotten_story", 
    host = "localhost", 
    username = "root", 
    password = "", 
    port = 3306
  )
  
  # Pastikan Koneksi Ditutup Saat Aplikasi Berhenti
  onStop(function() {
    dbDisconnect(con)
  })
  
  # Fungsi Query Aman
  def_safe_query <- function(query) {
    tryCatch({
      dbGetQuery(con, query)
    }, error = function(e) {
      warning(paste("Gagal mengambil data:", e$message))
      NULL
    })
  }
  
  # Tab Homepage
  # Query untuk menghitung Total Novel
  output$totalNovel <- renderValueBox({
    query <- "SELECT COUNT(*) AS total FROM novel"
    result <- def_safe_query(query)
    valueBox("Total Novel",result$total, icon = icon("book"), color = "fuchsia")
  })
  
  # Query untuk menghitung Total Genre
  output$totalPenulis <- renderValueBox({
    query <- "SELECT COUNT(DISTINCT penulis) AS total FROM penulis"
    result <- def_safe_query(query)
    valueBox("Total Penulis",result$total, icon = icon("pen"), color = "indigo")
  })
  
  # Query untuk menghitung Rata-rata Rating
  output$averageRating <- renderValueBox({
    query <- "SELECT ROUND(AVG(rating_novel), 1) AS avg_rating FROM novel"
    result <- def_safe_query(query)
    valueBox("Rata-rata Rating",result$avg_rating, icon = icon("star"), color = "teal")
  })
  
  # Query untuk membuat plot distribusi genre
  output$genrePlot <- renderPlotly({
    query_genre_count <- "SELECT g.nama_genre, COUNT(ng.id_novel) AS jumlah
                          FROM genre g
                          JOIN novel_genre ng ON g.id_genre = ng.id_genre
                          GROUP BY g.nama_genre
                          ORDER BY jumlah DESC"
    genre_data <- def_safe_query(query_genre_count)
    
    # Pastikan data tidak kosong sebelum membuat plot
    if (nrow(genre_data) > 0) {
      # Ubah nama_genre menjadi faktor dengan urutan berdasarkan jumlah
      genre_data$nama_genre <- factor(genre_data$nama_genre, levels =          genre_data$nama_genre[order(-genre_data$jumlah)])
      
      plot_ly(genre_data, 
              x = ~nama_genre, 
              y = ~jumlah, 
              type = "bar", 
              marker = list(color = "#213555")) %>%
        layout(title = "Jumlah Novel per Genre", 
               xaxis = list(title = "Genre", tickangle = -45), 
               yaxis = list(title = "Jumlah"))
    } else {
      plot_ly() %>% 
        layout(title = "Jumlah Novel per Genre", 
               xaxis = list(title = "Genre"), 
               yaxis = list(title = "Jumlah"),
               annotations = list(
                 list(text = "Tidak ada data", x = 0.5, y = 0.5, showarrow = FALSE)
               ))
    }
  })
  
  output$ratingPlot <- renderPlotly({
    query_rating <- "SELECT rating_novel, COUNT(*) AS jumlah
                    FROM novel
                    GROUP BY rating_novel
                    ORDER BY jumlah DESC
                    LIMIT 12"  # Ambil 12 rating dengan jumlah novel terbanyak
    
    rating_data <- def_safe_query(query_rating)  # Eksekusi query
    
    # Pastikan data tidak kosong sebelum membuat plot
    if (nrow(rating_data) > 0) {
      rating_data$rating_novel <- factor(rating_data$rating_novel, levels = rating_data$rating_novel)  # Urutkan faktor sesuai SQL
      
      plot_ly(rating_data, 
              x = ~rating_novel,  
              y = ~jumlah,  
              type = "bar",  
              marker = list(color = "#213555")  # Warna batang
              ) %>%
        layout(title = "Jumlah novel berdasarkan rating",
               xaxis = list(title = "Rating", categoryorder = "array", categoryarray = rating_data$rating_novel),  
               yaxis = list(title = "Jumlah Novel"))
    } else {
      plot_ly() %>%
        layout(title = "Distribusi Rating Novel",
               xaxis = list(title = "Rating"), 
               yaxis = list(title = "Jumlah"),
               annotations = list(
                 list(text = "Tidak ada data", x = 0.5, y = 0.5, showarrow = FALSE)
               ))
    }
  })
  
  top_novels <- reactive({
  query <- "SELECT judul, rating_novel, sampul 
            FROM novel 
            ORDER BY rating_novel DESC 
            "  # Ambil 5 novel teratas berdasarkan rating
  def_safe_query(query)
  })

  output$novelSlider <- slickR::renderSlickR({
  data <- top_novels()
  
  if (!is.null(data) && nrow(data) > 0) {
    sampul_urls <- as.character(data$sampul)

    slickR::slickR(
      obj = sampul_urls,  
      slideType = "img"
    ) + slickR::settings(
      slidesToShow = 5, slidesToScroll = 1, 
      infinite = TRUE, autoplay = TRUE, autoplaySpeed = 3000
    )
  } else {
    return(NULL)
  }
})



  
  #Novel
 # Reactive function untuk mengambil data novel
  novel_data <- reactive({
  novel_query <- "SELECT id_novel, 
                         judul, 
                         tahun_terbit, 
                         isbn, 
                         bahasa, 
                         edisi, 
                         jumlah_halaman, 
                         deskripsi, 
                         rating_novel, 
                         sampul
                  FROM novel"
  
  def_safe_query(novel_query)
  })

  # Observasi untuk update dropdown judul novel
  observe({
  req(novel_data())
  updateSelectInput(session, "selectedNovelTitle", 
                    choices = c("Semua", sort(unique(novel_data()$judul))))
  })

  # Render tabel berdasarkan filter
  output$NovelTable <- renderDataTable({
  req(novel_data())
  
  filtered_novel_data <- novel_data()
  
  # Filter berdasarkan judul
  if (input$selectedNovelTitle != "Semua") {
    filtered_novel_data <- filtered_novel_data %>% filter(judul ==              input$selectedNovelTitle)
  }
  
  # Filter berdasarkan kategori rating
  if (input$selectedRating == "Above 4") {
    filtered_novel_data <- filtered_novel_data %>% filter(rating_novel > 4)
  } else if (input$selectedRating == "Below 4") {
    filtered_novel_data <- filtered_novel_data %>% filter(rating_novel <= 4)
  }
  
  # Tambahkan kolom cover (HTML tag img)
  filtered_novel_data$sampul <- paste0(
    '<img src="', filtered_novel_data$sampul, 
    '" style="width:90px; height:120px;">'
  )
  
  # Batasi panjang deskripsi dengan "Read More"
  filtered_novel_data$Deskripsi <- ifelse(nchar(filtered_novel_data$deskripsi) > 100, 
    paste0(substr(filtered_novel_data$deskripsi, 1, 100), 
           '... <a href="#" onclick="alert(\'', 
           gsub("'", "\\'", filtered_novel_data$deskripsi), 
           '\');">Read more</a>'),
    filtered_novel_data$deskripsi
  )
  
  # Pilih kolom yang akan ditampilkan
  filtered_novel_data <- filtered_novel_data %>% select(
    sampul, Judul = judul, Tahun = tahun_terbit, 
    Halaman = jumlah_halaman, Rating = rating_novel, Deskripsi
  )
  
  # Tampilkan dalam DataTable dengan escape = FALSE agar HTML dirender
  datatable(filtered_novel_data, 
            options = list(pageLength = 10, autoWidth = TRUE), 
            escape = FALSE,  # Aktifkan render HTML untuk gambar & deskripsi
            class = "display")
})

  #Penulis
  # Reactive function untuk mengambil data penulis
  author_data <- reactive({
    author_query <- "SELECT id_penulis, 
                            penulis, 
                            tempat_lahir, 
                            tanggal_lahir, 
                            jumlah_buku 
                     FROM penulis"
    
    def_safe_query(author_query)
  })
  
  # Observasi untuk update dropdown pilihan penulis
  observe({
    req(author_data())
    updateSelectInput(session, "selectedAuthor", 
                      choices = c("Semua", sort(unique(author_data()$penulis))))
  })
  
  # Render tabel berdasarkan filter
  output$AuthorTable <- renderDataTable({
    req(author_data())
    
    filtered_author_data <- author_data()
    
    # Filter berdasarkan nama penulis
    if (input$selectedAuthor != "Semua") {
      filtered_author_data <- filtered_author_data %>% filter(penulis == input$selectedAuthor)
    }
    
    # Pilih kolom yang akan ditampilkan
    filtered_author_data <- filtered_author_data %>% select(
      "Nama Penulis" = penulis, 
      "Tempat Lahir" = tempat_lahir, 
      "Tanggal Lahir" = tanggal_lahir, 
      "Jumlah Buku" = jumlah_buku
    )
    
    # Tampilkan dalam DataTable
    datatable(filtered_author_data, 
              options = list(pageLength =12, autoWidth = TRUE),
              class = "display")
  })

  # Reactive function untuk mengambil data ulasan
review_data <- reactive({
  review_query <- "SELECT ulasan.id_novel, 
                          novel.judul, 
                          ulasan.nama_user, 
                          ulasan.tanggal_ulasan, 
                          ulasan.ulasan, 
                          novel.rating_novel 
                   FROM ulasan 
                   JOIN novel ON ulasan.id_novel = novel.id_novel"
  
  def_safe_query(review_query)
})

# Observasi untuk update dropdown pilihan novel
observe({
  req(review_data())
  updateSelectInput(session, "selectedReviewNovel", 
                    choices = c("Semua", sort(unique(review_data()$judul))))
})

# Reactive function untuk menyaring data ulasan berdasarkan pilihan novel
filtered_review_data <- reactive({
  req(review_data())
  data <- review_data()
  
  # Filter berdasarkan judul novel
  if (input$selectedReviewNovel != "Semua") {
    data <- data %>% filter(judul == input$selectedReviewNovel)
  }
  
  return(data)
})

# Render total ulasan berdasarkan novel yang dipilih
output$totalReviews <- renderValueBox({
  req(filtered_review_data())
  total <- nrow(filtered_review_data()) # Hitung jumlah ulasan
  valueBox(total, "Total Ulasan", icon = icon("comments"), color = "purple")
})

# Render rata-rata rating berdasarkan novel yang dipilih
output$averageReviewRating <- renderValueBox({
  req(filtered_review_data())
  
  # Periksa apakah ada data agar tidak error
  if (nrow(filtered_review_data()) > 0) {
    avg_rating <- mean(filtered_review_data()$rating_novel, na.rm = TRUE) # Hitung rata-rata rating
  } else {
    avg_rating <- 0
  }
  
  valueBox(round(avg_rating, 2), "Rata-Rata Rating", icon = icon("star"), color = "info")
})

# Render tabel ulasan berdasarkan filter
output$reviewTable <- renderDataTable({
  req(filtered_review_data())
  
  # Pilih kolom yang akan ditampilkan
  review_table <- filtered_review_data() %>% select(
    "Judul Novel" = judul, 
    "Nama Pengguna" = nama_user, 
    "Tanggal Ulasan" = tanggal_ulasan, 
    "Ulasan" = ulasan
  )
  
  # Tampilkan dalam DataTable
  datatable(review_table, 
            options = list(pageLength = 10, autoWidth = TRUE),
            class = "display")
})



}