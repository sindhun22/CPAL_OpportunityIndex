# Load libraries
library(progress)

# Import centroids file
gm_lsoa_centroids <- read.csv("CleanedLodeswithcentroid.csv", stringsAsFactors = FALSE)

# Load the OTP API functions
source("materials/materials/apps/otp-api-fn.R")

# Call otpConnect() to define a connection called otpcon
otpcon <-
  otpConnect(
    hostname = "localhost",
    router = "current",
    port = "8080",
    ssl = "false"
  )


total <- nrow(gm_lsoa_centroids) # set number of records
pb <- progress_bar$new(total = total, format = "(:spin) [:bar] :percent") #progress bar

# Begin the for loop  
for (i in 1:total) {
  pb$tick()   # update progress bar
  
  response <-
    otpTripTime(
      otpcon,
      from = gm_lsoa_centroids[i, ]$Origin_latlong,
      to = gm_lsoa_centroids[i, ]$Dest_latlong,
      modes = 'CAR',
      detail = TRUE,
      date = '2018-11-12',
      time = '08:00am',
      maxWalkDistance = "1600", # allows 800m at both ends of journey
      walkReluctance = "5",
      minTransferTime = "600"
    )
  # If response is OK update dataframe
  if (response$errorId == "OK") {
    gm_lsoa_centroids[i, "status"] <- response$errorId
    gm_lsoa_centroids[i, "duration"] <- response$itineraries$duration
    gm_lsoa_centroids[i, "waitingtime"] <- response$itineraries$waitingTime
    gm_lsoa_centroids[i, "transfers"] <-response$itineraries$transfers
  } else {
    # record error
    gm_lsoa_centroids[i, "status"] <- response$errorId
  }
}


write.csv(gm_lsoa_centroids, file="OTP_Output_car.csv")
