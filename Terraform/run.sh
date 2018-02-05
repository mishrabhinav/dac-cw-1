#!/bin/bash
while IFS='' read -r line || [[ -n "$line" ]]; do
	ssh -oStrictHostKeyChecking=no -i ~/.ssh/digital_rsa root@$line 'bash -s' < "$3/peer.sh" > peer-$line.txt
done < "$1"

while IFS='' read -r line || [[ -n "$line" ]]; do
	ssh -oStrictHostKeyChecking=no -i ~/.ssh/digital_rsa root@$line 'bash -s' < "$3/system.sh" > system-$line.txt
done < "$2"
