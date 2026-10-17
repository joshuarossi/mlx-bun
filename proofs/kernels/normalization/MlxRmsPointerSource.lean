import kernels.normalization.MlxRmsOutputMemory

namespace Inference.Kernels.Normalization.MlxRmsPointerSource
open Contracts.Mlx MlxRmsOutputSyntax
open Copy.ScalarCopySyntax (Parser accept)
set_option maxRecDepth 10000

structure Update where
  target : String
  offset : Expr
  deriving DecidableEq, Repr

def functionalCast : Parser Expr := fun tokens => do
  let (typeName,rest) ←nameToken tokens
  let (value,rest) ←parenthesized varExpr rest
  pure (.cast typeName value,rest)
def rowOffset : Parser Expr := binary (product varExpr functionalCast) "+"
  (product varExpr varExpr) Expr.add
def weightOffset : Parser Expr := product (product varExpr varExpr) varExpr
def parse (source : String) : Option Update := do
  let tokens ←tokenize source
  let (target,rest) ←nameToken tokens
  let rest ←accept "+" rest
  let rest ←accept "=" rest
  let (offset,rest) ←(rowOffset rest).orElse (fun _ => weightOffset rest)
  let rest ←accept ";" rest
  if rest=[] then some ⟨target,offset⟩ else none

def sourceX : String := "x += gid * size_t(axis_size) + lid * N_READS;"
def sourceW : String := "w += w_stride * lid * N_READS;"
def sourceOut : String := "out += gid * size_t(axis_size) + lid * N_READS;"
def rowExpr : Expr := .add (.mul (.var "gid") (.cast "size_t" (.var "axis_size")))
  (.mul (.var "lid") (.var "N_READS"))
def weightExpr : Expr := .mul (.mul (.var "w_stride") (.var "lid")) (.var "N_READS")
theorem parsed_x : parse sourceX=some ⟨"x",rowExpr⟩ := by decide +kernel
theorem parsed_w : parse sourceW=some ⟨"w",weightExpr⟩ := by decide +kernel
theorem parsed_out : parse sourceOut=some ⟨"out",rowExpr⟩ := by decide +kernel

-- Model the uint arithmetic and Apple's 64-bit size_t. The positive int
-- constexpr N_READS=4 is promoted to uint by its uint multiplication operand.
-- Pointer addresses are 64-bit byte addresses of BF16 elements.
inductive Unsigned where
  | small : BitVec 32 → Unsigned
  | wide : BitVec 64 → Unsigned
  deriving DecidableEq
def Unsigned.nat : Unsigned → Nat
  | .small value => value.toNat
  | .wide value => value.toNat
def arithmetic (op : Nat → Nat → Nat) : Unsigned → Unsigned → Unsigned
  | .small left,.small right => .small (BitVec.ofNat 32 (op left.toNat right.toNat))
  | left,right => .wide (BitVec.ofNat 64 (op left.nat right.nat))

def evaluate (gid width lid stride : Nat) : Expr → Option Unsigned
  | .var name =>
    if name="gid" then some (.small (BitVec.ofNat 32 gid))
    else if name="axis_size" then some (.small (BitVec.ofNat 32 width))
    else if name="lid" then some (.small (BitVec.ofNat 32 lid))
    else if name="w_stride" then some (.small (BitVec.ofNat 32 stride))
    else if name="N_READS" then some (.small 4) else none
  | .cast typeName value => do
    let value ←evaluate gid width lid stride value
    if typeName="size_t" then pure (.wide (BitVec.ofNat 64 value.nat)) else none
  | .mul left right => do
    pure (arithmetic Nat.mul (←evaluate gid width lid stride left) (←evaluate gid width lid stride right))
  | .add left right => do
    pure (arithmetic Nat.add (←evaluate gid width lid stride left) (←evaluate gid width lid stride right))
  | _ => none

def execute (source : String) (target : String) (base gid width lid stride : Nat) : Option Nat := do
  let statement ←parse source
  if statement.target=target then
    let offset ←evaluate gid width lid stride statement.offset
    pure (BitVec.ofNat 64 (base+2*offset.nat)).toNat
  else none

theorem row_offset (width lid : Nat) (small : lid*4<2^32) :
    evaluate 0 width lid 1 rowExpr=some (.wide (BitVec.ofNat 64 (lid*4))) := by
  have lane : lid<4294967296 := by change lid*4<4294967296 at small; omega
  have product : lid*4<4294967296 := small
  simp [evaluate,rowExpr,arithmetic,Unsigned.nat,BitVec.toNat_ofNat,Nat.mod_eq_of_lt lane,Nat.mod_eq_of_lt product]

theorem weight_offset (width lid : Nat) (small : lid*4<2^32) :
    evaluate 0 width lid 1 weightExpr=some (.small (BitVec.ofNat 32 (lid*4))) := by
  have lane : lid<4294967296 := by change lid*4<4294967296 at small; omega
  simp [evaluate,weightExpr,arithmetic,BitVec.toNat_ofNat,Nat.mod_eq_of_lt lane]

theorem x_address (base width lid : Nat) (small : lid*4<2^32) (room : base+2*(lid*4)<2^64) :
    execute sourceX "x" base 0 width lid 1=some (base+2*(lid*4)) := by
  have product : lid*4<18446744073709551616 := by change lid*4<4294967296 at small; omega
  change base+2*(lid*4)<18446744073709551616 at room
  simp [execute,parsed_x,row_offset width lid small,Unsigned.nat,BitVec.toNat_ofNat,
    Nat.mod_eq_of_lt product,Nat.mod_eq_of_lt room]

theorem out_address (base width lid : Nat) (small : lid*4<2^32) (room : base+2*(lid*4)<2^64) :
    execute sourceOut "out" base 0 width lid 1=some (base+2*(lid*4)) := by
  have product : lid*4<18446744073709551616 := by change lid*4<4294967296 at small; omega
  change base+2*(lid*4)<18446744073709551616 at room
  simp [execute,parsed_out,row_offset width lid small,Unsigned.nat,BitVec.toNat_ofNat,
    Nat.mod_eq_of_lt product,Nat.mod_eq_of_lt room]

theorem w_address (base width lid : Nat) (small : lid*4<2^32) (room : base+2*(lid*4)<2^64) :
    execute sourceW "w" base 0 width lid 1=some (base+2*(lid*4)) := by
  change lid*4<4294967296 at small
  change base+2*(lid*4)<18446744073709551616 at room
  simp [execute,parsed_w,weight_offset width lid small,Unsigned.nat,BitVec.toNat_ofNat,
    Nat.mod_eq_of_lt small,Nat.mod_eq_of_lt room]

variable {n : Nat} {values : Fin n → ArrayStorage.BF}

theorem buffer_room (buffer : ArrayStorage.BFBuffer values) (threads : Nat) (positive : 0<threads) (col : Fin n) :
    buffer.base+2*MlxRmsOutputMemory.origin threads positive col<2^64 := by
  have address := MlxRmsOutputMemory.column_address threads positive col
  have := col.isLt
  have := buffer.bounded
  omega

-- This discharges the input/weight pointer offsets used by sourceCell from
-- parsed pointer updates. Unit weight stride and row zero are the selected
-- single-token case; host selection and source loops remain separate.
theorem buffer_pointers (input : BinaryMemory.Input values weights) (threads : Nat) (positive : 0<threads)
    (width : n≤2^32) (col : Fin n) :
    let owner := NormalizationSchedule.owner threads positive col.val
    execute sourceX "x" input.lhs.base 0 n owner.thread.val 1=
      some (input.lhs.base+2*MlxRmsOutputMemory.origin threads positive col) ∧
    execute sourceW "w" input.rhs.base 0 n owner.thread.val 1=
      some (input.rhs.base+2*MlxRmsOutputMemory.origin threads positive col) := by
  have small : MlxRmsOutputMemory.origin threads positive col<2^32 := by
    have := MlxRmsOutputMemory.column_address threads positive col
    have := col.isLt
    omega
  exact ⟨x_address _ _ _ small (buffer_room input.lhs threads positive col),
    w_address _ _ _ small (buffer_room input.rhs threads positive col)⟩

def executeCell (input : BinaryMemory.Input values weights) {factor : Float32}
    (existing : BinaryMemory.Execution input (RmsNormMemory.operation factor))
    (threads : Nat) (positive : 0<threads) (inverse : M1Max.WordMemory) (inverseBase : Nat)
    (col : Fin n) (before : HalfMemory.Bytes) : Option HalfMemory.Bytes := do
  let owner := NormalizationSchedule.owner threads positive col.val
  let x ←execute sourceX "x" input.lhs.base 0 n owner.thread.val 1
  let w ←execute sourceW "w" input.rhs.base 0 n owner.thread.val 1
  let out ←execute sourceOut "out" (2*existing.base) 0 n owner.thread.val 1
  MlxRmsOutputSemantics.executeSource MlxRmsOutputSyntax.sourceBody x w out inverse inverseBase
    (MlxRmsOutputMemory.outer threads positive col) (MlxRmsOutputMemory.inner threads positive col) before

theorem execution_cell (input : BinaryMemory.Input values weights) {factor : Float32}
    (existing : BinaryMemory.Execution input (RmsNormMemory.operation factor))
    (threads : Nat) (positive : 0<threads) (width : n≤2^32)
    (inverse : M1Max.WordMemory) (inverseBase : Nat) (col : Fin n) (before : HalfMemory.Bytes) :
    executeCell input existing threads positive inverse inverseBase col before=
      some (MlxRmsOutputMemory.cell threads positive input.lhs.base input.rhs.base
        (2*existing.base) inverse inverseBase col before) := by
  have pointers := buffer_pointers input threads positive width col
  have small : MlxRmsOutputMemory.origin threads positive col<2^32 := by
    have := MlxRmsOutputMemory.column_address threads positive col
    have := col.isLt
    omega
  have output := out_address (2*existing.base) n
    (NormalizationSchedule.owner threads positive col.val).thread.val small
    (buffer_room existing.buffer threads positive col)
  dsimp only [executeCell] at ⊢
  dsimp only at pointers
  rw [pointers.1,pointers.2,output]
  simpa [MlxRmsOutputMemory.sourceCell,MlxRmsOutputMemory.origin] using
    MlxRmsOutputMemory.source_cell threads positive width input.lhs.base input.rhs.base
      (2*existing.base) inverse inverseBase col before

end Inference.Kernels.Normalization.MlxRmsPointerSource
