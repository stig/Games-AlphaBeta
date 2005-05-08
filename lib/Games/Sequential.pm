package Games::Sequential;
use Carp;
use 5.006001;
use strict;
use warnings;

our $VERSION = '0.2.2';

=head1 NAME

Games::Sequential - framework for sequential games with object oriented interface

=head1 SYNOPSIS

  use Games::Sequential;
  my $game = Games::Sequential->new($initialpos, move => \&move );

  $game->debug(1);

  $game->move($move);
  $game->undo;


=head1 DESCRIPTION

Games::Sequential provides a simple base class for sequential
games. The module provides an undo mechanism, as it keeps track
of the history of moves, in addition to methods to clone a game
state with or without history.

Users will have to provide this module with a reference to a
callback function to perform a move in the game they are
implementing. This callback is:

=over 4

=item C<move> $position, $move

Create $newpos as copy of $position and apply $move to it.
Return $newpos.

=back


=head1 METHODS

Users must not modify the referred-to values of references
returned by any of the below methods, except, of course,
indirectly using the supplied callbacks mentioned above.

=over 4

=item new [@list]

Create and return a new AlphaBeta object.

The function C<move> can be given as an argument to this
function. If so, there is no need to call the C<setfuncs()>
method. Similarly, if a valid starting position is given (as
C<initialpos>) there is no need to call init() on the returned
object. The C<debug> option can also be set here. 

=cut 

sub new {
    my $invocant = shift;
    my $class = ref($invocant) || $invocant;
    my $self = bless {}, $class;

    $self->_init(@_) or carp "Failed to init object!";
    return $self;
}


=item _init [@list]

I<Internal method>

Initialize a AlphaBeta object.

=cut

sub _init {
    my $self = shift;
    my $pos = shift or croak "No initial position given!";
    my $args = @_ && ref($_[0]) ? shift : { @_ };

    my %config = (
        # Stacks for backtracking
        pos_hist    => [ $pos ],
        move_hist   => [],

        # Callbacks
        move        => undef,

        # Debug and statistics
        debug       => 0,
    );

    # Set defaults
    @$self{keys %config} = values %config;

    # Override defaults
    while (my ($key, $val) = each %{ $args }) {
        $self->{$key} = $val if exists $self->{$key};
    }

    return $self;
}


=item setfuncs @list

Set (or change) callback functions. This method is required
unless ->new() is invoked with MOVE as an argument.

=cut

sub setfuncs {
    my $self = shift;
    croak "Setfuncs called with no arguments!" unless @_;
    my $args = @_ && ref($_[0]) ? shift : { @_ };

    while (my ($key, $val) = each %{ $self }) {
        $self->{$key} = $args->{$key} if ref($args->{$key}) eq 'CODE';
    }
    return $self;
}


=item debug [$value]

Return current debug level and, if invoked with an argument, set
to new value.

=cut

sub debug {
    my $self = shift;
    my $prev = $self->{debug};
    $self->{debug} = shift if @_;
    return $prev;
}


=item peek_pos

Return reference to current position.
Use this for drawing the board etc.

=cut

sub peek_pos {
    my $self = shift;
    return $self->{pos_hist}[-1];
}


=item peek_move

Return reference to last applied move.

=cut

sub peek_move {
    my $self = shift;
    return $self->{move_hist}[-1];
}


=item move $move

Apply $move to the current position, keeping track of history.
A reference to the new position is returned, or undef on failure.

=cut

sub move {
    my ($self, $move) = @_;
    my $pos = $self->peek_pos;

    my $npos = $self->{move}($pos, $move);
    return unless $npos;

    push @{ $self->{pos_hist} }, $npos;
    push @{ $self->{move_hist} }, $move;

    return $self->peek_pos;
}


=item undo

Undo last move. A reference to the previous position is returned,
or undef if there was no more moves to undo.

=cut

sub undo {
    my $self = shift;
    return unless pop @{ $self->{move_hist} };
    pop @{ $self->{pos_hist} } or carp "Can't pop empty stack";
    return $self->peek_pos;
}


1;  # ensure using this module works
__END__

=back

=head1 TODO

Implement missing methods, e.g.: clone(), snapshot(), save()
E<amp> resume().


=head1 SEE ALSO

The author's website, describing this module and other projects:
http://brautaset.org/projects/

=head1 AUTHOR

Stig Brautaset, E<lt>stig@brautaset.orgE<gt>

=head1 COPYRIGHT AND LICENCE

Copyright (C) 2004 by Stig Brautaset

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.3 or,
at your option, any later version of Perl 5 you may have available.

=cut

# vim: shiftwidth=4 tabstop=4 softtabstop=4 expandtab 
