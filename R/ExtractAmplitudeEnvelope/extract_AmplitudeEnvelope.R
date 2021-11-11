library(rPraat)
library(seewave)
library(signal)
library(rstudioapi)
library(dplR)

#author/questions?: Wim Pouw (wimpouw@gmail.com)

#CITATION OF TUTORIAL: 
#    Trujillo, J. P., & Pouw, W. (2019). Using video-based motion tracking to quantify speech-gesture synchrony.
#    Proceedings of the 6th meeting of Gesture and Speech in Interaction. Paderborn, Germany.

#CITATION OF CODE:
#    Pouw, W., Trujillo, J. P. (2019). Tutorial Gespin2019 - Using video-based motion tracking to quantify speech-gesture 
#     synchrony. doi: 10.17605/OSF.IO/RXB8J


#scripts
#this script can be dropped into a folder with wav's for which you need to generate smoothed amplitude envelope
#note that that the settings are now at 100Hz sampling rate, and a 5Hz smoothing Hanning Window as described by He & Dellwo (2017) (doi:https://doi.org/10.5167/uzh-136290)

    
#FOR TESTING
parentfolder <- (dirname(rstudioapi::getSourceEditorContext()$path))  #what is the current folder
data_to_process <- paste0(dirname(parentfolder), "/DATA_TO_PROCESS/") #This is the folder where your wav's are saved
                                                                      #you can set it to parentfolder if you dropped this R code in that folder

list_wavs <- list.files(data_to_process, pattern = ".wav")            #list of the wav's


#####################MAIN FUNCTION TO EXTRACT SMOOTHED ENVELOPE###############################
amplitude_envelope.extract <- function(locationsound, smoothingHz, resampledHz)
{
  snd <- snd.read(locationsound)                                #read the sound file into R
  hilb <- hilbert(snd$sig, f = snd$fs, fftw =FALSE)             #apply the hilbert on the signal
  env <- abs(hilb)                                              #apply modulus
  env_smoothed <- hanning(env, n =snd$fs/smoothingHz)           #smooth with a hanning window
  env_smoothed[is.na(env_smoothed)] <- 0                        #set undeterminable at beginning and end NA's to 0
  f <- approxfun(1:(snd$duration*snd$fs),env_smoothed)                       #resample settings at desired sampling rate
  downsampled <- f(seq(from=0,to=snd$duration*snd$fs,by=snd$fs/resampledHz))  #resample apply
  return(downsampled[!is.na(downsampled)])
}

########################APPLY MAIN FUNCTION ON THE SOUNDFILES#################################
for(wav in list_wavs)
  {
  locsound <- paste0(data_to_process, wav)                    #location of the current sound file in the loop
  env <-amplitude_envelope.extract(locsound, 5, 100)           #get the amplitude envelope at location, 5Hz Hanning, 100Hz sampling
  time_ms <- seq(1000/100, length(env)*(1000/100), by = 1000/100)     #make a time vector based on sampling rate (1000/Hz)
  ENV <- cbind.data.frame(time_ms, env)                                   #bind into data frame
  write.csv(ENV, file = paste0(paste0(data_to_process, "/", substr(wav, 1, nchar(wav)-4), "_ENV", ".csv")),row.names=FALSE) #save it to a folder
}
