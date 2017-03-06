#include <cstdio>

#define gpuErrchk(ans)                                                         \
  { gpuAssert((ans), __FILE__, __LINE__); }
inline void gpuAssert(cudaError_t code, const char *file, int line,
                      bool abort = true) {
  if (code != cudaSuccess) {
    fprintf(stderr, "GPUassert: %s %s %d\n", cudaGetErrorString(code), file,
            line);
    if (abort)
      exit(code);
  }
}

__global__ void kernel(int a) {
  (void)a;
  __syncthreads();
}

int main(int argc, char **argv) {
  int deviceCount;

  gpuErrchk(cudaGetDeviceCount(&deviceCount));
  printf("Detected %d devices\n", deviceCount);

  for (int dev = 0; dev < deviceCount; dev++) {
    cudaDeviceProp deviceProp;

    cudaGetDeviceProperties(&deviceProp, dev);

    if (dev == 0) {
      if (deviceProp.major == 9999 && deviceProp.minor == 9999) {
        printf("No CUDA GPU has been detected.\n");
        return EXIT_FAILURE;
      } else {
        printf("There are %d device(s) supporting CUDA\n", deviceCount);
      }
    }

    printf("Device %d name: %s\n", dev, deviceProp.name);
    printf("  Computational Capabilities: %d.%d\n", deviceProp.major,
           deviceProp.minor);
    printf("  Maximum global memory size: %lu\n", deviceProp.totalGlobalMem);
    printf("  Maximum constant memory size: %lu\n", deviceProp.totalConstMem);
    printf("  Maximum shared memory size per block: %lu\n",
           deviceProp.sharedMemPerBlock);
    printf("  Maximum block dimensions: %d x %d x %d\n",
           deviceProp.maxThreadsDim[0], deviceProp.maxThreadsDim[1],
           deviceProp.maxThreadsDim[2]);
    printf("  Maximum grid dimensions: %d x %d x %d\n",
           deviceProp.maxGridSize[0], deviceProp.maxGridSize[1],
           deviceProp.maxGridSize[2]);
    printf("  Warp size: %d\n", deviceProp.warpSize);

    cudaSetDevice(dev);
    printf("  Launching test kernel...");
    kernel<<<1, 1>>>(0); // test kernel launch
    gpuErrchk(cudaPeekAtLastError());
    gpuErrchk(cudaDeviceSynchronize());
    printf("Success!\n");
  }

  return 0;
}
