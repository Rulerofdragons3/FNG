import json
import os
import sys

directory = "d:/Godot/FNG/"
saveDir = "d:/Godot/FNG/FishDat/"

def createFile(fishData:dict):
    fishName:str = fishData["name"]
    fishName = fishName.lower().replace(" ","_")

    fishData.update({
        "texture":"BaseFish/"+fishName+".png",
        "id":fishName
        })

    with open(saveDir + fishName +".json", "w") as file:
        file.write(json.dumps(fishData,indent=1))
        file.close()




with open(directory + "FishDat.json") as f:
    FishDat = json.loads(f.read())
    f.close()


for fish in FishDat:
    createFile(fish)


