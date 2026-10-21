import host.load.Inputs
import host.mlx.GraphCertificate
import Lean
namespace Host.Load
open Host.Load.Extract Host.Mlx.FfiEval Lean Elab Command Meta

def cacheNodePair (c : Extract.Cache) : Option Nat × Option Nat :=
  (c.first.map Tensor.node,c.second.map Tensor.node)
def certifiedCachePair (cert : List Nat) (p : Nat × Nat) : Option Nat × Option Nat :=
  (some (certAt cert p.1),some (certAt cert p.2))

theorem map_cons_join {α β γ : Type} (f : α → γ) (g : β → γ)
    (a : α) (as : List α) (b : β) (bs : List β)
    (head : f a = g b) (tail : as.map f = bs.map g) :
    (a::as).map f = (b::bs).map g := congrArg₂ List.cons head tail

-- `addDecl` keeps a kernel-rejected theorem as an axiom; restoring the
-- environment keeps a rejected candidate out of it.
private def proof (name : Lean.Name) (ty value : Lean.Expr) : TermElabM Unit := do
  let saved ← getEnv
  try addDecl (.thmDecl {name,levelParams := [],type := ty,value})
  catch ex => setEnv saved; throw ex

/-- Stage the same cache-carrier list equality one pair at a time. Each
candidate head is checked by kernel conversion; only ordinary list
congruence composes the heads. No native evaluator is involved. -/
elab "load_cache_carriers " name:ident " : " source:term ", " expected:term ", " certificate:term : command =>
  liftTermElabM <| withOptions (fun o => o.setBool `Elab.async false) do
  let pre := (← getCurrNamespace) ++ name.getId
  let src ← instantiateMVars (← Term.elabTermAndSynthesize source none)
  let exp ← instantiateMVars (← Term.elabTermAndSynthesize expected none)
  let cert ← instantiateMVars (← Term.elabTermAndSynthesize certificate none)
  let f := mkConst ``cacheNodePair
  let g := mkApp (mkConst ``certifiedCachePair) cert
  let mut left := #[src]
  let mut right := #[exp]
  let mut heads : Array (Lean.Expr × Lean.Expr) := #[]
  repeat
    let s ← whnf left.back!
    let e ← whnf right.back!
    if s.isAppOfArity ``List.nil 1 && e.isAppOfArity ``List.nil 1 then break
    unless s.isAppOfArity ``List.cons 3 && e.isAppOfArity ``List.cons 3 do
      throwError "load_cache_carriers: cache/output lists have different or unresolved lengths"
    let sa := s.getAppArgs
    let ea := e.getAppArgs
    heads := heads.push (sa[1]!,ea[1]!)
    left := left.push sa[2]!
    right := right.push ea[2]!
  let mut next := mkConst ``True.intro
  for j in [:heads.size+1] do
    let i := heads.size-j
    let lhs ← mkAppM ``List.map #[f,left[i]!]
    let rhs ← mkAppM ``List.map #[g,right[i]!]
    let ty ← mkEq lhs rhs
    let nm := pre ++ Name.mkSimple s!"tail{i}"
    if i == heads.size then
      proof nm ty (← mkEqRefl lhs)
    else
      let (a,b) := heads[i]!
      let ha := mkApp f a
      let hb := mkApp g b
      let hn := pre ++ Name.mkSimple s!"head{i}"
      proof hn (← mkEq ha hb) (← mkEqRefl ha)
      let term ← mkAppM ``map_cons_join #[f,g,a,left[i+1]!,b,right[i+1]!,mkConst hn,next]
      proof nm ty term
    next := mkConst nm
  let lhs ← mkAppM ``List.map #[f,src]
  let rhs ← mkAppM ``List.map #[g,exp]
  proof pre (← mkEq lhs rhs) next
  logInfo m!"Kernel-checked {heads.size} cache carrier pairs"
end Host.Load
