=head1 NAME

AudioFile::Identify::MusicBrainz::Object

=head1 DESCRIPTION

Base class for L<AudioFile::Identify::MusicBrainz> objects.

=head1 METHODS

=cut

package AudioFile::Identify::MusicBrainz::Object;

use strict;
use warnings::register;
use Carp;

=head2 new

'new' method. Don't override this; override C<init> instead.

=cut

sub new {
  my $self = {};
  my $class = shift;
  bless $self, $class;
  $self->init;
  $self;
}

=head2 init

blank init method, used in some base classes to do setup

=cut

sub init { 1 }

=head2 parse

passed an C<XML::DOM::Node> object, parse assumes that it's a
Musicbrainz object, a Track, Album, whatever. For each chils of the
element, strip the namespace of the tag name, and call the method on
$self with that name, passing the C<XML::DOM::Node> that is that tag.

The base classes of Object will have methods like 'title', 'artist',
etc, that parse the passed Node object and extract the right data. See
L<AudioFile::Identify::MusicBrainz::Artist>, for instance, for examples.

=cut

sub parse {
  my $self = shift or croak;
  my $node = shift or croak;

  my $child = $node->getFirstChild();
  while($child) {
    if ($child->getNodeType == 1) {
      my $tag = $child->getTagName;
      $tag =~ s/.*://;
      if ($self->can($tag)) {
        $self->$tag($child);
      } else {
        print STDERR ref($self)." has no method for property $tag (data is ".$child->toString.")\n";
      }
    }
    $child = $child->getNextSibling();
  }

  return $self;

}

=head2 id

get/set the 'id' property - I use the url of the rdf resource.

=cut

sub id {
  my $self = shift;
  my $set = shift;
  if (defined($set)) {
    $self->{id} = $set;
    return $self;
  } else {
    return $self->{id};
  }
}
 
=head2 store

get/set the 'store' property. I use the store to keep all the objects that
I know about. Whenever we parse some rdf and get an object out of it, we put
the object in the store. see L<AudioFile::Identify::MusicBrainz::Store>.

=cut

sub store {
  my $self = shift;
  my $set = shift;
  if (defined($set)) {
    $self->{store} = $set;
    return $self;
  } else {
    return $self->{store};
  }
}

1;
