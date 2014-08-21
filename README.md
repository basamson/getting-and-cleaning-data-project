cleaning-data
=============

This is the course project for the "Getting and Cleaning Data" course at Coursera. 

##The Project
run\_analysis.R is the main script, which creates a function called run\_analysis(). It downloads the input zip file into the current working directory (if it is not already present), loads the required data into memory from inside the zip file, processes the data, and outputs two files (tidy.txt and tidy2.txt) into the current working directory. During processing, it uses the reshape2 library, which it installs if needed.

## Original Data:

- [source](https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip) 
- [description](http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones)

##Running the script
- Load the script run\_analysis.R
- Call the function run\_analysis()
- The output is two files tidy.txt and tidy2.txt
- The codebook can be found [here](https://github.com/ashic/cleaning-data/blob/master/CodeBook.md).

##Output
The files are stored in comma-delimited format, and can be loaded into data frames with read.csv. They are output to the current working directory.

###tidy.txt
This file contains the input data filtered to mean and standard deviation measures, and listed along with the relevant subject and activity name. 

###tidy2.txt
This file contains the average of each measure for each activity and each subject present in the input.

##Assumptions
- The script must have access to the internet to download the input zip file (unless it is already present in the current working directory).
- For each dataset:
        - Measurements for X are in the X_train.txt and X_test.txt files.
	- Measurements for Y are in the y_train.txt and y_test.txt files.
	- Measurements for S are in the subject_train.txt and subject_test.txt files.
- Activity codes and their labels are in a file named activity_labels.txt, and Y initially holds indices to these labels.
- A file called features.txt hold an ordered list of labels for each measurement in X. The columns in X correspond to the ordering in this file.
- Only columns representing mean and standard deviation are considered. Measurements are considered to be a mean or standard deviation measurement if they have "-mean()" or "-std()" in their names. Other measurements are ignored, and this includes features like "meanFreq".
