/*
 * loop_unrolling.cu
 * 使用 #pragma unroll 展开循环，减少分支判断和循环控制开销
 *
 * 关键点：
 * 1. #pragma unroll N 告诉编译器展开接下来的循环 N 次
 * 2. #pragma unroll（不带数字）让编译器自动决定展开次数
 * 3. 适合循环体小、迭代次数固定（编译期已知）的场景
 * 4. 过度展开会增加寄存器压力，反而降低 occupancy
 */

#include <cuda_runtime.h>
#include <stdio.h>
#include <stdlib.h>

#define N (1 << 20)
#define UNROLL_FACTOR 4

// 手动展开：每个线程处理 UNROLL_FACTOR 个元素
__global__ void vector_add_unrolled(
    const float* __restrict__ a,
    const float* __restrict__ b,
    float* __restrict__ c,
    int n)
{
    int base = (blockIdx.x * blockDim.x + threadIdx.x) * UNROLL_FACTOR;

    // #pragma unroll 展开固定次数的循环
    #pragma unroll
    for (int i = 0; i < UNROLL_FACTOR; i++) {
        int idx = base + i;
        if (idx < n) {
            c[idx] = a[idx] + b[idx];
        }
    }
}

// 也可以用在规约循环中（更常见的用法）
__global__ void reduce_unrolled(const float* __restrict__ input, float* output, int n) {
    __shared__ float sdata[256];
    int tid = threadIdx.x;
    int idx = blockIdx.x * blockDim.x + threadIdx.x;

    sdata[tid] = (idx < n) ? input[idx] : 0.0f;
    __syncthreads();

    // 展开规约循环
    #pragma unroll
    for (int s = blockDim.x / 2; s > 32; s >>= 1) {
        if (tid < s) sdata[tid] += sdata[tid + s];
        __syncthreads();
    }
    // warp 内不需要同步
    if (tid < 32) {
        sdata[tid] += sdata[tid + 32];
        sdata[tid] += sdata[tid + 16];
        sdata[tid] += sdata[tid + 8];
        sdata[tid] += sdata[tid + 4];
        sdata[tid] += sdata[tid + 2];
        sdata[tid] += sdata[tid + 1];
    }
    if (tid == 0) output[blockIdx.x] = sdata[0];
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

    int blockSize = 256;
    int gridSize = (N / UNROLL_FACTOR + blockSize - 1) / blockSize;

    cudaEvent_t start, stop;
    cudaEventCreate(&start);
    cudaEventCreate(&stop);
    cudaEventRecord(start);

    vector_add_unrolled<<<gridSize, blockSize>>>(d_a, d_b, d_c, N);

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
