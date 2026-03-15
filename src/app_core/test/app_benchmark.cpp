#include <benchmark/benchmark.h>
// #include <benchmark/state.h>

#include <cstdio>
#include <vector>
#include <cstdlib>

// double std::rand() {
//     return 0.0;
// }

struct FVector2D
{
    std::string X;
    std::string Y;

    FVector2D() = default;
    template <typename T>
    FVector2D(T InX, T InY): X(InX), Y(InY) {}
    FVector2D(const FVector2D& Other) = default;
    FVector2D(FVector2D&& Other) = default;
    FVector2D& operator=(const FVector2D& Other) = default;
    FVector2D& operator=(FVector2D&& Other) = default;
};

FVector2D Calculation0()
{
  FVector2D Value = {"a", "a"};
  return Value;
}

void Calculation1(FVector2D& OutResult)
{
  OutResult = {"a", "a"};
}

static void B0(benchmark::State& state)
{
  for (auto _ : state) {
    for(uint64_t i = 0; i <1000000; ++i){
        FVector2D Result = Calculation0();
        benchmark::DoNotOptimize(Result);
    }
  }
}

static void B1(benchmark::State& state)
{
  for (auto _ : state) {
    for(uint64_t i =0; i <1000000; ++i){
        FVector2D Result;
        Calculation1(Result);
        benchmark::DoNotOptimize(Result);
    }
  }
}

BENCHMARK(B0)->Name("FVectorBench00");
BENCHMARK(B0)->Name("FVectorBench01");
BENCHMARK(B0)->Name("FVectorBench02");
BENCHMARK(B0)->Name("FVectorBench03");
BENCHMARK(B0)->Name("FVectorBench04");

// BENCHMARK(Nope)->Name("Nope");

BENCHMARK(B1)->Name("FVectorBench10");
BENCHMARK(B1)->Name("FVectorBench11");
BENCHMARK(B1)->Name("FVectorBench12");
BENCHMARK(B1)->Name("FVectorBench13");
BENCHMARK(B1)->Name("FVectorBench14");
