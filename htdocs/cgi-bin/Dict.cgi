#!/usr/bin/perl 
#
# Name   : Dict
# Purpose: perl script cgi program to submit dict queries.
# Author : Doug L. Hoffman (hoffman@shopthenet.net)
# Created: Thu Aug 14 09:51:28 1997 by hoffman
# Revised: Mon Mar 30 12:25:38 1998 by hoffman
#
# This perl script both generates the www-browser form and accepts the results
# of submitting the form. The search is transmitted to a central machine
# and the results are interpreted and reposted for the user.
#

# Things adapdet to meet the demands for the things required for the
# freedict project on sourceforge


#  $Log: not supported by cvs2svn $
#  Revision 1.11  1998/03/30 17:33:26  hoffman
#  added text of query to the web page title line.
#
#  Revision 1.10  1998/02/23 17:46:04  hoffman
#  Fixed problem with word list anchors caused by changes to the "exact"
#  resopnse.
#
#  Revision 1.9  1998/02/23 16:41:30  hoffman
#  Made "exact" return list of words, not definitions.
#
#  Revision 1.8  1998/02/20 16:00:01  hoffman
#  gave the generated page(s) a general facelift, changed internal processing
#  to use the short database name, not the description, and then spent time
#  fixing various bugs that the name change caused. The server calls to fetch
#  the search and database options have been combined into one.
#
#  Revision 1.7  1998/02/19 15:10:26  hoffman
#  Rik's updated version.
#
#  Revision 1.6  1997/11/12 16:07:50  hoffman
#  Added link to copyright info.
#
#  Revision 1.5  1997/10/01 17:50:58  hoffman
#  Fixed some of the field edits for Rik.
#
#  Revision 1.4  1997/10/01 13:56:52  hoffman
#  fixed problem with ()'s
#
#  Revision 1.3  1997/08/17 20:48:04  hoffman
#  added link to dict.org home page
#
#  Revision 1.2  1997/08/17 20:07:37  hoffman
#  Fixed imbedded blank sequence query scanning.
#
#

# Setup is minimal.
#
#       You have to redefine at most the first few lines below
#
#       $ReturnUrl is the url of this file. It should be changed to reflect
#               the new location.

# ---------- Configuration variables

$Debug        = 0;

$Pgm          = "Dict";
$hostUrl      = "http://freedict.sourceforge.net";
# $hostUrl      = "";
$cgiPath      = "$hostUrl/cgi-bin";
$ReturnUrl    = "$cgiPath/$Pgm.cgi";
$bin          = "/data/httpd/html/bin";

$CRInfo   = "$ReturnUrl?Form=$Pgm".
    "1&Query=00-database-info&Strategy=*&Database=*";
$SInfo   = "$ReturnUrl?Form=$Pgm". "4";

$Dict    = "/home/groups/freedict/cgi-bin/dict -h 192.168.4.52";
# $Dict = "dict -h localhost";
$Counter = "/home/groups/freedict/cgi-bin/$Pgm.dat";
$Count   = "$cgiPath/Count.cgi";
$Background = "/images/brail.gif";
$Heading1= "FreeDict Wordsearch";
$Heading2= "<a href=\"http://www.freedict.de/\">The FreeDict Project</a>: Online
&nbsp;Dictionary&nbsp;Query";
$Counter1= ""; # <img src=\"$Count?sh=0|df=$Pgm.dat\" alt=\"\">";
$Counter2= ""; # <img src=\"$Count?sh=0|df=total.dat\" alt=\"\">";
# $Counter1= "";
# $Counter2= "";
$WebMaster="<a href=\"mailto:support\@freedict.de\">support\@freedict.de</a>";

# --- display stuff

##########################################################################
#
# Driving Program
#
#########################################################################

&init;                  # init globals
&ReadParse;             # read stdin


#
#
# If there is no standard input, this the the users first request to see
# the page. Return a decent looking page. Otherwise, you have work to do.
#
if ($in{"Form"} eq "") {
    $in{"Database"} = "*";
    $in{"Strategy"} = "*";
    print &PrintHeader();
    &SendBeginning;
    &SendForm1;
    &SendEnding;
}
elsif ($in{"Form"} eq ($Pgm . '1')) {
    print &PrintHeader();
    &SendBeginning;
    &StripFields;               # clean up user entered data.
    &CheckFields;               # Make sure all required data are there.
    &SendForm1;
    if ($Error eq "") {
        &SendListing;
    }
    &SendEnding;
}
elsif ($in{"Form"} eq ($Pgm . '2')) {
    $in{"Strategy"} = "*";
    print &PrintHeader();
    &SendBeginning;
    &StripFields;               # clean up user entered data.
    &CheckFields;               # Make sure all required data are there.
    &SendForm1;
    if ($Error eq "") {
        &SendListing;
    }
    &SendEnding;
}
elsif ($in{"Form"} eq ($Pgm . '3')) {
    $in{"Strategy"} = "";
    $in{"Query"} = "";
    print &PrintHeader();
    &SendBeginning;
    &StripFields;               # clean up user entered data.
#    &CheckFields;              # Make sure all required data are there.
    &SendForm1;
    if ($Error eq "") {
        &SendListing;
    }
    &SendEnding;
}
elsif ($in{"Form"} eq ($Pgm . '4')) {
    $in{"Strategy"} = "";
    $in{"Query"} = "";
    print &PrintHeader();
    &SendBeginning;
    &StripFields;               # clean up user entered data.
#    &CheckFields;              # Make sure all required data are there.
    &SendForm1;
    if ($Error eq "") {
        $in{"Query"} = "Server";
        &SendListing;
    }
    &SendEnding;
}
else {
    print &PrintHeader();
    &SendBeginning;
    print "<br><hr>Error, invalid syntax: $in<hr><br>\n";
    &SendForm1;                 # wtfo? send form anyway.
    &SendEnding;
}       

#############################################################################
#
# --------------- Init global variables 
#

sub init {
    local( $name, $desc);
#
# ----- List of  database and search strategy options
#
# For each option, a comma separated string of the acceptable values
#
    $Choices{"Database"} = "Any,First match";
    
    %Db = ("Any", "*",
           "First match","!"
           );
    
    %Dbr = ("*", "Any",
           "!","First match"
           );
    
    $Choices{"Strategy"} = "Return Definitions";
    
    %St = ("Return Definitions", "*");

    # ----- suck in the database/strategy names from the server

    open(IN,"$Dict -DS |") || die "$Pgm: can't execute /usr/bin/dict\n";
    <IN>;
LOOP: while (<IN>) {
        chop;
        last LOOP if  /^Strategies/;
        $name = substr($_, 2, 10);
        $name =~ s/\s+//g;
        $desc = substr($_, 13);
        $Choices{"Database"} .= ",$desc";
        $Db{$desc} = $name;
        ($Dbr{$name} = $desc) =~ tr/ /+/; # reverse lookup index
    }
    while (<IN>) {
        chop;
        $name = substr($_, 2, 10);
        $name =~ s/\s+//g;
        $desc = substr($_, 13);
        $Choices{"Strategy"} .= ",$desc";
        $St{$desc} = $name;
    }
    close( IN );
#
# The regular expression contraints:
#    
    @Fields = ("Query");
    
    @ReqFields =  ("Query");
}

# ---------- Update the counter
#
sub UpdateCounter {
    local ($count);
    if ($Counter ne "") {
        if (!(open(CT,"<$Counter"))) {
            print "$Pgm: Couldn't open $Counter<p>\n";
            return;
        }
        $count = <CT>;
        close CT;
        $count++;
        if (!(open(CT,">$Counter"))) {
            print "Couldn't write $Counter<p>\n";
            return;
        }
        print CT $count;
        close CT;
    }
}


# ---------- Strip fields
#
# change tabs and stuff to blanks, strip any leading/trailing blanks.
#

sub StripFields {
    foreach $x (@Fields) {
        $in{$x} =~ y/{};/() /;        #  ensure no {, },",", or ";".
        $in{$x} =~ y/\n\r\f\t\e/     /s;  # ensure newlines or cr's.
        $in{$x} =~ s/\'/\'\'/g; 
        $in{$x} =~ s/^\s*//;    
        $in{$x} =~ s/\s*$//;    
        $in{$x} =~ s/\s+/ /g;   
    }
}
#
# ---------- Check that the required fields are all present.
#

sub CheckFields {
    $Error = "";
    foreach $x (@ReqFields) {
        if ($in{$x} eq "") {
            $Error = $x;
            return;
        }
    }
}


#############################################################################
#
# ---------- Send the html form for the editing of a record
#

sub SendForm1 {

# ----- send the header
#
    local($q) = $in{"Query"};
    print <<EOF;
<!-- hidden counter -->
$Counter1
<!-- hidden counter -->
$Counter2

<form method=POST action=$ReturnUrl>
    <input type="hidden" name="Form" value="${Pgm}1">
    <center>
        <table><tr><td align="right">
        <b>Query string:</b></td><td>
        <input type="text" name="Query" size=40 value="$q">
        <br></td></tr><td align="right">
        <b>Search type:</b></td><td align="left">
        <select name="Strategy">
EOF
    foreach $x (split(/,/,$Choices{"Strategy"})) {
        print "        <option value=\"$St{$x}\"";
        if ($in{"Strategy"} eq $St{$x}) {
            print " selected";
        }
        print ">$x\n";
    }
    print <<EOF2;
        </select>
        <br></td></tr><td align="right">
        <b>Database:</b></td><td>
        <select name="Database">
EOF2
    foreach $x (split(/,/,$Choices{"Database"})) { 
        print "        <option value=\"$Db{$x}\"";    
        if ($in{"Database"} eq $Db{$x}) {
            print " selected";
        }
        print ">$x\n";
    }
    print <<EOF3;
        </select>
        </td></tr></table>
        <input type="submit" name="submit" value="Submit query">
        <input type="reset" value="Reset form">
        <p>
        You would like to help with the project?
        Please visit:
            <a href="http://www.freedict.de">FreeDict</a>.
        <br>
        <a href="$CRInfo">Database copyright information</a>
        <br>
        <a href="$SInfo">Server information</a>
    </center>
</form>
<hr>
EOF3
}  


#############################################################################
#
# ---------- Send the html form for the search listing results
#

sub SendListing {
    local( $command, $d, $s, $q);
    local( $i, $x );
    local( $flag=0 );

    # ----- add the hidden counter.

#    print "\n<!-- hidden counter -->\n";
#    print "<img src=\"/bin/Count.cgi?sh=0|df=$Pgm.dat\">\n";
    
    &UpdateCounter;
    
    # ---------- report

    $d = $in{"Database"};
    $d = $in{"Database"} if ($d eq "");
    $s = $in{"Strategy"};
    $q = $in{"Query"};
    $command = "$Dict --client \"$ENV{'REMOTE_HOST'} $ENV{'HTTP_USER_AGENT'}\" "
;
    if ($s eq "" && $q eq "") {
        $command .= "-i '$d'";
    } elsif ($s eq "" && $q eq "Server") {
        $command .= "-I";
    } else {
        $command .= "-d '$d'";
        $wordlist = 0;
        if ($s eq '*') {
            $command .= " \'". $q . "\'";
        }
#       elsif ($s eq 'exact') {
#           $command .= " -s exact \'". $q ."\'";
#       }
        else {
            $command .= " -s $s -m \'". $q ."\'";
        }
    }

    print "$command <p>\n" if ($Debug);

    if (!open(IN,"$command |")) {
        print "<hr><p>\n";
        print "<b>Backend database engine temporarily unavailable:\n";
        print " please try again later</b>\n";
        print "<p><hr>\n";
        return;
    }
    if ($s eq "" && $q eq "") {
        local($tmp) = &lx($Dbr{$d});
        print "<b>From <a href=\"$ReturnUrl?Form=${Pgm}3&Database=$d\">$tmp<\/a>
:</b>\n";
    }
    print "<pre>";
    while(<IN>) {
        ++$flag;
        if (/^From/) {
            if (/\[.*\]/) {
                s/^From\s*(.*)\s*\[(.*)\]\s*:.*$/From <a href=\"$ReturnUrl?Form=
${Pgm}3&Database=$2\">$1<\/a>:/; # " 
            }
            print "</pre><b>$_</b><pre>\n";
        }
        elsif (/^\d+ /) {
            print "</pre><b>$_</b><pre>";
        }
        elsif (/^No definitions/) {
            print "</pre><b>$_</b><pre>\n";
        }
        elsif (/^No matches/) {
            print "</pre><b>$_</b><pre>\n";
        }
        elsif (/^(\S+) /) {
            $x = $1;
            ($x, $line) = split(/:/, $_, 2);
            $line = &anchor( $x, $line);
            print "<b>$x:</b>$line";
            $wordlist = 1;
        }
        elsif ($wordlist && (/^  (\S+) /)) {
            $line = &anchor( $x, $_);
            print $line;
        }
        else {
            if (/(ftp|http):\/\/[^\s\)\}]*\}/) {
                s,((ftp|http)://[^\s\)\}]*)\},}<a href="$1">$1</a>,g;
            } else {
                s,((ftp|http)://[^\s\)\}]*),<a href="$1">$1</a>,g;
            }
            s,(\s){([^}\s][^}]*)},$1.'<a href="'.$ReturnUrl.'?Form='.$Pgm.'2&Dat
abase=*&Query='.&xl($2).'">'.$2.'</a>',ge;
            s,(\s){([^}\s][^}]*)(\n)$,$1.'<a href="'.$ReturnUrl.'?Form='.$Pgm.'2
&Database=*&Query='.&xl($2).'">'.$2.$3,se;
            s,^([^}]*)},$1.'</a>',e;
            print;
        }
    }
    print "</pre>\n";
    close( IN );
    if (!$flag) {
        print "<b>\n";
        print "Backend database engine error: please try again later\n";
        print "</b><p>";
    }
    print "<hr>\n";
}

sub xl { local($tmp) = $_[0]; $tmp =~ tr/ /+/; $tmp; }
sub lx { local($tmp) = $_[0]; $tmp =~ tr/+/ /; $tmp; }

sub anchor {
    local( $dbname, $line) = @_;
    local( $x, $y, $db, $new_line);

    $odd = 1;
    $db = $Dbr{$dbname};
    $db = $dbname;
    foreach $x  (split("\"", $line)) {
        if ($odd) {
            $x =~ s/ (\S+)/ <a href="$ReturnUrl?Form=${Pgm}2&Database=$db&Query=
$1">$1<\/a>/g;
            $new_line .= $x;
            $odd = 0;
        }
        else {
            ($y = $x) =~ tr/ /+/;
            $new_line .= "<a href=\"$ReturnUrl?Form=${Pgm}2&Database=$db&Query='
$y'\">\"$x\"<\/a>";
            $odd = 1;
        }
    }

    return $new_line;
}

#
# ----- Common beginning.
#
sub SendBeginning {
    local ($title);
    
    $title = $Heading1;
    if ($in{'Query'}) {
        $title .= "- $in{'Query'}";
    }
    
    print <<EOF;
<!DOCTYPE HTML PUBLIC "-//IETF//DTD HTML//EN">
<html>
<head>
<title>$title</title>
<META  HTTP-EQUIV="Content-Type" CONTENT="text/html; charset=UTF-8">
</head>
<body background="$Background">
<center>
    <table border=0><tr><td valign="middle">
<img src="/images/freedict.gif" width="200" height="100" border="0" alt="[FreeDict logo]">
</td><td valign="middle">
<font size="+3"><b>$Heading2</b></font>
</td></tr></table>
</center>
<hr size=3>
EOF
}

#
# ----- Common ending.
#
sub SendEnding {

    print <<EOF;
<center>
    <font size="-1">
        Questions or comments about this site?
        Contact $WebMaster
    </font>
</center>
</body>
</html>
EOF
}

# --------------- Numeric sort function

sub bynumber { $a <=> $b; }
  

#############################################################################
#
# --------------- Library Stuff
#

# Perl Routines to Manipulate CGI input
# S.E.Brenner@bioc.cam.ac.uk
# $Header: /data/httpd/html/Internal/bin/RCS/Dict,v 1.11 1998/03/30 17:33:26 hof
fman Exp $ #
# Copyright 1993 Steven E. Brenner  
# Unpublished work.
# Permission granted to use and modify this library so long as the
# copyright above is maintained, modifications are documented, and
# credit is given for any use of the library.

# ReadParse
# Reads in GET or POST data, converts it to unescaped text, and puts
# one key=value in each member of the list "@in"
# Also creates key/value pairs in %in, using '\0' to separate multiple
# selections

# If a variable-glob parameter (e.g., *cgi_input) is passed to ReadParse,
# information is stored there, rather than in $in, @in, and %in.
sub ReadParse {
  if (@_) {
    local (*in) = @_;
  }

  local ($i, $loc, $key, $val);
        local ($fp);
  # Read in text
  if ($ENV{'REQUEST_METHOD'} eq "GET") {
    $in = $ENV{'QUERY_STRING'};
  } elsif ($ENV{'REQUEST_METHOD'} eq "POST") {
    #for ($i = 0; $i < $ENV{'CONTENT_LENGTH'}; $i++) {
    #  $in .= getc;
    #}
        $ntoread = $ENV{'CONTENT_LENGTH'};
        $in = "";
        $n = 60;
        if ($ntoread < $n) {
                $n = $ntoread;
        }
        while ($ntoread) {
                $x = read(STDIN,$inn,$n);
                $in = $in . $inn;
                $ntoread = $ntoread - $x;
                if ($ntoread < $n) {
                        $n = $ntoread;
                }
        }
        #read(STDIN,$in,$ENV{'CONTENT_LENGTH'});
  } 

  @in = split(/&/,$in);

  foreach $i (0 .. $#in) {
    # Convert plus's to spaces
    $in[$i] =~ s/\+/ /g;

    # Convert %XX from hex numbers to alphanumeric
    $in[$i] =~ s/%(..)/pack("c",hex($1))/ge;

    # Split into key and value.
    $loc = index($in[$i],"=");
    $key = substr($in[$i],0,$loc);
    $val = substr($in[$i],$loc+1);
    $in{$key} .= '\0' if (defined($in{$key})); # \0 is the multiple separator
    $in{$key} .= $val;
  }
  return 1; # just for fun
}

# PrintHeader
# Returns the magic line which tells WWW that we're an HTML document

sub PrintHeader {
  return "Content-type: text/html; UTF-8\n\n";
}


