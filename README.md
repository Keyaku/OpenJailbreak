An unofficial Git to bump Joshua Hill's (a.k.a. DarkMalloc) OpenJailbreak project.
Website: https://www.openjailbreak.org
Twitter: @OpenJailbreak
IRC: chat.freenode.net, #OpenJailbreak

Adds fixes to minor issues, includes a (Home)brew-friendly installation script (Mac OS X only).



HOW TO INSTALL

You have two ways to install:
1- Pick your workspace folder

2- Do the following commands:
git clone https://github.com/Keyaku/OpenJailbreak.git
cd OpenJailbreak

3- Use the original script provided by DarkMalloc (edited to fix typos):
./autobuild.sh
OR, if you have Homebrew installed, I highly recommend doing:
./autobrew.sh

This single command fetches and builds the latest versions of all OpenJailbreak libraries.
Using the Homebrew script makes it more easy to update or uninstall the OpenJailbreak libs
without affecting much of the /usr/local directory and subdirectories.

I shall update the brew script to add the possibility to uninstall all OpenJailbreak libs
at once (in case anything major is broken) and the ability to install/reinstall a specific OpenJailbreak lib.
