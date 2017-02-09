#!/usr/bin/perl
$file =shift;


open(FILE,"<$file") or die "cannot open file $file\n";


while(<FILE>){
	@line=split(/\t/,$_);
	if(scalar(@line)> 5 && $line[2] ne "\*"  && $_ !~ m/NM:i:1/g){
		$len=length($line[9]);
		if($line[1] eq "256" || $line[1] eq "0"){
			$strand="+";
			$sub="-";
			if($line[5] =~ m/[0-9]S$/){
				$addlength=(split(/S/,$line[5]))[0];
				@addlength=split(/M/,$addlength);
				$sub=substr($line[9],$len-($addlength[1]),$addlength[1]);
			}
			print "$line[2]\th\tread\t$line[3]\t",($line[3]+$len-1),"\t$len\t$strand\t$sub\t$line[5]\n"; 	
		}else{
			$strand="-";
			$sub="-";
			if($line[5] =~ m/^[0-9]S/){
				$addlength=(split(/S/,$line[5]))[0];
				$sub=revComp(substr($line[9],0,$addlength));
			}
			print "$line[2]\th\tread\t$line[3]\t",($line[3]+$len-1),"\t$len\t$strand\t$sub\t$line[5]\n"; 	
		}
		
	}	

}


close(FILE);

sub revComp {
        my $dna = shift;

	# reverse the DNA sequence
        my $revcomp = reverse($dna);

	# complement the reversed DNA sequence
        $revcomp =~ tr/ACGTacgt/TGCAtgca/;
        return $revcomp;
}


