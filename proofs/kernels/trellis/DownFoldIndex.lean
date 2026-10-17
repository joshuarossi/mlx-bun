import kernels.trellis.DownFoldSyntax
import kernels.trellis.DownFoldVectorMemory
namespace Inference.Kernels.Trellis.DownFoldIndex
open DownFoldSyntax DownPointerSemantics
set_option maxRecDepth 10000

def columnEnvironment (group simd : Nat) : Environment := fun name =>
  if name="threadgroup_position_in_grid.x" then some (.uint (BitVec.ofNat 32 group))
  else if name="simdgroup_index_in_threadgroup" then some (.uint (BitVec.ofNat 32 simd)) else none

def columnValue (group simd : Nat) (code : Column) : Option (BitVec 32) :=
  if code.target="col" then
    (evaluate (columnEnvironment group simd)
      (.add (.multiply (.variable code.group) code.groupStride)
        (.multiply (.variable code.simd) code.simdStride))).bind (fun value => match value with
          | .uint value => some value
          | _ => none)
  else none

def sourceColumn (group simd : Nat) : Option (BitVec 32) :=
  (parse columnTokens columnSource).bind (columnValue group simd)

theorem column_selected (group simd : Nat) (hg : group<160) (hs : simd<8) :
    sourceColumn group simd=some (BitVec.ofNat 32 (group*32+simd*4)) := by
  rw [sourceColumn,parsed_column,Option.bind_some]
  change some (BitVec.ofNat 32 group*32+BitVec.ofNat 32 simd*4)=_
  apply congrArg some
  apply BitVec.eq_of_toNat_eq
  simp (disch := omega) only [show (32 : BitVec 32).toNat=32 from rfl,
    show (4 : BitVec 32).toNat=4 from rfl,BitVec.toNat_add,BitVec.toNat_mul,
    BitVec.toNat_ofNat,Nat.mod_eq_of_lt]

def pointerEnvironment (lane : Nat) (col : BitVec 32) : Environment := fun name =>
  if name="partial" then some (.pointer 0)
  else if name="lane" then some (.uint (BitVec.ofNat 32 lane))
  else if name="C" then some (.signed 5120)
  else if name="col" then some (.uint col) else none

def pointerValue (lane : Nat) (col : BitVec 32) (code : VectorRead) : Option (BitVec 64) :=
  if code.target="t" then (evaluate (pointerEnvironment lane col) code.pointer).bind (fun value => match value with
    | .pointer index => some index
    | _ => none)
  else none

def sourcePointer (group simd lane : Nat) : Option (BitVec 64) :=
  (sourceColumn group simd).bind (fun col =>
    (parse vectorTokens vectorSource).bind (pointerValue lane col))

theorem pointer_selected (group simd lane : Nat) (hg : group<160) (hs : simd<8) (hl : lane<32) :
    (sourcePointer group simd lane).map BitVec.toNat=some (lane*5120+group*32+simd*4) := by
  rw [sourcePointer,column_selected group simd hg hs,Option.bind_some,parsed_vector,Option.bind_some]
  change some ((0+(BitVec.ofNat 64 (BitVec.ofNat 32 lane).toNat*(5120 : BitVec 64))+
    BitVec.ofNat 64 (BitVec.ofNat 32 (group*32+simd*4)).toNat).toNat)=_
  simp (disch := omega) only [BitVec.toNat_add,BitVec.toNat_mul,BitVec.toNat_ofNat,
    show (0 : BitVec 64).toNat=0 from rfl,show (5120 : BitVec 64).toNat=5120 from rfl,
    Nat.mod_eq_of_lt,Nat.zero_add]
  apply congrArg some
  omega

def address (partialBase group simd lane : Nat) : Option Nat :=
  (sourcePointer group simd lane).map (fun index => partialBase+4*index.toNat)

theorem address_selected (partialBase group simd lane : Nat)
    (hg : group<160) (hs : simd<8) (hl : lane<32) :
    address partialBase group simd lane=some (DownDevice.vectorAddress partialBase group simd lane) := by
  have selected:=pointer_selected group simd lane hg hs hl
  change (sourcePointer group simd lane).map ((fun index => partialBase+4*index) ∘ BitVec.toNat)=_
  rw [←Option.map_map,selected]
  rfl
end Inference.Kernels.Trellis.DownFoldIndex
