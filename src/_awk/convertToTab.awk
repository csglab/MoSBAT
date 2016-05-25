{
	if( NR==1 )
		for( i=2; i<=NF; i++ )
			colname[i]=$i;
	else
		for( i=2; i<=NF; i++ )
			printf("%s\t%s\t%s\n",$1,colname[i],$i);
}

