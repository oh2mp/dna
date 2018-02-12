#!/usr/bin/perl

#######################################################################################################
#
# Simple script for importing FamilyTreeDna FF matches csv to a SQLite database.
# Mikko Pikarinen 2018
# See documentation at https://github.com/oh2mp/dna
#
#######################################################################################################

use strict;
use DBI;
use Text::CSV;
use IO::Uncompress::Gunzip;

binmode STDOUT, ":encoding(utf8)";

my ($csvfile, $dbfile) = @ARGV;
if (!$csvfile) {
    print STDERR "Usage: $0 matches_csv_file [sqlite_db_file]\n";
    exit(1);
}

if (!$dbfile) {
    ($dbfile = $csvfile) =~ s/\.gz$//;
    $dbfile =~ s/\.csv/.sqlite3/;
}

if (-e $dbfile) {
    print STDERR "Database file $dbfile already exists.\n";
    exit(2);
}

my $dbh = DBI->connect("DBI:SQLite:dbname=".$dbfile,"","",
                      {'RaiseError'     => 1,
                       'PrintError'     => 1,
                       'AutoCommit'     => 0,
                       'sqlite_unicode' => 1,
                      }) or die "Cannot create database file ". $DBI::errstr;

# Create table that has fields like the csv except ancestral surnames
$dbh->do(q{
           CREATE TABLE matches (
               id INTEGER primary key autoincrement,
               full_name TEXT,
               first_name TEXT,
               middle_name TEXT,
               last_name TEXT,
               match_date TEXT,
               relationship_range TEXT,
               suggested_relationship TEXT,
               shared_cm REAL,
               longest_block REAL,
               linked_relationship TEXT,
               email TEXT,
               ydna_haplogroup TEXT,
               mtdna_haplogroup TEXT,
               notes TEXT,
               matching_bucket TEXT
           )
});

# Separate table for surnames
$dbh->do(q{
           CREATE TABLE ancestors (
               id INTEGER,                   
               surname TEXT,
               area TEXT,
               foreign key(id) references matches(id)
           )
});

my $sqlma = q{
    INSERT INTO matches (full_name, first_name, middle_name, last_name, match_date, relationship_range, 
                         suggested_relationship, shared_cm, longest_block, linked_relationship, email, 
                         ydna_haplogroup, mtdna_haplogroup, notes, matching_bucket) 
                 VALUES (?,?,?,?,?,?, ?,(?+0),(?+0),?,?, ?,?,?,?)
};
my $sqlsn = q{INSERT INTO ancestors (id,surname,area) VALUES (?,?,?)};
my $sthsn = $dbh->prepare($sqlsn);

my $csv = Text::CSV->new({binary => 1});

# Open CSV and iterate through every row 

my @csvlines = ();
if ($csvfile =~ /\.gz$/) {
    my $z = IO::Uncompress::Gunzip->new($csvfile);
    while (my $line = $z->getline) {
        push @csvlines, $line;
    }
    $z->close();
} else {
    open(my $fd, "<:encoding(utf8)", $csvfile) or die "Cannot open csv: ".$!;
    @csvlines = <$fd>;
    close $fd;
}

foreach my $row (@csvlines) {
    my $status = $csv->parse($row);
    my @data = $csv->fields;

    my $surnames = $data[11];                        # Separate ancestral surnames from other data
    @data = (@data[0..10],@data[12..$#data]);

    next if ($data[8] !~ /^\d/);                     # If shared cM is not numeric, this is header row
 
    $data[4] =~ s/(\d{1,2})\/(\d{1,2})\/(\d{4})/sprintf("%04d-%02d-%02d",$3,$1,$2)/e;
                                                     # Fix braindead American date format to ISO-8601

    map {undef $_ if ($_ =~ /^(|N\/A)$/)} @data;     # convert "N/A" or empty string to NULL
    $dbh->do($sqlma,undef,@data);                    # insert data to matches table
    my $id = $dbh->last_insert_id(undef,undef,'matches','id');

    my @names = split(" / ",$surnames);              # Extract ancestral surnames to separate list
    map {s/^\s+|\s+$//g} @names;

    foreach my $name (@names) {
        next if (!$name);
        (my $area = $name) =~ s/.*\(([^)]+)\).*/$1/; # Area is always in parenthesis, so cut it out
        undef $area if ($area eq $name);             # No area for this name?
        $name =~ s/\s*\(.*//;
        next if (!$name);                            # don't save empty names
        $sthsn->execute($id,$name,$area);            # Save to ancestor table
    }
}
$dbh->commit;
$dbh->disconnect;

exit(0);

