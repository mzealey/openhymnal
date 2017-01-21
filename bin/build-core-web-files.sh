#!/bin/sh
#######################################################################
#     This is a script to alter the *-core.html files, building the 
# base files for the Web site
#
# Uses these scripts:
# ohroot
# build-newgenindex.pl
# build-topical-index.pl
#
# it makes these files:
# Web/Build/*-core.html
#
# version 1.0 18 Mar 2013
#######################################################################
OHROOT=`ohroot`
${OHROOT}bin/build-newhymnindex.pl > ${OHROOT}Web/Build/new-core.html &
${OHROOT}bin/build-peopleindex.pl > ${OHROOT}Web/Build/people-core.html &
${OHROOT}bin/build-tuneindex.pl > ${OHROOT}Web/Build/tune-core.html &
${OHROOT}bin/build-metrical-index.pl > ${OHROOT}Web/Build/metrical-core.html &
${OHROOT}bin/build-topical-index.pl &
${OHROOT}bin/build-scripture-index.pl &
${OHROOT}bin/build-all-lyrics &

# This one makes the general index, which is used by later scripts, so don't background this one
${OHROOT}bin/build-newgenindex.pl > ${OHROOT}Web/Build/genindex-core.html 

