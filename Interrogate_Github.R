install.packages("jsonlite")
library(jsonlite)
install.packages("httpuv")
library(httpuv)
install.packages("httr")
library(httr)
install.packages("plotly")
# Can be github, linkedin etc depending on application
oauth_endpoints("github")

# Change based on what you 
myapp <- oauth_app(appname = "Access_GitHub",
                   key = "27740e73ccf378672ed4",
                   secret = "f4c420255700721ddf1389cdfffcdf884f111c14")

# Get OAuth credentials
github_token <- oauth2.0_token(oauth_endpoints("github"), myapp)

# Use API
gtoken <- config(token = github_token)
req <- GET("https://api.github.com/users/evanmagee/repos", gtoken)

# Take action on http error
stop_for_status(req)

# Extract content from a request
json1 = content(req)

# Convert to a data.frame
gitDF = jsonlite::fromJSON(jsonlite::toJSON(json1))

# Subset data.frame
gitDF[gitDF$full_name == "evanmagee/datasharing", "created_at"] 

# Interrogate the Github API to extract data from my github account

myData = fromJSON("https://api.github.com/users/evanmagee")

#displays number of followers
myData$followers
followers = fromJSON("https://api.github.com/users/evanmagee/followers")
followers$login #Names of my followers

myData$following #Number of people i am following

following = fromJSON("https://api.github.com/users/evanmagee/following")
following$login #shows the names of all the people i am following 

myData$public_repos #Number of repositories I have


repos = fromJSON("https://api.github.com/users/evanmagee/repos")
repos$name #Names of my repositories 
repos$created_at #When repositories were created
repos$full_name #gives names of repositiories

myData$bio #Shows my bio

#Part 2 - Visualisations

#Using Matt Layher's account because he has more information than me. Found him online 


myData = GET("https://api.github.com/users/mdlayher/followers?per_page=100;", gtoken)
stop_for_status(myData)
extract = content(myData)
#converts into dataframe
githubDB = jsonlite::fromJSON(jsonlite::toJSON(extract))
githubDB$login

# Retrieve a list of usernames
id = githubDB$login
user_ids = c(id)

# Create an empty vector and data.frame
users = c()
usersDB = data.frame(
  username = integer(),
  following = integer(),
  followers = integer(),
  repos = integer(),
  dateCreated = integer()
)

#loops through users and adds to list
for(i in 1:length(user_ids))
{
  
  followingURL = paste("https://api.github.com/users/", user_ids[i], "/following", sep = "")
  followingRequest = GET(followingURL, gtoken)
  followingContent = content(followingRequest)
  
  #Does not add users if they have no followers
  if(length(followingContent) == 0)
  {
    next
  }

}
followingDF = jsonlite::fromJSON(jsonlite::toJSON(followingContent))
followingLogin = followingDF$login

#Loop through 'following' users
for (j in 1:length(followingLogin))
{
  #Check for duplicate users
  if (is.element(followingLogin[j], users) == FALSE)
  {
    #Adds user to the current list
    users[length(users) + 1] = followingLogin[j]
    
    #Obtain information from each user
    followingUrl2 = paste("https://api.github.com/users/", followingLogin[j], sep = "")
    following2 = GET(followingUrl2, gtoken)
    followingContent2 = content(following2)
    followingDF2 = jsonlite::fromJSON(jsonlite::toJSON(followingContent2))
    
    # who user is following
    followingNumber = followingDF2$following
    
    #followers
    followersNumber = followingDF2$followers
    
    # how many repository the user has 
    reposNumber = followingDF2$public_repos
    
    #year which each user joined Github
    yearCreated = substr(followingDF2$created_at, start = 1, stop = 4)
    
    #Add users data to a new row in dataframe
    usersDB[nrow(usersDB) + 1, ] = c(followingLogin[j], followingNumber, followersNumber, reposNumber, yearCreated)
    
  }
  next
}

if(length(users) > 150)
{
  break
}
next



#Use plotly to graph
Sys.setenv("plotly_username"="evanmagee")
Sys.setenv("plotly_api_key"="U6bhtM82CFCsMq6a39n3")

#plot one graphs repositories vs followers coloured by year
plot1 = plot_ly(data = usersDB, x = ~repos, y = ~followers, text = ~paste("Followers: ", followers, "<br>Repositories: ", repos, "<br>Date Created:", dateCreated), color = ~dateCreated)
plot1

