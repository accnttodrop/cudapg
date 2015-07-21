#include <stdio.h>

#define N 256
#define THREADS_PER_BLOCK 256
//Test
#define gpuErrchk(ans) { gpuAssert((ans), __FILE__, __LINE__); }
inline void gpuAssert(cudaError_t code, const char *file, int line, bool abort=true)
{
  if (code != cudaSuccess) 
    {
      fprintf(stderr,"GPUassert: %s %s %d\n", cudaGetErrorString(code), file, line);
      if (abort) exit(code);
    }
}

__global__ void add(double *price,int n) { 
  int index = blockIdx.x * blockDim.x + threadIdx.x;
  __shared__ double returns[256]; 
  //Calculate Log Returns
  double logRt = 0.0;
  if(index == 0) {
    returns[0] = 0.0;
  }else if(index < n) {
    logRt = log(price[index]) - log(price[index-1]);
    returns[index] = logRt; 
  }
  __syncthreads();

  
  //find average of returns
  int idx = 2; 
  int back = 1;
  while(idx <= (n+1)) { 
  if((index+1) % idx == 0) { 
    returns[index] = returns[index] + returns[index-back]; 
  }
  idx = idx * 2;
  back = back * 2;
    __syncthreads(); 
  }
  __syncthreads();

  float ravg = returns[n-1]/n; 
  float rdiffSq = (logRt - ravg) * (logRt - ravg); 
  __syncthreads(); 
  returns[index] = rdiffSq; 
  __syncthreads(); 
  idx = 2; 
  back = 1;
  while(idx <= (n + 1)) { 
  if((index+1) % idx == 0) { 
      returns[index] = returns[index] + returns[index-back]; 
    }
  idx = idx * 2;
  back = back * 2;
    __syncthreads(); 
  }
  __syncthreads();
  if(index == 0) {
    float vol  = returns[n-1]/(n-2);
    float sd = sqrt(vol); 
    printf("SD  %f Volatility   %f\n",sd,vol); 
  }
}
  

int main(void) {
  double *price; 
  double *d_price;
  int size = N * sizeof(double);
  cudaMalloc((void **)&d_price,size);

  price = (double *)malloc(size);

  for(int i = 0; i < N;i++) {
    price[i] = i+1;
  }

  cudaMemcpy(d_price,price,size,cudaMemcpyHostToDevice); 
  add<<<(N + THREADS_PER_BLOCK-1)/THREADS_PER_BLOCK,THREADS_PER_BLOCK>>>(d_price,N);
  gpuErrchk( cudaPeekAtLastError() );
  gpuErrchk( cudaDeviceSynchronize() ); 
  free(price);
  cudaFree(d_price);
  return 0;
}
