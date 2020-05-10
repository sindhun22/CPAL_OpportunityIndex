library("xlsx")

# Load LODES data
lodes.df <- read.csv("tx_od_main_JT00_2015.csv")

# Prevent Scientific Notation in R operations
options(scipen=999)

# Extract BlockGroup information from census blocks of work and home
lodes.df$h_blkgrp <- substring(lodes.df$h_geocode, 1, 12)
lodes.df$w_blkgrp <- substring(lodes.df$w_geocode, 1, 12)

# Extract Column Names
colnames(lodes.df)
# Result - [1] "w_geocode"  "h_geocode"  "S000"       "SA01"       "SA02"       "SA03"       "SE01"       "SE02"      
#          [9] "SE03"       "SI01"       "SI02"       "SI03"       "createdate" "h_blkgrp"   "w_blkgrp"

# Remove w_geocode, h_geocode and createdate from lodes
lodes.df <- lodes.df[,c(-1,-2,-13)]

# Check Column names now
colnames(lodes.df)
# Result OK [1] "S000"     "SA01"     "SA02"     "SA03"     "SE01"     "SE02"     "SE03"     "SI01"     "SI02"     "SI03"    
#          [11] "h_blkgrp" "w_blkgrp"

# Aggregate Lodes Data W.r.t h_blockgroups and w_blockgroups
aggresult.df <- aggregate(lodes.df[,c(-11, -12)], by = list(lodes.df$h_blkgrp, lodes.df$w_blkgrp), FUN = sum)

colnames(aggresult.df)
#Writing to new DF with descriptive column names
names(aggresult.df)[names(aggresult.df) == "Group.1"] <- "Origin_Res_CBG"
names(aggresult.df)[names(aggresult.df) == "Group.2"] <- "Dest_Wrk_CBG"
names(aggresult.df)[names(aggresult.df) == "S000"] <- "Total_jobs"
names(aggresult.df)[names(aggresult.df) == "SA01"] <- "Jobs_AgeYT29"
names(aggresult.df)[names(aggresult.df) == "SA02"] <- "Jobs_Age30to54"
names(aggresult.df)[names(aggresult.df) == "SA03"] <- "Jobs_AgeOT55"
names(aggresult.df)[names(aggresult.df) == "SE01"] <- "Jobs_WageLT1250"
names(aggresult.df)[names(aggresult.df) == "SE02"] <- "Jobs_Wage1251to3333"
names(aggresult.df)[names(aggresult.df) == "SE03"] <- "Jobs_WageGT3333"
names(aggresult.df)[names(aggresult.df) == "SI01"] <- "Jobs_sector1"
names(aggresult.df)[names(aggresult.df) == "SI02"] <- "Jobs_sector2"
names(aggresult.df)[names(aggresult.df) == "SI03"] <- "Jobs_sector3"

# Read City_Of_Dallas.csv and rename i..geoid column name to Given_CBGs
Dallas.df <- read.csv("City_of_Dallas.csv", stringsAsFactors = FALSE)
names(Dallas.df)[names(Dallas.df) == "ï..geoid"] <- "Given_CBGs"
# Since some CBGs are given with a and b, extract only the first 12 characters
Dallas.df$to_use_CBG <- substr(Dallas.df$Given_CBGs,1,12)
# Finding the unique CBG from the list
uniCBG <- unique(Dallas.df$to_use_CBG)

# Remove CBGs from LODES data which are not in Dallas_CBG
# Copy first to a fresh data frame
TXallaggCBG <- aggresult.df
cleaned_list <- TXallaggCBG[TXallaggCBG$Origin_Res_CBG %in% uniCBG,]

# Write the Cleaned Data to CleanedLodes.xlsx file
write.csv(cleaned_list, file = "CleanedLodes.csv", row.names = FALSE)

