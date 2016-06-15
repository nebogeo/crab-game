#!/usr/bin/env python
import os

# does crabs too...
def convert_bg(name):
    for location in os.listdir(name):
        if location[0:3]!="di-":
            for filename in os.listdir(name+"/"+location):
                ext = os.path.splitext(filename)[1]
                if filename[0:3]!="di-" and (ext==".jpg" or ext==".png"):
                    cmd="convert "+name+"/"+location+"/"+filename+" -channel red,green -fx \"(r+g)/2\" "+name+"/di-"+location+"/"+filename
                    print(cmd)
                    os.system(cmd)

convert_bg("mudflat")
convert_bg("rockpool")
convert_bg("musselbed")

def gen_lists(name):
    print(name)
    for location in os.listdir(name):
        if location[0:3]!="di-" and location!="crabs":
            for filename in os.listdir(name+"/"+location):
                ext = os.path.splitext(filename)[1]
                if filename[0:3]!="di-" and (ext==".jpg" or ext==".png"):
                    cmd="\""+location+"/"+filename+"\""
                    print(cmd)

def gen_crab_lists(name):
    for location in os.listdir(name):
        if location=="crabs":
            print(name)
            for filename in os.listdir(name+"/"+location):
                ext = os.path.splitext(filename)[1]
                if filename[0:3]!="di-" and (ext==".jpg" or ext==".png"):
                    cmd="\""+filename+"\""
                    print(cmd)



#gen_crab_lists("mudflat")
#gen_crab_lists("musselbed")
#gen_crab_lists("rockpool")

#gen_lists("mudflat")
#gen_lists("musselbed")
#gen_lists("rockpool")
