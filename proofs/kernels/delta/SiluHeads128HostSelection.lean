import kernels.delta.SiluHeads128Geometry

namespace Inference.Kernels.Delta.SiluHeads128HostSelection

-- Reviewed launch translation for finite integer descriptor metadata. Actual
-- descriptor extraction, native BF16 overloads and compilation remain explicit.
inductive Dtype where | bfloat16 | float32 deriving DecidableEq,Repr
structure Metadata where
  batch : Nat
  sequence : Nat
  channels : Nat
  rank : Nat
  keyHeads : Nat
  valueHeads : Nat
  valueWidth : Nat
  queryScaleSize : Nat
  queryScaleRank : Nat
  keyScaleSize : Nat
  keyScaleRank : Nat
  inputType : Dtype
  queryScaleType : Dtype
  keyScaleType : Dtype
  deriving DecidableEq,Repr
structure Launch where
  inputNames : List String
  outputNames : List String
  outputShapes : List (List Nat)
  outputType : Dtype
  grid : List Nat
  group : List Nat
  templateType : Dtype
  templateInts : List (String × Nat)
  deriving DecidableEq,Repr

def launch (m : Metadata) : Option Launch :=
  let keyWidth := m.queryScaleSize
  if m.rank≠3 ∨ m.channels≠2*m.keyHeads*keyWidth+m.valueHeads*m.valueWidth ∨
      keyWidth<1 ∨ keyWidth>128 ∨ m.valueWidth<1 ∨ m.valueWidth>128 ∨
      m.queryScaleRank≠1 ∨ m.keyScaleRank≠1 ∨ m.keyScaleSize≠keyWidth ∨
      m.queryScaleType≠m.inputType ∨ m.keyScaleType≠m.inputType then none
  else some ⟨["x","qscale","kscale"],["q","k","v"],
    [[m.batch,m.sequence,m.keyHeads,keyWidth],[m.batch,m.sequence,m.keyHeads,keyWidth],
      [m.batch,m.sequence,m.valueHeads,m.valueWidth]],m.inputType,
    [32*(2*m.keyHeads+m.valueHeads),m.batch*m.sequence,1],[32,1,1],m.inputType,
    [("C",m.channels),("HK",m.keyHeads),("HV",m.valueHeads),("DK",keyWidth),("DV",m.valueWidth)]⟩

def selected : Metadata := ⟨1,1,10240,3,16,48,128,128,1,128,1,.bfloat16,.bfloat16,.bfloat16⟩
def expected : Launch := ⟨["x","qscale","kscale"],["q","k","v"],
  [[1,1,16,128],[1,1,16,128],[1,1,48,128]],.bfloat16,[2560,1,1],[32,1,1],.bfloat16,
  [("C",10240),("HK",16),("HV",48),("DK",128),("DV",128)]⟩

theorem selected_launch : launch selected=some expected := by decide +kernel

theorem geometry (thread : Fin 2560) : thread.val/32<80 ∧ thread.val%32<32 ∧
    thread.val/32*32+thread.val%32=thread.val := by
  have := thread.isLt
  omega

theorem current_index (head : Fin 80) (lane : Fin 32) (i : Fin 4) :
    SiluHeads128Geometry.channel head+lane.val*4+i.val<10240 ∧
      SiluHeads128Geometry.channel head+lane.val*4+i.val<2^32 := by
  rw [SiluHeads128Geometry.channel_eq]
  have := head.isLt
  have := lane.isLt
  have := i.isLt
  omega

end Inference.Kernels.Delta.SiluHeads128HostSelection
