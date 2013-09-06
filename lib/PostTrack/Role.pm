package PostTrack::Role;
use Mouse::Role;
use LWP::UserAgent;

has 'ua' => ( is => 'ro', isa => 'LWP::UserAgent', lazy_build => 1 );

sub _build_ua {
    LWP::UserAgent->new();
}

1;
