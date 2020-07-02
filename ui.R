# install.packages('shinythemes')
library(shinythemes)

##Fonction pour recuperer les etudiants avec une requete SQL
recup_etudiant <- function() {
  tbl(
    con,
    sql(
      "SELECT nom.session_id as id, prenom.texte as prenom, nom.texte as nom
            FROM
                (SELECT q.libelle, r.texte, r.session_id
                FROM evaluation.reponse r
                INNER JOIN evaluation.question q ON q.id = r.question_id
                WHERE q.libelle = 'Nom') as nom
            INNER JOIN (SELECT q.libelle, r.texte, r.session_id
                FROM evaluation.reponse r
                INNER JOIN evaluation.question q ON q.id = r.question_id
                WHERE q.libelle = 'Prenom') as prenom
            ON nom.session_id = prenom.session_id"
    )
  ) %>% collect
}

#Fonction pour recuperer les formation
recup_formation <- function(){

  tbl(con,
      sql("SELECT id, libelle FROM choix WHERE question_id=14 LIMIT 11")) %>% collect
}
#fonction pour recuperer les questions
recup_question <- function() {
  tbl(con,
      sql("SELECT id, libelle as question FROM evaluation.question")) %>% collect
}


fluidPage(theme = shinytheme("united"),
           titlePanel("BILAN DE LA FORMATION CEFIM"),
          navbarPage(
            h4(p(strong('Réposnes des étudiants',style="color:black"))),
            tabsetPanel(
              tabPanel(
                selectInput(
                  "etudiant_filter",
                  "Filtrer par nom d'étudiant :",
                  choices =  c(setNames(
                    recup_etudiant()$id, (recup_etudiant()$nom)
                  ))
                ),
                dataTableOutput("df")),
              tabPanel(
                selectInput(
                  "formation_filter",
                  "Filtrer par formation:",
                  choices = c(setNames(
                    recup_formation()$id, (recup_formation()$libelle)
                  ))
                ),
                selectInput(
                  "question_filter",
                  "Filtrer par question:",
                  choices = c(setNames(recup_question()$id, 
                    (recup_question()$question)
              ))
              ),
              

              dataTableOutput("formation"),
              plotOutput("histo"), 
              dataTableOutput("verbatim")
              )
             
              )
              

          )
)
              
              
              



          


