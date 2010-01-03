package ParlAPI::Model::Bill;
use Moose;
use ParlAPI::Model;
use namespace::clean -except => 'meta';

with 'ParlAPI::Model::Collection';

has 'bill_id'       => (is => 'ro', isa => 'Int');
has 'name'          => (is => 'ro', isa => 'Str', required   => 1);
has 'parl_id'       => (is => 'ro', isa => 'Int', required   => 1);
has 'parliament'    => (is => 'ro', isa => 'ParlAPI::Model::Parliament', lazy_build => 1);
has 'sponsor_id'    => (is => 'ro', isa => 'Maybe[Int]');
has 'summary'       => (is => 'ro', isa => 'Str', required   => 1);
has 'sponsor'       => (is => 'ro', isa => 'Maybe[ParlAPI::Model::Member]', lazy_build => 1);
has 'sponsor_title' => (is => 'ro', isa => 'Str', required   => 1);
has 'links' => (is => 'rw', isa => 'ArrayRef[HashRef]', lazy_build => 1);
has 'official_url'  => (is => 'ro', isa => 'Str', lazy_build => 1);

sub table { 'bill' }

around 'All' => sub {
    my $orig = shift;
    return $orig->(@_, order_by => 'bill_id');
};

sub BUILDARGS {
    my $class = shift;
    my $args  = shift;
    delete $args->{parliament}; # always lazy build this object
    return $args;
}

sub to_hash {
    my $self = shift;
    return {
        parliament => $self->parliament->to_hash,
        links => $self->links,
        map { $_ => $self->$_ } qw/name sponsor_id sponsor_title summary official_url/
    };
}

sub _build_sponsor {
    my $self = shift;
    return ParlAPI::Model->get_member($self->sponsor_id);
}

sub insert {
    my $self = shift;
    my $db = shift;

    my @fields = qw/parl_id name summary sponsor_title sponsor_id/;
    my $sql = q{INSERT INTO bill (bill_id, }.join(', ', @fields)
         . q{) VALUES (DEFAULT,?,?,?,?,?)};
    my @bind = map { $self->$_} @fields;
    $db->sql_execute($sql, @bind);

    my $bill_id = $db->sql_singlevalue(q{
        SELECT bill_id FROM bill WHERE name = ?}, $self->name);
    $self->{id} = $bill_id;

    for my $link (@{ $self->links }) {
        $db->sql_execute(q{
            INSERT INTO bill_links (bill_id, link_name, link_href)
             VALUES (?,?,?)
             }, $bill_id, %$link);
    }
}

sub _build_official_url {
    my $self = shift;
    my $parl = $self->parliament;
    (my $name = $self->name) =~ s/-//;

    return q{http://www2.parl.gc.ca/HouseBills/BillsGovernment.aspx?Language=E}
         . q{&Mode=1&Parl=} . $parl->parliament . q{&Ses=} . $parl->session
         . q{#} . $name;
}

sub _build_parliament {
    my $self = shift;
    return ParlAPI::Model->get_parliament(parl_id => $self->parl_id);
}

sub _build_links {
    my $self = shift;
    my $db = ParlAPI::Model->db;

    my $sth = $db->sql_execute(
        q{SELECT link_name AS name, link_href AS href 
            FROM bill_links WHERE bill_id = ?}, $self->bill_id);
    return $sth->fetchall_arrayref({});
}

__PACKAGE__->meta->make_immutable;
1;
