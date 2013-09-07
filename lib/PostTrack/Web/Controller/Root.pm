package PostTrack::Web::Controller::Root;
use Mojo::Base 'Mojolicious::Controller';
use PostTrack::Logic::LastFM;
use Facebook::Graph;
use LWP::UserAgent;
use Encode;
use Try::Tiny;

sub index {
    my $self = shift;
    $self->render();
}

sub search {
    my $self = shift;
    my $t = $self->req->param('track') || '';
    my $a = $self->req->param('artist') || '';
    return $self->redirect_to('/') unless $t;
    my $lastfm = PostTrack::Logic::LastFM->new;
    my $tracks = $lastfm->search_track({ track => decode_utf8($t), artist => $a });
    $self->stash->{tracks} = $tracks;
}

sub action {
    my $self = shift;
    my $track_url = $self->req->param('track_url');
    if(my $access_token = $self->session->{access_token}) {
        $self->post($access_token, $track_url);
        return $self->redirect_to('/');
    }
    $self->session->{track_url} = $track_url;    
    my $uri = $self->fb()->authorize->extend_permissions(qw/publish_actions/)->uri_as_string;
    $self->redirect_to($uri);
}

sub redirect {
    my $self = shift;
    return $self->redirect_to('/');
}

sub callback {
    my $self = shift;
    my $code = $self->req->param('code');
    my $access_token;
    try {
        $access_token = $self->fb()->request_access_token($code);
    };
    my $path = $self->url_for('/')->to_abs->to_string();
    return $self->redirect_to($path) unless $access_token;
    $self->post($access_token->token, $self->session->{track_url});
    $self->session->{access_token} = undef;
    return $self->redirect_to($path);
}

sub fb {
    my $config = PostTrack->config()->{facebook};
    my $fb = Facebook::Graph->new(
        app_id => $config->{app_id},
        secret => $config->{app_secret},
        postback => $config->{site_url} . 'callback'
    );
    return $fb;
}

sub post {
    my ($self, $access_token, $track_url) = @_;
    my $uri = URI->new('https://graph.facebook.com/me/music.listens');
    $uri->query_form(
        access_token => $access_token,
        method => 'POST',
        song => $track_url
    );
    my $ua = LWP::UserAgent->new;
    my $res = $ua->post($uri);
}

1;
