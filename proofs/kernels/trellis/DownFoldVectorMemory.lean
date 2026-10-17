import kernels.trellis.DownPartialMemorySource
import kernels.trellis.DownOutput

namespace Inference.Kernels.Trellis.DownFoldVectorMemory
open Contracts.Mlx

/-- The native float4 load boundary, stated for arbitrary current bytes and
    each component rather than for an expected kernel result. -/
structure VectorLoad where
  read : ByteMemory.Bytes → Nat → Fin 4 → Float32
  component : ∀ bytes address, address % 16 = 0 → address + 16 ≤ 2^64 →
    ∀ component, read bytes address component =
      FloatMemory.load bytes (address + 4 * component.val)

/-- A scalar byte interpretation of the vector ABI. Native conformance to
    this interpretation remains a primitive contract. -/
def scalar : VectorLoad where
  read bytes address component := FloatMemory.load bytes (address + 4 * component.val)
  component _ _ _ _ _ := rfl

/-- Read from the same device trace memory produced by the partial stores. -/
def vector (abi : VectorLoad)
    (trace : DownDevice.Trace load before base words k scale input)
    (group simd lane : Nat) (component : Fin 4) : Float32 :=
  abi.read trace.memory (DownDevice.vectorAddress trace.partialBase group simd lane) component

theorem vector_current (abi : VectorLoad)
    (trace : DownDevice.Trace load before base words k scale input)
    (group simd lane : Nat) (hg : group < 160) (hs : simd < 8) (hl : lane < 32)
    (component : Fin 4) :
    vector abi trace group simd lane component =
      DownDevice.readVector trace group simd lane component := by
  apply abi.component
  · exact DownDevice.vector_aligned trace.partialBase group simd lane trace.partialAligned
  · exact (DownDevice.vector_bounds trace.partialBase group simd lane
      hg hs hl trace.partialBounded).2.2

/-- The SIMD primitive consumes all 32 lanes before writer selection. Its
    reduction tree is supplied explicitly; this theorem does not reassociate it. -/
def reduced (abi : VectorLoad)
    (trace : DownDevice.Trace load before base words k scale input)
    (reduce : DownExecution.SimdReduction) (group simd : Nat) (component : Fin 4) : Float32 :=
  reduce (fun lane => vector abi trace group simd lane.val component)

theorem reduced_current (abi : VectorLoad)
    (trace : DownDevice.Trace load before base words k scale input)
    (reduce : DownExecution.SimdReduction) (group simd : Nat)
    (hg : group < 160) (hs : simd < 8) (component : Fin 4) :
    reduced abi trace reduce group simd component =
      reduce (fun lane => DownDevice.readVector trace group simd lane.val component) := by
  unfold reduced
  congr 1
  funext lane
  exact vector_current abi trace group simd lane.val hg hs lane.isLt component

theorem narrowed_current (abi : VectorLoad)
    (trace : DownDevice.Trace load before base words k scale input)
    (reduce : DownExecution.SimdReduction) (group thread : Nat)
    (hg : group < 160) (ht : thread < 256) (component : Fin 4) :
    BFloat16.narrow (reduced abi trace reduce group (thread / 32) component) =
      DownOutput.foldValues trace reduce (DownOutput.column group thread component.val) := by
  rw [reduced_current abi trace reduce group (thread / 32) hg (by omega)]
  exact DownOutput.component_value trace reduce group thread component

end Inference.Kernels.Trellis.DownFoldVectorMemory
