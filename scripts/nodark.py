import os
# Need to install xset program for this to work correctly
file=open('count.dat','r')

value=file.readline()
print(value)
file.close()
if int(value) ==  1:
    file2=open('count.dat','w')
    file2.write("0")
    os.system('xset s noblank')
    file2.close()
    os.system('echo noblank')
    #os.system('trayer')
if int(value) == 0: 
    file2=open('count.dat','w')
    file2.write("1")
    os.system('xset s blank')
    file2.close()
    os.system('echo blank')
    #os.system('pkill trayer')

