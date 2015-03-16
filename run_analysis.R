# The purpose of this project is to demonstrate your ability to collect, work with, 
# and clean a data set. The goal is to prepare tidy data that can be used for later
# analysis. You will be graded by your peers on a series of yes/no questions related
# to the project. You will be required to submit: 1) a tidy data set as described 
# below, 2) a link to a Github repository with your script for performing the analysis,
# and 3) a code book that describes the variables, the data, and any transformations 
# or work that you performed to clean up the data called CodeBook.md. You should also 
# include a README.md in the repo with your scripts. This repo explains how all of 
# the scripts work and how they are connected.  

# One of the most exciting areas in all of data science right now is wearable computing
# - see for example this article . Companies like Fitbit, Nike, and Jawbone Up are 
# racing to develop the most advanced algorithms to attract new users. The data linked
# to from the course website represent data collected from the accelerometers from the
# Samsung Galaxy S smartphone. A full description is available at the site where the 
# data was obtained: 
    
# http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones 

# Here are the data for the project: 
    
# https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip 

# Clean up workspace
rm(list=ls())

library(dplyr)

# Downloading the file in the data folder
if(!file.exists("./data")){dir.create("./data")}
fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
if(!file.exists("./UCI\ HAR\ Dataset"))
{    
    download.file(fileUrl,destfile="./data/UCI-HAR-Dataset.zip")
}
    
# Unzip the file
unzip(zipfile="./data/UCI-HAR-Dataset.zip")

# Initialize the features, activity labels, train and test data files
dataset_dir <- "UCI\ HAR\ Dataset"
feature_file <- paste(dataset_dir, "/features.txt", sep = "")
activity_labels_file <- paste(dataset_dir, "/activity_labels.txt", sep = "")
x_train_file <- paste(dataset_dir, "/train/X_train.txt", sep = "")
y_train_file <- paste(dataset_dir, "/train/y_train.txt", sep = "")
subject_train_file <- paste(dataset_dir, "/train/subject_train.txt", sep = "")
x_test_file  <- paste(dataset_dir, "/test/X_test.txt", sep = "")
y_test_file  <- paste(dataset_dir, "/test/y_test.txt", sep = "")
subject_test_file <- paste(dataset_dir, "/test/subject_test.txt", sep = "")

# Load the features and activity labels data
features <- read.table(feature_file)
activity_labels <- read.table(activity_labels_file)

# Assigin column names to the imported activity labels
colnames(activity_labels) <- c('activityId','activityLabel')

# Load the training set, labels and subjects
x_train <- read.table(x_train_file) # Training set
y_train <- read.table(y_train_file) # Training labels 
subject_train <- read.table(subject_train_file) # Training Subjects

# Assigin column names to the imported training data
colnames(x_train) <- features[,2] 
colnames(y_train) <- "activityId"
colnames(subject_train) <- "subjectId"

# Create the final training set by merging y_train, subject_train, and x_train
trainingdata <- cbind(y_train, subject_train, x_train);

# Load the test set, labels and subjects
x_test <- read.table(x_test_file) # Test set
y_test <- read.table(y_test_file) # Test labels
subject_test <- read.table(subject_test_file) # Test Subjects

# Assign column names to the imported test data
colnames(x_test) <- features[,2]
colnames(y_test) <- "activityId"
colnames(subject_test) <- "subjectId"

# Create the final test set by merging the x_test, y_test and subject_test data
testdata <- cbind(y_test, subject_test, x_test)

# 1. Merges the training and the test sets to create one data set.

# Combine training and test data to create a final data set
combinedata <- rbind(trainingdata, testdata)
# write.table(combinedata, './traintestdata.csv', row.names=FALSE, sep=',')

# Create a vector for the column names from the final data, which will be used
# to select the desired mean() & stddev() columns
cdcolnames <- colnames(combinedata)

# 2. Extracts only the measurements on the mean and standard deviation for each measurement.

# Create a logical vector that contains TRUE values for the ID, mean() & stddev() columns and FALSE for others
data_mean_std <- (grepl("activityId", cdcolnames) | grepl("subjectId", cdcolnames) | grepl("mean", cdcolnames) | grepl("std", cdcolnames))

# Subset combine data table based on the logical vector to keep only desired columns
desiredata <- combinedata[data_mean_std == TRUE]
# write.table(desiredata, './meanstddata.csv', row.names=FALSE, sep=',')

# 3. Uses descriptive activity names to name the activities in the data set

# Merge the final data set with the acitivity label table to include descriptive activity names
finaldata <- merge(desiredata, activity_labels, by='activityId', all.x=TRUE)
# write.table(finaldata, './datawlabel.csv', row.names=FALSE, sep=',')

# Updating the final data column name vector to include the new column names after merge
fdcolnames <- colnames(finaldata)

# 4. Appropriately labels the data set with descriptive names.

# Cleaning up the variable names
for (i in 1:length(fdcolnames)) 
{
    fdcolnames[i] <- gsub("\\()", "", fdcolnames[i])
    fdcolnames[i] <- gsub("-std$", "StdDev", fdcolnames[i])
    fdcolnames[i] <- gsub("-mean", "Mean", fdcolnames[i])
    fdcolnames[i] <- gsub("^(t)", "time", fdcolnames[i])
    fdcolnames[i] <- gsub("^(f)", "freq", fdcolnames[i])
    fdcolnames[i] <- gsub("([Gg]ravity)", "Gravity", fdcolnames[i])
    fdcolnames[i] <- gsub("([Bb]ody[Bb]ody|[Bb]ody)", "Body", fdcolnames[i])
    fdcolnames[i] <- gsub("[Gg]yro", "Gyro", fdcolnames[i])
    fdcolnames[i] <- gsub("AccMag", "AccMagnitude", fdcolnames[i])
    fdcolnames[i] <- gsub("([Bb]odyaccjerkmag)", "BodyAccJerkMagnitude", fdcolnames[i])
    fdcolnames[i] <- gsub("JerkMag", "JerkMagnitude", fdcolnames[i])
    fdcolnames[i] <- gsub("GyroMag", "GyroMagnitude", fdcolnames[i])
};

# Reassigning the new descriptive column names to the final data set
colnames(finaldata) = fdcolnames;

# 5. From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.

# Create a new table without the activity label column
fdnoactlabel  = finaldata[,names(finaldata) != 'activityLabel']

# Summarizing the table to include just the mean of each variable for each activity and each subject
avgdata <- aggregate(fdnoactlabel[, names(fdnoactlabel) != c('activityId','subjectId')], by=list(activityId=fdnoactlabel$activityId, subjectId = fdnoactlabel$subjectId), mean)

# Merging the subjectavgdata with activity label to include descriptive acitvity names
avgdata <- merge(avgdata, activity_labels, by='activityId', all.x=TRUE)

# Sort by activity and subject
sortavgdata <- arrange(avgdata, activityId, subjectId)

# Re-arrange activity label next to activity ID
activitydata <- select(sortavgdata, activityId, activityLabel)
restofdata <- select (sortavgdata, -activityId, -activityLabel)
subjectavgdata <- cbind(activitydata, restofdata)

# Export the tidyData set 
write.table(subjectavgdata, './subjectavgdata.csv', row.names=FALSE, sep=',')
write.table(subjectavgdata, './subjectavgdata.txt', row.names=FALSE, sep='\t')

