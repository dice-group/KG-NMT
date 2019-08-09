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
wget http://downloads.dbpedia.org/2016-10/core-i18n/"$1"/mappingbased_objects_"$1".ttl.bz2 ;
wget http://downloads.dbpedia.org/2016-10/core-i18n/"$1"/labels_"$1".ttl.bz2;
bzip2 -d *.bz2;
mv *.ttl $SOURCEDIR

echo "Downloading German"
wget http://downloads.dbpedia.org/2016-10/core-i18n/"$2"/instance_types_"$2".ttl.bz2;
wget http://downloads.dbpedia.org/2016-10/core-i18n/"$2"/mappingbased_objects_"$2".ttl.bz2 ;
wget http://downloads.dbpedia.org/2016-10/core-i18n/"$2"/labels_"$2".ttl.bz2;

bzip2 -d *.bz2;
mv *.ttl $TARGETDIR

wget https://github.com/facebookresearch/fastText/archive/v0.9.1.zip ;
unzip v0.9.1.zip ;
cd fastText-0.9.1
make ;

cd ..

echo "Parsing the files"

tr A-Z a-z < $SOURCEDIR/instance_types_"$SOURCEDIR".ttl > $SOURCEDIR/instance_types_"$SOURCEDIR"_lc.txt
tr A-Z a-z < $SOURCEDIR/labels_"$SOURCEDIR".ttl > $SOURCEDIR/labels_"$SOURCEDIR"_lc.txt
tr A-Z a-z < $SOURCEDIR/mappingbased_objects_"$SOURCEDIR".ttl > $SOURCEDIR/mappingbased_objects_"$SOURCEDIR"_lc.txt

mkdir $SOURCEDIR/bkp 
mv $SOURCEDIR/*.ttl $SOURCEDIR/bkp/

sed -i '' -e 's/<http:\/\/dbpedia.org\/resource\//dbr_/g' $SOURCEDIR/*_lc.txt
sed -i '' -e 's/<http:\/\/www.w3.org\/2000\/01\/rdf-schema#/rdfs_/g' $SOURCEDIR/*_lc.txt
sed -i '' -e 's/<http:\/\/xmlns.com\/foaf\/0.1\//foaf_/g' $SOURCEDIR/*_lc.txt
sed -i '' -e 's/<http:\/\/schema.org\//schema_/g' $SOURCEDIR/*_lc.txt
sed -i '' -e 's/<http:\/\/purl.org\/dc\/terms/dc_/g' $SOURCEDIR/*_lc.txt
sed -i '' -e 's/<http:\/\/purl.org\/dc\/elements\/1.1\//dc_/g' $SOURCEDIR/*_lc.txt
sed -i '' -e 's/<http:\/\/www.w3.org\/2004\/02\/skos\/core#/skos_/g' $SOURCEDIR/*_lc.txt
sed -i '' -e 's/<http:\/\/dbpedia.org\/ontology\//dbo_/g' $SOURCEDIR/*_lc.txt
sed -i '' -e 's/<http:\/\/de.dbpedia.org\/property\//dbp_/g' $SOURCEDIR/*_lc.txt
sed -i '' -e 's/<http:\/\/dbpedia.org\/datatype\//dbt_/g' $SOURCEDIR/*_lc.txt
sed -i '' -e 's/<http:\/\/www.w3.org\/2002\/07\/owl#/owl_/g' $SOURCEDIR/*_lc.txt
sed -i '' -e 's/<http:\/\/www.w3.org\/1999\/02\/22-rdf-syntax-ns#/rdf_/g' $SOURCEDIR/*_lc.txt
sed -i '' -e 's/@en//g'  $SOURCEDIR/*_lc.txt
sed -i '' -e '/ontologydesignpatterns/d'  $SOURCEDIR/*_lc.txt
sed -i '' -e '/foaf_homepage/d'  $SOURCEDIR/*_lc.txt
sed -i '' -e '/wikidata_/d'  $SOURCEDIR/*_lc.txt
sed -i '' -e '/schema_/d'  $SOURCEDIR/*_lc.txt
sed -i '' -e 's/^^rdf_langString//g'  $SOURCEDIR/*_lc.txt
sed -i '' -e 's/\.//g' $SOURCEDIR/*_lc.txt
sed -i '' -e 's/>//g' $SOURCEDIR/*_lc.txt
sed -i '' -e 's/"//g' $SOURCEDIR/*_lc.txt
sed -i '' -e '/http:\/\//d' $SOURCEDIR/*_lc.txt
sed -i '' -e '/%3f/d' $SOURCEDIR/*_lc.txt
sed -i '' -e '/%/d' $SOURCEDIR/*_lc.txt
awk '{printf "__label__"$1" "; for(i=2;i<=NF;i++){printf $i" "}print ""}' <$SOURCEDIR/labels_"$SOURCEDIR"_lc.txt > $SOURCEDIR/labels_"$SOURCEDIR"_lc_new.txt
rm -rf $SOURCEDIR/labels_"$SOURCEDIR"_lc.txt
awk 'FNR==1{print ""}{print}' $SOURCEDIR/* > $SOURCEDIR/all_"$SOURCEDIR"_.txt

./fastText-0.9.1/fasttext supervised -input $SOURCEDIR/all_"$SOURCEDIR"_.txt -output $SOURCEDIR/all_'$SOURCEDIR'_model -minn 2 -maxn 5 -dim 500 -thread 12 -ws 50 -loss hs

tr A-Z a-z < $TARGETDIR/instance_types_"$TARGETDIR".ttl > $TARGETDIR/instance_types_"$TARGETDIR"_lc.txt
tr A-Z a-z < $TARGETDIR/labels_"$TARGETDIR".ttl > $TARGETDIR/labels_"$TARGETDIR"_lc.txt
tr A-Z a-z < $TARGETDIR/mappingbased_objects_"$TARGETDIR".ttl > $TARGETDIR/mappingbased_objects_"$TARGETDIR"_lc.txt

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
sed -i '' -e '/%3f/d' $TARGETDIR/*_lc.txt
sed -i '' -e '/%/d' $TARGETDIR/*_lc.txt
awk '{printf "__label__"$1" "; for(i=2;i<=NF;i++){printf $i" "}print ""}' <$TARGETDIR/labels_'$TARGETDIR'_lc.txt > $TARGETDIR/labels_'$TARGETDIR'_lc_new.txt
rm -rf $TARGETDIR/labels_"$TARGETDIR"_lc.txt
awk 'FNR==1{print ""}{print}' $TARGETDIR/* > $TARGETDIR/all_'$TARGETDIR'_.txt

./fastText-0.9.1/fasttext supervised -input $TARGETDIR/all_"$TARGETDIR"_.txt -output $TARGETDIR/all_'$TARGETDIR'_model -minn 2 -maxn 5 -dim 500 -thread 12 -ws 50 -loss hs
