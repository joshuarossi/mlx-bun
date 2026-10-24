import host.load.nat.Gen
namespace Host.Ts.FfiNat
open Lean Meta Elab Tactic Command

/-! # `rel_derive`: the relation lemma of an interpreter definition

For `c : (F : Ffi) → A₁ → … → B`, `rel_derive c` states and proves, over
worlds `F1`, `F2` with `[FfiRel F1 F2] [FfiSim F1 F2]`:

* arguments: shared where the types agree; a machine state `s` of the first
  world against `s.reFfi x` with `FfiRel.R s.ffi x`; a native state pair
  related by `FfiRel.R`; other pairs by their canonical relation;
* a computation result: `MR CRel.r (c F1 …) (c F2 …)`;
* a pure result: `c F2 … = c F1 …`, with machine states of the result
  `reFfi`'d with the first state argument's `x` (a `rel_simp` lemma); for a
  machine state result also `(c F … s …).ffi = s.ffi` (`c_ffi`, any world).

The proof unfolds `c` and runs `rel_auto`. -/

/-- `e` (of type `r1`, first world) mapped to type `r2` (second world), states `reFfi`'d with `x`. -/
partial def fmapTo (x : Lean.Expr) (r1 r2 : Lean.Expr) (e : Lean.Expr) : MetaM Lean.Expr := do
  if ← isDefEq r1 r2 then return e
  let r1' ← whnfI r1
  let r2' ← whnfI r2
  if r1'.isAppOfArity ``St 1 && r2'.isAppOfArity ``St 1 then
    return mkApp4 (mkConst ``St.reFfi) r1'.appArg! r2'.appArg! e x
  if r1'.isAppOfArity ``Prod 2 && r2'.isAppOfArity ``Prod 2 then
    let a ← fmapTo x (r1'.getArg! 0) (r2'.getArg! 0) (← mkAppM ``Prod.fst #[e])
    let b ← fmapTo x (r1'.getArg! 1) (r2'.getArg! 1) (← mkAppM ``Prod.snd #[e])
    return ← mkAppM ``Prod.mk #[a, b]
  if r1'.isAppOfArity ``Option 1 && r2'.isAppOfArity ``Option 1 then
    let f ← withLocalDeclD `a r1'.appArg! fun a => do
      mkLambdaFVars #[a] (← fmapTo x r1'.appArg! r2'.appArg! a)
    return ← mkAppM ``Option.map #[f, e]
  if r1'.isAppOfArity ``List 1 && r2'.isAppOfArity ``List 1 then
    let f ← withLocalDeclD `a r1'.appArg! fun a => do
      mkLambdaFVars #[a] (← fmapTo x r1'.appArg! r2'.appArg! a)
    return ← mkAppM ``List.map #[f, e]
  throwError "rel_derive: no map from {r1} to {r2}"

/-- Whether the native state appears in a type. -/
def mentionsSt (t : Lean.Expr) : MetaM Bool := do
  let t ← instantiateMVars t
  return t.find? (fun e => e.isConstOf ``St || e.isConstOf ``Ffi.S) |>.isSome

def runProof (goal : Lean.Expr) (tac : TSyntax `tactic) : TermElabM Lean.Expr := do
  let m ← mkFreshExprMVar goal
  let gs ← Term.withoutErrToSorry <| Tactic.run m.mvarId! (evalTactic tac)
  unless gs.isEmpty do
    let msgs ← gs.mapM fun g => do return m!"{g}"
    throwError "rel_derive: unsolved goals\n{MessageData.joinSep msgs "\n\n"}"
  let pf ← instantiateMVars m
  if pf.hasExprMVar then
    let ms := (pf.collectMVars {}).result
    let tys ← ms.mapM fun mv => do return m!"{mkMVar mv} : {← inferType (mkMVar mv)}"
    throwError "rel_derive: proof has metavariables\n{MessageData.joinSep tys.toList "\n"}"
  return pf

def addThm (n : Lean.Name) (ty pf : Lean.Expr) : TermElabM Unit := do
  let ty ← instantiateMVars ty
  let pf ← instantiateMVars pf
  let lvls := (collectLevelParams {} ty).params.toList
  addDecl <| .thmDecl { name := n, levelParams := lvls, type := ty, value := pf }

partial def telescope2 (t1 t2 : Lean.Expr) (fvars args1 args2 states : Array Lean.Expr)
    (k : Array Lean.Expr → Array Lean.Expr → Array Lean.Expr → Array Lean.Expr → Lean.Expr → Lean.Expr → TermElabM Unit) : TermElabM Unit := do
  let t1 ← whnfI t1
  let t2 ← whnfI t2
  match t1, t2 with
  | .forallE _ d1 b1 bi, .forallE _ d2 b2 _ =>
    let n := Lean.Name.mkSimple s!"a{args1.size}"
    if ← isDefEq d1 d2 then
      withLocalDecl n bi d1 fun a =>
        telescope2 (b1.instantiate1 a) (b2.instantiate1 a) (fvars.push a) (args1.push a) (args2.push a) states k
    else
      let d1' ← whnfI d1
      let d2' ← whnfI d2
      if d1'.isAppOfArity ``St 1 && d2'.isAppOfArity ``St 1 then
        withLocalDeclD n d1 fun s => withLocalDeclD (n.appendAfter "_x") d2'.appArg! fun x => do
          let hxTy ← mkAppM ``FfiRel.R #[← mkAppM ``St.ffi #[s], x]
          withLocalDeclD (n.appendAfter "_hx") hxTy fun hx => do
            let s2 := mkApp4 (mkConst ``St.reFfi) d1'.appArg! d2'.appArg! s x
            telescope2 (b1.instantiate1 s) (b2.instantiate1 s2) (fvars ++ #[s, x, hx]) (args1.push s) (args2.push s2)
              (states.push x) k
      else
        withLocalDeclD n d1 fun a1 => withLocalDeclD (n.appendAfter "'") d2 fun a2 => do
          let hTy ← mkAppM ``CRel.r #[a1, a2]
          withLocalDeclD (n.appendAfter "_h") hTy fun h =>
            telescope2 (b1.instantiate1 a1) (b2.instantiate1 a2) (fvars ++ #[a1, a2, h]) (args1.push a1) (args2.push a2)
              states k
  | _, _ => k fvars args1 args2 states t1 t2

/-- Mode of a constant: world-typed (`(F : Ffi) → …`), polymorphic in the native state type
(`{S : Type} → …`), or independent of both. -/
inductive Mode where
  | world | state | indep

/-- The proof: unfold `c` (after induction on argument `a{i}`, generalizing the later ones) and `rel_auto`. -/
def mkTac (c : Lean.Name) (fvars : Array Lean.Expr) (rec? : Option Nat) : TermElabM (TSyntax `tactic) := do
  let cid := mkIdent c
  match rec? with
  | none => `(tactic| (unfold $cid:ident; (try dsimp (config := { proj := false }) only); rel_auto))
  | some i =>
    let v := Lean.Name.mkSimple s!"a{i}"
    let mut gen : Array Lean.Name := #[]
    for e in fvars do
      let n ← e.fvarId!.getUserName
      if n != v then gen := gen.push n
    let vid := mkIdent v
    let gids := gen.map mkIdent
    if gids.isEmpty then `(tactic| (induction $vid:ident <;> (unfold $cid:ident; (try dsimp (config := { proj := false }) only); rel_auto)))
    else `(tactic| (induction $vid:ident generalizing $gids* <;> (unfold $cid:ident; (try dsimp (config := { proj := false }) only); rel_auto)))

/-- Whether the result after the arrows of `t` is a computation (`M` is itself a function type). -/
partial def resultIsM (t : Lean.Expr) : MetaM Bool := do
  match ← whnfI t with
  | .forallE n d b bi => withLocalDecl n bi d fun a => resultIsM (b.instantiate1 a)
  | r => return r.isAppOfArity ``M 1

def deriveOne (c : Lean.Name) (mode : Mode) (rec? : Option Nat) : TermElabM Unit := do
  let ci ← getConstInfo c
  let lvls := ci.levelParams.map mkLevelParam
  let cE := mkConst c lvls
  let ffiT := mkConst ``Ffi
  withLocalDeclD `F1 ffiT fun F1 => withLocalDeclD `F2 ffiT fun F2 => do
  withLocalDecl `inst .instImplicit (mkApp2 (mkConst ``FfiRel) F1 F2) fun inst => do
  -- a pure function needs only reads and addresses
  let resM ← do
    let t ← match mode with
      | .world => inferType (mkApp cE F1)
      | .state => inferType (mkApp cE (mkApp (mkConst ``Ffi.S) F1))
      | .indep => inferType cE
    resultIsM t
  let simCls := if resM then ``FfiSim else ``FfiReadSim
  withLocalDecl `sim .instImplicit (mkApp3 (mkConst simCls) F1 F2 inst) fun sim => do
    let S1 := mkApp (mkConst ``Ffi.S) F1
    let S2 := mkApp (mkConst ``Ffi.S) F2
    let (h1, h2) := match mode with
      | .world => (mkApp cE F1, mkApp cE F2)
      | .state => (mkApp cE S1, mkApp cE S2)
      | .indep => (cE, cE)
    let t1 ← inferType h1
    let t2 ← inferType h2
    telescope2 t1 t2 #[] #[] #[] #[] fun fvars args1 args2 states r1 r2 => do
      let lhs := mkAppN h1 args1
      let rhs := mkAppN h2 args2
      let ctx := match mode with
        | .indep => fvars
        | _ => #[F1, F2, inst, sim] ++ fvars
      let tac ← mkTac c fvars rec?
      let r1' ← whnfI r1
      if r1'.isAppOfArity ``M 1 then
        let r2' ← whnfI r2
        let instR ← synthInstance (← mkAppM ``CRel #[r1'.appArg!, r2'.appArg!])
        let R := mkApp3 (mkConst ``CRel.r [Level.one, Level.one]) r1'.appArg! r2'.appArg! instR
        let concl ← mkAppM ``MR #[R, lhs, rhs]
        let pf ← runProof concl tac
        addThm (relName c) (← mkForallFVars ctx concl) (← mkLambdaFVars ctx pf)
      else
        let x := states[0]?
        let rhsTarget ← if ← isDefEq r1 r2 then pure lhs else
          match x with
          | some x => fmapTo x r1 r2 lhs
          | none => throwError "rel_derive: state result without a state argument"
        let concl ← mkEq rhs rhsTarget
        let pf ← runProof concl tac
        let n := relName c
        addThm n (← mkForallFVars ctx concl) (← mkLambdaFVars ctx pf)
        liftCommandElabM <| elabCommand (← `(attribute [rel_simp] $(mkIdent n):ident))
        -- the partially applied form, for the function passed to a combinator (`List.mapM`, …)
        if rhsTarget == lhs then
          let mut k := args1.size
          while k > 0 && args1[k-1]! == args2[k-1]! && args1[k-1]!.isFVar do k := k - 1
          if k < args1.size && k > 0 then
            let trailing := args1.extract k args1.size
            let f2 := mkAppN h2 (args2.extract 0 k)
            let f1 := mkAppN h1 (args1.extract 0 k)
            let conclEta ← mkEq f2 f1
            -- funext over the trailing arguments, the last innermost
            let mut pfEta := pf
            for y in trailing.reverse do
              pfEta ← mkAppM ``funext #[← mkLambdaFVars #[y] pfEta]
            let ctxEta := ctx.filter fun e => !trailing.contains e
            let nEta := n.appendAfter "_eta"
            addThm nEta (← mkForallFVars ctxEta conclEta) (← mkLambdaFVars ctxEta pfEta)
            liftCommandElabM <| elabCommand (← `(attribute [rel_simp] $(mkIdent nEta):ident))

/-- Binders of `t` named `a0`, `a1`, …. -/
partial def telescopeNamed (t : Lean.Expr) (xs : Array Lean.Expr) (k : Array Lean.Expr → Lean.Expr → TermElabM Unit) : TermElabM Unit := do
  match ← whnfI t with
  | .forallE _ d b bi =>
    withLocalDecl (Lean.Name.mkSimple s!"a{xs.size}") bi d fun a => telescopeNamed (b.instantiate1 a) (xs.push a) k
  | r => k xs r

/-- `(c F … s …).ffi = s.ffi` for a pure function returning a machine state: the relation lemma at the
world related to itself by equality (`idRel`), with `s.reFfi s.ffi = s`. -/
def deriveFfi (c : Lean.Name) (_rec? : Option Nat) : TermElabM Unit := do
  let relC := relName c
  unless (← getEnv).contains relC do return
  let ci ← getConstInfo c
  let lvls := ci.levelParams.map mkLevelParam
  withLocalDeclD `F (mkConst ``Ffi) fun F => do
    let t ← instantiateForall ci.type #[F]
    telescopeNamed t #[] fun xs r => do
      let r' ← whnfI r
      let some s ← xs.findM? (fun a => do return (← whnfI (← inferType a)).isAppOfArity ``St 1) | return
      let app := mkAppN (mkConst c lvls) (#[F] ++ xs)
      -- the relation lemma at the identity world, its first-world arguments the telescope's
      let lvlsR := (← getConstInfo relC).levelParams.map mkLevelParam
      let lem := mkAppN (mkConst relC lvlsR) #[F, F, mkApp (mkConst ``idRel) F, mkApp (mkConst ``idReadSim) F]
      let (mvs, _, eq) ← forallMetaTelescopeReducing (← inferType lem)
      let some (_, l2, _) := eq.eq? | return
      let xs2 ← xs.mapM fun a => do
        if (← whnfI (← inferType a)).isAppOfArity ``St 1 then mkAppM ``St.reFfi #[a, ← mkAppM ``St.ffi #[a]]
        else pure a
      unless ← isDefEq l2 (mkAppN (mkConst c lvls) (#[F] ++ xs2)) do return
      for m in mvs do
        unless ← m.mvarId!.isAssigned do
          let ty ← whnfI (← inferType m)
          if ty.isAppOfArity ``Eq 3 then
            unless ← isDefEq m (← mkEqRefl (ty.getArg! 1)) do return
          else return
      -- h : c F (s.reFfi s.ffi) … = f (c F s …), definitionally app = f app
      let h ← instantiateMVars (mkAppN lem mvs)
      let some (_, _, fapp) := (← instantiateMVars (← inferType h)).eq? | return
      let hApp ← mkExpectedTypeHint h (← mkEq app fapp)
      let isSt (e : Lean.Expr) : TermElabM Bool := do return (← whnfI e).isAppOfArity ``St 1
      if r'.isAppOfArity ``Option 1 then
        -- `c … = some t → (… t …).ffi = s.ffi`
        let inner ← whnfI r'.appArg!
        withLocalDeclD `t r'.appArg! fun tv => do
          let proj ← if ← isSt inner then pure tv
            else if inner.isAppOfArity ``Prod 2 then
              if ← isSt (inner.getArg! 0) then mkAppM ``Prod.fst #[tv]
              else if ← isSt (inner.getArg! 1) then mkAppM ``Prod.snd #[tv]
              else return
            else return
          let hyp ← mkEq app (← mkAppM ``Option.some #[tv])
          withLocalDeclD `h hyp fun hv => do
            let concl ← mkEq (← mkAppM ``St.ffi #[proj]) (← mkAppM ``St.ffi #[s])
            -- fapp is `Option.map g app`: some t = app = Option.map g app = Option.map g (some t) = some (g t)
            unless fapp.isAppOfArity ``Option.map 4 do return
            let gfn := fapp.getArg! 2
            let e1 ← mkEqSymm hv
            let e3 ← mkCongrArg (mkApp3 (mkConst ``Option.map [levelZero, levelZero]) r'.appArg! r'.appArg! gfn) hv
            let chain ← mkEqTrans (← mkEqTrans e1 hApp) e3
            let someG ← mkEq (← mkAppM ``Option.some #[tv]) (← mkAppM ``Option.some #[mkApp gfn tv])
            let tEq ← mkAppM ``Option.some.inj #[← mkExpectedTypeHint chain someG]
            let projFn ← mkLambdaFVars #[tv] (← mkAppM ``St.ffi #[proj])
            let pf ← mkExpectedTypeHint (← mkCongrArg projFn tEq) concl
            let pf ← instantiateMVars pf
            let n := (relName c).appendAfter "_ffiSome"
            addThm n (← mkForallFVars (#[F] ++ xs ++ #[tv, hv]) concl) (← mkLambdaFVars (#[F] ++ xs ++ #[tv, hv]) pf)
        return
      let stateResult ← if r'.isAppOfArity ``St 1 then pure true
        else if r'.isAppOfArity ``Prod 2 then do pure ((← isSt (r'.getArg! 1)) || (← isSt (r'.getArg! 0)))
        else pure false
      unless stateResult do return
      let (lhs, projFn) ← withLocalDeclD `p r fun pv => do
        if r'.isAppOfArity ``St 1 then
          return (← mkAppM ``St.ffi #[app], ← mkLambdaFVars #[pv] (← mkAppM ``St.ffi #[pv]))
        else if r'.isAppOfArity ``Prod 2 then
          if ← isSt (r'.getArg! 1) then
            return (← mkAppM ``St.ffi #[← mkAppM ``Prod.snd #[app]],
              ← mkLambdaFVars #[pv] (← mkAppM ``St.ffi #[← mkAppM ``Prod.snd #[pv]]))
          else if ← isSt (r'.getArg! 0) then
            return (← mkAppM ``St.ffi #[← mkAppM ``Prod.fst #[app]],
              ← mkLambdaFVars #[pv] (← mkAppM ``St.ffi #[← mkAppM ``Prod.fst #[pv]]))
          else throwError "no state"
        else throwError "no state"
      let concl ← mkEq lhs (← mkAppM ``St.ffi #[s])
      let pf ← instantiateMVars (← mkExpectedTypeHint (← mkCongrArg projFn hApp) concl)
      let n := (relName c).appendAfter "_ffi"
      addThm n (← mkForallFVars (#[F] ++ xs) concl) (← mkLambdaFVars (#[F] ++ xs) pf)
      liftCommandElabM <| elabCommand (← `(attribute [rel_simp] $(mkIdent n):ident))

/-- Candidate induction arguments: positions of arguments of inductive types other than machine states. -/
def recCandidates (c : Lean.Name) (mode : Mode) : TermElabM (Array Nat) := do
  let ci ← getConstInfo c
  -- argument positions as the derive telescope counts them (one per argument, the world dropped);
  -- types up to definitional unfolding (`Props` is a list)
  forallTelescope ci.type fun xs0 _ => do
    let xs := match mode with
      | .indep => xs0
      | _ => xs0.extract 1 xs0.size
    let mut out := #[]
    for i in [0:xs.size] do
      let d ← whnfD (← inferType xs[i]!)
      let d' := d.getAppFn
      let ok := d'.isConst && !(d'.isConstOf ``St) && !(d'.isConstOf ``Ffi.S) &&
        ((← getEnv).find? d'.constName!).any (fun ci => ci matches .inductInfo _)
      if ok then out := out.push i
    return out

def isRecursive (c : Lean.Name) : CoreM Bool := do
  let some ci := (← getEnv).find? c | return false
  let some v := ci.value? | return false
  return v.getUsedConstants.any fun d => d == c || (d.toString.splitOn "._f").length > 1 ||
    (d.toString.splitOn "._unary").length > 1 || d == ``WellFounded.fix

/-- Try without induction, then by induction on each candidate argument. -/
def deriveAuto (c : Lean.Name) (mode : Mode) (ffi : Bool) : TermElabM Unit := do
  let s ← saveState
  try
    if ffi then deriveFfi c none else deriveOne c mode none
  catch e =>
    unless ← isRecursive c do throw e
    s.restore
    let mut first : Option Exception := none
    for i in ← recCandidates c mode do
      let s' ← saveState
      try
        if ffi then deriveFfi c (some i) else deriveOne c mode (some i)
        return
      catch e' =>
        if first.isNone then first := some e'
        s'.restore
    throw (first.getD e)

syntax "rel_derive " (ident)+ : command
syntax "rel_derive_rec " ident num : command
syntax "rel_derive_ffi " (ident)+ : command
syntax "rel_derive_state " (ident)+ : command
syntax "rel_derive_indep " (ident)+ : command

elab_rules : command
  | `(rel_derive $ids*) => do
    for id in ids do
      let c ← liftCoreM <| realizeGlobalConstNoOverloadWithInfo id
      try liftTermElabM <| deriveAuto c .world false catch e => logWarning m!"rel_derive {c} failed: {e.toMessageData}"
  | `(rel_derive_rec $id $i) => do
    let c ← liftCoreM <| realizeGlobalConstNoOverloadWithInfo id
    liftTermElabM <| deriveOne c .world (some i.getNat)
  | `(rel_derive_state $ids*) => do
    for id in ids do
      let c ← liftCoreM <| realizeGlobalConstNoOverloadWithInfo id
      try liftTermElabM <| deriveAuto c .state false catch e => logWarning m!"rel_derive {c} failed: {e.toMessageData}"
  | `(rel_derive_indep $ids*) => do
    for id in ids do
      let c ← liftCoreM <| realizeGlobalConstNoOverloadWithInfo id
      try liftTermElabM <| deriveAuto c .indep false catch e => logWarning m!"rel_derive {c} failed: {e.toMessageData}"
  | `(rel_derive_ffi $ids*) => do
    for id in ids do
      let c ← liftCoreM <| realizeGlobalConstNoOverloadWithInfo id
      try liftTermElabM <| deriveAuto c .world true catch e => logWarning m!"rel_derive {c} failed: {e.toMessageData}"

end Host.Ts.FfiNat
