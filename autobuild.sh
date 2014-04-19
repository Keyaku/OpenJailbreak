#!/bin/bash
# DarkMalloc 22/09/2013 - sorry for hacked up shit, really tired and cba to do this properly atm
# build script for OpenJailbreak (all libs)


successlibs=()
failedlibs=()
libs=( "libplist-1" "libusbmuxd-1" "libimobiledevice-1" "libcrippy-1" "libmacho-1" \
	"libdyldcache-1" "libimg3-1" "libirecovery-2" "libmbdb-1" "libpartialzip-1" \
	"libtss-1" "libipsw-1" "libidevicebackup-1-0" "libidevicecrashreport-1" "libsyringe-1" )

spinner() {
    local pid=$1
    local delay=0.75
    local spinstr='|/-\'
    echo "$pid" > "/tmp/.spinner.pid"
    while [ "$(ps a | awk '{print $1}' | grep $pid)" ]; do
        local temp=${spinstr#?}
        printf " [%c]  " "$spinstr"
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b\b\b\b"
    done
    printf "    \b\b\b\b"
}

buildlibs() {
	for i in "${libs[@]}"
	do
		echo -e "\033[1;32mFetching $i..."
		git clone git://openjailbreak.org/${i}.git
		cd $i
		echo -e "\033[1;32mConfiguring $i..."
		./autogen.sh
		./configure
		echo -e "\033[1;32mBuilding $i..."
		make && sudo make install
		echo -e "\033[1;32mInstalling $i..."
		cd ..
	done
	echo -e "\033[0m"
}

function main {
	buildlibs
}

echo -e "\033[1;37mOpenJailbreak library build script - DarkMalloc 2013"
main
