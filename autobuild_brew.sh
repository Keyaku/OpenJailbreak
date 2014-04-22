#!/bin/bash
# DarkMalloc 22/09/2013 - sorry for hacked up shit, really tired and cba to do this properly atm
# Edited by Keyaku to make installation happen in the Cellar (for Homebrew)
# build script for OpenJailbreak (most libs)


requiredKegs=( "openssl" "libtool" "zlib" "libplist" )
libs=( "libusbmuxd-1" "libimobiledevice-1" "libcrippy-1" "libmacho-1" \
	"libdyldcache-1" "libimg3-1" "libirecovery-2" "libmbdb-1" "libpartialzip-1" \
	"libtss-1" "libipsw-1" "libidevicebackup-1-0" "libidevicecrashreport-1" "libsyringe-1" )
cellar=/usr/local/Cellar

requirements() {
	# Homebrew already provides a working libplist keg; we shall use it
	echo "Checking if required packages are installed..."
	for i in "${requiredKegs[@]}"; do
		if [ ! -e $cellar/$i ]; then brew install $i; fi
	done
}

build_all_libs() {
	# Starting installation of all OpenJailbreak libs
	for i in "${libs[@]}"; do
		# Grabbing the lib's name
		kegName=$(echo $i | sed 's/-.*//')
		echo "Fetching $kegName..."
		git clone git://openjailbreak.org/${i}.git
		cd $i
		# If configure.ac file exists, use the version that it provides (ugliest way but also the quickest)
		if [ -e configure.ac ]; then
			kegVersion=$(cat configure.ac | grep "AC_INIT" | cut -d',' -f2 | sed 's/ //' | sed 's/).*//')
		else # use the number from the package's name instead (less accurate)
			kegVersion=$(echo $i | sed 's/.*-//').0
		fi
		# Setting the keg's place
		kegDir=$cellar/$kegName/$kegVersion
		# If the keg is up-to-date, skip it
		if [ -d $kegDir ]; then
			echo -e "$(brew ls $kegName --versions) is already installed and updated. Skipping.\n"
			continue
		fi
		echo "Configuring $kegName..."
		./autogen.sh > /dev/null # Makes less visual trash
		./configure --prefix=$kegDir
		echo "Building $kegName..."
		make && make install
		echo "Installing $kegName..."
		brew link $kegName
		# Prevents any (possible) mistake from OpenJailbreak's scripts to "cd .." more/less than enough
		cd $OJHome
	done
}

function main {
	OJHome=$(pwd)
	requirements
	case $# in
		0) echo "usage: ./autobuild_brew.sh" 
		;;
		1)
		;;
	esac
	build_all_libs
}

echo "OpenJailbreak library build script - DarkMalloc 2013"
echo "Homebrew (kegs) version - Keyaku 2014"
main
