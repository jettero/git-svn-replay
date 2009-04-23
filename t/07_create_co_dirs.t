
use Test;

plan tests => 11;

ok( system($^X, "blib/script/git-svn-replay", "-S", "s5.repo", (map {('-s', $_)} qw(dir1 dir2)), "s5.co") => 0 );
ok( -d "s5.co/dir1" );
ok( -d "s5.co/dir2" );

ok( system($^X, "blib/script/git-svn-replay", "-S", "s7.repo", (map {('-s', $_)} qw(dir1 dir2)), "s7.co") => 0 );
ok( -d "s7.co/.svn" );
ok( -d "s7.co/dir1" );
ok( -d "s7.co/dir2" );

ok( system($^X, "blib/script/git-svn-replay", "-S", "s7.repo", '-s', 'this/is/a/hard/test/yikes', "s7.co") => 0 );
ok( -d "s7.co/this/is/a/hard/test/yikes" );

ok( system($^X, "blib/script/git-svn-replay", "-S", "s7.repo", '-s', 'this/is/a/hard/test/yikes/2', "s7.co") => 0 );
ok( -d "s7.co/this/is/a/hard/test/yikes/2" );
