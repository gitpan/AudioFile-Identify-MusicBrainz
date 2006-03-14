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


=head2 cleanObjId(id)

Package method that returns a cleaned up version of the object id, or
croaks if id is undefined.

=cut

sub cleanObjId {
    my $id = shift;
    croak "Need an id" unless defined($id);
    $id =~ s!http://mm.!http://!; # GAAAAAAAH
    return $id;
}



=head2 cleanObjId(id)

Package method that determines the type of an object from its URL.
Returns the type as a string, or croaks if id is undefined.

=cut

sub objType {
    my $id = shift;
    croak "Need an id" unless defined($id);
    #print STDERR "###'$id'\n";
    $id =~ m{musicbrainz.org(?:/mm-\d+\.\d+)?/(\w+)/} or warn("Can't parse `$id'"), return;
    return $1;
}


=head2 obj(id, [objRef])

get/set an object with a given id in the store.

=cut

sub obj {
    my $self = shift;
    my $id = cleanObjId(shift);
    my $set = shift;
    my $type = objType($id);

    if (defined($set)) {
        $self->{$type}{$id} = $set;
        return $self;
    } else {
        my $obj = $self->{$type}{$id} or croak "No $type with id $id";
        return $obj;
    }
}


=head2 objExists(id)

Returns the reference to the object with the passed C<id>.  This
evaluates to true if an object with a given id exists in the store,
false otherwise.

=cut

sub objExists {
    my $self = shift;
    my $id = cleanObjId(shift);
    my $type = objType($id);

    return $self->{$type}{$id};
}


=head2 album(id, [album])

get/set an album with a given id in the store.

=cut

sub album {
    my $self = shift;
    return $self->obj(@_);
}


=head2 artist(id, [album])

get/set an artist with a given id in the store.

=cut

sub artist {
    my $self = shift;
    return $self->obj(@_);
}


=head2 track(id, [album])

get/set an track with a given id in the store.

=cut

sub track {
    my $self = shift;
    return $self->obj(@_);
}

1;

