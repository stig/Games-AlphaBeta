package Games::AlphaBeta::Position;
use base Games::Sequential::Position;

use strict;
use warnings;

use Carp;

our $VERSION = '0.1.0';

=head1 NAME

Games::AlphaBeta::Position - base Position class for use with Games::AlphaBeta 

=head1 SYNOPSIS

    package My::GamePos;
    use base Games::AlphaBeta::Position;

    sub apply { ... }
    sub endpos { ... }
    sub evaluate { ... }
    sub findmoves { ... }

    package main;
    my $pos = My::GamePos->new;
    my $game = Games::AlphaBeta->new($pos);


=head1 DESCRIPTION

Games::AlphaBeta::Position is a base class for position-classes
that can be used with L<Games::AlphaBeta>. It inherits most of
its methods from L<Games::Sequential::Position>; make sure you
read its documentation.

This class is provided for convenience. You don't need this class
in order to use L<Games::AlphaBeta>. It is, however, also
possible to make use of this class on its own.

=head1 MISSING METHODS

Modules inheriting this class must implement at least these three
methods (in addition to C<apply()> which is required by
L<Games::Sequential::Position>): C<endpos()>, C<evaluate()> &amp;
C<findmoves()>. If you chose to not use this class, you must also
implement a C<copy()> method which makes a deep copy of a
position object.

Here's a quick description of how the missing methods must work:

=over 4

=item findmoves()
    
Return an array of all moves possible for the current player at
the current position. Don't forget to include null moves if the
player is allowed to pass.

=item endpos()

True if the position is an ending position, i.e. either a draw or
a win for one of the players.

=item evaluate()

Return the "fitness" value for the current player at the current
position.

=back


=head1 METHODS

The following methods are provided by this class.

=over 4

=item _init [@list]

I<Internal method.>

Make sure the missing methods are implemented. You probably want
to override this though. You might want to call
C<$self->SUPER::_init(@_)> from within the overriding method.

=cut

sub _init {
    my $self = shift;
    $self->SUPER::_init(@_);

    for (qw(endpos evaluate findmoves)) {
        unless ($self->can($_)) {
            croak <<'EOF';
method $_() not implemented. 
Hint: read the Games::AlphaBeta::Position manpage.
EOF
        }
    }

    return $self;
}


1;  # ensure using this module works
__END__

=back


=head1 SEE ALSO

The author's website, describing this and other projects:
L<http://brautaset.org/projects/>


=head1 AUTHOR

Stig Brautaset, E<lt>stig@brautaset.orgE<gt>


=head1 COPYRIGHT AND LICENCE

Copyright (C) 2004 by Stig Brautaset

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.3 or,
at your option, any later version of Perl 5 you may have available.

=cut

# vim: shiftwidth=4 tabstop=4 softtabstop=4 expandtab 
