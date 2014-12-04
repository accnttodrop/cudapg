#include "stdlib.h"
#include "stdio.h"
#include "string.h"

typedef struct {
  int  id;
  int  binId1;
  int  binId2;
  float *price;
    } Security; 

typedef struct {
  Security sec;
  float *weight;
  float *bin1Weight;
  float *bin2Weight;
} PortfolioComponent;

typedef PortfolioComponent*  Portfolio;

typedef struct {
  Portfolio portfolio; 
  float *price;
  float *bin1;
  float *bin2; 
} PortfolioData;


const int TotalDays = 2048*128;
const int IndexOffset = 75000;
const float InitialInvestment = 10000;
const int SecurityPerBin = 2048;
const int TotalBin = 1024;

void generateData(int totalCount,float **ptr) {
  *ptr = NULL; 
  *ptr = (float *) malloc(totalCount * sizeof(float));
  for(int i = 0;i < totalCount; i++) {
    *((*ptr) + i) = 2.0+((double)rand()/(double)(RAND_MAX-1))*100;
  }
}

void generateSecurityData(int perBin,int bins,Security **securities) {
  int total = 0;
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


void generateIndexWeights(PortfolioComponent* portfolio,int totalCount){
  float totalValue = 0;
  float* bins = (float *) malloc(TotalBin * sizeof(float));
  memset(bins,0,TotalBin * sizeof(float));
  for(int q = 0; q < totalCount; q++) {
    totalValue +=  portfolio[q].sec.price[0];
    bins[portfolio[q].sec.binId1-1]  += portfolio[q].sec.price[0];
  }
  for(int q = 0; q < totalCount; q++) {
    float weight  = portfolio[q].sec.price[0]/totalValue;
    float binWeight = portfolio[q].sec.price[0]/
      bins[portfolio[q].sec.binId1-1];
    for(int i = 0; i < TotalDays; i++) {
      portfolio[q].weight[i] = weight;
      portfolio[q].bin1Weight[i] = binWeight;
    }

  }
 
}

void generatePortfolioWeights(PortfolioComponent* portfolio,int totalCount) {
  float totalValue = 0;
  float* bins = (float *) malloc(TotalBin * sizeof(float));
  float* securityContribution; 
  generateData(totalCount,&securityContribution); 
  memset(bins,0,TotalBin * sizeof(float));
  for(int q = 0; q < totalCount; q++) {
    totalValue += securityContribution[q];
    bins[portfolio[q].sec.binId1-1]  += securityContribution[q];
  }
  for(int q = 0; q < totalCount; q++) {
    float weight  = securityContribution[q]/totalValue;
    float binWeight = securityContribution[q]/
      bins[portfolio[q].sec.binId1-1];
    for(int i = 0; i < TotalDays; i++) {
      portfolio[q].weight[i] = weight;
      portfolio[q].bin1Weight[i] = binWeight;
    }

  }
 
}

void generatePortfolio(Security *securities,int totalCount
		       ,PortfolioComponent **portfolio) {
  *portfolio = NULL;
  *portfolio = (PortfolioComponent *) malloc(totalCount * sizeof(PortfolioComponent));
  size_t daysSize = TotalDays * sizeof(float);
  for(int q = 0; q < totalCount; q++) {
    PortfolioComponent component;
    component.sec = securities[q];
    component.weight = (float *) malloc(daysSize);
    component.bin1Weight = (float *) malloc(daysSize);
    component.bin2Weight = (float *) malloc(daysSize);
    memset(component.weight,0,daysSize); 
    memset(component.bin1Weight,0,daysSize); 
    memset(component.bin2Weight,0,daysSize); 
    *((*portfolio + q)) = component;
  }
}

PortfolioData* calculatePortfolioData( Portfolio components,
			    int totalCount) {
  PortfolioData* portfolio = (PortfolioData*) malloc(sizeof(PortfolioData));
  portfolio->portfolio = components;
  portfolio->price = (float *) malloc(totalCount * sizeof(float)); 
  portfolio->bin1  = (float *) malloc(totalCount * sizeof(float)); 
  portfolio->bin2  = (float *) malloc(totalCount * sizeof(float)); 
  for(int i = 0; i < totalCount; i++){
    portfolio->bin1[i] = 0;
    portfolio->bin2[i] = 0;
    portfolio->price[i] = 0;
  }
  return portfolio;
}

static void test(Portfolio index,int totalCount) {
  float w = 0;
  float binw[TotalBin];
  memset(binw,0,TotalBin * sizeof(float)); 
  for(int q = 0 ; q < totalCount; q++) {
    printf("\nWeight for %d security is %f and %d bin weight is %f",
	   index[q].sec.id,
    	   index[q].weight[0],index[q].sec.binId1,
	   index[q].bin1Weight[0]);
    w += index[q].weight[0];
    binw[index[q].sec.binId1-1] += index[q].bin1Weight[0];
  } 
  printf("\nTotal Weight %f",w);
  for(int i = 0; i < TotalBin; i++) {
    printf("\nBin %d Weight %f",i+1,binw[i]);
  }

}


int main() { 
  Security *securities;
  generateSecurityData(SecurityPerBin,TotalBin,&securities);
  Portfolio index;
  int totalCount = SecurityPerBin * TotalBin;
  generatePortfolio(securities,totalCount,&index);
  generateIndexWeights(index,totalCount); 

  Portfolio portfolio;
  generatePortfolio(securities,totalCount,&portfolio); 
  generatePortfolioWeights(portfolio,totalCount); 

  PortfolioData* idx = calculatePortfolioData(index,totalCount);
  PortfolioData* port = calculatePortfolioData(portfolio,totalCount);

  printf("\n");
  return 0;
} 
