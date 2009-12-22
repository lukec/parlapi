package ParlAPI::Model::Bill;
use Moose;
use namespace::clean -except => 'meta';

has 'name'          => (is => 'ro', isa => 'Str', required   => 1);
has 'id'            => (is => 'ro', isa => 'Str', lazy_build => 1);
has 'summary'       => (is => 'ro', isa => 'Str', required   => 1);
has 'sponsor'       => (is => 'ro', isa => 'ParlAPI::Model::Member');
has 'sponsor_title' => (is => 'ro', isa => 'Str', required   => 1);
has 'links' =>
    (is => 'rw', isa => 'ArrayRef[HashRef]', default => sub { [] });

__PACKAGE__->meta->make_immutable;
1;
