#!/bin/bash -e

make clean
summon -f secrets.test.yml make crd/install

summon -f secrets.test.yml make app/build
summon -f secrets.test.yml make app/verify
