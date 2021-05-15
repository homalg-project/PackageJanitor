#!/bin/bash

while read repo; do
	
	echo $repo
	
	xdg-open "https://github.com/homalg-project/$repo/actions"
	
done <hosts
