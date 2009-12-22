package ParlAPI;
use Moose;
with 'ParlAPI::Controller';

sub index {
    my $self   = shift;

    return $self->render('index.tt2');
}

__PACKAGE__->meta->make_immutable(inline_constructor => 0);
1;
