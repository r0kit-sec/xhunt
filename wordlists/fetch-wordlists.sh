#!/bin/sh

# Run this script from the root source directory
wget https://raw.githubusercontent.com/PortSwigger/param-miner/master/resources/params -O wordlists/portswigger.txt
wget https://wordlists-cdn.assetnote.io/data/automated/httparchive_parameters_top_1m_2022_12_28.txt -O wordlists/assetnote.txt
cat wordlists/portswigger.txt wordlists/assetnote.txt | sort -u > wordlists/all_params.txt
