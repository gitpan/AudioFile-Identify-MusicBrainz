#!/usr/bin/perl -w

use warnings;
use strict;

use lib './lib';
use AudioFile::Identify::MusicBrainz::Query;

my $query = AudioFile::Identify::MusicBrainz::Query->new();

$query->FileInfoLookup(

  track=>'yellow',
  artist => 'coldplay',
  items => 5)

or die "Error: ".$query->error();

print "Good response\n";

print "There are ".scalar(@{$query->results})." results\n";

for my $result (@{$query->results}) {
  print "- ".$result->track->title." ".$result->album->id."\n";
}
