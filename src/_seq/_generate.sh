awk 'BEGIN { for(i=0;i<200000;i++){ for(j=0;j<200;j++) { n=rand(); if(n<0.25) printf("A"); else if(n<0.5) printf("C"); else if(n<0.75) printf("G"); else printf("T"); } printf("\n"); } }'
