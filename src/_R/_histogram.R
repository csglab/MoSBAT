#  Copyright 2015 Hamed S. Najafabadi
#  
#  ********************************************************************
#  
#  This file is part of MoSBAT package.
#  
#  MoSBAT is free software: you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation, either version 3 of the License, or
#  (at your option) any later version.
#  
#  MoSBAT is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#  
#  You should have received a copy of the GNU General Public License
#  along with MoSBAT.  If not, see <http://www.gnu.org/licenses/>.
#  
#  ********************************************************************/

args <- commandArgs(trailingOnly = TRUE)

############### read affinities and write correlations

set1 <- read.csv(paste("./out/",args[1],"/results.set1.position.txt",sep=""),sep="\t")
set2 <- read.csv(paste("./out/",args[1],"/results.set2.position.txt",sep=""),sep="\t")
tophits <- read.csv(paste("./tmp/",args[1],"/tophits.",args[2],".tab",sep=""),sep="\t",header=F)

n <- nrow(tophits)

for( i in 1:n )
{
	index1 <- which( colnames(set1) == tophits[i,1] )
	index2 <- which( colnames(set2) == tophits[i,2] )
	
	filter <- ( sign( set1[,index1] ) == sign( set2[,index2] ) )
	forward <- set2[filter,index2] - set1[filter,index1]
	reverse <- -set2[!filter,index2] - set1[!filter,index1]
	all <- c(forward,reverse)
	
	maxy <- max(hist(all,breaks=seq(min(all)-0.5,max(all)+0.5,by=1),plot=F)$count)
		
	jpeg(file=paste("./out/",args[1],"/results.",args[2],".",i,".position.histogram.jpg",sep=""),width=600,height=100)
	par(mfrow=c(1,2),mar=c(2,2,1,1))

	if( sum(filter)>0 )
		hist(forward,breaks=seq(min(forward)-0.5,max(forward)+0.5,by=1),xlim=c(-20,20),ylim=c(0,maxy),freq=T,main="",col=rgb(1,0,0))
	else
		hist(1000,breaks=c(999,1001),xlim=c(-20,20),ylim=c(0,maxy),freq=T,main="",col=rgb(1,0,0))

	if( sum(!filter)>0 )
		hist(reverse,breaks=seq(min(reverse)-0.5,max(reverse)+0.5,by=1),xlim=c(-20,20),ylim=c(0,maxy),freq=T,main="",ylab="",col=rgb(0,0,1))
	else
		hist(1000,breaks=c(999,1001),xlim=c(-20,20),ylim=c(0,maxy),freq=T,main="",ylab="",col=rgb(0,0,1))

	dev.off()
}
