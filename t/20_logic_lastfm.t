use strict;
use Test::More;

BEGIN {
    use_ok('PostTrack::Logic::LastFM');
}

my $lastfm = PostTrack::Logic::LastFM->new;
my $tracks = $lastfm->search_track({ track => 'wonderwall' });
ok($tracks);
is($tracks->[0]{artist}, 'Oasis');

done_testing();
