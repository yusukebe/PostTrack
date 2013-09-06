package PostTrack::Web;
use Mojo::Base 'Mojolicious';
use PostTrack;

sub startup {
    my $self = shift;
    $self->secret(PostTrack->config->{secret});
    my $r = $self->routes;
    $r->namespaces([qw/PostTrack::Web::Controller/]);
    $r->get('/')->to('root#index');
    $r->get('/search')->to('root#search');

    $r->get('/action')->to('root#action');
    $r->get('/login')->to('root#login');
    $r->get('/logout')->to('root#logout');
    $r->get('/callback')->to('root#callback');

}

1;
