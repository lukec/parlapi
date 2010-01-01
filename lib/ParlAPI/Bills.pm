package ParlAPI::Bills;
use Moose;
use namespace::clean -except => 'meta';

with 'ParlAPI::Controller';

sub pretty_list {
    my $self   = shift;
    my $req    = shift;
    my $params = shift;

    my $parl = $self->model->get_parliament(%$params);
    return $self->render('unknown_parliament.html', $params) unless $parl;

    my $bills = $self->model->bills($parl);

    return $self->render('bills.html', 
        { 
            parliament => $parl,
            bills => $bills,
        },
    );
}


__PACKAGE__->meta->make_immutable;
1;
