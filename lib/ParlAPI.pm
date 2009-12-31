package ParlAPI;
use Moose;
use namespace::clean -except => 'meta';

with 'ParlAPI::Controller';

sub index {
    my $self   = shift;

    return $self->render('index.html',
        {
            parliaments => $self->model->parliaments(),
        },
    );
}

__PACKAGE__->meta->make_immutable;
1;
