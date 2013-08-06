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
our $opt_k;
our $opt_v;
our $opt_o;
our $opt_e;

getopts('s:d:ovke:');
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
    my $filename;
    
    ($file) = @_;
    ( $filename ) = $file =~ /(\w+\.\w+)$/;
    if($opt_e)
    {
	$opt_e =~ s/\s/_/g;
    }
    
    for(grep(/^.*\.(jpg|JPG|RAW|RW2)$/, $file))
    {
	
	my ($dev,$ino,$mode,$nlink,$uid,$gid,$rdev,$size,
        $atime,$mtime,$ctime,$blksize,$blocks)
           = stat($file);
	$info = ImageInfo(qq{$file}, 'DateTimeOriginal');
	$date = $info->{'DateTimeOriginal'};
        if(!$date)
        {
            return;
        }
        ( $year ) = $date =~ /^(\d{4})/;
        
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
        
        if( ( ! -f qq{$opt_d/$year/$dirname/$filename} ) )
        {
            if( $opt_v )
            {
                print qq{Copying $file\n};
                print qq{to $opt_d/$year/$dirname/$filename\n};
                print qq{ANNEE: $year\n};
            }
            copy($file, qq{$opt_d/$year/$dirname/}) or die qq{Failure while copying $file: $!};
        }
        else
        {
            if( $opt_o )
            {
                if($opt_v)
                {
                    print qq{overwriting $opt_d/$year/$dirname/$filename\n};
                    print qq{ANNEE: $year\n};
                }
                copy($file, qq{$opt_d/$year/$dirname/}) or die qq{Failure while copying $file: $!};
            }
            else
            {
                my ($dev_d,$ino_d,$mode_d,$nlink_d,$uid_s,$gid_d,$rdev_d,$size_d,
                $atime_d,$mtime_d,$ctime_d,$blksize_d,$blocks_d)
                = stat(qq{$opt_d/$year/$dirname/$filename});
                #Simple "rsync" stuff: compare modification time and size
                if( ( $mtime_d != $mtime ) && ( $size_d != $size ) )
                {
		    if(!$opt_k)
		    {
			if( $opt_v )
			{
			    print qq{Copying new version of $file\n};
			    print qq{to $opt_d/$year/$dirname/$filename\n};
			    print qq{ANNEE: $year\n};
			}
			copy($file, qq{$opt_d/$year/$dirname/}) or die qq{Failure while copying $file: $!};
                    }
                }
                else
                {
		    if( $opt_v )
		    {
			print qq{$opt_d/$year/$dirname/$filename is up-to-date\n};
		    }
                }
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
 -o    overwrite all existing files
 -v    Verbose Mode.
 -k    Keep modified files in their current version.
};
}

__END__
