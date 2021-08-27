#!/usr/bin/env bash

git submodule add https://github.com/nikit91/OpenNMT-py
git submodule init
git submodule update
git clone --recurse-submodules https://github.com/nikit91/OpenNMT-py
pip3 install -r requirements.txt
python3 -m spacy download en
python3 -m spacy download de
pip3 install -r OpenNMT-py/requirements.txt
