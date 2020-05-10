"{
http://localhost:8080/otp/routers/current/isochrone?fromPlace=32.79398,-96.78140&date=02-12-2019&time=09:00:00
&maxWalkDistance=1600&mode=WALK,TRANSIT&cutoffSec=900&cutoffSec=1800&cutoffSec=2700&cutoffSec=3600&cutoffSec=4500&cutoffSec=6000



http://132.207.98.170:8014/otp/routers/default/isochrone?fromPlace=45.537854,-73.611638&date=2015/03/20&time=11:00:00
&maxWalkDistance=500&mode=WALK,TRANSIT&cutoffSec=300&cutoffSec=600&cutoffSec=900&cutoffSec=1200&cutoffSec=1500&cutoffSec=1800
&cutoffSec=2100&cutoffSec=2400&cutoffSec=2700&cutoffSec=3000&cutoffSec=3300&cutoffSec=3600 

}"

setwd("D:/Google Drive/UTD/19 Spring")
source("otp-api-fn.R")
library(progress)
library(httr)

isochrone_by_wt <- GET(
  "http://localhost:8080/otp/routers/current/isochrone",
  query = list(
    fromPlace = "32.79398,-96.78140", # latlong of Manchester Airport
    mode = "WALK,TRANSIT", # modes we want the route planner to use
    date = "02-12-2019",
    time= "09:00am",
    maxWalkDistance = 1600, # in metres
    walkReluctance = 5,
    minTransferTime = 600, # in secs (allow 10 minutes)
    cutoffSec = 1000,
    cutoffSec = 1500,
    cutoffSec = 3000,
    cutoffSec = 4500,
    cutoffSec = 6000
  )
)

wtiso <- content(isochrone_by_wt, as = "text", encoding = "UTF-8") # to text

write(wtiso, file = "wtiso.geojson") # save to file

isochrone_by_c <- GET(
  "http://localhost:8080/otp/routers/current/isochrone",
  query = list(
    fromPlace = "32.79398,-96.78140", # latlong of Manchester Airport
    mode = "CAR", # modes we want the route planner to use
    date = "02-12-2019",
    time= "09:00am",
    maxWalkDistance = 1600, # in metres
    walkReluctance = 5,
    minTransferTime = 600, # in secs (allow 10 minutes)
    cutoffSec = 1000,
    cutoffSec = 1500,
    cutoffSec = 3000,
    cutoffSec = 4500,
    cutoffSec = 6000
  )
)

otpIsochrone <-function(otpcon,
           from = '32.80409, -96.80719',
           modes = 'WALK,TRANSIT',
           date = '2019/02/12',
           time = '09:00:00',
           maxWalkDistance = 1600,
           cutoffSec = 900,
           cutoffSec = 1800,
           cutoffSec = 2700,
           cutoffSec = 3600,
           cutoffSec = 4500,
           cutoffSec = 6000)

ciso <- content(isochrone_by_c, as = "text", encoding = "UTF-8") # to text

write(ciso, file = "ciso.geojson") # save to file

# Import the LSOA CSV file
Home <- read.csv("Home_LL.csv",stringsAsFactors = FALSE)
head(Home)

Work <- read.csv("DW_LL.csv",stringsAsFactors = FALSE)
head(Work)

# Load the OTP API functions
source("otp-api-fn.R")

# Call otpConnect() to define a connection called otpcon
otpcon <-
  otpConnect(
    hostname = "localhost",
    router = "current",
    port = "8080",
    ssl = "false"
  )

# Call otpTripTime to get attributes of an itinerary
otpTripTime(
  otpcon,
  from = '32.80409, -96.80719',
  to = '32.79334, -96.78200',
  modes = 'WALK,TRANSIT',
  detail = TRUE,
  date = '2019-02-26',
  time = '10:00am',
  maxWalkDistance = '1600',
  walkReluctance = '5',
  walkSpeed = '3',
  minTransferTime = '600'
)


############# For Home and Work #################
total <- nrow(Home) # set number of records
pb <- progress_bar$new(total = total, format = "(:spin)[:bar]:percent") #progress bar

# Begin the loop
for (i in 1:total) {
  pb$tick() # update progress bar
  response <-
    otpTripTime(
      otpcon,
      from = Home[i,]$latlong,
      to = Work[i,]$latlong,
      modes = 'WALK,TRANSIT',
      detail = TRUE,
      date = '2019-02-12',
      time = '09:00am',
      maxWalkDistance = "1600", # allows 800m at both ends of journey
      walkReluctance = "5",
      minTransferTime = "600"
    )
  # If response is OK update dataframe
  if (response$errorId == "OK") {
    Home[i, "status"] <- response$errorId
    Home[i, "duration"] <- response$itineraries$duration
    Home[i, "waitingtime"] <- response$itineraries$waitingTime
    Home[i, "transfers"] <-response$itineraries$transfers
  } else {
    # record error
    Home[i, "status"] <- response$errorId
  }
}

print(Home$status)

Home$lat <- substr(Home$latlong, 1,12)
Home$long <- substr(Home$latlong, 15,27)


'60df' <- subset(Home, duration <= 60)
'30df' <- subset(Home, duration <= 30)

`60df`$latitude <- `60df`$lat
`60df`$longitude <- `60df`$long

write.csv(`60df`, file = "texas_60.csv") # save to file

write.csv(`30df`, file = "texas_30.csv") # save to file

################  For ODLL (Only Jobs with living wage)  #################

ODLL <- read.csv("ODLL.csv",stringsAsFactors = FALSE)
head(ODLL)

ODtotal <- nrow(ODLL) # set number of records
ODpb <- progress_bar$new(total = ODtotal, format = "(:spin)[:bar]:percent") #progress bar

# Begin the loop
for (i in 1:ODtotal) {
  ODpb$tick() # update progress bar
  response <-
    otpTripTime(
      otpcon,
      from = ODLL[i,]$H_latlong,
      to = ODLL[i,]$W_latlong,
      modes = 'CAR',
      detail = TRUE,
      date = '2019-02-12',
      time = '09:00am',
      maxWalkDistance = "1600", # allows 800m at both ends of journey
      walkReluctance = "5",
      minTransferTime = "600"
    )
  # If response is OK update dataframe
  if (response$errorId == "OK") {
    ODLL[i, "status"] <- response$errorId
    ODLL[i, "duration"] <- response$itineraries$duration
    ODLL[i, "waitingtime"] <- response$itineraries$waitingTime
    ODLL[i, "transfers"] <-response$itineraries$transfers
  } else {
    # record error
    ODLL[i, "status"] <- response$errorId
  }
}

###### After getting the travel time put it back to the SQL we can get the average travel for each census block group
###### and using the Home geoid and put it into the QGIS to generate the map 
###### Each census blocks group's average travel time map to the jobs with living wage


#############   Q6  ###############
DCLL <- read.csv("City_of_Dallas.csv",stringsAsFactors = FALSE)
head(DCLL)

CLL <- read.csv("Q6C.csv",stringsAsFactors = FALSE)
head(CLL)

DCtotal <- nrow(DCLL) # set number of records
Ctotal <- nrow(CLL)
pb <- progress_bar$new(total = DCtotal*Ctotal, format = "(:spin)[:bar]:percent") #progress bar

##  By Car

Result <- NA
for (j in 1:Ctotal) {
  for (i in 1:DCtotal) {
    pb$tick() 
    response <-
      otpTripTime(
        otpcon,
        from = DCLL[i,]$latlong,
        to = CLL[j,]$latlong,
        modes = 'CAR',
        detail = TRUE,
        date = '2019-02-12',
        time = '09:00am',
        maxWalkDistance = "1600", 
        walkReluctance = "5",
        minTransferTime = "600"
      )
    # If response is OK update dataframe
    if (response$errorId == "OK") {
      DCLL[i, "status"] <- response$errorId
      DCLL[i, "duration"] <- response$itineraries$duration
      DCLL[i, "waitingtime"] <- response$itineraries$waitingTime
      DCLL[i, "transfers"] <-response$itineraries$transfers
    } else {
      # record error
      DCLL[i, "status"] <- response$errorId
    }
  }
  Result <- rbind(Result, DCLL)
}

##  Checking Null Values

length(which(Result == '404'))
length(which(is.na(Result)))

##  Save File

'Clinic_60dfbc' <- subset(Result, duration <= 60)
'Clinic_30dfbc' <- subset(Result, duration <= 30)

write.csv(`Clinic_60dfbc`, file = "Clinic_60BC.csv") # save to file

write.csv(`Clinic_30dfbc`, file = "Clinic_30BC.csv") # save to file

##  By Transit

DCtotal <- nrow(DCLL) # set number of records
Ctotal <- nrow(CLL)
pb <- progress_bar$new(total = DCtotal*Ctotal, format = "(:spin)[:bar]:percent") #progress bar


Result2 <- NA
for (j in 1:Ctotal) {
  for (i in 1:DCtotal) {
    pb$tick() 
    response <-
      otpTripTime(
        otpcon,
        from = DCLL[i,]$latlong,
        to = CLL[j,]$latlong,
        modes = 'WALK,TRANSIT',
        detail = TRUE,
        date = '2019-02-12',
        time = '09:00am',
        maxWalkDistance = "1600", 
        walkReluctance = "5",
        minTransferTime = "600"
      )
    # If response is OK update dataframe
    if (response$errorId == "OK") {
      DCLL[i, "status"] <- response$errorId
      DCLL[i, "duration"] <- response$itineraries$duration
      DCLL[i, "waitingtime"] <- response$itineraries$waitingTime
      DCLL[i, "transfers"] <-response$itineraries$transfers
    } else {
      # record error
      DCLL[i, "status"] <- response$errorId
    }
  }
  Result2 <- rbind(ResultZ, DCLL)
}

##  Checking Null Values

length(which(Result2 == '404'))
length(which(is.na(Result2)))

##  Save File

'Clinic_60dfbt' <- subset(Result2, duration <= 60)
'Clinic_30dfbt' <- subset(Result2, duration <= 30)

write.csv(`Clinic_60dfbt`, file = "Clinic_60BT.csv") # save to file

write.csv(`Clinic_30dfbt`, file = "Clinic_30BT.csv") # save to file

############### After getting the travel time from census block group to clinic for each one 
############### put it into the QGIS and calculate the number of clinics that each census block group can reach within 30 or 60m
############### After that we can apply it on to the map and we will have to redo it all over agian for transport via car

#############   Q4  ###############
DCLL <- read.csv("DClatlong.csv",stringsAsFactors = FALSE)
head(DCLL)

GLL <- read.csv("Q4G.csv",stringsAsFactors = FALSE)
head(CLL)

DCtotal <- nrow(DCLL) # set number of records
Gtotal <- nrow(GLL)
pb <- progress_bar$new(total = DCtotal*Gtotal, format = "(:spin)[:bar]:percent") #progress bar

##  By Car

Result3 <- NA
for (j in 1:Gtotal) {
  for (i in 1:DCtotal) {
    pb$tick() 
    response <-
      otpTripTime(
        otpcon,
        from = DCLL[i,]$latlong,
        to = GLL[j,]$latlong,
        modes = 'CAR',
        detail = TRUE,
        date = '2019-02-12',
        time = '09:00am', 
        maxWalkDistance = "1600", 
        walkReluctance = "5",
        minTransferTime = "600"
      )
    # If response is OK update dataframe
    if (response$errorId == "OK") {
      DCLL[i, "status"] <- response$errorId
      DCLL[i, "duration"] <- response$itineraries$duration
      DCLL[i, "waitingtime"] <- response$itineraries$waitingTime
      DCLL[i, "transfers"] <-response$itineraries$transfers
    } else {
      # record error
      DCLL[i, "status"] <- response$errorId
    }
  }
  Result3 <- rbind(Result3, DCLL)
}

##  Checking Null Values

length(which(Result3 == '404'))
length(which(is.na(Result3)))

##  Save File

'G_60dfbc' <- subset(Result3, duration <= 60)
'G_30dfbc' <- subset(Result3, duration <= 30)

write.csv(`G_60dfbc`, file = "G_60BC.csv") # save to file

write.csv(`G_30dfbc`, file = "G_30BC.csv") # save to file

##  By Transit

DCtotal <- nrow(DCLL) # set number of records
Gtotal <- nrow(GLL)
pb <- progress_bar$new(total = DCtotal*Gtotal, format = "(:spin)[:bar]:percent") #progress bar


Result4 <- NA
for (j in 1:Gtotal) {
  for (i in 1:DCtotal) {
    pb$tick() 
    response <-
      otpTripTime(
        otpcon,
        from = DCLL[i,]$latlong,
        to = GLL[j,]$latlong,
        modes = 'WALK,TRANSIT',
        detail = TRUE,
        date = '2019-02-12',
        time = '09:00am',
        maxWalkDistance = "1600", 
        walkReluctance = "5",
        minTransferTime = "600"
      )
    # If response is OK update dataframe
    if (response$errorId == "OK") {
      DCLL[i, "status"] <- response$errorId
      DCLL[i, "duration"] <- response$itineraries$duration
      DCLL[i, "waitingtime"] <- response$itineraries$waitingTime
      DCLL[i, "transfers"] <-response$itineraries$transfers
    } else {
      # record error
      DCLL[i, "status"] <- response$errorId
    }
  }
  Result4 <- rbind(Result4, DCLL)
}



##  Checking Null Values

length(which(Result4 == '404'))
length(which(is.na(Result4)))

##  Save File

'G_60dfbt' <- subset(Result4, duration <= 60)
'G_30dfbt' <- subset(Result4, duration <= 30)

write.csv(`G_60dfbt`, file = "G_60BT.csv") # save to file

write.csv(`G_30dfbt`, file = "G_30BT.csv") # save to file

