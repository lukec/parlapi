package ParlAPI::DB;
use MooseX::Singleton;
use DBI;
use namespace::clean -except => 'meta';

has 'dbh' => (is => 'ro', lazy_build => 1);

sub sql_execute {
    my $self = shift;
    my $statement = shift;
    my @bind = @_;

    my $sth = $self->dbh->prepare($statement);
    $sth->execute(@bind)
        || die "SQL execute failed: " . $sth->errstr;
    return $sth;
}

sub sql_singlevalue {
    my $self = shift;
    my $sth = $self->sql_execute(@_);
    my $all = $sth->fetchall_arrayref();
    return $all->[0][0];
}

sub _build_dbh {
    my $self = shift;

    my $db = 'parlapi';
    my $db_user = 'parlapi';
    if ($> >= 1000) {
        $db = "$ENV{USER}_$db";
        $db_user = $ENV{USER};
    }

    my $dsn = "dbi:Pg:database=$db";
    my $dbh = DBI->connect($dsn, $db_user, '', { AutoCommit => 1, });
    die "Could not create DBH with $dsn: $!" unless $dbh;
    return $dbh;
}

__PACKAGE__->meta->make_immutable;
1;
