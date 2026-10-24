import host.load.Micro
import host.load.Compose
import host.load.run.tail.Command
import host.load.RoutePrompt
import host.load.Decode
import host.load.Sha
namespace Host.Load.PromptStream
open Lean Elab Command Meta Host.Ts Host.Ts.Stream Host.Load Host.Load.Sha

/-! # Streams abstracted over the prompt array

The route of `RoutePrompt` reads its prompt only after `loadDone`, so its boot is checked
once for every prompt: the states `P.a<k> fw` (`host_stream … abs`) hold the prompt array
with elements `fw`, and every chunk is one kernel check with `fw` free. These commands only
build terms; every theorem is checked by the kernel. With a free variable the kernel turns
off numeral acceleration (`Run.Tail` command notes), so the checks pass `eagerReduce`.

* `promptBoot`: the boot the native choosers run from (`host/load/boot`'s `boot_w_micro`);
* `link_abs Q from L`, `link_chunk_abs_eager`, `link_step_abs_eager`, `link_abs_run`: the
  link chain `L` (computed for the sentinel prompt `[absSentinel]`) for every prompt. -/

private def nm (pre : Lean.Name) (tag : String) (i : Nat) : Lean.Name :=
  pre ++ Lean.Name.mkSimple (tag ++ toString i)

private def valL : Lean.Expr := mkApp (mkConst ``List [.zero]) (mkConst ``Val)

private def addThm (name : Lean.Name) (type value : Lean.Expr) : CoreM Unit :=
  addDecl (.thmDecl { name, levelParams := [], type, value })

private def addDef (name : Lean.Name) (type value : Lean.Expr) : CoreM Unit :=
  addDecl (.defnDecl { name, levelParams := [], type, value, hints := .regular 0, safety := .safe })

private def eqE (u : Level) (α a b : Lean.Expr) : Lean.Expr := mkApp3 (mkConst ``Eq [u]) α a b

/-- A numeral: a raw literal or `OfNat.ofNat _ n _`. -/
private partial def natE (e : Lean.Expr) : Option Nat :=
  match e with
  | .lit (.natVal n) => some n
  | .mdata _ b => natE b
  | _ => if e.isAppOfArity ``OfNat.ofNat 3 then natE e.appFn!.appArg! else none

/-- The numbers of a literal list expression. -/
private partial def natListE (e : Lean.Expr) : Option (List Nat) :=
  match e.getAppFn, e.getAppArgs with
  | .const ``List.nil _, #[_] => some []
  | .const ``List.cons _, #[_, h, t] => do pure ((← natE h) :: (← natListE t))
  | _, _ => none

/-- The value of a constant defined as a literal list of numbers (`P.ks`, `L.ns`). -/
private def constNats (n : Lean.Name) : MetaM (List Nat) := do
  let some v := (← getConstInfo n).value? | throwError "{n} has no value"
  let some l := natListE v | throwError "{n} is not a literal list of numbers"
  pure l

private def one : Level := .succ .zero

/-- The boot of the prompt stream's route (`run/prompt/States`'s `host_stream` term). -/
def promptBoot : Option (St LSt) := bootL (RoutePrompt.cx [9707]) Decode.world 2000

/-! ## The link chain for every prompt -/

private def linkTypes (src : Lean.Name) : MetaM (Lean.Expr × Lean.Expr × Lean.Expr) := do
  let some (.defnInfo d) := (← getEnv).find? (nm src "x" 0) | throwError "no link chain {src}"
  pure (d.type, d.type.appArg!, mkApp (mkConst ``Option [.zero]) d.type)

private def linkStart (src : Lean.Name) (k : Nat) : MetaM (Nat × Nat) := do
  let ns ← constNats (src ++ `ns)
  let some n := ns[k]? | throwError "no link chunk {k}"
  pure ((ns.take k).foldl (· + ·) 0, n)

/-- `link_abs Q from L`: `Q.x<k> : List Val → LinkSt LSt`, the link states of `L` (computed for
the prompt `[absSentinel]`) with the sentinel prompt's elements replaced by `fw`. -/
elab "link_abs " q:ident " from " p:ident : command => liftTermElabM do
  let tgt := (← getCurrNamespace) ++ q.getId
  let src := p.getId
  let ns ← constNats (src ++ `ns)
  let sentE := toExpr absSentinel
  let mut found : Nat := 0
  for k in [0:ns.length + 1] do
    let some (.defnInfo d) := (← getEnv).find? (nm src "x" k) | throwError "link_abs: no link state {k}"
    let body := absReplace sentE d.value
    if body.hasLooseBVars then found := found + 1
    addDef (nm tgt "x" k) (← mkArrow valL d.type) (.lam `fw valL body .default)
  logInfo m!"link_abs {tgt}: {found} of {ns.length + 1} link states hold the prompt"

/-- `Q.l<k> : ∀ fw, linkRun (cx fw) sₖ nₖ (Q.x<k> fw) = some (Q.x<k+1> fw)` (eager). -/
elab "link_chunk_abs_eager " q:ident " from " p:ident " using " c:ident i:num : command => liftTermElabM do
  let tgt := (← getCurrNamespace) ++ q.getId
  let src := p.getId
  let cxN ← realizeGlobalConstNoOverloadWithInfo c
  let k := i.getNat
  let (start, n) ← linkStart src k
  let (xTy, sTy, oTy) ← linkTypes src
  let fw := Lean.Expr.bvar 0
  let lhs := mkAppN (mkConst ``linkRun) #[sTy, mkApp (mkConst cxN) fw, mkRawNatLit start, mkRawNatLit n, mkApp (mkConst (nm tgt "x" k)) fw]
  let rhs := mkApp2 (mkConst ``Option.some [.zero]) xTy (mkApp (mkConst (nm tgt "x" (k + 1))) fw)
  let body := eqE one oTy lhs rhs
  addThm (nm tgt "l" k) (.forallE `fw valL body .default) (.lam `fw valL (Run.Tail.eagerRefl one oTy lhs rhs) .default)

/-- A one-step link theorem through `h : ∀ fw, linkRun … = r fw` (a scanned user-module step),
finished by eager `Eq.refl`. -/
elab "link_step_abs_eager " q:ident " from " p:ident " using " c:ident i:num " := " h:term : command => liftTermElabM do
  let tgt := (← getCurrNamespace) ++ q.getId
  let src := p.getId
  let cxN ← realizeGlobalConstNoOverloadWithInfo c
  let k := i.getNat
  let (start, n) ← linkStart src k
  let (xTy, sTy, oTy) ← linkTypes src
  let hE ← instantiateMVars (← Term.elabTermAndSynthesize h none)
  let (type, value) ← withLocalDeclD `fw valL fun fw => do
    let h₁ := (mkApp hE fw).headBeta
    let some (_, a, b) := (← instantiateMVars (← whnfR (← inferType h₁))).eq? | throwError "link_step_abs_eager: expected an equation"
    let lhs := mkAppN (mkConst ``linkRun) #[sTy, mkApp (mkConst cxN) fw, mkRawNatLit start, mkRawNatLit n, mkApp (mkConst (nm tgt "x" k)) fw]
    let rhs := mkApp2 (mkConst ``Option.some [.zero]) xTy (mkApp (mkConst (nm tgt "x" (k + 1))) fw)
    let pf := mkAppN (mkConst ``Eq.trans [one]) #[oTy, a, b, rhs, h₁, Run.Tail.eagerRefl one oTy b rhs]
    return (← mkForallFVars #[fw] (eqE one oTy lhs rhs), ← mkLambdaFVars #[fw] pf)
  addThm (nm tgt "l" k) type value

/-- Compose `Q.l<k>` into `Q.link : ∀ fw, linkRun (cx fw) 0 K (LinkSt.init w) = some (Q.x<N> fw)`
and `Q.booted : ∀ fw m, K ≤ m → bootL (cx fw) w m = some (Q.x<N> fw).st`. -/
elab "link_abs_run " q:ident " from " p:ident " using " c:ident " world " w:ident : command => liftTermElabM do
  let tgt := (← getCurrNamespace) ++ q.getId
  let src := p.getId
  let cxN ← realizeGlobalConstNoOverloadWithInfo c
  let wN ← realizeGlobalConstNoOverloadWithInfo w
  let ns ← constNats (src ++ `ns)
  let (xTy, sTy, oTy) ← linkTypes src
  let x (i : Nat) (fw : Lean.Expr) := mkApp (mkConst (nm tgt "x" i)) fw
  let cxF (fw : Lean.Expr) := mkApp (mkConst cxN) fw
  let run (fw : Lean.Expr) (fuel : Nat) (start : Lean.Expr) := mkAppN (mkConst ``linkRun) #[sTy, cxF fw, mkRawNatLit 0, mkRawNatLit fuel, start]
  let some' (e : Lean.Expr) := mkApp2 (mkConst ``Option.some [.zero]) xTy e
  let decl (name : Lean.Name) (mk : Lean.Expr → MetaM (Lean.Expr × Lean.Expr)) : MetaM Unit := do
    let (type, value) ← withLocalDeclD `fw valL fun fw => do
      let (ty, v) ← mk fw
      return (← mkForallFVars #[fw] ty, ← mkLambdaFVars #[fw] v)
    addThm name type value
  let mut total := 0
  let mut prev : Option Lean.Name := none
  for (n, i) in ns.zipIdx do
    let t := total
    let pv := prev
    decl (nm tgt "prefixLink" (i + 1)) fun fw => do
      let next := mkApp (mkConst (nm tgt "l" i)) fw
      let v := match pv with
        | none => next
        | some q => mkAppN (mkConst ``linkRun_trans) #[sTy, cxF fw, mkRawNatLit 0, mkRawNatLit t, mkRawNatLit n,
            x 0 fw, x i fw, x (i + 1) fw, mkApp (mkConst q) fw, next]
      pure (eqE one oTy (run fw (t + n) (x 0 fw)) (some' (x (i + 1) fw)), v)
    total := total + n
    prev := some (nm tgt "prefixLink" (i + 1))
  let N := ns.length
  let t := total
  decl (tgt ++ `link0) fun fw => pure (eqE one oTy (run fw t (x 0 fw)) (some' (x N fw)), mkApp (mkConst (nm tgt "prefixLink" N)) fw)
  let init := mkApp2 (mkConst ``LinkSt.init) sTy (mkConst wN)
  decl (tgt ++ `x0_eq) fun fw => pure (eqE one xTy init (x 0 fw), Run.Tail.eagerRefl one xTy init (x 0 fw))
  decl (tgt ++ `link) fun fw => pure (eqE one oTy (run fw t init) (some' (x N fw)),
    mkAppN (mkConst ``linkRun_initial) #[sTy, cxF fw, mkConst wN, mkRawNatLit t, x 0 fw, x N fw,
      mkApp (mkConst (tgt ++ `x0_eq)) fw, mkApp (mkConst (tgt ++ `link0)) fw])
  let done (fw : Lean.Expr) := mkApp2 (mkConst ``LinkSt.done) sTy (x N fw)
  decl (tgt ++ `done) fun fw => pure (eqE one (mkConst ``Bool) (done fw) (mkConst ``Bool.true),
    Run.Tail.eagerRefl one (mkConst ``Bool) (done fw) (mkConst ``Bool.true))
  decl (tgt ++ `booted) fun fw => do
    let v := mkAppN (mkConst ``boot_of_link) #[sTy, cxF fw, mkConst wN, mkRawNatLit t, x N fw,
      mkApp (mkConst (tgt ++ `link)) fw, mkApp (mkConst (tgt ++ `done)) fw]
    return (← inferType v, v)

end Host.Load.PromptStream
