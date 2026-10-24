import host.mlx.Kernel
import metal.Gpu
namespace Host.Mlx.FfiAneEval
open Inference.Contracts.Mlx

/-! # The in-place kernel interface (moved here from FfiAneEval.lean, unchanged)

A module of its own so that the route's kernel contract (`RouteKernelContract`, PrefillKernels.lean) can state its
in-place fields with it and the Neural Engine semantics (FfiAneEval.lean) can evaluate at that contract. -/

/-! ## The in-place kernel interface

The route's kernels that write through an input (src/kernels/ane/fill.ts):
the trellis fills write `dst` (input 2), the half writer writes `dst`
(input 1); each has one output, `done`. What the semantics needs of the
custom-kernel contract is the launch with every buffer's final contents, the
written input's included: `InPlace.launchAll`. Built from the GPU assumption
(`InPlace.ofGpu`) it is `Metal.Gpu.executeAll` on the launch text MLX
assembles and the inputs' buffers (`KernelGpu.buffer`, a row-contiguous
input as is: a surface wrap's buffer is the surface). A kernel contract then
states, per in-place kernel, `WritesThrough`: the launch completes, and the
written input holds the kernel's stores and its previous bytes elsewhere. -/

inductive InPlaceKernel where
  | trellisFill | trellisFillK3i | writeHalf
deriving DecidableEq

/-- The names our TypeScript gives them (`new MetalKernel({ name })`). -/
def inPlaceNames : List (List Char × InPlaceKernel) :=
  [(chars!"mlx_bun_ane_trellis_fill", .trellisFill), (chars!"mlx_bun_ane_trellis_fill_k3i", .trellisFillK3i),
   (chars!"mlx_bun_ane_write_half", .writeHalf)]

def inPlaceOf (name : List Char) : Option InPlaceKernel := (inPlaceNames.find? (·.1 = name)).map (·.2)

/-- The Metal source and header of each in-place kernel (bound to the TypeScript as `KernelSources` is). -/
structure InPlaceSources where
  source : InPlaceKernel → List Char
  header : InPlaceKernel → List Char

/-- `mlx_fast_metal_kernel_apply` of an in-place kernel on input values and a
configuration: every buffer's final contents, inputs in order, then outputs. -/
structure InPlace where
  launchAll : InPlaceKernel → List Value → Config → Option (List ByteMemory.Bytes)

/-- The in-place launch run by the GPU: `executeAll` of the assembled text (`text`, as `KernelGpu.launchText`)
on the inputs' buffers (`buffer`, as `KernelGpu.buffer`) and fresh outputs of the call's sizes. -/
def InPlace.ofGpu {C : M1Max.Contract} (G : Metal.Gpu C) (text : InPlaceKernel → List Value → Config → Option (List Char))
    (buffer : Value → Metal.Buffer) : InPlace :=
  ⟨fun k xs cfg => if cfg.initValue = none then (text k xs cfg).bind fun t =>
      G.executeAll t cfg.grid cfg.threadGroup (xs.map buffer) (cfg.outputs.map fun o => o.1.foldr (· * ·) 1 * o.2.bytes)
    else none⟩

/-- A launch writes input `i` through: it completes with one buffer per input and output, and input `i`'s
final bytes within its size are `stored` where the kernel stores and its previous bytes elsewhere. -/
def WritesThrough (IP : InPlace) (k : InPlaceKernel) (xs : List Value) (cfg : Config) (i : Nat)
    (stored : Nat → Option (BitVec 8)) : Prop :=
  ∃ res B dst, IP.launchAll k xs cfg = some res ∧ res.length = xs.length + cfg.outputs.length ∧
    res[i]? = some B ∧ xs[i]? = some dst ∧ ∀ b, b < dst.size * dst.dtype.bytes → B b = (stored b).getD (dst.storageByte b)

/-- An output buffer's bytes as the call's dtype and shape (`KernelGpu.readOutput`). -/
def outValue (bytes : ByteMemory.Bytes) (out : List Nat × Dtype) : Value :=
  ⟨out.2, out.1, fun i => (List.range out.2.bytes).foldr (fun k acc => (bytes (out.2.bytes * i + k)).toNat * 256 ^ k + acc) 0⟩

end Host.Mlx.FfiAneEval
