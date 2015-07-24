/*
Steps to test
1) Create a host vector of 1m enteries 
2) Sort histogram host vector 
*/

#include <omp.h>
#include <thrust/device_vector.h>
#include <thrust/host_vector.h>
#include <thrust/random/normal_distribution.h>
#include <thrust/sort.h>
#include <thrust/functional.h>
#include <thrust/sequence.h> 

#define CNT 1000 * 1000 * 150
int main(void) {
  thrust::host_vector<long> hBalance(CNT);
  double beforeStart = omp_get_wtime();
  thrust::sequence(hBalance.begin(),hBalance.end()); 
  double start = omp_get_wtime(); 
  thrust::device_vector<long> dBalance = hBalance; 
  thrust::sort(dBalance.begin(),dBalance.end(),thrust::greater<long>());
  
  double end = omp_get_wtime(); 
  std::cout << dBalance[CNT-100] << "\t" << dBalance[CNT-200] << "\t" <<  dBalance[CNT-300] << std::endl ;
  std::cout<< "Total Time Taken " << beforeStart << "\t"  << start << "\t" << end  << std::endl ; 
}
