#!/usr/bin/perl -w

# Tests for newly added album methods of asin(), coverart(), and
# releaseDateList()

use strict;
use warnings;
use lib './lib';
use Test::More tests => 15;

BEGIN { use_ok('AudioFile::Identify::MusicBrainz::Query'); }

my $query = AudioFile::Identify::MusicBrainz::Query->new();

isa_ok($query, "AudioFile::Identify::MusicBrainz::Query",
       "created query object");

# --------------------------------------------------------------------------
# Try a query that returns an ASIN and a cover-art image

unless (ok($query->FileInfoLookup(artist => 'Norah Jones',
				  album => 'Come Away With Me',
				  track => 'Seven Years', tracknum => '2',
				  items => 20,), "Do query"))  {
  diag("FileInfoLookup failed, returned '" . $query->error() . "'\n",
       "Skipping remaining tests that depend on query response");
} else {

  # For some reason, only the third result has the release date info.
  my $result = $query->result(3 - 1);

  isa_ok($result, "AudioFile::Identify::MusicBrainz::Result",
	 "got result object");

  like($result->track->artist->title, qr/Norah Jones/i,
       "Matching artist name");
  like($result->album->title, qr/Come Away With Me/i, "Matching album name");
  is($result->album->asin, "B00005YW4H", "Matching ASIN");
  is($result->album->coverart,
     "http://images.amazon.com/images/P/B00005YW4H.01.MZZZZZZZ.jpg",
     "Matching cover art URL");
  like($result->track->title, qr/Seven Years/i, "Matching track title");

  # Test Release Type and Release Status
  is($result->album->releaseType, "http://musicbrainz.org/mm/mm-2.1#TypeAlbum",
     "Release Type");
  is($result->album->releaseStatus,
     "http://musicbrainz.org/mm/mm-2.1#StatusOfficial", "Release Status");

  my $releaseDates = $result->album->releaseDateList;

  ok($releaseDates, "Have release dates");

  is(scalar(keys %{$releaseDates}), 2, "Two release dates returned");

  is($releaseDates->{"US"}, "2002", "US Release Date");

  is($releaseDates->{"GB"}, "2002-03-04", "UK Release Date");
}
