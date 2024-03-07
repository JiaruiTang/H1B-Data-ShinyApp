# Analysis and Visualization of H1B Visa Data in the US

This project offers an analysis and interactive visualization of H1B visa data in the United States. Utilizing data extracted from Wikipedia, the Bureau of Labor Statistics, and Trulia, the application explores factors affecting the number of H1B visa applicants and the job market for international employees. The project used Python and R for data extraction and analysis, with the final visualization presented through an R ShinyApp.

<img src="https://github.com/JiaruiTang/H1B-Data-ShinyApp/blob/eacb54979cebd53ff038443dbf2d2d2dcb193757/H1b%20Visa%20Visualization.png" alt="H1B Data ShinyApp Visualization" width="60%">

## Contents

- **Data Extraction Scripts:** R scripts used to scrape and preprocess data from the specified sources.
- **Data Visualization Code:** R scripts that visualize the H1B visa data, focusing on applicant information and employment statistics.
- **ShinyApp Code:** The R ShinyApp code that powers the interactive H1B map online.

## Accessing the Visualization

The interactive H1B visa data visualization is available online. You can explore the application through the following link: [Live ShinyApp URL](https://jiaruitang.shinyapps.io/myapp-1/)

## Project Structure

- `*.RData` & `*.csv`: Extracted and processed datasets.
- `myshinyapp.R`: Scripts for data extraction, preprocessing and local visualization.
- `server.R`, `ui.R` & `run.R`: R code for the interactive ShinyApp.

## Usage

This repository is intended for developers interested in the backend workings of the H1B visa data analysis and visualization project. You can explore the data, scripts, and app code to understand the project's inner workings, replicate the analysis, or extend the project.
