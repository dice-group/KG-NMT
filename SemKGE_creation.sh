#!/usr/bin/env bash


SOURCEDIR="KGE/$1"
#TARGETDIR="$2"

if [ ! -d "$SOURCEDIR" ]; then
  mkdir -p $SOURCEDIR
fi


echo "Dear user, let's start cracking it by downloading the important files from DBpedia"
echo "This is example is for translating between English and German, in case you want to use other languages you have to edit this file"


if [ ! -f "$SOURCEDIR/instance_types_$1.ttl" ]; then
	echo "Downloading $1"
	wget http://downloads.dbpedia.org/2016-10/core-i18n/"$1"/instance_types_"$1".ttl.bz2;
fi

if [ ! -f "$SOURCEDIR/mappingbased_objects_$1.ttl" ]; then
	wget http://downloads.dbpedia.org/2016-10/core-i18n/"$1"/mappingbased_objects_"$1".ttl.bz2 ;
fi
if [ ! -f "$SOURCEDIR/labels_$1.ttl" ]; then
	wget http://downloads.dbpedia.org/2016-10/core-i18n/"$1"/labels_"$1".ttl.bz2;
fi
if [ -f "labels_"$1".ttl.bz2" ] ; then
	bzip2 -d *.bz2;
	mv *.ttl $SOURCEDIR
fi


if [ ! -d "fastText-0.9.1" ]; then
	wget https://github.com/facebookresearch/fastText/archive/v0.9.1.zip ;
	unzip v0.9.1.zip ;
fi

cd fastText-0.9.1
if [ ! -f "fasttext" ]; then
	make ;
fi
cd ..

echo "Parsing the files";

tr "A-Z" "a-z" < $SOURCEDIR/instance_types_"$1".ttl > $SOURCEDIR/instance_types_"$1"_lc.txt
tr "A-Z" "a-z" < $SOURCEDIR/labels_"$1".ttl > $SOURCEDIR/labels_"$1"_lc.txt
tr "A-Z" "a-z" < $SOURCEDIR/mappingbased_objects_"$1".ttl > $SOURCEDIR/mappingbased_objects_"$1"_lc.txt

if [ ! -f "$SOURCEDIR/all_"$SOURCEDIR".txt" ]; then
	sed -i '' -e '/http/!d' $SOURCEDIR/*_lc.txt
	sed -i '' -e 's/<http:\/\/dbpedia.org\/resource\//dbr_/g' $SOURCEDIR/*_lc.txt
	sed -i '' -e 's/<http:\/\/de.dbpedia.org\/resource\//dbr_de_/g' $SOURCEDIR/*_lc.txt
	sed -i '' -e 's/<http:\/\/www.w3.org\/2000\/01\/rdf-schema#/rdfs_/g' $SOURCEDIR/*_lc.txt
	sed -i '' -e 's/<http:\/\/xmlns.com\/foaf\/0.1\//foaf_/g' $SOURCEDIR/*_lc.txt
	sed -i '' -e 's/<http:\/\/schema.org\//schema_/g' $SOURCEDIR/*_lc.txt
	sed -i '' -e 's/<http:\/\/purl.org\/dc\/terms/dc_/g' $SOURCEDIR/*_lc.txt
	sed -i '' -e 's/<http:\/\/purl.org\/dc\/elements\/1.1\//dc_/g' $SOURCEDIR/*_lc.txt
	sed -i '' -e 's/<http:\/\/www.w3.org\/2004\/02\/skos\/core#/skos_/g' $SOURCEDIR/*_lc.txt
	sed -i '' -e 's/<http:\/\/dbpedia.org\/ontology\//dbo_/g' $SOURCEDIR/*_lc.txt
	sed -i '' -e 's/<http:\/\/de.dbpedia.org\/property\//dbp_de_/g' $SOURCEDIR/*_lc.txt
	sed -i '' -e 's/<http:\/\/dbpedia.org\/datatype\//dbt_/g' $SOURCEDIR/*_lc.txt
	sed -i '' -e 's/<http:\/\/www.w3.org\/2002\/07\/owl#/owl_/g' $SOURCEDIR/*_lc.txt
	sed -i '' -e 's/<http:\/\/www.w3.org\/1999\/02\/22-rdf-syntax-ns#/rdf_/g' $SOURCEDIR/*_lc.txt
	sed -i '' -e 's/@en//g'  $SOURCEDIR/*_lc.txt
	sed -i '' -e 's/@de//g'  $SOURCEDIR/*_lc.txt
	sed -i '' -e '/ontologydesignpatterns/d'  $SOURCEDIR/*_lc.txt
	sed -i '' -e '/foaf_homepage/d'  $SOURCEDIR/*_lc.txt
	sed -i '' -e '/wikidata_/d'  $SOURCEDIR/*_lc.txt
	sed -i '' -e '/schema_/d'  $SOURCEDIR/*_lc.txt
	sed -i '' -e 's/^^rdf_langString//g'  $SOURCEDIR/*_lc.txt
	sed -i '' -e 's/\.//g' $SOURCEDIR/*_lc.txt
	sed -i '' -e 's/>//g' $SOURCEDIR/*_lc.txt
	sed -i '' -e 's/"//g' $SOURCEDIR/*_lc.txt
	sed -i '' -e '/%3f/d' $SOURCEDIR/*_lc.txt
	sed -i '' -e '/%/d' $SOURCEDIR/*_lc.txt
	awk '{print $1, $2, $3;print $3, $2, $1}' < $SOURCEDIR/instance_types_"$1"_lc.txt > $SOURCEDIR/instance_types_"$1"_new_lc.txt
	awk '{print $1, $2, $3;print $3, $2, $1}' < $SOURCEDIR/mappingbased_objects_"$1"_lc.txt > $SOURCEDIR/$SOURCEDIR/mappingbased_objects_"$1"_new_lc.txt 
	awk '{printf "__label__"$1" "; for(i=2;i<=NF;i++){printf $i" "}print ""}' < $SOURCEDIR/labels_"$1"_lc.txt > $SOURCEDIR/labels_"$1"_new_lc.txt
	rm -rf $SOURCEDIR/labels_"$1"_lc.txt
	rm -rf $SOURCEDIR/instance_types_"$1"_lc.txt
	rm -rf $SOURCEDIR/mappingbased_objects_"$1"_lc.txt
	awk 'FNR==1{print ""}{print}' $SOURCEDIR/*_lc.txt > $SOURCEDIR/all_"$1".txt
fi

if [ ! -f "$SOURCEDIR/all_"$SOURCEDIR"_model" ]; then
	./fastText-0.9.1/fasttext supervised -input $SOURCEDIR/all_"$1".txt -output $SOURCEDIR/all_"$1"_model -minn 2 -maxn 5 -dim 500 -thread 1 -ws 50 -loss hs 
fi
