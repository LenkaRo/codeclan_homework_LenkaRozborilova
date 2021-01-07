###########################################################################################
#   1 MVP
#   Take a copy of the app from the mini-lab today and 
#   use some of the tools learnt in the ‘Advanced UI’ lesson to make some changes, 
#   for example:
#    
#       Using HTML to change some of the font
#       Use a different layout (such as grid)
#       Adding more than 1 tab.
###########################################################################################

# changed the names of the two radioButton widgets to be in italic font using HTML 
# used shinytheme flatly in the UI
# changed the sidebarPanel to fluidRow and built the page with a series of three columns at the top
# added two tabs, one with graph, one with link to the website


library(shiny)
library(tidyverse)
library(shinythemes)

olympics_overall_medals <- read_csv("data/olympics_overall_medals.csv")

olympics_overall_medals <- olympics_overall_medals %>%
  mutate(
    condition = case_when(
      medal == "Gold" ~ "#fcba03",
      medal == "Silver" ~ "#C0C0C0",
      medal == "Bronze" ~ "#cd7f32"
    )
  )


ui <- fluidPage(
    
  theme = shinytheme("flatly"),
  
  titlePanel("Five Country Medal Comparison"),
  
  tabsetPanel(
      
      tabPanel("Plot",
  
          sidebarLayout(
            
            fluidRow(
                
                column(4,
              
                       radioButtons("season",
                                    tags$i("Summer or Winter Olympics?"),
                                    choices = c("Summer", "Winter")
                       )
                ),     
              
                column(4,
              
                       radioButtons("medal",
                                    tags$i("Which medal?"),
                                    choices = c("Gold", "Silver", "Bronze")
                       )
                ),
            
                column(4,
                       
                       tags$a("Olympic Games Website",
                              href = "https://www.Olympic.org/"
                       )
                )
            ),
            
            mainPanel("Plot",
                      plotOutput("medal_plot")
            )
         )        
      ),
      
      tabPanel("Website",
               
               tags$a("Olympic Games Website",
                      href = "https://www.Olympic.org/"
               ) 
      
      )
  )
)




server <- function(input, output) {
    
  output$medal_plot <- renderPlot({
    
    olympics_overall_medals %>%
      filter(team %in% c("United States",
                         "Soviet Union",
                         "Germany",
                         "Italy",
                         "Great Britain")) %>%
      filter(medal == input$medal) %>%
      filter(season == input$season) %>%
      ggplot() +
      aes(x = team, y = count, fill = condition) +
      scale_fill_identity() +
      geom_col()
  })
}


shinyApp(ui = ui, server = server)







