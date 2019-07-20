#!/usr/bin/env python
import sys
import os
name = ""
base_name = ""

latches = int(sys.argv[1])
players = int(sys.argv[2])

if sys.argv[3] == "":
	print("You need to specify a file to convert")
	sys.exit()
else:
	name = sys.argv[3]
	base_name = sys.argv[3][:-4]

f = open(os.path.dirname(os.path.realpath(__file__)) + "\\" + name, "rb")
fo = open(os.path.dirname(os.path.realpath(__file__)) + "\\" + base_name + ".inp", "w")

data = f.read()
c = 0

while c < len(data):
	v = data[c]
	i = ""
	ii = ""
	i = i + ("R" if v & 128 != 0 else ".")
	i = i + ("L" if v & 64 != 0 else ".")
	i = i + ("D" if v & 32 != 0 else ".")
	i = i + ("U" if v & 16 != 0 else ".")
	i = i + ("T" if v & 8 != 0 else ".")
	i = i + ("S" if v & 4 != 0 else ".")
	i = i + ("B" if v & 2 != 0 else ".")
	i = i + ("A" if v & 1 != 0 else ".")
	c = c + 1

	if players == 2:
		vv = data[c]
		ii = ii + ("R" if vv & 128 != 0 else ".")
		ii = ii + ("L" if vv & 64 != 0 else ".")
		ii = ii + ("D" if vv & 32 != 0 else ".")
		ii = ii + ("U" if vv & 16 != 0 else ".")
		ii = ii + ("T" if vv & 8 != 0 else ".")
		ii = ii + ("S" if vv & 4 != 0 else ".")
		ii = ii + ("B" if vv & 2 != 0 else ".")
		ii = ii + ("A" if vv & 1 != 0 else ".")
		c = c + 1
		
	for l in range(0, latches):
		if players == 1:
			fo.write(i + "|........\n")
		else:
			fo.write(i + "|" + ii + "\n")

f.close()
fo.close()
print("Converted " + str(len(data)) + " bytes.")