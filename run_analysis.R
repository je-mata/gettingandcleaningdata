#Course Project

#download data
if(!file.exists("./DataSets")){dir.create("./DataSets")}
URL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(URL,destfile="./DataSets/Data.zip",method="curl")

#Unzip Files
unzip(zipfile="./DataSets/Data.zip",exdir="./DataSets")

#View list of the files
DataFilesPath <- file.path("./DataSets" , "UCI HAR Dataset")
DataFiles <-list.files(DataFilesPath, recursive=TRUE)
DataFiles

## Files that we will merge are the following:
        # test/subject_test.txt
        # test/X_test.txt
        # test/y_test.txt
        # train/subject_train.txt
        # train/X_train.txt
        # train/y_train.txt

#Read and names data tables:

#Activity Data
ActivityTestData  <- 
        read.table(file.path(DataFilesPath, "test" , "Y_test.txt" ),header = FALSE)
ActivityTrainData <- 
        read.table(file.path(DataFilesPath, "train", "Y_train.txt"),header = FALSE)
#Subject Data
SubjectTrainData <- 
        read.table(file.path(DataFilesPath, "train", "subject_train.txt"),header = FALSE)
SubjectTestData  <- 
        read.table(file.path(DataFilesPath, "test" , "subject_test.txt"),header = FALSE)
#Features Data
FeaturesTestData  <- 
        read.table(file.path(DataFilesPath, "test" , "X_test.txt" ),header = FALSE)
FeaturesTrainData <- 
        read.table(file.path(DataFilesPath, "train", "X_train.txt"),header = FALSE)

#Merge data tables by rows
ActivityData<- rbind(ActivityTrainData, ActivityTestData)
SubjectData <- rbind(SubjectTrainData, SubjectTestData)
FeaturesData<- rbind(FeaturesTrainData, FeaturesTestData)

#Name variables
names(SubjectData)<-c("subject")
names(ActivityData)<- c("activity")
#Assign names in V2 column "features.txt" file to variables in FeatureData table
FeaturesNames <- read.table(file.path(DataFilesPath, "features.txt"),head=FALSE)
names(FeaturesData)<- FeaturesNames$V2

#Merge columns of three data sets
MergedData1 <- cbind(SubjectData, ActivityData)
MergedData <- cbind(MergedData1, FeaturesData)
#We have merged all the data sets :)

#Subset table with only Mean and Standard Deviation variables
ColsWanted <- FeaturesNames$V2[grep("mean\\(\\)|std\\(\\)", FeaturesNames$V2)]
selectedNames <- c("subject", "activity", as.character(ColsWanted))
Data <- subset(MergedData, select=selectedNames)

# Turn activity variable into factor and label to use descriptive activity names
# to name the activities in the data set
activityLabels <- read.table(file.path(DataFilesPath, "activity_labels.txt"),header = FALSE)
Data$activity <- factor(Data$activity, levels = activityLabels[,1], labels = activityLabels[,2])

#Label data with descriptive variable names
names(Data)<-gsub("^t", "time", names(Data))
names(Data)<-gsub("^f", "frequency", names(Data))
names(Data)<-gsub("Acc", "Accelerometer", names(Data))
names(Data)<-gsub("Gyro", "Gyroscope", names(Data))
names(Data)<-gsub("Mag", "Magnitude", names(Data))
names(Data)<-gsub("BodyBody", "Body", names(Data))

#Create a second, independent tidy data set 
#with the average of each variable for each activity and each subject.
library(plyr);
TidyData<-aggregate(. ~subject + activity, Data, mean)
TidyData<-TidyData[order(TidyData$subject,TidyData$activity),]
write.table(TidyData, file = "tidydata.txt",row.name=FALSE)



