%This function initialises an Android phone cam as a webcam
%using DroidcamX Pro-Software. Zoom has to be set to max-value, 
%manually.

function videoDevice = initialize_android_cam()
    videoDevice = imaq.VideoDevice('winvideo', 2);
    release(videoDevice);
    videoDevice.ReturnedDataType = 'uint8';
end