
use Test;
use File::Spec;
use IPC::System::Simple qw(capturex);

die "re-test requires clean" if -d "s9.co";

my $r = File::Spec->rel2abs("s7.repo");
my $l = capturex(svn=>'co', "file://$r", 's9.co');

my @r = (
    '^A\s+s9\.co/dir1$',
    '^A\s+s9\.co/dir2$',
    '^A\s+s9\.co/testdir$',
    '^A\s+s9\.co/testdir/yikes$',
    '^A\s+s9\.co/testdir/yikes/hard$',
    '^A\s+s9\.co/testdir/yikes/hard/test$',
    '^A\s+s9\.co/testdir/yikes/hard/test/recursive$',
    'revision 3',
);

plan tests => int @r;
ok( $l =~ m/$_/m ) for @r;
