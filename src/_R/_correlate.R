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

library(gplots)
maxheatmap=10

args <- commandArgs(trailingOnly = TRUE)

############### read affinities and write correlations

set1 <- read.csv(paste("./out/",args[1],"/results.set1.",args[2],".txt",sep=""),sep="\t")
set2 <- read.csv(paste("./out/",args[1],"/results.set2.",args[2],".txt",sep=""),sep="\t")

n1 <- ncol(set1)
n2 <- ncol(set2)
m <- cor(as.matrix(set1[,2:n1]),as.matrix(set2[,2:n2]))
rownames(m) <- colnames(set1)[2:n1]
colnames(m) <- colnames(set2)[2:n2]
write.table(m,paste("./out/",args[1],"/results.",args[2],".correl.txt",sep=""),sep="\t",quote=F,append=T)

if( n1>2 & n2>2 )
{
	rowmax <- apply(m,1,max)
	colmax <- apply(m,2,max)
	m <- m[ order(rowmax,decreasing=T), order(colmax,decreasing=T)]
	width  <- min(maxheatmap,n2-1) * 36.9 + 231
	height <- min(maxheatmap,n1-1) * 36.9 + 231
	jpeg(file=paste("./out/",args[1],"/results.",args[2],".correl.heatmap.jpg",sep=""),width=width,height=height)
	heatmap.2( 1-m[ 1:min(maxheatmap,n1-1), 1:min(maxheatmap,n2-1) ], notecol="black", cellnote=formatC(m[ 1:min(maxheatmap,n1-1), 1:min(maxheatmap,n2-1) ],digits=2,format="f"), margins=c(10,10), trace="none", key=F, revC=T,breaks=seq(0,2,length.out=256),col=colorRampPalette(c("red","white","blue"))(255),cexRow=1.2,cexCol=1.2,lmat=rbind(4:3,2:1),lwid=c(3,min(maxheatmap,n2-1)+3.15),lhei=c(3,min(maxheatmap,n1-1)+3.15))
	dev.off()
}
