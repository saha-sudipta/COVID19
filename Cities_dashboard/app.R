library(shinydashboard)
library(dplyr)
library(readr)
library(lubridate)
library(ggplot2)
library(googlesheets4)
library(DT)
options(scipen = 999)


#Authenticate Google Sheets

sheets_auth(cache = ".secrets", email = "sudipta.bba@gmail.com")


ui <- dashboardPage(
  
  
  
  dashboardHeader(title = "COVID-19 Cities Dashboard"),
  
  
  
  dashboardSidebar(
    
    sidebarMenu(
      menuItem("Graphs", tabName = "graphs", icon = icon("dashboard")),
      menuItem("Data", tabName = "data", icon = icon("list"))
    ),
    actionButton("refresh_button", "Update Data"),
    
    tags$footer(
      tags$p("Last Updated:", br(), textOutput("update_time", container = span),
             style = "padding: 10px;"))
  ),
  dashboardBody(
    
    
    tags$style(
      type = 'text/css', 
      '.bg-green {background-color: #00A08A!important; }',
      '.bg-orange {background-color: #F2AD00!important; }',
      '.bg-teal {background-color: #5BBCD6!important; }'
    ),
    
    
    tabItems(
      
      
      # Graphs
      tabItem(tabName = "graphs",
              h2("Graphs"),
              
              fluidRow(
                
                box(width = 3,
                    selectInput("city_select", "City:", multiple = TRUE, selected = "Toronto",
                                choices=list(
                                  US = c("Boston"="Boston",
                                         "Chicago" = "Chicago",
                                         "Detroit" = "Detroit",
                                         "New York" = "New York",
                                         "Philadelphia" = "Philadelphia",
                                         "San Francisco" = "San Francisco",
                                         "Seattle" = "Seattle"),
                                  Canada = c("Calgary"="Calgary",
                                             "Edmonton" = "Edmonton",
                                             "Montreal" = "Montreal",
                                             "Ottawa" = "Ottawa",
                                             "Peel Region" = "Peel Region",
                                             "Toronto" = "Toronto",
                                             "Vancouver Coastal" = "Vancouver Coastal"
                                             )))),
                box(width = 3,
                    radioButtons("y_axis", "Y Axis Scale", c("Log" = "log",
                                                             "Linear" = "linear"
                    ))),
                box(width = 3,
                    radioButtons("x_axis", "Time Plotted", c("Actual Date" = "Date",
                                                             "Day since 100th case" = "Date_from_100"
                    ))
                ),
                box(width = 3,
                    radioButtons("val", "Value", c("Absolute Count" = "Cumulative_Total", 
                                                   "Rate per 100,000" = "Rate")
                    ))
              ),
              
              fluidRow(
                box(width = 12, plotOutput("time_graph"))
              )
              
      ),
      
      # Data
      tabItem(tabName = "data",
              h2("Data"),
              
              fluidRow(
                box(width=12, DT::dataTableOutput("data_table"))
              )
              
      )
    )
  ))

server <- function(input, output){ 
  
  data2 <- eventReactive(input$refresh_button, {
    data2 <- sheets_read("1Pi04l_PYXBUpQCGZWF0gXLaPxTFsnCY-sWCE5rtwCiY")
    data2
  }, ignoreNULL = FALSE)
  
  update_time <- eventReactive(input$refresh_button, {
    format(Sys.time())
  }, ignoreNULL = FALSE)
  
  
  
  output$update_time <- renderText(paste0(update_time(), " EDT"))
  
  
  
  #Time Graph
  
  time_graph_data <- reactive({
    data2 <- filter(data2(), City %in% input$city_select)
    if(input$x_axis=="Date_from_100"){
      data2 <- filter(data2, Date_from_100 >= 0)
    }
    data2
  })
  
  output$time_graph <- renderPlot({
    
    
    plot <- ggplot(time_graph_data()) + 
      geom_line(aes_string(x=input$x_axis, y=input$val, group="City", colour="City"), size=1.5) + 
      theme_minimal() + labs(x="Date", y="Number of Cases")
    if(input$y_axis=="log"){
      plot <- plot + scale_y_log10()
    }
    if(input$val=="Rate"){
      plot <- plot + labs(y="Cases per 100,000 people")
    }
    if(input$x_axis=="Date_from_100"){
      plot <- plot + labs(x="Days from 100th case") 
    }
    plot
  })
  
  
  output$data_table <- renderDataTable({
    
    table <- data2() %>% 
      select(City, Date, Date_from_100,	Cumulative_Total,	Population, Rate) %>%
      rename(`Date from 100th case` = Date_from_100,
             `Running Total` = Cumulative_Total)
    
    datatable(table)
  })
}

shinyApp(ui, server)

