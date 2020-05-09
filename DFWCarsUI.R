library(shiny, warn.conflicts = FALSE)
library(shinydashboard, warn.conflicts = FALSE)
library(DT, warn.conflicts = FALSE)
library(shinyjs, warn.conflicts = FALSE)
library(sodium)
library(DBI)
library(odbc)
library(shinythemes)
library(leaflet)
library(wordcloud)
library(ggplot2)
library(RColorBrewer)
source("./credentials_v3.R")
ui <- dashboardPage(
  dashboardHeader(title = "Cars.com",uiOutput("logoutbtn")),
  dashboardSidebar(
    #Custom CSS to hide the default logout panel
    tags$head(tags$style(HTML('.logo {
                              background-color: #010203 !important;
                              }
                              .navbar {
                              background-color: #010203 !important;
                              }
                              .sidebar {
                              background-color: #010203 !important;
                              }'))),
    uiOutput("sidebarpanel")
  ),
  
  #'http://dqzrr9k4bjpzk.cloudfront.net/startersite/images/10452147/1516659271989.jpg'
  dashboardBody(img(
    src='http://dqzrr9k4bjpzk.cloudfront.net/startersite/images/10452147/1516659271989.jpg',
    #style='width: 85%; position:absolute; height:92%'
    style = "width: 86%; position:absolute; height:92%; text-align: center;"
  ),
  
  shinyjs::useShinyjs(), uiOutput("body"),
  tags$head(tags$style(HTML('
                                /* body */
                                .content-wrapper, .right-side {
                                background-color: #010203;
                                }

                                '))),
  tags$head(tags$style(HTML('
      .main-header .logo {
        font-family: "Algerian", Times, "candara", serif;
        font-weight: bold;
        font-size: 20px;
      }
    '))))
)

db_temp <- dbConnector(
  server   = getOption("database_server"),
  database = getOption("database_name"),
  uid      = getOption("database_userid"),
  pwd      = getOption("database_password"),
  port     = getOption("database_port")
)
on.exit(dbDisconnect(db_temp), add = TRUE)

query_temp <- paste("select manufacturer, paint_color from VehicleInfo;")
carResult_temp <- dbSendQuery(db_temp, query_temp)
cardata_temp <- dbFetch(carResult_temp)

query_inventory <- paste("select manufacturer from VehicleInfo;")
inventorydata <- dbGetQuery(db_temp, query_inventory)
w = table(as.factor(inventorydata$manufacturer))
t=as.data.frame(w)



query_student <- paste("select * from student;")
studentResult <- dbSendQuery(db_temp, query_student)
studentdata <- dbFetch(studentResult)
#View(studentdata)
#print(studentdata$Student_ID)
#print(studentdata$Student_PW)


# Main login screen
loginpage <- fluidPage(#tags$style(make_css(list('.box', c('font-size', 'font-family', 'color'), c('40px', 'Agency FB', 'white')))),
  fluidRow(column(width = 12,img(''),
                  tags$b("Cars.com",style = "font-family: 'Algerian'; font-size: 800%;color: #ffffff;"),
                  tags$p(em("Let's find your dream car here!",style = "font-family: 'candara'; font-size: 200%;color: #ffffff;")),
                  hr(),
                  br(),
                  br(),
                  br()
  )
  ),
  fluidRow(
    column(3,
           tabsetPanel(
             id = "loginpage", 
             #style = "width: 500px; max-width: 100%; margin: 0 auto; padding: 20px;",
             tabPanel(
               title = "Log in",
               #tags$h2("LOG IN", style = "padding-top: 0;color:#333; font-weight:600;"),
               div(id='my_textinput' ,
                   textInput("userName", placeholder="Username", label = tagList(icon("user"), "Username")),
                   passwordInput("passwd", placeholder="Password", label = tagList(icon("unlock-alt"), "Password")),
                   tags$style(type="text/css", "#my_textinput {color: white}")
               ),
               
               br(),
               div(
                 style = "text-align: center;",
                 actionButton("login", "SIGN IN", style = "color: white; background-color:#3c8dbc;
                                 padding: 10px 15px; width: 150px; cursor: pointer;
                                 font-size: 18px; font-weight: 600;"),
                 shinyjs::hidden(
                   div(id = "nomatch",
                       tags$p("OH SHIT!! TRY AGAIN!!!",
                              style = "color: red; font-weight: 600; 
                                            padding-top: 5px;font-size:16px;", 
                              class = "text-center")))
               )),
             tabPanel(
               title = "Register",
               div(id='my_textinput' ,
                   textInput("RuserName", placeholder="Username", label = tagList(icon("user"), "Username")),
                   passwordInput("Rpasswd", placeholder="Password", label = tagList(icon("unlock-alt"), "Password")),
                   # passwordInput("comfirmPW", placeholder="Password", label = tagList(icon("unlock-alt"), "Password")),
                   tags$style(type="text/css", "#my_textinput {color: white}")
               ),
               
               br(),
               actionButton("register", "REGISTER", style = "color: white; background-color:#3c8dbc;
                                 padding: 10px 15px; width: 150px; cursor: pointer;
                                 font-size: 18px; font-weight: 600;")
             )
           )
    ))
)

adminpage <- fluidPage(#tags$style(make_css(list('.box', c('font-size', 'font-family', 'color'), c('40px', 'Agency FB', 'white')))),
  img(
    src='http://dqzrr9k4bjpzk.cloudfront.net/startersite/images/10452147/1516659271989.jpg',
    #style='width: 85%; position:absolute; height:92%'
    style = "width: 90%; position:absolute; height:92%; text-align: center;"
  ),
  fluidRow(column(width = 12, 
                  #tags$b( "Cars.com",style = "font-family: 'Algerian'; font-size: 800%;color: #ffffff;"),
                  #tags$p(em("Let's find your dream car here!",style = "font-family: 'candara'; font-size: 200%;color: #ffffff;")),
                  tags$p(),
                  tags$p())),
  fluidRow(
    column(12,
           tabsetPanel(
             id = "adminpage",
             tabPanel(
               title = "Manage Inventory",
               column(4,
                      selectInput("adminbrand", "Brand:",
                                  choices = c("",unique(cardata_temp$manufacturer)))),
               column(4,
                      textInput("adminmodel", "Model:")),
               column(4,
                      textInput("adminVIN", "VIN:")
               ),
               
               column(12,actionButton("admingo", "Get results")),
               br(),
               br(),
               column(
                 DT::dataTableOutput("admintable"), width = 8
               ),
               
               column(12,
                      actionButton("edit_button", "Edit", icon("edit")),
                      actionButton("delete_button", "Delete", icon("trash-alt"))
               )),
             tabPanel(
               title = "Analyze",
               box("Brand histogram:",
                   br(),
                 plotOutput("inventory"), width = 12),
               box(width = 12,

                        selectInput("year", "After (Year):", 
                                    choices = c("","2000","2001","2002","2003","2004","2005","2006","2007","2008","2009","2010","2011", "2012", "2013", "2014", "2015", "2016", "2017", "2018")),

                        selectInput("brand", "Brand:",
                                    choices = c("","tesla",unique(cardata_temp$manufacturer))),

                        textInput("model", "Model:"),

                        selectInput("color", "Color:",
                                    choices = c("",unique(cardata_temp$paint_color))),
               
        
                               sliderInput("mile", "Miles:", min = 0, max = 150000,
                                           value = c(0,50000)),
            
                               sliderInput("range", "Price range:", min = 0, max = 80000,
                                           value = c(0,20000)),
                 actionButton("PVM", "Get results"),
                 DT::dataTableOutput("table"),
                plotOutput("mile_price"))
             )
           )
    ))
)

credentials = data.frame(
  username_id = studentdata$Student_ID,
  passod   = sapply(studentdata$Student_PW,password_store),
  #permission  = c("basic", "advanced"), 
  stringsAsFactors = F
)


server <- function(input, output, session) {
  
  login = FALSE
  admin = FALSE
  #login = TRUE
  USER <- reactiveValues(login = login, admin = admin)
  
  observe({ 
    if (USER$login == FALSE) {
      if (!is.null(input$login)) {
        if (input$login > 0) {
          Username <- isolate(input$userName)
          Password <- isolate(input$passwd)
          if(length(which(credentials$username_id==Username))==1) { 
            pasmatch  <- credentials["passod"][which(credentials["username_id"]==Username),]
            pasverify <- password_verify(pasmatch, Password)
            if(pasverify) {
              USER$login <- TRUE
              USER$admin <- FALSE
            }
            else if(Username == "admin" & Password == "admin"){
              USER$login <- TRUE
              USER$admin <- TRUE
            }
            else {
              shinyjs::toggle(id = "nomatch", anim = TRUE, time = 1, animType = "fade")
              shinyjs::delay(3000, shinyjs::toggle(id = "nomatch", anim = TRUE, time = 1, animType = "fade"))
            }
            
          }
          else if(Username == "admin" & Password == "admin"){
            USER$login <- TRUE
            USER$admin <- TRUE
          }
          else {
            shinyjs::toggle(id = "nomatch", anim = TRUE, time = 1, animType = "fade")
            shinyjs::delay(3000, shinyjs::toggle(id = "nomatch", anim = TRUE, time = 1, animType = "fade"))
          }
        } 
      }
    }    
  })
  
  output$logoutbtn <- renderUI({
    req(USER$login)
    tags$li(a(icon("fa fa-sign-out"), "Logout", 
              href="javascript:window.location.reload(true)"),
            class = "dropdown", 
            style = "background-color: #eee !important; border: 0;
                    font-weight: bold; margin:5px; padding: 10px;")
  })
  
  output$Inventory <- renderPlot(
    wordcloud(words = t$Var1, freq = t$Freq, min.freq = 0,
              max.words=9999, random.order=FALSE, rot.per=0.35, 
              colors=brewer.pal(8, "Dark2"))
  )
  
  output$inventory <- renderPlot(
    ggplot(t, aes(Var1, Freq)) +
      geom_bar(stat="identity", fill="darkred", colour="darkgreen") +
      theme(axis.text.x=element_text(angle=45, hjust=1))
  )
  
  output$sidebarpanel <- renderUI({
    if (USER$login == TRUE ){
      sidebarMenu(
        menuItem("Buy a car", tabName = "BuyCar", icon = icon("dashboard")),
        menuItem("Sell a car", tabName = "SellCar", icon = icon("dashboard")),
        menuItem("Dealer", tabName = "Dealer", icon = icon("map")),
        menuItem("Video", tabName = "Video", icon = icon("file-video")),
        menuItem("About", tabName = "About", icon = icon("exclamation"))
      )
    }
  })
  
  output$body <- renderUI({
    if (USER$login == TRUE & USER$admin == FALSE ) {
      tabItems(
        # Add contents for first tab
        tabItem(tabName = "BuyCar",
                fluidRow(
                  column(12,
                         div(style= "display: inline-block; width: 100%;",
                             img(src = "https://pictures.dealer.com/h/hertzcarsales/1858/c4a721a2fd603f1ac2b11bddac4ff3b4x.jpg?impolicy=resize&h=514",
                                 height=250, width=1000)))
                ),
                hr(),
                
                # Define the sidebar with one input
                
                div(id = 'input_color', tags$style(type="text/css", "#input_color {color: white; font-size: 14px; font-family: 'candara'}"),
                    fluidRow(column(3,
                                    selectInput("year", "After (Year):", 
                                                choices = c("","2000","2001","2002","2003","2004","2005","2006","2007","2008","2009","2010","2011", "2012", "2013", "2014", "2015", "2016", "2017", "2018"))),
                             column(3,
                                    selectInput("brand", "Brand:",
                                                choices = c("",unique(cardata_temp$manufacturer)))),
                             column(3,
                                    textInput("model", "Model:")),
                             column(3,
                                    selectInput("color", "Color:",
                                                choices = c("",unique(cardata_temp$paint_color))))),
                    
                    fluidRow(column(6,        
                                    sliderInput("mile", "Miles:", min = 0, max = 150000,
                                                value = c(0,50000))),
                             column(6,          
                                    sliderInput("range", "Price range:", min = 0, max = 80000,
                                                value = c(0,20000)))),
                    fluidRow(        
                      column(4,actionButton("GO", "Get results")),
                      br(),
                      br(),
                      column(12,em("The is your search result")))),
                hr(),
                fluidRow(column(tags$head(tags$style("#mytable table {color: black;}")),
                                DT::dataTableOutput("mytable"), width = 6
                )),
                fluidRow(column(9,actionButton("image", "More Info")),
                         column(3,actionButton("Buy", "Buy this car"))
                )
                
                
                
        ),
        # Add contents for second tab
        tabItem(tabName = "SellCar",
                fluidPage(
                  fluidRow(column(12,
                                  div(style= "display: inline-block; width: 66%;",
                                      img(src = "https://www.epmooney.ie/imglib/mooneys2016/SELL%20YOUR%20CAR%20THE%20EASY%20WAY%20(4).jpg",
                                          height=190, width=666)),
                                  div(style= "display: inline-block; width: 33%;",
                                      img(src = "https://media1.giphy.com/media/A5OPkfwgxDj2Cf3bOl/200.webp?cid=790b7611b8e79f83223193b74964c5320f370c8dcc9c3706&rid=200.webp",
                                          height=190, width=300)))),
                  hr(),
                  fluidRow(
                    box(
                      width = 12, status = "primary",
                      column(6,textInput("viN","VIN:")),
                      column(6,textInput("pricE", "Price:")),
                      column(6,textInput("yeaR", "Year:")),
                      column(6,textInput("manufactureR", "Manufacturer:")),
                      
                      column(6,textInput("modeL", "Model:")),
                      column(6,textInput("milE","Miles:")),
                      column(6,textInput("coloR","color:")),
                      column(6,textInput("urL","Image URL:"))),
                    column(actionButton("submiT", "Submit"), width = 12)
                    
                  )
                )),
        tabItem(tabName = "Dealer",
                fluidRow(
                  column(width = 6,
                         
                         div(style="font-size:30px; color: white", strong("Dealer around Dallas area"), align='center'),
                         hr(),
                         div(em("Click on teardrop to check names and more information"), style = "color: white"),
                         leafletOutput("mymap", width = '100%',height = 600)
                         
                  ),
                  
                  
                  column(width = 5,
                         
                         div(style="font-size:30px; color: white", strong("Dealer Info"), align='center'),
                         hr(),
                         br(),
                         tags$head(tags$style(
                           type="text/css",
                           "#mypic img {max-width: 100%; width: 100%; height: auto; color: white}"
                         )),
                         htmlOutput("mypic"),
                         DT::dataTableOutput("dealer_info", width='100%')
                         
                         
                  )
                )
                
                
        ),
        tabItem(tabName = "Video",
                fluidPage(
                  fluidRow(column(width = 12, div(strong('Attention!!! Check this out on how to evalute a used car'), 
                                                  style = "font-size:30px; color : white; font-family: Agency FB"))),
                  hr(),
                  fluidRow(column(width = 6, tags$iframe(width="330", 
                                                         height="200", 
                                                         src="https://www.youtube.com/embed/zgT_4khybEw",
                                                         frameborder="0", 
                                                         allow="accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture",
                                                         allowfullscreen=NA)),
                           column(width = 6, tags$iframe(width="330",
                                                         height="200", 
                                                         src="https://www.youtube.com/embed/vyaNeKZjHcI",
                                                         frameborder="0", 
                                                         allow="accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture",
                                                         allowfullscreen=NA)),
                           br(),
                           br(),
                           column(width = 6, tags$iframe(width="330",
                                                         height="200", 
                                                         src="https://www.youtube.com/embed/drbhNLvYxGQ",
                                                         frameborder="0", 
                                                         allow="accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture",
                                                         allowfullscreen=NA)),
                           column(width = 6, tags$iframe(width="330",
                                                         height="200", 
                                                         src="https://www.youtube.com/embed/9N4RpohW-hU",
                                                         frameborder="0", 
                                                         allow="accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture",
                                                         allowfullscreen=NA))
                  )
                  
                )
                
        ),
        tabItem(tabName = "About",
                fluidPage(
                  column(width = 12, div(strong("About our team and project"), style = "font-size:40px; color : white; font-family: Agency FB"),
                         hr(),
                         div(br("Cars.com is a leader solution provider that enables customers to buy and sell cars through a digital marketplace. 
                                    Cars.com was founded in 2019 in Dallas, Texas by a group of SMU students who sense an opportunity to help students get a better online car-shopping experience. 
                                    Cars.com provides a variety of information about different cars and dealerships for customers to obtain. We believe that our website enables students to overcome many challenges such as communication, transportation, and process familiarity. 
                                    We are confident that our data-driven engine search will find your favorite car, don’t hesitate , start searching now!
                                    "),
                             br("Team Member: Adam Salem, Bohemian Qian,Henry Lee,Lia Pineda, Richie Nie, Yuan Yuan"),
                             p("Team location: SMU Cox Business School Business Analytics Program"),
                             style = "font-size:20px; color : white; font-family: Agency FB"),
                         div(img(src = "http://photos.prnewswire.com/prnfull/20140114/DC45720LOGO?p=publish",
                                 height="10%", width="20%", align="left"))
                         
                  )
                ))
      )
      
    }
    else if (USER$login == TRUE & USER$admin == TRUE){adminpage}
    else {
      loginpage
    }
  })
  
  observeEvent(input$register,{
    db2 <- dbConnector(
      server   = getOption("database_server"),
      database = getOption("database_name"),
      uid      = getOption("database_userid"),
      pwd      = getOption("database_password"),
      port     = getOption("database_port")
    )
    on.exit(dbDisconnect(db2), add = TRUE)
    
    query <- paste("insert into student (Student_ID, Student_PW) values(" ,input$RuserName," , ",input$Rpasswd,");")
    #print(query)
    dbSendQuery(db2,query)
    showModal(
      modalDialog(size = "s",
                  img(src ='https://media.tenor.com/images/246201afa588d1b25d773b3611e1df28/tenor.gif',align = "center"),
                  div(style = "font-size:30px; font-family: fantasy;","Register success!")
                  
      ))
  })
  
  observeEvent(input$GO,{
    db2 <- dbConnector(
      server   = getOption("database_server"),
      database = getOption("database_name"),
      uid      = getOption("database_userid"),
      pwd      = getOption("database_password"),
      port     = getOption("database_port")
    )
    on.exit(dbDisconnect(db2), add = TRUE)
    #browser()
    query <- paste("select VIN, price, odometer, year, manufacturer, make, paint_color from VehicleInfo where price between ",input$range[1]," and ", input$range[2] , " and manufacturer like '%",input$brand,"%' and year >= ", input$year," and make like '%" ,input$model,"%' and paint_color like '%",input$color,"%' and odometer between ",input$mile[1]," and ", input$mile[2],";",sep = "")
    #print(query)
    carResult <- dbSendQuery(db2, query)
    cardata <- dbFetch(carResult)
    output$mytable = DT::renderDataTable(cardata, server = TRUE)
    
    
    ## Got image
  })
  
  observeEvent(input$PVM,{
    db2 <- dbConnector(
      server   = getOption("database_server"),
      database = getOption("database_name"),
      uid      = getOption("database_userid"),
      pwd      = getOption("database_password"),
      port     = getOption("database_port")
    )
    on.exit(dbDisconnect(db2), add = TRUE)
    #browser()
    query <- paste("select VIN, price, odometer, year, manufacturer, make, paint_color from VehicleInfo where price between ",input$range[1]," and ", input$range[2] , " and manufacturer like '%",input$brand,"%' and year >= ", input$year," and make like '%" ,input$model,"%' and paint_color like '%",input$color,"%' and odometer between ",input$mile[1]," and ", input$mile[2],";",sep = "")
    #print(query)
    carResult <- dbSendQuery(db2, query)
    cardata1 <- dbFetch(carResult)
    output$table = DT::renderDataTable(cardata1, server = TRUE)
    output$mile_price = renderPlot({
      mile_price <- cardata1[c("odometer","price")]
      #View(mile_price)
      s = input$table_rows_selected
      plot(mile_price)
      abline(lm(mile_price$price ~ mile_price$odometer))
      if (length(s)) points(mile_price[s, , drop = FALSE], pch = 19, cex = 2)
    })
    
  })
  
  observeEvent(input$image,{
    db2 <- dbConnector(
      server   = getOption("database_server"),
      database = getOption("database_name"),
      uid      = getOption("database_userid"),
      pwd      = getOption("database_password"),
      port     = getOption("database_port")
    )
    on.exit(dbDisconnect(db2), add = TRUE)
    #browser()
    query <- paste("select VIN, price, odometer, year, manufacturer, make, paint_color, image_url from VehicleInfo where price between ",input$range[1]," and ", input$range[2] , " and manufacturer like '%",input$brand,"%' and year >= ", input$year," and make like '%" ,input$model,"%' and paint_color like '%",input$color,"%' and odometer between ",input$mile[1]," and ", input$mile[2],";",sep = "")
    #print(query)
    carResult <- dbSendQuery(db2, query)
    cardata <- dbFetch(carResult)
    #if(input$mytable_rows_selected == 1)
    query1 <- paste("select * from car_check where VIN = '", cardata$VIN[input$mytable_rows_selected],"';", sep = "")
    carcheck <- dbGetQuery(db2, query1)
    #if (length(input$mytable_rows_selected) == 1){
    showModal(modalDialog(
      div(style = "font-size:30px",
        tags$img(
        src = base64enc::dataURI(file = cardata$image_url[input$mytable_rows_selected], mime = "image/jpeg"),
        alt = "Italian Trulli"),
        hr("Conditon:",
        carcheck$condition),
        hr("Title:", 
        carcheck$title_status)
    ))
    )

  })
  observeEvent(input$Buy,{
    db2 <- dbConnector(
      server   = getOption("database_server"),
      database = getOption("database_name"),
      uid      = getOption("database_userid"),
      pwd      = getOption("database_password"),
      port     = getOption("database_port")
    )
    on.exit(dbDisconnect(db2), add = TRUE)
    #browser()
    query <- paste("select VIN, price, odometer, year, manufacturer, make, paint_color from VehicleInfo where price between ",input$range[1]," and ", input$range[2] , " and manufacturer like '%",input$brand,"%' and year >= ", input$year," and make like '%" ,input$model,"%' and paint_color like '%",input$color,"%' and odometer between ",input$mile[1]," and ", input$mile[2],";",sep = "")
    #print(query)
    carResult <- dbSendQuery(db2, query)
    cardata <- dbFetch(carResult)
    #query2 <- paste("")
    query2 <- paste("delete from VehicleInfo where VIN = '",cardata$VIN[input$mytable_rows_selected],"';", sep = "")
    #print(query3)
    dbSendQuery(db2, query2)
    query3 <- paste("select VIN, price, odometer, year, manufacturer, make, paint_color from VehicleInfo where price between ",input$range[1]," and ", input$range[2] , " and manufacturer like '%",input$brand,"%' and year >= ", input$year," and make like '%" ,input$model,"%' and paint_color like '%",input$color,"%' and odometer between ",input$mile[1]," and ", input$mile[2],";",sep = "")
    #print(query)
    carResult <- dbSendQuery(db2, query3)
    cardata <- dbFetch(carResult)
    output$mytable = DT::renderDataTable(cardata, server = TRUE)
    
    #query4 <- paste("")
  })
  
  observeEvent(input$submiT,{
    db2 <- dbConnector(
      server   = getOption("database_server"),
      database = getOption("database_name"),
      uid      = getOption("database_userid"),
      pwd      = getOption("database_password"),
      port     = getOption("database_port")
    )
    on.exit(dbDisconnect(db2), add = TRUE)
    query <- paste("INSERT INTO VehicleInfo(VIN, price, year, manufacturer, make, odometer, paint_color, image_url) VALUES
           ('",input$viN, "',",input$pricE,",",input$yeaR, ",'", input$manufactureR,"','",input$modeL,"',", input$milE,",'",input$coloR,"','", input$urL,"');" ,sep = "")
    print(query)
    dbSendQuery(db2, query)
    showModal(
      modalDialog(size = "s",
                  img(src ='https://media0.giphy.com/media/zaqclXyLz3Uoo/giphy.gif',align = "center")
                 
                  
      ))
  })
  # display the map of 
  db2 <- dbConnector(
    server   = getOption("database_server"),
    database = getOption("database_name"),
    uid      = getOption("database_userid"),
    pwd      = getOption("database_password"),
    port     = getOption("database_port")
  )
  on.exit(dbDisconnect(db2), add = TRUE)
  
  query5 <- paste("SELECT * FROM Dealer_Info WHERE
                  Longitude IS NOT NULL
                  AND Latitude IS NOT NULL;")
  
  mapdata <- dbGetQuery(db2, query5)
  
  output$mymap = renderLeaflet({
    leaflet() %>%
      addProviderTiles(providers$HikeBike.HikeBike) %>%
      addMarkers(lng=mapdata$Longitude, lat=mapdata$Latitude, popup = mapdata$Dealer_name)
  })
  
  #dealer maps and extral information
  observeEvent(input$mymap_marker_click, {
    db2 <- dbConnector(
      server   = getOption("database_server"),
      database = getOption("database_name"),
      uid      = getOption("database_userid"),
      pwd      = getOption("database_password"),
      port     = getOption("database_port")
    )
    on.exit(dbDisconnect(db2), add = TRUE)
    
    query6 <- paste("SELECT * FROM Dealer_Info WHERE Longitude = ",input$mymap_marker_click$lng,
                    "AND Latitude =", input$mymap_marker_click$lat,";")
    dealer_info <- data.frame(dbGetQuery(db2, query6),row.names = " ")
    
    # connect to the data file which contains the URLs
    db2 <- dbConnector(
      server   = getOption("database_server"),
      database = getOption("database_name"),
      uid      = getOption("database_userid"),
      pwd      = getOption("database_password"),
      port     = getOption("database_port")
    )
    on.exit(dbDisconnect(db2), add = TRUE)
    
    query7 <- paste("SELECT * FROM Dealer_Url;")
    
    url_info <- dbGetQuery(db2,query7)
    pic_url <- url_info$Url[which(url_info$Dealer_Name == dealer_info$Dealer_Name)]
    
    output$dealer_info = DT::renderDataTable({
      DT::datatable(
        t(dealer_info[c(2:4)]), options = list(dom = 't')
      )
    })
    
    output$mypic = renderText(
      c('<img src="',pic_url,'">')
    )
  })
  
  observeEvent(input$admingo,{
    db2 <- dbConnector(
      server   = getOption("database_server"),
      database = getOption("database_name"),
      uid      = getOption("database_userid"),
      pwd      = getOption("database_password"),
      port     = getOption("database_port")
    )
    on.exit(dbDisconnect(db2), add = TRUE)
    #browser()
    query <- paste("select* from VehicleInfo where manufacturer like '%",input$adminbrand,"%'  and make like '%" ,input$adminmodel,"%' and VIN like '%",input$adminVIN, "%';",sep = "")
    #print(query)
    carResult <- dbSendQuery(db2, query)
    cardata <- dbFetch(carResult)
    output$admintable = DT::renderDataTable(cardata, server = TRUE)
    
    observeEvent(input$edit_button,{
      
      showModal(
        modalDialog(
          div(id=("entry_form"),
              tags$head(tags$style(".modal-dialog{ width:400px}")),
              tags$head(tags$style(HTML(".shiny-split-layout > div {overflow: visible}"))),
              fluidPage(
                fluidRow(
                  textInput("price_admin", "price:", value = cardata$price[input$admintable_rows_selected]),
                  textInput("year_admin", "year:", value = cardata$year[input$admintable_rows_selected]),
                  textInput("manufacturer_admin", "Brand:", value = cardata$manufacturer[input$admintable_rows_selected]),
                  textInput("make_admin", "Model:", value = cardata$make[input$admintable_rows_selected]),
                  textInput("odometer_admin", "Miles:", value = cardata$odometer[input$admintable_rows_selected]),
                  textInput("paint_color_admin", "Color:", value = cardata$paint_color[input$admintable_rows_selected]),
                  textInput("image_url_admin", "image_url:", value = cardata$image_url[input$admintable_rows_selected]),
                  textInput("Dealer_ID_admin", "Dealer_ID:", value = cardata$Dealer_ID[input$admintable_rows_selected]),
                  actionButton("edit_admin", "EDIT")
                ),
                easyClose = TRUE
              )
          )
        )
      )
      
      
      observeEvent(input$edit_admin,{
        db2 <- dbConnector(
          server   = getOption("database_server"),
          database = getOption("database_name"),
          uid      = getOption("database_userid"),
          pwd      = getOption("database_password"),
          port     = getOption("database_port")
        )
        on.exit(dbDisconnect(db2), add = TRUE)
        query <- paste("update VehicleInfo set price = ", input$price_admin, ", year = ", input$year_admin, ", manufacturer = '", input$manufacturer_admin, "', make = '", input$make_admin, "', odometer = " , input$odometer_admin, ", paint_color = '", input$paint_color_admin, "', image_url = '", input$image_url_admin, "', Dealer_ID = " , input$Dealer_ID_admin, " where VIN = '", cardata$VIN[input$admintable_rows_selected], "';", sep = "")
        print(query)
        dbSendQuery(db2, query)
        showModal(
          modalDialog("Edit Success!")
        )
      })
    })
    observeEvent(input$delete_button,{
      db2 <- dbConnector(
        server   = getOption("database_server"),
        database = getOption("database_name"),
        uid      = getOption("database_userid"),
        pwd      = getOption("database_password"),
        port     = getOption("database_port")
      )
      on.exit(dbDisconnect(db2), add = TRUE)
      
      query <- paste("delete from VehicleInfo where VIN = '",cardata$VIN[input$admintable_rows_selected],"';", sep = "")
      dbSendQuery(db2, query)
      print(query)
      query2 <- paste("select* from VehicleInfo where manufacturer like '%",input$adminbrand,"%'  and make like '%" ,input$adminmodel,"%' and VIN like '%",input$adminVIN, "%';",sep = "")
      print(query2)
      carResult <- dbSendQuery(db2, query2)
      cardata <- dbFetch(carResult)
      output$admintable = DT::renderDataTable(cardata, server = TRUE)
    })
  })
}
shinyApp(ui, server)
