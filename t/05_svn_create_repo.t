
use Test;

plan tests => 4;

die "re-test requires clean" if -d "s5.repo";

ok( system($^X, '-Iblib/lib', "blib/script/git-svn-replay", "-S", "s5.repo", "s5.co") => 0 );

ok( -d "s5.repo" );
ok( -x "s5.repo/hooks/pre-revprop-change" );
ok( -d "s5.co/.svn" );
