package Games::AlphaBeta::Reversi;
use base Games::Sequential::Position;
use Carp;

use strict;
use warnings;

our $VERSION = '0.1';

=head1 NAME

Games::AlphaBeta::Reversi - class used with Games::AlphaBeta for
playing Reversi

=head1 SYNOPSIS

  package My::Reversi;
  use base Games::AlphaBeta::Reversi;

  # Override drawing routine
  sub draw { ... }

  package main;
  use My::Reversi;
  use Games::AlphaBeta;

  my ($p, $g);
  $p = My::Reversi->new;
  $g = Games::AlphaBeta->new($p);

  while ($g->abmove) {
    $p->draw;
  }

=head1 DESCRIPTION


=head1 METHODS

=over 4

=item _init()

I<Internal method.>

Initialize the initial state.

=cut

sub _init {
    my $self = shift;

    my $size = shift || 8;
    my $half = abs($size / 2);
    my %config = (
        player => 1,
        size => $size,
        board => undef,
    );

    # Create a blank board
    $size--;
    for my $x (0 .. $size) {
        for my $y (0 .. $size) {
            $config{board}[$x][$y] = 0;
        }
    }

    # Put initial pieces on board
    $config{board}[$size - $half][$size - $half] = 1;
    $config{board}[$half][$half] = 1;
    $config{board}[$size - $half][$half] = 2;
    $config{board}[$half][$size - $half] = 2;

    @$self{keys %config} = values %config;

    $self->SUPER::_init(@_) or croak "failed to call SUPER:_init()";
    return $self;
}

=item as_string

Return a plain-text representation of the current game position
as a string.

=cut

sub as_string {
    my $self = shift;

    # Header
    my ($c, $str) = "a";
    $str .= " " . $c++ for (1 .. $self->{size});
    $str  = sprintf("    %s\n", $str);
    $str .= sprintf("   +%s\n", "--" x $self->{size});

    # Actual board (with numbers down the left side)
    my $i;
    for (@{$self->{board}}) {
        for (join " ", @$_) {
            s/0/./g;
            s/1/o/g;
            s/2/x/g;
            $str .= sprintf("%2d | %s\n", ++$i, $_);
        }
    }
    
    # Footer
    $str .= "Player " . $self->{player} . " to move.\n";
    return $str;
}


=item valid_move $x, $y

Return true if the given $x/$y coordinate is a valid move for the
current player, false otherwise.

=cut

sub valid_move {
    my ($self, $x, $y) = @_;

    return 1        if ($x == $y && $y == -1);  # Null move
    return undef    if $self->{board}[$x][$y];  # Slot must be free

    # Define some convenient names.
    my $b       = $self->{board};
    my $me      = $self->{player};
    my $not_me  = 3 - $me;

    my ($tx, $ty);

    # Check left 
    for ($tx = $x - 1; $tx >= 0 && $b->[$tx][$y] == $not_me; $tx--) {
         ;
    }
    if ($tx >= 0 && $tx != $x - 1 && $b->[$tx][$y] == $me) {
        return 1;
    }

    # Check right
    for ($tx = $x + 1; $tx < 8 && $b->[$tx][$y] == $not_me; $tx++) {
        ;
    }
    if ($tx < 8 && $tx != $x + 1 && $b->[$tx][$y] == $me) {
        return 1;
    }

    # Check up
    for ($ty = $y - 1; $ty >= 0 && $b->[$x][$ty] == $not_me; $ty--) {
        ;
    }
    if ($ty >= 0 && $ty != $y - 1 && $b->[$x][$ty] == $me) {
        return 1;
    }

    # Check down
    for ($ty = $y + 1; $ty < 8 && $b->[$x][$ty] == $not_me; $ty++) {
        ;
    }
    if ($ty < 8 && $ty != $y + 1 && $b->[$x][$ty] == $me) {
        return 1;
    }

    # Check up/left
    $tx = $x - 1;
    $ty = $y - 1;
    while ($tx >= 0 && $ty >= 0 && $b->[$tx][$ty] == $not_me) {
        $tx--; 
        $ty--;
    }
    if ($tx >= 0 && $ty >= 0 && $tx != $x - 1 && $ty != $y - 1 &&
        $b->[$tx][$ty] == $me) {
        return 1;
    }


    # Check up/right
    $tx = $x - 1;
    $ty = $y + 1;
    while ($tx >= 0 && $ty < 8 && $b->[$tx][$ty] == $not_me) {
        $tx--; 
        $ty++;
    }
    if ($tx >= 0 && $ty < 8 && $tx != $x - 1 && $ty != $y + 1 &&
        $b->[$tx][$ty] == $me) {
        return 1;
    }

    # Check down/right
    $tx = $x + 1;
    $ty = $y + 1;
    while ($tx < 8 && $ty < 8 && $b->[$tx][$ty] == $not_me) {
        $tx++; 
        $ty++;
    }
    if ($tx < 8 && $ty < 8 && $tx != $x + 1 && $ty != $y + 1 &&
        $b->[$tx][$ty] == $me) {
        return 1;
    }

    # Check down/left
    $tx = $x + 1;
    $ty = $y - 1;
    while ($tx < 8 && $ty >= 0 && $b->[$tx][$ty] == $not_me) {
        $tx++; 
        $ty--;
    }
    if ($tx < 8 && $ty >= 0 && $tx != $x + 1 && $ty != $y - 1 &&
        $b->[$tx][$ty] == $me) {
        return 1;
    }

    # If we got here the move was illegal
    return undef;
}

=item findmoves

Return an array of all legal moves at the current position (for
the current player).

=cut

sub findmoves {
    my $self = shift;
    my @moves;

    for my $x (0 .. $self->{size} - 1) {
        for my $y (0 .. $self->{size} - 1) {
            if ($self->valid_move($x, $y)) {
                push @moves, [$x, $y];
            }
        }
    }
    # Pass if no available moves
    @moves = [-1, -1] unless @moves;
    return @moves;
}


=item evaluate

Evaluate a game position.

=cut

sub evaluate {
    my $self = shift;
    my $player = $self->{player};
    my ($me, $not_me);

    $me = scalar $self->findmoves;
    $self->{player} = 3 - $player;
    $not_me = scalar $self->findmoves;
    $self->{player} = $player;

    return $me - $not_me;
}



=item apply $move

Apply a move to the current position, producing the new position.

=cut

sub apply ($) {
    my ($self, $move) = @_;

    my $size    = $self->{size};
    my $b       = $self->{board};
    my $me      = $self->{player};
    my $not_me  = 3 - $self->{player};
    my ($x, $y) = @$move;

    # null or pass move
    if ($x == -1 && $y == -1) {
        $self->{player} = $not_me;
        return $self;
    }

    my ($tx, $ty, $flipped);

    # slot must not be outside the board, or already occupied
    if ($x < 0 || $x >= $size || $y < 0 || $y >= $size) {
        return undef;
    }
    elsif ($b->[$x][$y]) {
        return undef;
    }

    # left
    for ($tx = $x - 1; $tx >= 0 && $b->[$tx][$y] == $not_me; $tx--) {
        ;
    }
    if ($tx >= 0 && $tx != $x - 1 && $b->[$tx][$y] == $me) {
        $tx = $x - 1;
        while ($tx >= 0 && $b->[$tx][$y] == $not_me) {
            $b->[$tx][$y] = $me;
            $tx--;
        }
        $flipped++;
    }

    # right
    for ($tx = $x + 1; $tx < $size && $b->[$tx][$y] == $not_me; $tx++) {
        ;
    }
    if ($tx < $size && $tx != $x + 1 && $b->[$tx][$y] == $me) {
        $tx = $x + 1;
        while ($tx < $size && $b->[$tx][$y] == $not_me) {
            $b->[$tx][$y] = $me;
            $tx++;
        }
        $flipped++;
    }

    # up
    for ($ty = $y - 1; $ty >= 0 && $b->[$x][$ty] == $not_me; $ty--) {
        ;
    }
    if ($ty >= 0 && $ty != $y - 1 && $b->[$x][$ty] == $me) {
        $ty = $y - 1;
        while ($ty >= 0 && $b->[$x][$ty] == $not_me) {
            $b->[$x][$ty] = $me;
            $ty--;
        }
        $flipped++;
    }
    
    # down
    for ($ty = $y + 1; $ty < $size && $b->[$x][$ty] == $not_me; $ty++) {
        ;
    }
    if ($ty < $size && $ty != $y + 1 && $b->[$x][$ty] == $me) {
        $ty = $y + 1;
        while ($ty < $size && $b->[$x][$ty] == $not_me) {
            $b->[$x][$ty] = $me;
            $ty++;
        }
        $flipped++;
    }
    
    # up/left
    $tx = $x - 1;
    $ty = $y - 1; 
    while ($tx >= 0 && $ty >= 0 && $b->[$tx][$ty] == $not_me) {
        $tx--;
        $ty--;
    }
    if ($tx >= 0 && $ty >= 0 && $tx != $x - 1 && $ty != $y - 1 && 
            $b->[$tx][$ty] == $me) {
        $tx = $x - 1;
        $ty = $y - 1;
        while ($tx >= 0 && $ty >= 0 && $b->[$tx][$ty] == $not_me) {
            $b->[$tx][$ty] = $me;
            $tx--; 
            $ty--;
        }
        $flipped++;
    }

    # up/right
    $tx = $x - 1;
    $ty = $y + 1; 
    while ($tx >= 0 && $ty < $size && $b->[$tx][$ty] == $not_me) {
        $tx--;
        $ty++;
    }
    if ($tx >= 0 && $ty < $size && $tx != $x - 1 && $ty != $y + 1 && 
            $b->[$tx][$ty] == $me) {
        $tx = $x - 1;
        $ty = $y + 1;
        while ($tx >= 0 && $ty < $size && $b->[$tx][$ty] == $not_me) {
            $b->[$tx][$ty] = $me;
            $tx--;
            $ty++;
        }
        $flipped++;
    }
    
    # down/right
    $tx = $x + 1;
    $ty = $y + 1; 
    while ($tx < $size && $ty < $size && $b->[$tx][$ty] == $not_me) {
        $tx++;
        $ty++;
    }
    if ($tx < $size && $ty < $size && $tx != $x + 1 && $ty != $y + 1 && 
            $b->[$tx][$ty] == $me) {
        $tx = $x + 1;
        $ty = $y + 1;
        while ($tx < $size && $ty < $size && $b->[$tx][$ty] == $not_me) {
            $b->[$tx][$ty] = $me;
            $tx++;
            $ty++;
        }
        $flipped++;
    }

    # down/left
    $tx = $x + 1;
    $ty = $y - 1;
    while ($tx < $size && $ty >= 0 && $b->[$tx][$ty] == $not_me) {
        $tx++;
        $ty--;
    }
    if ($tx < $size && $ty >= 0 && $tx != $x + 1 && $ty != $y - 1 && 
            $b->[$tx][$ty] == $me) {
        $tx = $x + 1;
        $ty = $y - 1;
        while ($tx < $size && $ty >= 0 && $b->[$tx][$ty] == $not_me) {
            $b->[$tx][$ty] = $me;
            $tx++;
            $ty--;
        }
        $flipped++;
    }

    unless ($flipped) {
        return undef;
    }

    $b->[$x][$y] = $me;
    $self->{player} = $not_me;

    return $self;
}

=back

=head1 BUGS


=head1 TODO


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

# vim: shiftwidth=4 tabstop=4 softtabstop=4 expandtab 
