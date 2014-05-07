#!/bin/bash
# DarkMalloc 22/09/2013 - sorry for hacked up shit, really tired and cba to do this properly atm
# Edited by Keyaku to make installation happen in the Cellar (for Homebrew)
# build script for OpenJailbreak (most libs)


# LIBRARIES
requiredKegs=( "openssl" "libtool" "zlib" "libplist" )
mainLibs=( "libusbmuxd-1" "libimobiledevice-1" "libcrippy-1" "libmacho-1" \
	"libdyldcache-1" "libimg3-1" "libirecovery-2" "libmbdb-1" "libpartialzip-1" \
	"libtss-1" "libipsw-1" "libidevicebackup-1-0" "libidevicecrashreport-1" "libsyringe-1" )
failedLibs=""

# PATHS
cellar=/usr/local/Cellar
OJHome=$(pwd)

# LINKS
libSrc="git://openjailbreak.org"
pingableHost="google.com"
keyakuOJ="https://github.com/Keyaku/OpenJailbreak"

# STRINGS
welcomeMsg="\nOpenJailbreak library build script - DarkMalloc 2013\n\
Homebrew (kegs) version - Keyaku 2014\n"
usage="usage: $0 [help] [OpenJailbreak Lib(s)]\n"
installBrew="ruby -e \"\$(curl -fsSL https://raw.github.com/Homebrew/homebrew/go/install)\""
noBrew="Homebrew is not installed.\nTo install it quickly (Xcode & CLT must be installed), run this: \
\n\n\t$installBrew \
\n\nVisit http://brew.sh/ for more information."
invalidArgs="Invalid arguments."
failedInstall="\nThese libs failed to install: "
conclusion="\nInstallation complete.\nTo uninstall a lib, execute the \"uninstall\" \
argument with brew, followed by the lib name.\nHere's an example:\n\
\tbrew uninstall ${mainLibs[$(((RANDOM/1000)%10))]} \n"

# STATUS
RET_success=0
RET_error=1
RET_invalid=2
RET_help=3
RET_exists=4
RET_install=5
RET_hasBrew=10
RET_hasNoBrew=11
RET_pingError=68
noInternet=0

# COLORS
BGre='\e[1;32m';	# Bold Green



# FUNCTIONS

check_for_brew() {
	# Checks for Homebrew
	if [ ! -e /usr/local/bin/brew ]; then
		return $RET_hasNoBrew
	fi
	
	return $RET_hasBrew
}

check_for_connect() {
	ping -c1 $pingableHost > /dev/null 2>&1
	if [ $? -eq $RET_pingError ]; then
		noInternet=1
		echo -e "No internet connection found. Using local stuff.\n"
	fi
}

check_stuff() {
	# Checks for required installs, connection to the internet, and many more
	
	# First things first: check if user has asked for help.
	if [ "$(echo $* | grep help)" ]; then
		echo -e $usage; exit $RET_help
	fi
	
	# If we are to download stuff: check for internet.
	check_for_connect
	
	if [ $noInternet -eq 1 ]; then
		# Then, check for Homebrew.
		check_for_brew
		# If Homebrew isn't installed, why on Earth are you running this script, dawg?!
		if [ $? -eq $RET_hasNoBrew ]; then
			echo -e $noBrew; exit $RET_hasNoBrew
		fi
	fi
	
	# Check for required kegs to be installed before digging into OJ libs installation
	requirements
	
	# After that, checks if the user has put more arguments than available libraries
	if [ $# -gt $(echo "${mainLibs[@]}" | wc -w) ]; then
		echo -e "$invalidArgs \n$usage"; exit $RET_invalid
	fi
}

requirements() {
	# Homebrew already provides a working libplist keg; we shall use it
	echo "Checking if required packages are installed..."
	for i in "${requiredKegs[@]}"; do
		if [ ! -e $cellar/$i -a $noInternet -eq 0 ]; then brew install $i; fi
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
	echo -e "Configuring $kegName..."
	./autogen.sh > /dev/null		# Makes less visual garbage
	./configure --prefix=$kegDir
	echo -e "Building $kegName..."
	make && make install
	# Let's check if the installation was successful
	if [ -d $kegDir ]; then
		echo -e "Installing $kegName..."
		brew link $kegName
	else
		failedLibs=$failedLibs\ "$kegName"
	fi
}

# Lib(s) building
build_libs() {
	for keg in ${libs[@]:-$(echo ${mainLibs[@]})}; do
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
	
	if [ -z $failedLibs ]; then return $RET_success
	else return $RET_error; fi
}

which_libs() {
	libs=""
	for arg in $@; do
		if [ -z "$(echo ${mainLibs[@]} | grep $arg)" ]; then
			echo -e "Library $arg doesn't exist. Ignoring this argument.\n"
			continue
		fi
		lib_temp=$(echo ${mainLibs[@]} | sed 's/.*'$arg'/'$arg'/' | cut -d' ' -f1)
		libs=$libs\ "$lib_temp"
	done
	if [ ! $libs ]; then
		echo -e "No valid libs found in arguments. Aborting.\n"
		exit $RET_invalid
	fi
}


# MAIN
function main {
	# Our main checking system. Checks for stuff, and only once.
	check_stuff $@
	
	# If we have one or more arguments, find out which are valid libs
	if [ $# -gt 0 ]; then which_libs $@; fi
	build_libs
	
	if [ $? -eq $RET_error ]; then
		echo -e $failedInstall
		for fail in ${failedLibs[@]}; do
			echo -e "- $fail\n"
		done
		echo -e "Check what went wrong. If you can't do anything about it, file an issue \
in my Github project page: \n\t$keyakuOJ\n"
		exit $RET_error
	else
		echo -e $conclusion
		exit $RET_succes
	fi
}

# Script starts HERE
echo -e $welcomeMsg
main $*
