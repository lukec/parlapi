package ParlAPI::Parliaments;
use Moose;
use namespace::clean -except => 'meta';

with 'ParlAPI::Controller';

sub show {
    my $self = shift;
    my $req  = shift;
    my $p    = shift;

    unless ($p->{parliament} and $p->{session}) {
        return $self->render('unknown_parliament.html', $p);
    }

    my $parl = $self->model->get_parliament(%$p);
    return $self->render('parliament.html', { parliament => $parl });
}

__PACKAGE__->meta->make_immutable;
1;
