#questions: wimpouw@gmail.com

#What does this do?
You have a video that you want to clip into subpieces based on annotations in ELAN. This way
you can make smaller clips with relevant behavior. This script loops over the annotation files, links it up
with the relevant video, and then for each annotation, clips the video accordingly and saves it into your clipped folder.

###################################FOLDERING
ANNOTATIONS
This contains the annotations in csv format with columns begintime,endtime,annotation format as exported via ELAN.
Please note that the first 3 digits are a code that should be exactly the same as your video name.

#ELAN_EXAMPLE
Just an example of some ELAN codings

#OUTPUT_CLIPPED_VIDEOS
This will contain your clipped videos

#SCRIPT
This contains a jupyter notebook script.

#VIDEOS
Here are your videos (now an example video)

###################################Installation
install anaconda
open "anaconda prompt" (AP)
enter command AP: conda install pip
enter command AP: pip install --trusted-host pypi.python.org moviepy
enter command AP: pip install imageio-ffmpeg





