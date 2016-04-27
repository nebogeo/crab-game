#!/usr/bin/env python
import os

def convert_crabs():
    for filename in os.listdir('crabs/'):
        ext = os.path.splitext(filename)[1]
        if filename[0:3]!="di-" and (ext==".jpg" or ext==".png"):
            cmd="convert crabs/"+filename+" -channel Red -fx 0 +channel crabs/di-"+filename
            print(cmd)
            os.system(cmd)

def convert_bg(name):
    for location in os.listdir(name):
        if location[0:3]!="di-":
            for filename in os.listdir(name+"/"+location):
                ext = os.path.splitext(filename)[1]
                if filename[0:3]!="di-" and (ext==".jpg" or ext==".png"):
                    cmd="convert "+name+"/"+location+"/"+filename+" -channel Red -fx 0 +channel "+name+"/di-"+location+"/"+filename
                    print(cmd)
                    os.system(cmd)

convert_crabs()
convert_bg("mudflat")
convert_bg("rockpool")
