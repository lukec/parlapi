package ParlAPI::Votes;
use Moose;
use namespace::clean -except => 'meta';

with 'ParlAPI::Controller';

sub pretty_list {
    my $self   = shift;
    my $req    = shift;
    my $params = shift;

    my $parl = $self->model->get_parliament(%$params);
    return $self->render('unknown_parliament.html', $params) unless $parl;

    my $votes = $self->model->votes($parl);
    if (my $format = $params->{format} || '') {
#        if ($format eq 'json') {
#            return $self->render_json( [ map { $_->to_hash } @$bills ] );
#        }
#        elsif ($format =~ m/^te?xt$/) {
#            return $self->render_text(join "\n", map { $_->name } @$bills);
#        }
#        else {
            return $self->unknown_format($format);
#        }
    }

    return $self->render('votes.html', 
        { 
            parliament => $parl,
            votes => $votes,
        },
    );
}

sub show_vote {
    my $self   = shift;
    my $req    = shift;
    my $params = shift;

    my $parl = $self->model->get_parliament(%$params);
    return $self->render('unknown_parliament.html', $params) unless $parl;

    my $bill_vote_id = $params->{bill_vote_id};
    my $bv = $self->model->get_billvote($bill_vote_id);
    unless ($bill_vote_id and $bv) {
        return $self->render('unknown_vote.html', { 
                bill_vote_id => $bill_vote_id,
                parliament => $parl,
            });
    }

    if (my $format = $params->{format} || '') {
#         if ($format eq 'json') {
#             return $self->render_json( $bill->to_hash );
#         }
#         elsif ($format =~ m/^te?xt$/) {
#             my $hash = $bill->to_hash;
#             my $links = delete $hash->{links};
#             my $parl  = delete $hash->{parliament};
#             my $text = join "\n", map { "$_: $hash->{$_}" } keys %$hash;
#             $text .= "\n";
#             $text .= "Link: $_->{href} ($_->{name})\n" for @$links;
#             $text .= join "\n", map { "Parliament: $_: $parl->{$_}" } keys %$parl;
#             return $self->render_text($text);
#         }
#         else {
            return $self->unknown_format($format);
#         }
    }

    return $self->render('vote.html', 
        { 
            parliament => $parl,
            vote => $bv,
            bill => $bv->bill,
        },
    );
}

sub show_voters {
    my $self   = shift;
    my $req    = shift;
    my $params = shift;

    my $parl = $self->model->get_parliament(%$params);
    return $self->render('unknown_parliament.html', $params) unless $parl;

    my $bill_vote_id = $params->{bill_vote_id};
    my $bv = $self->model->get_billvote($bill_vote_id);
    unless ($bill_vote_id and $bv) {
        return $self->render('unknown_vote.html', { 
                bill_vote_id => $bill_vote_id,
                parliament => $parl,
            });
    }

    my %name_to_num = ( nays => 0, yeas => 1, yays => 1, paired => 2 );
    my $vote = $params->{vote};
    my $vote_num = $name_to_num{ $vote };
    die "Not a valid vote: $vote" unless defined $vote_num;

    my $members = $self->model->get_members_by_vote($bill_vote_id, $vote_num);

    return $self->render('voters.html', 
        { 
            parliament => $parl,
            vote => $vote,
            bill => $bv->bill,
            bill_vote => $bv,
            members => $members,
        },
    );
}

__PACKAGE__->meta->make_immutable;
1;
