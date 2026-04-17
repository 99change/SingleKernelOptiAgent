/*
 * occupancy_tuning.cu
 * 通过调整 block size 和寄存器使用来提升 occupancy
 *
 * 关键点：
 * 1. occupancy = 活跃 warp 数 / SM 最大 warp 数
 * 2. block size 通常选 128、256、512（32 的倍数，即整数个 warp）
 * 3. __launch_bounds__(MAX_THREADS, MIN_BLOCKS) 限制寄存器用量，提升 occupancy
 * 4. cudaOccupancyMaxPotentialBlockSize 可以自动选最优 block size
 */

#include <cuda_runtime.h>
#include <stdio.h>
#include <stdlib.h>

#define N (1 << 20)

// __launch_bounds__ 限制每个线程最多使用的寄存器数
// MAX_THREADS_PER_BLOCK=256, MIN_BLOCKS_PER_SM=4
// 这样每个 SM 至少可以调度 4 个 block，提升 occupancy
__global__ __launch_bounds__(256, 4)
void vector_add_tuned(
    const float* __restrict__ a,
    const float* __restrict__ b,
    float* __restrict__ c,
    int n)
{
    int idx = blockIdx.x * blockDim.x + threadIdx.x;
    if (idx < n) {
        c[idx] = a[idx] + b[idx];
    }
}

int main() {
    float *h_a, *h_b, *h_c;
    float *d_a, *d_b, *d_c;
    size_t size = N * sizeof(float);

    h_a = (float*)malloc(size);
    h_b = (float*)malloc(size);
    h_c = (float*)malloc(size);

    for (int i = 0; i < N; i++) {
        h_a[i] = (float)i;
        h_b[i] = (float)(i * 2);
    }

    cudaMalloc(&d_a, size);
    cudaMalloc(&d_b, size);
    cudaMalloc(&d_c, size);

    cudaMemcpy(d_a, h_a, size, cudaMemcpyHostToDevice);
    cudaMemcpy(d_b, h_b, size, cudaMemcpyHostToDevice);

    // 使用 CUDA API 自动选最优 block size
    int blockSize = 0;
    int minGridSize = 0;
    cudaOccupancyMaxPotentialBlockSize(&minGridSize, &blockSize, vector_add_tuned, 0, 0);
    int gridSize = (N + blockSize - 1) / blockSize;

    printf("Auto-selected blockSize=%d, gridSize=%d\n", blockSize, gridSize);

    cudaEvent_t start, stop;
    cudaEventCreate(&start);
    cudaEventCreate(&stop);
    cudaEventRecord(start);

    vector_add_tuned<<<gridSize, blockSize>>>(d_a, d_b, d_c, N);

    cudaEventRecord(stop);
    cudaEventSynchronize(stop);
    float ms = 0;
    cudaEventElapsedTime(&ms, start, stop);
    printf("EXEC_TIME_MS:%.4f\n", ms);

    cudaMemcpy(h_c, d_c, size, cudaMemcpyDeviceToHost);

    for (int i = 0; i < N; i++) {
        if (h_c[i] != h_a[i] + h_b[i]) {
            printf("MISMATCH at %d\n", i);
            return 1;
        }
    }
    printf("PASSED\n");

    free(h_a); free(h_b); free(h_c);
    cudaFree(d_a); cudaFree(d_b); cudaFree(d_c);
    return 0;
}
