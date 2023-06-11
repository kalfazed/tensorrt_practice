#include <cuda_runtime.h>
#include <stdio.h>


__global__ void print_idx_kernel(){
  printf("block idx: (%3d, %3d, %3d), thread idx: (%3d, %3d, %3d)\n",
         blockIdx.z, blockIdx.y, blockIdx.x,
         threadIdx.z, threadIdx.y, threadIdx.x);
}

__global__ void print_dim_kernel(){
  printf("grid dimension: (%3d, %3d, %3d), thread dimension: (%3d, %3d, %3d)\n",
         gridDim.z, gridDim.y, gridDim.x,
         blockDim.z, blockDim.y, blockDim.x);
}

__global__ void print_thread_idx_per_block_kernel(){
  int index = threadIdx.z * blockDim.x * blockDim.y + \
              threadIdx.y * blockDim.x + \
              threadIdx.x;

  printf("block idx: (%3d, %3d, %3d), thread idx: %3d\n",
         blockIdx.z, blockIdx.y, blockIdx.x,
         index);
}

__global__ void print_thread_idx_kernel(){
  int bSize  = blockDim.z * blockDim.y * blockDim.x;

  int bIndex = blockIdx.z * gridDim.x * gridDim.y + \
               blockIdx.y * gridDim.x + \
               blockIdx.x;

  int tIndex = threadIdx.z * blockDim.x * blockDim.y + \
               threadIdx.y * blockDim.x + \
               threadIdx.x;

  int index  = bIndex * bSize + tIndex;

  printf("block idx: %3d, thread idx in block: %3d, thread idx: %3d\n", 
         bIndex, tIndex, index);
}

void print_one_dim(){
  int inputSize = 32;

  int blockDim = 4;
  int gridDim = inputSize / blockDim;

  dim3 block(blockDim);
  dim3 grid(gridDim);

  print_idx_kernel<<<grid, block>>>();
  print_dim_kernel<<<grid, block>>>();
  print_thread_idx_per_block_kernel<<<grid, block>>>();
  print_thread_idx_kernel<<<grid, block>>>();

  cudaDeviceSynchronize();
}

void print_two_dim(){
  int inputWidth = 8;

  int blockDim = 2;
  int gridDim = inputWidth / blockDim;

  dim3 block(blockDim, blockDim);
  dim3 grid(gridDim, gridDim);

  print_idx_kernel<<<grid, block>>>();
  // print_dim_kernel<<<grid, block>>>();
  // print_thread_idx_per_block_kernel<<<grid, block>>>();
  // print_thread_idx_kernel<<<grid, block>>>();

  cudaDeviceSynchronize();
}

int main() {
  /*
    synchronize是同步的意思，有几种synchronize

    cudaDeviceSynchronize: cpu端停止执行，知道gpu端完成这个语句以前的所有cuda操作
    cudaStreamSynchronize: 跟cudaDeviceSynchronize很像，但是这个是针对某一个stream的。只同步指定的stream中的cpu/gpu操作，其他的不管
    cudaThreadSynchronize: 现在已经不被推荐使用的方法
    __syncthreads:         线程块内同步
  */
  // print_one_dim();
  print_two_dim();
  return 0;
}
