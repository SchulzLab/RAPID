#!/usr/bin/perl/ -w
use strict;
use warnings;


my $name = shift;
open(FILE,"<$name");
my $block= "";
my $ok = 1;
my $count =1;



while(<FILE>){
        # read in all consecutive 4 lines after the first @
        if($_ =~ m/^@/){
                 $block = $_;
                $block =~ s/^@/>/;
                $block = $block.<FILE>;
                <FILE>;<FILE>;
                print $block;
                
        }else{
                die "wrong input format, not FASTQ \n$_ Terminated at read Fastq conversion step.";
        }

}
