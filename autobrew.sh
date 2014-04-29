#!/bin/bash
# DarkMalloc 22/09/2013 - sorry for hacked up shit, really tired and cba to do this properly atm
# Edited by Keyaku to make installation happen in the Cellar (for Homebrew)
# build script for OpenJailbreak (most libs)


# LIBRARIES
requiredKegs=( "openssl" "libtool" "zlib" "libplist" )
mainLibs=( "libusbmuxd-1" "libimobiledevice-1" "libcrippy-1" "libmacho-1" \
	"libdyldcache-1" "libimg3-1" "libirecovery-2" "libmbdb-1" "libpartialzip-1" \
	"libtss-1" "libipsw-1" "libidevicebackup-1-0" "libidevicecrashreport-1" "libsyringe-1" )

# PATHS
cellar=/usr/local/Cellar
OJHome=$(pwd)

# LINKS
libSrc="git://openjailbreak.org"
pingableHost="google.com"

# STRINGS
welcomeMsg="OpenJailbreak library build script - DarkMalloc 2013\n\
Homebrew (kegs) version - Keyaku 2014\n"
usage="usage: $0 [help] ([OpenJailbreak Lib])\n" 
unsufArgs="Not enough arguments."
invalidArgs="Invalid arguments."
conclusion="\nTo uninstall a lib, execute the \"uninstall\" argument with brew, followed \
by the lib name.\nHere's an example:\n\
\tbrew uninstall ${mainLibs[$(((RANDOM/1000)%10))]}"

# STATUS
RET_success=0
RET_error=1
RET_invalid=2
RET_help=3
RET_exists=4
RET_pingError=68
noInternet=0


# FUNCTIONS
check_for_connect() {
	ping -t 1 $pingableHost > /dev/null 2>&1
	if [ $? -eq $RET_pingError ]; then
		noInternet=1
		echo -e "No internet connection found. Using local stuff.\n"
	fi
}

check_args() {
	# Checks for the available arguments, makes stuff out of them, returns the appropriate
	#function to call
	
	if [ -n $(echo $* | grep "help") ]; then
		return $RET_help
	elif [ $(echo ${mainLibs[@]} | grep $*) ]; then
		return $RET_success
	else
		return $RET_invalid
	fi
}

requirements() {
	# Homebrew already provides a working libplist keg; we shall use it
	echo "Checking if required packages are installed..."
	for i in "${requiredKegs[@]}"; do
		if [ ! -e $cellar/$i ]; then brew install $i; fi
	done
	echo -e "All required packages are installed!\n"
}

# Packages management
grab_package() {
	if [ ! -d ./$keg ]; then
		echo -e "Fetching $keg..."
		git clone $libSrc/${keg}.git
	else
		echo -e "$keg already fetched (directory exists)."
	fi
}

prep_package() {
	# If configure.ac file exists, use the version that it provides (ugliest way but also the quickest)
	if [ -e configure.ac ]; then
		kegVersion=$(cat configure.ac | grep "AC_INIT" | cut -d',' -f2 | sed 's/ //' | sed 's/).*//')
	else # use the number from the package's name instead (less accurate)
		kegVersion=$(echo $keg | sed 's/.*-//').0
	fi
	# Setting the keg's place in the Cellar
	kegDir=$cellar/$kegName/$kegVersion
	# If the keg exists...
	if [ -d $kegDir ]; then
		# If it is up-to-date, skip it
		if [ $kegVersion != $(ls $cellar/$kegName/)  ]; then
			echo -e "$(brew ls $kegName --versions) is already installed and updated. Skipping.\n"
			return $RET_exists
		fi
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

# Lib(s) building
build_libs() {
	check_for_connect
	requirements
	
	for keg in ${libs[@]}; do
		# Grabbing the lib's name
		kegName=$(echo $keg | sed 's/-.*//')
		
		# Grab our package! (only if there's internet)
		if [ $noInternet == 0 ]; then grab_package; fi
		
		if [ -d $keg ]; then
			# Prepare our package!
			cd $keg
			prep_package
			# INSTALL DAT SHIT (... only if it's not installed)
			if [ $? != $RET_exists ]; then install_package; fi
		fi
		
		# Prevents any (possible) mistake from OJ's scripts for doing "cd .." more/less than enough
		cd $OJHome
	done
	
	return $RET_success
}


# MAIN
function main {
	# First checks if the user has put too much gibberish as arguments
	if [ $# -gt $(echo "${mainLibs[@]}" | wc -w) ]; then
		echo -e $invalidArgs; echo -e $usage
	fi
	
	case $# in
		# No arguments == builds all available libraries
		0)	libs=( ${mainLibs[@]} )
			build_libs
			;;
		# 1+ argument == runs check_args and whatever command is given by it
		*)	check_args
			case $? in
				$RET_success)
					libs=( $@ )
					build_libs
					;;
				$RET_help)
					echo -e $usage
					;;
				$RET_invalid) 
				echo -e $invalidArgs; echo -e $usage
					;;
			
			esac
			;;
	esac
	
	#echo -e $conclusion
}

# Script starts HERE
echo -e $welcomeMsg
main $*
