
use Test;

plan tests => 4;

ok( system($^X, "blib/script/git-svn-replay", "-S", "s5.repo", "s5.co") => 0 );

ok( -d "s5.repo" );
ok( -x "s5.repo/hooks/pre-revprop-change" );
ok( -d "s5.co/.svn" );
