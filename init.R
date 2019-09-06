options("h2o.use.data.table" = TRUE)
options(stringsAsFactors = FALSE)
options(java.parameters = "-Xmx4096m")
options(dplyr.width = Inf) 
Sys.setenv(TZ='GMT')
if( "data.table" %in% rownames(installed.packages()) ){
  data.table::setDTthreads(0)
}
if( "tidyverse" %in% rownames(installed.packages()) ){
  options(tidyverse.quiet = TRUE)
}

# Proyect Parameters ------------------------------------------------------

path_src = paste0(getwd(),"/") # Si se pone rstudioapi::, solo se puede usar desde rstudio, no desde shiny
path_files = paste0(path_src,"files/")
project_name = basename(path_src)

# Basic Libraries Entel Framework -----------------------------------------

if(!require("dftools")){
  if( !"devtools" %in% rownames(installed.packages()) ){
    install.packages("devtools")
  }
  print("Installing dftools...")
  devtools::install_github("danielfm123/dftools",force=T)
  library(dftools)
}

# Configuraci?n seg?n OS --------------------------------------------------

if(version$os == "mingw32"){
  # Hacer si es Windows
}else{
  #Cosas que pasan cuando corre en linux
}

sourceDir("functions")

# Conecciones SQL

pg_sample = expression({
    safeLibrary("RPostgres")
    safeLibrary("bit64")
    dbConnect(
      dbDriver("Postgres"),
      dbname = "database",
      user = "usuario",
      password = "contrasena",
      host = "hostname",
      port = 5432,
      bigint = "integer64"
    )
})
rs_sample = expression({
  safeLibrary("RPostgres")
  safeLibrary("bit64")
  dbConnect(
    dbDriver("Postgres"),
    dbname = "database",
    user = "usuario",
    password = "password",
    host = "hostname",
    port = 5439,
    bigint = "integer64"
  )
})


odbc_sample = expression({
  safeLibrary("odbc")
  #la ip tb creo que puede ser 200.7.29.203
  dbConnect(odbc(),.connection_string = "ODBC_Connection_String")
})
