$file =shift;


open(FILE,"<$file") or die "cannot open file $file\n";


#HISEQ_7001355:57:D28TDACXX:3:1101:10490:2600    16      scaffold_110    58383   255     1S23M   *
#       0       0       AGTTCCAAATAGTCCATTTATGGG        IIIHHGEHEGDHHHHFFFFFCCAA        AS:i:46 XN:i:0  XM:i:0  XO:i:0  XG:i:0  NM:i:0  MD:Z:23 YT:Z:UU

#awk 'BEGIN{OFS="\t"}{ if($1 !~ /^@/ && $3 !~ "*"){if($2 =="0" || $2 == "272"){strand="+"}else{st    rand="-"};SUB="-";len=length($10);if($6 ~ /^[0-9]S/){split($6,W,/S/);SUB=substr($10,1,W[1])};if(    $6 ~ /[0-9]S$/){split($6,w,/M/);split(w[2],W,/S/);SUB=substr($10,(len-W[1]+1),W[1])};print $3,"h    ","read",$4,$4+(len-1),len,strand,SUB,$6}}' $file

while(<FILE>){
	@line=split(/\t/,$_);
	if(scalar(@line)> 5 && $line[2] ne "\*"  && $_ !~ m/NM:i:1/g){
		$len=length($line[9]);
		if($line[1] eq "256" || $line[1] eq "0"){
			$strand="+";
			$sub="-";
			if($line[5] =~ m/[0-9]S$/){
				#22M1S
				$addlength=(split(/S/,$line[5]))[0];
				@addlength=split(/M/,$addlength);
				$sub=substr($line[9],$len-($addlength[1]),$addlength[1]);
			}
			print "$line[2]\th\tread\t$line[3]\t",($line[3]+$len-1),"\t$len\t$strand\t$sub\t$line[5]\n"; 	
		}else{
			$strand="-";
			$sub="-";
			if($line[5] =~ m/^[0-9]S/){
				#1S23M
				$addlength=(split(/S/,$line[5]))[0];
				#@addlength=split(/M/,$addlength);
				$sub=revComp(substr($line[9],0,$addlength));
				# print "add length: $addlength[1] $addlength[0] $sub \n"; 	
			}
			print "$line[2]\th\tread\t$line[3]\t",($line[3]+$len-1),"\t$len\t$strand\t$sub\t$line[5]\n"; 	
		}
		
		#we found a SAM line
	#	print $_;
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
