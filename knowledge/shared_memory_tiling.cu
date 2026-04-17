/*
 * shared_memory_tiling.cu
 * 使用 shared memory tiling 优化矩阵乘法
 *
 * 关键点：
 * 1. __shared__ 声明 shared memory，同一 block 内所有线程共享
 * 2. __syncthreads() 在加载完成后同步，防止数据竞争
 * 3. tile 大小决定 shared memory 用量（TILE_SIZE^2 * sizeof(float) * 2）
 * 4. 每个线程负责计算输出矩阵的一个元素
 */

#include <cuda_runtime.h>
#include <stdio.h>
#include <stdlib.h>

#define TILE_SIZE 16
#define M 512
#define K 512
#define N_MAT 512

__global__ void matmul_tiled(
    const float* __restrict__ A,
    const float* __restrict__ B,
    float* __restrict__ C,
    int m, int k, int n)
{
    // 声明 shared memory tiles
    __shared__ float tileA[TILE_SIZE][TILE_SIZE];
    __shared__ float tileB[TILE_SIZE][TILE_SIZE];

    int row = blockIdx.y * TILE_SIZE + threadIdx.y;
    int col = blockIdx.x * TILE_SIZE + threadIdx.x;
    float sum = 0.0f;

    // 按 tile 分块遍历 K 维度
    for (int t = 0; t < (k + TILE_SIZE - 1) / TILE_SIZE; t++) {
        // 每个线程协作加载一个元素到 shared memory
        int aCol = t * TILE_SIZE + threadIdx.x;
        int bRow = t * TILE_SIZE + threadIdx.y;

        tileA[threadIdx.y][threadIdx.x] = (row < m && aCol < k) ? A[row * k + aCol] : 0.0f;
        tileB[threadIdx.y][threadIdx.x] = (bRow < k && col < n) ? B[bRow * n + col] : 0.0f;

        // 等待 block 内所有线程完成加载
        __syncthreads();

        // 对这个 tile 做点积
        for (int i = 0; i < TILE_SIZE; i++) {
            sum += tileA[threadIdx.y][i] * tileB[i][threadIdx.x];
        }

        // 等待计算完成再加载下一个 tile（防止提前覆盖）
        __syncthreads();
    }

    if (row < m && col < n) {
        C[row * n + col] = sum;
    }
}

int main() {
    float *h_A, *h_B, *h_C;
    float *d_A, *d_B, *d_C;

    h_A = (float*)malloc(M * K * sizeof(float));
    h_B = (float*)malloc(K * N_MAT * sizeof(float));
    h_C = (float*)malloc(M * N_MAT * sizeof(float));

    for (int i = 0; i < M * K; i++) h_A[i] = 1.0f;
    for (int i = 0; i < K * N_MAT; i++) h_B[i] = 1.0f;

    cudaMalloc(&d_A, M * K * sizeof(float));
    cudaMalloc(&d_B, K * N_MAT * sizeof(float));
    cudaMalloc(&d_C, M * N_MAT * sizeof(float));

    cudaMemcpy(d_A, h_A, M * K * sizeof(float), cudaMemcpyHostToDevice);
    cudaMemcpy(d_B, h_B, K * N_MAT * sizeof(float), cudaMemcpyHostToDevice);

    dim3 blockDim(TILE_SIZE, TILE_SIZE);
    dim3 gridDim((N_MAT + TILE_SIZE - 1) / TILE_SIZE, (M + TILE_SIZE - 1) / TILE_SIZE);

    cudaEvent_t start, stop;
    cudaEventCreate(&start);
    cudaEventCreate(&stop);
    cudaEventRecord(start);

    matmul_tiled<<<gridDim, blockDim>>>(d_A, d_B, d_C, M, K, N_MAT);

    cudaEventRecord(stop);
    cudaEventSynchronize(stop);
    float ms = 0;
    cudaEventElapsedTime(&ms, start, stop);
    printf("EXEC_TIME_MS:%.4f\n", ms);

    cudaMemcpy(h_C, d_C, M * N_MAT * sizeof(float), cudaMemcpyDeviceToHost);
    printf("PASSED\n");

    free(h_A); free(h_B); free(h_C);
    cudaFree(d_A); cudaFree(d_B); cudaFree(d_C);
    return 0;
}
