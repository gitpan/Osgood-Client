package Osgood::EventList::Serializer;
use Moose;

has 'list' => ( is => 'rw', isa => 'Osgood::EventList' );
has 'version' => ( is => 'rw', isa => 'Int', default => 1 );

use XML::DOM;

=head1 NAME

Osgood::EventList::Serializer - Serializer for EventLists

=head1 DESCRIPTION

Serializes an EventList into XML.

=head1 SYNOPSIS

  my $serializer = new Osgood::EventList::Serializer(list => $list);
  my $xml = $serializer->serialize();

=head1 METHODS

=head2 Constructor

=over 4

=item new

Creates a new Osgood::EventList::Serializer object.

=back

=head2 Class Methods

=over 4

=item list

Get/Set the EventList we are serializing.

=item serialize

Serialize the EventList.  Returns an XML string.

=cut
sub serialize {
	my $self = shift();

	my $doc = new XML::DOM::Document;
	my $root = $doc->createElement('eventlist');
	$doc->appendChild($root);

	my $version = $doc->createElement('version');
	$version->addText('1');
	$root->appendChild($version);

	my $events = $doc->createElement('events');

	foreach my $event (@{ $self->list->events() }) {
		my $ev = $doc->createElement('event');

		if(defined($event->id())) {
			my $id = $doc->createElement('id');
			$id->addText($event->id());
			$ev->appendChild($id);
		}

		my $obj = $doc->createElement('object');
		$obj->addText($event->object());
		$ev->appendChild($obj);

		my $act = $doc->createElement('action');
		$act->addText($event->action());
		$ev->appendChild($act);

		my $do = $doc->createElement('date_occurred');
		$do->addText($event->date_occurred->iso8601());
		$ev->appendChild($do);

		if(scalar(keys(%{ $event->params() }))) {
			my $params = $doc->createElement('params');

			foreach my $key (keys(%{ $event->params() })) {
				my $param = $doc->createElement('param');

				my $name = $doc->createElement('name');
				$name->addText($key);
				$param->appendChild($name);
				my $value = $doc->createElement('value');
				$value->addText($event->get_param($key));
				$param->appendChild($value);

				$params->appendChild($param);
			}
			$ev->appendChild($params);
		}

		$events->appendChild($ev);
	}

	$root->appendChild($events);

	my $string = $doc->toString();
	$doc->dispose();
	return $string;
}

=item version

Get/Set the version of serialization we will be performing.

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