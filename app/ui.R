# Define UI for app

key <- "AIzaSyC2rGN5ZbV-21zklpgVGnsV-WfdQnNALjk" # Google API

ui <- navbarPage("NYC Citi Bikes", id="nav",
                 
                 tabPanel("Home",value ="a",

                    div(class="outer",

                        tags$head(
                          # Include our custom CSS
                          includeCSS("styles.css"),
                          includeScript("gomap.js")
                        ),

                        leafletOutput("map_home",width = "100%",height = "100%"),
                        tags$style("#selection {font-weight:bold;
                                 color:white;}"),
                        absolutePanel(id="selection", fixed = TRUE,
                                      top = 105, left = 18, right = "auto", bottom = "auto",
                                      width = 250, height = 370,style="opacity:0.8",
                                      br(),
                                      br(),
                                      h4("To start using this app, please tell us more about yourself",align="center"),
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
                                      top = 120, left = 'auto', right = 20, bottom ="auto",
                                      width = 300, height = "auto",

                                      h2("The hourly change of pick up location"),
                                       sliderInput("hours", "Hours of Day:",
                                                  min = 0, max = 23, value = 0, step = 1,
                                                  animate=animationOptions(interval = 500)),
                                      helpText("Please click the button to see the changes"),
                                      helpText("Data refer to 2018-08-01 from 00:00 to 23:59")


                        )


                    )

           ),
           tabPanel("Bike User", value = "b",
                    bootstrapPage(
                      # Fill the webpage with the map
                      div(class="outer",
                      # Print base map
                      leafletOutput("map", width="100%", height="100%"),

                      # Panel for presenting the last update time
                      absolutePanel(bottom=20,right=10,width="auto",
                                    tags$h6("Last Update Time:"),
                                    textOutput("update_time_Box")),

                      # Panel for presenting the weather
                      absolutePanel(id = "Weather", class = "panel panel-default", fixed = TRUE,
                                     bottom=10,left=18,width=260,
                                    height = "auto", style="opacity: 0.7",
                                    tags$h5("Weather"),
                                    textOutput("temperature"),
                                    textOutput("weather_condition")),
                      #Font of temperature and weather condition
                      tags$style("#temperature {
                                 font-weight:normal;}"),
                      tags$style("#weather_condition {
                                 font-weight:normal};"),
                      
                      #Color of distance and time
                      tags$style("#times {font-size:15px;
                                 font-weight:bold;}"),
                      tags$style("#distances {font-size:15px;
                                 font-weight:bold};"),

                      includeScript("message_handler.js"), # This java script file controls message
                      #includeCSS("styles.css"), # This css file contains fade out efect for following panel
                      # Panel for entering start point and end point and possibily users' Email-addresses
                      absolutePanel(id = "controls", class = "panel panel-default", fixed = TRUE,
                                    draggable = TRUE, top = 120, left = 18, right = "auto", bottom = "auto",
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

                    ))
           ),

           navbarMenu("Business Purpose",
                      #  tags$a(href='https://www.citibikenyc.com/',   tags$img(src='citibike.jpg', align = "left", width = 150)),
                      # br(),
                      # bootstrapPage(
                      
                      tabPanel('Station Popularity Plot', 
                               #  h3("You may think of making advertisement at popular stations or invest in establishing a new station. This map would help you to figure out station popularity in each census tract."),
                               div(class="outer",
                                   
                                   tags$head(
                                     # Include our custom CSS
                                     includeCSS("styles.css"),
                                     includeScript("gomap.js")
                                   ),
                                   leafletOutput("popstation", height = 800),
                                   absolutePanel(bottom=10,right=10,width="25%",
                                                 textOutput("text2")),
                                   tags$style("#text2 {font-size: 15px; font-style: italic
                                              ;font-weight: bold;}")
                                   )),
                      tabPanel('Nearly Empty Station Plot', 
                               #h3("This map would help you to figure out station that is running out of bikes."),
                               div(class="outer",
                                   
                                   tags$head(
                                     # Include our custom CSS
                                     includeCSS("styles.css"),
                                     includeScript("gomap.js")
                                   ),
                                   leafletOutput("emptymap", height = 800),
                                   absolutePanel(bottom=10,right=10,width="25%",
                                                 textOutput("text1")),
                                   tags$style("#text1 {font-size: 15px; font-style: italic
                                              ;font-weight: bold;}")
                                   )),
                      
                      tabPanel('Station Popularity List', h3("A list of station usage by tract"),
                               fluidRow(
                                 column(4,
                                        selectInput("state",
                                                    "State:",
                                                    c("All",
                                                      unique(list$state)))
                                 ),
                                 column(4,
                                        selectInput("county",
                                                    "County:",
                                                    c("All",
                                                      unique(as.character(list$county))))
                                 ),
                                 column(4,
                                        selectInput("num_station",
                                                    "No. of Station:",
                                                    c("All",
                                                      unique(as.character(sort(list$num_station)))))
                                 )
                               ),
                               DT::dataTableOutput("poplist")),
                      tabPanel('Nearly Empty Station List', h3("A list of real-time nearly empty station"),
                               DT::dataTableOutput("emptylist"))
                      
                               ),
           tabPanel("About",value="d",
                    fluidPage(
                      tags$a(href='https://www.citibikenyc.com/',   tags$img(src='citibike.jpg', align = "left", width = 50)),
                      br(),
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



