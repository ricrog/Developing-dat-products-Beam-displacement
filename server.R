## Developing data products - Final Assignment
## Author: Riccardo Roganti
## Date: 03/06/2017
## Server of the application

library(shiny)

shinyServer(function(input, output) {

        ## Reaction function for the input
        
        l <- reactive ({input$length}) 
        part_x <- reactive({seq(0, l(), length.out = 1000)}) # Partition of beam length
        x_load <- reactive ({input$load_position})
        F_load <- reactive ({input$load_value})
        E <- reactive({input$elasticity})
        I <- reactive({input$inertia})
        dist_check <- reactive({input$distributed})
        boundary <- reactive({input$constraint})
        force_show_check <- reactive({input$force_dist_check})
        type_show <- reactive({input$type_force})
        
        ## Computation of displacement
        
        displacement <- reactive({
                
                x <- part_x()
                
                if (boundary() == "Fixed End"){

                        disp_calc(F_load(), E(), I(), l(), x_load(), x, "fixed")
                
                } else if (boundary() == "Simple Supported") {
                        
                        disp_calc(F_load(), E(), I(), l(), x_load(), x, "simple")        
                        
                }

        })

        ## Plot of the displacement
        
        output$beamPlot <- renderPlot({
                
                x <- part_x()
                beam <- rep(0, 1000)
                disp <- displacement()
                
                plot(x,disp, ylim = c(max(disp,-disp/2),min(disp,-disp/2)),
                     xlab = "Beam position [m]",
                     ylab = "Displacement [m]",
                     main = "Displacement of the beam",
                     col = "red" )
                points(x, beam, col = "blue", pch = 0)
                arrows(x_load()*l()/100,-max(abs(disp))/2*disp[500]/abs(disp[500]), x_load()*l()/100, 0)
                legend("topleft", inset=.01, legend=c("Beam", "Deformed Beam"),
                       col=c("blue", "red"), lty=1:2, cex=0.8,
                       box.lty=0)

        })
        
        ## Plot of the internal forces
        
        output$forcePlot <- renderPlot({
                
                if (force_show_check()) {
                        
                        beam <- rep(0, 1000)
                        x <- part_x()
                        
                        if (type_show() == "Moment") {
                 
                                to_plot <- moment_calc(F_load(), l(), x_load(), x, boundary())
                                plot(x,to_plot,
                                     xlab = "Beam position [m]",
                                     ylab = "Moment [N*m]",
                                     main = "Moment in the beam", pch=16, type="h", col = "orange")

                                
                        } else if (type_show() == "Shear"){
                                
                                to_plot <- shear_calc(F_load(), l(), x_load(), x, boundary())
                                plot(x,to_plot,
                                     xlab = "Beam position [m]",
                                     ylab = "Shear [N]",
                                     main = "Shear in the beam", pch=16, type="h", col = "orange")

                        }
                        
                        points(x, beam, col = "blue", pch = 0)
                
                }
                
        })   
        
        ## Textual output to show maximum
        
        output$max_defl <- renderText({ 
                maxdef <- max(abs(displacement()))
                paste("The maximum deflection is: ", toString(maxdef), " m")
        })
        
        output$max_internal <- renderText({ 
                
                x <- part_x()
                
                if (type_show() == "Moment") {
                        
                        maxmom <- max(abs(moment_calc(F_load(), l(), x_load(), x, boundary())))
                        paste("The maximum Moment is: ", toString(maxmom), " N*m")
                        
                } else if (type_show() == "Shear"){
                        
                        maxshear <- max(abs(shear_calc(F_load(), l(), x_load(), x, boundary())))
                        paste("The maximum Shear is: ", toString(maxshear), " N")
                        
                }
                
        })

})


## Definition of function to compute shear, moment and displacement for two types of beam

disp_calc <- function(P, E, I, l, x_load, partition, const_type){
        
        a <- x_load*l/100
        b <- l - a
        x <- partition
        disp <- rep(0,length(partition))
        pos <- x < a
        
        if(const_type == "fixed") {
                
                disp1 <- P*b*b*x*x*(3*a*l-3*a*x-b*x)/(6*E*I*l*l*l)
                disp2 <- P*a*a*x*x*(3*b*l-3*b*x-a*x)/(6*E*I*l*l*l)
                
        } else if(const_type == "simple") {
                
                disp1 <- P*b*x*(l*l-b*b-x*x)/(6*E*I*l)
                disp2 <- P*a*x*(l*l-a*a-x*x)/(6*E*I*l)
                
        }
        
        disp[pos] <- disp1[1:length(disp[pos])]
        disp[!pos] <- rev(disp2[1:length(disp[!pos])]) 
        
        disp <- disp * 100
        
        return(disp)
        
}

shear_calc <- function(P, l, x_load, partition, const_type){
        
        a <- x_load*l/100
        b <- l - a
        shear <- rep(0,length(partition))
        x <- partition
        pos <- x < a
        
        if(const_type == "Fixed End") {
                
                shear[pos] <- P*b*b*(3*a+b)/(l*l*l)
                shear[!pos] <- -P*a*a*(3*b+a)/(l*l*l)
                
        } else if(const_type == "Simple Supported") {
                
                shear[pos] <- P*b/l
                shear[!pos] <- -P*a/l
                
        }
        
        return(shear)
        
}

moment_calc <- function(P, l, x_load, partition, const_type){
        
        a <- x_load*l/100
        b <- l - a
        x <- partition
        moment <- rep(0,length(partition))
        pos <- x < a

        if(const_type == "Fixed End") {
                
                R1 <- P*b*b*(3*a+b)/(l*l*l)
                R2 <- P*a*a*(3*b+a)/(l*l*l)
                
                moment1 <- R1*x - P*a*b*b/(l*l)
                moment2 <- R2*x - P*b*a*a/(l*l)

        } else if(const_type == "Simple Supported") {
                
                moment1 <- P*b*x/l
                moment2 <- P*a*x/l
                
        }
        
        moment[pos] <- moment1[1:length(moment[pos])]
        moment[!pos] <- rev(moment2[1:length(moment[!pos])])
        
        return(moment)
        
}