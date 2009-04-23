
use Test;

plan tests => 1;

ok( system($^X, '-c', "blib/script/git-svn-replay") => 0 );
