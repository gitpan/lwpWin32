#! perl -w
# 
#	Perl5 Libwww-perlWin32   Martin.Cleaver@BCS.org.uk    Release 2.1   22/Feb/1997
#								
#			This script may be distributed under the same 
#			terms and conditions as Perl itself.
#
#	Libwww-perl (LWP) is a library of Perl modules that facilitate 
#	easy programming of the WWW. LWP can be found at:
#		http://www.perl.com/cgi-bin/cpan_mod?module=LWP
#	or:	http://www.sn.no/libwww-perl/
#
#	lwpWin32 is a Quick'n'Dirty Script to patch libwww-perl-5 to less 
#	up-to-date platforms.
# 	I see this being useful in two scenarios:
#		1) to use LWP in a Win32 environment
#		2) to use LWP where Perl 5.003 is not available 
#				(this use is untested)
#
#	lwpWin32 has been tested with LWP 5.05 and appears to work fine under
#	5.07. 
#
#	Because Win32 doesn't come with the patch utility, I wrote this 
#	modification as a perl script. (An alternative would be for someone to
#	write a version of patch in perl).
#
#	I developed this for Perl i386-107 from HIP communications. Since then
#	two 5.003 versions have been released, one from Activeware.com and another
#	from Gary Ng. I Gary's version has no modification on the core distribution
#	so that will hopefully become part of the standard distribution. At the 
#	moment I know it works with Activeware's binary distribution, after a couple
#	of modifications have been made by hand to 2 files in \win32app\perl5\lib\*
#
#	I attempted a while ago to port the FTP modules to Win32. I failed and haven't
#	got time to do it properly - if anyone else has succeeded, please let me know. 
#
#	Acknowledgements go to Gisle Aas and others for such a wonderfully useful
#	piece of software.
#
# If anyone knows how to eliminate the warnings or just general improvements
# to this code, I would really like to include them.
#
#	Martin.Cleaver@bcs.org.com	
#
#	Unpack the Perl LWP archive, cd into it and run this script with the version
#       number of perl you want to prepare for, the default is 5.003. It produces
#	a log file 'lwpWin32.log' in the current directory, this shows the search 
#	and replacements made.
#
#		gzip -d libwww-perl-5_00_tar.gz
#		tar xf libwww-perl-5_00_tar
#		cd libwww-perl-5_00
#		perl ../lwpWin32.pl 5.003
#
#	This script patches files from the lib/ and bin/ directories downwards.
#
#	You now have to move the lib directory to where you want to keep it. I keep
#	perl and its libraries under c:\win32app\ as follows:
#
#		c:\win32app\perl5\lib
#		c:\win32app\perl-extra-libs\prod\standard\LWP	# and other libs off CPAN
#
#	Make the perl-extra-libs\prod\standard directory and move the files from libwww-perl-xxx
#	into it. Then call the embedded perllib program as follows:
#		perl lwpWin32.pl perllib prod 
#
#	This will alter the registry to allow the binary to see the new lib files. 
#	
#
#   For 5.003 on Win32:
#		makes lib\auto
#		turns off use of alarms
#		overwrites LWP/IO.pm with a version that doesn't use select
#		invokes AutoSplit on *.pm	(usually a function of Makefile.PL)
#		replace "$pwd = `pwd`" with "use Cwd; $pwd=pwd()"

#   For 5.001:
#	All of the above, plus:
#		removes dependencies on 'use vars' by removing the 'use vars' line 
#		   and replacing every further reference to the variable with a fully
#		   qualified version of the variable.
#		replaces 'require 5.002' with 'require 5.001'
#   
#       If you downgrade to 5.001 and run on 5.003, you may get 
#	warnings when using LWP under strict. These include:
#		Odd number of elements in hash list
#		Global variables being used only once
#
#
#	

#  PROBLEMS and FIXES
#  This version of the script uses 'strict', so it produces some
#  warnings that don't seem to matter. (see below)
#
#   1) General problems on Win32
# 	- extra problem in Windoze 95
#   2) Problems under 5.001
#
# 1) GENERAL PROBLEMS ON Win32:
#
#    1. Killing the use of alarms and select is no substitute for having them implemented.
#
#    2. Autosplit will warn with complaints about writing to closed filehandle <OUT>
#	at (approximately 278). As it happens, the program wants to throw away the
#	data so opens /dev/null - /dev/null does not exist on Win32. Supposedly we
#	should be able to patch perl5/lib/AutoSplit.pm, but even this does not work:
#          open(OUT,">/dev/null") || open(OUT,">nla0:") || open(OUT,">nul:"); 
#							 avoid 'not opened' warning
#       instead of
#          open(OUT,">/dev/null") || open(OUT,">nla0:"); # avoid 'not opened' warning
#
#    3. AutoSplit will warn about line 234 'use of uninitialised variable',
#       this doesn't seem to affect the result.
#
#    4. The pod2htm package at the end of this file is very rough and will produce 
#	lots of warnings if any other problems are found in this script. Ignore the
#	warnings, they are because this script uses 'use strict'.
#
#    PROBLEMS SPECIFIC TO Windoze 95
#
#	1. AutoSplit.pm fails on Windows 95	(We need long filenames)
# 		I try to force a config option that isn't currently set for the Autosplit.
#		For some reason, this fails on a Win95 box, and files with long filenames 
#		get deleted
#		One solution is to edit Autosplit.pm and comment out the line:
#		   $maxflen = 14 if $Config{'d_flexfnam'} ne 'define';	
#
#
#  	2. lines 157 and 220 in Autosplit.pm and
#		  lines 116 in File\path.pm have to be changed from
#	      next if -d "@p/";
# 	   To:
#     	      next if -d "@p";
#
#
#	3. Config.pm has to be edited to tell Win95 about 
#   
# 2) Problems under 5.001:
#   Running an LWP script might crash at some awkward moments with error:
#   'Error: Runtime exception Attempt to free unreferenced scalar during global destruction.'
#   This can be prevented by altering Symbol.pm
#		sub gensym {
# 		   my $name = "GEN" . $genseq++;
#		   local *{$genpkg . $name};
#		   # \delete ${$genpkg}{$name};
#		   \${$genpkg}{$name};		# Memory leak now I presume, but doesn't
#		}				# crash
#
#
# Possible improvements -
#	   could print out list of the files altered (saved as .old files)
#	   binmode should be default or the binmode parameter be required for all platforms.
#		- there may be 'open' statements left in LWP that need fixing up.

require 5.001;
use strict;

if ($#ARGV < 0) {
	print "\nUsage:   $0 perlver\n or:     $0 perllib <args>\n\n";
	print "Instructions can be found at the start of this script!\n";
	exit 1;
}

if ($ARGV[0] eq 'perllib') {
	shift;
	perllib::main(@ARGV);
} else {
    use Config;
    if ($Config::Config{d_flexfnam} ne 'define') {
	# so that Autosplit does not barf on long sub names.
	die lwpWin32::autosplit_message();
    }

    %lwpWin32::done_file = ();
    %lwpWin32::file = (			# These need changing specifically.
       	lwp_protocol_pm 	=> 'lib/LWP/Protocol.pm',
    	lwp_socket_pm 		=> 'lib/LWP/Socket.pm',
    	lwp_useragent_pm 	=> 'lib/LWP/UserAgent.pm',
    #	lwp_mediatypes_pm 	=> 'lib/LWP/MediaTypes.pm',	# Not needed after LWP 5.001
    	lwp_io_pm		=> 'lib/LWP/IO.pm',
    	bin_lwp_mirror_pl	=> 'bin/lwp-mirror.pl',
    	bin_lwp_request_pl	=> 'bin/lwp-request.pl',
    	bin_lwp_rget_pl		=> 'bin/lwp-rget.pl',
   	bin_lwp_download_pl	=> 'bin/lwp-download.pl',
    );

    lwpWin32::main(@ARGV);

    my $var =<<"EOM";

Now you need to create c:/win32app/perl-extra-libs/prod/standard 
and move everything from lib/* to that directory. 
Then run this script again like this:

	perl $0 perllib prod

A simple test of successful installation can be performed by running
	perl bin\lwp-request.pl -m GET http://www.sn.no/libwww-perl/

If you get back a page then you are in business!

Best regards, I hope you find this useful
	Martin Cleaver (Martin.Cleaver\@BCS.org.uk)
EOM
    lwpWin32::report($var);
}

package lwpWin32;



sub main {
    $lwpWin32::for_version = shift;
    if ($lwpWin32::for_version < 5.000) {
	print "First argument must be version of Perl, either 5.001 or 5.003\n";
	exit 1;
    }
    print "Altering LWP for perl version '$lwpWin32::for_version'\n";

    my $file;
    foreach $file (keys %lwpWin32::file) {
      $lwpWin32::done_file{$file} =0;
    }

    my @manifest = read_manifest();
    open_report();
    edit_manifest_files(@manifest);
    edit_lwp_socket_pm();
    edit_lwp_io_pm();
    edit_bin_prog('bin_lwp_mirror_pl');
    edit_bin_prog('bin_lwp_request_pl');
    edit_bin_prog('bin_lwp_rget_pl');
    edit_bin_prog('bin_lwp_download_pl');
    
#    check_home_var();	# Gisle patched this in versions later than LWP 5.01
    close_report();
    
    my @pod_em = (grep /.pm$/, @manifest);		# You could even Pod2htm all your perl5\lib\*.pm files...
#    print "Pod2htm'ing:\n", join("\n", @pod_em),"\n";
    pod2htm::pod2htm(@pod_em);
    
    foreach $file (sort keys %lwpWin32::file) {
        if ($lwpWin32::done_file{$file} != 1) {
    	   report("WARNING  - ".$lwpWin32::file{$file}." edited $lwpWin32::done_file{$file} times\n");
        } else {
    	   report("FIXED UP - ".$lwpWin32::file{$file}." ok\n");
        }
    }

}
exit 0;

# Open each file in the MANIFEST, replacing 5.002 and UNIXisms where necessary.
sub edit_manifest_files {
  my (@manifest) = @_;
  my $file;
  my %replace_vars;
  my $buf;
  my $altered;
  my $package;
  my $line;
  my $copy;
  
  FILE:
  foreach $file (@manifest) {
      report("Searching $file\n"); 
  
      if (! open (FILE, $file)) {
         report("$file - $!\n");
         next FILE;
      }
  
      %replace_vars = ();
      $buf = '';
      $altered = 'no';
      $package = '';
  
      LINE:
      while ($line = <FILE>) {
        $copy = $line;
        $line =~ s/require 5.002/require 5.001/ if ($lwpWin32::for_version < 5.003);
        $line =~ s/(sub [^\{]*?)\(.*?\)/$1/     if ($lwpWin32::for_version < 5.003);
  
        $line =~ s/chomp(\$pwd = `pwd`);/use Cwd; \$pwd = cwd()/;
  
        if ($line =~ m/package (.*);/) {
  	  $package = $1;
        }
  
### Start of 'use vars' hack (for Perl 5.001 only) ###########################
        # Turn all variables mentioned in 'use vars' statements into fully
        # qualified variables inside of the package. Seems to work ok. Needs
        # the $package variable defined.
      if ($lwpWin32::for_version < 5.003) {
        if ($line =~ m/use vars.*/) {
          if ($line !~ m/;$/) {
            while ($line .= <FILE>) {
              last if ($line =~ m/;/);  
            }
          }
          $copy = $line;	# well, multiline
          $line =~ m/use vars *qw\(([\000-\377]*)\);/;	#m/use vars *(.*);/m;
       
       	  my $vars = $1;
       	  my $var_fq;
       	  my $var;
       	  my $sym;
       
  #       report("$file: has a 'use vars' line:\n$line\n\n");
  #  	  report("Line = '$line'\nVars  = '$vars'\n\n");
      
          $line = '';
          $vars =~ s/qw\((.*)\)/$1/m; # the string between ()'s, quoted.
          foreach $var (split(/\s+/, $vars)) {	   # one char followed by a string
           # i.e. the $, %, or @ is the 1 character,
           #          sym        is the variable name.
            (undef,$sym) = unpack("a1a*", $var);
            $replace_vars{$sym} = $package.'::'.$sym;
            report("Replacing $sym => ".$replace_vars{$sym}."\n"); 
            $line .= "$var = undef; # Used at least twice\n"
          }
        } #endif m/use vars/
      
      
        # Replace vars where they occur. Might do a bit more than necessary (ie comments)
        # This has yet to be a problem.
        my $var;
        foreach $var (keys %replace_vars) {	
          $line =~ s/([^\s:])$var/$1$replace_vars{$var}/g;	# not if prefixed with whitespace or ::
        }
      } # end version < 5.003

### End of 'use vars' hack ###########################################

### Start of Socket hack ###########################################
      if ($line =~ m/use Socket(.*)/) {
        MULTILINE:
  	while ($line .= <FILE>) {
  	  last MULTILINE if ($line =~ m/;/);  
  	}

  	$copy = $line;	# well, multiline
  #  	report("$file: has a 'use Socket' line:\n$line\n\n");
  	$line =~ s/pack_sockaddr_in//;
  	$line =~ s/unpack_sockaddr_in//;
  	$line =~ s/inet_ntoa//;
  	$line =~ s/inet_aton//;
      }
  
      if ($line =~ m/Socket->require_version(1.5)/) {
  	   next LINE;		# Version line not defined in distribution,
      }
### End of Socket hack ###############################################  
  
### Start of kill use of Alarms ######################################
      if ($file eq $lwpWin32::file{'lwp_useragent_pm'}) {
  	   if ($line =~ m/'use_alarm'\s*\=\>\s1.*/) {
  	      $line =~ s/1/0/;
  	      report("Disabled alarms by default\n");
	      $lwpWin32::done_file{'lwp_useragent_pm'} ++;
  	   }
      }
### End of kill use of Alarms ########################################
  
### Start of binmode modifications ###################################
  # Binmode should be a required parameter to file open.
  # A Generic version would look like this:
  #      if ($line =~ m/open\s*\(?(\w).*/) {	# This doesn't work, need something 
  #	$filehandle = $1;			# more specific.
  #	if ($line !~ m/;$/) {
  #	  while ($line .= <FILE>) {
  #	    last if ($line =~ m/;/);  
  #	  }
  #	}
  #	$copy = $line;	# well, multiline
  #	$line .= "\nbinmode($filehandle);\n";	# Doesn't hurt to do it more than once :^)
  #     }
  
  # But instead we have a specific version:
        if ($file eq $lwpWin32::file{'lwp_protocol_pm'}) {
    	  if ($line =~ m/open\(OUT/    ) {
   	    if ($line !~ m/;$/) {
  	      while ($line .= <FILE>) {
  	        last if ($line =~ m/;/);  
  	      }
  	    }
	    $copy = $line;	# well, multiline
  	    $line .= "\nbinmode(OUT);\n";	# Doesn't hurt to do it more than once :^)	  
	    $lwpWin32::done_file{'lwp_protocol_pm'} ++;
  	  }
        }
### End of binmode modifications.

        ### report file changes.
        if ($line ne $copy) {
  	  report("$file: altered \n\t'$copy' to \n\t'$line'\n");
  	  $altered = 'yes';
        }
        $buf .= $line;
      } 
      close FILE;

      ### Save file if it changed.
      if ($altered eq 'yes') {
#	report("$buf\n"); next FILE; # DEBUGGING CODE.

  	report("\n\nWriting $file\n");
  	rename $file, $file.'.old' || die "$!";
  	if (!open (FILE, '>'.$file)) {
           report("Can't write $file - $!\n");
           next FILE;
        }
  	print FILE $buf;
  	close FILE;
      }

### And now call autosplit. 
      report("\t\t");
      if ($file =~ m/pm$/) {
	my_autosplit_lib_modules($file);
      } else {
	report("\n");
      }
  
  }
  report("\n");
}

BEGIN {
  my $oW = $^W; $^W = 0;
  require AutoSplit;
  AutoSplit->import();
  $^W = $oW;
}

sub my_autosplit_lib_modules {
  $AutoSplit::Maxlen = 250;	# else we get errors on lib/URI/URL/_generic.pm
  $AutoSplit::Verbose = 2;
  my $oW = $^W; $^W = 0;
  autosplit_lib_modules(@_);
  $^W = $oW;
}

sub autosplit_message {
return <<'EOM';
PROBLEM
-------

You must edit perl5\lib\Config.pm to include the line:
d_flexfnam='define'

This goes in the definition of $config_sh, similar to the line:
prototype='define'

This tells perl that long filenames are usable; this is needed for
Autosplit to work properly.
EOM
}

sub open_report {
  open (REPORT, '>lwpWin32.log');
}

sub report {
  my $what = $_[0];
  print REPORT $what;
  print $what;
}

sub close_report {
  close REPORT;
}

sub read_manifest {
  open (MANIFEST, "MANIFEST") || die "$!";
  my $line;
  my $description;
  my $file;
  my @manifest;
  while ($line = <MANIFEST>) {
    ($file,$description) = split(/\s/,$line);
#    if ($file =~ m!lib/|bin/!) {
	push @manifest, $file;
#    }
  } 
  return @manifest;
}

sub check_home_var {
  if (!defined($ENV{'HOME'})) {
    report "You might want to set the HOME env var so that ".
    	  "$lwpWin32::file{'lwp_mediatypes_pm'} does not complain\n";
  } else {
    $lwpWin32::done_file{'lwp_mediatypes_pm'} ++;
  }
}

sub edit_bin_prog {
  my ($file) = @_;
  my $filename = $lwpWin32::file{$file}; # Yuk!
  if (!open (ORIG, $filename)) {
	report "$file = $filename - $!\n"; return;
  };
  my $line;
  my @prog;
  my $found = 'false';
  while ($line = <ORIG>) {
     if ($line =~ m/print OUT <<'!NO!SUBS!';/) {
        $found = 'true';
	last;
     }
  }
  while ($line = <ORIG>) {
     last if $line =~ m/^!NO!SUBS!/;
     push (@prog, $line);
  }
  close ORIG;
  if ($found ne 'true') {
	report "Eek - couldn't redo #! perl line in $filename\n";
	return;
  }

  open (NEW, '>'.$filename.'.new') || die $!;
  print NEW "#! perl -w\n";
  print NEW "\$DISTNAME = \"$filename-version_lwpwin32\";";
  print NEW @prog;
  close NEW;

  rename $filename.'.new', $filename;
  report "Rewritten $filename\n";
  $lwpWin32::done_file{$file}++;
}

sub edit_lwp_socket_pm {
  my $win32_id = "# \$Id: $lwpWin32::file{'lwp_socket_pm'} - Win32 mrjc \$";

  if (!open (SOCKET_PM, $lwpWin32::file{'lwp_socket_pm'}) ) {
    report "$lwpWin32::file{'lwp_socket_pm'} - $!\n";
    return;
  }
  my @code = <SOCKET_PM>;
  close SOCKET_PM;

  my $found_end='false';
  my $id_line = $code[0];
  chomp($id_line);
  #report "ID line ='$id_line'\nCk line ='$win32_id'\n";
  if ($id_line ne $win32_id) {
    report "Rewriting $lwpWin32::file{'lwp_socket_pm'} ...";
    open (NEW_SOCKET_PM, '>'.$lwpWin32::file{'lwp_socket_pm'}.'.new' ) || die "$!";
    print NEW_SOCKET_PM $win32_id."\n";

    my $found_end = 'false';
    my $line;
    foreach $line (@code) {
	next if ($line =~ m/Socket->require_version/);

        if ($line =~ m/^__END__$/) {
	    print NEW_SOCKET_PM "\n #Begin patch for Win32\n";
	    print NEW_SOCKET_PM win32_code();
	    print NEW_SOCKET_PM "\n#End patch for Win32\n";
	    report "\tfound it!\n";
	    $found_end='true';
	}
	if ($line =~ m/^&chargen;$/) {
	    $line = 'print "This is NT\n"'.";\n";
	    $line .= '#'.$line;
	}
	if ($line =~ m/^&echo;$/) {
	    $line = '#'.$line;
	    $line .= "&http();\n";
	}
        print NEW_SOCKET_PM $line;
    }
    print NEW_SOCKET_PM http_test_code();
    close NEW_SOCKET_PM;

    if ($found_end eq 'true') {
	report "\t$lwpWin32::file{'lwp_socket_pm'} fixed\n"; 
	rename $lwpWin32::file{'lwp_socket_pm'}, $lwpWin32::file{'lwp_socket_pm'}.'.old' || die "$!";
	rename $lwpWin32::file{'lwp_socket_pm'}.'.new', $lwpWin32::file{'lwp_socket_pm'} || die "$!";
	$lwpWin32::done_file{'lwp_socket_pm'} ++;
    } else {
	report "\t$lwpWin32::file{'lwp_socket_pm'} - COULDN'T FIND __END__ token\n";
    }
  } else {
   report "$lwpWin32::file{'lwp_socket_pm'} already done\n";
  }
}

sub edit_lwp_io_pm {
  rename $lwpWin32::file{'lwp_io_pm'}, $lwpWin32::file{'lwp_io_pm'}.'.old';
  if (!open (LWP_IO_PM, '>'.$lwpWin32::file{'lwp_io_pm'})) {report "$lwpWin32::file{'lwp_io_pm'} - $!\n"; return;}
  print LWP_IO_PM lwp_io_code();
  close LWP_IO_PM;
  report "Rewrote $lwpWin32::file{'lwp_io_pm'}\n";
  my_autosplit_lib_modules($lwpWin32::file{'lwp_io_pm'});
  $lwpWin32::done_file{'lwp_io_pm'} ++;
}


# ------------------------------------------------------------------------

sub win32_code {
my $addit = <<'EOM';
BEGIN {
  if (!defined &sockaddr_in) {

     my $nt_compat = <<'EOT';
  
  # Of course, this lot should be added to lib/Socket.pm as supplied from HIP
  sub LWP::Socket::pack_sockaddr_in {
	my ($port, $addr) = @_;
	my (@addr) = unpack('C4', $addr);
	my $pf_inet = 2;				# PF_INET
#	print "$port,". LWP::Socket::inet_ntoa($addr);
	return pack("S n C4 x8", $pf_inet, $port, @addr); 
  }

  sub LWP::Socket::inet_aton {return pack('C4',split(/\./, $_[0]))};
  sub LWP::Socket::inet_ntoa {return join(".", unpack('C4', @_))};
  sub LWP::Socket::unpack_sockaddr_in {print "unpack @_\n"; my ($family, $port, $addr) = unpack('S n C4 x8', @_); return ($port, $addr) }; #  unpack... 

EOT

  eval $nt_compat;

  } # End BEGIN
}
EOM

return $addit;
}


sub lwp_io_code {
my $addit = <<'EOM';
package LWP::IO;

# $Id: IO.pm,v 1.7 1996/04/09 15:44:26 aas Exp $

require LWP::Debug;
use AutoLoader;
@ISA=qw(AutoLoader);

sub read;
sub write;

1;
__END__

=head1 NAME

LWP::IO - Low level I/O capability

=head1 DESCRIPTION

=head2 LWP::IO::read($fd, $data, $size, $offset, $timeout)

=head2 LWP::IO::write($fd, $data, $timeout)

These routines provide low level I/O with timeout capability for the
LWP library.  These routines will only be installed if they are not
already defined.  This fact can be used by programs that need to
override these functions.  Just provide replacement functions before
you require LWP. See also L<LWP::TkIO>.

=cut

sub read
{
    my $fd      = shift;
    # data is now $_[0]
    my $size    = $_[1];
    my $offset  = $_[2] || 0;
    my $timeout = $_[3];

    my $rin = '';
    vec($rin, fileno($fd), 1) = 1;
    my $err = "";   #Thou shall not use Timeouts
    my $nfound = 2; # select($rin, undef, $err = $rin, 0);	# $timeout
#    my $err;
#    my $nfound = select($rin, undef, $err = $rin, $timeout);
    if ($nfound == 0) {
        die "Timeout";
    } elsif ($nfound < 0) {
        die "Select failed: $!";
    } elsif ($err =~ /[^\0]/) {
        die "Exception while reading on socket handle";
    } else {
        my $n = sysread($fd, $_[0], $size, $offset);
        # Since so much data might pass here we cheat about debugging
        if ($LWP::Debug::current_level{'conns'}) {
            LWP::Debug::debug("Read $n bytes");
            LWP::Debug::conns($_[0]) if $n;
        }
        return $n;
    }
}


sub write
{
    my $fd = shift;
    my $timeout = $_[1];  # we don't want to copy data in $_[0]

    my $len = length $_[0];
    my $offset = 0;
    while ($offset < $len) {
        my $win = '';
        vec($win, fileno($fd), 1) = 1;
	my $err = ""; 	 #Thou shall not use Timeouts
	my $nfound = 2 ; #select(undef, $win, $err = $win, $timeout);
#        my $err;
#        my $nfound = select(undef, $win, $err = $win, $timeout);
        if ($nfound == 0) {
            die "Timeout";
        } elsif ($nfound < 0) {
            die "Select failed: $!";
        } elsif ($err =~ /[^\0]/) {
            die "Exception while writing on socket handle";
        } else {
            my $n = syswrite($fd, $_[0], $len-$offset, $offset);
            return $bytes_written unless defined $n;

            if ($LWP::Debug::current_level{'conns'}) {
                LWP::Debug::conns("Write $n bytes: '" .
                                  substr($_[0], $offset, $n) .
                                  "'");
            }
            $offset += $n;
        }
    }
    $offset;
}

1;
EOM
return $addit;
}





sub http_test_code {
my $addit = <<'EOM';

sub http
{
    $socket = new LWP::Socket;
    $socket->connect('www', 80); # http

    select($socket->{'socket'});$|=1;
    select(STDOUT);
    $socket->write("GET /\r\n\r\n");
    $socket->read_until("\n", \$buffer);
    print "$buffer\n";
}
EOM

return $addit;
}


##########################################################################
##########################################################################
##########################################################################
##########################################################################

#################### Copy of perllib.pl off my machine (22feb97)############

# Multiple versions of the Perl libraries on a Win32 machine.
# Functionally equivalent to putting things in site_perl except that you
# can have multiple versions.

package perllib;

use strict;

sub usage {
    print <<'EOM'

Usage:
	perllib standard_lib adhoc_lib override_lib

where standard_lib adhoc_lib override_lib are names of directories in 
directory c:\win32app\perl-extra-libs\ and all default to 'prod'.

typing  perllib  by itself shows current setting.

eg.  perllib prod 		// switch to prod (production) mode
eg.  perllib dev prod dev       // use dev libraries for standard and override

EOM
}

BEGIN {
$main::HKEY_PERFORMANCE_TEXT 	= undef;
$main::HKEY_CURRENT_USER	= undef;
$main::HKEY_CLASSES_ROOT	= undef;
$main::HKEY_USERS		= undef;
$Win32::Registry::pack		= undef;
$Win32::WinError::pack		= undef;
$main::HKEY_LOCAL_MACHINE	= undef;
$main::HKEY_PERFORMANCE_NLSTEXT	= undef;
$main::HKEY_PERFORMANCE_DATA	= undef;
   if ($] < 5.003) {
	require "NT.ph";
	print "old $]\n";
	$perllib::regkey = 'SOFTWARE\Microsoft\Resource Kit\PERL5';
	$perllib::redef = <<END_OF_REDEF;
		sub Win32::RegCreateKeyEx { NTRegCreateKeyEx(@_) };
		sub Win32::RegQueryValueEx { NTRegQueryValueEx(@_) };	
		sub Win32::RegSetValueEx { NTRegSetValueEx(@_) };
		sub Win32::RegCloseKey { NTRegCloseKey(@_) };
END_OF_REDEF
	eval $perllib::redef;
   } else {
	require Win32::Registry;
	Win32::Registry->import();
	$perllib::regkey = 'SOFTWARE\ActiveWare\Perl5';
   }
}

sub NULL {
   return (0);
}

sub main {
    my @argv = @_;
    if ($#argv>-1 && $argv[0] eq '-h') {
       usage();
       exit 0;
    }
    my ($hkey, $disposition, $type, $current_lib);
    Win32::RegCreateKeyEx( &HKEY_LOCAL_MACHINE, $perllib::regkey,
        &NULL, 'NT Perl 5', &REG_OPTION_NON_VOLATILE, &KEY_ALL_ACCESS, &NULL,
        $hkey, $disposition ) ||
        &gripe( "Couldn't add key for Perl 5 to NT Registry Database!!\n" );
    
    if ( $disposition  == &REG_OPENED_EXISTING_KEY ) {
        &gripe( "Key exists...\n" );
    }
    
    Win32::RegQueryValueEx( $hkey, 'PRIVLIB', &NULL, $type, $current_lib );
    
    if ($#argv != -1) {
    
       print "Old PRIVLIB setting:\n".split_lib($current_lib)."\n";
       my $stdlib = $argv[0];
       my $adlib  = $argv[1] || 'prod';
       my $ovlib  = $argv[2] || 'prod';
       my $libdir = 'C:/win32app/perl-extra-libs/'.$ovlib.'/override;'.
                 'C:/win32app/perl5/lib;'.
                 'C:/win32app/perl-extra-libs/'.$adlib.'/adhoc;'.
     	         'C:/win32app/perl-extra-libs/'.$stdlib.'/standard;';
    
       $libdir =~ s(\\)(/);
    
       if (Win32::RegSetValueEx($hkey, 'PRIVLIB', &NULL, &REG_SZ, "$libdir")) {
          report("Adding ".split_lib($libdir)." to library include path information\n");
       } else {
          gripe("Couldn't add library path to registry!!\n");
       }
    
       Win32::RegQueryValueEx($hkey, 'PRIVLIB', &NULL, $type, $current_lib);
    
    }
    
    print "\n\nCurrent PRIVLIB setting:\n".split_lib($current_lib)."\n";
    print "\nType perllib -h for help\n";
    
    Win32::RegCloseKey( $hkey );
}

sub split_lib {
   my ($current_lib) = @_;
   $current_lib =~ s/\;/\n\t/g;
   return "\t".$current_lib;
}

sub report {
    my ($message) = @_;
#    print LOG $message;
    print $message;
}

sub gripe {
    my ($message) = @_;
#    print LOG $message;
    warn $message;
}


##########################################################################
##########################################################################
##########################################################################
##########################################################################

#################### Copy of Pod2htm off my machine (22feb97)############
#
# According to CPAN (http://www.perl.com/perl/CPAN/), the 
# whole Pod:: module suite was under revision at the time of writing.
# In order to give you something that works, I have copied the code into
# this script. Horrible, yes. Works, let's hope so!
#
#
package pod2htm;
$^W = 0;	# Else complains too much!
no strict;

$pod2htm::sawsym = undef;	# stops warnings.
$pod2htm::debug  = undef;
$pod2htm::Headers = undef;

sub pod2htm {
  my @Pods = @_;
  $^W = 0;

  *RS = */;
  *ERRNO = *!;

  use Carp;

  $gensym = 0;

  $A={};

  # The beginning of the url for the anchors to the other sections.
  # Edit $type to suit.  It's configured for relative url's now.
  $type='<A HREF="';		
  $debug = 0;
  @Pods or die "expected pods";

  # loop twice through the pods, first to learn the links, then to produce html
  for $count (0,1){
    (print "Scanning pods...\n") unless $count;
    foreach $podfh ( @Pods ) {
	($pod = $podfh) =~ s/\.pod$//;
	Debug("files", "opening 2 $podfh" );
	(print "Creating $pod.htm from $podfh\n") if $count;
	$RS = "\n=";
	open($podfh,"<".$podfh)  || die "can't open $podfh: $ERRNO";
	@all=<$podfh>;
	close($podfh);
	$RS = "\n";
	$all[0]=~s/^=//;
	for(@all){s/=$//;}
	$Podnames{$pod} = 1;
	$in_list=0;
	$html=$pod.".htm";
	if($count){
	    open(HTML,">$html") || die "can't create $html: $ERRNO";
	    print HTML <<'HTML__EOQ', <<"HTML__EOQQ";
	    <!-- \$RCSfile\$\$Revision\$\$Date\$ -->
	    <!-- \$Log\$ -->
	    <HTML>
HTML__EOQ
	    <TITLE>\U$pod\E</TITLE>
HTML__EOQQ
	}

	for($i=0;$i<=$#all;$i++){

	    $all[$i] =~ /^(\w+)\s*(.*)\n?([^\0]*)$/ ;
	    ($cmd, $title, $rest) = ($1,$2,$3);
	    if ($cmd eq "item") {
		if($count ){
		    ($depth) or do_list("over",$all[$i],\$in_list,\$depth);
		    do_item($title,$rest,$in_list);
		}
		else{
		    # scan item
		    scan_thing("item",$title,$pod);
		}
	    }
	    elsif ($cmd =~ /^head([12])/){
		$num=$1;
		if($count){
		    do_hdr($num,$title,$rest,$depth);
		}
		else{
		    # header scan
		    scan_thing($cmd,$title,$pod); # skip head1
		}
	    }
	    elsif ($cmd =~ /^over/) {
		$count and $depth and do_list("over",$all[$i+1],\$in_list,\$depth);
	    }
	    elsif ($cmd =~ /^back/) {
		if($count){
		    ($depth) or next; # just skip it
		    do_list("back",$all[$i+1],\$in_list,\$depth);
		    do_rest("$title.$rest");
		}
	    }
	    elsif ($cmd =~ /^cut/) {
		next;
	    }
	    elsif($Debug){
		(warn "unrecognized header: $cmd") if $Debug;
	    }
	}
        # close open lists without '=back' stmts
	if($count){
	    while($depth){
		 do_list("back",$all[$i+1],\$in_list,\$depth);
	    }
	    print HTML "\n</HTML>\n";
	}
    }
  }
}
sub do_list{
    my($which,$next_one,$list_type,$depth)=@_;
    my($key);
    if($which eq "over"){
	($next_one =~ /^item\s+(.*)/ ) or (warn "Bad list, $1\n") if $Debug;
	$key=$1;
	if($key =~ /^1\.?/){
	$$list_type = "OL";
	}
	elsif($key =~ /\*\s*$/){
	$$list_type="UL";
	}
	elsif($key =~ /\*?\s*\w/){
	$$list_type="DL";
	}
	else{
	(warn "unknown list type for item $key") if $Debug;
	}
	print HTML qq{\n};
	print HTML qq{<$$list_type>};
	$$depth++;
    }
    elsif($which eq "back"){
	print HTML qq{\n</$$list_type>\n};
	$$depth--;
    }
}

sub do_hdr{
    my($num,$title,$rest,$depth)=@_;
    ($num == 1) and print HTML qq{<p><hr>\n};
    process_thing(\$title,"NAME");
    print HTML qq{\n<H$num> };
    print HTML $title; 
    print HTML qq{</H$num>\n};
    do_rest($rest);
}

sub do_item{
    my($title,$rest,$list_type)=@_;
    process_thing(\$title,"NAME");
    if($list_type eq "DL"){
	print HTML qq{\n<DT><STRONG>\n};
	print HTML $title; 
	print HTML qq{\n</STRONG></DT>\n};
	print HTML qq{<DD>\n};
    }
    else{
	print HTML qq{\n<LI>};
	($list_type ne "OL") && (print HTML $title,"\n");
    }
    do_rest($rest);
    print HTML ($list_type eq "DL" )? qq{</DD>} : qq{</LI>};
}

sub do_rest{
    my($rest)=@_;
    my(@lines,$p,$q,$line,,@paras,$inpre);
    @paras=split(/\n\n+/,$rest);
    for($p=0;$p<=$#paras;$p++){
	@lines=split(/\n/,$paras[$p]);
	if($lines[0] =~ /^\s+\w*\t.*/){  # listing or unordered list
	    print HTML qq{<UL>};
	    foreach $line (@lines){ 
		($line =~ /^\s+(\w*)\t(.*)/) && (($key,$rem) = ($1,$2));
		print HTML defined($Podnames{$key}) ?
		    "<LI>$type$key.htm\">$key<\/A>\t$rem</LI>\n" : 
			"<LI>$line</LI>\n";
	    }
	    print HTML qq{</UL>\n};
	}
	elsif($lines[0] =~ /^\s/){       # preformatted code
	    if($paras[$p] =~/>>|<</){
		print HTML qq{\n<PRE>\n};
		$inpre=1;
	    }
	    else{
		print HTML qq{\n<XMP>\n};
		$inpre=0;
	    }
inner:
	    while(defined($paras[$p])){
	        @lines=split(/\n/,$paras[$p]);
		foreach $q (@lines){
		    if($paras[$p]=~/>>|<</){
			if($inpre){
			    process_thing(\$q,"HTML");
			}
			else {
			    print HTML qq{\n</XMP>\n};
			    print HTML qq{<PRE>\n};
			    $inpre=1;
			    process_thing(\$q,"HTML");
			}
		    }
		    while($q =~  s/\t+/' 'x (length($&) * 8 - length($`) % 8)/e){
			1;
		    }
		    print HTML  $q,"\n";
		}
		last if $paras[$p+1] !~ /^\s/;
		$p++;
	    }
	    print HTML ($inpre==1) ? (qq{\n</PRE>\n}) : (qq{\n</XMP>\n});
	}
	else{                             # other text
	    @lines=split(/\n/,$paras[$p]);
	    foreach $line (@lines){
                process_thing(\$line,"HTML");
		print HTML qq{$line\n};
	    }
	}
	print HTML qq{<p>};
    }
}

sub process_thing{
    my($thing,$htype)=@_;
    pre_escapes($thing);
    find_refs($thing,$htype);
    post_escapes($thing);
}

sub scan_thing{
    my($cmd,$title,$pod)=@_;
    $_=$title;
    s/\n$//;
    s/E<(.*?)>/&$1;/g;
    # remove any formatting information for the headers
    s/[SFCBI]<(.*?)>/$1/g;         
    # the "don't format me" thing
    s/Z<>//g;
    if ($cmd eq "item") {

        if (/^\*/) 	{  return } 	# skip bullets
        if (/^\d+\./) 	{  return } 	# skip numbers
        s/(-[a-z]).*/$1/i;
	trim($_);
        return if defined $A->{$pod}->{"Items"}->{$_};
        $A->{$pod}->{"Items"}->{$_} = gensym($pod, $_);
        $A->{$pod}->{"Items"}->{(split(' ',$_))[0]}=$A->{$pod}->{"Items"}->{$_};
        Debug("items", "item $_");
        if (!/^-\w$/ && /([%\$\@\w]+)/ && $1 ne $_ 
    	    && !defined($A->{$pod}->{"Items"}->{$_}) && ($_ ne $1)) 
        {
    	    $A->{$pod}->{"Items"}->{$1} = $A->{$pod}->{"Items"}->{$_};
    	    Debug("items", "item $1 REF TO $_");
        } 
        if ( m{^(tr|y|s|m|q[qwx])/.*[^/]} ) {
    	    my $pf = $1 . '//';
    	    $pf .= "/" if $1 eq "tr" || $1 eq "y" || $1 eq "s";
    	    if ($pf ne $_) {
    	        $A->{$pod}->{"Items"}->{$pf} = $A->{$pod}->{"Items"}->{$_};
    	        Debug("items", "item $pf REF TO $_");
    	    }
	}
    }
    elsif ($cmd =~ /^head[12]/){                
        return if defined($Headers{$_});
        $A->{$pod}->{"Headers"}->{$_} = gensym($pod, $_);
        Debug("headers", "header $_");
    } 
    else {
        (warn "unrecognized header: $cmd") if $Debug;
    } 
}


sub picrefs { 
    my($char, $bigkey, $lilkey,$htype) = @_;
    my($key,$ref,$podname);
    for $podname ($pod,@inclusions){
	for $ref ( "Items", "Headers" ) {
	    if (defined $A->{$podname}->{$ref}->{$bigkey}) {
		$value = $A->{$podname}->{$ref}->{$key=$bigkey};
		Debug("subs", "bigkey is $bigkey, value is $value\n");
	    } 
	    elsif (defined $A->{$podname}->{$ref}->{$lilkey}) {
		$value = $A->{$podname}->{$ref}->{$key=$lilkey};
		return "" if $lilkey eq '';
		Debug("subs", "lilkey is $lilkey, value is $value\n");
	    } 
	} 
	if (length($key)) {
            ($pod2,$num) = split(/_/,$value,2);
	    if($htype eq "NAME"){  
		return "\n<A NAME=\"".$value."\">\n$bigkey</A>\n"
	    }
	    else{
		return "\n$type$pod2.htm\#".$value."\">$bigkey<\/A>\n";
	    }
	} 
    }
    if ($char =~ /[IF]/) {
	return "<EM>$bigkey</EM>";
    } elsif($char =~ /C/) {
	return "<CODE>$bigkey</CODE>";
    } else {
	return "<STRONG>$bigkey</STRONG>";
    }
} 

sub find_refs { 
    my($thing,$htype)=@_;
    my($orig) = $$thing;
    # LREF: a manpage(3f) we don't know about
    $$thing=~s:L<([a-zA-Z][^\s\/]+)(\([^\)]+\))>:the I<$1>$2 manpage:g;
    $$thing=~s/L<([^>]*)>/lrefs($1,$htype)/ge;
    $$thing=~s/([CIBF])<(\W*?(-?\w*).*?)>/picrefs($1, $2, $3, $htype)/ge;
    $$thing=~s/((\w+)\(\))/picrefs("I", $1, $2,$htype)/ge;
    $$thing=~s/([\$\@%](?!&[gl]t)([\w:]+|\W\b))/varrefs($1,$htype)/ge;
    (($$thing eq $orig) && ($htype eq "NAME")) && 
	($$thing=picrefs("I", $$thing, "", $htype));
}

sub lrefs {
    my($page, $item) = split(m#/#, $_[0], 2);
    my($htype)=$_[1];
    my($podname);
    my($section) = $page =~ /\((.*)\)/;
    my $selfref;
    if ($page =~ /^[A-Z]/ && $item) {
	$selfref++;
	$item = "$page/$item";
	$page = $pod;
    }  elsif (!$item && $page =~ /[^a-z\-]/ && $page !~ /^\$.$/) {
	$selfref++;
	$item = $page;
	$page = $pod;
    } 
    $item =~ s/\(\)$//;
    if (!$item) {
    	if (!defined $section && defined $Podnames{$page}) {
	    return "\n$type$page.htm\">\nthe <EM>$page</EM> manpage<\/A>\n";
	} else {
	    (warn "Bizarre entry $page/$item") if $Debug;
	    return "the <EM>$_[0]</EM>  manpage\n";
	} 
    } 

    if ($item =~ s/"(.*)"/$1/ || ($item =~ /[^\w\/\-]/ && $item !~ /^\$.$/)) {
	$text = "<EM>$item</EM>";
	$ref = "Headers";
    } else {
	$text = "<EM>$item</EM>";
	$ref = "Items";
    } 
    for $podname ($pod, @inclusions){
	undef $value;
	if ($ref eq "Items") {
	    if (defined($value = $A->{$podname}->{$ref}->{$item})) {
		($pod2,$num) = split(/_/,$value,2);
		return (($pod eq $pod2) && ($htype eq "NAME"))
	    	? "\n<A NAME=\"".$value."\">\n$text</A>\n"
	    	: "\n$type$pod2.htm\#".$value."\">$text<\/A>\n";
            }
        } 
	elsif($ref eq "Headers") {
	    if (defined($value = $A->{$podname}->{$ref}->{$item})) {
		($pod2,$num) = split(/_/,$value,2);
		return (($pod eq $pod2) && ($htype eq "NAME")) 
	    	? "\n<A NAME=\"".$value."\">\n$text</A>\n"
	    	: "\n$type$pod2.htm\#".$value."\">$text<\/A>\n";
            }
	}
    }
    (warn "No $ref reference for $item (@_)") if $Debug;
    return $text;
} 

sub varrefs {
    my ($var,$htype) = @_;
    for $podname ($pod,@inclusions){
	if ($value = $A->{$podname}->{"Items"}->{$var}) {
	    ($pod2,$num) = split(/_/,$value,2);
	    Debug("vars", "way cool -- var ref on $var");
	    return (($pod eq $pod2) && ($htype eq "NAME"))  # INHERIT $_, $pod
		? "\n<A NAME=\"".$value."\">\n$var</A>\n"
		: "\n$type$pod2.htm\#".$value."\">$var<\/A>\n";
	}
    }
    Debug( "vars", "bummer, $var not a var");
    return "<STRONG>$var</STRONG>";
} 

sub gensym {
    my ($podname, $key) = @_;
    $key =~ s/\s.*//;
    ($key = lc($key)) =~ tr/a-z/_/cs;
    my $name = "${podname}_${key}_0";
    $name =~ s/__/_/g;
    while ($sawsym{$name}++) {
        $name =~ s/_?(\d+)$/'_' . ($1 + 1)/e;
    }
    return $name;
} 

sub pre_escapes {
    my($thing)=@_;
    $$thing=~s/&/noremap("&amp;")/ge;
    $$thing=~s/<</noremap("&lt;&lt;")/eg;
    $$thing=~s/(?:[^ESIBLCF])</noremap("&lt;")/eg;
    $$thing=~s/E<([^\/][^<>]*)>/\&$1\;/g;              # embedded special
}

sub noremap {
    my $hide = $_[0];
    $hide =~ tr/\000-\177/\200-\377/;
    $hide;
} 

sub post_escapes {
    my($thing)=@_;
    $$thing=~s/[^GM]>>/\&gt\;\&gt\;/g;
    $$thing=~s/([^"MGAE])>/$1\&gt\;/g;
    $$thing=~tr/\200-\377/\000-\177/;
}

sub Debug {
    my $level = shift;
    print STDERR @_,"\n" if $Debug{$level};
} 

sub dumptable  {
    my $t = shift;
    print STDERR "TABLE DUMP $t\n";
    foreach $k (sort keys %$t) {
	printf STDERR "%-20s <%s>\n", $t->{$k}, $k;
    } 
} 
sub trim {
    for (@_) {
        s/^\s+//;
        s/\s\n?$//;
    }
}


