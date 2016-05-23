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
