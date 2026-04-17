/*
 * restrict_qualifiers.cu
 * 使用 __restrict__ 消除指针别名，允许编译器更激进的优化
 *
 * 关键点：
 * 1. __restrict__ 告诉编译器这些指针不互相重叠（无别名）
 * 2. 编译器可以缓存加载结果、重排指令，通常提升 5~15%
 * 3. 仅在调用者保证指针不重叠时使用，否则结果未定义
 */

#include <cuda_runtime.h>
#include <stdio.h>
#include <stdlib.h>

#define N (1 << 20)

// 使用 __restrict__ 修饰所有输入输出指针
__global__ void vector_add_restrict(
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

    int blockSize = 256;
    int gridSize = (N + blockSize - 1) / blockSize;

    cudaEvent_t start, stop;
    cudaEventCreate(&start);
    cudaEventCreate(&stop);
    cudaEventRecord(start);

    vector_add_restrict<<<gridSize, blockSize>>>(d_a, d_b, d_c, N);

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
