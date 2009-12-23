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
        else {
            return $self->unknown_format($format);
        }
    }
    return $self->render('members.html', 
        { 
            members => $members,
            json_url => '/members.json',
            text_url => '/members.txt',
        },
    );
}

sub show_member {
    my $self   = shift;
    my $req    = shift;
    my $params = shift;

    my $member_id = $params->{member};
    unless ($member_id) {
        return $self->render('unknown_member.html',
            { member_id => $member_id });
    }
    my $member = $self->model->get_member($member_id);

    if (my $format = $params->{format} || '') {
        if ($format eq 'json') {
            return $self->render_json( $member->to_hash );
        }
        elsif ($format =~ m/^te?xt$/) {
            my $hash = $member->to_hash;
            return $self->render_text(join "\n",
                map { "$_: " . $member->$_ } keys %$hash);
        }
        else {
            return $self->unknown_format($format);
        }
    }

    my $member_id = $member->member_id;
    return $self->render('member.html', 
        { 
            member => $member,
            json_url => "/members/$member_id.json",
            text_url => "/members/$member_id.txt",
        },
    );
}

__PACKAGE__->meta->make_immutable;
1;
