# encoding=utf-8
from time import time, sleep
from random import randint

import serial
import serial.tools.list_ports

from Crypto.Cipher import AES

WINV_INSTR = bytes([0x00])
WNK_INSTR  = bytes([0x10])
EX_INSTR   = bytes([0x20])
WPCT_INSTR = bytes([0x30])
RPCT_INSTR = bytes([0x40])
TEST_INSTR = bytes([0x50])

def aes_write(ser, instr, write_data, write_n = 1, send_n = False):
    #Send instr and check if instr is received
    ser.write(instr)
    rev = ser.read(1)
    if rev != instr:
        print(list(rev), list(instr))
        return False
    #Send n
    if send_n:
        ser.write(bytes([write_n]))
    #Send data and receive checksum to check
    ser.write(write_data)
    checksum = bytes([sum(write_data) & 0xFF])
    return ser.read(1) == checksum

def aes_read(ser, instr, read_n = 1, send_n = False):
    #Send instr and check if instr is received
    ser.write(instr);
    if ser.read(1) != instr:
        return False
    #Send n
    if send_n:
        ser.write(bytes([read_n]))
    #Receive data and check checksum
    data = ser.read(read_n)
    checksum = bytes([sum(data) & 0xFF])
    return ser.read(1) == checksum, data

def aes_setinv(ser, inv):
    return aes_write(ser, WINV_INSTR, bytes([inv]))

def aes_setnk(ser, nk):
    return aes_write(ser, WNK_INSTR, bytes([0 if nk == 4 else (1 if nk == 6 else 3)]))

def aes_expandkey(ser, key):
    return aes_write(ser, EX_INSTR, key, len(key), True)

def aes_setpct(ser, pcts):
    return aes_write(ser, WPCT_INSTR, pcts)

def aes_getpct(ser):
    return aes_read(ser, RPCT_INSTR, 128)

def aes_test(ser, type, times):
    data = [times&0xFF, (times>>8)&0xFF, (times>>16)&0xFF, (times>>24)&0xFF]
    return aes_write(ser, TEST_INSTR, bytes(data + [type]))

def print_bytes(bytes, end='\n'):
    for b in bytes:
        print("%02x"%(b), end='')
    print(end=end)

check_times = 100
compare_times = 2000

if __name__ == '__main__':
    #Print available comports
    port_list = list(serial.tools.list_ports.comports())
    if len(port_list) <= 0:
        print("No comport found!")
        exit()
    else:
        print("Available comports:")
        for port in port_list:
            print(list(port)[0], list(port)[1])

    #Chose a comport to communicate with aes 
    while True:
        ser_name = input('Please input com dev: ')
        try:
            ser = serial.Serial(ser_name, 115200)
        except:
            print('Comport %s no found'%ser_name)
            continue
        if ser.isOpen():
            print('Comport %s has been opened'%ser_name)
            break
        else:
            print('Comport %s hasnt been opened, please try again'%ser_name)

    #Clear buffer
    ser.reset_input_buffer()
    ser.reset_output_buffer()

    #Verify function of aes module
    check_sums = []
    correct_sums = []
    print('Function verification starts')
    for inv in [0, 1]:
        #Set inv mode
        while not aes_setinv(ser, inv): pass
        print('AES sets as ' + ('inv' if inv else '') + 'cipher mode')
        
        for nk in [4, 6, 8]:
            #Set nk
            while not aes_setnk(ser, nk): pass
            print('Nk sets as ' + str(nk))

            #Set and expand key
            key = bytes([randint(0, 255) for i in range(nk*4)])
            print('Key is ')
            print_bytes(key)
            while not aes_expandkey(ser, key): pass
            print('Key has been expanded')
            aes = AES.new(key, AES.MODE_ECB)

            #Stop for seconds
            sleep(1)

            check_sum = 0
            correct_sum = 0
            for try_times in range(check_times):
                #Set plain text or cipher ctext and get result
                in_pcts = bytes([randint(0, 255) for i in range(16*8)])
                while not aes_setpct(ser, in_pcts): pass
                valid = False
                while not valid:
                    valid, out_pcts = aes_getpct(ser)

                #Print result and compare with reference
                for pct_index in range(8):
                    in_pct = in_pcts[16*pct_index:16*(pct_index+1)]
                    out_pct = out_pcts[16*pct_index:16*(pct_index+1)]
                    
                    print('in_pct is ')
                    print_bytes(in_pct)
                    print('out_pct is ')
                    print_bytes(out_pct)

                    ac_out_pct = aes.decrypt(in_pct) if inv else aes.encrypt(in_pct)
                    print('ac_out_pct is ')
                    print_bytes(ac_out_pct)

                    if ac_out_pct == out_pct:
                        correct_sum += 1
                        print('Correct')
                    else:
                        print('Error')
                    check_sum += 1
            check_sums.append(check_sum)
            correct_sums.append(correct_sum)
    print('Function verification ends')

    #Performence of aes module compares with software
    intervals = []
    print('Performence comparsion starts')
    for type in range(9):
        t1 = time()
        while not aes_test(ser, type, compare_times): pass
        t2 = time()
        intervals.append(t2-t1)
    print('Performence comparsion ends')

    #Print report
    #Function verification
    print('|-------------Function Verification-------------|')
    print('| Inv | Nk | Correct Sum | Check Sum | Accuracy |')
    for i in range(6):
        print('|{:^5}|{:^4d}|{:^13d}|{:^11d}|{:^10.2%}|'.format('n' if i < 3 else 'y', i%3*2+4, \
                                                                correct_sums[i], check_sums[i], \
                                                                correct_sums[i]/check_sums[i]))
    #Performence comparsion
    print('|------------Performence  Comparsion------------|')
    print('|  Num of blocks  |{:^29d}|'.format(compare_times))
    print('|   Type   |   Num of blocks once   |  Time(s)  |')
    for i in range(9):
        print('|{:^10}|{:^24d}|{:^11.2f}|'.format('Softwave' if i == 0 else 'Hardwave', \
                                                  1 if i == 0 else i, intervals[i]))

    ser.close()
    if ser.isOpen():
        print('Comport %s hasnt been closed'%ser.name)
    else:
        print('Comport %s has been closed'%ser.name)
