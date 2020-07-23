#!/bin/bash
# Use this script to load config to solr:5.5.5  
counter=1
for (( c=1; c<=10; c++ ))
do
   date -u
   echo " validating solr health check"
   curl "http://solr-svc:8983/solr/admin/collections?action=clusterstatus"
   if [ $? -eq 0 ]
   then
    echo "health check  successful"
    break
   else
    echo "health check failed , will retry in 60 seconds"
    c=$c+1
    sleep 60
   fi
done

if [ c = 10 ]
then
exit 1
fi
date -u
echo "attempting to write config to solr-zookeeper"
/opt/solr/server/scripts/cloud-scripts/zkcli.sh -cmd upconfig -zkhost solr-zookeeper -confname $CONFNAME -confdir /tmp/config/
if [ $? -eq 0 ]
then
echo "config load successful"
fi
echo "$date attempting to create collection"
curl "http://solr-svc:8983/solr/admin/collections?action=CREATE&name=$COLLECTIONNAME&numShards=1&replicationFactor=3&maxShardsPerNode=1&collection.configName=$CONFIG"
