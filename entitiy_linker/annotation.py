import sys
import spacy

nlp = spacy.load('en')

from lib import AgdistisEntityLinker

linker = AgdistisEntityLinker()

nlp.add_pipe(linker)

import time
start_time = time.time()

from multiprocessing.dummy import Pool as ThreadPool 

#print(nlp.pipe_names) # Default processing components for en model

pool = ThreadPool(8) 

file = sys.argv[1]
file2 = sys.argv[2]

line2 = open(file2,"w");
def annotate(text):
 #for text in open("testfile.txt", 'r+'):
     
        try:

            newtext = text;    
            doc = nlp(newtext)

            position = 1;
            for ent in doc.ents:
                if(ent._.has_dbpedia_uri):
                    if(newtext.find(ent.text)!= position and newtext.find(ent.text+"_<") == -1):
                        if(ent.label_ != "ORDINAL" and ent.label_ != "DATE" and ent.label_ != "CARDINAL" and ent.label_ != "TIME"):
                            new_ent = ent.text.replace(" ","_");
                            #print(new_ent)
                            #print(ent.label_)
                            #print(newtext.find(ent.text))
                            #print(newtext.find(ent.text+"_<"))
                            #print(ent.text+"_"+ent._.dbpedia_uri)
                            newtext = newtext.replace(ent.text,new_ent+"_<"+ent._.dbpedia_uri+">",1)
                            position = newtext.find(ent.text,1);
        except Exception:
            pass       
   
        newtext = newtext.replace("<http://dbpedia.org/resource/","dbr_").replace(">","");
        return newtext

with open(file) as source_file:

    newtext = pool.map(annotate, source_file, 1)


for line in newtext:
    line2.write(line)
        
line2.close()
print("--- %s seconds ---" % (time.time() - start_time))