#
# Final project for Getting and Cleaning Data
#
#   Data obtained from:
#       http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones
#
#   Data for the project:
#       https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip

library(dplyr)
library(reshape2)

# ------------------------------------------------------------------------
# You should create one R script called run_analysis.R that does the following. 
# 1.  Merges the training and the test sets to create one data set.
# 2.  Extracts only the measurements on the mean and standard deviation for each measurement. 
# 3.  Uses descriptive activity names to name the activities in the data set
# 4.  Appropriately labels the data set with descriptive variable names. 
# 5.  From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.
# ------------------------------------------------------------------------

#------------------------------------------------------------------------
#   Get the data
#------------------------------------------------------------------------

download.file("https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip","UCI-HAR-Dataset.zip",method="curl")
downloadtime=date()
print(downloadtime)

unzip("UCI-HAR-Dataset.zip", overwrite=TRUE)
file.rename("UCI HAR Dataset","UCI-HAR-Dataset")

#------------------------------------------------------------------------
#   Load into R
#------------------------------------------------------------------------

dir_project <- "./UCI-HAR-Dataset"
dir_train <- "train"
dir_test <- "test"

fname_activity_labels <- "activity_labels.txt"
fname_features <- "features.txt"

# In the "test" directory
fname_subject_test <- "subject_test.txt"
fname_X_test <- "X_test.txt"
fname_y_test <- "y_test.txt"

# In the "train" directory
fname_subject_train <- "subject_train.txt"
fname_X_train <- "X_train.txt"
fname_y_train <- "y_train.txt"

read_data <- function(fname, subdir = NULL) {
    read.table(paste(dir_project, subdir, fname, sep = "/"), header  = FALSE, sep = "", as.is = TRUE)
}

subject_train <- read_data(fname_subject_train, dir_train)
X_train <- read_data(fname_X_train, dir_train)
y_train <- read_data(fname_y_train, dir_train)

subject_test <- read_data(fname_subject_test, dir_test)
X_test <- read_data(fname_X_test, dir_test)
y_test <- read_data(fname_y_test, dir_test)

#------------------------------------------------------------------------
# 1.    Merge the training and the test sets to create one data set. 
#------------------------------------------------------------------------
train_plus_test <- rbind(X_train, X_test)

#------------------------------------------------------------------------
# 2.    Extract only the measurements on the mean and standard deviation for each measurement.
#------------------------------------------------------------------------

# Note that the colnames for both X_test and X_train are the same
# Both features.txt and activity_labels.txt have 2 columns: row number and name
# We only need the names themselves
activity_labels <- read_data(fname_activity_labels)$V2
features <- read_data(fname_features)$V2

# Since the select method from dplyr can't handle dataframes whose columns don't have unique names,
# we need to remove columns with identical names. Normally this wouldn't work, but the dataset we
# need doesn't use any of these columns

# Logical vector of duplicated features
duplicated_features_l <- duplicated(features)

losing_needed_column <- length(grep("(mean|std)\\(", features[duplicated(features)])) > 0

colnames(train_plus_test) <- features

non_dup_features <- features[!duplicated_features_l]
non_dup_train_plus_test <- train_plus_test[, !duplicated_features_l]

colnames(non_dup_train_plus_test) <- non_dup_features

# Pick a subset of the columns with mean and std deviation
# This leaves in any measurement with e.g. "mean()" in the name but omits e.g. gravityMean or meanFreq

column_subset <- non_dup_features[grepl("(mean|std)\\(", non_dup_features)]

train_plus_test_subset <- select(non_dup_train_plus_test, column_subset)

# Make the column names slightly more readable by replacing mean() with MEAN and std() with STD

column_subset <- column_subset %>%
    gsub("mean\\(\\)", "MEAN", .) %>%
    gsub("std\\(\\)", "STD", .)

colnames(train_plus_test_subset) <- column_subset

#------------------------------------------------------------------------
# 3.    Use descriptive activity names to name the activities in the data set
#------------------------------------------------------------------------

# Replace numeric values of activity with text values from activity_labels
activity_labels.factor <- factor(activity_labels)
y_train_labelled <- sapply(y_train$V1, function(x) activity_labels.factor[x])
y_test_labelled <- sapply(y_test$V1, function(x) activity_labels.factor[x])

# Add the subject and activity data as new columns to train_plus_test
datax <- cbind(train_plus_test_subset, c(subject_train$V1, subject_test$V1), c(y_train_labelled, y_test_labelled))

#------------------------------------------------------------------------
# 4.    Appropriately label the data set with descriptive variable names.
#------------------------------------------------------------------------

# Add on the Subject and Activity columns
colnames(datax) <- c(column_subset, "subject", "activity")

#------------------------------------------------------------------------
# 5.    From the data set in step 4, create a second, independent tidy data set 
#       with the average of each variable for each activity and each subject.
#------------------------------------------------------------------------

id_labels   = c("subject", "activity")
melt_data      = melt(datax, id = id_labels, measure.vars = column_subset)
# Use the dcast function to apply the mean function to the data
tidy_data   = dcast(melt_data, subject + activity ~ variable, mean)

# Append "-mean" to each data column name to indicate the transformation
colnames(tidy_data) <- c(id_labels, paste0(column_subset, "-mean"))

write.table(tidy_data, file = "./tidy_data.txt")
