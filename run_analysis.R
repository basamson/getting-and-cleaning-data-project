# This main script creates a function called run\_analysis(). It downloads the input zip file 
# into the current working directory (if it is not already present), loads the required data 
# into memory from inside the zip file, processes the data, and outputs two files (tidy.txt 
# and tidy2.txt) into the current working directory. During processing, it uses the reshape2 
# library, which it installs if needed.

# Outputs:
#   tidy.txt: contains the cleaned raw data whereby the mean and standard deviation features 
#             are listed for each subject and activity.
#   tidy2.txt: contains the average of each feature per subject and activity.

# Mean and standard deviation metrics are identified with mean() and -std() in their names.
# Note: measures like meanfreq() are not considered to be relevant, and are ignored.

# reshape2 library required for melt and dcast functions
if('reshape2' %in% installed.packages() == F){
        install.packages('reshape2')
}
library(reshape2)

run_analysis <- function(){

        target_url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
        target_localfile <- "UCI HAR Dataset.zip"
        
        # This function downloads the data and returns the resulting filename
        downloadData <- function(){
                target_localfile <- 'UCI HAR Dataset.zip'
                
                if (!file.exists("UCI HAR Dataset")) {
                        if (!file.exists("UCI HAR Dataset.zip")) {
                                print("Downloading dataset...")
                                download.file(target_url, target_localfile, method="auto")
                                library(tools)       # for md5 checksum
                                sink("download_metadata.txt")
                                print("Download date:")
                                print(Sys.time() )
                                print("Download URL:")
                                print(target_url)
                                print("Downloaded file Information")
                                print(file.info(target_localfile))
                                print("Downloaded file md5 Checksum")
                                print(md5sum(target_localfile))
                                sink()
                        }
                        
                }
                else
                        print("Using previously downloaded dataset")

                target_localfile
        }
        
        # This function loads the relevant data from the zip file into a list of data tables. 
        loadData <- function(file){

                print("Extracting individual data files into internal tables...")
                
                x_train <- read.table(unz(file, 'UCI HAR Dataset/train/X_train.txt'))
                x_test <- read.table(unz(file, 'UCI HAR Dataset/test/X_test.txt'))
                
                y_train <- read.table(unz(file, 'UCI HAR Dataset/train/y_train.txt'))
                y_test <- read.table(unz(file, 'UCI HAR Dataset/test/y_test.txt'))
                
                subject_train <- read.table(unz(file, 'UCI HAR Dataset/train/subject_train.txt'))
                subject_test <- read.table(unz(file, 'UCI HAR Dataset/test/subject_test.txt'))
                
                features <- read.table(unz(file, "UCI HAR Dataset/features.txt"), 
                                       header=F, colClasses="character")
                activities <- read.table(unz(file, "UCI HAR Dataset/activity_labels.txt"), 
                                         header=F, colClasses="character")
                
                #return a list enabling easy access.
                list(x_train = x_train, x_test = x_test, 
                     y_train = y_train, y_test = y_test, 
                     subject_train = subject_train, subject_test = subject_test,
                     features = features,
                     activities = activities)
        }
        
        # This return a list where the X, Y and S elements are merged using the respective 
        # 'train' and 'test' frames from the input.
        mergeData <- function(l) {
                
                print("Merging tables...")
                
                list(X = rbind(l$x_train, l$x_test), 
                     Y = rbind(l$y_train, l$y_test), 
                     S = rbind(l$subject_train, l$subject_test))
        }
        
        # This function returns the input dataset with only the relevant features.
        extract_mean_std_features = function(X, features) {

                print("Removing non-mean and non-standard deviation columns...")

                #only consider features with '-mean()' and '-std()'
                target_features <- grep("-mean\\(\\)|-std\\(\\)", features[, 2])
                
                #filter out unwanted features
                X <- X[, target_features]
                
                #'prettify' column names
                names(X) <- features[target_features, 2]
                names(X) <- gsub("\\(|\\)", "", names(X))
                names(X) <- tolower(names(X))
                
                #return filtered frame
                X
        }
        
        #This function replaces the activity indices with their textual names.
        apply_activity_names <- function(x, activities){

                print("Applying activity names to data...")
                
                activities[, 2] <- gsub("_", "", tolower(activities[, 2]))
                x[,1] <- activities[x[,1], 2]
                names(x) <- "activity"
                
                x
        }

        
        # MAIN PROCESSING

        print("BEGIN: Getting and cleaning dataset")
        
        # Download and load data
        f <- downloadData()
        d <- loadData(f)
        
        # 1: Merge into one dataset...Keeping X, Y, and S separate for now for easier column 
        #    naming. Will merge later. This is to maintain the suggested sequence of steps.
        m <- mergeData(d)
        
        # done with the data sets, but not the features.
        d <- d[-1:-6]
        
        # 2: Extract the mean and std features
        m$X <- extract_mean_std_features(m$X, d$features)
        
        # 3: Apply activity names
        m$Y <- apply_activity_names(m$Y, d$activities)
        
        # 4: Label the data set with descriptive variable names
        #    Much of this was already performed in step 2's function above.
        names(m$S) <- "subject"
        
        # Merge the columns into the tidy data frame.
        print("Storing tidy data set without aggregation...")
        tidy <- cbind(m$S, m$Y, m$X)
        
        # write out the csv file. A .txt extension is used to enable upload to Coursera.
        write.csv(tidy, "tidy.txt", row.names=F)
        
        # 5: Create a second, independent tidy data set with the average of each variable for
        #    each activity and each subject
        
        # melt the tidy data using the first two columns as id and the rest as values.
        melted <- melt(tidy, 1:2)
        
        # dcast the metlted data to get the average for each feature per subject per activity.
        print("Storing tidy data set after aggregation...")
        tidy2 <- dcast(melted, subject + activity ~ variable, mean)
        write.csv(tidy2, "tidy2.txt", row.names=F)
        
        print("COMPLETE: Getting and cleaning dataset")
}