package Games::AlphaBeta;
use base Games::Sequential;
use Carp;
use 5.006001;

use strict;
use warnings;


our $VERSION = '0.4.0';

=head1 NAME

Games::AlphaBeta - game-tree search with object oriented interface

=head1 SYNOPSIS

  package Some::Game;
  use base Games::Sequential::Position;

  # initialise starting position
  sub _init { ... }

  # Methods required by Games::AlphaBeta
  sub apply { ... }
  sub endpos { ... }
  sub evaluate { ... }
  sub findmoves { ... }

  # Print a position in the game (optional)
  sub draw { ... }

  package main;
  my $pos = Some::Game->new;
  my $game = Games::AlphaBeta->new($pos);

  while ($game->abmove) {
      print draw($game->peek_pos);
  }

=head1 DESCRIPTION

Games::AlphaBeta provides a generic implementation of the
AlphaBeta game-tree search algorithm (also known as MiniMax
search with alpha beta pruning). This algorithm can be used to
find the best move at a particular position in any two-player,
zero-sum game with perfect information. Examples of such games
include Chess, Othello, Connect4, Go, Tic-Tac-Toe and many, many
other boardgames. 

Users must pass an object representing the initial state of the
game as the first argument to ->new(). This object *must* provide
the following five methods: C<copy()>, C<apply()>, C<endpos()>,
C<evaluate()> and C<findmoves()>. You can use
Games::Sequential::Position as a base class, in which case the
C<copy()> method will be provided for you. Here's a short
description of what each of the required methods of the position
object:

=over 4

=item copy()

Return a deep copy of the object.

=item apply($move)

Apply $move to the position producing the next position. 

=item endpos()

Returns true if the position is an end position, i.e. either a
draw or a win for one of the players, and false otherwise. 

=item findmoves()

Returns a list of all legal moves the current player can perform
at the current position. Note that if a pass move is legal in
the game (i.e. as it is in Othello) you must allow for this
function to produce a null move. A null move does nothing but
pass the turn to the next player.

=item evaluate()

Returns the calculated fitness value of the current position for
the current player. The value must be in the range -99_999 -
99_999 (see BUGS). 

=back


=head1 METHODS

Most of this module's methods are inherited from
Games::Sequential; be sure to check its documentation. The
methods unique to Games::AlphaBeta are described below.

=over 4

=item _init [@list]

I<Internal method.>

Initialize an AlphaBeta object.

=cut

sub _init {
    my $self = shift;
    my %config = (
        # Runtime variables
        ply         => 2,       # default search depth
        alpha       => -100_000,
        beta        => 100_000,
    );

    @$self{keys %config} = values %config;
    $self->SUPER::_init(@_);

    my $pos = $self->peek_pos;
    croak "no endpos() method defined" unless $pos->can("endpos");
    croak "no evaluate() method defined" unless $pos->can("evaluate");
    croak "no findmoves() method defined" unless $pos->can("findmoves");

    return $self;
}


=item ply [$value]

Return current default search depth and, if invoked with an
argument, set to new value.

=cut

sub ply {
    my $self = shift;
    my $prev = $self->{ply};
    $self->{ply} = shift if @_;
    return $prev;
}


=item abmove [$ply]

Perform the best move found after an AlphaBeta game-tree search
to depth $ply. If $ply is not specified, the default depth is
used (see ply()). The best move found is performed and a
reference to the resulting position is returned. undef is
returned on failure.

Note that this function can take a long time if $ply is high,
particularly if the game in question has many possible moves at
each position.

If debug() is set, some basic debugging is printed as the search
progresses.

=cut

sub abmove {
    my $self = shift;
    my $ply;

    if (@_) {
        $ply = shift;
        print "Explicit ply $ply overrides default ($self->{ply})\n" if $self->{debug};
    }
    else {
        $ply = $self->{ply};
    }

    my $bestmove;
    my $pos = $self->peek_pos;
    my @moves = $pos->findmoves 
        or return;

    my $alpha = $self->{alpha};
    my $beta = $self->{beta};

    print "Searching to depth $ply\n" if $self->{debug};
    $self->{found_end} = $self->{count} = 0;
    for my $move (@moves) {
        my ($npos, $sc);
        $npos = $pos->copy;
        $npos->apply($move) or croak "apply() failed";
        $sc = -$self->_alphabeta($npos, -$beta, -$alpha, $ply - 1);

        print "ab val: $sc" if $self->{debug};
        if ($sc > $alpha) {
            print " > $alpha new best move" if $self->{debug};
            $bestmove = $move;
            $alpha = $sc;
        }
        print "\n" if $self->{debug};
    }
    print "$self->{count} visited\n" if $self->{debug};

    return unless $bestmove;
    return $self->move($bestmove);
}


=item _alphabeta $pos $alpha $beta $ply

I<Internal method.>

=cut

sub _alphabeta {
    my ($self, $pos, $alpha, $beta, $ply) = @_;
    my @moves;

    # Keep count of the number of positions we've seen
    $self->{count}++;

    # When using iterative deepening we can optimise for the case
    # when we find an end position at every branch (for example,
    # near the end of the game)
    #
    if (($pos->endpos && ++$self->{found_end}) || $ply <= 0) {
        return $pos->evaluate;
    }

    return $pos->evaluate
        unless @moves = $pos->findmoves;

    for my $move (@moves) {
        my ($npos, $sc);
        $npos = $pos->copy or croak "$pos->copy() failed";
        $npos->apply($move) or croak "$pos->apply() failed";

        $sc = -$self->_alphabeta($npos, -$beta, -$alpha, $ply - 1);

        $alpha = $sc if $sc > $alpha;
        last unless $alpha < $beta;
    }

    return $alpha;
}


1;  # ensure using this module works
__END__

=back


=head1 BUGS

The valid range of values C<evaluate> can return is hardcoded to
-99_999 - +99_999 at the moment. Probably should provide methods
to get/set these.


=head1 TODO

Implement the missing iterative deepening alphabeta routine. 


=head1 SEE ALSO

The author's website, describing this and other projects:
http://brautaset.org/projects/


=head1 AUTHOR

Stig Brautaset, E<lt>stig@brautaset.orgE<gt>

=head1 COPYRIGHT AND LICENCE

Copyright (C) 2004 by Stig Brautaset

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.3 or,
at your option, any later version of Perl 5 you may have available.

=cut

# vim: shiftwidth=4 tabstop=4 softtabstop=6 expandtab 
