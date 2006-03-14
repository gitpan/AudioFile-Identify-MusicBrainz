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
  my $class = shift;
  my $id = shift;
  my $store = shift;
  my $node = shift;
  my $self = undef;

  # See if an object already exists in the store
  if (defined($id) and defined($store)) {
    $self = $store->objExists($id);
  }

  # If the object wasn't found in the store, create a new one and
  # initialize it.
  unless (defined $self) {
    $self = {};
    bless $self, $class;
    $self->init();
  }

  # Set the appropriate parameters
  $self->store($store) if defined $store;
  $self->id($id) if defined $id;
  $self->parse($node) if defined $node;

  # Save the object in the store if possible
  if (defined($id) and defined($store)) {
    $store->obj($id, $self);
  }

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

      # Make sure tags start with a lowercase char.  In particluar,
      # this takes care of the ASIN value, which comes back from the
      # server with a name 'Asin'.
      $tag = lcfirst($tag);

      if ($self->can($tag)) {
        $self->$tag($child);
      } else {
        warn(ref($self), " has no method for property $tag (data is ",
	     $child->toString, ")\n");
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


# The MusicBrainz server returns certain characters encoded as XML
# entities.  This method transforms them back to the values expected
# by a user.
sub _unescape_mb {
    my $val = shift;
    $val =~ s/&amp;/&/g if defined $val;
    $val =~ s/&lt;/</g if defined $val;

    return $val;
}


# Internal method to simplify the implementation of several other
# accessor methods.  Implements a method where the name of the
# internal hash member to get/set is passed in the C<$var> parameter
# and the value to set it to (if any) is passed in C<$set>.  If the
# value of C<$set> is an C<XML::DOM::Element>, it will be parsed and
# the first child element will be rendered as a string and used for
# the value.
sub _xmlChildAccessor {
  my $self = shift;
  my $var = shift;
  my $set = shift;

  if (defined($set)) {
    if (ref $set and $set->isa('XML::DOM::Element') and $set->getFirstChild) {
      $self->{$var} = _unescape_mb($set->getFirstChild->toString);
    } else {
      $self->{$var} = $set;
    }
    return $self;
  } else {
    if (not defined $self->{$var} and $self->can("getData")) {
      $self->getData();
    }
    return $self->{$var};
  }
}


# Internal method to simplify the implementation of several other
# accessor methods.  Implements a method where the name of the
# internal hash member to get/set is passed in the C<$var> parameter
# and the value to set it to (if any) is passed in C<$set>.  If the
# value of C<$set> is an C<XML::DOM::Element>, it will be parsed and
# the value of the rdf:resource attribute will be used for the value.
sub _xmlAttributeAccessor {
  my $self = shift;
  my $var = shift;
  my $set = shift;

  if (defined($set)) {
    if (ref $set and $set->isa('XML::DOM::Element')) {
      $self->{$var} = $set->getAttributeNode("rdf:resource")->getValue;
    } else {
      $self->{$var} = $set;
    }
    return $self;
  } else {
    if (not defined $self->{$var} and $self->can("getData")) {
      $self->getData();
    }
    return $self->{$var};
  }
}


1;
