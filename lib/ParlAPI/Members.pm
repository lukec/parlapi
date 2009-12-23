package ParlAPI::Members;
use Moose;
use namespace::clean -except => 'meta';

with 'ParlAPI::Controller';

sub pretty_list {
    my $self = shift;
    my %opts = (
        members => $self->model->members,
    );
    return $self->render('members.html', \%opts);
}

__PACKAGE__->meta->make_immutable;
1;
