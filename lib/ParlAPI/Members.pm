package ParlAPI::Members;
use Moose;
use namespace::clean -except => 'meta';

with 'ParlAPI::Controller';

sub pretty_list {
    my $self   = shift;
    my $req    = shift;
    my $params = shift;

    my $members = $self->model->members;

    if (my $format = $params->{format} || '') {
        if ($format eq 'json') {
            return $self->render_json( [ map { $_->to_hash } @$members ] );
        }
        elsif ($format =~ m/^te?xt$/) {
            return $self->render_text(join "\n", map { $_->name } @$members);
        }
    }
    return $self->render('members.html', { members => $members });
}

__PACKAGE__->meta->make_immutable;
1;
