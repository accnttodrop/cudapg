#include <stdio.h>

#define N (2048 * 2048)
#define THREADS_PER_BLOCK 512

__global__ void add(int *a,int *b,int *c,int n) { 
  int index = blockIdx.x * blockDim.x + threadIdx.x;
  if(index < n) {
    c[index] = a[index] + b[index]; 
  }
}

int main(void) {
  int *a,*b,*c; 
  int *d_a,*d_b,*d_c;
  int size = N * sizeof(int);
  cudaMalloc((void **)&d_a,size);
  cudaMalloc((void **)&d_b,size); 
  cudaMalloc((void **)&d_c,size); 
  a = (int *)malloc(size);
  b = (int *)malloc(size); 
  c = (int *)malloc(size); 
  for(int i = 0; i < N;i++) {
    a[i] = i+1;
    b[i] = i+1; 
  }

  cudaMemcpy(d_a,a,size,cudaMemcpyHostToDevice); 
  cudaMemcpy(d_b,b,size,cudaMemcpyHostToDevice); 
  add<<<(N + THREADS_PER_BLOCK-1)/THREADS_PER_BLOCK,THREADS_PER_BLOCK>>>(d_a,d_b,d_c,N);
  cudaMemcpy(c,d_c,size,cudaMemcpyDeviceToHost); 
  printf("Hello world %d\n",c[100]);
  free(a);
  free(b);
  free(c);
  cudaFree(d_a);
  cudaFree(d_b); 
  cudaFree(d_c); 
  return 0;
}
