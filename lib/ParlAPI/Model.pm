package ParlAPI::Model;
use MooseX::Singleton;
use ParlAPI::DB;
use ParlAPI::Model::Parliament;
use ParlAPI::Model::Member;
use ParlAPI::Model::Bill;
use namespace::clean -except => 'meta';

has 'db' => (is => 'ro', isa => 'ParlAPI::DB', lazy_build => 1);

sub get_parliament {
    my $self = shift;
    my %p = @_;

    my $sth = $self->db->sql_execute(q{
            SELECT parl_id as id, 
                   parl as parliament, 
                   "session", start_date, end_date
              FROM parliament 
             WHERE parl = ? AND session = ?
        }, $p{parliament}, $p{session},
    );
    my $result = $sth->fetchall_arrayref({});
    return undef unless $result->[0];
    return ParlAPI::Model::Parliament->new($result->[0]);
}

sub get_member {
    my $self = shift;
    my $maybe_id   = shift;
    
    my $where;
    if ($maybe_id =~ m/\D/) {
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

sub delete_member {
    my $self = shift;
    my $member_id = shift;
    $self->db->sql_execute(
        q{DELETE FROM member WHERE member_id = ?},
        $member_id,
    );
}

sub delete_bill {
    my $self = shift;
    my $bill_name = shift;
    warn "Deleting $bill_name";
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
    warn "creating $bill_hash->{name}";
    my $b = ParlAPI::Model::Bill->new($bill_hash);
    $b->insert($self->db);
    return $b;
}

sub members {
    my $self = shift;
    my $sth = $self->db->sql_execute(q{SELECT * from member});
    my $results = $sth->fetchall_arrayref({});
    my @members;
    for my $m (@$results) {
        push @members, ParlAPI::Model::Member->new($m);
    }
    return \@members;
}

sub _build_db { ParlAPI::DB->new }

__PACKAGE__->meta->make_immutable;
1;
