package ParlAPI::Model::Parliament;
use Moose;
use feature 'switch';
use namespace::clean -except => 'meta';

with 'ParlAPI::Model::Collection';

has 'parl_id'    => (is => 'ro', isa => 'Str',     required   => 1);
has 'parliament' => (is => 'ro', isa => 'Int',     required   => 1);
has 'session'    => (is => 'ro', isa => 'Int',     required   => 1);
has 'start_date' => (is => 'ro', isa => 'Str',     required   => 1);
has 'end_date'   => (is => 'ro', isa => 'Maybe[Str]');
has 'name'       => (is => 'ro', isa => 'Str',     lazy_build => 1);
has 'short_name' => (is => 'ro', isa => 'Str',     lazy_build => 1);
has 'url'        => (is => 'ro', isa => 'Str',     lazy_build => 1);
has 'hash_repr'  => (is => 'ro', isa => 'HashRef', lazy_build => 1);

sub table { 'parliament' }

sub BUILDARGS {
    my $class = shift;
    my $args  = shift;
    $args->{parliament} ||= delete $args->{parl};
    return $args;
}

sub _build_name {
    my $self = shift;
    return _add_postfix($self->parliament) . " Parliament, "
         . _add_postfix($self->session) . " Session";
}

sub _build_short_name {
    my $self = shift;
    return join '-', $self->parliament, $self->session;
}

sub _build_url {
    my $self = shift;
    return '/parliaments/' . $self->short_name;
}

sub _build_hash_repr {
    my $self = shift;
    return {
        map { $_ => $self->$_ }
        qw/id name parliament session start_date end_date/
    };
}

sub _add_postfix {
    my $num = shift;
    given ($num) {
        when (/1$/) {return "${num}st"}
        when (/2$/) {return "${num}nd"}
        when (/3$/) {return "${num}rd"}
        default     {return "${num}th"}
    };
}

__PACKAGE__->meta->make_immutable;
1;

