### [Installation](#installation)

1. Start with any local operating system such as Mac OS X, Linux, or Windows.
    * For Windows 8 or higher it is recommended that you run the cmd window as Administrator
    * In Windows, better results have been achieved by using Git Bash instead of cmd, so this is what we recommend.
1. Install [VirtualBox 5.1.x](https://www.virtualbox.org/wiki/Downloads)
1. Install [Vagrant 1.8.x](https://www.vagrantup.com/downloads.html)
    * `vagrant` will now be available as a command in your terminal, try it out.
    * ***Note:*** If Vagrant is already installed, use `vagrant -v` to check the version. You may want to consider upgrading if a much older version is in use.
1. Install some convenient Vagrant plugins (highly recommended):
    1. Install the [vagrant-hostsupdater](https://github.com/cogitatio/vagrant-hostsupdater) plugin with `vagrant plugin install vagrant-hostsupdater`
        * Note: This step is not a requirement, though it does make the process of starting up a virtual machine nicer by automating the entries needed in your local machine's `hosts` file to access the provisioned VVV domains in your browser.
        * If you choose not to install this plugin, a manual entry should be added to your local `hosts` file that looks like this: `192.168.50.4  vvv.dev local.wordpress.dev src.wordpress-develop.dev build.wordpress-develop.dev`
    1. Install the [vagrant-triggers](https://github.com/emyl/vagrant-triggers) plugin with `vagrant plugin install vagrant-triggers`
        * Note: This step is not a requirement. When installed, it allows for various scripts to fire when issuing commands such as `vagrant halt` and `vagrant destroy`.
        * By default, if vagrant-triggers is installed, a `db_backup` script will run on halt, suspend, and destroy that backs up each database to a `dbname.sql` file in the `{vvv}/database/backups/` directory. These will then be imported automatically if starting from scratch. Custom scripts can be added to override this default behavior.
        * If vagrant-triggers is not installed, VVV will not provide automated database backups.
    1. Install the [vagrant-vbguest](https://github.com/dotless-de/vagrant-vbguest) plugin with `vagrant plugin install vagrant-vbguest`.
        * Note: This step is not a requirement. When installed, it keeps the [VirtualBox Guest Additions](https://www.virtualbox.org/manual/ch04.html) kernel modules of your guest synchronized with the version of your host whenever you do `vagrant up`. This can prevent some subtle shared folder errors.
1. Clone or extract the Varying Vagrant Vagrants project into a local directory
    * `git clone git://github.com/saucal/VVV.git -b saucal_version vagrant-local`
    * OR download and extract the repository `saucal_version` branch [zip file](https://github.com/saucal/vvv/archive/saucal_version.zip) to a `vagrant-local` directory on your computer.
1. In a command prompt, change into the new directory with `cd vagrant-local`
1. Start the Vagrant environment with `vagrant up`
    * Be patient as the magic happens. This could take a while on the first run as your local machine downloads the required files.
    * Watch as the script ends, as an administrator or `su` ***password may be required*** to properly modify the hosts file on your local machine.
    * If you're getting errors on OSX at the beginning of the process that says something that the box cannot be found, try the following:
        * `sudo rm -rf /opt/vagrant/embedded/bin/curl`
1. Visit any of the following default sites in your browser:
    * [http://local.wordpress.dev/](http://local.wordpress.dev/) for WordPress stable
    * [http://src.wordpress-develop.dev/](http://src.wordpress-develop.dev/) for trunk WordPress development files
    * [http://build.wordpress-develop.dev/](http://build.wordpress-develop.dev/) for the version of those development files built with Grunt
    * [http://vvv.dev/](http://vvv.dev/) for a default dashboard containing several useful tools