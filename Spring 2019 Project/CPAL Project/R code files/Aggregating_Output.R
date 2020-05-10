library("xlsx")
library("readxl")
library("sqldf")

# Read csv segregated for 30min car output only
LT30min_Car <- read_xlsx("All_LT30_Car.xlsx")

# Read csv segregated for 60min car output only
LT60min_Car <- read_xlsx("All_LT60_Car.xlsx")

# Read input to OTP
inputfile <- read.csv("CleanedLodeswithcentroid.csv", stringsAsFactors = FALSE)

colnames(Totaljobs)
names(inputfile)[names(inputfile) == "ï..Origin_Res_CBG"] <- "Origin_Res_CBG"
#Aggregate Job Count w.r.t Origin_CBG
LT30min <- aggregate(LT30min_Car[,c(-1,-2,-3,-14,-15,-16,-17)], by = list(LT30min_Car$Origin_Res_CBG), FUN = sum)
LT60min <- aggregate(LT60min_Car[,c(-1,-2,-3,-14,-15,-16,-17)], by = list(LT60min_Car$Origin_Res_CBG), FUN = sum)
Totaljobs <- aggregate(inputfile[,c(-1,-2,-13,-14)], by = list(inputfile$Origin_Res_CBG), FUN = sum)

names(LT30min)[names(LT30min) == "Group.1"] <- "Origin_Res_CBG"
names(LT60min)[names(LT60min) == "Group.1"] <- "Origin_Res_CBG"
names(Totaljobs)[names(Totaljobs) == "Group.1"] <- "Origin_Res_CBG"

LT30min$Jobs_WageLT3333 <- LT30min$Jobs_WageLT1250 + LT30min$Jobs_Wage1251to3333
LT60min$Jobs_WageLT3333 <- LT60min$Jobs_WageLT1250 + LT60min$Jobs_Wage1251to3333
Totaljobs$Jobs_WageLT3333 <- Totaljobs$Jobs_WageLT1250 + Totaljobs$Jobs_Wage1251to3333

write.xlsx(LT30min, file = "LT30min.xlsx", row.names = FALSE)
write.xlsx(LT60min, file = "LT60min.xlsx", row.names = FALSE)
write.xlsx(Totaljobs, file = "Totaljobs.xlsx", row.names = FALSE)


forjobs <- read_xlsx("OTP_Output_car-Processing.xlsx")
colnames(forjobs)
aggdest <- aggregate(forjobs[,c(-1,-2,-3, -14,-15,-16,-17,-18,-19)], by = list(forjobs$Dest_Wrk_CBG), FUN = sum)
write.xlsx(aggdest, file="destaggre.xlsx")
