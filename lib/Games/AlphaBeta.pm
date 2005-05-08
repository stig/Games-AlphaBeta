package Games::AlphaBeta;
use base Games::Sequential;
use Carp;
use 5.008003;
use strict;
use warnings;

our $VERSION = '0.03';

=head1 NAME

Games::AlphaBeta - game-tree search with object oriented interface

=head1 SYNOPSIS

  use Games::AlphaBeta;
  my $game = Games::AlphaBeta->new( ... );
  
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

This module inherits most of its methods from Games::Sequential.
However, users will have to implement (and provide this module
with pointers to) three more callback functions specific to the
game they are implementing. The four callbacks required are:

=over 4

=item MOVE $position, $move

Create $newpos as copy of $position and apply $move to it.
Return $newpos.

=item FINDMOVES $position

Returns a list of all legal moves the current player can perform
at the current $position. Note that if a pass move is legal in
the game (i.e. as it is in Othello) you must allow for this
function to produce a null move. A null move does nothing but
pass the turn to the next player.

=item ENDOFGAME $position

Returns true if $position is the end of the game, false
otherwise. Remember to account for a draw in addition to either
of the players winning. 

=item EVALUATE $position

Returns the calculated fitness value of the current position for
the current player. The value must be in the range -99_999 -
99_999 (see BUGS). 

=back


=head1 METHODS

Users must not modify the referred-to values of references
returned by any of the below methods, except, of course,
indirectly using the supplied callbacks mentioned above.

=over 4

=begin internal

=item _init [@list]

Initialize a AlphaBeta object.

=end

=cut

sub _init {
    my $self = shift;
    my $args = @_ && ref($_[0]) ? shift : { @_ };
    my $config = {
		# Callbacks
		EVALUATE	=> undef,
		FINDMOVES	=> undef,
		ENDOFGAME	=> undef,

        # Runtime variables
        PLY         => 2,       # default search depth
        ALPHA       => -100_000,
        BETA        => 100_000,
	};

    # Initialise backend
    $self->SUPER::_init($args);

    # Set defaults
    while (my ($key, $val) = each %{ $config }) {
        $self->{$key} = $val;
    }

    # Override defaults
    while (my ($key, $val) = each %{ $args }) {
        if (exists $self->{$key}) {
            $self->{$key} = $val;
        }
        else {
            carp "Non-recognised key/value pair: $key/$val\n";
        }
    }

	return $self;
}


=item ply [$value]

Return current default search depth and, if invoked with an
argument, set to new value.

=cut

sub ply {
    my $self = shift;
    my $prev = $self->{PLY};
    $self->{PLY} = shift if @_;
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
        print "Explicit ply $ply overrides default ($self->{PLY})\n" if $self->{DEBUG};
    }
    else {
        $ply = $self->{PLY};
    }

    my $bestmove;
    my $pos = $self->peek_pos;
	my @moves = $self->{FINDMOVES}($pos)
        or return;

    my $alpha = $self->{ALPHA};
    my $beta = $self->{BETA};

    print "Searching to depth $ply\n" if $self->{DEBUG};
    $self->{FOUND_END} = $self->{COUNT} = 0;
	for my $move (@moves) {
		my $npos = $self->{MOVE}($pos, $move) or croak "No move returned from MOVE!";
		my $sc = -$self->_alphabeta($npos, -$beta, -$alpha, $ply - 1);

        print "ab val: $sc" if $self->{DEBUG};
        if ($sc > $alpha) {
            print " > $alpha new best move" if $self->{DEBUG};
            $bestmove = $move;
            $alpha = $sc;
        }
        print "\n" if $self->{DEBUG};
    }
    print "$self->{COUNT} visited\n" if $self->{DEBUG};

    return unless $bestmove;
    return $self->move($bestmove);
}


=begin internal

=item _alphabeta $pos $alpha $beta $ply

=end

=cut

sub _alphabeta {
	my ($self, $pos, $alpha, $beta, $ply) = @_;
    my @moves;

	# Keep count of the number of positions we've seen
	$self->{COUNT}++;

    # When using iterative deepening we can optimise for the case
    # when we find an end position at every branch (for example,
    # near the end of the game)
	#
	if ($self->{ENDOFGAME}($pos)) {
		$self->{FOUND_END}++;
		return $self->{EVALUATE}($pos);
	}
	elsif ($ply <= 0) {
		return $self->{EVALUATE}($pos);
	}

    return $self->{EVALUATE}($pos) 
        unless @moves = $self->{FINDMOVES}($pos);

	for my $move (@moves) {
		my $npos = $self->{MOVE}($pos, $move);
		my $sc = -$self->_alphabeta($npos, -$beta, -$alpha, $ply - 1);

		$alpha = $sc if $sc > $alpha;
        last unless $alpha < $beta;
	}

	return $alpha;
}

=back

=end

=cut

1;  # ensure using this module works

__END__

=head1 BUGS

The valid range of values EVALUATE can retun is hardcoded to
-99_999 - +99_999 at the moment. Probably should provide methods
to get/set these.


=head1 SEE ALSO

The author's website for this module: 
http://brautaset.org/projects/alphabeta/

The author's website for the C library that inspired this module:
http://brautaset.org/projects/ggtl/


=head1 AUTHOR

Stig Brautaset, E<lt>stig@brautaset.orgE<gt>

=head1 COPYRIGHT AND LICENCE

Copyright (C) 2004 by Stig Brautaset

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.3 or,
at your option, any later version of Perl 5 you may have available.

=cut

# vim: shiftwidth=4 tabstop=4 softtabstop=4 expandtab 
