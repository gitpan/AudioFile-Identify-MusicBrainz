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
use LWP::Simple;

=head2 title

get/set the track title. Pass a string or an C<XML::DOM::Element>.

=cut

sub title {
  my $self = shift;
  my $set = shift;
  if (defined($set)) {
    if ($set->isa('XML::DOM::Element') and $set->getFirstChild) {
      $self->{title} = $set->getFirstChild->toString;
    } else {
      $self->{title} = $set;
    }
    return $self;
  } else {
    $self->getData;
    return $self->{title};
  }
}

=head2 title

get/set the trackNum. Pass a number or an C<XML::DOM::Element>. Note that
this doesn't do the iTunes-style '3/14' numbering, it'll just be '3'.

=cut

sub trackNum {
  my $self = shift;
  my $set = shift;
  if (defined($set)) {
    if ($set->isa('XML::DOM::Element') and $set->getFirstChild) {
      $self->{trackNum} = $set->getFirstChild->toString;
    } else {
      $self->{trackNum} = $set;
    }
    return $self;
  } else {
    $self->getData;
    return $self->{trackNum};
  }
}

=head2 trmid

get/set the trmid. Pass a string or an C<XML::DOM::Element>.

=cut


sub trmid {
  my $self = shift;
  my $set = shift;
  if (defined($set)) {
    if ($set->isa('XML::DOM::Element') and $set->getFirstChild) {
      $self->{trmid} = $set->getFirstChild->toString;
    } else {
      $self->{trmid} = $set;
    }
    return $self;
  } else {
    $self->getData;
    return $self->{trmid};
  }
}

=head2 creator

get/set the creator id. Pass a string or an C<XML::DOM::Element>. This corresponds
to the artist, but don't get the artist like this, get the artist with the L<artist>
method, which will return a C<AudioFile::Identify::MusicBrainz::Artist> object.

=cut

sub creator {
  my $self = shift;
  my $set = shift;
  if (defined($set) and $set->isa('XML::DOM::Element')) {
    $self->{creator} = $set->getAttributeNode("rdf:resource")->getValue;
    return $self;
  } else {
    $self->getData;
    return $self->{creator};
  }
}

=head2 artist

return a L<AudioFile::Identify::MusicBrainz::Artist> object for the track artist.

=cut

sub artist {
  my $self = shift;
  return $self->store->artist($self->creator);
}

=head2 duration

get/set the track duration, in seconds.

=cut

sub duration {
  my $self = shift;
  my $set = shift;
  if (defined($set)) {
    if ($set->isa('XML::DOM::Element') and $set->getFirstChild) {
      $self->{duration} = $set->getFirstChild->toString;
      $self->{duration} = int($self->{duration} / 1000); # SECONDS, damnit.
    } else {
      $self->{duration} = $set;
    }
    return $self;
  } else {
    $self->getData;
    return $self->{duration};
  }
}

=head2 getData

The track object is created with no data in it, merely an url to ask about
for more information. getData() will get that url and build the properties of
the track. It's safe to call multiple times, as it won't fetch the data more
than once.

If you're getting the Track object via a Request or Album object, you can ignore
this, as it'll be called for you.

=cut

sub getData {
  my $self = shift;
  return $self if $self->{got_data};
  my $url = $self->id;
  #print STDERR "Parsing from URL $url\n";
  my $data = get($url); # TODO reuse LWP::Useragent stuff from query.

  my $parser = new XML::DOM::Parser;
  my $doc = $parser->parse($data);
  my $node = $doc->getElementsByTagName('mm:Track')->item(0);

  $self->{got_data} = 1;
  return $self->parse($node);
}


1;

