## Developing data products - Final Assignment
## Author: Riccardo Roganti
## Date: 03/06/2017
## UI of the application

library(shiny)

shinyUI(fluidPage(
  
  titlePanel("Deformation of beams"),
  
  sidebarLayout(
          
    sidebarPanel(
            
            ## Setting panel
            
            selectInput("constraint", "Select the type of boundary condition", c("Fixed End", "Simple Supported")),
            numericInput("elasticity", "Set E, module of elasticity [MPa]:", 45000),
            numericInput("inertia", "Set I, moment of inertia [cm^4]:", 12000),
            numericInput("length", "Set l, length of the beam [m]:", 25),
            numericInput("load_value", "Set load value [N]:", 10000),
            sliderInput("load_position", "Set position of the load [%]:", min = 1, max = 99, value = 50),
            checkboxInput("force_dist_check", "Show internal forces"),
            conditionalPanel(
                    
                    condition = "input.force_dist_check == true",
                    selectInput("type_force", "Select the internal stress", c("Shear", "Moment"))
                    
            )

    ),
    
    mainPanel(
            
            ## Description
            h4("How to use it"),
            p("On the side bar panel it is asked to insert:"),
            p(" - Type of constraint: this indicate the type of constraint of both ends. The possible choices are fixed end or simple support."),
            p(" - Property of the material: elasticity (E), inertia of the section (I), length of the beam (l)"),
            p(" - Property of the load: value and position"),
            p("It is possible also the put a tick on the box to show a plot where internal forces are shown"),
            
            ## Output
            
            plotOutput("beamPlot"),
            
            textOutput("max_defl"),
            
            plotOutput("forcePlot"),
            
            conditionalPanel(
                    
                condition = "input.force_dist_check == true",    
                textOutput("max_internal")
                
            )
            
    )
    
  )
  
))