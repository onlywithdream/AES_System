#!/usr/bin/env python3
#
# This is free and unencumbered software released into the public domain.
#
# Anyone is free to copy, modify, publish, use, compile, sell, or
# distribute this software, either in source code form or as a compiled
# binary, for any purpose, commercial or non-commercial, and by any
# means.

from sys import argv

nwords = int(argv[1])
boot_type = argv[2]
binfile = argv[3]
hexfileprefix = argv[4]

with open(binfile, 'rb') as binf:
    bindata = binf.read()

assert len(bindata) < 4*nwords
assert len(bindata) % 4 == 0

if boot_type == 'FLASH':
    with open(hexfileprefix + '.hex', 'w') as hexf:
        for i in range(nwords):
            if i < len(bindata) // 4:
                w = bindata[4*i : 4*i+4]
                hexf.write('%02x%02x%02x%02x' % (w[3], w[2], w[1], w[0]) + '\n')
            else:
                hexf.write('0\n')
else: # RAM
    hexfs = [open(hexfileprefix + str(i) +'.mi', 'w') for i in range(4)]
        
    for i in range(4):
        hexfs[i].write('#File_format=Hex\n')
        hexfs[i].write('#Address_depth=' + str(nwords) + '\n')
        hexfs[i].write('#Data_width=8\n')

    for i in range(nwords):
        if i < len(bindata) // 4:
            w = bindata[4*i : 4*i+4]
            for j in range(4):
                hexfs[j].write('%02x' % w[j] + '\n')
        else:
            for j in range(4):
                hexfs[j].write(2*'0' + '\n')

    for hexf in hexfs:
        hexf.close()
