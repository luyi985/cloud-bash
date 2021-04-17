#!/bin/bash
source variables.sh;
variablesFile="$(pwd)/variables.sh";
utilsFile="$(pwd)/utils.sh";

function ubuntuInit() {
    sudo apt-get update &&
    sudo apt-get upgrade
}

function load() {
     if [ -f ${variablesFile} ]; then
        echo "source ${variablesFile}"
        source ${variablesFile}
    fi

    if [ -f ${utilsFile} ]; then
        echo "source ${utilsFile}"
        source ${utilsFile}
    fi
}

function init() {
    if [ -f ${variablesFile} ]; then
        echo "load ${variablesFile}"
        echo "source ${variablesFile}" >> $remoreBashRcPath
    fi

    if [ -f ${utilsFile} ]; then
        echo "load ${utilsFile}"
        echo "source ${utilsFile}" >> $remoreBashRcPath
    fi
} 
