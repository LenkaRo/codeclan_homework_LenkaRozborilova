# Shiny - Weekend homework
# 
# In the CodeClanData package there is a dataset called game_sales. 
# It contains information about world wide video game sales.
# 
# We want you to create an interactive visualisation(s) of this data using Shiny - 
#     use the tools learned through the lessons on ggplot and Shiny to create the visualisation, 
#     and it should have at least one iteractive element where the user can change the visualisation 
#     (for example via a widget).
# 
# It’s completely up to you which elements of the data you focus on. 
# Please add a small comment with the code of each of your graphs/visuals to explain 
# why you picked viewing the data in this way and what insight you hope the user will gain from it. 
# This is great practice for the group project of starting to think about WHY you are plotting the data 
# and thinking about what insights and decisions do you want the dashboard users to get from it.

library(shiny)
library(shinythemes)
library(ggthemes)
library(tidyverse)
library(scales)
library(CodeClanData)

#View(game_sales)

# Shiny app
### Layout - Tab 1: Video games, two selectInput widgets, two output bar charts, reactive functionality (action button)
###          Tab 2: Meme image, website link

## User Interface
ui <- fluidPage(
    
    theme = shinytheme("flatly"),
    
    titlePanel("Video games overview"),
    
    tabsetPanel(
        tabPanel("Video games",
    
            sidebarLayout(
                sidebarPanel(
                    
                    selectInput("genre_select",
                                "Genre",
                                choices = unique(game_sales$genre)
                    ),
                    
                    selectInput("publisher_select",
                                "Publisher",
                                choices = unique(game_sales$publisher)
                    ),
                    
                    actionButton("update",
                                 "Press to update")
                    
                ),
                
                mainPanel(
                    
                    plotOutput("score_graph"),
                    
                    plotOutput("sales_graph")
                )
            )
        ),
        
        tabPanel("Meme",
                 
                mainPanel(
                    
                    HTML('<center><img src = "true_gamer.png"></center>'),
                    
                    hr(),
                    
                    tags$a("Source", href = "https://www.pinterest.com/pin/631911391441873672/")
                )
        )
    )
)

## Server
server <- function(input, output) {
    
    ### setting up the reactive functionality, to get the results only after selecting filters and pressing action button
    ### improving efficiency of the code by applying the filter function only once (it is used in both graphs)
    game_sales_filtered <- eventReactive(input$update, {
        game_sales %>% 
            filter(genre == input$genre_select) %>%  #input from UI
            filter(publisher == input$publisher_select) #input from UI
    })
    
    ### bar chart showing the score (both from critics and users) for each game from selected categories 
    output$score_graph <- renderPlot({
        
        game_sales_filtered() %>% #input from reactive function
            mutate(user_score = user_score * 10) %>% 
            pivot_longer(
                cols = c(critic_score, user_score),
                names_to = "evaluator",
                values_to = "score"
            ) %>% 
            group_by(evaluator) %>% 
            ggplot() +
            aes(x = name, y = score, fill = evaluator) +
            geom_col(position = "dodge") +
            theme_light() +
            labs(
                x = "Video game",
                y = "Score (%)",
                title = "\n\n Score"
            ) +
            coord_flip()
    })
    
    ### bar chart showing the sales for each game from selected categories
    output$sales_graph <- renderPlot({
        
        game_sales_filtered() %>% #input from reactive function
            mutate(
                sales = sales * 1000000
            ) %>% 
            ggplot() +
            aes(x = name, y = sales) +
            geom_col(fill = "steel blue") +
            theme_light() +
            scale_y_continuous(labels = scales::comma) +
            labs(
                x = "Video game",
                y = "Sales (units)",
                title = "\n\n Sales"
            ) +
            coord_flip()
    })
}

shinyApp(ui = ui, server = server)