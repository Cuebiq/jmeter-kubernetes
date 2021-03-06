#!/usr/bin/env bash
#Script created to launch Jmeter tests directly from the current terminal without accessing the jmeter master pod.
#It requires that you supply the path to the jmx file
#After execution, test script jmx file may be deleted from the pod itself but not locally.

working_dir=`pwd`

#Get namesapce variable
tenant=`awk '{print $NF}' $working_dir/tenant_export`

read -p 'Enter path to the jmx file ' jmx

read -p 'Enter path to the csv data file ' csv

if [ ! -f "$jmx" ];
then
    echo "Test script file was not found in PATH"
    echo "Kindly check and input the correct file path"
    exit
fi


if [ ! -f "$csv" ];
then
    echo "CVS file was not found in PATH"
    echo "Kindly check and input the correct file path"
    exit
fi

#Get Master pod details

master_pod=`kubectl get po -n $tenant | grep jmeter-master | awk '{print $1}'`

kubectl cp $jmx -n $tenant $master_pod:/$jmx

kubectl cp $jmx -n $tenant $master_pod:/$csv

kubectl cp load_test_with_csv.sh -n $tenant $master_pod:/load_test_with_csv.sh
kubectl cp load_test_with_csv.sh -n $tenant $master_pod:/jmeter/load_test_with_csv.sh



## Echo Starting Jmeter load test

kubectl exec -ti -n $tenant $master_pod -- sh /jmeter/load_test_with_csv.sh $jmx $csv


