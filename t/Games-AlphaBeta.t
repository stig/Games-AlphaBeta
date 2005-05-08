# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl Games-GGTL.t'

#########################

# change 'tests => 1' to 'tests => last_test_to_print';

use Test::More tests => 17;
BEGIN { use_ok('Games::AlphaBeta') };

#########################

# Insert your test code below, the Test::More module is use()ed here so read
# its man page ( perldoc Test::More ) for help writing this test script.

sub move {
    my ($p, $m) = @_;

    $m = -$m if $p->{player} == 2;
    my $np = {
        player => 3 - $p->{player},
        val => $p->{val} + $m,
    };
    return $np;
}

sub evaluate {
    my $p = shift;
    return $p->{val};
}

sub findmoves {
    return (0, 1, -1, 0);
}

sub eog {
    $p = shift;
    return $p->{val} > 30 ? 1 : 0;
}

my $p = {
        player => 1,
        val => 0
};
ok(my $g = Games::AlphaBeta->new($p, {
            move => \&move, evaluate => \&evaluate, 
            findmoves => \&findmoves, endofgame => \&eog
        }), "Constructor");
can_ok($g, qw/abmove ply/);

isa_ok($g, Games::AlphaBeta);
isa_ok($g, Games::Sequential);

is($g->debug(1), 0, "debug");
is($g->debug, 1, "debug read");

ok($g->abmove(4), "abmove");
ok($p = $g->peek_pos, "peek pos");
is($g->peek_move, 1, "move");
is($p->{player}, 2, "player turn");
is($p->{val}, 1, "best value");


is($g->ply(3), 2, "set & read ply");
ok($g->abmove, "abmove (2)");

is($p->{player}, 2, "player turn (2)");
is($p->{val}, 1, "current value");
is($g->peek_move, 1, "move (2)");

