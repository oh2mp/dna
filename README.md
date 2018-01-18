*This repository will contain DNA data processing scripts for your own data that you can download from [FamilyTreeDNA](https://www.familytreedna.com/)*

SQLite3, Perl modules DBI, DBD::SQLite3 and Text::CSV are needed. You can install them in Ubuntu or Debian:
`sudo apt install sqlite3 libdbi-perl libdbd-sqlite3-perl libtext-csv-perl`

RedHat, CentOS and other RPM-based distros:
`sudo yum install sqlite perl-DBI perl-Text-CSV perl-DBD-SQLite`

Mac OS X:
1. First install [XCode](https://developer.apple.com/xcode/) and command line tools. Start XCode, go to preferences, click downloads tab and click to install command line tools.
2. Configure CPAN. Start terminal window and use command:
   `sudo perl -MCPAN -e 'install Text::CSV'`
   
Windows:
Sorry, I have no idea how to do it.

## Scripts

### matchimport.pl
  - A simple perl script that imports Family Finder CSV data to a SQLite3 database. See its own README.
