#!/usr/bin/perl -w

=head1 NAME

tagger.pl

=head1 DESCRIPTION

simple utility that will extract ID3 information from an mp3, ask MusicBrainz
about it, and print the 5 best responses.

=head1 USAGE

./tagger.pl <filename.mp3>

=cut

use warnings;
use strict;

use lib qw(./lib ../lib);
use AudioFile::Identify::MusicBrainz::Query;
use AudioFile::Info;

my $filename = shift;

unless ($filename and -e $filename) {
  print "Usage: tagger.pl <filename>\n";
  exit;
  
}

my $query = AudioFile::Identify::MusicBrainz::Query->new() or die "Can't make query";
my $info = AudioFile::Info->new($filename);

my $info = {
  title => $info->title,
  artist => $info->artist,
  album => $info->album,
  tracknum => $info->track,
  items => 5,
};

print "Running query with:\n";
print Dumper($info); use Data::Dumper;

$query->FileInfoLookup( %$info )
  or die("Query error: ".$query->error());

print "Results:\n";

for my $result (@{$query->results}) {
  if ($result->type eq 'Track') {
    print "  ".$result->track->artist->title
          ." - ".$result->album->title
          ." - #".$result->track->trackNum
          ." / ".scalar( @{ $result->album->tracks } )
          ." ".$result->track->title
          ." (".$result->relevance.")"
          ."\n";
  } else {
    print "(album) ".$result->album->artist->title
          ." - ".$result->album->title
          ."\n";
  }
}
