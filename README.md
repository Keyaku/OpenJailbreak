<h1>Brew script for OpenJailbreak</h1>
Website: https://www.openjailbreak.org/  
Twitter: [@OpenJailbreak](https://twitter.com/OpenJailbreak)  
IRC: chat.freenode.net, #OpenJailbreak

A (Home)brew installation script (Mac OS X only).

<h2>HOW TO INSTALL</h2>

1- Pick your workspace folder in Terminal (using ``cd``)

2- Run the following commands:  
<code>**git clone https://github.com/Keyaku/OpenJailbreak.git**</code>  
<code>**cd OpenJailbreak**</code>  
<code>**./autobrew.sh**</code>

=======================

This script fetches and builds the latest versions of all OpenJailbreak libraries.
It'll make it more easy for you to update or uninstall the OpenJailbreak libs
without affecting much of the /usr/local directory and subdirectories.  
This script doesn't even make use of `sudo`, which removes the hassle of putting in your
password every time you run it. Plus, `sudo` is <i>dangerous</i>.

Note: __autobuild.sh__ is DarkMalloc's older script. It mostly has Linux in mind
so it can work on both OS X and Linux. Keep in mind, however, that this script is a
<i>huge</i> mess and is not supported by the original author any longer, at least for now.
