#!/usr/bin/python
import sys
import os
import re
#import jellyfish


def LD(s, t):
        ''' From Wikipedia article; Iterative with two matrix rows. '''
        if s == t: return 0
        elif len(s) == 0: return len(t)
        elif len(t) == 0: return len(s)
        v0 = [None] * (len(t) + 1)
        v1 = [None] * (len(t) + 1)
        for i in range(len(v0)):
            v0[i] = i
        for i in range(len(s)):
            v1[0] = i + 1
            for j in range(len(t)):
                cost = 0 if s[i] == t[j] else 1
                v1[j + 1] = min(v1[j] + 1, v0[j + 1] + 1, v0[j] + cost)
            for j in range(len(v0)):
                v0[j] = v1[j]
                
        return v1[len(t)]
        
def ldscore(a, b):
    '''Compute the levenshtein distance function and then normalize it as
a probability for higher level computational analysis'''
    mlen = max(len(a),len(b))
    return 1.0 - ( float(LD(a, b)) / mlen);
        

def getdata ():
    '''Suck in all of the lines from the data files'''
    with open("data") as fp:
        return fp.readlines()

## Predicate that tests if a line is a record seperator    
recordSplitRE = re.compile("Example\s+\d+")
def isRecordSplit(line):
    '''Predicate to look for the start of a record'''
    if recordSplitRE.search(line): return line

## Predicate that tests if a line is a phone number
phoneNumRE = re.compile("\d{3}.+\d{4}")
def isPhoneNum(line):
    '''Predicate to determine if the line is a phone number'''
    if phoneNumRE.search(line): return line

emailNameExtractRE = re.compile("\s*(.+)@.*")
def emailExtractName(line):
    '''Extract the name from the email'''
    m = emailNameExtractRE.match(line)
    if m: return m.group(1)

phoneExtractRE = re.compile("[^0-9]")
def phoneExtract(line):
    '''Remove everything that is not a number'''
    return phoneExtractRE.sub("",line)

dataAndAnswerDiv = re.compile("==>")
def isDataAnswerDiv(line):
    '''A predicate to find the split marker between input data and answer in the data stream'''
    if dataAndAnswerDiv.search(line): return line

emailRE = re.compile(".*\@[^.]+\.com")
def isEmail(line):
    '''a predicate to determin if a line is an email address'''
    if emailRE.search(line): return line;

    ####
dt = getdata()

def getFirstEmail(lines):
    '''Linear search of the record(s) for an email address'''
    for l in lines:
        if isEmail(l): return l

def getFirstPhone(lines):
    '''Linear search of the record(s) for a phone number'''    
    for l in lines:
        if isPhoneNum(l) and "ax:" not in l: return l

def textToRecords(lst):
    '''parse the input data and return a list of records, where the records are simple a list of the data'''
    recs = [];
    buff = [];
    qa = 0
    for l in lst:
        if isRecordSplit(l):
            qa = 1
        elif isDataAnswerDiv(l):
            if len (buff) > 0:
                recs.append(buff)
                buff = []
                qa = 0
        elif qa == 1:
            buff.append(l);
    return recs

def getPhoneNumber(lines):
    '''Part of the intrface specification. Retrieve the phone number for the record'''
    return phoneExtract(getFirstPhone(lines))

def getsortkey (arr):
    return arr[0]

def _getName(lines):
    email = getFirstEmail(lines)
    emailName = emailExtractName(email)
    sortedArray = sorted(map(lambda x: [ldscore(x,emailName) #, LD(x,emailName)
                                      , x],
                             filter(lambda x: x != email,
                                    lines)),
                         key=getsortkey,reverse=True)
    return sortedArray;

def getName(lines):
    '''Part of the intrface specification. Retrieve the name of the person'''    
    return _getName(lines)[0][1];

def finalExtractor(lines):
    '''Example of the interface against a record'''
    return [getFirstEmail(lines),getPhoneNumber(lines),getName(lines)]

def run ():
    '''Test of the interface functions against the test data'''
    return map(finalExtractor,textToRecords(dt))

def main():
    for elmnt in run():
        print(elmnt)
        
        
    
if __name__ == '__main__':
    main()
    
