package ParlAPI::Model::Collection;
use Moose::Role;
use namespace::clean -except => 'meta';

sub All {
    my $class = shift;
    my $db = shift;
    my %opts = @_;

    my $table = $class->table;
    my $sql = qq{SELECT * from $table};
    if (my $ob = $opts{order_by}) {
        $sql .= " ORDER BY $ob";
    }

    my $sth = $db->sql_execute($sql);
    my $results = $sth->fetchall_arrayref({});
    my @collection;
    for my $r (@$results) {
        push @collection, $class->new($r);
    }
    return \@collection;
}

1;
