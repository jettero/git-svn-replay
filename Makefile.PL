package main;

require 5.006001;

use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME          => 'git_svn_replay',
    AUTHOR        => 'Paul Miller <jettero@cpan.org>',
    VERSION_FROM  => 'git_svn_replay',
    EXE_FILES     => [ 'git_svn_replay' ],

    PREREQ_PM => {
        'File::Slurp'           => 0,
        'Date::Parse'           => 0,
        'Getopt::Long'          => 0,
        'Term::GentooFunctions' => 0,
        'IPC::System::Simple'   => 0,
        'Pod::Usage'            => 0,
        'DBM::Deep'             => 0,
    },

    ($ExtUtils::MakeMaker::VERSION ge '6.48'? 
        (MIN_PERL_VERSION => 5.008,
            META_MERGE => {
                keywords => ['git', 'svn'],
                resources=> {
                    repository => 'http://github.com/jettero/git_svn_replay',
                },
            },

        LICENSE	=> 'GPL',
    ) : ()),

);

sub MY::postamble {
    my $postamble = <<'MAKE_FRAG';

README: git_svn_replay
	perl -MPod::Text -e '$p = Pod::Text->new (sentence => 0, width => 65); $p->select("DESCRIPTION"); $p->parse_from_file( git_svn_replay => "README");'

MAKE_FRAG

    return $postamble;
}

1;
