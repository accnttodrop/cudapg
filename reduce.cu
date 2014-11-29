#include "stdio.h"

void generateData(int a,float **b); 

typedef struct {
  int  id;
  int  binId1;
  int  binId2;
  float *price;
    } Security; 

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
      generateData(2048,&sec.price);
      *((*securities + total)) = sec;
    }
  }
}   

int main() { 
  Security *securities;
  generateSecurityData(256,32,&securities);
  return 0;
} 
