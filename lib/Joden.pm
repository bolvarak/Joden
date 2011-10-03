#!/usr/bin/perl -w
# Define our package
package Joden;
# We need strict syntax
use strict;
# We need JSON to decode requests
# and encode responses
use JSON;
# We need DateTime for the logs
use DateTime;
# Our connection placeholder
my(%oConnection) = ();
# This is the current database
my(%oDatabase)   = ();
# This is our error placeholder
my(@aErrors)     = [];
# Grab a new instance of JSON
my($oJson)       = JSON->new->pretty->indent->utf8->allow_nonref;
# This is our set of privileges
my(%oPrivileges) = ();
# This is our current resultset
my(@aResultSet)  = [];
# This subprocess is our constructor
# it sets up and blesses the instance
sub new {
	# Grab the class
	my($oClass) = @_;
	# Set the instance
	my($oInstance)  = {
		# connect   => {
		#	host => 'string', 
		#	user => 'string', 
		#	pass => 'string', 
		#	db   => 'string', 
		#	port => 'integer'
		# }, 
		# query     => {
		#	sql => 'string'
		# }
	};
	# Return the blessed instance
	return(bless($oInstance));
}

sub parse {
	my($_self, $_data) = @_;
	$_data             = (defined($_data) ? $_data : undef);
	my($_jql)          = undef;

	if (defined($_data) and $_json->decode($_data)) {
		$_jql = from_json($_data, {
			utf8 => 1
		});
	} else {
		$_jql = undef;
	}

	if ($_jql) {
		if (defined($_jql->{'method'})) {
			if ($_jql->{'method'} eq 'connect') {
				return($_self->connect(
					username => $_jql->{'user'}, 
					passwd   => $_jql->{'pass'}, 
					database => $_jql->{'db'}
				));
			}
			
			if ($_jql->{'method'} eq 'query') {
				return($_self->query($_jql->{'sql'}));
			}
		} else {
			return($_self->map);
		}
	} else {
		return($_self->map);
	}
}	return(1);

sub query
{
	my($_self, $_) = @_;
	my(@_parse)    = m/^(select)\s+([a-z0-9_\,\.\s\*]+)\s+from\s+([a-z0-9_\.]+)(?: where\s+\((.+)\))?\s*(?:order\sby\s+([a-z0-9_\,]+))?\s*(asc|ascending|desc|descending|ascnum|descnum)?\s*(?:limit\s+([0-9_\,]+))?/i;
	my(%_query)    = (
			query_string => $_, 
			query_type   => lc($_parse[0]), 
			fields       => $_parse[1], 
			from         => $_parse[2], 
			where        => $_parse[3], 
			orderby      => $_parse[4], 
			order        => lc($_parse[5]), 
			limit        => $_parse[6]
	);
	my(@_args);
		
	if ($_query{'fields'} =~ /,*\s*/) {
		
	}
	
	# if (defined($_query{'from'})) {
	#	$_query{'from'} =~ s/, /,/g;
	# }
	
	if ($_query{'where'} =~ /(and|or)\s*/i) {
		
		for my $_i (split(/(and|or)\s*/i, $_query{'where'})) {
			if ($_i =~ /(and|or)\s*/i) {
				push(@_args, lc($_i));
			} else {
				push(@_args, $_i);
			}
		}
		
		$_query{'where'} = [@_args];
	}
	
	
	
	return(to_json({%_query}, {
		pretty => 1, 
		utf8   => 1
	}));
}
# This subprocess reads the permissions
# store to get the abilities and check 
# the existance of the connecting user
sub readDatabasePrivileges {
	# Grab this instance 
	my($oInstance) = @_;
	# Privileges placeholder
	my($sPrivileges);
	# Open the privileges store
	open(DBPRIV, '../conf.d/privileges.json', 'r');
	# Read the privileges
	$sPrivileges = do {
		# Set the CLR
		local $\;
		# Read the data
		<DBPRIV>
	}
	# Close the privileges store
	close(DBPRIV);
	# Decode the privileges and store 
	# them into the system
	%oPrivileges = $oJson->decode($sPrivileges);
	# Return success
	return 1;
}
# This subprocess reads a database 
# a database store and stores it
# into the system
sub readDatabaseStore {
	# Grab this instance 
	# and database name
	my($oInstance, $sDatabase) = @_;
	# Database placeholder
	my($sDatabaseStore);
	# Open the database store
	open(DBS, "../conf.d/$sDatabase.json", 'r');
	# Read the database
	$sDatabaseStore = do {
		# Set the CLR
		local $\;
		# Read the data
		<DBS>
	}
	# Close the database store
	close(DBS);
	# Decode the database and
	# storeitinto the system
	%oDatabase = $oJson->decode($sDatabase);
	# Return success
	return 1;
}
# Terminate gracefully
1;
# This is the end of the file
__END__
