#!/bin/bash

mkdir -p packages
rm packages/*.tar
cd bind9
tar -cvf ../packages/bind9.tar *
cd ../bono
tar -cvf ../packages/bono.tar *
cd ../dime
tar -cvf ../packages/dime.tar *
cd ../ellis
tar -cvf ../packages/ellis.tar *
cd ../fhoss
tar -cvf ../packages/fhoss.tar *
cd ../homer
tar -cvf ../packages/homer.tar *
cd ../sprout
tar -cvf ../packages/sprout.tar *
cd ../vellum
tar -cvf ../packages/vellum.tar *
