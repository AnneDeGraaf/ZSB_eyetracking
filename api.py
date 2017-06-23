import matlab.engine

eng = matlab.engine.start_matlab()
eng.cd(r'D:\000Minor\ZoekenSturenBewegen\eyetracking_code')

cam = eng.initialize_cam()

# while gameover == false: 
# insert pong funtion here

# run the iris detection inside the pong program
eng.test_complete_script(0, cam)



