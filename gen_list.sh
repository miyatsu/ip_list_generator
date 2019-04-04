#!/bin/sh
#
# Copyright (C) 2019 Ding Tao <i@dingtao.org>
#
# SPDX-License-Identifier: GPL-3.0
#
# @file gen_list.sh
#
# IP list generator used to generate all allocated IP address by IANA and
# classify them by region/company etc.

registry_array="afrinic apnic arin lacnic ripencc"

# US: United States	# CN: China		# JP: Japan		# GB: United Kingdom
# DE: Germany		# KR: Korea, South	# FR: France		# CA: Canada
# IT: Italy		# BR: Brazil		# AU: Australia		# NL: Netherlands
# RU: Russia		# TW: Taiwan		# IN: India		# SE: Sweden
# ES: Spain		# MX: Mexico		# CH: Switzerland	# ZA: South Africa
# PL: Poland		# ID: Indonesia		# VN: Vietnam		# TR: Turkey
# NO: Norway		# AR: Argentina		# FI: Finland		# RO: Romania
# DK: Denmark		# HK: Hong Kong		# AT: Austria		# UA: Ukraine
# BE: Belgium		# CO: Colombia		# TH: Thailand
region_array="US CN JP GB DE KR FR CA IT BR AU NL RU TW IN SE ES MX CH ZA PL \
	ID VN TR NO AR FI RO DK HK AT UA BE CO TH"

iana_download() {
	# Download delegated list from 5 registries
	wget -O afrinic.list https://ftp.afrinic.net/pub/stats/afrinic/delegated-afrinic-latest
	wget -O apnic.list http://ftp.apnic.net/stats/apnic/delegated-apnic-latest
	wget -O arin.list https://ftp.arin.net/pub/stats/arin/delegated-arin-latest
	wget -O lacnic.list https://ftp.lacnic.net/pub/stats/lacnic/delegated-lacnic-latest
	wget -O ripencc.list https://ftp.ripe.net/pub/stats/ripencc/delegated-ripencc-latest

	# Merge and make "iana_v4.list" & "iana_v6.list"
	cat afrinic.list > iana.list
	cat apnic.list >> iana.list
	cat arin.list >> iana.list
	cat lacnic.list >> iana.list
	cat ripencc.list >> iana.list
	rm afrinic.list apnic.list arin.list lacnic.list ripencc.list
	cat iana.list | grep ipv4 > iana_v4.list
	cat iana.list | grep ipv6 > iana_v6.list
	rm iana.list


	# Download delegated extended list from 5 registries
	wget -O afrinic-extended.list https://ftp.afrinic.net/pub/stats/afrinic/delegated-afrinic-extended-latest
	wget -O apnic-extended.list http://ftp.apnic.net/stats/apnic/delegated-apnic-extended-latest
	wget -O arin-extended.list https://ftp.arin.net/pub/stats/arin/delegated-arin-extended-latest
	wget -O lacnic-extended.list https://ftp.lacnic.net/pub/stats/lacnic/delegated-lacnic-extended-latest
	wget -O ripencc-extended.list https://ftp.ripe.net/pub/stats/ripencc/delegated-ripencc-extended-latest

	# Merge and make "iana-extended_v4.list" & "iana-extended_v6.list"
	cat afrinic-extended.list > iana-extended.list
	cat apnic-extended.list >> iana-extended.list
	cat arin-extended.list >> iana-extended.list
	cat lacnic-extended.list >> iana-extended.list
	cat ripencc-extended.list >> iana-extended.list
	rm afrinic-extended.list apnic-extended.list arin-extended.list lacnic-extended.list ripencc-extended.list
	cat iana-extended.list | grep ipv4 > iana-extended_v4.list
	cat iana-extended.list | grep ipv6 > iana-extended_v6.list
	rm iana-extended.list

	# Merge extended to normal
	cat iana-extended_v4.list >> iana_v4.list
	cat iana-extended_v6.list >> iana_v6.list
	rm iana-extended_v4.list iana-extended_v6.list
}


gen_region_v4_list() {
	region=${1}

	cat iana_v4.list | grep ipv4 | grep ${region} | awk -F\| {'	\
		if (1 == $5) printf("%s/32\n", $4);			\
		else if (2 == $5) printf("%s/31\n", $4);		\
		else if (4 == $5) printf("%s/30\n", $4);		\
		else if (8 == $5) printf("%s/29\n", $4);		\
		else if (16 == $5) printf("%s/28\n", $4);		\
		else if (32 == $5) printf("%s/27\n", $4);		\
		else if (64 == $5) printf("%s/26\n", $4);		\
		else if (128 == $5) printf("%s/25\n", $4);		\
		else if (256 == $5) printf("%s/24\n", $4);		\
		else if (512 == $5) printf("%s/23\n", $4);		\
		else if (1024 == $5) printf("%s/22\n", $4);		\
		else if (2048 == $5) printf("%s/21\n", $4);		\
		else if (4096 == $5) printf("%s/20\n", $4);		\
		else if (8192 == $5) printf("%s/19\n", $4);		\
		else if (16384 == $5) printf("%s/18\n", $4);		\
		else if (32768 == $5) printf("%s/17\n", $4);		\
		else if (65535 == $5) printf("%s/16\n", $4);		\
		else if (131072 == $5) printf("%s/15\n", $4);		\
		else if (262144 == $5) printf("%s/14\n", $4);		\
		else if (524288 == $5) printf("%s/13\n", $4);		\
		else if (1048576 == $5) printf("%s/12\n", $4);		\
		else if (2097152 == $5) printf("%s/11\n", $4);		\
		else if (4194304 == $5) printf("%s/10\n", $4);		\
		else if (8388608 == $5) printf("%s/9\n", $4);		\
		else if (16777216 == $5) printf("%s/8\n", $4);		\
		else if (33554432 == $5) printf("%s/7\n", $4);		\
		else if (67108864 == $5) printf("%s/6\n", $4);		\
		else if (134217728 == $5) printf("%s/5\n", $4);		\
		else if (268435456 == $5) printf("%s/4\n", $4);		\
		else if (536870912 == $5) printf("%s/3\n", $4);		\
		else if (1073741824 == $5) printf("%s/2\n", $4);	\
		else if (2147483648 == $5) printf("%s/1\n", $4);	\
			'} > region_${region}_ipv4_unoptimize.list

	if [ ! -e region ]
	then
		mkdir region
	fi

	iprange --optimize <region_${region}_ipv4_unoptimize.list > region/ipv4_${region}_unsort.list
	rm region_${region}_ipv4_unoptimize.list

	cat region/ipv4_${region}_unsort.list | sort -n -t "/" -k 2 > region/ipv4_${region}.list
	rm region/ipv4_${region}_unsort.list
}

#iana_download 

gen_v4_list () {
	for region in $region_array
	do
		gen_region_v4_list ${region}
	done
}

gen_v4_set () {
	for region in $region_array
	do
		for net_item in `cat region/ipv4_${region}.list`
		do
			# Do ipset add operation here
			true
		done
	done
}

gen_v4_list


gen_v4_set

