#!/usr/bin/perl -w

# Tests for newly added album methods of asin(), coverart(), and
# releaseDateList()

use strict;
use warnings;
use lib './lib';
use Test::More tests => 16;

use_ok('AudioFile::Identify::MusicBrainz::Query') or die;

my $query = AudioFile::Identify::MusicBrainz::Query->new();

isa_ok(
  $query,
  "AudioFile::Identify::MusicBrainz::Query",
  "created query object");

# --------------------------------------------------------------------------
# Try a query that returns an ASIN and a cover-art image

ok($query->FileInfoLookup(
  artist => 'Norah Jones',
  album => 'Come Away With Me',
  track => 'Seven Years',
  tracknum => '2',
  items => 20,
), "Do query")

  or die diag(
  "FileInfoLookup failed, returned '" . $query->error() . "'\n",
  "Skipping remaining tests that depend on query response");

# For some reason, only the third result has the release date info.
# to be properly general, loop through all results till we find a nice one.
my $result;
foreach my $r (@{ $query->results() }) {
  if ($r->album->id =~ m[http://musicbrainz.org(/mm-\d+\.\d+)?/album/506fe9cf-29c6-4318-9070-da9463f51617]) {
    $result = $r;
  }
}
die "No result that we like found!" unless $result;

isa_ok(
  $result,
  "AudioFile::Identify::MusicBrainz::Result",
  "got result object");

like(
  $result->album->id,
  qr[http://musicbrainz.org(/mm-\d+\.\d+)?/album/506fe9cf-29c6-4318-9070-da9463f51617],
  'Got the album ID with all the funky features');

like(
  $result->track->artist->title,
  qr/Norah Jones/i,
  "Matching artist name");
like(
  $result->album->title,
  qr/Come Away With Me/i,
  "Matching album name");
is(
  $result->album->asin,
  "B00005YW4H",
  "Matching ASIN");
is(
  $result->album->coverart,
  undef, # "http://images.amazon.com/images/P/B00005YW4H.01.MZZZZZZZ.jpg",
  "Matching cover art URL");
like(
  $result->track->title,
  qr/Seven Years/i,
  "Matching track title");

# Test Release Type and Release Status
is(
  $result->album->releaseType,
  "http://musicbrainz.org/mm/mm-2.1#TypeAlbum",
  "Release Type");
is(
  $result->album->releaseStatus,
  "http://musicbrainz.org/mm/mm-2.1#StatusOfficial",
  "Release Status");

my $releaseDates = $result->album->releaseDateList;

ok($releaseDates, "Have release dates");

is(
  scalar(keys %{$releaseDates}),
  2,
  "Two release dates returned");

like(
  $releaseDates->{"US"},
  qr/^2002/,
  "US Release Date");

is(
  $releaseDates->{"GB"},
  "2002-03-04",
  "UK Release Date");


