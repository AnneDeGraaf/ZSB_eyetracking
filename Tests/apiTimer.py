import matlab.engine
import timeit
import matplotlib.pyplot as plt

eng = matlab.engine.start_matlab()
eng.cd(r'D:\000Minor\ZoekenSturenBewegen\eyetracking_code')

cam = eng.initialize_cam()
time_list = []

for n in range(50):

	t0 = timeit.default_timer()
	eng.test_complete_script(0, cam)
	t1 = timeit.default_timer()
	time_list.append(t1-t0)

plt.plot(time_list, color='k')
plt.xlabel('iterations n')
plt.ylabel('time in seconds')
plt.title('Runtime python API matlab')
plt.show();