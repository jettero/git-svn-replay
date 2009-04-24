package Git::SVNReplay;

use strict;
use warnings;

use Carp;
use DBM::Deep;
use File::Find;
use File::Slurp qw(write_file slurp);
use Term::GentooFunctions qw(:all);
use IPC::System::Simple qw(systemx capturex);
use Date::Parse; # dates in (Date::Manip will not handle git/date-R time...)
use POSIX; # dates out

our %DEFAULTS = (
    db_file       => "replay.rdb",
    patch_format  => '%s [%h]%n%n%b%n%aN <%aE>%n%ai%n%H',
    src_branch    => "master",
    mirror_branch => "mirror",
);

# new {{{
sub new {
    my $class = shift;
    my $this = bless {%DEFAULTS, @_}, $class;

    $this;
}
# }}}
# create_db {{{
sub create_db {
    my $this = shift;

    return $this->{dbm} if $this->{dbm};

    my $TOP = new DBM::Deep($this->{db_file});

    $TOP->{$this->{svnco}} = {}
        unless $TOP->{$this->{svnco}};

    $this->{dbm} = $TOP->{$this->{svnco}};
}
# }}}

# setup_git_in_svnco {{{
sub setup_git_in_svnco {
    my $this = shift;

    chdir $this->{svnco} or die "couldn't chdir into svnco($this->{svnco}): $!";

    if( not -d "$this->{svnco}/.git/" ) {
        ebegin "cloning $this->{gitrepo} ($this->{src_branch})";
        logging_systemx(qw(git init));
        logging_systemx(qw(git symbolic-ref HEAD), "refs/heads/$this->{mirror_branch}");
        eend 1;

    } else {
        ebegin "resettting mirror";
        logging_systemx(qw(git checkout -q), $this->{mirror_branch});
        logging_systemx(qw(git reset --hard));
        eend 1;

    }

    ebegin "pulling updates from $this->{gitrepo} ($this->{src_branch})";
    logging_systemx(qw(git pull), $this->{gitrepo}, "$this->{src_branch}:$this->{mirror_branch}");
    eend 1;
}
# }}}
# run {{{
sub run {
    my $this = shift;
       $this->create_db;

    my @commits = capturex(qw(git rev-list --reverse mirror)); chomp @commits;
       @commits = grep { !$this->{dbm}{already_replayed}{$_} } @commits;

    my $total = @commits;
    my $cur = 1;

    for my $commit ( @commits ) {
        $this->{_progress} = "[$cur/$total]:$commit";

        if( $this->replay($commit) and $this->inform_svn($commit) ) {
            push @{ $this->{dbm}{replayed_commits_in_order} }, $commit;
            $this->{dbm}{already_replayed}{$commit} = 1

        } else {
            edie("no point in continuing, something is wrong");
        }

        $cur ++;
    }
}
# }}}

# replay {{{
sub replay {
    my ($this, $commit) = @_;

    einfo "REPLAY $this->{_progress}";
    eindent;

    einfo "git checkout";
    logging_systemx(qw(git checkout -q), $commit);
    eend 1;

    ebegin "dumping commit log to .msg";
    write_file(".msg" => capturex(qw(git show -s), '--pretty=format:' . $this->{patchformat}));
    eend 1;

    eoutdent;

    return 1;
}
# }}}
# inform_svn {{{
sub inform_svn {
    my ($this, $commit) = @_;

    einfo "INFORM $this->{_progress}";
    eindent;

    my @files;
    my @dirs;

    &File::Find::find({wanted => sub {
        if( -f $_ ) {
            unless( $_ eq ".msg" ) {
                push @files, $File::Find::name;
            }

        } elsif( -d _ ) {
            if( m/^\.(?:git|svn)\z/ ) {
                $File::Find::prune = 1;

            } elsif( not m/^\.{1,2}\z/ ) {
                push @dirs, $File::Find::name;
            }
        }

    }}, '.' );

    if( my $parent = $this->{dbm}{replayed_commits_in_order}[-1] ) {
        for my $f (@{ $this->{dbm}{last_files}{$parent} }) {
            unless( -f $f ) {
                einfo "removing file \"$f\" from svn:  ";
                logging_systemx(qw(svn rm), $f);
                eend 1;

                $this->{dbm}{already_tracking_file}{$f} = 0;
            }
        }

        for my $d (@{ $this->{dbm}{last_dirs}{$parent} }) {
            unless( -d $d ) {
                einfo "removing directory \"$d\" from svn:  ";
                logging_systemx(qw(svn rm), $d);
                eend 1;

                $this->{dbm}{already_tracking_dir}{$d} = 0;
            }
        }
    }

    for my $d (@dirs) {
        next if $this->{dbm}{already_tracking_dir}{$d};

        einfo "adding directory \"$d\" to svn:  ";
        logging_systemx(qw(svn add), $d);
        eend 1;

        $this->{dbm}{already_tracking_dir}{$d} = 1;
    }

    for my $f (@files) {
        next if $this->{dbm}{already_tracking_file}{$f};

        einfo "adding file \"$f\" to svn:  ";
        logging_systemx(qw(svn add), $f);
        eend 1;

        $this->{dbm}{already_tracking_file}{$f} = 1;
    }

    ebegin "comitting changes to svn";
    logging_systemx(qw(svn commit -F .msg));
    eend 1;

    if( my $gdate = capturex(qw(git show -s --pretty=format:%at)) ) {
        my $date = strftime('%Y-%m-%dT%H:%M:%S.000000Z', gmtime($gdate));

        ebegin "changing commit date to $date";
        logging_systemx(qw(svn propset --revprop -r HEAD svn:date), $date);
        eend 1;

    } else {
        ewarn "date not found for $commit";
    }

    $this->{dbm}{last_dirs}{$commit}  = \@dirs;
    $this->{dbm}{last_files}{$commit} = \@files;

    # svn commits sometimes alters things causing git merge problems (very rare).
    # This resets everything that's tracked by git.
    logging_systemx(qw(git reset --hard));

    eoutdent;

    return 1;
}
# }}}

no warnings;
"my codes are perfect (too)";
