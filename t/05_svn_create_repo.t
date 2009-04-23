
use Test;

plan tests => 3;

ok( system($^X, "blib/script/git-svn-replay", "-S", "s5.repo", "s5.co") => 0 );

ok( -d "s5.repo" );
ok( -d "s5.co/.svn" );
