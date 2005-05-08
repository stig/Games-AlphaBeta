package Games::GGTL;

use 5.008003;
use strict;
use warnings;

use Carp;

our $VERSION = '0.02';

=head1 NAME

Games::GGTL - AlphaBeta game-tree search with object oriented interface

=head1 SYNOPSIS

  use Games::GGTL;
  my $game = Games::GGTL->new( ... );
  
  while ($game->aimove) {
          print draw($game->peek_pos);
  }

=head1 DESCRIPTION

GGTL exists to help people create computer games, in particular
2-player, zero-sum games with perfect information. Examples of
such games include Chess, Othello, Connect4, Tic-Tac-Toe, Go and
a whole slew of other boardgames. For such games GGTL provides
AlphaBeta game-tree search.

Users of the module will have to implement 4 callback functions
specific to the game in question. These are:

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
returned by any of GGTL's methods, except, of course, indirectly
using the methods described below.

=over 4

=item new [@list]

Create and return a new GGTL object.

The functions EVALUATE, FINDMOVES, MOVE E<amp> ENDOFGAME
arguments can be given here. If so, there is no need to call the
setfuncs() method. Similarly, if a valid starting position is
given (as STARTPOS) there is no need to call init() on the
returned object.

The arguments PLY E<amp> DEBUG can also optionally be set here.
They can later be changed with their respective accessor methods.

=cut 

sub new {
	my $invocant = shift;
	my $class = ref($invocant) || $invocant;
	my $self = bless {}, $class;

    $self->_init(@_);
    return $self;
}


=begin internal

=item _init [@list]

Initialize a GGTL object.

=end

=cut

sub _init {
    my $self = shift;
    my $args = @_ && ref($_[0]) ? shift : { @_ };
    my $config = {
		# Stacks for backtracking
		POS_HIST	=> [],
		MOVE_HIST	=> [],

		# Callbacks
		EVALUATE	=> undef,
		FINDMOVES	=> undef,
		MOVE	    => undef,
		ENDOFGAME	=> undef,

        # Runtime variables
        PLY         => 2,       # default search depth
        ALPHA       => -100_000,
        BETA        => 100_000,

		# Debug and statistics
		DEBUG		=> 0,
	};

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
    $self->{POS_HIST} = [ $args->{STARTPOS} ] if exists($args->{STARTPOS});

	return $self;
}

=item init $position

Initialise a GGTL object with the starting position of the game.
This method is required, unless ->new() is invoked with an
apropriate STARTPOS argument.

=cut

# Set initial position
sub init {
    my $self = shift;
    croak "No initial position given!" unless @_;

    $self->{POS_HIST} = [ shift ];
    $self->{MOVE_HIST} = undef;

    return $self->peek_pos;
}


=item setfuncs @list

Set (or change) callback functions. This method is required,
unless ->new() is invoked with the apropriate arguments
(EVALUATE, FINDMOVES, MOVE E<amp> ENDOFGAME) instead.

=cut

sub setfuncs {
    my $self = shift;
    croak "Setfunc called with no arguments!" unless @_;

    my %funcs = @_;
    foreach (qw/EVALUATE FINDMOVES MOVE ENDOFGAME/) {
        $self->{$_} = $funcs{$_} if ref($funcs{$_}) eq 'CODE';
    }
    return $self;
}


=item debug [$value]

Return current debug level and, if invoked with an argument, set
to new value.

=cut

sub debug {
    my $self = shift;
    my $prev = $self->{DEBUG};
    $self->{DEBUG} = shift if @_;
    return $prev;
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


=item peek_pos

Return reference to current position.
Use this for drawing the board etc.

=cut

sub peek_pos {
    my $self = shift;
    my $pos = pop @{ $self->{POS_HIST} };
    push @{ $self->{POS_HIST} }, $pos;
    return $pos;
}


=item peek_move

Return reference to last applied move.

=cut

sub peek_move {
    my $self = shift;
    my $move = pop @{ $self->{MOVE_HIST} };
    push @{ $self->{MOVE_HIST} }, $move;
    return $move;
}


=item move $move

Apply $move to the current position, keeping track of history.
A reference to the new position is returned, or undef on failure.

=cut

sub move {
    my ($self, $move) = @_;
    my $pos = $self->peek_pos;

    my $npos = $self->{MOVE}($pos, $move);
    return unless $npos;

    push @{ $self->{POS_HIST} }, $npos;
    push @{ $self->{MOVE_HIST} }, $move;

    return $self->peek_pos;
}


=item undo

Undo last move. A reference to the previous position is returned,
or undef if there was no more moves to undo.

=cut

sub undo {
    my $self = shift;
    return unless pop @{ $self->{MOVE_HIST} };
    pop @{ $self->{POS_HIST} } or carp "Can't pop empty stack";
    return $self->peek_pos;
}


=item aimove [$ply]

Perform MiniMax search with Alpha-Beta pruning to depth $ply. If
$ply is not specified, the default depth is used (see ply()). 
The best move found is performed and a reference to the resulting
position is returned. undef is returned on failure.

Note that this function can take a long time if $ply is high,
particularly if the game in question has many possible moves at
each position.

If debug() is set, some basic debugging is printed as the search
progresses.

=cut

sub aimove {
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


=head1 TODO

Implement missing methods, e.g.: clone(), snapshot(), save()
E<amp> resume().

Fix bugs.


=head1 SEE ALSO

The author's website for this module: 
http://brautaset.org/projects/ggtl-perl/

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
