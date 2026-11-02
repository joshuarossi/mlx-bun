import host.simgraph.GenLoadRel
import host.sim.template.DimVals
import host.simgraph.prompt.NativeD
import host.simgraph.prompt.NormalizeX
import host.mlx.KernelSources
set_option maxRecDepth 1000000
set_option autoImplicit false
namespace Host.Route.Cert.Row
open Host.Ts Host.Mlx Host.Mlx.FfiEval Host.Mlx.SimGraph
open Host.Load.Run.Tpl (tailVal)

/-! # What a POST row's certificate reads

A POST row runs the ordinary decode forward at time `L + d` while its table reads the prompt's length: the table's
numbers are `L + c`, so its dimensions are the template's `pos` at `c = d` and `pos1` at `c = d + 1` (`clsRow`). -/

def dimsBox : Box := (List.range 58).map fun i =>
  (201 + i, (((tailVal (201 + i)).getD 0 : Nat) : Int), (((tailVal (201 + i)).getD 0 : Nat) : Int))

def boxRow : Box := (9, 1, 224) :: (10, 1, 1) :: (11, 1, 224) :: (16, 256, 256) :: dimsBox

/-- The terms over the box: `k + a·L`, the row count 1, the capacity 256 and the dims being constants. -/
def rowTerms : List (Int × Nat) → Option (Int × Int)
  | [] => some (0, 0)
  | t :: ts => (rowTerms ts).bind fun r =>
    if t.2 = 9 ∨ t.2 = 11 then some (r.1, r.2 + t.1)
    else if t.2 = 10 then some (r.1 + t.1, r.2)
    else if t.2 = 16 then some (r.1 + t.1 * 256, r.2)
    else match tailVal t.2 with
      | some k => some (r.1 + t.1 * (k : Int), r.2)
      | none => none

/-- A normal form as `k + a·L`; its divisions only of constants. -/
def rowLin : PDim → Option (Int × Int)
  | .lit i => some (i, 0)
  | .lin c ts => (rowTerms ts).map fun r => (c + r.1, r.2)
  | .fdiv d k => (rowLin d).bind fun r => if r.2 = 0 then some (r.1 / (k : Int), 0) else none
  | .cdiv d k => (rowLin d).bind fun r => if r.2 = 0 then some (ceilDiv r.1 k, 0) else none
  | .rup k d => (rowLin d).bind fun r => if r.2 = 0 then some ((k : Int) * ceilDiv r.1 k, 0) else none

/-- A normal form at the row's offset `d`, read as the template's dimension. -/
def rowS (d : Int) (p : PDim) : Option SDim :=
  (rowLin p).bind fun r =>
    if r.2 = 0 then some (.lit r.1)
    else if r.2 = 1 then
      if r.1 = d then some .pos else if r.1 = d + 1 then some .pos1 else none
    else none

/-- The template's number at the row's offset. -/
def clsRow (S : SSrv) (d : Int) (x : NumV) : Option SDim := (clsOfX S boxRow x).bind (rowS d)

/-- The template's dimension as the row's normal form, for the search. -/
def toP (d : Int) : SDim → PDim
  | .lit i => .lit i
  | .pos => .lin d [(1, 11)]
  | .pos1 => .lin (d + 1) [(1, 11)]

/-- Partial evaluation with the row count and the dims fixed. -/
def evalRow : SymE → Option F64
  | .lit f => some f
  | .var i => if i = 10 then some (F64.ofNat 1) else (tailVal i).map F64.ofNat
  | .un op a => (evalRow a).map (F64.un op)
  | .bin op a b => do pure (F64.bin op (← evalRow a) (← evalRow b))

def rowNumVal (S : SSrv) : NumV → Option F64
  | .lit f => some f
  | .ref i => (nth? S.tab i).bind evalRow

/-- Numeric cells read through the fixed row count, bigint cells refused. -/
def rowByte (S : SSrv) : Byte → Option Nat
  | .lit b => some b
  | .part k (.num x) i => concreteByte (rowNumVal S) (.part k (.num x) i)
  | .part _ (.big _) _ => none

/-- The row's reading: dimensions through `clsRow`, host bytes through `rowByte`. -/
def rowNums (S : SSrv) (d : Int) : Nums SDim :=
  { symNumsD (clsRow S d) SDim.lit with byte := rowByte S }

noncomputable def rowGs (s : Ffi.St) (S : SSrv) (d : Int) : Nat → Option (RNode SDim InKey) :=
  restrictTo (exactTplDom 15235 15235 [5554869888] s) (ffiGraph (rowNums S d) SourceKernels.sources s)

end Host.Route.Cert.Row
