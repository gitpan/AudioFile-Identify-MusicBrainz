=head1 NAME

AudioFile::Identify::MusicBrainz::Artist

=head1 DESCRIPTION

MusicBrainz 'Artist' object.

=head1 METHODS

=cut

package AudioFile::Identify::MusicBrainz::Artist;

use strict;
use warnings::register;
use base qw(AudioFile::Identify::MusicBrainz::Object);
use XML::DOM;

=head2 title

get/set the title of the artist. Pass a string or an C<XML::DOM::Node>
object to set.

=cut

sub title {
  my $self = shift;
  my $set = shift;
  return $self->_xmlChildAccessor("title", $set);
}


=head2 sortName

get/set the sortname property, which removes things like 'The' from band
names.

=cut

sub sortName {
  my $self = shift;
  my $set = shift;
  return $self->_xmlChildAccessor("sortname", $set);
}


1;
