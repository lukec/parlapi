package ParlAPI::Model::Collection;
use Moose::Role;
use namespace::clean -except => 'meta';

sub All {
    my $class = shift;
    my $db = shift;
    my %opts = @_;

    my $table = $class->table;
    my $sql = qq{SELECT * from $table};
    if (my $j = $opts{join}) {
        $sql .= " $j";
    }
    if (my $w = $opts{where}) {
        $sql .= " WHERE $w";
    }
    if (my $ob = $opts{order_by}) {
        $sql .= " ORDER BY $ob";
    }
    my $bind = $opts{bind} || [];

    # warn "Executing: $sql (@$bind)";
    my $sth = $db->sql_execute($sql, @$bind);
    my $results = $sth->fetchall_arrayref({});
    my @collection;
    for my $r (@$results) {
        push @collection, $class->new($r);
    }
    return \@collection;
}

1;
