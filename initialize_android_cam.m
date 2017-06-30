%This function initialises an Android phone cam as a webcam
%using DroidcamX Pro-Software. Zoom has to be set to max-value, 
%manually.

function cam = initialize_android_cam()
    cam = webcam(2)
end
