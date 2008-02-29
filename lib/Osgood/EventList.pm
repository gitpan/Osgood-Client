package Osgood::EventList;
use Moose;
use MooseX::Iterator;

has 'events' => ( is => 'rw', isa => 'ArrayRef', default => sub { [] } );

has 'iterator' => (
	metaclass => 'Iterable',
	iterate_over => 'events'
);

=head1 NAME

Osgood::EventList - A list of Osgood events.

=head1 DESCRIPTION

A list of events.

=head1 SYNOPSIS

  my $list = new Osgood::EventList();
  $list->add_to_events($event);
  print $list->size()."\n";

=head1 METHODS

=head2 Constructor

=over 4

=item new

Creates a new Osgood::EventList object.

=back

=head2 Class Methods

=over 4

=item add_to_events

Add the specified event to the list.

=cut
sub add_to_events {
	my $self = shift();
	my $event = shift();

	push(@{ $self->events() }, $event);
}

=item events

Set/Get the ArrayRef of events in this list.

=item size

Returns the number of events in this list.

=cut
sub size {
	my $self = shift();

	return scalar(@{ $self->events });
}

=item get_highest_id

Retrieves the largest id from the list of events.  This is useful for keeping
state with an external process that needs to 'remember' the last event id
it handled.

=cut
sub get_highest_id {
	my $self = shift();

	my $high = undef;
	foreach my $event (@{ $self->events() }) {
		if(!defined($high) || ($high < $event->id())) {
			$high = $event->id();
		}
	}

	return $high;
}

=head1 AUTHOR

Cory 'G' Watson <gphat@cpan.org>

=head1 SEE ALSO

perl(1), L<Osgood::Event>

=head1 COPYRIGHT AND LICENSE

Copyright 2008 by Magazines.com, LLC

You can redistribute and/or modify this code under the same terms as Perl
itself.

=cut

1;