################################################################################
# WeBWorK Online Homework Delivery System
# Copyright � 2000-2006 The WeBWorK Project, http://openwebwork.sf.net/
# $CVSHeader: webwork2/lib/WeBWorK/Request.pm,v 1.5 2006/06/29 23:20:47 sh002i Exp $
# 
# This program is free software; you can redistribute it and/or modify it under
# the terms of either: (a) the GNU General Public License as published by the
# Free Software Foundation; either version 2, or (at your option) any later
# version, or (b) the "Artistic License" which comes with this package.
# 
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE.  See either the GNU General Public License or the
# Artistic License for more details.
################################################################################

package WeBWorK::Request;

=head1 NAME

WeBWorK::Request - a request to the WeBWorK system, a subclass of
Apache::Request with additional WeBWorK-specific fields.

=cut

use strict;
use warnings;

use mod_perl;
use constant MP2 => ( exists $ENV{MOD_PERL_API_VERSION} and $ENV{MOD_PERL_API_VERSION} >= 2 );

# This class inherits from Apache::Request under mod_perl and Apache2::Request under mod_perl2
BEGIN {
	if (MP2) {
		require Apache2::Request;
		Apache2::Request->import;
		push @WeBWorK::Request::ISA, "Apache2::Request";
	} else {
		require Apache::Request;
		Apache::Request->import;
		push @WeBWorK::Request::ISA, "Apache::Request";
	}
}

# Apache2::Request's param method doesn't support setting parameters, so we need to provide the
# behavior in this class if we're running under mod_perl2.
BEGIN {
	if (MP2) {
		*param = sub {
			my $self = shift;
			if (@_ == 0) {
				my %names;
				@names{$self->SUPER::param} = ();
				@names{keys %{$self->{paramcache}}} = ();
				return keys %names;
			} elsif (@_ == 1) {
				my $name = shift;
				if (exists $self->{paramcache}{$name}) {
					my $val = $self->{paramcache}{$name};
					if (ref $val eq "ARRAY") {
						return @$val;
					} else {
						return $val;
					}
				} else {
					return $self->SUPER::param($name);
				}
			} elsif (@_ == 2) {
				my ($name, $val) = @_;
				$self->{paramcache}{$name} = $val;
				if (ref $val eq "ARRAY") {
					return @$val;
				} else {
					return $val;
				}
			}
		}
	}
}


=head1 CONSTRUCTOR

=over

=item new(@args)

Creates an new WeBWorK::Request. All arguments are passed to Apache::Request's
constructor. You must specify at least an Apache request_rec object.

=for comment

From: http://search.cpan.org/~joesuf/libapreq-1.3/Request/Request.pm#SUBCLASSING_Apache::Request

If the instances of your subclass are hash references then you can actually
inherit from Apache::Request as long as the Apache::Request object is stored in
an attribute called "r" or "_r". (The Apache::Request class effectively does the
delegation for you automagically, as long as it knows where to find the
Apache::Request object to delegate to.)

=cut

sub new {
	my ($invocant, @args) = @_;
	my $class = ref $invocant || $invocant;
	# construct the appropriate superclass instance depending on mod_perl version
	my $apreq_class = MP2 ? "Apache2::Request" : "Apache::Request";
	return bless { r => $apreq_class->new(@args) }, $class;
}

=back

=cut

=head1 METHODS

=over

=item ce([$new])

Return the course environment (WeBWorK::CourseEnvironment) associated with this
request. If $new is specified, set the course environment to $new before
returning the value.

=cut

sub ce {
	my $self = shift;
	$self->{ce} = shift if @_;
	return $self->{ce};
}

=item db([$new])

Return the database (WeBWorK::DB) associated with this request. If $new is
specified, set the database to $new before returning the value.

=cut

sub db {
	my $self = shift;
	$self->{db} = shift if @_;
	return $self->{db};
}

=item authen([$new])

Return the authenticator (WeBWorK::Authen) associated with this request. If $new
is specified, set the authenticator to $new before returning the value.

=cut

sub authen {
	my $self = shift;
	$self->{authen} = shift if @_;
	return $self->{authen};
}

=item authz([$new])

Return the authorizer (WeBWorK::Authz) associated with this request. If $new is
specified, set the authorizer to $new before returning the value.

=cut

sub authz {
	my $self = shift;
	$self->{authz} = shift if @_;
	return $self->{authz};
}

=item urlpath([$new])

Return the URL path (WeBWorK::URLPath) associated with this request. If $new is
specified, set the URL path to $new before returning the value.

=cut

sub urlpath {
	my $self = shift;
	$self->{urlpath} = shift if @_;
	return $self->{urlpath};
}

=back

=cut

1;
