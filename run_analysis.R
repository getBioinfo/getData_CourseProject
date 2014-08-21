## run_analysis.R that does the following. 
##   1. Merges the training and the test sets to create one data set.
##   2. Extracts only the measurements on the mean and standard deviation for each measurement. 
##   3. Uses descriptive activity names to name the activities in the data set
##   4. Appropriately labels the data set with descriptive variable names. 
##   5. Creates a second, independent tidy data set with the average of each variable for each activity and each subject. 


## download and unzip data
##   Function getData(url, dirname) takes url and directory name as input.
##     1. check whether directory exists, return its name if it exists
##     2. if directory doesn't exist, check whether the zipped data file exists
##     3. if zipped file exists, unzip it and return dirname
##     4. if zipped doesn't exist, download it from url and unzip the file and
##        return dirname

getData <- function(url = "https://d396qusza40orc.cloudfront.net/getdata/projectfiles/UCI%20HAR%20Dataset.zip", 
                    dirname = "UCI HAR Dataset") {
    # check whether directory exists
    if (file.exists(dirname)) {
        message("Data directory - '", dirname, "' exists")
        return(dirname)
    }
    
    # if directory doesn't exist, check whether the zip file exists
    zipFile = paste(dirname, '.zip', sep = "")
    if (file.exists(zipFile)) {
        message("Unzip file - '", zipFile, "'")
        unzip(zipFile)
        return(dirname)
    }
    
    # else download file and unzip it
    message("Download data file ...")
    download.file(url, destfile = zipFile, method = "curl", quiet = TRUE)
    message("Unzip file - '", zipFile, "'")
    unzip(zipFile)
    message("Data directory ready")
    return(dirname)
}

## prepare data
##   Function prepareData(dirname, dataset) transform data to tidy data set.
##     1. read activity_labels.txt for activity name
##     2. match activity name with activity files - y_test.txt or y_train.txt
##     3. read measurement files - X_test.txt or X_train.txt
##     4. read features.txt for variable names, use it to rename columns of
##        measurement data from previous step
##     5. combind subject, activity, with measurement:
##          subject_test.txt + y_test.txt + X_test.txt
##      OR  subject_train.txt + y_train.txt + X_train.txt
##     6. return data.frame

prepareData <- function(dirname = "UCI HAR Dataset", dataset = "test") {
    # read activity label file
    labelFile <- paste(dirname, '/activity_labels.txt', sep = "")
    labels <- read.table(labelFile)
    
    # read activity file
    actFile <- paste(dirname, '/', dataset, '/y_', dataset, '.txt', sep = "")
    acts <- read.table(actFile)
    
    # merge activity with label
    activities <- merge(acts, labels, by = "V1", sort = FALSE)
    activities$V1 <- NULL
    colnames(activities) <- c('activity')
    
    # read in measurements: X_test.txt or X_train.txt
    measureFile <- paste(dirname, '/', dataset, '/X_', dataset, '.txt', sep = "")
    measures <- read.table(measureFile)
    
    # read in features: features.txt
    featureFile <- paste(dirname, '/features.txt', sep = "")
    features <- read.table(featureFile)
    
    # replace measurement column names with features
    colnames(measures) <- features$V2
    
    # read in subjects
    subjectFile <- paste(dirname, '/', dataset, '/subject_', dataset, '.txt', sep = "")
    subjects <- read.table(subjectFile)
    colnames(subjects) <- c('subject')
    subjects$subject <- as.factor(subjects$subject)
    
    # combine subjects, activities, and measures
    dataset <- cbind(subjects, activities, measures)
}

## main program part
##   1. call function getData() to get data in directory
##   2. call function prepareData() to prepare test & train data sets
##   3. merge test & train data sets into one data set
##   4. subset data to choose only measurements of mean & std

# get data first
directory <- getData()

# prepare test data set
testData <- prepareData(dirname = directory, dataset = "test")
# prepare train data set
trainData <- prepareData(dirname = directory, dataset = "train")

# merge test & train data sets into one data set
allData <- rbind(testData, trainData)

# subset data to choose only measurements of mean & std
# Ref: http://r.789695.n4.nabble.com/Sub-setting-a-data-frame-by-partial-column-names-td1577672.html
#      http://stackoverflow.com/questions/24250878/selecting-multiple-columns-in-data-frame-using-partial-column-name
subData <- allData[ , grep("subject|activity|mean()|std()", colnames(allData))]
# save prepared sub data set in file
write.table(subData, file = "prepared_data.txt", row.name =FALSE)

## use function aggregate() to average each varible for each activity and subject 
aggrData <- aggregate(. ~ activity + subject, FUN=mean, data=subData)

## save above tidy data set in file
write.table(aggrData, file = "tidy_data.txt", row.name =FALSE)

