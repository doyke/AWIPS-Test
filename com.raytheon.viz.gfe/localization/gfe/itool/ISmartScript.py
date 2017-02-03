##
# This software was developed and / or modified by Raytheon Company,
# pursuant to Contract DG133W-05-CQ-1067 with the US Government.
# 
# U.S. EXPORT CONTROLLED TECHNICAL DATA
# This software product contains export-restricted data whose
# export/transfer/disclosure is restricted by U.S. law. Dissemination
# to non-U.S. persons whether in the United States or abroad requires
# an export license or other authorization.
# 
# Contractor Name:        Raytheon Company
# Contractor Address:     6825 Pine Street, Suite 340
#                         Mail Stop B8
#                         Omaha, NE 68106
#                         402.291.0100
# 
# See the AWIPS II Master Rights File ("Master Rights File.pdf") for
# further licensing information.
##
########################################################################
# This software is in the public domain, furnished "as is", without technical
# support, and with no warranty, express or implied, as to its usefulness for
# any purpose.
#
#    ISmartScript -- library of methods for ITools
#
# Author: hansen
# ----------------------------------------------------------------------------
########################################################################

import string, time
import re, numpy
import Exceptions
import SmartScript, AbsTime

class ISmartScript(SmartScript.SmartScript):
    def __init__(self, dbss):
        SmartScript.SmartScript.__init__(self, dbss)        
        self.__dataMgr = dbss
        self.__parmMgr = self.__dataMgr.getParmManager()       
        self._empty = self.getTopo() * 0.0 
        
    def executeCmd(self, cmd):
        cmd = re.sub("\s*&\s*\Z", "", cmd)
        return self._dbss.dataManager().queueServerProcessing(uiname, cmd)

    def getDataType(self, elementName):
        parm = self.__parmMgr.getParmInExpr(elementName, 1)
        return parm.getGridInfo().getGridType().toString()

    # This method was copied from gfe/ui/ZoneCombiner.py
    def writeActiveComboFile(self, list, comboFilename):
        from com.raytheon.viz.gfe.smarttool import TextFileUtil
        #self._blockNotify = True
        s = """
# ----------------------------------------------------------------------------
# <comboFilename>
# ----------------------------------------------------------------------------

# Format:
# Combinations = [
#    ([ list of edit areas as named in the GFE ], label),
#    ...
#    ]
#
# NOTE: This file was automatically generated by GFE Zone Combiner Editor

"""
        s = s + "Combinations = [\n"
        s = string.replace(s, "<comboFilename>", comboFilename)
        for zones,reg in list:
            s = s + '  (' + repr(zones) + ', ' + repr(reg) + ' ),\n'
        s = s + "]\n\n"


        # write updated combinations file to server        
        textFileID = TextFileUtil.getSiteTextFile(comboFilename, "COMBINATIONS")        
        textFile = open(textFileID.getFile().getPath(), 'w')
        textFile.write(s)
        textFile.close()
        textFileID.save()        
        

        #self.setStatusText('R',
        #                   'Combinations file saved: ' + comboFilename)
        #self._blockNotify = False

    def saveElements(self, elementList, model="Fcst"):
        # Save the given Fcst elements to the server
        # Example:
        #    self.saveElements(["T","Td"])
        for element in elementList:            
            parm = self.getParm(model, element, "SFC")
            if parm:            
                parm.saveParameter(1)

##    def getInitialGrid(self, elementName, elementType, hazardGrid=None):
##        # If hazardGrid is not None, return it (this is assuming we are
##        #  going to overlay hazards onto the grid)
##        # Otherwise, return an empty grid per elementType
##        if elementType == "DISCRETE":
##            self._makeEmptyHazardGrid(elementName, timeRange)
##        elif elementType == "WEATHER":
##            self._makeEmptyWxGrid(elementName, timeRange)
##        else:
##            pass
            
    def getAbsTime(self, timeStr):
        "Create an AbsTime from a string: YYYYMMDD_HHMM"
        year = string.atoi(timeStr[0:4])
        month = string.atoi(timeStr[4:6])
        day = string.atoi(timeStr[6:8])
        hour = string.atoi(timeStr[9:11])
        minute = string.atoi(timeStr[11:13])
        return AbsTime.absTimeYMD(year,month,day,hour,minute)
    
    def getTimeStr(self, absTime):
        # Create a time string YYYYMMDD_HHMM given an AbsTime
        return absTime.stringFmt("%4Y%2m%2d_%2H%2M")

    def getAbsFromLocal(self, year, month, day, hour, minute):
        # Return an AbsTime GMT given the year, month, day, local hour, and minute
        ltSecs = time.mktime((year, month, day, hour, minute, 0, -1, -1, -1))
        gmTime = time.gmtime(ltSecs)
        return AbsTime.absTimeYMD(
            gmTime[0],gmTime[1],gmTime[2],gmTime[3],gmTime[4])
               
    
##############  HazardUtils -- can be removed eventually

    # This method will create an empty hazards-type grid with the specified
    # name and timeRange
    def _makeEmptyHazardGrid(self, weName, timeRange):
        gridShape = self.getTopo().shape
        byteGrid = zeros(gridShape)
        hazKeys = self.getDiscreteKeys("Hazards")
        currentKeys = ["<None>"]
        # make the grid
        self.createGrid("Fcst", weName, "DISCRETE", (byteGrid, currentKeys),
                        timeRange, discreteKeys=hazKeys,
                        discreteAuxDataLength=4, discreteOverlap=1)
        return


    def _makeMask(self, zoneList):
        mask = self._empty
        eaList = self.editAreaList()
        for z in zoneList:
            if z in eaList:
                zoneArea = self.getEditArea(z)
                zoneMask = self.encodeEditArea(zoneArea)
                mask = numpy.logical_or(mask, zoneMask)
        return mask
    
    # adds the specified hazard to weName over the specified timeRange
    # and spatially over the specified mask.  Combines the specified
    # hazard with the existing hazards by default.  For replaceMode,
    # specify 0 in the combineField
    def _addHazard(self, weName, timeRange, addHaz, mask, combine=1):
        # set up the inventory first
        self._setupHazardsInventory(weName, [timeRange])

        # get the inventory
        trList = self._getWEInventory(weName, timeRange)

        for tr in trList:
            byteGrid, hazKey = self.getGrids("Fcst", weName, "SFC", tr,
                                             mode="First", cache=0)

            uniqueKeys = self._getUniqueKeys(byteGrid, hazKey, mask)
            for uKey in uniqueKeys:
                newKey = self._makeNewKey(uKey, addHaz)
                oldIndex = self.getIndex(uKey, hazKey)
                newIndex = self.getIndex(newKey, hazKey)

                # calculate the mask - intersection of mask and oldIndex values
                editMask = logical_and(equal(byteGrid, oldIndex), mask)
        
                # poke in the new values
                byteGrid = where(editMask, newIndex, byteGrid)

            self.createGrid("Fcst", weName, "DISCRETE", (byteGrid, hazKey),
                            tr, discreteOverlap=1, discreteAuxDataLength=4)

            byteGrid, hazKey = self.getGrids("Fcst", weName, "SFC", tr,
                                             mode="First")
            noneMask = equal(byteGrid, 0)
            noneCount = sum(sum(noneMask))
            
        return

    def dirList2(self):
        return {
            'N' : 0,
            'NE':45,
            'E' :90,
            'SE':135,
            'S' :180,
            'SW':225,
            'W' :270,
            'NW':315,
            }

    def textToDir(self, textDir):
        # Return a numeric direction 8-point text direction
        return self.dirList2()[textDir]

    def output(self, msg, outFile, prt=1):
        # Put message to outFile
        # If prt=1, also print the message
        if prt==1:
            print msg
        if outFile is not None:
            try:
                outFile.write(msg+"\n")
                outFile.flush()
            except:
                pass

    def internalStrip(self, inStr):
        while inStr.find("  ") >= 0:
            inStr = inStr.replace("  ", " ")
        return inStr

    