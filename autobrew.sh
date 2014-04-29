#!/bin/bash
# DarkMalloc 22/09/2013 - sorry for hacked up shit, really tired and cba to do this properly atm
# Edited by Keyaku to make installation happen in the Cellar (for Homebrew)
# build script for OpenJailbreak (most libs)


# Libraries
requiredKegs=( "openssl" "libtool" "zlib" "libplist" )
mainLibs=( "libusbmuxd-1" "libimobiledevice-1" "libcrippy-1" "libmacho-1" \
	"libdyldcache-1" "libimg3-1" "libirecovery-2" "libmbdb-1" "libpartialzip-1" \
	"libtss-1" "libipsw-1" "libidevicebackup-1-0" "libidevicecrashreport-1" "libsyringe-1" )

# Paths
cellar=/usr/local/Cellar
OJHome=$(pwd)

# Links
libSrc="git://openjailbreak.org"

# Strings
welcomeMsg="OpenJailbreak library build script - DarkMalloc 2013\n\
Homebrew (kegs) version - Keyaku 2014\n"
usage="usage: ./$0 ([OpenJailbreak Lib])" 
unsufArgs="Not enough arguments."
invalidArgs="Invalid arguments."
conclusion="To uninstall a lib, execute the \"uninstall\" argument with brew, followed by \
the lib name.\nHere's an example:\n \
brew uninstall ${mainLibs[$(((RANDOM/1000)%10))]}"


# Functions
check_args() {
	# Checks for the available arguments, makes stuff out of them, returns the appropriate
	#function to call
	if [ $(echo $1 | grep "help") ]; then
		callMeUp="echo $usage"
	elif [ $(echo ${mainLibs[@]} | grep $*) ]; then
		libs=( $@ )
		callMeUp="build_libs ${libs[@]}"
	else
		callMeUp="echo $invalidArgs"
	fi
	
	return $callMeUp
}

requirements() {
	# Homebrew already provides a working libplist keg; we shall use it
	echo "Checking if required packages are installed..."
	for i in "${requiredKegs[@]}"; do
		if [ ! -e $cellar/$i ]; then brew install $i; fi
	done
}

prep_package() {
	# Grabbing the lib's name
	kegName=$(echo $keg | sed 's/-.*//')
	echo "Fetching $kegName..."
	if [ ! -d ./$keg ]; then git clone $libSrc/${keg}.git; fi
	cd $keg
	# If configure.ac file exists, use the version that it provides (ugliest way but also the quickest)
	if [ -e configure.ac ]; then
		kegVersion=$(cat configure.ac | grep "AC_INIT" | cut -d',' -f2 | sed 's/ //' | sed 's/).*//')
	else # use the number from the package's name instead (less accurate)
		kegVersion=$(echo $keg | sed 's/.*-//').0
	fi
	# Setting the keg's place in the Cellar
	kegDir=$cellar/$kegName/$kegVersion
	# If the keg is up-to-date, skip it
	if [ -d $kegDir ]; then
		echo -e "$(brew ls $kegName --versions) is already installed and updated. Skipping.\n"
		continue
	fi
}

install_package() {
	echo "Configuring $kegName..."
	./autogen.sh > /dev/null		# Makes less visual garbage
	./configure --prefix=$kegDir
	echo "Building $kegName..."
	make && make install
	echo "Installing $kegName..."
	brew link $kegName
}

build_libs() {
	for keg in "${libs[@]}"; do
		# Prepare our package!
		prep_package
		# Install it!
		install_package
		
		# Prevents any (possible) mistake from OJ's scripts for doing "cd .." more/less than enough
		cd $OJHome
	done
	
	echo $conclusion
}


# MAIN
function main {
	# First checks if the user has put too much gibberish as arguments
	if [ $# -gt $(echo "${mainLibs[@]}" | wc -w) ]; then
		echo $invalidArgs; echo $usage
	fi
	requirements
	case $# in
		# No arguments == builds all available libraries
		0)	libs=( ${mainLibs[@]} )
			build_libs
			;;
		# 1+ argument == runs check_args and whatever command is given by it
		*)	check_args
			$?	# Runs the "returned" command by check_args
			;;
	esac
}

# Script starts HERE
echo -e $welcomeMsg
main
