package ParlAPI::Controller;
use Moose::Role;
use Template;
use Plack::Response;
use ParlAPI::Model;
use JSON qw/to_json/;
use namespace::clean -except => 'meta';

has 'template' => (is => 'ro', lazy_build => 1);
has 'model'    => (is => 'ro', lazy_build => 1);

sub render {
    my ($self, $template, $vars) = @_;

    my $resp = Plack::Response->new(200);
    eval {
        $resp->content_type('text/html; charset=utf-8');
        $self->template->process($template, $vars || {}, 
                                 sub { $resp->body(shift) })
            || die "Template error: " . $self->template->error();
    };
    if ($@) {
        $resp->content_type('text/plain; charset=utf-8');
        $resp->body($@);
    }
    return $resp->finalize;
}

sub render_json {
    my $self = shift;
    my $hash = shift;
    
    my $resp = Plack::Response->new(200);
    $resp->content_type('application/json; charset=utf-8');
    $resp->body( to_json($hash) );
    return $resp->finalize;
}

sub render_text {
    my $self = shift;
    my $body = shift;
    
    my $resp = Plack::Response->new(200);
    $resp->content_type('text/plain');
    $resp->body( $body );
    return $resp->finalize;
}

sub unknown_format {
    my $self = shift;
    my $format = shift;

    my $resp = Plack::Response->new(415);
    $resp->content_type('text/plain');
    $resp->body( "Sorry, '$format' is not a supported format." );
    return $resp->finalize;
}

sub _build_template {
    my $self = shift;
    return Template->new({
        INCLUDE_PATH => "$ENV{PWD}/templates",
    });
}

sub _build_model { ParlAPI::Model->new }

1;
