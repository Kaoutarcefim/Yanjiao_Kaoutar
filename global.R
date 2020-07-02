# install.packages("RMySQL")
# install.packages("DT")
library(RMySQL)
library(shiny)
library(tidyverse)
library(DT)

con <-
  dbConnect(
    MySQL(),
    host = "localhost",
    user = "root",
    password = "Kaoutar1993*",
    dbname = "evaluation"
  )


