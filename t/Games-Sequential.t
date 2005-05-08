# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl
# Games-Sequential.t'

#########################

use Test::More tests => 17;
BEGIN { use_ok('Games::Sequential') };

#########################

# Insert your test code below, the Test::More module is use()ed here so read
# its man page ( perldoc Test::More ) for help writing this test script.

sub move {
    my ($p, $m) = @_;
    return $p + $m;
}

sub move2 {
    my ($p, $m) = @_;
    return $p - $m;
}
	
ok(my $g = Games::Sequential->new(1, move => \&move), "Constructor");
can_ok($g, qw/new setfuncs move undo peek_pos peek_move debug/);
ok(1 == $g->peek_pos, "peek pos");
ok(!$g->peek_move, "peek move");

ok(0 == $g->debug(1), "set debug");
ok(1 == $g->debug(0), "reset debug");
ok(0 == $g->debug, "read debug");

ok(2 == $g->move(1), "move (1)");
ok(4 == $g->move(2), "move (2)");
ok(4 == $g->peek_pos, "peek pos again");
ok(2 == $g->peek_move, "peek move again");

ok($g->setfuncs(move => \&move2), "setfuncs (list)");
ok(3 == $g->move(1), "move (3)");

ok($g->setfuncs({move => \&move}), "setfuncs (hashref)");
ok(4 == $g->move(1), "move (4)");

ok(3 == $g->undo, "undo");
