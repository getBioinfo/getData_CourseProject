Course Project Code Book
========================

This code book explains how R script, `run_analysis.R`, does the course project assignment:

  1. Merges the training and the test sets to create one data set.
  2. Extracts only the measurements on the mean and standard deviation for each measurement. 
  3. Uses descriptive activity names to name the activities in the data set.
  4. Appropriately labels the data set with descriptive variable names. 
  5. Creates a second, independent tidy data set with the average of each variable for each activity and each subject. 


### Get Data

Getting data is done by function `getData(url, dirname)`. The function has two inputs:

* **url**: the URL of data file. The default value is `https://d396qusza40orc.cloudfront.net/getdata/projectfiles/UCI%20HAR%20Dataset.zip`.
* **dirname**: the directory name of the data files after they are unzipped. The default value is `UCI HAR Dataset`

The `getData(url, dirname)` function does the following steps:

  1. Check whether directory exists, return its name if it exists.
  2. If directory doesn't exist, check whether the zipped data file exists.
  3. If zipped file exists, unzip it and return dirname.
  4. If zipped doesn't exist, download it from url and unzip the file and return dirname.
  
The final output of `getData(url, dirname)` function is zipped data file and unzipped data directory under current work directory.


### Prepare Data

Preparing data is done by function `prepareData(dirname, dataset)`. The function has two inputs:

* **dirname**: the directory name of the data files after they are unzipped. The default value is `UCI HAR Dataset`
* **dataset**: the name of the two data sets: `test` or `train`. The default value is `test`

The function `prepareData(dirname, dataset)` does following steps:

  1. Read *activity_labels.txt* for activity name (variable: data frame `labels`).
  2. Match activity name with activity (variable: vector `activities`) files - *y_test.txt* or *y_train.txt*.
  3. Read measurement (variable: data frame `measures`) files - *X_test.txt* or *X_train.txt*.
  4. Read features.txt for variable names (variable: data frame `measures`), use it to rename columns of measurement data from previous step.
  5. Use `cbind` to combind subject (variable: vector `subjects`), activity (variable: vector `activities`), with measurement (variable: data frame `measures`): *subject_test.txt* + *y_test.txt* + *X_test.txt* OR *subject_train.txt* + *y_train.txt* + *X_train.txt*.
  6. Return merged test and train data as one data set (variable: data frame `dataset`).
  

### Main Program Section

The main program part does following steps:

  1. Call function `getData()` get data first.
  2. Call function `prepareData(dirname = directory, dataset = "test")` to prepare test data set (variable: data frame `testData`).
  3. Call function `prepareData(dirname = directory, dataset = "train")` to prepare train data set (variable: data frame `trainData`).
  4. Use `rbind` to merge test data (variable: data frame `testData`) and train data (variable: data frame `trainData`) into one data set (variable: data frame `allData`).
  5. Use `subset` to select columns: *subject*, *activity*, and measurements related to **mean()** and **std()**. And save data into file `prepared_data.txt`.
  6. Use function `aggregate` to average each varible for each activity and subject. And save data into file `tidy_data.txt`. 
  
