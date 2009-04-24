package main;

require 5.006001;

use strict;
use warnings;
use ExtUtils::MakeMaker;

$SIG{PIPE} = sub {}; 
open POPEN_SVN, "svn help|" or die "git and svn must be installed and in our path for this tool to function."; 1 while <POPEN_SVN>;
close POPEN_SVN             or die "git and svn must be installed and in our path for this tool to function.";

open POPEN_GIT, "git help|" or die "git and svn must be installed and in our path for this tool to function."; 1 while <POPEN_GIT>;
close POPEN_GIT             or die "git and svn must be installed and in our path for this tool to function.";

WriteMakefile(
    NAME          => 'git-svn-replay',
    AUTHOR        => 'Paul Miller <jettero@cpan.org>',
    VERSION_FROM  => 'git-svn-replay',
    EXE_FILES     => [ 'git-svn-replay' ],

    PREREQ_PM => {
        'File::Slurp'           => 0,
        'File::Path'            => 0,
        'Date::Parse'           => 0,
        'Getopt::Long'          => 0,
        'Term::GentooFunctions' => 0,
        'IPC::System::Simple'   => 0,
        'Pod::Usage'            => 0,
        'DBM::Deep'             => 0,
    },

    ($ExtUtils::MakeMaker::VERSION ge '6.48'? 
        (MIN_PERL_VERSION => 5.006001,
            META_MERGE => {
                keywords => ['git', 'svn'],
                resources=> {
                    repository => 'http://github.com/jettero/git-svn-replay',
                },
            },

        LICENSE	=> 'GPL',
    ) : ()),

    clean => { FILES => '*.repo *.co *.rdb dist' },
);

sub MY::postamble {
    my $postamble = <<'MAKE_FRAG';

README: git-svn-replay
	perl -MPod::Text -e '$$p = Pod::Text->new (sentence => 0, width => 65); $$p->select("DESCRIPTION"); $$p->parse_from_file( "git-svn-replay" => "README");'

MAKE_FRAG

    return $postamble;
}

1;
