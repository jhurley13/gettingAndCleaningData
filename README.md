# Final project for Getting and Cleaning Data

## Peer-graded Assignment: Getting and Cleaning Data Course Project

[This section copied from the course project page]  

One of the most exciting areas in all of data science right now is wearable computing - see for example this article . Companies like Fitbit, Nike, and Jawbone Up are racing to develop the most advanced algorithms to attract new users. The data linked to from the course website represent data collected from the accelerometers from the Samsung Galaxy S smartphone. A full description is available at the site where the data was obtained:

http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones

Here are the data for the project:

https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip

You should create one R script called run_analysis.R that does the following.

1. Merges the training and the test sets to create one data set.
2. Extracts only the measurements on the mean and standard deviation for each measurement.
3. Uses descriptive activity names to name the activities in the data set
4. Appropriately labels the data set with descriptive variable names.
5. From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.

## Review criteria

[This section copied from the course project page]  

1. The submitted data set is tidy.
2. The Github repo contains the required scripts.
3. GitHub contains a code book that modifies and updates the available codebooks with the data to indicate all the variables and summaries calculated, along with units, and any other relevant information.  
4. The README that explains the analysis files is clear and understandable.
5. The work submitted for this project is the work of the student who submitted it.

## Data Structure and Transformations

| R variable name | File | Dimensions (r,c) |
|-----------------|---------------------|-----------|
| subject_train   | subject_train.txt   | 7352    1 |
| subject_test    | subject_test.txt    | 7352    1 |
| X_train         | X_train.txt         | 7352  561 |
| X_test          | X_test.txt          | 7352  561 |
| y_train         | y_train.txt         | 7352    1 |
| y_test          | y_test.txt          | 7352    1 |
| activity_labels | activity_labels.txt |    6    2 |
| features        | features.txt        |  561    2 |

To collect this all into a single data.frame, we match up dimensions. X_test is added as new rows to X_train. "features" is used as the column names for this combined data. subject_train and subject_test are concatenated into one long column, which is added as column to the combined data. Similarly, y_train and y_test are concatenated into one long column, which is also added as column to the combined data. These two new columns are named "subject" and "activity".  

The "activity" column is stored in y_train and y_test as numeric values from 1 to 6, which are replaced by the corresponding text values from activity_labels.

One other technical transformation should be noted. Since the select method from dplyr can't handle dataframes whose columns don't have unique names, we need to remove columns with identical names. Normally this wouldn't work, but the dataset we need doesn't use any of these columns. It seems that many of the columns with "bandsEnergy" in the name are duplicates (after running run_analysis.R, "features[duplicated_features_l]" will show all duplicate column names).

## Files

README.md - this file  
README.html - this file run through knitr  
tidy_data.txt - The data frame created during step 5 above  
run_analysis.R - the R script used to analyze the data  
CodeBook.md - A code book describing the variables

## Notes for graders

### Descriptive names

The names described in "feature_info.txt" are terse but described well in that document. The prefix 't' denotes time domain signal; the prefix 't' indicates frequency domain signals.  

In Step 2, we make the column names slightly more readable by replacing mean() with MEAN and std() with STD.
The final step of creating the tidy_data is to adjust the column names by appendiing "-mean" to each data column name to indicate the transformation done with the melt/dcast.

### Tidiness

The data contained in the data.frame tidy_data and the file tidy_data.txt is tidy because:  
- Each variable forms a column
- Each observation forms a row
- Each table/file stores data about one kind of observation

### Loading the data

To load the save tidy-data, use this R code (thanks [Hood] for the suggestion)

    data <- read.table("./tidy_data.txt", header = TRUE)  
    View(data)  
    
## Data Origin

Data obtained from: http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones  
Data for the project: https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip  

## References

[Anguita et al] Davide Anguita, Alessandro Ghio, Luca Oneto, Xavier Parra and Jorge L. Reyes-Ortiz. Human Activity Recognition on Smartphones using a Multiclass Hardware-Friendly Support Vector Machine. International Workshop of Ambient Assisted Living (IWAAL 2012). Vitoria-Gasteiz, Spain. Dec 2012

[Hood] https://thoughtfulbloke.wordpress.com/2015/09/09/getting-and-cleaning-the-assignment/

## Author

John Hurley

