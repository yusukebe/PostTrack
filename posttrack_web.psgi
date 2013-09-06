#!/usr/bin/env perl
use strict;
use warnings;
use File::Spec;
use File::Basename;
use lib File::Spec->catdir(dirname('__FILE__'), 'lib');
use Mojo::Server::PSGI;
use Plack::Builder;
use PostTrack::Web;

my $psgi = Mojo::Server::PSGI->new( app => PostTrack::Web->new );
my $app = $psgi->to_psgi_app;

builder {
    enable 'Plack::Middleware::ReverseProxy';
    enable 'AxsLog',
        combined => 1,
        response_time => 1;
    $app;
};
