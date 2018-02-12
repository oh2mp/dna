#!/usr/bin/perl

#######################################################################################################
#
# Simple script for importing FamilyTreeDna FF chromosome browser csv to a SQLite database.
# 
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

my $dbh = DBI->connect("DBI:SQLite:dbname=".$dbfile,"","",
                      {'RaiseError'     => 1,
                       'PrintError'     => 1,
                       'AutoCommit'     => 0,
                       'sqlite_unicode' => 1,
                      }) or die "Cannot create database file ". $DBI::errstr;

$dbh->do(q{DROP TABLE IF EXISTS chrdata});

$dbh->do(q{
           CREATE TABLE chrdata (
               id INTEGER primary key autoincrement,
               name TEXT,
               matchname TEXT,
               chromosome TEXT,
               start_location REAL,
               end_location REAL,
               centimorgans REAL,
               snps REAL
           )
});

my $sqlma = q{
    INSERT INTO chrdata (name,matchname,chromosome,start_location,end_location,centimorgans,snps)
                 VALUES (?,?,?,(?+0),(?+0),(?+0),(?+0))
};

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

shift @csvlines;                    # remove header row
foreach my $row (@csvlines) {
    my @dummy = split(",",$row);
    if (scalar @dummy == 7) {
        $row =~ s/"//g;
    }
    my $status = $csv->parse($row);
    my @data = $csv->fields;
    $dbh->do($sqlma,undef,@data);   # insert data to matches table
}
$dbh->commit;
$dbh->disconnect;

exit(0);

