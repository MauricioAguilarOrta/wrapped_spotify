#Aquí se ejecuta la aplicación con la interfaz y el servidor
shinyApp(ui, server)

# Si deseas publicarlo necesitas una cuenta en shiny.app (hay otras opciones pero ésta es la más sencilla). Encuentra las credenciales en tu perfil y pégalas aquí
rsconnect::setAccountInfo(name='',
                          token='',
                          secret='')

# Aquí se ejecuta con el path que definiste al principio, tu working directory.
rsconnect::deployApp(path)