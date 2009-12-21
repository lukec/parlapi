use Plack::Test;
use Test::More;
use HTTP::Request;
use Plack::Util;

my $app = Plack::Util::load_psgi('app.psgi');

test_psgi $app, sub {
    my $cb = shift;

    my $req = HTTP::Request->new(GET => 'http://localhost/');
    my $res = $cb->($req);

    is $res->code, 200;
    like $res->content, qr/ParlAPI/;
};

done_testing;
