#!/usr/bin/env python
# -*- coding: utf-8 -*-

# Copyright 2014 Maja Popovic


import sys
import math
import unicodedata


def separate_characters(line, space):
    newline = ""
    #l = unicode(line, "utf-8")
    #words = l.split()
    words = line.split()
    for w in words:
        for c in w:
            newline += c + " "
        if(space):
            newline += " = "
       
    newline += ("\n")

    #print(newline)
    
    return newline
    

def take_ngrams(line, m):
    newline = ""
    words = line.split()
    for i, word in enumerate(words):
        for j in range(1, m+1):
            if i+j <= len(words):
                for k in range(i, i+j-1):
                    newline += words[k] + "=="
                newline += words[i+j-1]
                if j < m:
                    newline += "*#"
            if j==m:
                newline += " "
   
    ngram = [[] for x in range(m)]

    newwords = newline.split()
    for newword in newwords:
        ngrams = newword.split("*#")
        for nnw, nw in enumerate(ngrams):
            if nw != "" and nw !="\n":
                ngram[nnw].append(nw)

    return ngram


def hyp_ref_errors(rwords, hwords):
    errorcount = 0.0
    precrec = 0.0
    missing = []

    for w in hwords:
        if w in rwords:
            j = rwords.index(w)
            del rwords[j]
        else:
            errorcount += 1
            missing.append(w)

        if len(hwords) != 0:
            precrec = 100*errorcount/len(hwords)
        else:
            if len(rwords) != 0:
                precrec = 100
            else:
                precrec = 0

    return errorcount, precrec, missing



 
sent = False
analyse = False
ngramprecrecf = False
prec = False
rec = False
nweight = False
space = False
nweights = []
beta = 1.0
n = 6

args = sys.argv
if len(args) < 5:
    print("\nchrF.py \t\t -R, --ref   reference \n \t\t\t -H, --hyp   hypothesis \n\noptional inputs: \t -n,  --ngram     ngram order (default = 6) \n \t\t\t -nw, --nweight   ngram weights (default = 1/n) \n\noptional outputs: \t -p, --prec   show precisions \n  \t\t\t -r, --rec    show recalls \n \t\t\t -b, --beta beta-parameter \n \t\t\t -g, --gram   show separate ngram scores \n \t\t\t -s, --sent   show sentence level scores \n \t\t\t -c, --space   take spaces into account \n \t\t\t -a, --analyse   show ngrams without a match\n")
    sys.exit()
for arg in args:
    if arg == "-R" or arg == "--ref":
        rtext = args[args.index(arg)+1]
    elif arg == "-H" or arg == "--hyp":
        htext = args[args.index(arg)+1]
    elif arg == "-s" or arg == "--sent":
        sent = True
    elif arg == "-a" or arg == "--analyse":
        analyse = True
    elif arg == "--ngram" or arg == "-n":
        n = int(args[args.index(arg)+1])
    elif arg == "-nw" or arg == "--nweight":
        nweight = True
        nweights = (args[args.index(arg)+1]).split("-") 
    elif arg == "-g" or arg == "--gram":
        ngramprecrecf = True
    elif arg == "-r" or arg == "--rec":
        rec = True
    elif arg == "-p" or arg == "--prec":
        prec = True
    elif arg == "-b" or arg == "--beta":
        beta = float(args[args.index(arg)+1])
    elif arg == "-c" or arg == "--space":
        space = True

rtxt = open(rtext, 'r')
htxt = open(htext, 'r')

hline = htxt.readline()
rline = rtxt.readline()

totalNgramRperCount = [0.0 for x in range(n)]
totalNgramHperCount = [0.0 for x in range(n)]
totalNgramHypLength = [0.0 for x in range(n)]
totalNgramRefLength = [0.0 for x in range(n)]

nsent = 0

ngramweights = []


if not(nweight):
    ngramweights = [1/float(n) for x in range(n)]
else:
    if len(nweights) != n:
        print("error: ngram weights length!")
        sys.exit()
    total = 0.0
    for i in range(len(nweights)):
        total += float(nweights[i])
    for i in range(len(nweights)):
        ngramweights.append(float(nweights[i])/total)

factor = math.pow(beta,2)

while (hline and rline):

    nsent += 1

    sentRec = 0.0
    sentPrec = 0.0
    sentF = 0.0


    # preparation for multiple references

    minNgramSentRper = [1000.0 for x in range(n)]
    minNgramSentHper = [1000.0 for x in range(n)]
    bestNgramSentRperCount = [0.0 for x in range(n)]
    bestNgramSentHperCount = [0.0 for x in range(n)]
    bestNgramHypLength = [0.0 for x in range(n)]
    bestNgramRefLength = [0.0 for x in range(n)]
    bestSentRMissing = [[] for x in range(n)]
    bestSentHMissing = [[] for x in range(n)]
    
    chrhline = separate_characters(hline, space)
    hngrams = take_ngrams(chrhline, n)


    # going through multiple references

    refs = rline.split("*#")

    nref = 0

    for ref in refs:
        nref += 1

        chrrline = separate_characters(ref, space)
        rngrams = take_ngrams(chrrline, n)
        rngrams1 = take_ngrams(chrrline, n)
        hngrams1 = take_ngrams(chrhline, n)


        #############
        # precision #
        #############

        for kh, hypWords in enumerate(hngrams):
            rwords1 = rngrams1[kh]
            sentHperCount, sentHper, sentHmissing = hyp_ref_errors(rwords1, hypWords)
 
            if sentHper < minNgramSentHper[kh]:
                minNgramSentHper[kh] = sentHper
                bestNgramHypLength[kh] = len(hypWords)
                bestNgramSentHperCount[kh] = sentHperCount
                bestSentHMissing[kh] = sentHmissing
        

        ##########
        # recall #
        ##########

        for kr, refWords in enumerate(rngrams):
            hwords1 = hngrams1[kr]
            sentRperCount, sentRper, sentRmissing = hyp_ref_errors(hwords1, refWords)

            if sentRper < minNgramSentRper[kr]:
                minNgramSentRper[kr] = sentRper
                bestNgramRefLength[kr] = len(refWords)
                bestNgramSentRperCount[kr] = sentRperCount
                bestSentRMissing[kr] = sentRmissing
   
        

    # all the references are done


    # collect ngram counts

    for i in range(n):
        totalNgramHperCount[i] += bestNgramSentHperCount[i]
        totalNgramRperCount[i] += bestNgramSentRperCount[i]
        totalNgramRefLength[i] += bestNgramRefLength[i]
        totalNgramHypLength[i] += bestNgramHypLength[i]



    # analysis of results: which hyp/ref n-grams do not have a match in ref/hyp 

    if analyse:
        for ng, ngh in enumerate(bestSentRMissing):
            sys.stdout.write(str(nsent)+"::ref-"+str(ng+1)+"grams: ")
            for wh in ngh:
                sys.stdout.write(wh+" ")
            sys.stdout.write("\n")

        for ng, ngr in enumerate(bestSentHMissing):
            sys.stdout.write(str(nsent)+"::hyp-"+str(ng+1)+"grams: ")               
            for wr in ngr:
                sys.stdout.write(wr+" ")   
            sys.stdout.write("\n")


    # sentence precision, recall and F (arithmetic mean of all ngrams)
    
    if sent:
        sentNgramPrec = [0.0 for x in range(n)]
        sentNgramRec = [0.0 for x in range(n)]
        sentNgramF = [0.0 for x in range(n)]


        for i in range(n):
            if bestNgramRefLength[i] != 0:
                sentNgramRec[i] = 100 - 100*bestNgramSentRperCount[i]/bestNgramRefLength[i]
            else:
                sentNgramRec[i] = 0
            
            if bestNgramHypLength[i] != 0:
                sentNgramPrec[i] = 100 - 100*bestNgramSentHperCount[i]/bestNgramHypLength[i]
            else:
                sentNgramPrec[i] = 0

            if sentNgramPrec[i] != 0 or sentNgramRec[i] != 0:
                sentNgramF[i] = (1+factor)*sentNgramPrec[i]*sentNgramRec[i]/(factor*sentNgramPrec[i] + sentNgramRec[i])
            else:
                sentNgramF[i] = 0


            if ngramprecrecf:
                sys.stdout.write(str(nsent)+"::"+str(i+1)+"gram-F     "+str("%.4f" % sentNgramF[i])+"\n")
                if prec:
                    sys.stdout.write(str(nsent)+"::"+str(i+1)+"gram-Prec  "+str("%.4f" % sentNgramPrec[i])+"\n")
                if rec:
                    sys.stdout.write(str(nsent)+"::"+str(i+1)+"gram-Rec   "+str("%.4f" % sentNgramRec[i])+"\n")



            sentRec += ngramweights[i]*sentNgramRec[i]
            sentPrec += ngramweights[i]*sentNgramPrec[i]
            sentF += ngramweights[i]*sentNgramF[i]
 

        sys.stdout.write(str(nsent)+"::chrF-"+str(beta)+"\t"+str("%.4f" % sentF)+"\n")   
        if prec:
            sys.stdout.write(str(nsent)+"::chrPrec\t"+str("%.4f" % sentPrec)+"\n")
        if rec:
            sys.stdout.write(str(nsent)+"::chrRec\t"+str("%.4f" % sentRec)+"\n")
   

    hline = htxt.readline()
    rline = rtxt.readline()

    hypUnits = hline.split("++")
    refUnits = rline.split("++")

        
        
# total precision, recall and F (aritmetic mean of all ngrams)

totRec = 0.0
totPrec = 0.0
totF = 0.0

totalPrec = [0.0 for x in range(n)]
totalRec = [0.0 for x in range(n)]
totalF = [0.0 for x in range(n)]

for i in range(n):
    if totalNgramRefLength[i] != 0:
        totalRec[i] = 100 - 100*totalNgramRperCount[i]/totalNgramRefLength[i]
    else:
        totalRec[i] = 0

    if totalNgramHypLength[i] != 0:
        totalPrec[i] = 100 - 100*totalNgramHperCount[i]/totalNgramHypLength[i]
    else:
        totalPrec[i] = 0

    if totalRec[i] != 0 or totalPrec[i] != 0:
        totalF[i] = (1+factor)*totalRec[i]*totalPrec[i]/(factor*totalPrec[i] + totalRec[i])
    else:
        totalF[i] = 0

    if ngramprecrecf:
        sys.stdout.write(str(i+1)+"gram-F     "+str("%.4f" % totalF[i])+"\n")
        if prec:
            sys.stdout.write(str(i+1)+"gram-Prec  "+str("%.4f" % totalPrec[i])+"\n")
        if rec:
            sys.stdout.write(str(i+1)+"gram-Rec   "+str("%.4f" % totalRec[i])+"\n")

    totRec += ngramweights[i]*totalRec[i]
    totPrec += ngramweights[i]*totalPrec[i]
    totF += ngramweights[i]*totalF[i]
    
 

sys.stdout.write("chrF-"+str(beta)+"\t"+str("%.4f" % totF)+"\n")
if prec:
    sys.stdout.write("chrPrec\t"+str("%.4f" % totPrec)+"\n")
if rec:
    sys.stdout.write("chrRec\t"+str("%.4f" % totRec)+"\n")



htxt.close()
rtxt.close()







