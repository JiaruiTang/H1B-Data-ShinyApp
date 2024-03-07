rm(list = ls())
library(stringr)
library(rvest)
library(Matrix)
library(readr)
library(data.table)
library(magrittr)
library(dplyr)
library(XML)
library(RCurl)
library(leaflet)
library(rgdal)
library(shiny)
library(maps)
library("readxl")
library("hashmap")
library("ggplot2")
library("ggmap")
library("ggrepel")
library(XML)
library(RCurl)

load("h1b2017.RData")
##View(h1b2017)

#h1b2017 = h1b2017 %>% left_join(states.name, by = "abbr")


## State Name-statename
load("try.RData")

## Industry
load("industry.RData")
load("occupation.RData")
## Read Data for companies in each state
# state.table = readHTMLTable(getURL("http://www.myvisajobs.com/Reports/2017-H1B-Visa-Category.aspx?T=WS"), skip.rows = 1)[[3]]
# 
# 
# ## Clean data
# state.table$`Average Salary` = as.character(state.table$`Average Salary`)
# state.table$`Average Salary` = gsub(",", "", state.table$`Average Salary`)
# state.table$`Average Salary` = gsub("\\$", "", state.table$`Average Salary`)
# state.table$`Average Salary` = as.numeric(state.table$`Average Salary`)
# state.table$`Number of LCA  *` = gsub(",", "", state.table$`Number of LCA  *`)
# for (i in 1:nrow(state.table)) {
#   if (is.na(state.table[i,3]) & is.na(state.table[i,4])) {
#     state.table = state.table[-i,]
#   }
# }

## Generalized code
# state = state.table$`Work State`
# all.state = list()
# URL.state = matrix(nrow = length(state), ncol = 4)
# state = gsub(" ","-", state)
# length = matrix(nrow = length(state), ncol = 4)

## Get the URL we will read
# for (i in 1:length(state)) {
#   table.temp = list()
#   for (j in 1:4) {
#     URL.state[i,j] = paste0("http://www.myvisajobs.com/", state[i], "_", j,"-2017WS.htm")
#     length[i,j]=length(readHTMLTable(getURL(URL.state[i,j])))
#     ## for general tables
#     if (length[i,j]==6) {
#       table.temp[[j]] = readHTMLTable(getURL(URL.state[i,j]))[[5]]
#       table.temp[[j]]$`Average Salary` = as.character(table.temp[[j]]$`Average Salary`)
#       table.temp[[j]]$`Average Salary` = gsub(",", "", table.temp[[j]]$`Average Salary`)
#       table.temp[[j]]$`Average Salary` = gsub("\\$", "", table.temp[[j]]$`Average Salary`)
#       table.temp[[j]]$`Average Salary` = as.numeric(table.temp[[j]]$`Average Salary`)
#       table.temp[[j]]$`Number of LCA  *` = gsub(",", "", table.temp[[j]]$`Number of LCA  *`)
#       table.temp[[j]]$`Number of LCA  *` = as.numeric(table.temp[[j]]$`Number of LCA  *`)
#       # Clean DATA
#       for (k in 1:nrow(table.temp[[j]])) {
#         if (is.na(table.temp[[j]][k,3]) & is.na(table.temp[[j]][k,4])) {
#           table.temp[[j]] = table.temp[[j]][-k,]
#         }
#       }
#     }
#     ## for last two states who do not have enough companies (100)
#     else {
#       table.temp[[j]] = readHTMLTable(getURL(URL.state[i,j]), skip.rows = 1)[[3]]
#       table.temp[[j]]$`Average Salary` = as.character(table.temp[[j]]$`Average Salary`)
#       table.temp[[j]]$`Average Salary` = gsub(",", "", table.temp[[j]]$`Average Salary`)
#       table.temp[[j]]$`Average Salary` = gsub("\\$", "", table.temp[[j]]$`Average Salary`)
#       table.temp[[j]]$`Average Salary` = as.numeric(table.temp[[j]]$`Average Salary`)
#       table.temp[[j]]$`Number of LCA  *` = gsub(",", "", table.temp[[j]]$`Number of LCA  *`)
#       table.temp[[j]]$`Number of LCA  *` = as.numeric(table.temp[[j]]$`Number of LCA  *`)
#       # Clean DATA
#       for (k in 1:nrow(table.temp[[j]])) {
#         if (is.na(table.temp[[j]][k,3]) & is.na(table.temp[[j]][k,4])) {
#           table.temp[[j]] = table.temp[[j]][-k,]
#         }
#       }
#       break;
#     }
#     
#     
#   }
#   all.state[[i]] = bind_rows(table.temp)
# }

## Interface
ui <- navbarPage("Map",
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
                            
                            #sidebarLayout(sidebarPanel(selectInput("forindustries", "Industries", industryname, multiple=F, selected = industryname[1]),
                            #                                   hr(),
                            #                                   helpText("Choose the industry you want to learn more")), 
                            #                      mainPanel(plotOutput("barIndustry")))
                                                  
                                    
                          )
                          )
                          
                 )


## Code
server<- function(input,output) {
  ## Data tidying process
  # dat8=read.csv("dat8.csv",header = T)
  # dat8$basetaxes[35]=5
  # dat8$basetaxes[36]=5.5
  # dat8$basetaxes[16]=6
  # population=read.csv("population.csv",header = T)
  # dat9=merge(dat8,population,by.x="State",all.x=T)
  # dat9$Population[9]=681000
  # dat9$Population[37]=3570000
  # dat9$Population[39]=12802503
  # 
  # fulldata=dat9[,c(2,3,5:14)]
  # colnames(fulldata)[5]="int_students"
  # colnames(fulldata)[7]="education_level"
  # colnames(fulldata)[8]="Avg_Listing_Price"
  # colnames(fulldata)[9]="Large_Company_Ratio"
  # colnames(fulldata)[10]="Num_of_Large_Company"
  # fulldata$Avg_Listing_Price=as.numeric(fulldata$Avg_Listing_Price)
  # str(fulldata)
  # 
  # ##Get final data table
  # final=fulldata[,c("numbofLCA","GDP","Avesalary","education_level","Large_Company_Ratio","Population")]
  # final$State=dat8$State
  # final=final[,c(7,1:6)]
  # write.csv(final,file="final.csv",row.names = F)
  final = read.csv("final.csv")
  colnames(final)[1]="NAME_1"
  final1 = final
  colnames(final1)[1] = "state"
  
  ##Plot graph
  dns <- "USA_adm_shp" 
  shape <- readOGR(dns, "USA_adm1")
  shape2 <- merge(shape, final, by = "NAME_1") 
  i_popup <- paste0("<strong>STATE: </strong>", shape2$NAME_1, "<br>","<strong>Number of applicants: </strong>", shape2$numbofLCA,"<br>", "<strong>Large Company Ratio: </strong>", shape2$Large_Company_Ratio,
                    "<br>" ,"<strong>Average salary: </strong>", shape2$Avesalary,"<br>","<strong>GDP: </strong>", shape2$GDP,"<br>",
                    "<strong>Population: </strong>", shape2$Population,"<br>","<strong>Education level: </strong>", shape2$education_level) 
  pal <- colorQuantile("Greens", NULL, n =7) 
  
  output$promap = renderLeaflet(leaflet(shape2) %>% addTiles() %>% setView(-85, 40, zoom = 3.8) %>% 
                               addPolygons(fillColor = ~pal(shape2$numbofLCA), fillOpacity = 0.8, color = "#000000", weight = 1, popup = i_popup))
  
  output$by.state = DT::renderDataTable({final1 %>% filter(is.null(input$states)|state %in% input$states)})
  
  output$industry.table = DT::renderDataTable({
    industry %>% filter(is.null(input$industries)|industry %in% input$industries)})
  
  output$histSalary = renderPlot({
    if (length(input$state)==0)
      return(NULL)
    hist((h1b2017 %>% filter(is.null(input$state)|h1b2017[,15] %in% input$state))[,10], breaks = input$bins, plot = T, 
         main = paste0("Histogram of Salary in ", input$state), col = which(statename==input$state), xlab = "Wages per year",cex.axis = 0.8, cex.lab = 0.7, cex.main = 0.7)
  }
    )
  
  output$histOccup = renderPlot({
    if (length(input$occupation)==0|length(input$state)==0)
      return(NULL)
    hist((h1b2017 %>% filter((h1b2017[,15] %in% input$state) & (h1b2017[,8] %in% input$occupation)))[,10], breaks = input$bins, plot = T, 
         xlab = "Wage per year dollars", main = "Distribution of Salary of Chosen Occupation in Chosen State",
         col = which(occupationname==input$occupation), cex.axis = 0.8, cex.lab = 0.7, cex.main = 0.7)
  })
  
  ## Output histIndustry
  output$barIndustry = renderPlot({
    par(mar=c(5,11,4,2)+0.1,mgp=c(11,1,0))
    barplot((rev(industry %>% filter(is.null(input$forindustries)|industry %in% input$forindustries))$`Average Salary`), 
            main = "Average Salary of Top25 Companies with Highest H1B Applicants", col = sample(25), border = NA,
            names.arg = rev((industry %>% filter(is.null(input$forindustries)|industry %in% input$forindustries))$`H1B Visa Sponsor`[1:nrow(industry %>% filter(is.null(input$forindustries)|industry %in% input$forindustries))]),
            cex.names = 0.85, las = 2, horiz = T)
  })
}  


shinyApp(ui = ui, server = server)

