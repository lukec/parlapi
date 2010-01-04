package ParlAPI::Model::MemberVote;
use Moose;
use namespace::clean -except => 'meta';

has 'member_id'    => (is => 'ro', isa => 'Int', required => 1);
has 'bill_vote_id' => (is => 'ro', isa => 'Int', required => 1);
has 'vote'         => (is => 'ro', isa => 'Int', required => 1);

has 'bill'      => (is => 'ro', isa => 'ParlAPI::Bill',     lazy_build => 1);
has 'bill_vote' => (is => 'ro', isa => 'ParlAPI::BillVote', lazy_build => 1);
has 'member'    => (is => 'ro', isa => 'ParlAPI::Member',   lazy_build => 1);

sub insert {
    my $self = shift;
    my $db = shift;

    my @fields = qw/bill_vote_id member_id vote/;
    my $sql = q{INSERT INTO member_vote (}.join(', ', @fields)
            . q{) VALUES (?,?,?)};
    my @bind = map { $self->$_} @fields;
    $db->sql_execute($sql, @bind);
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

