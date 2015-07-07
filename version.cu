#include <thrust/version.h> 
#include <thrust/host_vector.h> 
#include <thrust/device_vector.h>
#include <thrust/transform.h> 
#include <thrust/sequence.h> 
#include <thrust/functional.h> 
#include <iostream>

#define N 2048

struct saxpy_functor
{
  const float a;

  saxpy_functor(float _a) : a(_a) {}

  __host__ __device__
  float operator()(const float& x, const float& y) const
  { 
    return a * x + y;
  }
};

void transformTest() { 
  float A  = 2.3;
  thrust::device_vector<float> F1(N); 
  thrust::device_vector<float> F2(N); 
  thrust::device_vector<float> F3(N); 
  thrust::host_vector<float>  H1(N);
  thrust::sequence(F1.begin(),F1.end()); 
  thrust::sequence(F2.begin(), F2.end()); 
  thrust::transform(F1.begin(),F1.end(),F2.begin(),F3.begin(),
		    saxpy_functor(A));
  H1 = F3;
  std::cout << "Sample sum value " << H1[24] << std::endl; 
}

void reduceTest() { 
  thrust::device_vector<float> F1(N); 
  float finalSum; 
  thrust::sequence(F1.begin(), F1.end()); 
  finalSum =  thrust::reduce(F1.begin(), F1.end(), (float) 0,  thrust::plus<float>());
  std::cout << "Sample total " << finalSum << std::endl; 
}
    
void largeReduce() { 
  thrust::device_vector<float> F1(N); 
  float finalSum; 
  thrust::generate(F1.begin(),F1.end(),rand);
  finalSum  = thrust::reduce(F1.begin(), F1.end(), -1.0, thrust::maximum<float>());
  std::cout<< "Max Element" << finalSum << std::endl;
}

int main(void) { 
  largeReduce(); 
}
