import host.simgraph.GenLoadRel
import host.simgraph.prompt.NativeD
import host.simgraph.prompt.NormalizeX
import host.mlx.KernelSources
set_option maxRecDepth 1000000
set_option autoImplicit false
namespace Host.Route.Cert.Fin
open Host.Ts Host.Mlx Host.Mlx.FfiEval Host.Mlx.SimGraph

/-! # What a class's certificate reads

A template's table numbers are linear in the prompt's length `L`, each variable `v` being `k + a·L` (`VarV`): a dimension is the
ordinary template's `pos` or `pos1` at time `L + d`, or a literal. Host bytes read constants: a row count's expression may mention
`L` and cancel it. -/

/-- Each variable's value: `(v, k, a)` for `k + a·L`. -/
abbrev VarV := List (Nat × Int × Int)

def varGet (V : VarV) (x : Nat) : Option (Int × Int) := (V.find? (·.1 = x)).map (·.2)

def termsV (V : VarV) : List (Int × Nat) → Option (Int × Int)
  | [] => some (0, 0)
  | t :: ts => (termsV V ts).bind fun r => (varGet V t.2).map fun q => (r.1 + t.1 * q.1, r.2 + t.1 * q.2)

/-- A normal form as `k + a·L`; its divisions only of constants. -/
def linV (V : VarV) : PDim → Option (Int × Int)
  | .lit i => some (i, 0)
  | .lin c ts => (termsV V ts).map fun r => (c + r.1, r.2)
  | .fdiv d k => (linV V d).bind fun r => if r.2 = 0 then some (r.1 / (k : Int), 0) else none
  | .cdiv d k => (linV V d).bind fun r => if r.2 = 0 then some (ceilDiv r.1 k, 0) else none
  | .rup k d => (linV V d).bind fun r => if r.2 = 0 then some ((k : Int) * ceilDiv r.1 k, 0) else none

/-- A normal form at the time `L + d`, read as the template's dimension. -/
def sdimV (V : VarV) (d : Int) (p : PDim) : Option SDim :=
  (linV V p).bind fun r =>
    if r.2 = 0 then some (.lit r.1)
    else if r.2 = 1 then
      if r.1 = d then some .pos else if r.1 = d + 1 then some .pos1 else none
    else none

def clsV (S : SSrv) (B : Box) (V : VarV) (d : Int) (x : NumV) : Option SDim := (clsOfX S B x).bind (sdimV V d)

/-- A number's value as a constant of the table: its normal form, independent of `L`. -/
def constV (S : SSrv) (B : Box) (V : VarV) (x : NumV) : Option Int :=
  ((clsOfX S B x).bind (linV V)).bind fun r => if r.2 = 0 then some r.1 else none

/-- 32-bit cells read through their constant value, others refused. -/
def byteV (S : SSrv) (B : Box) (V : VarV) : Byte → Option Nat
  | .lit b => some b
  | .part .i32 (.num x) i => (constV S B V x).bind fun c => nth? (leBytes 4 (F64.modNat c (2 ^ 32))) i
  | .part .u32 (.num x) i => (constV S B V x).bind fun c => nth? (leBytes 4 (F64.modNat c (2 ^ 32))) i
  | _ => none

def numsV (S : SSrv) (B : Box) (V : VarV) (d : Int) : Nums SDim :=
  { symNumsD (clsV S B V d) SDim.lit with byte := byteV S B V }

noncomputable def gsV (s : Ffi.St) (S : SSrv) (B : Box) (V : VarV) (d : Int) : Nat → Option (RNode SDim InKey) :=
  restrictTo (exactTplDom 15235 15235 [5554869888] s) (ffiGraph (numsV S B V d) SourceKernels.sources s)

end Host.Route.Cert.Fin
