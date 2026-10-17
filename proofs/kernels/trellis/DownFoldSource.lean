import kernels.trellis.DownFoldIndex
namespace Inference.Kernels.Trellis.DownFoldSource
open Contracts.Mlx DownFoldSyntax DownFoldVectorMemory
set_option maxRecDepth 10000

def read (abi : VectorLoad)
    (trace : DownDevice.Trace load before base words k scale input)
    (group simd lane : Nat) (component : Fin 4) : Option Float32 :=
  (DownFoldIndex.address trace.partialBase group simd lane).map
    (fun address => abi.read trace.memory address component)

theorem read_current (abi : VectorLoad)
    (trace : DownDevice.Trace load before base words k scale input)
    (group simd lane : Nat) (hg : group<160) (hs : simd<8) (hl : lane<32) (component : Fin 4) :
    read abi trace group simd lane component=some (DownDevice.readVector trace group simd lane component) := by
  rw [read,DownFoldIndex.address_selected trace.partialBase group simd lane hg hs hl,Option.map_some]
  exact congrArg some (vector_current abi trace group simd lane hg hs hl component)

/-- All native SIMD lanes execute the parsed collective. Totalization is
    unobserved: read_current proves every one of the 32 reads succeeds. -/
def reduce (abi : VectorLoad)
    (trace : DownDevice.Trace load before base words k scale input)
    (simdSum : DownExecution.SimdReduction) (group simd : Nat) (component : Fin 4) : Option Float32 :=
  (parse reductionTokens reductionSource).bind (fun code =>
    if code.target="v" ∧ code.vector="t" ∧ code.index=.variable "i" then
      some (simdSum (fun lane => (read abi trace group simd lane.val component).getD 0))
    else none)

theorem reduce_current (abi : VectorLoad)
    (trace : DownDevice.Trace load before base words k scale input)
    (simdSum : DownExecution.SimdReduction) (group simd : Nat)
    (hg : group<160) (hs : simd<8) (component : Fin 4) :
    reduce abi trace simdSum group simd component=some
      (simdSum (fun lane => DownDevice.readVector trace group simd lane.val component)) := by
  rw [reduce,parsed_reduction,Option.bind_some]
  change some (simdSum (fun lane => (read abi trace group simd lane.val component).getD 0))=_
  apply congrArg some
  apply congrArg simdSum
  funext lane
  rw [read_current abi trace group simd lane.val hg hs lane.isLt component,Option.getD_some]

/-- Parsed four-component loop control, including its final false test. -/
def components : Option (List Nat) :=
  (GateLoopSource.parseLoop loopSource).bind (fun code =>
    if code.counter="i" ∧ code.test="i" ∧ code.step="i" then
      (PackedArraySemantics.evaluate 16 ⟨[],[],[]⟩ code.start).bind (fun start =>
        (PackedArraySemantics.asUInt start).bind (fun start =>
          (PackedArraySemantics.evaluate 16 ⟨[],[],[]⟩ code.bound).bind (fun bound =>
            (PackedArraySemantics.asUInt bound).bind (fun bound =>
              (PackedArraySemantics.evaluate 16 ⟨[],[],[]⟩ code.increment).bind (fun step =>
                (PackedArraySemantics.asUInt step).bind (GateLoopSource.iterations 6 start bound))))))
    else none)

theorem components_selected : components=some (List.range 4) := rfl

/-- Builtin values are the native dispatch interface; parsing fixes which
    builtin is used. Mapping a native thread to its SIMD lane is explicit. -/
def nativeLane (thread : Nat) : Option Nat :=
  (parse laneTokens laneSource).bind (fun code =>
    if code=("lane","thread_index_in_simdgroup") then some (thread%32) else none)

theorem native_lane (thread : Nat) : nativeLane thread=some (thread%32) := by
  rw [nativeLane,parsed_lane]
  rfl

def storeIndex (group simd : Nat) (component : Fin 4) (code : Store) : Option Nat :=
  if code.target="out" ∧ code.index=.add (.variable "col") (.variable "i") then
    (DownFoldIndex.sourceColumn group simd).map (fun col => (col+BitVec.ofNat 32 component.val).toNat)
  else none

theorem store_index (group simd : Nat) (hg : group<160) (hs : simd<8) (component : Fin 4) :
    storeIndex group simd component store=some (group*32+simd*4+component.val) := by
  rw [storeIndex,ite_eq_left (by decide)]
  rw [DownFoldIndex.column_selected group simd hg hs,Option.map_some]
  apply congrArg some
  simp (disch := have := component.isLt; omega) only [BitVec.toNat_add,BitVec.toNat_ofNat,Nat.mod_eq_of_lt]

/-- The collective is evaluated before the writer branch. T is specialized
    to BF16 here; the native specialization/cast conformance remains explicit. -/
def operation (abi : VectorLoad)
    (trace : DownDevice.Trace load before base words k scale input)
    (simdSum : DownExecution.SimdReduction) (outputBase group thread : Nat)
    (component : Fin 4) : Option (List HalfMemory.Store) :=
  (reduce abi trace simdSum group (thread/32) component).bind (fun value =>
    (parse storeTokens storeSource).bind (fun code =>
      if code.lane="lane" ∧ code.writer=.uint 0 ∧ code.conversion="T" ∧ code.value="v" then
        (nativeLane thread).bind (fun lane =>
          if lane=0 then (storeIndex group (thread/32) component code).map (fun index =>
            [⟨outputBase/2+index,(BFloat16.narrow value).bits⟩])
          else some [])
      else none))

theorem operation_current (abi : VectorLoad)
    (trace : DownDevice.Trace load before base words k scale input)
    (simdSum : DownExecution.SimdReduction) (outputBase group thread : Nat)
    (hg : group<160) (ht : thread<256) (component : Fin 4) :
    operation abi trace simdSum outputBase group thread component=some
      (if thread%32=0 then [DownOutput.entry outputBase (DownOutput.foldValues trace simdSum) group thread component.val] else []) := by
  rw [operation,reduce_current abi trace simdSum group (thread/32) hg (by omega),Option.bind_some,
    parsed_store,Option.bind_some]
  rw [ite_eq_left (by decide)]
  rw [native_lane,Option.bind_some]
  by_cases active : thread%32=0
  · rw [ite_eq_left active,store_index group (thread/32) hg (by omega),Option.map_some,ite_eq_left active,
      DownOutput.component_value trace simdSum group thread component]
    rfl
  · rw [ite_eq_right active,ite_eq_right active]

end Inference.Kernels.Trellis.DownFoldSource
