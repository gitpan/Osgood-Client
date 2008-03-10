package Osgood::EventList::Deserializer;
use Moose;

has 'xml' => ( is => 'rw', isa => 'Str', required => 1);

use DateTime::Format::ISO8601;
use Osgood::Event;
use Osgood::EventList;
use XML::XPath;

=head1 NAME

Osgood::EventList::Deserializer - Deserializer for EventLists

=head1 DESCRIPTION

Deserializes an EventList from XML.

=head1 SYNOPSIS

  my $deserializer = new Osgood::EventList::Deserializer(xml => $xml);
  my $list = $deserializer->deserialize();

=head1 METHODS

=head2 Constructor

=over 4

=item new

Creates a new Osgood::Deserialize object.

=back

=head2 Class Methods

=over 4

=item serialize

Serialize the EventList.  Returns an XML string.

=cut
sub deserialize {
	my $self = shift();

	my $list = new Osgood::EventList();

	my $xp = new XML::XPath(xml => $self->xml());
	my $events = $xp->find('/eventlist/events/event');
	foreach my $node ($events->get_nodelist()) {

		my $id = $xp->find('id', $node);
		my $obj = $xp->find('object', $node);
		my $act = $xp->find('action', $node);
		my $docc = $xp->find('date_occurred', $node);

		my $event = new Osgood::Event(
			object	=> $obj->string_value(),
			action	=> $act->string_value(),
			date_occurred => DateTime::Format::ISO8601->parse_datetime(
				$docc->string_value()
			)
		);
		if(defined($id) && ($id->string_value() ne '')) {
			$event->id($id->string_value());
		}

		$list->add_to_events($event);

		my $params = $xp->find('params/param', $node);
		if($params->size() > 0) {
			foreach my $pnode ($params->get_nodelist()) {
				my $name = $xp->find('name', $pnode);
				my $value = $xp->find('value', $pnode);

				$event->set_param(
					$name->string_value(), $value->string_value()
				);
			}
		}
	}

	return $list;
}

=head1 AUTHOR

Cory 'G' Watson <gphat@cpan.org>

=head1 SEE ALSO

perl(1)

=head1 COPYRIGHT AND LICENSE

Copyright 2008 by Magazines.com, LLC

You can redistribute and/or modify this code under the same terms as Perl
itself.

=cut

1;