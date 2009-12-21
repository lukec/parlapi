package ParlAPI;
use strict;
use warnings;
use base 'CGI::Application';
use CGI::Application::Plugin::Routes;
use CGI::Application::Plugin::TT;

sub setup {
    my $self = shift;

    $self->routes(
        [
            '' => 'home',
        ]
    );
    $self->start_mode('home');
    $self->tmpl_path('templates/');
}

sub home {
    my $self   = shift;

    return $self->dump_html() if $self->param('DEBUG');
    return $self->tt_process({});
}

# configure the template object once during the init stage
sub cgiapp_init {
    my $self = shift;

    # Configure the template
    $self->tt_config(
        TEMPLATE_OPTIONS => {
            INCLUDE_PATH => $self->param('parl_base') . '/templates',
            POST_CHOMP   => 1,
        },
    );
}

1;
