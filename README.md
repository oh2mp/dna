**This repository will contain DNA data processing scripts for your own data that you can download from [FamilyTreeDNA](https://www.familytreedna.com/)**

SQLite3 and Perl modules DBI, DBD::SQLite3 and Text::CSV are needed. Install them: 

  - Ubuntu or Debian:

  `sudo apt install sqlite3 libdbi-perl libdbd-sqlite3-perl libtext-csv-perl perl-modules`

  - RedHat, CentOS and other RPM-based distros:

  `sudo yum install sqlite perl-DBI perl-Text-CSV perl-DBD-SQLite`

  - Mac OS X:

1. Install [XCode](https://developer.apple.com/xcode/)
2. Start XCode, go to preferences, click downloads tab and click to install command line tools.
3. Install Text::CSV from CPAN. Other packages are already installed in Mac OS X. 
       Start terminal window and use command:

   `sudo perl -MCPAN -e 'install Text::CSV'`
   
  - Windows:
 
    Sorry, I have no idea how to do it. Get another OS.

## The scripts

### matchimport.pl
  - A simple perl script that imports Family Finder CSV data to a SQLite3 database. 
    See [matchimport.README.md](matchimport.README.md)

### chrimport.pl
  - A simple perl script that imports Family Finder chromosome browser CSV data to a SQLite3 database.
    See [chrimport.README.md](chrimport.README.md)
