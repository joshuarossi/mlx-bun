import { MlxArray } from "../../src/mlx/array";
import { Dtype } from "../../src/mlx/ffi";
import { MetalKernel } from "../../src/mlx/metal-kernel";
// Does MLX metal_kernel donate an input buffer to an identically-shaped output
// (in-place), or allocate fresh? Write only index 0; check the rest.
const k = new MetalKernel({
  name: "donate_probe",
  inputNames: ["buf"],
  outputNames: ["out"],
  source: String.raw`
    uint i = thread_position_in_grid.x;
    if (i==0) out[0] = (float)999.0;
  `,
});
const N = 8;
const data = new Float32Array(N); for (let i=0;i<N;i++) data[i]=i+1;
const buf = MlxArray.fromFloat32(data, [N]);
const [out] = k.apply([buf], {
  outputs: [{ shape: [N], dtype: Dtype.float32 }],
  grid: [N,1,1], threadGroup: [N,1,1],
});
out!.eval();
console.log("out =", Array.from(out!.toFloat32()));
console.log("donation => [999,2,3,4,5,6,7,8] ; fresh-alloc => [999, garbage/0 ...]");
