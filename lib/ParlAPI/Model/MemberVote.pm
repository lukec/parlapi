package ParlAPI::MemberVote;
use Moose;
use namespace::clean -except => 'meta';

has 'member' => (
    is => 'ro',
    isa => 'ParlAPI::Member',
    required => 1,
    weak_ref => 1,
);

has 'bill' => (
    is => 'ro',
    isa => 'ParlAPI::Bill',
    required => 1,
    weak_ref => 1,
);

has 'bill_vote' => (
    is => 'ro',
    isa => 'ParlAPI::BillVote',
    required => 1,
    weak_ref => 1,
);


sub Create {
    my $class   = shift;
    my %opts    = @_;
    my $bill    = $opts{bill} or die "No bill supplied!";
    my $voteref = delete $opts{vote} or die "No vote supplied!";

    $opts{bill_vote} = $bill->find_vote($voteref->{date});
    return $class->new(%opts);
}

__PACKAGE__->meta->make_immutable;
1;

__DATA__

  'TotalNays' => '36',
  'number' => '5',
  'parliament' => '40',
  'TotalYeas' => '258',
  'Decision' => 'Agreed to',
  'date' => '2009-02-05',
  'TotalPaired' => '2',
  'session' => '2',
  'RelatedBill' => {
                   'number' => 'C-2'
                 },
  'RecordedVote' => {
                    'Paired' => '0',
                    'Nay' => '0',
                    'Yea' => '1'
                  },
  'sitting' => '9'

