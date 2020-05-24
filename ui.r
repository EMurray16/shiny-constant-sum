#This is the front-end for the edit application page
library(shiny)
library(shinythemes)
library(shinyjs)

shinyUI(fluidPage(title="Constant Sum Demo", theme=shinytheme("yeti"), useShinyjs(),
	headerPanel("Constant Sum Proof of Concept"),
	
	sidebarPanel(h3(strong("How It Works")),
		p("This is a constant sum voting app. In it, users are presented with 
		a number of choices to vote on. But rather than having just one vote (which is restricting),
		or doing ranked choice voting (which is hard), users get a multiple votes, which are all
		equally weighted. In this example, there are 5 choices, and users may
		distribute 20 votes between them, however they'd like."),
		br(),
		p("There are some fancy features here as well:"), 
		p(" - To avoid bias, the order of choices is randomized from run to run."),
		p(" - To avoid multiple submissions, the Submit button is removed on successful entry"),
		p(" - A text notification refreshes every time a numeric input is altered to tell the user if they've used all of their votes"),
		br(),
		p("Once someone has voted, their votes are written as a small csv file to the `votes` folder of the app. The filename includes
		the submission time of the vote down to the millisecond, which makes this 99% (but not 100%!) collision-free. Because
		each csv is small, millions of votes can be recorded without burdening disk space, and they are easy to tabulate in 
		an R script once the vote is completed."),
		
		width=4
	),
	
	mainPanel(h1(strong('Choices')), 
		#br(),
		p("You get 20 votes to spread across the options below:"),
		hr(),
		uiOutput("choiceForm"),
		width=4
	),
	
	sidebarPanel(
		textOutput("submitmessage"),
		actionButton("submit", label=h4(strong("Submit")), width="100%"),
		width = 4
	)
))