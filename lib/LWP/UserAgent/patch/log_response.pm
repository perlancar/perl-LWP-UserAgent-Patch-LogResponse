package LWP::UserAgent::patch::log_response;

use 5.010001;
use strict;
no warnings;

use Module::Patch 0.07 qw();
use base qw(Module::Patch);

# VERSION

our %config;

my $p_simple_request = sub {
    require Log::Any;

    my $ctx  = shift;
    my $orig = shift;
    my $resp = $orig->(@_);

    my $log = Log::Any->get_logger;
    $log->tracef("HTTP response header:\n%s",
                 $resp->status_line . "\r\n" . $resp->headers->as_string);
    $resp;
};

sub patch_data {
    return {
        v => 2,
        patches => [
            {
                action      => 'wrap',
                mod_version => qr/^6\.0.*/,
                sub_name    => 'simple_request',
                code        => $p_simple_request,
            },
        ],
    };
}

1;
# ABSTRACT: Patch module for LWP::UserAgent

=head1 SYNOPSIS

 use LWP::UserAgent::patch::log_response;

 # now all your LWP HTTP responses are logged

Sample script and output:

 % TRACE=1 perl -MLog::Any::App -MLWP::UserAgent::patch::log_response \
   -MLWP::Simple -e'getprint "http://www.google.com/"'


=head1 DESCRIPTION

This module patches LWP::UserAgent (which is used by LWP::Simple,
WWW::Mechanize, among others) so that HTTP responses are logged using
L<Log::Any>.


=head1 FAQ

=head2 Why not subclass?

By patching, you do not need to replace all the client code which uses LWP (or
WWW::Mechanize, etc).


=head1 SEE ALSO

Use L<Net::HTTP::Methods::patch::log_request> to log raw HTTP requests being
sent to servers.

=cut
