#!/usr/bin/perl -w
#
# Takes an EntityDescriptor or EntititesDescriptor and determines the
# composition of it
#
if ( ! $ARGV[0] ) {
	print "Must provide a file to check\n";
	exit 1;
}

$xmlfile = $ARGV[0];

if ( ! -r $xmlfile ) {
	print "Must provide a readable XML file, not $xmlfile\n";
	exit 1;
}

if ( $ARGV[1] ) {
	$registrationAuthority = $ARGV[1];
	print "Only looking for registrationAuthority $registrationAuthority\n";
}
my @nodes;
use XML::LibXML;
my $dom = XML::LibXML->load_xml( location => $xmlfile);
my $xpc = XML::LibXML::XPathContext->new( $dom );
$xpc->registerNs( 'md', 'urn:oasis:names:tc:SAML:2.0:metadata' );
$xpc->registerNs( 'mdrpi', 'urn:oasis:names:tc:SAML:metadata:rpi' );
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




