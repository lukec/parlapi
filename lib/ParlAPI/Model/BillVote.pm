package ParlAPI::Model::BillVote;
use Moose;
use namespace::clean -except => 'meta';

with 'ParlAPI::Model::Collection';

has 'bill' => (
    is         => 'ro',
    isa        => 'ParlAPI::Model::Bill',
    lazy_build => 1,
    weak_ref   => 1,
);

has 'id'        => (is => 'ro', isa => 'Str',  lazy_build => 1);
has 'bill_id'   => (is => 'ro', isa => 'Str',  required   => 1);
has 'nays'      => (is => 'ro', isa => 'Int',  required   => 1);
has 'yays'      => (is => 'ro', isa => 'Int',  required   => 1);
has 'paired'    => (is => 'ro', isa => 'Int',  required   => 1);
has 'decision'  => (is => 'ro', isa => 'Str',  required   => 1);
has 'date'      => (is => 'ro', isa => 'Str',  required   => 1);
has 'number'    => (is => 'ro', isa => 'Int',  required   => 1);
has 'sitting'   => (is => 'ro', isa => 'Int',  required   => 1);
has 'agreed_to' => (is => 'ro', isa => 'Bool', lazy_build => 1);
has 'bill_vote_id'   => (is => 'ro', isa => 'Str');


sub _build_id {
    my $self = shift;
    return join '-', $self->bill->id, $self->number, $self->sitting;
}

sub _build_agreed_to {
    my $self = shift;
    return $self->decision eq 'Agreed to';
}

sub insert {
    my $self = shift;
    my $db = shift;

    my @fields = qw/bill_id nays yays paired decision date number sitting/;
    my $sql = q{INSERT INTO bill_vote (}.join(', ', @fields)
            . q{) VALUES (?,?,?,?,?,?,?,?)};
    my @bind = map { $self->$_} @fields;
    $db->sql_execute($sql, @bind);
    my $bill_vote_id = $db->sql_singlevalue(q{
        SELECT bill_vote_id FROM bill_vote WHERE bill_id = ? AND sitting = ?},
        $self->bill_id, $self->sitting);
    $self->{bill_vote_id} = $bill_vote_id;
}

__PACKAGE__->meta->make_immutable;
1;
