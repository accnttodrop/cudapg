#include <stdio.h>

#define N (2048 * 2048)
#define THREADS_PER_BLOCK 512
#define RADIUS 3


__global__ void add(int *in,int *out,int size) { 
  __shared__ int temp[THREADS_PER_BLOCK + (2*RADIUS)];
  int globalIdx = blockIdx.x * blockDim.x + threadIdx.x;
  int localIdx = threadIdx.x + RADIUS;
  int localSum = 0 ;
  temp[localIdx] = in[globalIdx];
  if(threadIdx.x < RADIUS) {
    if((globalIdx - RADIUS) >= 1) {
      temp[localIdx - RADIUS] = in[globalIdx - RADIUS];
    }else {
      temp[localIdx - RADIUS] = 0;
    }
    if((globalIdx + THREADS_PER_BLOCK) < size) {
    temp[localIdx + THREADS_PER_BLOCK] = in[globalIdx + THREADS_PER_BLOCK];
    }else {
      temp[localIdx + THREADS_PER_BLOCK] = 0;
    }
  }
  __syncthreads();
  for(int i = -RADIUS; i  <= RADIUS; i++) {
    localSum = localSum + temp[threadIdx.x + RADIUS  + i];
  }
  out[globalIdx] = localSum;
  __syncthreads();
} 

int main(void) {
  int *a,*b; 
  int *d_a,*d_b;
  int size = N * sizeof(int);
  cudaMalloc((void **)&d_a,size);
  cudaMalloc((void **)&d_b,size); 
  a = (int *)malloc(size);
  b = (int *)malloc(size); 

  for(int i = 0; i < N;i++) {
    a[i] = 1;
  }

  cudaMemcpy(d_a,a,size,cudaMemcpyHostToDevice); 
  add<<<(N + THREADS_PER_BLOCK-1)/THREADS_PER_BLOCK,THREADS_PER_BLOCK>>>(d_a,d_b,N);
  cudaMemcpy(b,d_b,size,cudaMemcpyDeviceToHost); 
  printf("Hello world %d\n",b[120]);
  free(a);
  free(b);
  cudaFree(d_a);
  cudaFree(d_b); 
  return 0;
}
