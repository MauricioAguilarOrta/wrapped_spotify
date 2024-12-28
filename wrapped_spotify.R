##### Creación de aplicación shiny para el Wrapped de Spotify #####
# Se sugiere llamar a este script app.R

# Paquetes, idioma y wd
# Si no tienes cargados estos paquetes deberás hacerlo antes de llamarlos con library(), esto con install.packages()
library(pacman)
p_load(tidyverse, jsonlite, shiny, plotly)
Sys.setlocale("LC_TIME", "English_United States.UTF-8")
path <- "~/" # Aquí la carpeta donde están tus archivos json
setwd(path)

# Cargar todos los archivos json. Hay tantos archivos como años y apilarlos en uno solo 
archivos <- list.files(path, pattern = "^Streaming_History_Audio_\\d+.*\\.json$", full.names = TRUE)
historical <- archivos %>%
  lapply(fromJSON) %>%       
  bind_rows() 

# Un poquito de limpieza, cambiar nombres y modificar el tiempo de reproducción, por default lo da en milisegundos, creamos nuestra variable que esté en minutos
historical <- historical %>% 
  rename(song = master_metadata_track_name,
         album = master_metadata_album_album_name,
         artist = master_metadata_album_artist_name) %>% 
  mutate(minutes_played = ms_played / 60000)

# Un vector que contendrá todos los años con registro en spotify, lo reconoce con los años iniciales en la variable ts
years <- historical %>%
  mutate(year = substr(ts, 1, 4)) %>%  
  pull(year) %>%                       
  unique()                             

# Para cada año que se detectó, dividiremos el histórico por esos años y además generamos un objeto del total de minutos de reproducción por año (para acada año detectado en el vector que creamos arriba)
for (year in years) {
  
  data_year <- historical %>%
    filter(grepl(paste0("^", year, "-"), ts))
  
  assign(paste0("spotify", year), data_year)
  
  total_minutes <- data_year %>%
    summarise(total = sum(minutes_played, na.rm = TRUE)) %>% 
    mutate(total = round(total, 2))
  
  assign(paste0("total_minutes_", year), total_minutes$total)
}

# Hasta aquí ya podrías usar esos objetos para visualizar ciertas métricas, pero hagamos un shiny

##### Shiny Application #####
# Los shiny se componen principalmente de una interfaz de usuario y un servidor. Puedes entrar en los detalles para ver cómo está definida cada una de las cosas. Si hasta aquí ya pudiste cargar con tus propios archivos, correr lo siguiente no debería tener ningún problema para ti y visualizarás el shiny con tu info de spotify

# Interfaz (en pocas palabras, toda la definición visual)
ui <- fluidPage(
  tags$head(
    tags$style(HTML("
      @import url('https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;600&display=swap');
      
      body {
        background-color: #191414;
        color: white;
        font-family: 'Poppins', sans-serif;
      }
      h1, h2, h3, h4, h5, h6 {
        color: #1DB954; 
        text-align: center; 
        font-weight: 600; 
      }
      .navbar-default {
        background-color: #191414;
      }
      .navbar-default .navbar-brand {
        color: #1DB954;
        font-weight: 600;
      }
      .shiny-input-container {
        color: white;
        font-weight: 400;
      }
      .plotly .main-svg {
        background-color: transparent !important;
      }
      .plotly-graph-div {
        border: 1px solid #1DB954;
      }
      .logo-spotify {
        position: absolute;
        top: 10px;
        right: 10px;
        width: 50px;
        height: 50px;
        opacity: 0.8;
      }
      .selectize-input, .selectize-dropdown {
        background-color: #333 !important; 
        border: 1px solid #1DB954 !important;
        color: white !important;
        text-align: center; 
      }
      .selectize-input:focus {
        border-color: #1DB954 !important;
      }
      .selectize-dropdown {
        color: white !important;
        border: 1px solid #1DB954;
        text-align: center;
      }
      .shiny-input-container label {
        color: white !important;
        font-weight: 600;
        text-align: center;
        display: block;
        width: 100%;
      }
      .total-minutes-text {
        font-size: 24px;
        font-weight: 600;
        color: white;
        text-align: center;
        margin-top: 10px;
        width: 100%; 
      }
      .footer-text {
        position: fixed;
        bottom: 10px;
        right: 10px;
        color: white;
        font-size: 16px;
        font-weight: 400;
        opacity: 0.8;
      }
      .selectInput {
        color: white !important;
        font-weight: 600;
      }
      .center-container {
        display: flex;
        justify-content: center;
        width: 100%;
        margin-top: 20px;
      }
    "))
  ),
  
  # Título dinámico
  titlePanel(uiOutput("dynamic_title")),  
  

  fluidRow(
    column(12, 
           div(
             class = "center-container", 
             selectInput(
               "year",
               "Select a year:",
               choices = c("Historical", years),
               selected = "Historical",
               width = "200px"  
             )
           )
    )
  ),
  
  fluidRow(
    column(12, 
           div(
             style = "display: flex; justify-content: center;",
             uiOutput("total_minutes_text")
           )
    )
  ),
  
  fluidRow(
    column(4, plotlyOutput("song_graph")),
    column(4, plotlyOutput("album_graph")),
    column(4, plotlyOutput("artist_graph"))
  ),
  # Le agregamos el logo de spotify descargándolo de esta liga
  img(src = "https://storage.googleapis.com/pr-newsroom-wp/1/2023/05/Spotify_Primary_Logo_RGB_Green.png", class = "logo-spotify"),
  
  # Aquí yo agregué mi usuario de X como marca de agua
  tags$div(
    class = "footer-text", 
    "X: @MauAguilarOrta"
  )
)

#Aquí se define el servidor
server <- function(input, output, session) {
  # El título es dinámico para que reconozca el año más antiguo de cada persona, en mi caso dice Since 2013 porque desde entonces tengo datos en spotify pero se actualizará para cada persona
  output$dynamic_title <- renderUI({
    title <- paste("My Real Spotify Wrapped Since", min(years))
    titlePanel(title)
  })
  
  filtered_data <- reactive({
    if (input$year == "Historical") {
      historical
    } else {
      get(paste0("spotify", input$year))
    }
  })
  
  output$total_minutes_text <- renderUI({
    if (input$year == "Historical") {
      total_minutes <- sum(historical$minutes_played, na.rm = TRUE)
    } else {
      total_minutes <- get(paste0("total_minutes_", input$year))
    }
    total_minutes_formatted <- prettyNum(total_minutes, big.mark = ",")
    span(paste("Total Minutes in", input$year, ":", total_minutes_formatted), class = "total-minutes-text")
  })
  
  output$song_graph <- renderPlotly({
    filtered_data() %>%
      group_by(song, artist) %>%
      summarise(total_minutes = sum(minutes_played, na.rm = TRUE)) %>%
      arrange(desc(total_minutes)) %>%
      head(20) %>%
      plot_ly(
        x = ~total_minutes, 
        y = ~reorder(song, total_minutes), 
        type = "bar", 
        orientation = "h", 
        marker = list(color = "#1DB954"),
        hoverinfo = "text",
        text = ~paste("Minutes played: ", prettyNum(round(total_minutes, 2), big.mark = ","), "<br>Artist: ", artist),
        textposition = "none"
      ) %>%
      layout(
        title = list(text = paste("Top 20 Songs (", input$year, ")", sep = ""), font = list(color = "white")),
        xaxis = list(title = "Minutes Played", tickfont = list(color = "white"), titlefont = list(color = "white")),
        yaxis = list(title = "", tickfont = list(color = "white", size = 10)),
        margin = list(t = 80, b = 80)
      )
  })
  
  output$album_graph <- renderPlotly({
    filtered_data() %>%
      group_by(album, artist) %>%
      summarise(total_minutes = sum(minutes_played, na.rm = TRUE)) %>%
      arrange(desc(total_minutes)) %>%
      head(20) %>%
      plot_ly(
        x = ~total_minutes, 
        y = ~reorder(album, total_minutes), 
        type = "bar", 
        orientation = "h", 
        marker = list(color = "#1DB954"),
        hoverinfo = "text",
        text = ~paste("Minutes played: ", prettyNum(round(total_minutes, 2), big.mark = ","), "<br>Artist: ", artist),
        textposition = "none"
      ) %>%
      layout(
        title = list(text = paste("Top 20 Albums (", input$year, ")", sep = ""), font = list(color = "white")),
        xaxis = list(title = "Minutes Played", tickfont = list(color = "white"), titlefont = list(color = "white")),
        yaxis = list(title = "", tickfont = list(color = "white", size = 10)),
        margin = list(t = 80, b = 80)
      )
  })
  
  output$artist_graph <- renderPlotly({
    filtered_data() %>%
      group_by(artist) %>%
      summarise(total_minutes = sum(minutes_played, na.rm = TRUE)) %>%
      arrange(desc(total_minutes)) %>%
      head(20) %>%
      plot_ly(
        x = ~total_minutes, 
        y = ~reorder(artist, total_minutes), 
        type = "bar", 
        orientation = "h", 
        marker = list(color = "#1DB954"),
        hoverinfo = "text",
        text = ~paste("Minutes played: ", prettyNum(round(total_minutes, 2), big.mark = ",")),
        textposition = "none"
      ) %>%
      layout(
        title = list(text = paste("Top 20 Artists (", input$year, ")", sep = ""), font = list(color = "white")),
        xaxis = list(title = "Minutes Played", tickfont = list(color = "white"), titlefont = list(color = "white")),
        yaxis = list(title = "", tickfont = list(color = "white", size = 10)),
        margin = list(t = 80, b = 80)
      )
  })
}

#Aquí se ejecuta la aplicación con la interfaz y el servidor
shinyApp(ui, server)

# Si deseas publicarlo necesitas una cuenta en shiny.app (hay otras opciones pero ésta es la más sencilla). Encuentra las credenciales en tu perfil y pégalas aquí
rsconnect::setAccountInfo(name='',
                          token='',
                          secret='')

# Aquí se ejecuta con el path que definiste al principio, tu working directory.
rsconnect::deployApp(path)
