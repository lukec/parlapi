package ParlAPI::Controller;
use Moose::Role;
use Template;
use Plack::Response;
use namespace::clean -except => 'meta';

has 'template' => (is => 'ro', lazy_build => 1);

sub render {
    my ($self, $template, $vars) = @_;

    my $resp = Plack::Response->new(200);
    eval {
        $resp->content_type('text/html');
        $self->template->process($template, $vars || {}, 
                                 sub { $resp->body(shift) })
            || die "Template error: " . $self->template->error();
    };
    if ($@) {
        $resp->content_type('text/plain');
        $resp->body($@);
    }
    return $resp->finalize;
}

sub _build_template {
    my $self = shift;
    return Template->new({
            INCLUDE_PATH => "$ENV{PWD}/templates",
        });
}

1;
