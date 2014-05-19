<p>An unofficial Git to bump Joshua Hill's (a.k.a. p0sixninja) OpenJailbreak project.<br>
Website: https://www.openjailbreak.org<br>
Twitter: @OpenJailbreak<br>
IRC: chat.freenode.net, #OpenJailbreak</p>

<p>A (Home)brew-friendly installation script (Mac OS X only).</p>

<h1>HOW TO INSTALL</h1>

<p>1- Pick your workspace folder</p>

<p>2- Run the following commands in Terminal:<br>
<strong>git clone https://github.com/Keyaku/OpenJailbreak.git</strong><br>
<strong>cd OpenJailbreak</strong></p>

<p>3- I highly recommend now running:<br>
<strong>./autobrew.sh</strong><br>
Since I'm still making the old script available, you can use it. 
It's better prepared for people who use Linux (however, take in consideration that the
original script is a <i>huge</i> mess and is not supported by the original author any longer until
further notice).</p>

<p>This single command fetches and builds the latest versions of all OpenJailbreak libraries.
Using the Homebrew script makes it more easy to update or uninstall the OpenJailbreak libs
without affecting much of the /usr/local directory and subdirectories.<br>
This script doesn't even make use of <strong>sudo</strong>, which removes the hassle of putting in a
password every time you run it. Plus, <strong>sudo</strong> is <i>dangerous</i></p>

<p>For people who are (much) better at Brew Cooking than me:<br>
I'm still green in Ruby programing, so I haven't created a Gem for each library yet.<br>
For now, what the script does is install the libraries in the Cellar for easy uninstalling 
and is capable of detecting newer versions of the libraries ONLY WITH the script.
</p>
