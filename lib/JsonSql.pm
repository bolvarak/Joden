#!/usr/bin/perl -w

package JsonSql;
	use strict;
	use JSON;
	use DateTime;

		my($_json) = JSON->new->pretty->indent->utf8->allow_nonref;
		my(%_conn);
		
			sub new
			{
				my($_class) = @_;
				my($_self)  = {
					connect   => {
						host => 'string', 
						user => 'string', 
						pass => 'string', 
						db   => 'string', 
						port => 'integer'
					}, 
					query     => {
						sql => 'string'
					}
				};
				%_conn      = ();
						
					return(bless($_self));
			}

			sub map 
			{
				my($_self) = @_;
			
				return(to_json({%{$_self}}, {
					pretty => 1, 
					utf8   => 1, 
				}));
			}

			sub parse 
			{
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
			}

			sub connect 
			{
				my($_self, %_data) = @_;
			}		return(1);

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
1;
__END__
