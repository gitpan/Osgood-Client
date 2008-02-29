package Osgood::Client;

use Moose;

use HTTP::Request;
use LWP::UserAgent;
use URI;
use XML::XPath;

use Osgood::EventList::Deserializer;
use Osgood::EventList::Serializer;

has 'error' => ( is => 'rw', iss => 'Str' );
has 'url' => ( is => 'rw', isa => 'URI', default => sub { new URI('http://localhost'); });
has 'list' => ( is => 'rw', isa => 'Osgood::EventList' );
has 'timeout' => ( is => 'rw', isa => 'Int', default => 30 );

our $VERSION = '1.0.4';
our $AUTHORITY = 'cpan:GPHAT';

=head1 NAME

Osgood::Client - Client for the Osgood Passive, Persistent Event Queue

=head1 DESCRIPTION

Provides a client for sending events to or retrieving events from an Osgood
queue.

=head1 SYNOPSIS

  my $event = new Osgood::Event(
	object => 'Foo', action => 'create',
	date_occurred => DateTime->now()
  );
  my $list = new Osgood::EventList(events => [ $event ])
  my $client = new Osgood::Client(
	url => 'http://localhost',
	list => $list
  );
  my $retval = $client->send();
  if($list->size() == $retval) {
    print "Success :)\n";
  } else {
    print "Failure :(\n";
  }

=head1 METHODS

=head2 Constructor

=over 4

=item new

Creates a new Osgood::Client object.

=back

=head2 Class Methods

=over 4

=item list

Set/Get the EventList.  For sending events, you should set this.  For
retrieving them, this will be populated after querying the queue.

=item send

Send events to the server.

=cut
sub send {
	my $self = shift();

	my $serializer = new Osgood::EventList::Serializer(list => $self->list());
  	my $xml = $serializer->serialize();

	my $ua = new LWP::UserAgent();

	my $req = new HTTP::Request(POST => $self->url->canonical().'/event/add');
	$req->content_type('application/x-www-form-urlencoded');
	$req->content("xml=$xml");

	my $res = $ua->request($req);

	if($res->is_success()) {

		my $xpresp = new XML::XPath(xml => $res->content());
		my $count = $xpresp->find('/response/@count');

		my $err = $xpresp->find('/response/@error');
		$self->error($err->string_value());

		return $count->string_value();
	} else {
		$self->error($res->status_line());
		return 0;
	}
}

=item query

Query the Osgood server for events.  Takes a hashref in the following format:

  {
    id => X,
	object => 'obj',
	action => 'foo',
	date => '2007-12-11'
  }

At least one key is required.

A true of false value is returned to denote the success of failure of the
query.  If false, then the error will be set in the error accessor.  On
success the list may be retrived from the list accessor.

=cut

sub query {
	my $self = shift();
	my $params = shift();

	if((ref($params) ne 'HASH') || !scalar(keys(%{ $params }))) {
		die('Must supply a hash of parameters to query.');
	}

	my $ua = new LWP::UserAgent();

	my $query = join('&', map { "$_=".$params->{$_} } keys(%{ $params }));

	my $req = new HTTP::Request(POST => $self->url->canonical().'/event/list?'.$query);

	my $res = $ua->request($req);

	if($res->is_success()) {

		my $deserializer = new Osgood::EventList::Deserializer(xml => $res->content());
		$self->list($deserializer->deserialize());

		return 1;
	} else {
		$self->error($res->status_line());
		return 0;
	}
}

=item timeout

The number of seconds to wait before timing out.

=item url

The host on which the Osgood queue we should contact is running.  Expects an
instance of URI.

=back

=head1 AUTHOR

Cory 'G' Watson <gphat@cpan.org>

=head1 SEE ALSO

perl(1), Osgood::Event, Osgood::EventList

=head1 COPYRIGHT AND LICENSE

Copyright 2008 by Magazines.com, LLC

You can redistribute and/or modify this code under the same terms as Perl
itself.

=cut

1;