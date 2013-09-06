package PostTrack;
use strict;
use warnings;
use File::Spec;

our $VERSION = '0.01';

sub config_file {
    my $mode = $ENV{PLACK_ENV} || 'development';
    my $fname = File::Spec->catfile( PostTrack->base_dir() . '/config', $mode . '.pl' );
    $fname = readlink $fname || $fname;
    return $fname;
}

sub config {
    my $fname = PostTrack->config_file();
    my $config = undef;
    if( -f $fname ){
        $config = do $fname or die "Cannnot load configuration file: $fname";
    }else{
        die "Cannot find configuration file: $fname";
    }
    return $config;
}

sub base_dir {
    my $path = ref $_[0] || $_[0];
    $path =~ s!::!/!g;
    if ( my $libpath = $INC{"$path.pm"} ) {
        $libpath =~ s!(?:blib/)?lib/+$path\.pm$!!;
        return File::Spec->rel2abs( $libpath || './' );
    }
    return File::Spec->rel2abs( './' );
}

1;
