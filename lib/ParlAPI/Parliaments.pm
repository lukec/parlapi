package ParlAPI::Parliaments;
use Moose;
use namespace::clean -except => 'meta';

with 'ParlAPI::Controller';

sub pretty_list {
    my $self = shift;
}

__PACKAGE__->meta->make_immutable;
1;
