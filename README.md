KG-NMT - Knowledge Graph-augmented NMT
=========

### About
This project aims at delivering a framework which uses knowledge graphs into Neural Networks for augmenting the translation of entities in texts.

### Required steps 

Please first run

```
./install.sh
./download_data.sh en de - it is for reproducing the results from our paper

```

### Running steps 

If you want to run the first strategy of KG-NMT which relies on the use of Knowledge Graph embeddigns with Entity Link task, you should run
```
1. ./kg-nmt_KGE+EL_workflow.sh
```

In case you want to run the second strategy of KG-NMT which relies on the use of Knowledge Graph embeddigns enriched with textual descriptions, please run
```
2. ./kg-nmt_SemKGE_workflow.sh
```

### KGE creation separately 

In case you prefer to create the knowledge graph embeddings before training it along with the NMT, you can run the code below for the KGE without textual descriptions.
```
1. ./KGE_creation.sh language
```
Or the one with textual descriptions. 

```
2. ./SemKGE_creation.sh language
```
 
### Structure

KG-NMT currently consists of the following modules:

1. OpenNMT-py - NMT submodule component, you can change it for a tensorflow implementation or another NMT system
2. fastText - responsible for creating knowledge graph embeddings, you can also change it for another KGE implementation
3. KG-NMT workflows - they are responsible for creating both strategies described in our paper
4. Entiy Linker - the component responsible for annotating the entities in the billingual parallel corpora, you can also replace for another EL system.

### Structure

All data pertaining to our publication can be found and downloaded via the command below
```
wget -r --no-parent https://hobbitdata.informatik.uni-leipzig.de/KG-NMT ;
```

### Support and Feedback
If you need help or you have questions do not hesitate to write an email to  <a href="mailto:diego.moussallem@uni-paderborn.de">Diego Moussallem</a>. Or use the issue tracker in the right sidebar.

