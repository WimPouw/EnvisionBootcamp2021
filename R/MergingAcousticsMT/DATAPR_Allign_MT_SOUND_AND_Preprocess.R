library(zoo)    #functions for time series functions (e.g., NA.approx)
library(dplyr)  #data gathering and formatting functions
library(signal) #package for smoothing function
library(ggplot2)
library(plotly)

#author/questions?: Wim Pouw (wimpouw@gmail.com)

#CITATION OF TUTORIAL: 
#    Trujillo, J. P., & Pouw, W. (2019). Using video-based motion tracking to quantify speech-gesture synchrony.
#    Proceedings of the 6th meeting of Gesture and Speech in Interaction. Paderborn, Germany.

#CITATION OF CODE:
#    Pouw, W., Trujillo, J. P. (2019). Tutorial Gespin2019 - Using video-based motion tracking to quantify speech-gesture 
#     synchrony. doi: 10.17605/OSF.IO/RXB8J

############################################CUSTOM FUNCTIONS
#FUNCTION for kolmogorov-Zurbenko filter 

#FUNCTION for applying butterworth filter low pass filter at 33Hz
#butter.it <- function(x)
#{bf <- butter(1, 100/33, type="low")
#x <- as.numeric(signal::filtfilt(bf, x))}

#FUNCTION FOR GETTING SPEED VECTOR per 1000ms time
speedXY.it <- function(x, y, time_millisecond)
{
  speed <- c(0, sqrt( rowSums( cbind(diff(x)^2, diff(y)^2)) ))
  speed <<- speed/(c(0, diff(time_millisecond)/1000))
}
############################################################


#FOLDER LOCATIONS
parentfolder <- (dirname(rstudioapi::getSourceEditorContext()$path))  #what is the current folder
data_to_process <- paste0(dirname(parentfolder), "/DATA_TO_PROCESS/") #get the folder for MT and SOUND data

#LOAD IN FILES
MT <-  read.csv(paste0(data_to_process, "VIDEO_GESTURES_MT.csv"))
ENV <- read.csv(paste0(data_to_process, "AUDIO_GESTURES_ENV.csv"))


##############ALLIGN AND INTERPOLATE
#ALLIGN FILES
merged <- merge(MT, ENV, by.x = "time_ms", by.y = "time_ms", all = TRUE)
merged <- select(merged,time_ms, env,x_index_right, y_index_right)

#interpolate data using na.approx()
merged$x_index_right <- na.approx(merged$x_index_right, x= merged$time_ms, na.rm = FALSE)
merged$y_index_right <- na.approx(merged$y_index_right, x= merged$time_ms, na.rm = FALSE)
  #trim
merged <- merged[!is.na(merged$env),]   #keep only sampling at speech observation   
merged <- na.trim(merged)               #trim outer values that could not be interpolated

##############PRE-PROCESS
  #calculate x,y unsmoothed speed sqrt((x1-xn)^2 +(y1-yn)^2)
merged$speed_UNsmooth <- speedXY.it(merged$x_index_right, merged$y_index_right, merged$time_ms)
  
  #HOWEVER WE ALWAYS WANT TO APPLY SMOOTHING FIRST (before calculating speed)
merged$x_index_right_S <- butter.it(merged$x_index_right)
merged$y_index_right_S <- butter.it(merged$y_index_right)
#now we calculate speed of the smoothed coordinate vectors
merged$speed <- speedXY.it(merged$x_index_right_S, merged$y_index_right_S, merged$time_ms)
merged$speed <- c(0, butter.it(merged$speed[is.finite(merged$speed)])) #now apply smoothing once more

#how do the two compare?
CompUns <- ggplot(merged, aes(x = time_ms, y = speed_UNsmooth)) + geom_line(color = "darkred") + theme_bw() + ylab("unsmoothed (px/s)") + xlim(500,25000) + ylim(0,750)
CompS <- ggplot(merged, aes(x = time_ms, y = speed)) + geom_line(color = "blue") + theme_bw()+ ylab("smoothed (px/s)") + xlim(500,25000)+ ylim(0,750)
subplot(ggplotly(CompUns), ggplotly(CompS), nrows=2,titleY = TRUE)

#write to data_to_process for next steps
write.csv(merged, paste0(data_to_process, "merged_GS.csv"))


