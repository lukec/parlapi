package ParlAPI::Model::Member;
use Moose;
use namespace::clean -except => 'meta';

has 'member_id'    => (is => 'ro', isa => 'Str', required => 1);
has 'name'         => (is => 'ro', isa => 'Str', required => 1);
has 'url'          => (is => 'ro', isa => 'Str', required => 1);
has 'caucus'       => (is => 'rw', isa => 'Str', required => 1);
has 'constituency' => (is => 'rw', isa => 'Str', required => 1);
has 'email'        => (is => 'rw', isa => 'Str');
has 'website'      => (is => 'rw', isa => 'Str');
has 'telephone'    => (is => 'rw', isa => 'Str');
has 'fax'          => (is => 'rw', isa => 'Str');
has 'province'     => (is => 'rw', isa => 'Str');
has 'profile_photo_url' => (is => 'rw', isa  => 'Str');

sub BUILDARGS {
    my $class = shift;
    my $args = shift;

    $args->{name} ||= delete $args->{member_name};
    $args->{url} ||= delete $args->{member_url};
    $args->{website} ||= delete($args->{'web site'}) || '';
    return $args;
}

sub to_hash {
    my $self = shift;
    return { map { $_ => $self->$_ } 
        qw/member_id name url caucus constituency email website telephone
           fax province profile_photo_url/ }
}

sub insert_sql {
    my $self = shift;

    my @fields = qw/ member_id name url caucus constituency
            email website telephone fax province profile_photo_url/;

    return q{INSERT INTO member (}.join(', ', @fields)
         . q{) VALUES (?,?,?,?,?,?,?,?,?,?,?)},
           map { $self->$_} @fields;
}

__PACKAGE__->meta->make_immutable;
1;
