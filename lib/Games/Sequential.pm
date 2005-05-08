package Games::Sequential;
use Carp;
use 5.008003;
use strict;
use warnings;

our $VERSION = '0.01';

=head1 NAME

Games::AlphaBeta - game-tree search with object oriented interface

=head1 SYNOPSIS

  use Games::Sequential;
  my $game = Games::Sequential->new( INITIALPOS => $p, MOVE => \&move );

  $game->debug(1);

  $game->move($move);
  $game->undo;
  

=head1 DESCRIPTION

Games::Sequential provides a very simple base class for
sequential games. The module provides an undo mechanism, as it
keeps track of the history of moves, in addition to methods to
clone a game state with or without history.

Users will have to implement and provide this module with a
pointer to a callback function to perform a move in the game they
are implementing. This callback is:

=over 4

=item MOVE $position, $move

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

The function MOVE can be given as an argument to this function.
If so, there is no need to call the setfuncs() method. Similarly,
if a valid starting position is given (as INITIALPOS) there is no
need to call init() on the returned object.

The arguments PLY E<amp> DEBUG can also optionally be set here.
They can later be changed with their respective accessor methods.

=cut 

sub new {
	my $invocant = shift;
	my $class = ref($invocant) || $invocant;
	my $self = bless {}, $class;

    $self->_init(@_) or carp "Failed to init object!";
    return $self;
}


=begin internal

=item _init [@list]

Initialize a AlphaBeta object.

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
		MOVE	    => undef,

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
            delete($args->{$key});
        }
        elsif ($key eq "INITIALPOS") {
            $self->{POS_HIST} = [ $args->{INITIALPOS} ];
            $self->{MOVE_HIST} = [];
            delete($args->{$key});
        }
    }

	return $self;
}

=item init $position

Initialise an object with the starting position of the game. This
method is required unless ->new() is invoked with an apropriate
INITIALPOS argument.

=cut

# Set initial position
sub init {
    my $self = shift;
    croak "No initial position given!" unless @_;

    $self->{POS_HIST} = [ shift ];
    $self->{MOVE_HIST} = [ ];

    return $self->peek_pos;
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
    my $prev = $self->{DEBUG};
    $self->{DEBUG} = shift if @_;
    return $prev;
}


=item peek_pos

Return reference to current position.
Use this for drawing the board etc.

=cut

sub peek_pos {
    my $self = shift;
    return $self->{POS_HIST}[-1];
}


=item peek_move

Return reference to last applied move.

=cut

sub peek_move {
    my $self = shift;
    return $self->{MOVE_HIST}[-1];
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


1;  # ensure using this module works

__END__


=head1 TODO

Implement missing methods, e.g.: clone(), snapshot(), save()
E<amp> resume().


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
