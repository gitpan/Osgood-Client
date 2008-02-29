use Test::More tests => 7;

BEGIN {
	use_ok('Osgood::EventList::Serializer');
	use_ok('Osgood::EventList::Deserializer');
}

use Osgood::Event;
use Osgood::EventList;

use XML::XPath;

my $list = new Osgood::EventList;

my $ser = new Osgood::EventList::Serializer(list => $list);
isa_ok($ser, 'Osgood::EventList::Serializer', 'isa Osgood::EventList::Serializer');

my $xml = $ser->serialize();

my $xp = new XML::XPath(xml => $xml);

my $evsnd = $xp->find('/eventlist/events');
cmp_ok($evsnd->size(), '==', 1, 'One events node');

my $evnd = $xp->find('/eventlist/events/event');
cmp_ok($evnd->size(), '==', 0, 'Zero event nodes');

my $des = new Osgood::EventList::Deserializer(xml => $xml);
my $slist = $des->deserialize();
isa_ok($slist, 'Osgood::EventList', 'isa Osgood::EventList');

cmp_ok($slist->size(), '==', 0, 'Zero events');
