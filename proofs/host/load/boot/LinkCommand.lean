import host.load.PromptStream
import host.load.run.tail.World
import host.load.ReadTail
namespace Host.Load.Boot
open Lean Elab Command Meta Host.Ts Host.Load

/-! # The prompt route's link over every unread readback suffix

The prompt stream's link states `Lp.x<k> fw` (`link_abs`) are computed in `Decode.world`. These
commands abstract them over the world's unread readback suffix (`worldTail tail`, as
`link_read_tail` does for the decode tail) and check the link for every prompt and suffix:

* `boot_link_states Q from Lp i to j`: `Q.x<k> fw tail`, `Lp.x<k> fw` with the native token queue after
  its two known heads replaced by `tail` (as the boundary states, `ReadTail.abstractTail`);
* `boot_link_chunk Q from L k`: `Q.l<k> : ∀ fw tail, linkRun (cxV fw) sₖ nₖ (Q.x<k> fw tail) =
  some (Q.x<k+1> fw tail)`, by eager `Eq.refl`; `boot_link_step Q from L k := h` through an equation;
* `boot_link_run Q from L`: `Q.booted : ∀ fw tail m, K ≤ m → bootL (cxV fw) (worldTail tail) m =
  some (Q.x<N> fw tail).st`. -/

private def nm (pre : Lean.Name) (tag : String) (i : Nat) : Lean.Name :=
  pre ++ Lean.Name.mkSimple (tag ++ toString i)

private def valL : Lean.Expr := mkApp (mkConst ``List [.zero]) (mkConst ``Val)
private def numL : Lean.Expr := mkApp (mkConst ``List [.zero]) (mkConst ``NumV)
private def one : Level := .succ .zero

private def addThm (name : Lean.Name) (type value : Lean.Expr) : CoreM Unit :=
  addDecl (.thmDecl { name, levelParams := [], type, value })

private def eqE (u : Level) (α a b : Lean.Expr) : Lean.Expr := mkApp3 (mkConst ``Eq [u]) α a b

private partial def natE (e : Lean.Expr) : Option Nat :=
  match e with
  | .lit (.natVal n) => some n
  | .mdata _ b => natE b
  | _ => if e.isAppOfArity ``OfNat.ofNat 3 then natE e.appFn!.appArg! else none

private partial def natListE (e : Lean.Expr) : Option (List Nat) :=
  match e.getAppFn, e.getAppArgs with
  | .const ``List.nil _, #[_] => some []
  | .const ``List.cons _, #[_, h, t] => do pure ((← natE h) :: (← natListE t))
  | _, _ => none

private def constNats (n : Lean.Name) : MetaM (List Nat) := do
  let some v := (← getConstInfo n).value? | throwError "{n} has no value"
  let some l := natListE v | throwError "{n} is not a literal list of numbers"
  pure l

private def withFT {α : Type} (k : Lean.Expr → Lean.Expr → TermElabM α) : TermElabM α :=
  withLocalDeclD `fw valL fun fw => withLocalDeclD `tail numL fun tail => k fw tail

/-- The native MLX record inside a link state (a cached search; the states share subterms heavily). -/
private def nativeOf (e : Lean.Expr) : Option Lean.Expr := e.find? (·.isAppOfArity ``Host.Mlx.Ffi.St.mk 13)

/-- `ReadTail.abstractTail` through the cached search. -/
private def abstractTokens (suffix tail : Lean.Expr) (e : Lean.Expr) : Except String Lean.Expr := do
  let some native := nativeOf e | throw "the state has no inline MLX native record"
  let args := native.getAppArgs
  let tokens ← ReadTail.replaceSuffix suffix tail args[5]!
  let replacement := mkAppN native.getAppFn (args.set! 5 tokens)
  pure (e.replace fun t => if t == native then some replacement else none)

elab "boot_link_states " q:ident " from " p:ident i:num " to " j:num : command => liftTermElabM do
  let tgt := (← getCurrNamespace) ++ q.getId
  let src := p.getId
  -- the token queue's suffix after its two known heads, as the link's first state holds it
  let some (.defnInfo d0) := (← getEnv).find? (nm src "x" 0) | throwError "boot_link_states: no link state 0"
  let suffix ← withLocalDeclD `fw valL fun fw => do
    let some native := nativeOf (d0.value.beta #[fw]) | throwError "boot_link_states: no native MLX state"
    match ReadTail.dropList 2 native.getAppArgs[5]! with
    | .ok e => pure e
    | .error e => throwError "boot_link_states: {e}"
  for k in [i.getNat:j.getNat + 1] do
    let some (.defnInfo d) := (← getEnv).find? (nm src "x" k) | throwError "boot_link_states: no link state {k}"
    let ty := d.type.bindingBody!
    let body ← withFT fun fw tail => do
      let v ← match abstractTokens suffix tail (d.value.beta #[fw]) with
        | .ok e => pure e
        | .error e => throwError "boot_link_states: link state {k}: {e}"
      mkLambdaFVars #[fw, tail] v
    let fty ← mkArrow valL (← mkArrow numL ty)
    addDecl (.defnDecl (mkDefinitionValEx (nm tgt "x" k) [] fty body (.regular 0) .safe [nm tgt "x" k]))

private def linkTypes (src : Lean.Name) : MetaM (Lean.Expr × Lean.Expr × Lean.Expr) := do
  let some (.defnInfo d) := (← getEnv).find? (nm src "x" 0) | throwError "no link chain {src}"
  pure (d.type, d.type.appArg!, mkApp (mkConst ``Option [.zero]) d.type)

private def linkStart (src : Lean.Name) (k : Nat) : MetaM (Nat × Nat) := do
  let ns ← constNats (src ++ `ns)
  let some n := ns[k]? | throwError "no link chunk {k}"
  pure ((ns.take k).foldl (· + ·) 0, n)

private def cxE (fw : Lean.Expr) : Lean.Expr := mkApp (mkConst ``RoutePrompt.cxV) fw

private def linkEq (tgt src : Lean.Name) (k : Nat) (fw tail : Lean.Expr) : MetaM (Lean.Expr × Lean.Expr × Lean.Expr) := do
  let (start, n) ← linkStart src k
  let (xTy, sTy, oTy) ← linkTypes src
  let lhs := mkAppN (mkConst ``linkRun) #[sTy, cxE fw, mkRawNatLit start, mkRawNatLit n, mkApp2 (mkConst (nm tgt "x" k)) fw tail]
  let rhs := mkApp2 (mkConst ``Option.some [.zero]) xTy (mkApp2 (mkConst (nm tgt "x" (k + 1))) fw tail)
  pure (lhs, rhs, oTy)

elab "boot_link_chunk " q:ident " from " p:ident i:num : command => liftTermElabM do
  let tgt := (← getCurrNamespace) ++ q.getId
  let src := p.getId
  withFT fun fw tail => do
    let (lhs, rhs, oTy) ← linkEq tgt src i.getNat fw tail
    addThm (nm tgt "l" i.getNat) (← mkForallFVars #[fw, tail] (eqE one oTy lhs rhs))
      (← mkLambdaFVars #[fw, tail] (Run.Tail.eagerRefl one oTy lhs rhs))

elab "boot_link_step " q:ident " from " p:ident i:num " := " h:term : command => liftTermElabM do
  let tgt := (← getCurrNamespace) ++ q.getId
  let src := p.getId
  let hE ← instantiateMVars (← Term.elabTermAndSynthesize h none)
  withFT fun fw tail => do
    let (lhs, rhs, oTy) ← linkEq tgt src i.getNat fw tail
    let h₁ := (mkApp2 hE fw tail).headBeta
    let some (_, a, b) := (← instantiateMVars (← whnfR (← inferType h₁))).eq? | throwError "boot_link_step: expected an equation"
    let pf := mkAppN (mkConst ``Eq.trans [one]) #[oTy, a, b, rhs, h₁, Run.Tail.eagerRefl one oTy b rhs]
    addThm (nm tgt "l" i.getNat) (← mkForallFVars #[fw, tail] (eqE one oTy lhs rhs)) (← mkLambdaFVars #[fw, tail] pf)

elab "boot_link_run " q:ident " from " p:ident : command => liftTermElabM do
  let tgt := (← getCurrNamespace) ++ q.getId
  let src := p.getId
  let ns ← constNats (src ++ `ns)
  let (xTy, sTy, oTy) ← linkTypes src
  let x (i : Nat) (fw tail : Lean.Expr) := mkApp2 (mkConst (nm tgt "x" i)) fw tail
  let run (fw : Lean.Expr) (fuel : Nat) (start : Lean.Expr) :=
    mkAppN (mkConst ``linkRun) #[sTy, cxE fw, mkRawNatLit 0, mkRawNatLit fuel, start]
  let some' (e : Lean.Expr) := mkApp2 (mkConst ``Option.some [.zero]) xTy e
  let decl (name : Lean.Name) (mk : Lean.Expr → Lean.Expr → MetaM (Lean.Expr × Lean.Expr)) : TermElabM Unit :=
    withFT fun fw tail => do
      let (ty, v) ← mk fw tail
      addThm name (← mkForallFVars #[fw, tail] ty) (← mkLambdaFVars #[fw, tail] v)
  let mut total := 0
  let mut prev : Option Lean.Name := none
  for (n, i) in ns.zipIdx do
    let t := total
    let pv := prev
    decl (nm tgt "prefixLink" (i + 1)) fun fw tail => do
      let next := mkApp2 (mkConst (nm tgt "l" i)) fw tail
      let v := match pv with
        | none => next
        | some q => mkAppN (mkConst ``linkRun_trans) #[sTy, cxE fw, mkRawNatLit 0, mkRawNatLit t, mkRawNatLit n,
            x 0 fw tail, x i fw tail, x (i + 1) fw tail, mkApp2 (mkConst q) fw tail, next]
      pure (eqE one oTy (run fw (t + n) (x 0 fw tail)) (some' (x (i + 1) fw tail)), v)
    total := total + n
    prev := some (nm tgt "prefixLink" (i + 1))
  let N := ns.length
  let t := total
  decl (tgt ++ `link0) fun fw tail =>
    pure (eqE one oTy (run fw t (x 0 fw tail)) (some' (x N fw tail)), mkApp2 (mkConst (nm tgt "prefixLink" N)) fw tail)
  let wE (tail : Lean.Expr) := mkApp (mkConst ``Run.Tail.worldTail) tail
  let init (tail : Lean.Expr) := mkApp2 (mkConst ``LinkSt.init) sTy (wE tail)
  decl (tgt ++ `x0_eq) fun fw tail =>
    pure (eqE one xTy (init tail) (x 0 fw tail), Run.Tail.eagerRefl one xTy (init tail) (x 0 fw tail))
  decl (tgt ++ `link) fun fw tail => pure (eqE one oTy (run fw t (init tail)) (some' (x N fw tail)),
    mkAppN (mkConst ``linkRun_initial) #[sTy, cxE fw, wE tail, mkRawNatLit t, x 0 fw tail, x N fw tail,
      mkApp2 (mkConst (tgt ++ `x0_eq)) fw tail, mkApp2 (mkConst (tgt ++ `link0)) fw tail])
  let done (fw tail : Lean.Expr) := mkApp2 (mkConst ``LinkSt.done) sTy (x N fw tail)
  decl (tgt ++ `done) fun fw tail => pure (eqE one (mkConst ``Bool) (done fw tail) (mkConst ``Bool.true),
    Run.Tail.eagerRefl one (mkConst ``Bool) (done fw tail) (mkConst ``Bool.true))
  decl (tgt ++ `booted) fun fw tail => do
    let v := mkAppN (mkConst ``boot_of_link) #[sTy, cxE fw, wE tail, mkRawNatLit t, x N fw tail,
      mkApp2 (mkConst (tgt ++ `link)) fw tail, mkApp2 (mkConst (tgt ++ `done)) fw tail]
    return (← inferType v, v)

end Host.Load.Boot
