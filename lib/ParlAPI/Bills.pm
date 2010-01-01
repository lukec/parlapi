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
    if (my $format = $params->{format} || '') {
        if ($format eq 'json') {
            return $self->render_json( [ map { $_->to_hash } @$bills ] );
        }
        elsif ($format =~ m/^te?xt$/) {
            return $self->render_text(join "\n", map { $_->name } @$bills);
        }
        else {
            return $self->unknown_format($format);
        }
    }

    return $self->render('bills.html', 
        { 
            parliament => $parl,
            bills => $bills,
        },
    );
}

sub show_bill {
    my $self   = shift;
    my $req    = shift;
    my $params = shift;

    my $parl = $self->model->get_parliament(%$params);
    return $self->render('unknown_parliament.html', $params) unless $parl;

    my $bill_name = $params->{billname};
    unless ($bill_name) {
        return $self->render('unknown_bill.html', { 
                bill_name => $bill_name,
                parliament => $parl,
            });
    }
    my $bill = $self->model->get_bill($parl, $bill_name);

    return $self->render('bill.html', 
        { 
            parliament => $parl,
            bill => $bill,
        },
    );
}


__PACKAGE__->meta->make_immutable;
1;
