=head1 NAME

AudioFile::Identify::MusicBrainz::Result

=head1 DESCRIPTION

Represents a result returned from a MusicBrainz query. Can represent either a
returned track, or a returned album.

=head2 METHODS

=cut

package AudioFile::Identify::MusicBrainz::Result;

use strict;
use warnings::register;
use base qw(AudioFile::Identify::MusicBrainz::Object);
use XML::DOM;

=head2 relevance

get/set the result relevance

=cut

sub relevance {
  my $self = shift;
  my $set = shift;
  if (defined($set)) {
    if (ref($set) and $set->getFirstChild) {
      $self->{relevance} = $set->getFirstChild->toString;
    } else {
      $self->{relevance} = $set;
    }
    return $self;
  } else {
    return $self->{relevance};
  }
}

=head2 album

get/set the album of the result. Returns a
C<AudioFile::Identify::MusicBrainz::Album> object if called with no
parameters, sets the ID of the album if called with a parameter.

=cut

sub album {
  my $self = shift;
  my $set = shift;
  if (defined($set)) {
    $self->{album} = $set->getAttributeNode('rdf:resource')->getValue;
    return $self;
  } else {
    return undef unless $self->{album};
    return $self->store->album($self->{album});
  }
}

=head2 type

get/set the result type. This will be 'Album' for an album result, in
which case there will only be an album returned, and C<track> will return
undef, or 'Track' for a track result, in which case there will be
results for both C<track> and C<album>.

=cut

sub type {
  my $self = shift;
  my $set = shift;
  if (defined($set)) {
    $self->{type} = $set;
    return $self;
  } else {
    return $self->{type};
  }
}

=head2 track

get/set the track of the result, assuming the result C<type> is 'Track'.
Returns a C<AudioFile::Identify::MusicBrainz::Track> object if called
with no parameters, sets the ID of the track if called with a parameter.

=cut

sub track {
  my $self = shift;
  my $set = shift;
  if (defined($set)) {
    $self->{track} = $set->getAttributeNode('rdf:resource')->getValue;
    return $self;
  } else {
    return undef unless $self->{track};
    return $self->album->track($self->{track})->getData();
  }
}


1;
