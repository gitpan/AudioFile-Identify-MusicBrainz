=head1 NAME

AudioFile::Identify::MusicBrainz - A pure-perl MusicBrainz client implementation

=head1 DESCRIPTION

A::I::M is, at heart, a pure-perl implementation of the MusicBrainz client
protocol, encapsulated in some sensible Track/Album/Artist objects that have the
sort of methods you'd expect. So I can, given a Track object, go

  my $some_title = $track->album->track(4)->artist->title;

Eventually, this is intended to be merely a plugin to a more general
AudioFile::Identify architecture, along with such exciting things as
A::I::Amazon, A::I::CDDB, etc, but until they're ready and we have a
decent API for it, it's useful to have this out in the wild, as it's
very useful.

=head1 USAGE

See L<AudioFile::Identify::MusicBrainz::Query> for details,
but in summary:

  use AudioFile::Identify::MusicBrainz::Query;
  my $query = AudioFile::Identify::MusicBrainz::Query->new();
  $query->FileInfoLookup(
      artist => 'coldplay',
      title => 'yellow',
      items => 5,
  ) or die "Could not query: " . $query->error();
  print "I got ".scalar(@{$query->results})." results\n";

  print "Most likely album is '". 
    $query->result(0)->album->title ."'\n";
  print "Most likely trackNum is '". 
    $query->result(0)->track->trackNum ."'\n";

See L<AudioFile::Identify::MusicBrainz::Album>, L<AudioFile::Identify::MusicBrainz::Artist> and L<AudioFile::Identify::MusicBrainz::Track>
for details of the methods you can call on these returned objects.

There's an example of its use in the I<examples> folder in the tarball,
I<tagger.pl> (see L<tagger.pl>). This is a utility that examines the ID3
tags of an MP3 file, and will print what MusicBrainz suggests for the
rest of the tags.

=head1 AUTHOR

Tom Insam E<lt>tom@jerakeen.orgE<gt>

This program is free software, licensed under the terms of the GNU LGPL.

=head1 CREDITS

Most code is Copyright 2003 Tom Insam E<lt>tom@jerakeen.orgE<gt>. The
sole exception is the source for the I<RDF> module, which contains a
derivative work of a file Copyright 2000 Robert Kaye, see
L<AudioFile::Identify::MusicBrainz::RDF> for details of this.

Paul Mison E<lt>paulm@husk.orgE<gt> provided the inspiration and
badgering that all modules require to get released, and has spent many
hours shouting at his laptop as he tried to get a 'real' RDF parser to
work. I have used C<XML::DOM> to parse the XML in this module, which is Bad
and Wrong and will get me in Trouble. I didn't use his work, as it
doesn't, but he deserves credit for trying to do the Right Thing. I'm
sure a later version will be better.

The RDF module is programmatically generated from queries.h in the
libmusicbrainz client library distribution. See
L<AudioFile::Identify::MusicBrainz::RDF> for specific copyright information.

Mike McCallister <mike@metalogue.com> contibuted a fantastic patch in March
2004 to fix the module after a protocol change and added lazy object loading
and lots of nice abstractions. Lovely stuff.

=head1 BUGS

I use C<XML::DOM>, and not something in the RDF space. I have also
reverse-engineered the protocol from looking at HTTP dumps, as opposed
to actually trying to understand the C libraries. On the other hand,
this is exactly why XML and RDF are so cool.

=head1 SEE ALSO

L<MusicBrainz::Client>, L<MusicBrainz::Queries>, for the original
implementation of this protocol, using the C-based libmusicbrainz client
library.

=cut

package AudioFile::Identify::MusicBrainz;

use strict;
use warnings::register;
use lib './lib';

our $VERSION=0.31;

1;
