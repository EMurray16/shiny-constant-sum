# shiny-constant-sum
This is a simple constant sum voting app implemented in shiny. I wrote it because I really like the [constant sum question type in Qualtrics](https://www.qualtrics.com/support/survey-platform/survey-module/editing-questions/question-types-guide/specialty-questions/constant-sum/), but was too cheap to pay for Qualtrics to orchestrate a vote like that. 

This app is pretty simple. The choices are read from a csv, and the server sends the UI elements for the choices to the user interface by parsing that file and building each element. This means the choices can be changed only by changing the csv file, and not having to change many lines of code for each option. This also means the *number* of options can be changed just as easily.

The app auto-refreshes a message whenever an input is altered to let the user know what their vote count is relative to how many they're allowed to cast. Once a vote has been entered, the option of hitting submit again is taken away, to provide easy spamming.

The votes are written to a small csv file, named with the date and time of submittal (on the server side, not the client). The time is tracked to the millisecond to avoid filename collisions. With these csv files, it's easy to write an R script that will tabulate the votes. Then the vote-by-vote csv files may be deleted, kept in an archive, or left alone depending on the needs of the project. 