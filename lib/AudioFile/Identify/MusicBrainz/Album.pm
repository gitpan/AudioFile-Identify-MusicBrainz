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
use Carp;

=head2 title

get/set the title of the album. Pass a string or an C<XML::DOM::Node> object
to set.

=cut

sub title {
  my $self = shift;
  my $set = shift;
  return $self->_xmlChildAccessor("title", $set);
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
  return $self->_xmlAttributeAccessor("creator", $set);
}


=head2 artist

return the C<AudioFile::Identify::MusicBrainz::Artist> object that is the
returned artist for this album. May be the 'Various Artists' object.

=cut

sub artist {
  my $self = shift;
  return $self->store->artist($self->creator);
}


=head2 coverart

Returns a string containing the URL to the Amazon.com images server
for the album if one is available, otherwise returns C<undef>.

=cut

sub coverart {
  my $self = shift;
  my $set = shift;
  my $val = $self->_xmlAttributeAccessor("coverart", $set);

  if ($val eq "/images/no_coverart.png") {
    delete $self->{coverart};
    return undef;
  }

  return $val;
}


=head2 asin

Returns the ASIN for the album specified in this Album object.  ASIN
stands for Amazon Standard Identification Number.  It is a unique
identifier for a product on amazon.com.  This value can be used for
constructing links into the Amazon website for providing affiliate
referrals or for retrieving images or other information.

MusicBrainz only has ASIN values for a subset of all the albums in
their database, so this property will quite possibly be C<undef> if
MusicBrainz cannot provide a value.

=cut

sub asin {
  my $self = shift;
  my $set = shift;
  return $self->_xmlChildAccessor("asin", $set);
}


=head2 releaseDateList

Return a hash ref of release dates where the keys are country codes
and the values are dates of release in the respective countries.  Will
return C<undef> if MusicBrainz does not respond to the query with this
information.

=cut

sub releaseDateList {
  my $self = shift;
  my $set = shift;

  if (defined($set) and ref $set and $set->isa('XML::DOM::Element')) {

    $self->{releaseDates} = {};

    my $dates = $set->getElementsByTagName('mm:ReleaseDate');
    for (my $i = 0; $i < $dates->getLength; $i++) {

      my $date = $dates->item($i);

      my $dateStr = $date->getElementsByTagName('dc:date')
                         ->item(0)->getFirstChild()->getNodeValue();
      my $ctryStr = $date->getElementsByTagName('mm:country')
                         ->item(0)->getFirstChild()->getNodeValue();

      $self->{releaseDates}->{$ctryStr} = $dateStr;
    }

    return $self;
  } else {
    return $self->{releaseDates};
  }
}


=head2 releaseType

get/set the releaseType property

=cut

sub releaseType {
  my $self = shift;
  my $set = shift;
  return $self->_xmlAttributeAccessor("releaseType", $set);
}


=head2 releaseStatus

get/set the releaseStatus property

=cut

sub releaseStatus {
  my $self = shift;
  my $set = shift;
  return $self->_xmlAttributeAccessor("releaseStatus", $set);
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
  if (defined($set) and UNIVERSAL::isa($set, 'XML::DOM::Element')) {
    my $tracks = $set->getElementsByTagName('rdf:li');
    for (my $i = 0; $i < $tracks->getLength; $i++) {
      my $id = $tracks->item($i)->getAttributeNode('rdf:resource')->getValue;
      my $track = AudioFile::Identify::MusicBrainz::Track->new($id,
                     $self->store);
      # Initialize the trackNum based on the position in the
      # mm:trackList sequence
      $track->trackNum($i + 1);
      $self->{tracks}->[$i] = $id;
    }
    return $self;
  } else {
    croak "Must call with node\n";
  }
}


=head2 tracks

returns a listref of C<AudioFile::Identify::MusicBrainz::Track> object, in
track order for the album.

=cut

sub tracks {
  my $self = shift;
  return [ map { $self->store->track($_) } @{ $self->{tracks} } ];
}


=head2 track(index)

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
