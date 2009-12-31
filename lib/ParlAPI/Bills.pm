package ParlAPI::Bills;
use Moose;
use namespace::clean -except => 'meta';

with 'ParlAPI::Controller';

sub pretty_list {
    my $self   = shift;
    my $req    = shift;
    my $params = shift;

    my $bills = $self->model->bills;

    return $self->render('bills.html', 
        { 
            bills => $bills,
            json_url => '/bills.json',
            text_url => '/bills.txt',
        },
    );
}


__PACKAGE__->meta->make_immutable;
1;
