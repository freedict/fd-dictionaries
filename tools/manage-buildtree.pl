#!/usr/bin/perl

# Revisions of the TEI files in CVS that are tagged as "rel-x-y-z"
# are destined to become releases. The latest revisions tagged as
# release are kept in the FreeDict build tree. This tree can be
# updated with this tool.
#
# From the revisions tagged as releases, the actual releases for
# the supported platforms are built. The releases are released with
# a version matching the <edition> of their originating TEI file.

use Cvs;
use Getopt::Std;
use strict;

our ($interactive, $loglevel, $opt_v, $opt_n, $opt_a, $opt_h, $opt_i,
 $testdir, $checkout_all, $checkout_none, $cvsroot, $opt_m, $opt_c);

# scan tags for "rel-x-y-z"
# returns tag for which x,y,z are highest
sub highest
{
  my $h;
  foreach(@_)
  {
    my @parts = split /-/, $_,;
    #print "parts: ", join('#', @parts), " #:", $#parts, "\n";
    next if($parts[0] ne 'rel') ||
           ($#parts != 3);
    my $x = $parts[1]; $x =~ s/\D//g;
    my $y = $parts[2]; $y =~ s/\D//g;
    my $z = $parts[3]; $z =~ s/\D//g;
    next if $x ne $parts[1] || $y ne $parts[2] || $z ne $parts[3];
    my ($hx, $hy, $hz);
    next if $x < $hx || $y < $hy || $z < $hz;
    $hx = $x; $hy = $y; $hz = $z;
    $h = $_;
  }
  return $h;
}

##########################################################################

sub check_module
{
  my $m = shift;# fetch module name
  print "Module $m:\n" if $loglevel>1;

  if($_ !~ /\w\w\w-\w\w\w/)
  {
    print "\tIllegal name - skipping\n" if $loglevel>2;
    return;
  }
  if(/eng-ger|ger-eng|spa-spa/)
  {
    print "\tIllegal module - skipping\n" if $loglevel>2;
    return;
  }

  # for checking status, the module has to be in the working directory
  # already. how to find existing tags without prior working directory?
  if(!-d "$testdir/$m/CVS")
  {    
    my $checkout_this = $checkout_all ? 1 : 0;
    $checkout_this = $checkout_none ? 0 : $checkout_this;
    if($interactive && !$checkout_all && !$checkout_none)
    {
      print "\tModule $m not checked out. Checkout (y/Y/n/N, default n)? ";
      my $answer = <STDIN>;
      if($answer =~ /^y$/) { $checkout_this=1; }
      elsif($answer =~ /^Y$/) { $checkout_all=1; $checkout_this=1; }
      elsif($answer =~ /^N$/) { $checkout_none=1; }
      else { print "assuming 'no'. "; }
    }
      
    if(!$checkout_this) { print "skipping\n" if($loglevel>1); return; }

    print "\tCheckout..." if $loglevel>1;
    my $cvs1 = new Cvs($testdir . "/$m", debug=>0, cvsroot => $cvsroot)
      or die $Cvs::ERROR;
    push @{$cvs1->{args}}, '-z3';
    $cvs1->checkout($m);
    print "\n" if $loglevel>1;
  }
  elsif(!$opt_i)
  {
    print "\tChecking modification date... " if $loglevel>2;
    my @s = stat "$testdir/$m/CVS";
    if(!@s) { warn "stat failed on $testdir/$m/CVS"; return; }
    my $mtime = $s[9];
    #print "mtime=", $mtime, "\n";
    #print "time=", time, "\n";
    #print "\$^T=$^T\n";
    if($mtime > ($^T - 3600*24))
    {
      print "\t'CVS' subdir is less than 24 h old. Skipping module!\n"
        if $loglevel>1;
      return;
    }
  }
 
  if($opt_c)
  {
    print "\tSkipping status check and eventual update\n"
      if $loglevel>1;
    return;
  }

  # XXX for speedup:
  #Cvs::Result::StatusList =
  #               $cvs->status("file1", "file2", {multiple => 1});
		 
  my $cvs1 = new Cvs($testdir . "/$m", debug=>0, cvsroot => $cvsroot)
    or die $Cvs::ERROR;
  push @{$cvs1->{args}}, '-z3';

  #print "working_directory: ", $cvs->working_directory, "\n";
  #mkdir($cvs->working_directory . "/$m");

  my $status = $cvs1->status("$m.tei") or die $Cvs::ERROR;  
  if($status->error)
  {
    print "Error: ", $status->error, ". Skipping module!\n";
    return;
  }

  my $h = "";
  if($status->success)
  {
    print "\tTags: ", join(' ', $status->tags), "\n" if $loglevel>2;
    $h = highest($status->tags);
    print "\tHighest Release Tag: $h\n" if $loglevel>1 && $h;
  }

  if($h ne "")
  {
    my $tr = $status->tag_revision($h);
    my $wr = $status->working_revision;
    if($tr ne $wr)
    {
      print "\tTag revision does not match revision of file in " .
        "working directory.\n";
      print "\ttr<wr: this shouldn't happen! " if($tr < $wr);
      if($tr > $wr)
      {
	print "\tModule needs update: working revision ($wr) < " .
	  "tag revision ($tr)\n";
	# XXX do update to the tagged release
      }
    }
    else
    {
      print "\tWorking revision is consistent with tagged release.\n";
    }

    # check whether that release was already made (released/built)

    # if not made yet
    # build (don't do if we don't trust sources)
    # test
    # inform release manager and maintainer of new release
    # (email if we are run from cron)
  }
  else
  {
    print "\tNo release tagged! Nothing to do for me.\n" if $loglevel>1;
  }
  
  # mark this module as checked
  system 'touch', "$testdir/$m/CVS" || warn "touch: Returned status $?";
}

##########################################################################

sub check_all
{
  print "Getting module list..." if $loglevel>1;
  my $cvs = new Cvs($testdir, cvsroot => $cvsroot,
    # password => '',
     debug => 1
    ) or die $Cvs::ERROR;

  my @modules = $cvs->module_list;
  print $#modules, " modules\n" if $loglevel>1;

  foreach(@modules)
  {
    check_module($_);
  }
}

##########################################################################

our $interactive = 1;
our $loglevel = 2;
# this will be the residence of the release tree - should be parameters :)
our $testdir = $ENV{'FREEDICTDIR'} || '~/freedict';
our $cvsroot = ($ENV{'CVSROOT'} =~ /freedict/) ? $ENV{'CVSROOT'} :
  ':pserver:anonymous@cvs.sourceforge.net:/cvsroot/freedict';

getopts('hnaicv:m:');
$interactive = 0 if $opt_n;
$loglevel = $opt_v if $opt_v;
if($opt_h)
{
  print <<EOT;

This tool checks out and updates a local copy of the FreeDict build tree.
Per default, all CVS modules that were not checked for updates for today
or that were not checked out yet, are checked out.

For checkout the latest revision tagged as releaseable is used, if available.

For checking/remembering the day of the last update, the modification date
of the "CVS" subdirectory of each module is checked/touched.

$0 -h | -a | -m la1-la2 [-v level] [-n] [-i] [-c]
  -a\t\tCheck all modules
  -c\t\tDo `cvs checkout', but no `cvs update'
  -n\t\tNo interactive mode: No automatic checkouts, no questions.
  -v level\tSet debug level (0 = error, 1 = warn, 2 = info, 3 = verbose)
  -i ignore date of last CVS check and check anyway
  
EOT
  exit;
}

if(!$opt_a && !$opt_m)
{
  print "You must give at least one of -a, -m or -h.\n";
  exit;
}
  

check_all() if $opt_a;
check_module($opt_m) if $opt_m;

print "Finished.\n" if $loglevel>1;

