#!/usr/bin/perl
use warnings;
use strict;

use Module::Build;

Module::Build->new(
    module_name => 'AudioFile::Identify::MusicBrainz',
    license => 'lgpl',
    requires => {
        'perl'        => '5.6.0',
        'LWP'         => '0',
        'XML::DOM'    => '0',
        'Test::More'  => 0,
    },
    create_makefile_pl => 'traditional',
)->create_build_script;

