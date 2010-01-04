package ParlAPI::Model;
use MooseX::Singleton;
use ParlAPI::DB;
use ParlAPI::Model::Parliament;
use ParlAPI::Model::Member;
use ParlAPI::Model::Bill;
use ParlAPI::Model::BillVote;
use ParlAPI::Model::MemberVote;
use namespace::clean -except => 'meta';

has 'db' => (is => 'ro', isa => 'ParlAPI::DB', lazy_build => 1);

sub get_parliament {
    my $self = shift;
    my %p = @_;

    my ($where, @bind);
    if ($p{parl_id}) {
        $where = 'parl_id = ?';
        push @bind, $p{parl_id};
    }
    elsif ($p{parliament} and $p{session}) {
        $where = 'parl = ? AND session = ?';
        push @bind, $p{parliament}, $p{session};
    }
    else { die "Look ups by parl_id or parliament & session only" }

    my $sth = $self->db->sql_execute(qq{SELECT * FROM parliament WHERE $where}, @bind);
    my $result = $sth->fetchall_arrayref({});
    return undef unless $result->[0];
    return ParlAPI::Model::Parliament->new($result->[0]);
}

sub get_member {
    my $self = shift;
    my $maybe_id   = shift;
    
    my $where;
    if ($maybe_id =~ m/\@/) {
        $where = 'LOWER(email) = LOWER(?)';
    }
    elsif ($maybe_id =~ m/\D/) {
        $where = 'LOWER(name) = LOWER(?)';
    }
    else {
        $where = 'member_id = ?';
    }
    my $sth = $self->db->sql_execute(qq{
            SELECT * 
              FROM member
             WHERE $where
        }, $maybe_id
    );
    my $result = $sth->fetchall_arrayref({});
    return undef unless $result->[0];
    return ParlAPI::Model::Member->new($result->[0]);
}

sub get_members_by_vote {
    my $self = shift;
    my $bill_vote_id = shift;
    my $vote_num = shift;

    return ParlAPI::Model::Member->All(
        $self->db,
        'join' => 'JOIN member_vote USING (member_id)',
        where => 'bill_vote_id = ? AND vote = ?',
        'bind' => [$bill_vote_id, $vote_num],
        order_by => 'name ASC',
    );
}


sub get_bill {
    my $self = shift;
    my $parl = shift;
    my $bill_name = uc shift;

    my ($where, @bind);
    if (defined $parl) {
        $where = q{parl_id = ? and name = ?};
        push @bind, $parl->parl_id, $bill_name;
    }
    else {
        $where = q{bill_id = ?};
        push @bind, $bill_name;
    }
    
    my $sth = $self->db->sql_execute(qq{ SELECT * FROM bill WHERE $where }, @bind);
    my $result = $sth->fetchall_arrayref({});
    return undef unless $result->[0];
    return ParlAPI::Model::Bill->new($result->[0]);
}

sub get_billvote {
    my $self = shift;
    my $maybe_bill_id = shift;
    my $sitting = shift;

    my ($where, @bind);
    if (defined $sitting) {
        $where = q{bill_id = ? and sitting = ?};
        push @bind, $maybe_bill_id, $sitting;
    }
    else {
        $where = q{bill_vote_id = ?};
        push @bind, $maybe_bill_id;
    }
    
    my $sth = $self->db->sql_execute(qq{SELECT * FROM bill_vote WHERE $where}, @bind);
    my $result = $sth->fetchall_arrayref({});
    return undef unless $result->[0];
    return ParlAPI::Model::BillVote->new($result->[0]);
}

sub delete_member {
    my $self = shift;
    my $member_id = shift;
    $self->db->sql_execute(
        q{DELETE FROM member WHERE member_id = ?},
        $member_id,
    );
    $self->db->sql_execute(
        q{DELETE FROM parliament_members WHERE member_id = ?},
        $member_id,
    );
}

sub delete_bill {
    my $self = shift;
    my $bill_name = shift;
    $self->db->sql_execute(
        q{DELETE FROM bill WHERE name = ?},
        $bill_name,
    );
}

sub create_member {
    my $self = shift;
    my $m = ParlAPI::Model::Member->new(@_);
    $self->db->sql_execute( $m->insert_sql );
    return $m;
}

sub create_bill {
    my $self = shift;
    my $bill_hash = shift;
    my $b = ParlAPI::Model::Bill->new($bill_hash);
    $b->insert($self->db);
    return $b;
}

sub create_billvote {
    my $self   = shift;
    my $bill   = shift;
    my $member = shift;
    my $bv     = shift;

    my $b = ParlAPI::Model::BillVote->new({
            bill_id => $bill->bill_id,
            nays => delete $bv->{TotalNays},
            yays => delete $bv->{TotalYeas},
            paired => delete $bv->{TotalPaired},
            decision => delete $bv->{Decision},
            date => delete $bv->{date},
            number => delete $bv->{number},
            sitting => delete $bv->{sitting},
        });
    $b->insert($self->db);
    return $b;
}

sub create_membervote {
    my $self = shift;
    my $args = shift;

    my $vote = delete $args->{vote};
    if ($vote->{Nay}) {
        $args->{vote} = 0;
    }
    elsif ($vote->{Yea}) {
        $args->{vote} = 1;
    }
    else {
        $args->{vote} = 2;
    }

    $self->db->sql_execute(q{DELETE FROM member_vote 
                              WHERE bill_vote_id = ? AND member_id = ?},
                            $args->{bill_vote_id}, $args->{member_id});
    my $mv = ParlAPI::Model::MemberVote->new($args);
    $mv->insert($self->db);
    return $mv;
}

sub parliaments {
    my $self = shift;
    return ParlAPI::Model::Parliament->All($self->db);
}

sub members {
    my $self = shift;
    my $parl = shift or die "A Parliament object is mandatory!";
    return ParlAPI::Model::Member->All(
        $self->db,
        'join' => 'LEFT JOIN parliament_members USING (member_id)',
        where => 'parl_id = ?',
        'bind' => [$parl->parl_id],
        order_by => 'name ASC',
    );
}

sub bills {
    my $self = shift;
    my $parl = shift;
    return ParlAPI::Model::Bill->All(
        $self->db,
        where => 'parl_id = ?',
        'bind' => [$parl->parl_id],
        order_by => 'name ASC',
    );
}

sub votes {
    my $self = shift;
    my $parl = shift;
    return ParlAPI::Model::BillVote->All(
        $self->db,
        'join' => 'JOIN bill USING (bill_id)',
        where => 'parl_id = ?',
        'bind' => [$parl->parl_id],
        order_by => 'date DESC',
    );
}

sub _build_db { ParlAPI::DB->new }

__PACKAGE__->meta->make_immutable;
1;
