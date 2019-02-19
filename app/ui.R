# Define UI for app

key <- "AIzaSyC2rGN5ZbV-21zklpgVGnsV-WfdQnNALjk" # Google API

ui <- bootstrapPage(
  # Fill the webpage with the map
  tags$style(type="text/css","html,body{width:100%;height:100%}"),
  
  # Print base map
  leafletOutput("map", width="100%", height="100%"),
  
  # Panel for presenting the last update time
  absolutePanel(bottom=10,left=10,width="25%",
                tags$h6("Last Update Time:"),             
                textOutput("update_time_Box")),
  
  includeCSS("styles.css"), # This css file contains fade out efect for following panel
  # Panel for entering start point and end point
  absolutePanel(id = "controls", class = "panel panel-default", fixed = TRUE,
                draggable = TRUE, top = 85, left = 18, right = "auto", bottom = "auto",
                width = 300, height = 300, 
                h4("Citi Bike Route",align = "center"),
                
                fluidRow(
                  column(10, offset = 1,
                         textInput(inputId = "input_start_point", label = "From"),
                         textInput(inputId = "input_end_point", label = "To"),
                         checkboxInput(inputId="input_checkbox",label = "Could you please do us a favor?", value = FALSE),

                         actionButton(inputId = "input_go", label = "Let's Go!"),
                         
                         ## The following is the autocomplete feature
                         HTML(paste0("
            <script>
            function initAutocomplete() {
            new google.maps.places.Autocomplete(
            (document.getElementById('input_start_point')),{types: ['geocode']}
            );
             new google.maps.places.Autocomplete(
            (document.getElementById('input_end_point')),{types: ['geocode']}
            );
            }
            </script>
            <script src='https://maps.googleapis.com/maps/api/js?key=", key,"&libraries=places&callback=initAutocomplete'
            async defer></script>
    ")),
                         
  # This java script file controls message
  includeScript("message_handler.js")
                         
                        
))))




