package PostTrack::Logic::LastFM;
use Mouse;
with qw/PostTrack::Role/;
use URI;
use JSON qw/decode_json/;
use PostTrack;

has 'base_uri' => (
    is      => 'ro',
    isa     => 'URI',
    default => sub {
        URI->new('http://ws.audioscrobbler.com/2.0/');
    }
);

sub search_track {
    my ($self, $args) = @_;
    my $uri = $self->base_uri->clone();
    my $api_key = PostTrack->config()->{lastfm}{api_key};
    $uri->query_form(
        %$args,
        api_key => $api_key,
        method  => 'track.search',
        format  => 'json'
    );
    my $res = $self->ua->get($uri);
    if ($res->is_error){
        die $res->status_line . "\n\n" . $res->decoded_content;
    }
    my $json = $res->decoded_content;
    my $data = decode_json($json);
    if($data->{results}{'opensearch:totalResults'} > 0) {
        return $data->{results}{trackmatches}{track};
    }else{
        return [];
    }
}

__PACKAGE__->meta->make_immutable();
