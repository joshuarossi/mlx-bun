import kernels.quantization.MlxQmvFast4LoopSource
import kernels.quantization.MlxQmvHostSource
namespace Inference.Kernels.Quantization.MlxQmvFast4Output
open Contracts.Mlx Contracts.Mlx.Numerics
open Copy.ScalarCopySyntax (accept)
open Sampling.ArgmaxShuffleSyntax (acceptMany)
set_option maxRecDepth 10000

def parseRow (source : String) : Option Unit := do
  let ts ←Trellis.GateInputSyntax.tokenize source
  let ts ←acceptMany ["const","int","out_row","=","tid",".","y","*","(","num_simdgroups","*","results_per_simdgroup",")","+","simd_gid","*","results_per_simdgroup",";"] ts
  if ts=[] then some () else none

def parseOutput (source : String) : Option Nat := do
  let ts ←Trellis.PackedArraySyntax.tokenize source
  let ts ←acceptMany ["result","[","row","]","=","simd_sum","(","result","[","row","]",")",";","if","(","simd_lid","=="] ts
  let (selected,ts) ←AffineInput4Syntax.number ts
  let ts ←acceptMany [")","{","y","[","row","]","=","static_cast","<","T",">","(","result","[","row","]",")",";","}"] ts
  if ts=[] then some selected else none

def rowSource : String := "const int out_row = tid.y * (num_simdgroups * results_per_simdgroup) +\n      simd_gid * results_per_simdgroup;"
def outputSource : String := "result[row] = simd_sum(result[row]);\n    if (simd_lid == 0) {\n      y[row] = static_cast<T>(result[row]);\n    }"
theorem parsed_row : parseRow rowSource=some () := by decide +kernel
theorem parsed_output : parseOutput outputSource=some 0 := by decide +kernel
attribute [local irreducible] parseRow parseOutput

-- tid.y/simd_gid are uint32, while out_row is signed int. Range is checked
-- before retaining the cast. grid.x=1 makes the batched y offset zero.
def rowBase (group : Fin groups) : Option Int := do
  let _ ←parseRow rowSource
  let raw := (BitVec.ofNat 32 (group.val/2))*(BitVec.ofNat 32 (2*4))+
    (BitVec.ofNat 32 (group.val%2))*(BitVec.ofNat 32 4)
  if raw.toNat<2^31 then some raw.toNat else none

theorem row_base (limit : groups≤62080) (group : Fin groups) : rowBase group=some (4*group.val:Int) := by
  have g := group.isLt
  have safe : group.val/2*8+group.val%2*4<2^31 := by omega
  have modulo : (group.val/2*8+group.val%2*4)%2^32=4*group.val := by omega
  simp only [rowBase,parsed_row,bind,Option.bind,BitVec.toNat_add,BitVec.toNat_mul,BitVec.toNat_ofNat]
  have block : group.val/2%2^32=group.val/2 := Nat.mod_eq_of_lt (by omega)
  have simd : group.val%2%2^32=group.val%2 := Nat.mod_eq_of_lt (by omega)
  rw [block,simd]
  norm_num only at *
  have mul : group.val/2*8%4294967296=group.val/2*8 := Nat.mod_eq_of_lt (by omega)
  have mul2 : group.val%2*4%4294967296=group.val%2*4 := Nat.mod_eq_of_lt (by omega)
  rw [mul,mul2,modulo]
  simp only [show 4*group.val<2147483648 from by omega,ite_true]
  norm_cast

def store (p : AffineRow.Platform) (registers : Fin (4*groups)→Fin 32→Float32)
    (base : Nat) (group : Fin groups) (lane : Fin 32) (offset : Fin 4) : Option (List HalfMemory.Store) := do
  let row0 ←rowBase group
  let selected ←parseOutput outputSource
  if lane.val=selected then
    if 0≤row0+(offset.val:Int) ∧ row0+(offset.val:Int)<2^31 then
      some [⟨base/2+(row0+(offset.val:Int)).toNat,
        AffineOutputSource.values p registers (CopyContiguous.index group offset)⟩]
    else none
  else some []

theorem source_store (p : AffineRow.Platform) (registers : Fin (4*groups)→Fin 32→Float32)
    (base : Nat) (limit : groups≤62080) (group : Fin groups) (lane : Fin 32) (offset : Fin 4) :
    store p registers base group lane offset=some (if lane.val=0 then
      [CopyContiguous.entry base (AffineOutputSource.values p registers) group offset] else []) := by
  have g := group.isLt; have r := offset.isLt
  have safe : 0≤(4*group.val:Int)+offset.val ∧ (4*group.val:Int)+offset.val<2^31 := by omega
  have index : ((4*group.val:Int)+offset.val).toNat=(CopyContiguous.index group offset).val := by
    dsimp [CopyContiguous.index];omega
  simp only [store,row_base limit,parsed_output,bind,Option.bind]
  rw [ite_eq_left safe,index]
  by_cases writer : lane.val=0 <;> simp [writer,CopyContiguous.entry]

def threadProgram (p : AffineRow.Platform) (registers : Fin (4*groups)→Fin 32→Float32)
    (base : Nat) (group : Fin groups) : Option (List HalfMemory.Store) := do
  let rows ←MlxQmvFast4LoopSource.innerVisits
  let writes ←rows.mapM (store p registers base group 0)
  pure writes.flatten

theorem source_thread (p : AffineRow.Platform) (registers : Fin (4*groups)→Fin 32→Float32)
    (base : Nat) (limit : groups≤62080) (group : Fin groups) :
    threadProgram p registers base group=some (CopyContiguous.threadStores base (AffineOutputSource.values p registers) group) := by
  simp only [threadProgram,MlxQmvFast4LoopSource.inner_visits]
  change (([0,1,2,3] : List (Fin 4)).mapM (store p registers base group 0)).bind (fun writes=>some writes.flatten)=_
  simp only [List.mapM_cons,List.mapM_nil,source_store p registers base limit,Fin.val_zero,ite_true,bind,Option.bind]
  rfl

def programs (p : AffineRow.Platform) (registers : Fin (4*groups)→Fin 32→Float32) (base : Nat) :=
  (List.finRange groups).mapM (threadProgram p registers base)

theorem source_programs (p : AffineRow.Platform) (registers : Fin (4*groups)→Fin 32→Float32)
    (base : Nat) (limit : groups≤62080) :
    programs p registers base=some (CopyContiguous.programs base (AffineOutputSource.values p registers)) := by
  unfold programs CopyContiguous.programs
  induction List.finRange groups with
  | nil => rfl
  | cons group rest ih =>
    simp only [List.mapM_cons,List.map_cons,source_thread p registers base limit,bind,Option.bind,ih]
    rfl
end Inference.Kernels.Quantization.MlxQmvFast4Output
