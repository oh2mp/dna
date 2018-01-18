# matchimport.pl

This script imports Family Finder matches to a SQLite3 database. So if you can "speak" SQL, it is easy to
make queries that aren't possible on [FamilyTreeDna](https://www.familytreedna.com) website. 
See [README.md](README.md) for instructions for installing the needed modules.

Simply run the script eg. like this:

`perl matchimport.pl 999999_Family_Finder_Matches_20180118.csv matches.sqlite3`

The script imports your csv into the database file `matches.sqlite3` 

If the script has nothing to complain, then it is totally quiet. This is only for import, not updating,
so the script will not overwrite existing database file but creates a new one. After import just run 
`sqlite3 matches.sqlite3` and start querying the database.

There will be two tables. The table **matches** follows the schema of the csv file except
the ancestors field is separated and parsed to another table **ancestors**. The schemas are:

 - **matches**
```
id  			INTEGER
full_name 		TEXT
first_name 		TEXT
middle_name 		TEXT
last_name 		TEXT
match_date 		TEXT
relationship_range 	TEXT
suggested_relationship 	TEXT
shared_cm 		REAL
longest_block 		REAL
linked_relationship 	TEXT
email 			TEXT
ydna_haplogroup 	TEXT
mtdna_haplogroup 	TEXT
notes 			TEXT
matching_bucket 	TEXT
```

 - **ancestors**
```
id 		INTEGER
surname 	TEXT
area 		TEXT
```

## Some example queries

 - Get average shared cM

   `select avg(shared_cm) from matches;`

 - Get top 10 of ancestor surnames

   `select count(*),surname from ancestors where surname is not null group by 2 order by 1 desc limit 10;`

 - Get top 5 first names from your matches

   `select count(*),first_name from matches group by 2 order by 1 desc limit 5;`

 - Get percentage of YDNA haplogroups from the matches who have YDNA haplogroup information

<pre>
   select substr(ydna_haplogroup,1,1) as h,
          round(count(*)/
              (select count(*)/100.0 from matches where ydna_haplogroup != ''),2)
       from matches where h != '' group by h order by 2 desc;
</pre>
