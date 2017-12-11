library(reshape2)

filename <- "getdata_dataset.zip"

## Download the data and unzip, checking for existing files.

if (!file.exists(filename)){
  fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip "
  download.file(fileURL, filename, method="curl")
}  
if (!file.exists("UCI HAR Dataset")) { 
  unzip(filename) 
}

# Read labels and features and make sure its char data.

activity_labels <- read.table("UCI HAR Dataset/activity_labels.txt")
activity_labels[,2] <- as.character(activity_labels[,2])
features <- read.table("UCI\ HAR\ Dataset/features.txt")
features[,2] <- as.character(features[,2])

# Extract only the measurements on the mean 
# and standard deviation for each measurement.

features_extract <- grep(".*mean.*|.*std.*", features[,2])
features_extract.names <- features[features_extract,2]
features_extract.names = gsub('-mean', 'Mean', features_extract.names)
features_extract.names = gsub('-std', 'Std', features_extract.names)
features_extract.names <- gsub('[-()]', '', features_extract.names)

# Merge the training and the test sets to create one data set.

train <- read.table("UCI HAR Dataset/train/X_train.txt")[features_extract]
train_activities <- read.table("UCI HAR Dataset/train/Y_train.txt")
train_subjects <- read.table("UCI HAR Dataset/train/subject_train.txt")
train <- cbind(train_subjects, train_activities, train)

test <- read.table("UCI HAR Dataset/test/X_test.txt")[features_extract]
test_activities <- read.table("UCI HAR Dataset/test/Y_test.txt")
test_subjects <- read.table("UCI HAR Dataset/test/subject_test.txt")
test <- cbind(test_subjects, test_activities, test)

# Use descriptive activity names to name the activities in the data set

data_merge <- rbind(train, test)
colnames(data_merge) <- c("subject", "activity", features_extract.names)

# Appropriately label the data set with descriptive variable names.

data_merge$activity <- factor(data_merge$activity, levels = activity_labels[,1], labels = activity_labels[,2])
data_merge$subject <- as.factor(data_merge$subject)

data_merge.melted <- melt(data_merge, id = c("subject", "activity"))
data_merge.mean <- dcast(data_merge.melted, subject + activity ~ variable, mean)

# From the data set in step 4, create a second, independent tidy data set 
# with the average of each variable for each activity and each subject.

write.table(data_merge.mean, "tidy_dataset.txt", row.names = FALSE, quote = FALSE)