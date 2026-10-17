import kernels.copy.GatherFrontHost

namespace Inference.Kernels.Quantization.AffineDequantizeHost

-- Reviewed selected branch of get_quantize_kernel_dims/quantize_impl.
-- Gather outputs must attach as contiguous native descriptors. The native
-- pipeline's nonzero maximum threadgroup size remains an explicit input.
structure Launch where
  threads : Nat
  group : Nat
  gridX : Nat
  gridY : Nat
  use2d : Bool
  deriving DecidableEq

def dims (bits outputSize maximum : Nat) : Launch :=
  let packs := if bits=3 ∨ bits=5 then 8 else if bits=6 then 4 else 8/bits
  let threads := outputSize/packs
  ⟨threads,min maximum threads,threads,1,threads>4294967295⟩

theorem selected (maximum : Nat) : dims 4 5120 maximum=⟨2560,min maximum 2560,2560,1,false⟩ := rfl

theorem group_bounds (maximum : Nat) (positive : 0<maximum) :
    0<(dims 4 5120 maximum).group ∧ (dims 4 5120 maximum).group≤maximum ∧
      (dims 4 5120 maximum).group≤2560 := by
  rw [selected]
  dsimp
  omega

theorem selected_sizes : 640*4=2560 ∧ 2560*2=5120 ∧ 5120/64=80 ∧ 5120*2=10240 := by decide

structure Bindings where
  packed : Nat
  scales : Nat
  biases : Nat
  output : Nat

def slot (b : Bindings) : Fin 4 → Nat := fun i => match i.val with
  | 0 => b.packed
  | 1 => b.scales
  | 2 => b.biases
  | _ => b.output

theorem slots (b : Bindings) : slot b 0=b.packed ∧ slot b 1=b.scales ∧ slot b 2=b.biases ∧ slot b 3=b.output :=
  ⟨rfl,rfl,rfl,rfl⟩

end Inference.Kernels.Quantization.AffineDequantizeHost
