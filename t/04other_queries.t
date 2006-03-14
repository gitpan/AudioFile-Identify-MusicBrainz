#!/usr/bin/perl -w

# Tests for various other query scenarios.

use strict;
use warnings;
use lib './lib';
use Test::More tests => 12;

BEGIN { use_ok('AudioFile::Identify::MusicBrainz::Query'); }

my $query = AudioFile::Identify::MusicBrainz::Query->new();

isa_ok($query, "AudioFile::Identify::MusicBrainz::Query",
       "created query object");

# --------------------------------------------------------------------------
# Try a query that uses special characters in query fields

unless (ok($query->FileInfoLookup(artist => 'Big Head Todd & the Monsters',
				  album => 'Strategem"><#!&\'\\',
				  items => 20,), "Do query")) {
  diag("FileInfoLookup failed, returned '" . $query->error() . "'\n",
       "Skipping remaining tests that depend on query response");
} else {

  isnt($query->resultCount(), 0, "Got some hits") or die;

  my $result = $query->result(0);

  isa_ok($result, "AudioFile::Identify::MusicBrainz::Result",
	 "got result object");

  is($result->type, "Album", "Result type is Album");

  is($result->album->artist->title, "Big Head Todd and The Monsters",
     "Matching artist name");
}


# --------------------------------------------------------------------------
# Try a query that gets an ampersand back in the response

unless (ok($query->FileInfoLookup(track => 'The Other End Of The Telescope',
				  tracknum => 1,
				  artist => 'Elvis Costello & The Attractions',
				  album => 'All This Useless Beauty',
				  items => 20,), "Do query")) {
  diag("FileInfoLookup failed, returned '" . $query->error() . "'\n",
       "Skipping remaining tests that depend on query response");
} else {

  isnt($query->resultCount(), 0, "Got some hits") or die;

  my $result = $query->result(0);

  isa_ok($result, "AudioFile::Identify::MusicBrainz::Result",
	 "got result object");

  is($result->type, "Track", "Result type is Track");

  is($result->album->artist->title, 'Elvis Costello & The Attractions',
     "Matching artist name");
}
