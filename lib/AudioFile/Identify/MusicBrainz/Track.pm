=head1 NAME

AudioFile::Identify::MusicBrainz::Track

=head1 DESCRIPTION

A 'Track' object. Holds properties like 'trackNum', 'artist', 'title', etc.

=head1 METHODS

=cut

package AudioFile::Identify::MusicBrainz::Track;

use strict;
use warnings::register;
use base qw(AudioFile::Identify::MusicBrainz::Object);
use Carp;


=head2 title

get/set the track title. Pass a string or an C<XML::DOM::Element>.

=cut

sub title {
  my $self = shift;
  my $set = shift;
  return $self->_xmlChildAccessor("title", $set);
}


=head2 trackNum

get/set the trackNum. Pass a number or an C<XML::DOM::Element>. Note that
this doesn't do the iTunes-style '3/14' numbering, it'll just be '3'.

=cut

sub trackNum {
  my $self = shift;
  my $set = shift;
  return $self->_xmlChildAccessor("trackNum", $set);
}


=head2 trmid

get/set the trmid. Pass a string or an C<XML::DOM::Element>.  NOTE:
This only returns the first TRM ID, even if more than one is provided
by the MusicBrainz server.

=cut

sub trmid {
  my $self = shift;
  my $set = shift;
  return $self->_xmlChildAccessor("trmid", $set);
}


=head2 creator

get/set the creator id. Pass a string or an C<XML::DOM::Element>. This
corresponds to the artist, but don't get the artist like this, get the
artist with the L<artist> method, which will return a
C<AudioFile::Identify::MusicBrainz::Artist> object.

=cut

sub creator {
  my $self = shift;
  my $set = shift;
  return $self->_xmlAttributeAccessor("creator", $set);
}


=head2 artist

return a L<AudioFile::Identify::MusicBrainz::Artist> object for the
track artist.

=cut

sub artist {
  my $self = shift;
  return $self->store->artist($self->creator);
}


=head2 duration

get/set the track duration, in seconds.  Pass a scalar value for
duration or a C<XML::DOM::Element>.

=cut

sub duration {
  my $self = shift;
  my $set = shift;
  if (defined($set)) {
    if (ref $set and UNIVERSAL::isa($set, 'XML::DOM::Element') and $set->getFirstChild) {
      $self->{duration} = $set->getFirstChild->toString;
      $self->{duration} = int($self->{duration} / 1000); # SECONDS, damnit.
    } else {
      $self->{duration} = $set;
    }
    return $self;
  } else {
    $self->getData unless defined $self->{duration};
    return $self->{duration};
  }
}


=head2 getData

The track object is created with no data in it, merely an url to ask
about for more information. getData() will get that url and build the
properties of the track. It's safe to call multiple times, as it won't
fetch the data more than once.

However, you really don't need to call it at all.  The various
accessor methods of the Track object will take care of invoking this
function when necessary.  Also, if you're getting the Track object via
a Request or Album object, you can ignore this, as it'll be called for
you.

=cut

sub getData {
  my $self = shift;
  return $self if $self->{got_data};
  my $url = $self->id;
  #print STDERR "Parsing from URL $url\n";

  my $ua = AudioFile::Identify::MusicBrainz::Query::userAgent();
  my $res = $ua->get($url);

  # Mark as attempted here, in case it doesn't work out.  We don't
  # want to keep attempting to retrieve something that isn't working.
  $self->{got_data} = 1;

  if (not $res->is_success) {
    croak "Could not retrieve data for track '$url': $res->code";
  }

  my $data = $res->content;

  my $parser = new XML::DOM::Parser;
  my $doc = $parser->parse($data);
  my $node = $doc->getElementsByTagName('mm:Track')->item(0);

  return $self->parse($node);
}


1;

