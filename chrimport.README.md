# chrimport.pl

This script imports Family Finder chromosome browser data to a SQLite3 database. 
So if you can "speak" SQL, it is easy to make queries that aren't possible on 
[FamilyTreeDna](https://www.familytreedna.com) website. 
See [README.md](README.md) for instructions for installing the needed modules.

First go to [https://www.familytreedna.com/my/family-finder/chromosome-browser](https://www.familytreedna.com/my/family-finder/chromosome-browser)
and download your data. The link is on up right: *"Download All Matches to Excel (CSV Format)"*.

Simply run the script eg. like this:

`perl chrimport.pl 999999_Chromosome_Browser_Results_20180212.csv matches.sqlite3`

The script imports your csv into the database file `matches.sqlite3` 

The csv file can be also gzipped, .csv.gz

If you don't give the name for the dbfile, it will be the same filename as csv with extension .sqlite3

If the script has nothing to complain, then it is totally quiet. This is only for import, not updating,
so the script will not overwrite existing database file but drops the old data first if it exists.
After import just run  `sqlite3 matches.sqlite3` and start querying the database.

There will be table called **chrdata** that follows the schema of the csv file:

 - **chrdata**
```
id  			INTEGER
name 			TEXT,
matchname 		TEXT,
chromosome 		TEXT,
start_location 		REAL,
end_location 		REAL,
centimorgans 		REAL,
snps 			REAL
```

Happy querying!
