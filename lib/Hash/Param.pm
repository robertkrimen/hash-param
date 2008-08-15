package Hash::Param;

use warnings;
use strict;

=head1 NAME

Hash::Param - CGI/Catalyst::Request-like parameter-hash accessor/mutator

=head1 VERSION

Version 0.01

=head1 SYNPOSIS

=head1 DESCRIPTION

=cut

our $VERSION = '0.01';

use Moose;
use Carp::Clan;

use Hash::Slice;

has parameters => qw/accessor _parameters isa HashRef lazy_build 1/;
sub _build_parameters {
    return {};
}

has _is_rw => qw/is rw default 1/;

sub BUILD {
    my $self = shift;
    my $given = shift;

    if (my $is = $given->{is}) {
        if ($is =~ m/^(?:rw|readwrite|writable)$/i) {
            $self->_is_rw(1);
        }
        elsif ($is =~ m/^(?:ro|readonly)$/i) {
            $self->_is_rw(0);
        }
        else {
            croak "Don't understand this read/write designation: \"$is\"";
        }
    }

    for (qw/params hash data from/) {
        last if $self->{_parameters} ||= $given->{$_};
    }
}

sub parameters {
    my $self = shift;
    return $self->params(@_);
}

sub params {
    my $self = shift;
    if (@_) {
        if (1 == @_ && ref $_[0] eq "HASH") {
            croak "Unable to modify readonly parameters" unless $self->_is_rw;
            $self->_parameters($_[0]);
        }
        else {
            my @params = map { $self->_parameters->{$_} } @_;
            @params = map { ref $_ eq "ARRAY" ? [ @$_ ] : $_ } @params unless $self->_is_rw;
            return wantarray ? @params : \@params;
        }
    }
    else {
        return wantarray ? keys %{ $self->_parameters } : $self->_is_rw ? $self->_parameters : { %{ $self->_parameters } };
    }
}

sub slice {
    my $self = shift;
    my $parameters = $self->_parameters;
    return $self->_is_rw ? Hash::Slice::slice $parameters, @_ : Hash::Slice::clone_slice $parameters, @_;
}

sub parameter {
    my $self = shift;
    return $self->param(@_);
}

sub get {
    my $self = shift;
    return $self->params(@_) if @_ > 1;
    return $self->param(@_);
}

sub param {
    my $self = shift;

    if (@_ == 0) {
        return keys %{ $self->_parameters };
    }

    if (@_ == 1) {
        
        my $param = shift;

        if (ref $param eq "ARRAY") {
            return $self->params(@$param);
        }

        unless (exists $self->_parameters->{$param}) {
            return wantarray ? () : undef;
        }

        if (ref $self->_parameters->{$param} eq 'ARRAY') {
            return (wantarray)
              ? @{ $self->_parameters->{$param} }
              : $self->_parameters->{$param}->[0];
        }
        else {
            return (wantarray)
              ? ($self->_parameters->{$param})
              : $self->_parameters->{$param};
        }
    }
    elsif (@_ > 1) {
        my $field = shift;
        croak "Unable to modify readonly parameter \"@{[ $field || '' ]}\"" unless $self->_is_rw;
        $self->_parameters->{$field} = @_ > 1 ? [ @_ ] : $_[0];
    }
}

=head1 SYNOPSIS

=head1 AUTHOR

Robert Krimen, C<< <rkrimen at cpan.org> >>

=head1 SOURCE

You can contribute or fork this project via GitHub:

L<http://github.com/robertkrimen/hash-param/tree/master>

    git clone git://github.com/robertkrimen/hash-param.git Hash-Param

=head1 BUGS

Please report any bugs or feature requests to C<bug-hash-param at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Hash-Param>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Hash::Param


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Hash-Param>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Hash-Param>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Hash-Param>

=item * Search CPAN

L<http://search.cpan.org/dist/Hash-Param>

=back


=head1 ACKNOWLEDGEMENTS


=head1 COPYRIGHT & LICENSE

Copyright 2008 Robert Krimen, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.


=cut

1; # End of Hash::Param
