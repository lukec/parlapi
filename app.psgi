#!perl
use Plack::Builder;
use Plack::App::HTTP::Router;
use HTTP::Router::Declare;

my $router = router {
    match '/' => to { controller => 'ParlAPI', action => 'index' };

    # Parliaments
    match '/parliaments/{parliament}-{session}' =>
        to { controller => 'ParlAPI::Parliaments', action => 'show' };

    # Members
    match '/parliaments/{parliament}-{session}/members.{format}' =>
        to { controller => 'ParlAPI::Members', action => 'pretty_list' };
    match '/parliaments/{parliament}-{session}/members' =>
        to { controller => 'ParlAPI::Members', action => 'pretty_list' };
    match '/parliaments/{parliament}-{session}/members/{member}.{format}' =>
        to { controller => 'ParlAPI::Members', action => 'show_member' };
    match '/parliaments/{parliament}-{session}/members/{member}' =>
        to { controller => 'ParlAPI::Members', action => 'show_member' };
    match '/members/{member}.{format}' =>
        to { controller => 'ParlAPI::Members', action => 'show_member' };
    match '/members/{member}' =>
        to { controller => 'ParlAPI::Members', action => 'show_member' };

    # Bills
    match '/parliaments/{parliament}-{session}/bills.{format}' =>
        to { controller => 'ParlAPI::Bills', action => 'pretty_list' };
    match '/parliaments/{parliament}-{session}/bills' =>
        to { controller => 'ParlAPI::Bills', action => 'pretty_list' };
    match '/parliaments/{parliament}-{session}/bills/{billname}.{format}' =>
        to { controller => 'ParlAPI::Bills', action => 'show_bill' };
    match '/parliaments/{parliament}-{session}/bills/{billname}' =>
        to { controller => 'ParlAPI::Bills', action => 'show_bill' };

    # Votes
    match '/parliaments/{parliament}-{session}/votes.{format}' =>
        to { controller => 'ParlAPI::Votes', action => 'pretty_list' };
    match '/parliaments/{parliament}-{session}/votes' =>
        to { controller => 'ParlAPI::Votes', action => 'pretty_list' };
    match '/parliaments/{parliament}-{session}/votes/{bill_vote_id}.{format}' =>
        to { controller => 'ParlAPI::Votes', action => 'show_vote' };
    match '/parliaments/{parliament}-{session}/votes/{bill_vote_id}' =>
        to { controller => 'ParlAPI::Votes', action => 'show_vote' };
    match '/parliaments/{parliament}-{session}/votes/{bill_vote_id}/{vote}.{format}' =>
        to { controller => 'ParlAPI::Votes', action => 'show_voters' };
    match '/parliaments/{parliament}-{session}/votes/{bill_vote_id}/{vote}' =>
        to { controller => 'ParlAPI::Votes', action => 'show_voters' };

    # Self update
    match '/self-update' =>
        to { controller => 'ParlAPI::Updater', action => 'update' };
};
my $app = Plack::App::HTTP::Router->new({ router => $router} )->to_app;

builder {
    enable "Plack::Middleware::StackTrace";
#    enable "Debug";
    $app;
};

