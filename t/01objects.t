#!/usr/bin/perl -w

use strict;
use warnings;
use lib './lib';
use Test::More tests => 18;

use_ok('AudioFile::Identify::MusicBrainz::Store');
use_ok('AudioFile::Identify::MusicBrainz::Album');
use_ok('AudioFile::Identify::MusicBrainz::Artist');
use_ok('AudioFile::Identify::MusicBrainz::Track');
use_ok('AudioFile::Identify::MusicBrainz::Query');

ok(my $store = AudioFile::Identify::MusicBrainz::Store->new(), "created store");

my $track_id = 'http://mm.musicbrainz.org/track/66e7b963-3c31-4495-8002-3770cf1b7fa8';
my $track_title = 'Yellow';

ok(my $track = AudioFile::Identify::MusicBrainz::Track->new(), "created track object");
ok($track->id($track_id), "set track url");
is($track->id, $track_id, "get track id");
ok($track->getData, "got track data");
is($track->title, $track_title, "got track title");
ok($store->track($track_id, $track), "stored track");

# now try a real query

ok(my $query = AudioFile::Identify::MusicBrainz::Query->new(), "created query object");
ok($query->FileInfoLookup(track => 'yellow', artist => 'coldplay', items => 5 ), "sent query");

ok(my $result = $query->result(0), "got a result");

ok($result->track->title =~ /yellow/i, "result title contains query string");
ok($result->track->artist->title =~ /coldplay/i, "result artist contains query string");
ok($result->album->title, "album has a title");
