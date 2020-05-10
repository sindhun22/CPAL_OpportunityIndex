#CPAL Group 4
#Team Members - Arpit Agarwal, Arpit Chaukiyal, Devendra Sawant & Tarun Goyal
#University of Texas at Dallas

from org.opentripplanner.scripting.api import *
from org.opentripplanner.scripting.api import OtpsEntryPoint

### arpit router = otp.getRouter("current")

# Instantiate an OtpsEntryPoint
otp = OtpsEntryPoint.fromArgs(['--graphs', 'graphs','--router', 'current'])
# Start timing the code
import time
start_time = time.time()

# Get the default router
router = otp.getRouter('current')

# Read Points of Destination - The file points.csv contains the columns geoid, Centx and Centy.

points = otp.loadCSVPopulation('points.csv', 'Centy', 'Centx')

dests = otp.loadCSVPopulation('points.csv', 'Centy', 'Centx')
# Create a default request for a given time
# Arpit-- for h in range(0, 24):

for h in range(8, 9):
	for m in range(0,60,30): # Loop every 30 minutes
		# Create a default request for a given time
		req = otp.createRequest()
		#req1 = otp.createRequest()
		
		req.setDateTime(2018, 11, 1, h, m, 00) # set departure time
		#req1.setDateTime(2018, 11, 1, h, m, 00) # set departure time
		
		req.setMaxTimeSec(3600)  #setting the time for the 30 min
		#req1.setMaxTimeSec(1800) #setting the time for the 30 min
		
		req.setModes('WALK,BUS,RAIL') # define transport mode
		#req1.setModes('CAR') # define transport mode for cars only
		
		#print("checkpoint1")
		# Create a CSV output
		matrixCsv = otp.createCSVOutput()
		matrixCsv.setHeader([ 'year','depart_time', 'origin', 'destination','travel_time' ])
		
		# Create a CSV output
		#print("checkpoint2")
		#matrixCsv1 = otp.createCSVOutput()
		#matrixCsv1.setHeader([ 'year','depart_time', 'origin', 'destination','travel_time' ])
		#print("checkpoint3")
		## Arpit
		for origin in points:
			loop_time = time.time()
			print "Processing origin: ", str(h)+"-"+str(m)," ", origin
			req.setOrigin(origin)
			#req1.setOrigin(origin)
			
			spt = router.plan(req)
			#spt1 = router.plan(req1)
	
			counter  = 0 
			#counter1 = 0
			if spt is None:
				counter  = 1
			#if spt1 is None:
			#	counter1 = 1
			
			# Evaluate the SPT for all points
			if counter == 0:
				result = spt.eval(dests)
				
				# Add a new row of result in the CSV output
				for r in result:
					matrixCsv.addRow([ 2018, str(h) + ":" + str(m) + ":00", origin.getStringData('geoid'), r.getIndividual().getStringData('geoid'), r.getTime()])
					# Save the result
					matrixCsv.save('traveltime_matrix_60min_transit'+ str(h)+"-"+str(m) + '.csv')
			
			#if counter1 == 0:
			#	result1 = spt1.eval(dests)
				# Add a new row of result in the CSV output
			#	for r in result1:
			#		matrixCsv1.addRow([ 2018, str(h) + ":" + str(m) + ":00", origin.getStringData('geoid'), r.getIndividual().getStringData('geoid'), r.getTime()])
					# Save the result
			#		matrixCsv1.save('traveltime_matrix_car'+ str(h)+"-"+str(m) + '.csv')
				
			print("Elapsed time was %g seconds" % (time.time() - loop_time))

# Stop timing the code
print("Total elapsed time was %g seconds" % (time.time() - start_time))
