=head1 NAME

AudioFile::Identify::MusicBrainz::Store

=head1 DESCRIPTION

Acts as a cache to store and retrieve objects. All created objects have the
store passed to them, and keep created objects in it.

=head1 METHODS

=cut

package AudioFile::Identify::MusicBrainz::Store;

use strict;
use warnings::register;
use base qw(AudioFile::Identify::MusicBrainz::Object);
use Carp;

use AudioFile::Identify::MusicBrainz::RDF qw(rdf);
use AudioFile::Identify::MusicBrainz::Artist;

=head2 init

the init method (called by new) creates an artist in the store for the
'Various Artists' artist, used by MusicBrainz for.. well, representing
'Various Artists', mostly.

=cut

sub init {
  my $self = shift;
  my $va = rdf('MBI_VARIOUS_ARTIST_ID');
  $self->artist($va,
    AudioFile::Identify::MusicBrainz::Artist->new()
                                            ->store($self)
                                            ->title('Various Artists')
  );
  1;
}

=head2 album(id, [album])

get/set an album with a given id in the store.

=cut

sub album {
  my $self = shift;
  my $id = shift;
  croak "Need an id" unless $id;
  $id =~ s!http://mm.!http://!; # GAAAAAAAH
  my $set = shift;
  if (defined($set)) {
#    print STDERR "Stored album with id $id\n";
    $self->{album}{$id} = $set;
    return $self;
  } else {
    my $album = $self->{album}{$id} or die "No album with id $id";
    return $album;
  }
}

=head2 artist(id, [album])

get/set an artist with a given id in the store.

=cut

sub artist {
  my $self = shift;
  my $id = shift;
  croak "Need an id" unless $id;
  $id =~ s!http://mm.!http://!; # GAAAAAAAH
  my $set = shift;
  if (defined($set)) {
#    print STDERR "Stored artist with id $id\n";
    $self->{artist}{$id} = $set;
    return $self;
  } else {
    my $artist = $self->{artist}{$id} or die "No artist with id $id";
    return $artist;
  }
}

=head2 track(id, [album])

get/set an track with a given id in the store.

=cut

sub track {
  my $self = shift;
  my $id = shift;
  croak "Need an id" unless $id;
  $id =~ s!http://mm.!http://!; # GAAAAAAAH
  my $set = shift;
  if (defined($set)) {
#    print STDERR "Stored track with id $id\n";
    $self->{track}{$id} = $set;
    return $self;
  } else {
    my $track = $self->{track}{$id} or die "No track with id $id";
    return $track;
  }
}


1;

