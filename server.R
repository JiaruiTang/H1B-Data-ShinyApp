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
library("ggmap")
library("ggrepel")
library(sp)
library(rgeos)

options(shiny.trace = TRUE)

## Read h1b2017
load("h1b2017.RData")

## Get industry table
load("industry.RData")

load("occupation.RData")

load("try.RData")

## Data tidying process
final = read.csv("final.csv")
colnames(final)[1]="NAME_1"
final2 = final
colnames(final2)[1]="name"
final1 = final
colnames(final1)[1] = "state"

shinyServer(function(input, output) {
  dns <- "USA_adm_shp" 
  shape <- readOGR(dns, "USA_adm1")
  shape2 <- merge(shape, final, by = "NAME_1")
  shape2@data = shape2@data[,c(-2:-12)]
  newdata = shape2@data
  subdata = gSimplify(shape2,tol = 0.5,topologyPreserve = T)
  rowname = as.integer(rownames(newdata))-1
  rownames(newdata)=rowname
  shape2 = SpatialPolygonsDataFrame(subdata,newdata)
  i_popup <- paste0("<strong>STATE: </strong>", shape2$NAME_1, "<br>","<strong>Number of applicants: </strong>", 
                    shape2$numbofLCA,"<br>", "<strong>Large Company Ratio: </strong>", shape2$Large_Company_Ratio,
                    "<br>" ,"<strong>Average salary: </strong>", shape2$Avesalary,"<br>","<strong>GDP: </strong>", shape2$GDP,"<br>",
                    "<strong>Population: </strong>", shape2$Population,"<br>","<strong>Education level: </strong>", shape2$education_level)
  pal <- colorQuantile("Greens", NULL, n =7)

  output$promap = renderLeaflet({leaflet(shape2) %>% addTiles() %>% setView(-85, 40, zoom = 3) %>% 
      addPolygons(fillColor = ~pal(shape2$numbofLCA), fillOpacity = 0.8, color = "#000000", weight = 1, 
                  popup = i_popup)})

  output$by.state = DT::renderDataTable({final1 %>% filter(is.null(input$states)|state %in% input$states)})

  output$industry.table = DT::renderDataTable({
    industry %>% filter(is.null(input$industries)|industry %in% input$industries)})
  
  output$histSalary = renderPlot({
    #if (length(input$state)==0)
    #  return(NULL)
    hist((h1b2017 %>% filter(h1b2017[,15] %in% input$state))[,10], breaks = input$bins, plot = T, 
         main = paste0("Histogram of Salary in ", input$state), col = sample(c(1:56),1), 
         xlab = "Wages per year",cex.axis = 0.8, cex.lab = 0.7, cex.main = 0.7)
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
    start_time <- Sys.time()
    par(mar=c(5,11,4,2)+0.1,mgp=c(11,1,0))
    barplot((rev(industry %>% filter(is.null(input$forindustries)|industry %in% input$forindustries))$`Average Salary`), 
            main = "Average Salary of Top25 Companies with Highest H1B Applicants", col = sample(25), border = NA,
            names.arg = rev((industry %>% filter(is.null(input$forindustries)|industry %in% input$forindustries))$`H1B Visa Sponsor`[1:nrow(industry %>% filter(is.null(input$forindustries)|industry %in% input$forindustries))]),
            cex.names = 0.85, las = 2, horiz = T)
    end_time <- Sys.time()
    print(paste0("histogram time: ", end_time-start_time))
  })
})
