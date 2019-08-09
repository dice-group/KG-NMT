#!/usr/bin/env bash


SOURCEDIR="$1"
TARGETDIR="$2"

if [ ! -d "$SOURCEDIR" ]; then
  mkdir $SOURCEDIR
fi

if [ ! -d "$TARGETDIR" ]; then
  mkdir $TARGETDIR
fi


echo "Dear user, let's start cracking it by downloading the important files from DBpedia"
echo "This is example is for translating between English and German, in case you want to use other languages you have to edit this file"
echo "Downloading English"
wget http://downloads.dbpedia.org/2016-10/core-i18n/"$1"/instance_types_"$1".ttl.bz2;
wget http://downloads.dbpedia.org/2016-10/core-i18n/"$1"/mappingbased_literals_"$1".ttl.bz2 ;   
wget http://downloads.dbpedia.org/2016-10/core-i18n/"$1"/mappingbased_objects_"$1".ttl.bz2 ;
wget http://downloads.dbpedia.org/2016-10/core-i18n/"$1"/labels_"$1".ttl.bz2;
bzip2 -d *.bz2;
mv *.ttl $SOURCEDIR
echo "Downloading German"
wget http://downloads.dbpedia.org/2016-10/core-i18n/"$2"/instance_types_"$2".ttl.bz2;
wget http://downloads.dbpedia.org/2016-10/core-i18n/"$2"/mappingbased_literals_"$2".ttl.bz2 ;   
wget http://downloads.dbpedia.org/2016-10/core-i18n/"$2"/mappingbased_objects_"$2".ttl.bz2 ;
wget http://downloads.dbpedia.org/2016-10/core-i18n/"$2"/labels_"$2".ttl.bz2;

bzip2 -d *.bz2;
mv *.ttl $TARGETDIR

cd $SOURCEDIR

wget https://github.com/facebookresearch/fastText/archive/v0.9.1.zip ;
unzip v0.9.1.zip ;
fastText-0.9.1/make ;

sed -i '' -e 's/dbr_/<http:\/\/dbpedia.org\/resource\//g' $SOURCEDIR/*.ttl

tr A-Z a-z < de/instance_types_de.ttl > de/instance_types_de_lc.txt
tr A-Z a-z < de/labels_de.ttl > de/labels_de_lc.txt
tr A-Z a-z < de/mappingbased_literals_de.ttl > de/mappingbased_literals_de_lc.txt
tr A-Z a-z < de/mappingbased_objects_de.ttl > de/mappingbased_objects_de_lc.txt

mkdir $TARGETDIR/bkp 
mv $TARGETDIR/*.ttl $TARGETDIR/bkp/

sed -i '' -e 's/<http:\/\/de.dbpedia.org\/resource\//dbr_de_/g' $TARGETDIR/*_lc.txt
sed -i '' -e 's/<http:\/\/www.w3.org\/2000\/01\/rdf-schema#/rdfs_/g' $TARGETDIR/*_lc.txt
sed -i '' -e 's/<http:\/\/xmlns.com\/foaf\/0.1\//foaf_/g' $TARGETDIR/*_lc.txt
sed -i '' -e 's/<http:\/\/schema.org\//schema_/g' $TARGETDIR/*_lc.txt
sed -i '' -e 's/<http:\/\/purl.org\/dc\/terms/dc_/g' $TARGETDIR/*_lc.txt
sed -i '' -e 's/<http:\/\/purl.org\/dc\/elements\/1.1\//dc_/g' $TARGETDIR/*_lc.txt
sed -i '' -e 's/<http:\/\/www.w3.org\/2004\/02\/skos\/core#/skos_/g' $TARGETDIR/*_lc.txt
sed -i '' -e 's/<http:\/\/dbpedia.org\/ontology\//dbo_/g' $TARGETDIR/*_lc.txt
sed -i '' -e 's/<http:\/\/de.dbpedia.org\/property\//dbp_/g' $TARGETDIR/*_lc.txt
sed -i '' -e 's/<http:\/\/dbpedia.org\/datatype\//dbt_/g' $TARGETDIR/*_lc.txt
sed -i '' -e 's/<http:\/\/www.w3.org\/2002\/07\/owl#/owl_/g' $TARGETDIR/*_lc.txt
sed -i '' -e 's/<http:\/\/www.w3.org\/1999\/02\/22-rdf-syntax-ns#/rdf_/g' $TARGETDIR/*_lc.txt
sed -i '' -e 's/@de//g'  $TARGETDIR/*_lc.txt
sed -i '' -e '/ontologydesignpatterns/d'  $TARGETDIR/*_lc.txt
sed -i '' -e '/foaf_homepage/d'  $TARGETDIR/*_lc.txt
sed -i '' -e '/wikidata_/d'  $TARGETDIR/*_lc.txt
sed -i '' -e '/schema_/d'  $TARGETDIR/*_lc.txt
sed -i '' -e 's/^^rdf_langString//g'  $TARGETDIR/*_lc.txt
sed -i '' -e 's/\.//g' $TARGETDIR/*_lc.txt
sed -i '' -e 's/>//g' $TARGETDIR/*_lc.txt
sed -i '' -e 's/"//g' $TARGETDIR/*_lc.txt
sed -i '' -e '/http:\/\//d' $TARGETDIR/*_lc.txt



./fasttext supervised -input ../embeddings_encoder/en/unsupervised/all_dbpedia_labels_en.txt -output ../embeddings_encoder/en/unsupervised/all_dbpedia_en_label_model -minn 2 -maxn 5 -dim 500 -thread 12 -ws 50 -loss hs