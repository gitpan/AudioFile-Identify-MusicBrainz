#!/usr/bin/perl

use strict;
use warnings;
use lib './lib';
use Test::More tests => 7;

use_ok('AudioFile::Identify::MusicBrainz');
use_ok('AudioFile::Identify::MusicBrainz::Album');
use_ok('AudioFile::Identify::MusicBrainz::Artist');
use_ok('AudioFile::Identify::MusicBrainz::Track');
use_ok('AudioFile::Identify::MusicBrainz::Result');
use_ok('AudioFile::Identify::MusicBrainz::RDF');
use_ok('AudioFile::Identify::MusicBrainz::Query');
