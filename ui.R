library(stringr)
library(rvest)
library(Matrix)
library(readr)
library(data.table)
library(magrittr)
library(dplyr)
library(XML)
library(RCurl)
library(rgdal)
library(leaflet)
library(maps)

start_time <- Sys.time()
load("try.RData")

load("occupation.RData")
end_time <- Sys.time()
print(paste0("loading of ui: ", end_time-start_time))

## Page
shinyUI(navbarPage("Map",
                 tabPanel("Interactive Map",
                          div(class="outer",
                              tags$style(type = "text/css", ".outer {position: fixed; top: 41px; left: 0; right: 0; bottom: 0; overflow: hidden; padding: 0}"),
                              leafletOutput("promap", height = "100%")),
                          absolutePanel(
                            bottom = -70, right = 10, width = 320,
                            draggable = TRUE,
                            wellPanel(
                              selectInput("state", "State", statename, selected = statename[1]),
                              selectInput("occupation", "Occupation", occupationname),
                              sliderInput("bins", "Number of bins:", min =15, max = 65, value = 40),
                              plotOutput("histSalary", height = 180),
                              plotOutput("histOccup", height = 180)
                            ),
                            style = "opacity:0.85"
                          )),
                 tabPanel("H1B Info by State",
                          fluidRow(
                            column(3,
                                   selectInput("states", "States", statename, multiple=TRUE)
                            )
                            
                          ),
                          hr(),
                          DT::dataTableOutput("by.state")),
                 tabPanel("H1B Info by Industry",
                          fluidRow(
                            column(3,
                                   selectInput("industries", "Industries", industryname, multiple=TRUE)
                            )
                            
                          ),
                          hr(),
                          DT::dataTableOutput("industry.table")
                 ),
                 tabPanel("H1B Graph by Industry",
                          fluidPage(
                            fluidRow(
                              column(8, 
                                     selectInput("forindustries", "Industries", industryname, multiple=F, selected = industryname[1]),
                                     "Choose the industry you want to learn more. The companies are sorted by their number of applications for H1B."
                              )
                            ),
                            plotOutput("barIndustry")
                            # sidebarLayout(sidebarPanel(selectInput("forindustries", "Industries", industryname, multiple=F, selected = industryname[1]),
                            #                                    hr(),
                            #                                    helpText("Choose the industry you want to learn more")), 
                            #                       mainPanel(plotOutput("barIndustry")))
                            # 
                            
                          )
                 )
                 
))