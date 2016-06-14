#!/bin/bash
if [ $# -eq 0 ]
  then
    echo "No arguments supplied, specify DB archive to extract to neo4j."
    exit
fi

dbArchive=$1
echo "Using '$dbArchive' as input"
neo4jDir="/Applications/neo4j-community-2.2.9"
currentDir=pwd

mkdir tmp
tar -xf $dbArchive -C tmp
rm -r $neo4jDir/data/*
mkdir $neo4jDir/data/graph.db
cp -r tmp/* $neo4jDir/data/graph.db
rm -r tmp
echo "DB copied to $neo4jDir/data"