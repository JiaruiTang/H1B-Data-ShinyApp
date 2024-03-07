library(stringr)
library(rvest)
library(Matrix)
library(readr)
library(data.table)
library(magrittr)
library(dplyr)


url <- 'http://www.myvisajobs.com/Reports/2018-H1B-Visa-Category.aspx?T=WS'
webpage <- read_html(url)

state <- html_nodes(webpage,'.tbl a')
state=unlist(as.character(state))
state=state[-1]

statename=vector(mode = "character",length = 51)
for(i in 1:51){
  link=state[i]
  statename[i]=sub(pattern=".*href=\"/(.*?)-2018.*"   , replacement="\\1", x=link)
}
statename=gsub(pattern = "-", replacement = " ", x = statename)

number=html_nodes(webpage,'.tbl td:nth-child(3)')
number=unlist(as.character(number))
number=number[-1]
numberofLCA=vector(mode = "character",length = 51)
for(i in 1:51){
  link=number[i]
  numberofLCA[i]=sub(pattern=".*td>(.*?)<.*"   , replacement="\\1", x=link)
}
numbofLCA=gsub(pattern = ",", replacement = "", x = numberofLCA)
numbofLCA=as.numeric(numbofLCA)

salary=html_nodes(webpage,'.tbl td:nth-child(4)')
salary=unlist(as.character(salary))
salary=salary[-1]
avesalary=vector(mode = "character",length = 51)
for(i in 1:51){
  link=salary[i]
  avesalary[i]=sub(pattern=".*td>(.*?)<.*"   , replacement="\\1", x=link)
}

avesalary=gsub(pattern = "\\$", replacement = "", x = avesalary)
avesalary=gsub(pattern = ",", replacement = "", x = avesalary)
avesalary=as.numeric(avesalary)

salarybystate=data.frame(statename,avesalary)
colnames(salarybystate)=c("NAME_1","avesalary")

library(leaflet)
library(rgdal)

dns <- "/Users/zhujunxia/Downloads/USA_adm_shp" 
shape <- readOGR(dns, "USA_adm1")

shape <- merge(shape, salarybystate, by = "NAME_1") 
i_popup <- paste0("<strong>STATE: </strong>", shape$NAME_1, "<br>", "<strong>AverageSalary: </strong>", shape$avesalary) 
pal <- colorQuantile("YlOrRd", NULL, n =7) 
leaflet(shape) %>% addTiles() %>% setView(-100, 37.5, zoom = 3) %>% 
  addPolygons(fillColor = ~pal(shape$avesalary), fillOpacity = 0.8, color = "#000000", weight = 1, popup = i_popup)
