#include <stdio.h>
#include <stdlib.h>

#define THREADS_PER_BLOCK 1024
#define SIZE 5000000
#define LL long long int

__global__ void scan(LL* data,LL* result, unsigned int size) {
  unsigned int  globalIdx = blockIdx.x * blockDim.x + threadIdx.x;
  if(globalIdx < size) { 
    result[globalIdx] = data[globalIdx]; 
  }else {

  }
}

LL* AllocArr(unsigned int size); 
int main(void) {
  LL *iptr,*optr = NULL;
  LL *di_ptr,*do_ptr = NULL;
  unsigned int  size = SIZE;
  unsigned int  memSize = SIZE * sizeof(LL);
  int  result = 0; 
  iptr = AllocArr(size);
  optr = (LL *)malloc(memSize); 
  result = cudaMalloc((void **)&di_ptr,memSize);
  result = cudaMalloc((void **)&do_ptr,memSize); 
  result = cudaMemcpy(di_ptr,iptr,memSize,cudaMemcpyHostToDevice); 
  scan<<<(SIZE + THREADS_PER_BLOCK-1)/THREADS_PER_BLOCK,THREADS_PER_BLOCK>>>(di_ptr,do_ptr,size);
  cudaMemcpy(optr,do_ptr,memSize,cudaMemcpyDeviceToHost); 
  printf("Non computed %lld \nComputed %lld\n",iptr[20],optr[20]);
  free(iptr); 
  free(optr); 
  cudaFree(di_ptr);
  cudaFree(do_ptr); 
  return 1;
}

LL* AllocArr(unsigned int size) {
  LL * ptr = NULL;
  ptr = (LL *)malloc(sizeof(LL)*size);
  unsigned int i = 0;
  for(i = 0; i < size;i++) {
    ptr[i] = 1;
  }
  return ptr;
}


