import serial
 
port = "COM6"
baud = 115200
 
ser = serial.Serial(port, baud, timeout=1)
    # open the serial port
if ser.isOpen():
     print(ser.name + ' is open...')
 
while True:
    cmd = input("Enter command or 'exit':")
        # for Python 2
    # cmd = input("Enter command or 'exit':")
        # for Python 3
    if cmd == 'exit':
        ser.close()
        exit()
    else:
        ser.write((cmd+'\r\n').encode('utf-8'))
        out = ser.read()
        #print('Receiving...'+out)