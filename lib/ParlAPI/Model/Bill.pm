package ParlAPI::Model::Bill;
use Moose;
use namespace::clean -except => 'meta';

has 'id'            => (is => 'ro', isa => 'Int');
has 'name'          => (is => 'ro', isa => 'Str', required   => 1);
has 'parl_id'       => (is => 'ro', isa => 'Int', required   => 1);
has 'sponsor_id'    => (is => 'ro', isa => 'Int');
has 'summary'       => (is => 'ro', isa => 'Str', required   => 1);
has 'sponsor'       => (is => 'ro', isa => 'ParlAPI::Model::Member', lazy_build => 1);
has 'sponsor_title' => (is => 'ro', isa => 'Str', required   => 1);
has 'links' =>
    (is => 'rw', isa => 'ArrayRef[HashRef]', default => sub { [] });

sub _build_sponsor {
    my $self = shift;
    return $self->get_member($self->sponsor_id);
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

__PACKAGE__->meta->make_immutable;
1;
