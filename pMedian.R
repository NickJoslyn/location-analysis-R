#Read-In Files

DemandNamesReadIn <- read.csv("CityClass_Names_CSV.csv", header = FALSE)
DemandNames <- as.matrix(DemandNamesReadIn)

DemandNumbersReadIn <- read.table("DS_CityClass_Numbers_Text.txt")
DemandNumbers <- as.matrix(DemandNumbersReadIn)

SupplyStringReadIn <- read.csv("AHA_String_Class_CSV.csv", header = FALSE)
SupplyClassString <- as.matrix(SupplyStringReadIn)

SupplyNumberReadIn <- read.table("AHA_Numbers_Class_Text.txt")
SupplyClassNumber <- as.matrix(SupplyNumberReadIn)

DistanceMatrixReadIn <- read.table("FinalDistanceMatrix_Text.txt")
DistanceMatrix <- as.matrix(DistanceMatrixReadIn)

#--------------------------------------------------------------
#Initialize important parameters

numberOptimized <- 8

totalDistance <- 0
optimalLocations <- c()

numberOfSupplyNodes <- length(SupplyClassNumber[,1])
numberOfDemandNodes <- length(DemandNumbers[,1])

#--------------------------------------------------------------
#Start Timer
ptm <- proc.time()

#Find initial solution

solutionMatrix <- matrix(ncol = numberOptimized, nrow = numberOfDemandNodes)
demandDistances <- c()

#Choose first p clinics as initial solution
for (i in 1:numberOptimized)
{
  optimalLocations[i] <- SupplyClassNumber[i,3]
}

#Extract corresponding columns from the distance matrix
for (i in 1:numberOptimized)
{
  solutionMatrix[,i] <- DistanceMatrix[,optimalLocations[i]] 
}

#Determine which clinic a city will go to
for (i in 1:numberOfDemandNodes)
{
  closestSupplyLocation <- min(solutionMatrix[i,])
  demandDistances[i] <- (closestSupplyLocation * DemandNumbers[i,1])
}

#Calculate the total distance
for (i in 1:numberOfDemandNodes)
{
  totalDistance <- totalDistance + demandDistances[i]
}

#--------------------------------------------------------------
#While loop for vertex substitutions until convergence

whileCounter <- 0
while(whileCounter < (numberOptimized*numberOfSupplyNodes))
{
  #Initialize/re-initialize
  solutionMatrixTest <- matrix(ncol = numberOptimized, nrow = numberOfDemandNodes)
  demandDistancesTest <- c()
  totalDistanceTest <- 0
  whileCounter <- 0
  
  #Begin vertex substitutions
  for (i in 1:numberOptimized)
  {
    for (j in 1:numberOfSupplyNodes)
    {
      temporaryLocations <- optimalLocations
      temporaryLocations[i] <- SupplyClassNumber[j,3]
      
      #Same steps to calculate totalDistance, this time with temporaryLocations
      for (k in 1:numberOptimized)
      {
        solutionMatrixTest[,k] <- DistanceMatrix[,temporaryLocations[k]] 
      }
      
      for (m in 1:numberOfDemandNodes)
      {
        closestSupplyLocationTest <- min(solutionMatrixTest[m,])
        demandDistancesTest[m] <- (closestSupplyLocationTest * DemandNumbers[m,1])
      }
      
      for (n in 1:numberOfDemandNodes)
      {
        totalDistanceTest <- totalDistanceTest + demandDistancesTest[n]
      }
      
      #Add to whileCounter if there is no improvement from a substitution
      if (totalDistanceTest >= totalDistance)
      {
        whileCounter <- whileCounter + 1
      }
      
      #If there is improvement, complete the substitution
      if (totalDistanceTest < totalDistance)
      {
        totalDistance <- totalDistanceTest
        optimalLocations[i] <- SupplyClassNumber[j,3]
      }
      
      totalDistanceTest <- 0
      solutionMatrixTest <- matrix(ncol = numberOptimized, nrow = numberOfDemandNodes)
      demandDistancesTest <- c()
    }
  }
}
totalDistance
optimalLocations

proc.time()-ptm
