# -*- coding: utf-8 -*-
"""
Created on Tue Nov 16 18:31:14 2021
This script visualizes the pairing and hand chaining outputs by drawing the tracked
points on the video along with the unique hand ID that was assigned  as well as the paired hand ID
The ID itself should stay stable across frames for any given hand. The paired ID shows whether
the pairing was accurate
@author: jptru
"""
import os
from os import listdir
from os.path import isfile, join
import cv2
import pandas as pd
import time
import numpy as np

os.chdir("D:\data\MoCap\WPsCodeLibrary-master\Python\MediaPipeHandTracking_top_view")

#list all videos in mediafolder
mypath = "./MediaToAnalyze/"
onlyfiles = [f for f in listdir(mypath) if isfile(join(mypath, f))] # get all files that are in mediatoanalyze
#time series output folder
foldtime = "./Timeseries_Output/"


markers = ['WRIST', 'THUMB_CMC', 'THUMB_MCP', 'THUMB_IP', 'THUMB_TIP', 
 'INDEX_MCP', 'INDEX_PIP', 'INDEX_DIP', 'INDEX_TIP', 
 'MIDDLE_MCP', 'MIDDLE_PIP', 'MIDDLE_DIP','MIDDLE_TIP', 
 'RING_MCP', 'RING_TIP', 'RING_DIP', 'RING_TIP', 
 'PINKY_MCP', 'PINKY_PIP', 'PINKY_DIP', 'PINKY_TIP']

checkpoints = [0.2,0.4,0.6,0.8,1]

def output_progress(df_idx, len_df, checkpoints):
    if df_idx >= len_df and 1 in checkpoints:
        checkpoints.remove(1)
        print("done!")
    elif df_idx > len_df*0.8 and 0.8 in checkpoints:
        checkpoints.remove(0.8)
        print("80% complete")
    elif  df_idx > len_df*0.6 and 0.6 in checkpoints:
        checkpoints.remove(0.6)
        print("60% complete")
    elif  df_idx > len_df*0.4 and 0.4 in checkpoints:
        checkpoints.remove(0.4)
        print("40% complete")
    elif  df_idx > len_df*0.2 and 0.2 in checkpoints:
        checkpoints.remove(0.2)
        print("20% complete")


  #  net = cv2.dnn.readNetFromCaffe(protoFile, weightsFile)
for videofile in onlyfiles:
    checkpoints = [0.2,0.4,0.6,0.8,1]

    
    tracking_name = foldtime + videofile.split(".")[0] + "_paired.csv"
    tracking_file = pd.read_csv(tracking_name)
    #load in the video file
    cap = cv2.VideoCapture(mypath + videofile)
    hasFrame, frame = cap.read()
    # create an output file to see our visualized tracking
    output_filename = "./Videotracking_output_withIDs/" + videofile.split(".")[0] + "_paired.mp4"
    vid_writer = cv2.VideoWriter(output_filename,cv2.VideoWriter_fourcc('m','p','4','v'), 30, (frame.shape[1],frame.shape[0]))

    no_frames = max(tracking_file["index"])

    frame_no = 1
    while hasFrame:
        t = time.time()
        hasFrame, frame = cap.read() #grabs *next* frame
        frameCopy = np.copy(frame)
        if not hasFrame:
            cv2.waitKey()
            break
        # mediapipe scales x,y coordinates to a 0,1 range, so we need to recalculate the pixel coordinates
        frameWidth = frame.shape[1]
        frameHeight = frame.shape[0] 

        
        # get just the tracking data for this frame
        tracking_frame = tracking_file.loc[tracking_file["index"] == frame_no]
        for _,hand in tracking_frame.iterrows():
            # then we go through each joint/marker and add a circle, and an ID
            for marker in markers:
                x = int(hand["X_" + marker]*frameWidth)
                y = int(hand["Y_" + marker]*frameHeight)
                # we want to loop through each column and get the x,y coordinates of
                # any tracked hand 
                cv2.circle(frameCopy, (int(x), int(y)), 5, (0, 255, 255), thickness=-1, lineType=cv2.FILLED)
            # we want our IDs to be about the center horizontally,
            hand_cent_x = np.median([(hand["X_" + marker]*frameWidth) for marker in markers])
            # and just above all the points
            hand_cent_y = max([(hand["Y_" + marker]*frameHeight) for marker in markers]) + 10
            hand_text = str(hand["hand"][10]) + "  ID:" + str(hand["hand_ID"])+ "   pair: " + str(hand["paired_hand"])
            cv2.putText(frameCopy, hand_text, (int(hand_cent_x), int(hand_cent_y)), cv2.FONT_HERSHEY_SIMPLEX, 1.5, (0, 0, 255), 1, lineType=cv2.LINE_AA)
          
           
        cv2.imshow('Frame',frameCopy)    
        frame_no +=1
        vid_writer.write(frameCopy)
        output_progress(frame_no,no_frames, checkpoints)
        #if not 0.2 in checkpoints:
         #   break
    vid_writer.release()

        
        
        
        
        