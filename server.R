

dbGetQuery(con, "SET NAMES 'utf8'")

# lapply(dbListConnections(MySQL()), dbDisconnect)

#Fonction pour recuperer les reponses des etudiants selon id
reponse_etudiant <- function(id) {
  print("Je suis déconnecté")
  tbl(con, sql(
    paste(
      "SELECT r.id, r.texte, r.`date`, q.`type`, q.libelle, p.titre
  FROM evaluation.reponse r
  INNER JOIN evaluation.question q ON q.id = r.question_id
  INNER JOIN evaluation.`page` p ON p.id = q.page_id
  LEFT JOIN evaluation.choix c ON c.id = r.choix_id
  WHERE session_id = ",
      id,
      "
                    ORDER BY p.ordre"
    )
  )) %>% collect()
}

#Fonction pour afficher les formations

afficher_formation <- function(id) {
  print("Je suis déconnecté")
  tbl(con, sql(
    paste(
      "SELECT question.id, question.libelle FROM choix c
                    inner join page_condition pgc on c.id = pgc.choix_id
                    inner join question on question.page_id = pgc.page_id
                    where choix_id = ",
      id,
      " "
    )
  )) %>% collect
}

#fonction pour afficher les question selon id de formations
afficher_question <- function() {
  tbl(con,
      sql("SELECT id, libelle as formation FROM evaluation.question")) %>% collect
}

graph <- function(id) {
  tbl(con,
      sql(
        paste(
          "SELECT pgc.choix_id,question.id, question.libelle, question.type, reponse.texte, reponse.score FROM choix c
inner join page_condition pgc on c.id = pgc.choix_id
inner join question on question.page_id = pgc.page_id
inner join reponse on reponse.question_id = question.id
inner join session on session.id = reponse.session_id where question.type='score' and question.id = ",
          id
        )
      )) %>% collect
}

#Fonction pour afficher les reponses textuelle
recup_verbatim <- function(id) {
  tbl(con,
      sql(
        paste(
          "SELECT pgc.choix_id,question.id, question.libelle, question.type, reponse.texte, reponse.score FROM choix c
                        inner join page_condition pgc on c.id = pgc.choix_id
                        inner join question on question.page_id = pgc.page_id
                        inner join reponse on reponse.question_id = question.id
                        inner join session on session.id = reponse.session_id where ((question.type= 'texte_long') OR (question.type='texte_court')) AND question.id = ",
          id
        )
      )) %>% collect()
}


function(input, output, session) {
  onStop(function() {
    dbDisconnect(con)
    print("Je suis déconnecté")
    
  })
  output$df <- renderDataTable({
    reponse_etudiant(input$etudiant_filter)

  })
  
  output$formation <- renderDataTable({
    afficher_formation(input$formation_filter)
  })
  
  
  
  observeEvent(
    input$formation_filter,
    updateSelectInput(
      session,
      "question_filter",
      choices = c(
        setNames(
          afficher_formation(input$formation_filter)$id,
          afficher_formation(input$formation_filter)$libelle
        )
      ),
      print(input$formation_filter)
    )
  )
  
  output$histo <- renderPlot({
    graph(input$question_filter) %>%
      ggplot() +
      geom_histogram(aes(x = score))
  })
  
  output$verbatim <- renderDataTable(
    recup_verbatim(input$question_filter)
  )
  
}
