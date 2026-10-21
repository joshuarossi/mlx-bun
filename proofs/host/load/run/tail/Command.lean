import host.load.ReadTail
import host.load.Compose
namespace Host.Load.Run.Tail
open Lean Elab Command Meta Host.Ts

/-! Commands for the boot-to-first-cut run with an arbitrary unread native
token suffix. They only build terms; every theorem is checked by the kernel.

The kernel skips numeral acceleration when either side of a definitional
equation has a free variable (`lazy_delta_reduction`). The unread suffix is
such a variable, and it lies beside every MLX native field, so unevaluated
field arithmetic would unfold in unary. The proofs therefore pass
`eagerReduce (Eq.refl a)` as an application argument, which asks the kernel to
reduce numerals as it does for closed terms. Statements are unchanged. -/

private def nm (pre : Lean.Name) (tag : String) (i : Nat) : Lean.Name :=
  pre ++ Lean.Name.mkSimple (tag ++ toString i)

private def listTy : Lean.Expr := mkApp (mkConst ``List [.zero]) (mkConst ``NumV)

private def eqE (u : Level) (α a b : Lean.Expr) : Lean.Expr := mkApp3 (mkConst ``Eq [u]) α a b

/-- `id (eagerReduce (Eq.refl a)) : a = b`, checked with eager reduction. -/
def eagerRefl (u : Level) (α a b : Lean.Expr) : Lean.Expr :=
  mkApp2 (mkConst ``id [.zero]) (eqE u α a b)
    (mkApp2 (mkConst ``eagerReduce [.zero]) (eqE u α a a) (mkApp2 (mkConst ``Eq.refl [u]) α a))

private def addThm (name : Lean.Name) (type value : Lean.Expr) : CoreM Unit :=
  addDecl (.thmDecl { name, levelParams := [], type, value })

/-- `kernel_rfl_eager n : ∀ xs, a = b`: proved by eager `Eq.refl a`, checked
only by the kernel. -/
elab "kernel_rfl_eager " n:ident " : " t:term : command => do
  let ns ← getCurrNamespace
  liftTermElabM do
    let ty ← Term.elabType t
    Term.synthesizeSyntheticMVarsNoPostponing
    let ty ← instantiateMVars ty
    let value ← forallTelescope ty fun xs body => do
      let some (α, a, b) := body.eq? | throwError "kernel_rfl_eager: expected an equation"
      mkLambdaFVars xs (eagerRefl (← getLevel α) α a b)
    addThm (ns ++ n.getId) ty value

/-! ## Decode chunks -/

private def chunkTypes (pre : Lean.Name) : Lean.Expr × Lean.Expr × Lean.Expr :=
  let F := mkConst (pre ++ `F)
  let stTy := mkApp (mkConst ``St) (mkApp (mkConst ``Ffi.S) F)
  let pairTy := mkApp2 (mkConst ``Prod [.zero, .zero]) stTy (mkConst ``SSrv)
  (stTy, pairTy, mkApp (mkConst ``Option [.zero]) pairTy)

/-- `host_chunk_read_tail` with eager kernel reduction: the same statements
`tac<k> : ∀ tail, runS P.F kₖ (P.ta<k> tail) P.S<k> = some (P.ta<k+1> tail, P.S<k+1>)`
and `tc<k>`, its specialization to the original suffix. -/
elab "host_chunk_read_tail_eager " p:ident i:num : command => liftTermElabM do
  let pre := (← getCurrNamespace) ++ p.getId
  let k := i.getNat
  let t0 ← IO.monoMsNow
  let ks ← unsafe evalConst (List Nat) (pre ++ `ks)
  let some n := ks[k]? | throwError "host_chunk_read_tail_eager: no chunk {k}"
  let F := mkConst (pre ++ `F)
  let (stTy, pairTy, optionTy) := chunkTypes pre
  let eqAt (a b : Lean.Expr) :=
    let lhs := mkAppN (mkConst ``runS) #[F, mkRawNatLit n, a, mkConst (nm pre "S" k)]
    let rhs := mkApp2 (mkConst ``Option.some [.zero]) pairTy (mkApp4 (mkConst ``Prod.mk [.zero, .zero]) stTy (mkConst ``SSrv) b (mkConst (nm pre "S" (k + 1))))
    (lhs, rhs)
  let (lhs, rhs) := eqAt (mkApp (mkConst (nm pre "ta" k)) (.bvar 0)) (mkApp (mkConst (nm pre "ta" (k + 1))) (.bvar 0))
  addThm (nm pre "tac" k) (.forallE `tail listTy (eqE (.succ .zero) optionTy lhs rhs) .default)
    (.lam `tail listTy (eagerRefl (.succ .zero) optionTy lhs rhs) .default)
  let (lhs, rhs) := eqAt (mkConst (nm pre "s" k)) (mkConst (nm pre "s" (k + 1)))
  addThm (nm pre "tc" k) (eqE (.succ .zero) optionTy lhs rhs) (mkApp (mkConst (nm pre "tac" k)) (mkConst (pre ++ `tokenBase)))
  -- Optional timing trace, as for `host_chunk` (`HOST_CHUNK_TRACE`).
  if let some path ← IO.getEnv "HOST_CHUNK_TRACE" then
    let ms := (← IO.monoMsNow) - t0
    IO.FS.withFile path .append fun h => h.putStrLn s!"tail chunk {k}: {ms} ms"

/-- `tail_compose P name := t₁ … tₙ` composes theorems of the form
`∀ tail, runS P.F n (a tail) A = some (b tail, B)` that meet end to start into
`name : ∀ tail, runS P.F (n₁ + … + nₙ) (a₁ tail) A₁ = some (bₙ tail, Bₙ)`. -/
elab "tail_compose " p:ident name:ident " := " ts:ident* : command => liftTermElabM do
  let ns ← getCurrNamespace
  let pre := ns ++ p.getId
  let F := mkConst (pre ++ `F)
  let (stTy, pairTy, optionTy) := chunkTypes pre
  let (type, value) ← withLocalDeclD `tail listTy fun tail => do
    let mut acc : Option (Lean.Expr × Nat × Lean.Expr × Lean.Expr × Lean.Expr × Lean.Expr) := none
    for t in ts do
      let c ← realizeGlobalConstNoOverloadWithInfo t
      let body ← instantiateForall (← getConstInfo c).type #[tail]
      let some (_, lhs, rhs) := body.eq? | throwError "tail_compose: {c} is not an equation"
      let #[_, nE, s, S] := lhs.getAppArgs | throwError "tail_compose: {c} is not a run"
      let some n := nE.rawNatLit? | throwError "tail_compose: {c} has no literal fuel"
      let #[_, pr] := rhs.getAppArgs | throwError "tail_compose: {c} has no result"
      let #[_, _, s', S'] := pr.getAppArgs | throwError "tail_compose: {c} has no result pair"
      let pf := mkApp (mkConst c) tail
      acc ← match acc with
        | none => pure (some (pf, n, s, S, s', S'))
        | some (pf₀, m, s₀, S₀, s₁, S₁) => do
          unless s == s₁ && S == S₁ do throwError "tail_compose: {c} does not start where the previous run ends"
          pure (some (mkAppN (mkConst ``runS_trans) #[F, mkRawNatLit m, mkRawNatLit n, s₀, s₁, s', S₀, S₁, S', pf₀, pf], m + n, s₀, S₀, s', S'))
    let some (pf, m, s₀, S₀, s₁, S₁) := acc | throwError "tail_compose: no theorems"
    let lhs := mkAppN (mkConst ``runS) #[F, mkRawNatLit m, s₀, S₀]
    let rhs := mkApp2 (mkConst ``Option.some [.zero]) pairTy (mkApp4 (mkConst ``Prod.mk [.zero, .zero]) stTy (mkConst ``SSrv) s₁ S₁)
    return (← mkForallFVars #[tail] (eqE (.succ .zero) optionTy lhs rhs), ← mkLambdaFVars #[tail] pf)
  addThm (ns ++ name.getId) type value

/-! ## Link chain -/

/-- `link_read_tail Q from L i, j replace w by f`: `Q.x<k> : List NumV → LinkSt _`
for `k ∈ i … j`, the link state `L.x<k>` with every occurrence of the world
constant `w` replaced by `f tail`. -/
elab "link_read_tail " q:ident " from " p:ident i:num ", " j:num " replace " w:ident " by " f:ident : command => liftTermElabM do
  let tgt := (← getCurrNamespace) ++ q.getId
  let src := p.getId
  let wName ← realizeGlobalConstNoOverloadWithInfo w
  let fName ← realizeGlobalConstNoOverloadWithInfo f
  for k in [i.getNat:j.getNat + 1] do
    let some (.defnInfo d) := (← getEnv).find? (nm src "x" k) | throwError "link_read_tail: no link state {k}"
    let body ← withLocalDeclD `tail listTy fun tail => do
      let v := d.value.replace fun e => if e.isConstOf wName then some (mkApp (mkConst fName) tail) else none
      unless v.containsFVar tail.fvarId! do throwError "link_read_tail: link state {k} does not name {wName}"
      mkLambdaFVars #[tail] v
    addDecl (.defnDecl { name := nm tgt "x" k, levelParams := [], type := ← mkArrow listTy d.type, value := body, hints := .regular 0, safety := .safe })

private def linkTypes (src : Lean.Name) : MetaM (Lean.Expr × Lean.Expr × Lean.Expr) := do
  let some (.defnInfo d) := (← getEnv).find? (nm src "x" 0) | throwError "no link chain {src}"
  pure (d.type, d.type.appArg!, mkApp (mkConst ``Option [.zero]) d.type)

private def linkStart (src : Lean.Name) (k : Nat) : MetaM (Nat × Nat) := do
  let ns ← unsafe evalConst (List Nat) (src ++ `ns)
  let some n := ns[k]? | throwError "no link chunk {k}"
  pure ((ns.take k).foldl (· + ·) 0, n)

/-- `Q.l<k> : ∀ tail, linkRun L.cx sₖ nₖ (Q.x<k> tail) = some (Q.x<k+1> tail)`. -/
elab "link_chunk_read_tail_eager " q:ident " from " p:ident i:num : command => liftTermElabM do
  let tgt := (← getCurrNamespace) ++ q.getId
  let src := p.getId
  let k := i.getNat
  let (start, n) ← linkStart src k
  let (xTy, sTy, oTy) ← linkTypes src
  let lhs := mkAppN (mkConst ``linkRun) #[sTy, mkConst (src ++ `cx), mkRawNatLit start, mkRawNatLit n, mkApp (mkConst (nm tgt "x" k)) (.bvar 0)]
  let rhs := mkApp2 (mkConst ``Option.some [.zero]) xTy (mkApp (mkConst (nm tgt "x" (k + 1))) (.bvar 0))
  addThm (nm tgt "l" k) (.forallE `tail listTy (eqE (.succ .zero) oTy lhs rhs) .default)
    (.lam `tail listTy (eagerRefl (.succ .zero) oTy lhs rhs) .default)

/-- A one-step link theorem through an equation `h : ∀ tail, linkRun … = r tail`
(for example a scanned user-module step), finished by eager `Eq.refl`. -/
elab "link_step_read_tail_eager " q:ident " from " p:ident i:num " := " h:term : command => liftTermElabM do
  let tgt := (← getCurrNamespace) ++ q.getId
  let src := p.getId
  let k := i.getNat
  let (start, n) ← linkStart src k
  let (xTy, sTy, oTy) ← linkTypes src
  let hE ← instantiateMVars (← Term.elabTermAndSynthesize h none)
  let (type, value) ← withLocalDeclD `tail listTy fun tail => do
    let h₁ := (mkApp hE tail).headBeta
    let some (_, a, b) := (← instantiateMVars (← whnfR (← inferType h₁))).eq? | throwError "link_step_read_tail_eager: expected an equation"
    let lhs := mkAppN (mkConst ``linkRun) #[sTy, mkConst (src ++ `cx), mkRawNatLit start, mkRawNatLit n, mkApp (mkConst (nm tgt "x" k)) tail]
    let rhs := mkApp2 (mkConst ``Option.some [.zero]) xTy (mkApp (mkConst (nm tgt "x" (k + 1))) tail)
    let pf := mkAppN (mkConst ``Eq.trans [.succ .zero]) #[oTy, a, b, rhs, h₁, eagerRefl (.succ .zero) oTy b rhs]
    return (← mkForallFVars #[tail] (eqE (.succ .zero) oTy lhs rhs), ← mkLambdaFVars #[tail] pf)
  addThm (nm tgt "l" k) type value

/-- Compose `Q.l<k>` into `Q.link0` through named prefixes, then `Q.x0_eq`,
`Q.link`, `Q.done` and
`Q.booted : ∀ tail m, K ≤ m → bootL L.cx (f tail) m = some (Q.x<N> tail).st`. -/
elab "link_tail_run " q:ident " from " p:ident " world " f:ident : command => liftTermElabM do
  let tgt := (← getCurrNamespace) ++ q.getId
  let src := p.getId
  let fName ← realizeGlobalConstNoOverloadWithInfo f
  let ns ← unsafe evalConst (List Nat) (src ++ `ns)
  let (xTy, sTy, oTy) ← linkTypes src
  let cx := mkConst (src ++ `cx)
  let one := Level.succ .zero
  let x (i : Nat) (tail : Lean.Expr) := mkApp (mkConst (nm tgt "x" i)) tail
  let run (fuel : Nat) (start : Lean.Expr) := mkAppN (mkConst ``linkRun) #[sTy, cx, mkRawNatLit 0, mkRawNatLit fuel, start]
  let some' (e : Lean.Expr) := mkApp2 (mkConst ``Option.some [.zero]) xTy e
  let decl (name : Lean.Name) (mk : Lean.Expr → MetaM (Lean.Expr × Lean.Expr)) : MetaM Unit := do
    let (type, value) ← withLocalDeclD `tail listTy fun tail => do
      let (ty, v) ← mk tail
      return (← mkForallFVars #[tail] ty, ← mkLambdaFVars #[tail] v)
    addThm name type value
  let mut total := 0
  let mut prev : Option Lean.Name := none
  for (n, i) in ns.zipIdx do
    let t := total
    let pv := prev
    decl (nm tgt "prefixLink" (i + 1)) fun tail => do
      let next := mkApp (mkConst (nm tgt "l" i)) tail
      let v := match pv with
        | none => next
        | some p => mkAppN (mkConst ``linkRun_trans) #[sTy, cx, mkRawNatLit 0, mkRawNatLit t, mkRawNatLit n,
            x 0 tail, x i tail, x (i + 1) tail, mkApp (mkConst p) tail, next]
      pure (eqE one oTy (run (t + n) (x 0 tail)) (some' (x (i + 1) tail)), v)
    total := total + n
    prev := some (nm tgt "prefixLink" (i + 1))
  let N := ns.length
  let t := total
  decl (tgt ++ `link0) fun tail => pure (eqE one oTy (run t (x 0 tail)) (some' (x N tail)), mkApp (mkConst (nm tgt "prefixLink" N)) tail)
  let init (tail : Lean.Expr) := mkApp2 (mkConst ``LinkSt.init) sTy (mkApp (mkConst fName) tail)
  decl (tgt ++ `x0_eq) fun tail => pure (eqE one xTy (init tail) (x 0 tail), eagerRefl one xTy (init tail) (x 0 tail))
  decl (tgt ++ `link) fun tail => pure (eqE one oTy (run t (init tail)) (some' (x N tail)),
    mkAppN (mkConst ``linkRun_initial) #[sTy, cx, mkApp (mkConst fName) tail, mkRawNatLit t, x 0 tail, x N tail,
      mkApp (mkConst (tgt ++ `x0_eq)) tail, mkApp (mkConst (tgt ++ `link0)) tail])
  let done (tail : Lean.Expr) := mkApp2 (mkConst ``LinkSt.done) sTy (x N tail)
  decl (tgt ++ `done) fun tail => pure (eqE one (mkConst ``Bool) (done tail) (mkConst ``Bool.true),
    eagerRefl one (mkConst ``Bool) (done tail) (mkConst ``Bool.true))
  decl (tgt ++ `booted) fun tail => do
    let v := mkAppN (mkConst ``boot_of_link) #[sTy, cx, mkApp (mkConst fName) tail, mkRawNatLit t, x N tail,
      mkApp (mkConst (tgt ++ `link)) tail, mkApp (mkConst (tgt ++ `done)) tail]
    return (← inferType v, v)

end Host.Load.Run.Tail
