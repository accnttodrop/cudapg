#include "stdio.h"

void generateData(int a,int **b); 

int main() { 
  int count = 100; 
  int* elements; 
  generateData(count,&elements); 
  int sum = 0;
  for(int i = 0;i < count;i++) {
    sum = sum + elements[i];
  }
  printf("Sum %d\n",sum); 
  free(elements);
  return 0;
} 


void generateData(int totalCount,int **ptr) {
  *ptr = NULL; 
  *ptr = (int *) malloc(totalCount * sizeof(int));
  for(int i = 0;i < totalCount; i++) {
    *((*ptr) + i) = i;
  }
  printf("Data generated\n");
}
    
