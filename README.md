Este script permite crear una aplicación Shiny interactiva que replica y amplía la lógica del Spotify Wrapped, utilizando los archivos de historial de reproducción que Spotify proporciona al usuario en formato JSON. El objetivo es ofrecer una visualización personalizada, transparente y reproducible del consumo musical a lo largo del tiempo.
La aplicación procesa automáticamente los archivos históricos, genera métricas agregadas y permite explorar la información tanto de forma acumulada como por año específico.

**Archivos necesarios**
El script está pensado para ejecutarse como una aplicación Shiny y se recomienda nombrarlo app.R.
Es necesario contar con los archivos JSON de Spotify, normalmente descargados desde la sección “Download your data” de Spotify. Estos archivos suelen tener nombres como:
Streaming_History_Audio_2019.json
Streaming_History_Audio_2020.json
Streaming_History_Audio_2021.json

Todos los archivos deben colocarse en una misma carpeta, cuyo path debe indicarse en el script.

**Paquetes utilizados**
El script utiliza los siguientes paquetes de R:

- tidyverse: manipulación y limpieza de datos

- jsonlite: lectura de archivos JSON

-shiny: construcción de la aplicación interactiva

- plotly: visualizaciones interactivas

La carga de paquetes se gestiona con pacman para facilitar su instalación automática si no están disponibles.

**Flujo de procesamiento de datos**

*Carga de archivos JSON*
El script detecta automáticamente todos los archivos de historial de Spotify presentes en la carpeta indicada y los concatena en un solo dataset histórico.

*Limpieza y transformación*
- Se renombran variables para mayor claridad (canción, álbum, artista).
- Se convierte el tiempo de reproducción de milisegundos a minutos.
- Se identifican los años disponibles a partir del timestamp (ts).

**Separación por año**
Para cada año detectado:
- Se crea un objeto con los datos de ese año.
- Se calcula el total de minutos reproducidos.
- Estos objetos se utilizan dinámicamente dentro de la aplicación.

**Funcionalidades de la aplicación**
La aplicación Shiny incluye:
- Selector de año:
- Opción Historical para ver el histórico completo.
- Opción de seleccionar años individuales disponibles.
- Indicador de minutos totales reproducidos para el periodo seleccionado.
- Tres visualizaciones interactivas (Top 20):
- Canciones más escuchadas
- Álbumes más escuchados
- Artistas más escuchados
- Gráficos interactivos con plotly, que permiten explorar detalles al pasar el cursor.

**Diseño e interfaz**
La interfaz está inspirada en la estética de Spotify:
- Tema oscuro
- Tipografía moderna (Poppins)
- Colores institucionales de Spotify
- Inclusión del logotipo oficial
- Estilo visual consistente en todos los gráficos

El título de la aplicación es dinámico y se adapta al año más antiguo disponible en los datos del usuario (por ejemplo: “My Real Spotify Wrapped Since 2013”).

**Ejecución**
Una vez que:
- los archivos JSON están en la carpeta correcta,
- el path ha sido configurado,
- y los paquetes están instalados,

la aplicación puede ejecutarse directamente desde RStudio:
```r
shiny::runApp()
```
o simplemente ejecutando el script app.R.

**Notas finales**
- El producto tiene fines recreativos únicamente.
- La aplicación no depende de servicios externos ni de la API de Spotify.
- Todo el procesamiento se realiza de forma local con los datos del usuario y sus propias rutas.
- El script puede adaptarse fácilmente para agregar nuevas métricas o visualizaciones.

Mi ejemplo personal se encuentra en: https://mauricioaguilarorta1992.shinyapps.io/spotify_wrapped/ (too much Interpol!)
