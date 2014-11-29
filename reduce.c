#include "stdlib.h"
#include "stdio.h"

typedef struct {
  int  id;
  int  binId1;
  int  binId2;
  float *price;
    } Security; 
const int TotalDays = 2048;
const int IndexOffset = 75000;

void generateData(int totalCount,float **ptr) {
  *ptr = NULL; 
  *ptr = (float *) malloc(totalCount * sizeof(float));
  for(int i = 0;i < totalCount; i++) {
    *((*ptr) + i) = 20.0+((double)rand()/(double)(RAND_MAX-1))*100;
  }
}

void generateSecurityData(int perBin,int bins,Security **securities) {
  int total = 1;
  *securities = NULL;
  *securities = (Security *)malloc(perBin*bins*sizeof(Security));
  for(int i =0;i < bins; i++) {
    for(int q = 0; q < perBin; q++) {
      Security sec;
      sec.id = total+1;
      sec.binId1 = (i+1); 
      generateData(TotalDays,&sec.price);
      *((*securities + total)) = sec;
      total++;
    }
  }
}   

Security generateIndex(Security *securities,int totalCount) {
  Security index;
  index.id = IndexOffset;
  index.binId1 = -1;
  index.price = (float *) malloc(TotalDays * sizeof(float));
  for(int i = 0; i < TotalDays; i++) {

  }
  return index;
}

int main() { 
  Security *securities;
  generateSecurityData(256,32,&securities);
  printf("Securities Generated"); 
  Security idx =  generateIndex(securities,256*32); 
  printf("\nIndex Generated. Id %f\n",idx.price[3]);
  return 0;
} 
