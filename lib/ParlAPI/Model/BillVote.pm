package ParlAPI::Model::BillVote;
use Moose;
use namespace::clean -except => 'meta';

has 'bill' => (
    is         => 'ro',
    isa        => 'ParlAPI::Model::Bill',
    lazy_build => 1,
    weak_ref   => 1,
);

has 'id'        => (is => 'ro', isa => 'Str',  lazy_build => 1);
has 'nays'      => (is => 'ro', isa => 'Int',  required   => 1);
has 'yeas'      => (is => 'ro', isa => 'Int',  required   => 1);
has 'paired'    => (is => 'ro', isa => 'Int',  required   => 1);
has 'decision'  => (is => 'ro', isa => 'Str',  required   => 1);
has 'date'      => (is => 'ro', isa => 'Str',  required   => 1);
has 'number'    => (is => 'ro', isa => 'Int',  required   => 1);
has 'sitting'   => (is => 'ro', isa => 'Int',  required   => 1);
has 'agreed_to' => (is => 'ro', isa => 'Bool', lazy_build => 1);


sub _build_id {
    my $self = shift;
    return join '-', $self->bill->id, $self->number, $self->sitting;
}

sub _build_agreed_to {
    my $self = shift;
    return $self->decision eq 'Agreed to';
}

sub CreateVotes {
    my $class = shift;
    my $bill  = shift;
    my $votes = shift;

    my @votes;
    for my $voteref (@$votes) {
        delete $voteref->{RelatedBill};
        for my $key (keys %$voteref) {
            if ($key =~ m/^Total(\w+)/) {
                $voteref->{lc $1} = delete $voteref->{$key};
            }
            else {
                $voteref->{lc $key} = delete $voteref->{$key};
            }
        }

        push @votes, $class->new(%$voteref, bill => $bill);
    }
    return \@votes;
}

__PACKAGE__->meta->make_immutable;
1;

__DATA__

{
'RelatedBill' => {
                 'number' => 'C-2'
               },
'sitting' => '9'
}

