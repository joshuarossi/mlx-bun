export { MlxArray, cpuStream, gpuStream, type StoredTensorView } from "./array";
export * as ops from "./ops";
export { CompiledFunction, setCompileMode, type TraceFn } from "./compile";
export { MetalKernel, type MetalKernelSpec, type MetalKernelCall } from "./metal-kernel";
export {
  Dtype,
  MLX_VERSION,
  activeMemory,
  cacheMemory,
  peakMemory,
  resetPeakMemory,
  clearCache,
  deviceArchitecture,
  maxRecommendedWorkingSetSize,
  setMemoryLimit,
  setWiredLimit,
  synchronize,
} from "./ffi";
