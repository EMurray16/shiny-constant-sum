# This is the server for the constant sum voting app
library(shiny)
library(shinyjs)
options(digits.secs = 3)

# This function builds a UI from a choices.csv document
buildChoiceUI <- function(filename, numberOfVotes) {
	choiceData = read.csv("choices.csv", stringsAsFactors=F)
	nChoices = nrow(choiceData)
	defaultVotes = 0
	
	choiceOrder = sample(choiceData$ChoiceID)
	
	UIstring = "tagList("
	sumString = "sum(c("
	uiID = vector(mode="character", length=nChoices)
	for (i in 1:nChoices) {
		index = choiceOrder[i]
		inputVarName = paste("choice", i, sep="")
		choiceLabel = choiceData$Name[index]
		
		
		UIstring = paste(UIstring, 
			" numericInput(inputId='",inputVarName, "'",
			", label='", choiceLabel, "'",
			", value=", defaultVotes, 
			",min=0, max=",numberOfVotes,
			", step=1)",
			sep = ""
		)
		
		sumString = paste(sumString,
			"input$", inputVarName,
			sep = ""
		)
		
		if (i < nChoices) {
			UIstring = paste(UIstring, ",")
			sumString = paste(sumString, ",")
		}
		
		uiID[index] = inputVarName
	}
	UIstring = paste(UIstring, ")")
	sumString = paste(sumString, "))")
	
	# Add the inputID to the table so we can reference when saving votes
	choiceData$uiID = uiID
	
	return(list(UIstring, choiceData, sumString))
}
votesAllowed = 20
choiceList = buildChoiceUI("choice.csv", votesAllowed)
choiceTable = choiceList[[2]]
choiceUIString = choiceList[[1]]
totalVoteString = choiceList[[3]]
print(totalVoteString)

function(input, output, session) {
	reactVals = reactiveValues()
	reactVals$hasSubmit = FALSE
	# The first thing we want to do is render the choices
	output$choiceForm = renderUI(eval(parse(text=choiceUIString)))
	
	# Now we want to hide the submit button
	numericObserver <- observe({
		shinyjs::hide("submit")
		
		#print(eval(parse(text=totalVoteString)))
		totalVotesCast = eval(parse(text=totalVoteString))
		#print(totalVotesCast)
		
		# Handle the text message first
		if (!is.na(totalVotesCast)) { # This is a failsafe if the UI hasn't completely rendered, or a 
			if (totalVotesCast < votesAllowed & !reactVals$hasSubmit) {
				votesLeft = votesAllowed - totalVotesCast
				output$submitmessage = renderText(paste(
					"You still have", votesLeft, "votes left to cast before you can submit."
				))
			} else if (totalVotesCast > votesAllowed & !reactVals$hasSubmit) {
				votesOver = totalVotesCast - votesAllowed
				output$submitmessage = renderText(paste(
					"You've entered", votesOver, "votes too many! You must remove them before you can submit."
				))
			} else if (totalVotesCast == votesAllowed) {
				#print(reactVals$hasSubmit)
				if (!reactVals$hasSubmit) {
					output$submitmessage = renderText(
						"You have entered the correct number of votes. Hit SUBMIT to vote now!"
					)
					shinyjs::show("submit")
				} else {
					output$submitmessage = renderText(
						"Thank you for voting! Your results have been recorded."
					)
				}
			}
		}
	})
	
	observeEvent(input$submit, handlerExpr = {
		timeOfSubmit = Sys.time()
		# Convert this to a string, and replace spaces with underscores
		timeOfSubmitString = gsub(" ", "_", as.character(timeOfSubmit))
		# Now replace dashes, decimals, and semicolons with underscores
		timeOfSubmitString = gsub("-", "_", timeOfSubmitString)
		timeOfSubmitString = gsub("\\.", "_", timeOfSubmitString)
		timeOfSubmitString = gsub(":", "_", timeOfSubmitString)
		
		# Create the output filename
		outputFilename = paste("votes/vote_", timeOfSubmitString, ".csv", sep="")
		
		# Now append the votes to the existing table
		voteVec = vector(mode='double', length=nrow(choiceTable))
		
		for (i in 1:nrow(choiceTable)) {
			listVarName = choiceTable[i,"uiID"]
			voteCount = input[[listVarName]]
			voteVec[i] = voteCount
		}
		
		choiceTable$votes = voteVec
		
		# Write the csv file
		write.csv(choiceTable, file=outputFilename, row.names=F)
		reactVals$hasSubmit = TRUE
		
		shinyjs::hide("submit")
		#numericObserver$destroy
	})
}