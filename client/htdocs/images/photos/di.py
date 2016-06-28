#!/usr/bin/env python
import os
import time
from PIL import Image

# does crabs too...
def convert_bg(name):
    for location in os.listdir(name):
	if location[0:3]!="di-":
	#if location=="crabs":
            for filename in os.listdir(name+"/"+location):
                ext = os.path.splitext(filename)[1]
                if filename[0:3]!="di-" and (ext==".jpg" or ext==".png"):
                    cmd="convert "+name+"/"+location+"/"+filename+" -channel red,green -fx \"(r+g)/2\" "+name+"/di-"+location+"/"+filename
                    print(cmd)
                    os.system(cmd)

def gen_lists(name):
    print(name)
    for location in os.listdir(name):
        if location[0:3]!="di-" and location!="crabs":
            for filename in os.listdir(name+"/"+location):
                ext = os.path.splitext(filename)[1]
                if filename[0:3]!="di-" and (ext==".jpg" or ext==".png"):
                    cmd="\""+location+"/"+filename+"\""
                    print(cmd)

def gen_rmlists(name):
    print(name)
    for location in os.listdir(name):
        for filename in os.listdir(name+"/"+location):
            ext = os.path.splitext(filename)[1]
            if location!="crabs" and location!="di-crabs" and (ext==".jpg" or ext==".png"):
                #cmd="\""+location+"/"+filename+"\""
                im = Image.open(name+"/"+location+"/"+filename)
                if im.size[0]<1600:
                    cmd="rm "+name+"/"+location+"/"+filename
                    print(cmd)

def gen_crab_lists(name):
    lst = []
    for location in os.listdir(name):
        if location=="crabs":
            print(name)
            for filename in os.listdir(name+"/"+location):
                ext = os.path.splitext(filename)[1]
                if filename[0:3]!="di-" and (ext==".jpg" or ext==".png"):
                    cmd="\""+filename+"\""
                    im = Image.open(name+"/"+location+"/"+filename)
                    if im.size[0]<500:
                        lst.append(cmd)
    			#print(cmd)
#    lst.sort()
    for f in lst:
        print(f)

num_crabs = 0
num_big = 0

def check_crab_sizes(name):
    global num_crabs
    global num_big
    num_crabs = 0
    num_big = 0
    for location in os.listdir(name):
        if location=="crabs":
            print(name)
            for filename in os.listdir(name+"/"+location):
                ext = os.path.splitext(filename)[1]
                if ext==".png":
                    num_crabs+=1
                    im = Image.open(name+"/"+location+"/"+filename)
                    if im.size[0]>500:
                        num_big+=1

    print("num too big: "+str(num_big))
    print("total: "+str(num_crabs))
    print("("+str((num_big/float(num_crabs))*100)+"% are too big)")
    print("in game: "+str(num_crabs-num_big))


#convert_bg("mudflat")
#convert_bg("rockpool")
#convert_bg("musselbed")

gen_crab_lists("mudflat")
gen_crab_lists("musselbed")
gen_crab_lists("rockpool")

#gen_lists("mudflat")
#gen_lists("musselbed")
#gen_lists("rockpool")

check_crab_sizes("mudflat")
check_crab_sizes("musselbed")
check_crab_sizes("rockpool")
