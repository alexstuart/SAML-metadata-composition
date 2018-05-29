#!/usr/bin/perl -w
#
# Takes an EntityDescriptor or EntititesDescriptor and determines the
# composition of it
#
use XML::LibXML;
use Getopt::Long;

sub usage {
        my $message = shift(@_);
        if ($message) { print "\n$message\n"; }

        print <<EOF;

	usage: $0 [-h] [ -reg <regAuth> ] [-l] <file>

	-h - print this help text and exit

	<regAuth> - only output entities from this registrationAuthority
	-l        - list the registrationAuthority strings in this file

	Given an EntityDescriptor or EntitiesDescriptor, display the elements
	that are in this file. Outputs number of occurences.

EOF
}

my $help;
my $registrationAuthority;
my $list;
GetOptions (	"help" => \$help,
		"reg=s" => \$registrationAuthority,
		"list" => \$list
	   );

if ( $help ) {
	usage;
	exit 0;
}

if ( ! $ARGV[0] ) {
	usage "ERROR: Must provide a file to check";
	exit 1;
}

$xmlfile = $ARGV[0];

if ( ! -r $xmlfile ) {
	usage "ERROR: Must provide a readable XML file, not $xmlfile";
	exit 1;
}

my @nodes;
my $dom = XML::LibXML->load_xml( location => $xmlfile);
my $xpc = XML::LibXML::XPathContext->new( $dom );
$xpc->registerNs( 'md', 'urn:oasis:names:tc:SAML:2.0:metadata' );
$xpc->registerNs( 'mdrpi', 'urn:oasis:names:tc:SAML:metadata:rpi' );

if ( $list ) {
	my @nodes = $xpc->findnodes( '//md:EntityDescriptor/md:Extensions/mdrpi:RegistrationInfo/@registrationAuthority' );
	foreach (@nodes) {
		my $regAuth = ${_}->to_literal;
		#print "$regAuth\n";
		++$frequency{ $regAuth };
	}
	foreach (sort { $frequency{ $b } <=> $frequency{ $a } } keys %frequency) {
		print "$_ $frequency{ $_ }\n";
	}
	exit 0;
}

if ( $registrationAuthority ) {
	@nodes = $xpc->findnodes( '//md:EntityDescriptor[md:Extensions/mdrpi:RegistrationInfo/@registrationAuthority="' . $registrationAuthority . '"]');
} else {
	@nodes = $xpc->findnodes( '//md:EntityDescriptor');
}

#print "Walking through the tree...\n";
my %elements; 
foreach (@nodes) { 
	processNode( $_ );
}
foreach (sort keys %elements) {
	print "$_ $elements{$_}\n";
}

sub processNode {
	my $node = shift;
	my $nodeNS;

	if ( $node->nodeType != XML_ELEMENT_NODE) { return; }
	$nodeNS = '{' . $node->namespaceURI . '}' . $node->localname;
	#print "$nodeNS\n";
        ++$elements{ $nodeNS };
	#print $node->nodePath() . "\n";
	if ( ! $node->hasChildNodes ) { return; }
	foreach $child ($node->childNodes) {
		if ( $child->nodeType != XML_ELEMENT_NODE) { next; }
		processNode( $child );
	}


}




