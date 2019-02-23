# Define UI for app

key <- "AIzaSyC2rGN5ZbV-21zklpgVGnsV-WfdQnNALjk" # Google API

ui <- navbarPage("NYC Citi Bikes", id="nav",
                 
                 tabPanel("Home",value ="a",
                    
                    div(class="outer",
                        
                        tags$head(
                          # Include our custom CSS
                          includeCSS("styles.css")
                          # ,
                          # includeScript("gomap.js")
                        ),
                        
                        leafletOutput("map_home",width = "100%",height = "100%"),
                        absolutePanel(id="selection", class = "panel panel-default", fixed = TRUE,
                                      draggable = TRUE, top = 180, left = 40, right = "auto", bottom = "auto",
                                      width = 330, height = "auto",
                                      tags$a(href='https://www.citibikenyc.com/',   tags$img(src='logo.jpg', align = "left", width = 150)),
                                      br(),
                                      br(),
                                      h3("To start using this app, please tell us more about yourself"),
                                      br(),
                                      div(style = "text-align:center",
                                          h2("Who you are?")),
                                      div(style = "text-align:center",
                                          bsButton("bu", "Bike User", icon("bicycle"),size = "large",style = "warning")),
                                      br(),
                                      br(),
                                      div(style = "text-align:center",
                                          bsButton("invest", "Investor", icon("user-tie"),size = "large",style = "warning"))
                                      
                        ),
                        
                        absolutePanel(id = "controls", class = "panel panel-default", fixed = TRUE,
                                      draggable = TRUE, top = "60", left = "auto", right = 20, bottom ="auto",
                                      width = "auto", height = "auto",
                                      
                                      h2("The hourly change of pick up location"),
                                      
                                      
                                      selectInput("pd", "pick up or drop off", c("Pick up", "Drop off", "All"), selected = "Pick up"),
                                      
                                      
                                      sliderInput("hours", "Hours of Day:", 
                                                  min = 0, max = 23, value = 0, step = 1,
                                                  animate=animationOptions(interval = 500)),
                                      helpText("Please click the button to see the changes"),
                                      helpText("Data refer to 2018-08-01 from 00:00 to 23:59")
                                      
                                      
                        )
                        
                        
                    )
                    
           ),
           tabPanel("Bike User", value = "b",
                    fluidPage(
                      # tags$a(href='https://www.citibikenyc.com/',   tags$img(src='citibike.jpg', align = "left", width = 150)),
                      
                      # Fill the webpage with the map
                      #tags$style(type="text/css","html,body{width:100%;height:100%}"),
                      
                      # Print base map
                      leafletOutput("map", width="100%", height="100%"),
                      
                      # Panel for presenting the last update time
                      absolutePanel(bottom=10,left=10,width="25%",
                                    tags$h6("Last Update Time:"),
                                    textOutput("update_time_Box")),
                      
                      # Panel for presenting the weather
                      absolutePanel(top=15,right=5,
                                    tags$h6("Weather"), 
                                    textOutput("temperature"),
                                    textOutput("weather_condition")),
                      #Color of distance and time
                      tags$style("#times {font-size:15px;
                                 font-weight:bold;}"),
                      tags$style("#distances {font-size:15px;
                                 font-weight:bold};"),
                      
                      includeScript("message_handler.js"), # This java script file controls message
                      includeCSS("styles.css"), # This css file contains fade out efect for following panel
                      # Panel for entering start point and end point and possibily users' Email-addresses
                      absolutePanel(id = "controls", class = "panel panel-default", fixed = TRUE,
                                    draggable = TRUE, top = 100, left = 18, right = "auto", bottom = "auto",
                                    width = 300, height = "auto", 
                                    h4("Citi Bike Route",align = "center"),
                                    
                                    fluidRow(
                                      column(10, offset = 1,
                                             textInput(inputId = "input_start_point", label = "From"),
                                             textInput(inputId = "input_end_point", label = "To"),
                                             h5("Don't forget to hit return when you finish entering",align = "center"),
                                             checkboxInput(inputId="input_checkbox",label = "Could you please do us a favor?", value = FALSE),
                                             conditionalPanel(condition="input.input_checkbox==true",
                                                              textInput(inputId = "enter_email", label = "Please enter your E-mail address")),
                                             actionButton(inputId = "input_go", label = "Let's Go!"),
                                             conditionalPanel(condition="output.nrows==1",
                                                              textOutput("distances"),
                                                              textOutput("times")),
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
                                                         "))
                                             )
                                             )
                                             )

                    )
           ),
           tabPanel("Business Purpose", value="c",
                    tags$a(href='https://www.citibikenyc.com/',   tags$img(src='citibike.jpg', align = "left", width = 150)),
                    br(),
                    fluidPage(
                      h2("This map would help you to figuer out the popular routes to make your advertisements more popular.")
                    )),
           tabPanel("About",value="d",
                    fluidPage(
                      tags$a(href='https://www.citibikenyc.com/',   tags$img(src='citibike.jpg', align = "left", width = 150)),
                      br(),
                      h2("Introduction:"),
                      h3("This application is mainly focusing on bringing convinence to bike users, and helping business operations"),
                      h3("Features:"),
                      h4("1. Real-Time Bike Station Information helps bike users to figuer out the number of bikes in the station."),
                      h4("2. Closest Bike Stations offer bike users the best bike stations."),
                      h4("3. Offer a Favor gives bike users bonus for delivering bikes to the station with less bikes."),
                      h4("4. Offer a Favor helps NYC Citi Bikes with delivering bikes."),
                      h4("5. Popular bike stations helps business with advertising"),
                      br(),
                      
                      h3("Team Members:"),
                      h4("This Project is developed by:"),
                      h4(" Huang, Shengwei:  sh3825@columbia.edu"),
                      h4(" Liu, Sitong:  sl4460@columbia.edu"),
                      h4(" Wang, Yujie:  yw3285@columbia.edu"),
                      h4(" Yang, Zeyu: zy2327@columbia.edu"),
                      h4(" Zhang, Zhicheng: zz2555@columbia.edu"),
                      br(),
                      h4("If you have any idea or questions of this application, please feel free to contact us."),
                      br(),
                      
                      h3("Reference:"),
                      h4("Data:https://data.cityofnewyork.us/NYC-BigApps/Citi-Bike-System-Data/vsnr-94wk"),
                      h4("Tool: R-studio"),
                      img(src='aboutuse.jpg', align = "left", width = 300)
                      
                      
                      
                      
                    )
                    
           )
)



