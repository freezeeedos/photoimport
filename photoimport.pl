#!/usr/bin/perl

use warnings;
use strict;
use Getopt::Std;
use Image::ExifTool qw(:Public);
use File::Find ();
use File::Copy;


use vars qw/*name *dir *prune/;
*name   = *File::Find::name;
*dir    = *File::Find::dir;
*prune  = *File::Find::prune;
our $opt_s;
our $opt_d;
our $opt_q;
our $opt_v;
our $opt_o;
our $opt_e;

getopts('s:d:ovqe:');
sub process;
sub wanted;
sub helpmsg;

if(!$opt_s or !$opt_d){
    helpmsg();
    exit 1;
}

# Traverse desired filesystems
File::Find::find({wanted => \&wanted}, "$opt_s");
exit;


sub process {
    my $file;
    my $date;
    my $year;
    my $info;
    my $dirname;
    
    ($file) = @_;
    if($opt_e)
    {
	$opt_e =~ s/\s/_/g;
    }
    
    for(grep(/^.*\.(jpg|JPG|RAW|RW2)$/, $file))
    {
	if(!$opt_q)
	{
	    print qq{Processing $file...\n};
	}
	$info = ImageInfo(qq{$file}, 'DateTimeOriginal');
	$date = $info->{'DateTimeOriginal'};
	if($date)
	{
	    ( $year ) = $date =~ /^(\d{4})/;
	    if(!$opt_q)
	    {
		print qq{ANNEE: $year\n};
	    }
	    
	    ( $dirname ) = $date =~ /^(.{10})/;
	    $dirname =~ s/:/_/g;
	    if($opt_e)
	    {
		$dirname = qq{$dirname\_$opt_e};
	    }
	    
	    if( ! -d $opt_d )
	    {
		mkdir(qq{$opt_d}, 0755) or die qq{Failure while creating directory $opt_d: $!};
		if($opt_v)
		{
		    print qq{Creating directory $opt_d\n};
		}
	    }
	    if( ! -d qq{$opt_d/$year} )
	    {
		mkdir(qq{$opt_d/$year}, 0755) or die qq{Failure while creating directory $opt_d/$year: $!};
		if($opt_v)
		{
		    print qq{Creating directory $opt_d/$year\n};
		}
	    }
	    if( ! -d qq{$opt_d/$year/$dirname} )
	    {
		mkdir(qq{$opt_d/$year/$dirname}, 0755) or die qq{Failure while creating directory $opt_d/$year/$dirname: $!};
		if($opt_v)
		{
		    print qq{Creating directory $opt_d/$year/$dirname\n};
		}
	    }
	    if( ( ! -f qq{$opt_d/$year/$dirname/$file} ) )
	    {
		copy($file, qq{$opt_d/$year/$dirname/}) or die qq{Failure while copying $file: $!};
	    }
	    else
	    {
		if( $opt_o )
		{
		    copy($file, qq{$opt_d/$year/$dirname/}) or die qq{Failure while copying $file: $!};
		}
	    }
	}
	else
	{
	    if(!$opt_q)
	    {
		print qq{No date found. Nothing to do.\n};
	    }
	}
    }
}

sub wanted {
    my ($dev,$ino,$mode,$nlink,$uid,$gid);

    (($dev,$ino,$mode,$nlink,$uid,$gid) = lstat($_)) &&
    process($name);
}

sub helpmsg(){
    no warnings;
    print qq{Usage:
    
photoimport -s [full path to source directory] -d [full path to destination directory]

 -s    <source_directory>
 -d    <destination_directory>
 -e    "<event>" (e.g: "This awesome party")
 -o    overwrite existing files
 -v    Verbose Mode.
 -q    Quiet Mode.
};
}

__END__