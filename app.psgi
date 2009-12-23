#!perl
use Plack::Builder;
use Plack::App::HTTP::Router;
use HTTP::Router::Declare;

my $router = router {
    match '/' => to { controller => 'ParlAPI', action => 'index' };
    match '/parliaments' =>
        to { controller => 'ParlAPI::Parliaments', action => 'pretty_list' };
    match '/members' =>
        to { controller => 'ParlAPI::Members', action => 'pretty_list' };
};
my $app = Plack::App::HTTP::Router->new({ router => $router} )->to_app;

builder {
    enable "Plack::Middleware::StackTrace";
    $app;
};

