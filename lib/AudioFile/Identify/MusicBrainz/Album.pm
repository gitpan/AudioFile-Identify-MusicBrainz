=head1 NAME

AudioFile::Identify::MusicBrainz::Album

=head1 DESCRIPTION

MusicBrainz 'Album' object.

=head1 METHODS

=cut

package AudioFile::Identify::MusicBrainz::Album;

use strict;
use warnings::register;
use base qw(AudioFile::Identify::MusicBrainz::Object);
use AudioFile::Identify::MusicBrainz::Track;
use XML::DOM;

=head2 title

get/set the title of the album. Pass a string or an C<XML::DOM::Node> object
to set.

=cut

sub title {
  my $self = shift;
  my $set = shift;
  if (defined($set) and $set->getFirstChild) {
    $self->{title} = $set->getFirstChild->toString;
    return $self;
  } else {
    return $self->{title};
  }
}

=head2 cdindexIdList

yeah, well. The documentation has this to say about the cdindexIdList property:

  This property is used to describe a list of CD Index ids in an album.

BRILLIANT. That's really helpful, thanks guys. Anyone know what this is?

=cut

sub cdindexidList {
  my $self = shift;
}

=head2 creator

get/set the 'dc:creator' resource property. This describes the albums 'artist',
insofarasmuch as albums can have artists. Don't use this to get the artist; the
C<artist> method will return a C<AudioFile::Identify::MusicBrainz::Artist>
object, assuming this resource is in the store, which it should be.

=cut

sub creator {
  my $self = shift;
  my $set = shift;
  if (defined($set)) {
    $self->{creator} = $set->getAttributeNode("rdf:resource")->getValue;
    return $self;
  } else {
    return $self->{creator};
  }
}

=head2 artist

return the C<AudioFile::Identify::MusicBrainz::Artist> object that is the
returned artist for this album. May be the 'Various Artists' object.

=cut

sub artist {
  my $self = shift;
  return $self->store->artist($self->creator);
}

=head2 releaseType

get/set the releaseType property

=cut

sub releaseType {
  my $self = shift;
  my $set = shift;
  if (defined($set)) {
    $self->{releaseType} = $set;
    return $self;
  } else {
    return $self->{releaseType};
  }
}

=head2 releaseStatus

get/set the releaseStatus property

=cut

sub releaseStatus {
  my $self = shift;
  my $set = shift;
  if (defined($set)) {
    $self->{releaseStatus} = $set;
    return $self;
  } else {
    return $self->{releaseStatus};
  }
}

=head2 trackList

called by parse, this will extract a list of tracks from an C<XML::DOM::Node>
and build C<AudioFile::Identify::MusicBrainz::Track> object from them, put them
in the store, and build an internal array for track order. To get the tracks back,
use the C<track> or C<tracks> method.

=cut

sub trackList {
  my $self = shift;
  my $set = shift;
  if (defined($set) and ref($set)) {
    my $tracks = $set->getElementsByTagName('rdf:li');
    for (my $i = 0; $i < $tracks->getLength; $i++) {
      my $id = $tracks->item($i)->getAttributeNode('rdf:resource')->getValue;
      my $track = AudioFile::Identify::MusicBrainz::Track->new()
                                                         ->id($id)
                                                         ->store($self->store);
      $self->store->track($id, $track);
      $self->{tracks}->[$i] = $id;
    }
    return $self;
  } else {
    die "Must call with node\n";
  }
}

=head2 tracks

returns a listref of C<AudioFile::Identify::MusicBrainz::Track> object, in
track order for the album.

=cut

sub tracks {
  my $self = shift;
  return map { $self->store->track($_) } $self->{tracks};
}

=head2 tracks(index)

returns a C<AudioFile::Identify::MusicBrainz::Track> object for the track
with the give track number.

=cut

sub track {
  my $self = shift;
  my $track = shift;
  return unless defined($track);

  if (length $track > 4) {
    return $self->store->track($track);
  } else {
    return $self->store->track($self->{tracks}->[$track]);
  }

}


1;
