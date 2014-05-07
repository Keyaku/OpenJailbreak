<p>An unofficial Git to bump Joshua Hill's (a.k.a. p0sixninja) OpenJailbreak project.<br>
Website: https://www.openjailbreak.org<br>
Twitter: @OpenJailbreak<br>
IRC: chat.freenode.net, #OpenJailbreak</p>

<p>A (Home)brew-friendly installation script (Mac OS X only).</p>

<h1>HOW TO INSTALL</h1>

<p>1- Pick your workspace folder</p>

<p>2- Do the following commands:<br>
git clone https://github.com/Keyaku/OpenJailbreak.git<br>
cd OpenJailbreak</p>

<p>3- I highly recommend now doing:<br>
./autobrew.sh<br>
Since I'm still making the old script available, you can still use it. 
Recommended for people who use Linux (however, take in consideration that the original 
script is a mess and is not supported by the original author any longer until further 
notice).</p>

<p>This single command fetches and builds the latest versions of all OpenJailbreak libraries.
Using the Homebrew script makes it more easy to update or uninstall the OpenJailbreak libs
without affecting much of the /usr/local directory and subdirectories.</p>

<p>For people who are (much) better at Brew Cooking than me:<br>
I'm still green in Ruby programing, so I haven't created a Gem for each library yet.<br>
For now, what the script does is install the libraries in the Cellar for easy uninstalling 
and is capable of detecting newer versions of the libraries ONLY WITH the script.
</p>
