package ParlAPI::Updater;
use Moose;
use namespace::clean -except => 'meta';

with 'ParlAPI::Controller';

sub update {
    my $self   = shift;
    my $req    = shift;
    my $params = shift;

    my $updater = "$ENV{PWD}/bin/parlapi-updater";
    if (-x $updater) {
        return $self->render_text(qx{$updater});
    }
    return $self->render_text("Executable updater not found.");
}


__PACKAGE__->meta->make_immutable;
1;
