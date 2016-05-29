{
	if( NF==2 )
	{
		url[$2]=$1
		n[$2]=1;
	}
	else
	{
		count++;
		printf("<tr>\n");
		if( n[$1]==1 )
			printf("<td><a href=\"%s\" target=\"_blank\">%s</a></td>\n",url[$1],$1);
		else
			printf("<td>%s</td>\n",$1);
		if( n[$2]==1 )
			printf("<td><a href=\"%s\" target=\"_blank\">%s</a></td>\n",url[$2],$2);
		else
			printf("<td>%s</td>\n",$2);
		printf("<td>%0.2f</td>\n",$3);
		if(count<=100)
			printf("<td><a href=\"hist/results.%s.%i.position.histogram.jpg\" target=\"_blank\"><img src=\"hist/results.%s.%i.position.histogram.jpg\" alt=\"Alignment offset histogram\" style=\"width:330px;height:55px;\"></a></td>\n",type,count,type,count);
		else
			printf("<td></td>\n");
		printf("</tr>\n");
	}
}
