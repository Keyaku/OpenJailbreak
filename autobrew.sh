#!/bin/bash
# Original script by DarkMalloc - 22/09/2013
# Edited by Keyaku to make installation happen in the Cellar (for Homebrew)
# Build script for OpenJailbreak (most libs)



# COLORS
RCol='\033[0m'					# Text Reset
Red='\033[0;31m'				# Red, for small details
Whi='\033[0;37m'				# White, for small details
Yel='\033[0;33m'				# Yellow, for mid-building
BGre='\033[1;32m'				# Bold Green, for successes
BWhi='\033[1;37m'				# Bold White, when beginning something
BRed='\033[1;31m'				# Bold Red, when an error occurred
BYel='\033[1;33m'				# Bold Yellow, when building stuff
UWhi='\033[4;37m'				# Underline White, for commands
URed='\033[4;31m'				# Underline Red, for warnings
UBlu='\033[4;34m'				# Underline Blue, for links


# ----------------- LIBS, HERE WE GO -----------------

# AVAILABLE KEGS
requiredKegs=( "openssl" "libtool" "zlib" "libplist" "usbmuxd" "libimobiledevice" )


# SUB-LIBRARIES
# -- libabsinthe --
libabsintheSubs=( "libcrippy-1" "libdyldcache-1" "libmacho-1" "libmbdb-1" )

# -- libimobiledevice --
libidevicerestoreSubs=( "idevicerestore-1" "libimg3-1" "libimg4-1" "libipsw-1" "libtss-1" )

libimobiledeviceSubs=( "libcnary-1" "libidevicebackup-1-0" "libidevicecrashreport-1" \
${libidevicerestoreSubs[@]} )

# -- libpois0n --
libanthraxSubs=( "libhfsplus-1" )
libarsenicSubs=( "libdmg-1" )

libpoisonSubs=( ${libanthraxSubs[@]} ${libarsenicSubs[@]} \
"libirecovery-2" "libpartialzip-1" "libsyringe-1"
)

# -- libqmi --
# These are mostly Xcode projects
#libqmiSubs=( "bbtool" "dbltool" "dloadtool" "iosusbenum" )


# LIBRARIES
mainLibs=( ${libabsintheSubs[@]} \
${libimobiledeviceSubs[@]} \
"libpois0n-1" ${libpoisonSubs[@]} \
#"libqmi-1" ${libqmiSubs[@]}
)

# ----------------- END OF LIBS -----------------

# PATHS
cellar=/usr/local/Cellar
OJHome=$(pwd)


# LINKS
gitKeyaku="https://github.com/Keyaku"
keyakuOJ="$gitKeyaku/OpenJailbreak"
libSrcOJ="git://openjailbreak.org"
pingableHost="google.com"
brewWeb="http://brew.sh"
brewWebInstall="https://raw.github.com/Homebrew/homebrew/go/install"


# STRINGS
Warn="${BYel}Warning${Yel}:${RCol}"

Note="${UWhi}Notice${Whi}:${RCol}"

Err="${BRed}Error${Red}:${RCol}"


STR_usage="usage: $0 [help] [OpenJailbreak Lib(s)]\n"

STR_linkTrick="(CMD+Double Click the following link)"

STR_noBrew="$Warn Homebrew is not installed.\nTo install it quickly (Xcode & CLT must be \
installed), run this: \
\n\n\truby -e \"\$(curl -fsSL $brewWebInstall)\" \
\n\nVisit $STR_linkTrick: ${UBlu}$brewWeb${RCol} for more information."

STR_noConnectFound="$Warn No internet connection found. Using local stuff.\n"

STR_invalidArgs="$Warn No valid libs found in arguments. Aborting.\n$STR_usage"

STR_failedInstall="\n$Warn Problems occurred while..."

STR_failedInstallConfirm="Check what went wrong. If necessary, file an issue in \
my Github project page $STR_linkTrick: \
\n\t${UBlu}$keyakuOJ${RCol}\n"

STR_conclusion="\n${BGre}Installation complete${RCol}.\nTo uninstall a lib, execute the \
\"uninstall\" argument with brew, followed by the lib name.\nHere's an example:\n\
---> \tbrew uninstall ${mainLibs[$(((RANDOM/1000)%10))]} \n"


# STATUS
RET_value=""
RET_success=0
RET_error=1
RET_invalid=2
RET_help=3
RET_exists=4
RET_install=5
RET_pingError=68


# VARIABLES
failedLibs=()
noInternet=0



# FUNCTIONS

check_for_brew() {
	which brew > /dev/null
	return $?
}

check_for_connect() {
	ping -c1 $pingableHost > /dev/null 2>&1
	if [ $? -eq $RET_pingError ]; then
		noInternet=1
		echo -e $STR_noConnectFound
	fi
}

check_stuff() {
# Checks for required installs, connection to the internet, and many more

	# First things first: check if user has asked for help.
	if [ "$(echo $* | grep help)" ]; then
		echo -e $STR_usage
		exit $RET_help
	fi

	# If we are to download stuff: check for internet.
	check_for_connect

	# Then, check for Homebrew.
	check_for_brew
	# If Homebrew isn't installed, why on Earth are you running this script, dawg?!
	if [ $? -eq $RET_error ]; then
		echo -e $STR_noBrew
		exit $RET_error
	fi

	# Check for required kegs to be installed before digging into OJ libs installation
	requirements
}

currently_doing() {
	STR_currentlyDoing ="$1"
	echo -e "${BYel}$STR_currentlyDoing ...${Yel}"
}

requirements() {
	# Homebrew already provides stable kegs needed for OpenJailbreak; we shall use them
	echo -e "Checking if required packages are installed..."
	for i in "${requiredKegs[@]}"; do
		if [ ! -e $cellar/$i -a $noInternet -eq 0 ]; then brew install $i; fi
	done
	echo -e "All required packages are installed!\n"
}

# Packages management
grab_package() {
# 2 arguments
# 	$1 - keg
# 	$2 - kegName

	if [ ! -d ./$1 ]; then
		currently_doing "Fetching $2"
		git clone "$libSrcOJ/$2.git"
		if [ $? -ne $RET_success ]; then
			add_failed_lib $STR_currentlyDoing
		fi
		echo
	else
		echo -e "$2 already fetched (directory exists)."
	fi
}

prep_package() {
# 2 arguments
# 	$1 - kegName
# 	$2 - keg
# 1 return
#	$RET_value - kegDir

	# If configure.ac file exists, use the version that it provides (ugliest way but also the quickest)
	if [ -e configure.ac ]; then
		kegVersion=$(cat configure.ac | grep "AC_INIT" | cut -d',' -f2 | sed 's/ //' | sed 's/).*//')
	else # use the number from the package's name instead (less accurate)
		kegVersion=$(echo $2 | sed 's/.*-//').0
	fi
	# Setting the keg's place in the Cellar
	RET_value="$cellar/$1/$kegVersion"
	# If the keg exists...
	if [ -e "$RET_value" ]; then
		# If it is up-to-date, skip it
		if [ $kegVersion != $(ls $cellar/$1/)  ]; then
			echo -e "$Note $(brew ls $1 --versions) is already installed and updated. Skipping.\n"
			return $RET_exists
		fi
	fi
}

install_package() {
# 2 arguments
# 	$1 - kegName
#	$2 - kegDir

	currently_doing "Configuring $1"
	./autogen.sh > /dev/null		# Makes less visual garbage
	# Making sure auto config is correctly set up (otherwise causes ridiculous errors)
	aclocal -I /usr/local/share/aclocal
	autoheader
	automake
	autoconf
	# Finally launching configure
	./configure --prefix=$2

	currently_doing "Building $1"
	make && make install
	if [ $? -ne 0 ]; then
		add_failed_lib $STR_currentlyDoing
		return $RET_error
	fi

	# Let's check if the installation was successful
	currently_doing "Installing $1"
	if [ -d $2 ]; then
		brew link $1
	else
		add_failed_lib $STR_currentlyDoing
	fi
	echo -e "${RCol}"
}

add_failed_lib() {
# 2 arguments:
#	$1 - What failed
#	$2 - keg/kegName

	failedLibs+=("$1 $2")
}

# Lib(s) building
build_libs() {
	for keg in ${libs[@]:-$(echo ${mainLibs[@]})}; do
		# Grabbing the lib's name
		kegName=$(echo $keg | sed 's/-.*//')
		kegDir=""

		# Grab our package! (only if there's internet)
		if [ $noInternet == 0 ]; then grab_package $kegName $keg; fi

		if [ -d $keg ]; then
			# Prepare our package!
			cd $keg
			prep_package $kegName $keg
			# INSTALL DAT SHIT (... only if it's not installed)
			if [ $? != $RET_exists ]; then
				kegDir="$RET_value"
				install_package $kegName $kegDir
			fi
		fi

		# Prevents any (possible) mistake from OJ's scripts for doing "cd .." more/less than enough
		cd $OJHome
	done

	if [ -z "$failedLibs" ]; then return $RET_success
	else return $RET_error
	fi
}

which_libs() {
# $# arguments
#	$@ - libraries to install

	libs=""
	while [ "$1" != "" ]; do
		if [ -z "$(echo ${mainLibs[@]} | grep $1)" ]; then
			echo -e "$Note Library $1 doesn't exist. Ignoring this argument.\n"
		else
			lib_temp=$(echo ${mainLibs[@]} | sed 's/.*'$1'/'$1'/' | cut -d' ' -f1)
			libs=$libs\ "$lib_temp"
		fi
		shift
	done
	if [ ! "$libs" ]; then
		echo -e $STR_invalidArgs
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
		echo -e $STR_failedInstall
		for i in $(seq 0 `expr ${#failedLibs[@]} - 1`); do
			echo -e "- ${failedLibs[i]}\n"
		done
		echo -e $STR_failedInstallConfirm
		exit $RET_error
	else
		echo -e $STR_conclusion
		exit $RET_success
	fi
}

# Script starts HERE
clear

echo -e "${BWhi}OpenJailbreak library build script - DarkMalloc 2013\n\
Homebrew (kegs) version - Keyaku 2015${RCol}\n"
main $*
