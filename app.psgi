use CGI::PSGI;
use CGI::Application::PSGI;
use ParlAPI;

warn "$ENV{PWD}/templates/home.tt2";
my $handler = sub {
    my $env = shift;
    my $app = ParlAPI->new({
        QUERY => CGI::PSGI->new($env),
        PARAMS => {
            debug => 0,
            parl_base => $ENV{PWD},
        },
    });
    CGI::Application::PSGI->run($app);
};
