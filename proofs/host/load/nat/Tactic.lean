import host.load.nat.Core
namespace Host.Ts.FfiNat
open Lean Meta Elab Tactic

/-! # `rel_auto`: relating a definition's two instances

The goal `MR R (e F1 …) (e F2 …)` (or a canonical relation of pure values)
is decomposed along the shared structure of both sides: binds, pure results,
failures, conditionals, matches (split on the common discriminant), number
requests, and the relation lemmas `rel.<c>` of the constants they call;
other definitions are unfolded. The second world's pure terms are first
normalized to the first's (`rel_simp`). -/

/-- Side conditions of conditional rewrites: related native states, up to the state functions' `ffi` lemmas. -/
macro "rel_disch" : tactic => `(tactic| first
  | assumption
  | (simp only [rel_simp]; assumption)
  | (simp only [rel_simp]; done)
  | (simp only [rel_simp, *]; done)
  | (simp only [rel_simp, *]; assumption))

/-- Weak head normal form unfolding instances (canonical relations). -/
def whnfI (e : Lean.Expr) : MetaM Lean.Expr := withTransparency .instances <| whnf e

/-- The relation lemma of constant `c`. -/
def relName (c : Lean.Name) : Lean.Name :=
  let s := c.toString
  let s := if s.startsWith "Host.Ts." then s.drop 8 else s
  `Host.Ts.FfiNat ++ Lean.Name.mkSimple ("rel_" ++ s.replace "." "_")

def runTac (stx : TSyntax `tactic) : TacticM Bool := do
  let s ← saveState
  try
    evalTactic stx
    return true
  catch _ =>
    s.restore
    return false

/-- Whether `e` is a constructor application. -/
def isCtorApp (e : Lean.Expr) : MetaM Bool := do
  match e.getAppFn with
  | .const c _ => return (← getEnv).isConstructor c
  | _ => return false

/-- Case on the values `x1`, `x2` (product or option), and on their product or option fields, tracking
`h`. Returns the goals with `h`'s new fvar. -/
partial def caseVals (g : MVarId) (x1 x2 : FVarId) (h : FVarId) : MetaM (List (MVarId × FVarId)) := g.withContext do
  let t1 ← whnfI (← x1.getType)
  unless t1.isAppOfArity ``Prod 2 || t1.isAppOfArity ``Option 1 do return [(g, h)]
  let gs ← g.cases x1
  let mut out := []
  for sg in gs do
    let x2' := sg.subst.apply (mkFVar x2)
    let h' := sg.subst.apply (mkFVar h)
    let gs2 ← sg.mvarId.cases x2'.fvarId!
    for sg2 in gs2 do
      let h'' := sg2.subst.apply h'
      let some hh := h''.fvarId? | continue
      -- the fields pairwise (same constructor on both sides)
      let f1 := sg.fields.map (sg2.subst.apply ·)
      let f2 := sg2.fields
      let mut cur : List (MVarId × FVarId × Array Lean.Expr) := [(sg2.mvarId, hh, f1)]
      if f1.size = f2.size then
        for i in [0:f1.size] do
          let mut next := []
          for (gc, hc, f1c) in cur do
            match f1c[i]!, (f2[i]!) with
            | .fvar a, .fvar b =>
              for (gd, hd) in ← caseVals gc a b hc do
                next := next ++ [(gd, hd, f1c)]
            | _, _ => next := next ++ [(gc, hc, f1c)]
          cur := next
      out := out ++ cur.map fun (gc, hc, _) => (gc, hc)
  return out

/-- Destruct the canonical-relation hypothesis `h` between two values: equalities substituted, state
relations to `s.reFfi x`, conjunctions split; values of products and options are cased on first (the
relation then reduces). Returns the resulting goals. -/
partial def destructRel (g : MVarId) (h : FVarId) (fuel : Nat := 64) : MetaM (List MVarId) := g.withContext do
  if fuel = 0 then return [g]
  let some ldecl := (← getLCtx).find? h | return [g]
  let ty0 ← instantiateMVars ldecl.type
  -- the relation of two values of a product or option type: case on the values first
  if ty0.isAppOf ``CRel.r then
    let args := ty0.getAppArgs
    if args.size ≥ 5 then
      let x1 := args[3]!
      let x2 := args[4]!
      if x1.isFVar && x2.isFVar then
        let t1 ← whnfI (← inferType x1)
        if t1.isAppOfArity ``Prod 2 || t1.isAppOfArity ``Option 1 then
          let s ← saveState
          try
            let mut out := []
            for (gc, hc) in ← caseVals g x1.fvarId! x2.fvarId! h do
              out := out ++ (← destructRel gc hc (fuel - 1))
            return out
          catch _ => s.restore
  let ty ← whnfI ty0
  -- head-normal arguments (projections of constructors reduced)
  let ty ← if ty.isAppOfArity ``Eq 3 then
      pure (mkApp3 ty.getAppFn (ty.getArg! 0) (← whnfI (ty.getArg! 1)) (← whnfI (ty.getArg! 2)))
    else if ty.isAppOfArity ``StRel 5 then
      pure (mkAppN ty.getAppFn #[ty.getArg! 0, ty.getArg! 1, ty.getArg! 2, ← whnfI (ty.getArg! 3), ← whnfI (ty.getArg! 4)])
    else pure ty
  let g ← if ty != ty0 then g.replaceLocalDeclDefEq h ty else pure g
  g.withContext do
  if ty.isAppOfArity ``Eq 3 then
    let lhs := ty.getArg! 1
    let rhs := ty.getArg! 2
    if (rhs.isFVar && !(rhs.occurs lhs)) || (lhs.isFVar && !(lhs.occurs rhs)) then
      try return [← Lean.Meta.subst g h] catch _ => pure ()
    -- constructor applications on both sides: unify
    if (← isCtorApp lhs) && (← isCtorApp rhs) then
      try
        let gs ← g.cases h
        return gs.toList.map (·.mvarId)
      catch _ => pure ()
    return [g]
  if ty.isAppOfArity ``StRel 5 && (ty.getArg! 4).isFVar then
    try
      let gs ← g.cases h
      let mut out := []
      for sg in gs do
        -- fields: the native state, the equation, the relation
        let f := sg.fields
        match f.back? with
        | some (.fvar he) => out := out ++ (← destructRel sg.mvarId he (fuel - 1))
        | _ => out := out ++ [sg.mvarId]
      return out
    catch _ => return [g]
  if ty.isAppOfArity ``And 2 then
    try
      let gs ← g.cases h
      let mut out := []
      for sg in gs do
        let f := sg.fields
        if f.size = 2 then
          match f[0]!, f[1]! with
          | .fvar h1, .fvar h2 =>
            -- name the second conjunct to find it after the first's substitutions
            let n2 ← mkFreshUserName `hrel
            let g1 ← sg.mvarId.rename h2 n2
            for g2 in ← destructRel g1 h1 (fuel - 1) do
              match ← g2.withContext do return (← getLCtx).findFromUserName? n2 with
              | some d2 => out := out ++ (← destructRel g2 d2.fvarId (fuel - 1))
              | none => out := out ++ [g2]
          | _, _ => out := out ++ [sg.mvarId]
        else out := out ++ [sg.mvarId]
      return out
    catch _ => return [g]
  if ty.isConstOf ``True then
    return [← g.clear h]
  if ty.isConstOf ``False then
    let gs ← g.cases h
    return gs.toList.map (·.mvarId)
  return [g]

/-- Introduce two related values of a canonical relation and destruct the relation. -/
def introRel : TacticM Unit := withMainContext do
  let g ← getMainGoal
  let (fvs, g') ← g.introN 3
  let gs ← destructRel g' fvs[2]!
  replaceMainGoal gs

/-- Whether constant `c` names a matcher. -/
def isMatcherConst (c : Lean.Name) : MetaM Bool := do
  return (← getMatcherInfo? c).isSome

/-- Matcher applications in `e` (closed subterms). -/
partial def matcherApps (e : Lean.Expr) (acc : Array Lean.Expr) : MetaM (Array Lean.Expr) := do
  let acc ← match e with
    | .app f a => do matcherApps a (← matcherApps f acc)
    | .lam _ d b _ | .forallE _ d b _ => do matcherApps b (← matcherApps d acc)
    | .letE _ t v b _ => do matcherApps b (← matcherApps v (← matcherApps t acc))
    | .mdata _ b => matcherApps b acc
    | .proj _ _ b => matcherApps b acc
    | _ => pure acc
  if e.isApp && !e.hasLooseBVars then
    if (← matchMatcherApp? e).isSome then return acc.push e
  return acc

/-- `cases` on each hypothesis `C … = C' …` between constructor applications (injection and substitution). -/
partial def unifyCtorEqs (g : MVarId) : MetaM (List MVarId) := g.withContext do
  for d in ← getLCtx do
    if d.isImplementationDetail then continue
    let ty ← instantiateMVars d.type
    if ty.isAppOfArity ``Eq 3 then
      let a := ty.getArg! 1
      let b := ty.getArg! 2
      if (← isCtorApp a) || (← isCtorApp b) then
        let s ← saveState
        try
          let gs ← g.cases d.fvarId
          let mut out := []
          for sg in gs do
            out := out ++ (← unifyCtorEqs sg.mvarId)
          return out
        catch _ => s.restore
  return [g]

/-- Destruct the conjunctions among the hypotheses (case equations of tuples), substituting their
variable equations. -/
partial def destructAnds (g : MVarId) : MetaM (List MVarId) := g.withContext do
  for d in ← getLCtx do
    if d.isImplementationDetail then continue
    let ty ← instantiateMVars d.type
    if ty.isAppOfArity ``And 2 then
      let gs ← destructRel g d.fvarId
      if gs == [g] then continue
      let mut out := []
      for g' in gs do
        out := out ++ (← destructAnds g')
      return out
  return [g]

/-- For a case equation `d = (…, s, …)` binding a machine state `s`: `s.ffi = (… d …).ffi` (the state
functions' `ffi` lemmas then give the native state the split lost). -/
partial def addFfiFacts (g : MVarId) : MetaM MVarId := g.withContext do
  let mut g := g
  for d in ← getLCtx do
    if d.isImplementationDetail then continue
    let ty ← instantiateMVars d.type
    unless ty.isAppOfArity ``Eq 3 do continue
    let lhs := ty.getArg! 1
    let rhs := ty.getArg! 2
    if lhs.isFVar then continue
    -- states at product positions of the right side, with the projection of the left side
    let rec paths (e l : Lean.Expr) (acc : Array (Lean.Expr × Lean.Expr)) : MetaM (Array (Lean.Expr × Lean.Expr)) := do
      if e.isAppOfArity ``Prod.mk 4 then
        let acc ← paths (e.getArg! 2) (← mkAppM ``Prod.fst #[l]) acc
        paths (e.getArg! 3) (← mkAppM ``Prod.snd #[l]) acc
      else if e.isFVar && (← whnfI (← inferType e)).isAppOfArity ``St 1 then
        return acc.push (e, l)
      else return acc
    -- `c … = some e`: the function's `_ffiSome` lemma
    if rhs.isAppOfArity ``Option.some 2 then
      if let .const c _ := lhs.getAppFn then
        let ln := (relName c).appendAfter "_ffiSome"
        if (← getEnv).contains ln then
          try
            let lem ← mkConstWithFreshMVarLevels ln
            let (mvs, _, factTy) ← forallMetaTelescopeReducing (← inferType lem)
            if ← isDefEq (← inferType mvs.back!) ty then
              let _ ← isDefEq mvs.back! (mkFVar d.fvarId)
              let fact ← instantiateMVars (mkAppN lem mvs)
              let factTy ← instantiateMVars factTy
              unless fact.hasExprMVar do
                let (hv, g') ← (← g.assert `hffi factTy fact).intro1
                g := g'
                if let some ext ← getSimpExtension? `rel_simp then
                  let ctx ← Simp.mkContext (simpTheorems := #[← ext.getTheorems])
                  if let some (_, g'') := (← simpLocalDecl g' hv ctx).1 then g := g''
          catch _ => pure ()
    for (s, l) in ← paths rhs lhs #[] do
      try
        -- s.ffi = l.ffi, from the case equation
        let lam ← withLocalDeclD `p (← inferType lhs) fun p => do
          let lp := (l.replace fun e => if e == lhs then some p else none)
          mkLambdaFVars #[p] (← mkAppM ``St.ffi #[lp])
        let h ← mkCongrArg lam (mkFVar d.fvarId)
        let fact ← mkEqSymm h
        let factTy ← mkEq (← mkAppM ``St.ffi #[s]) (← mkAppM ``St.ffi #[l])
        let (hv, g') ← (← g.assert `hffi factTy (← mkExpectedTypeHint fact factTy)).intro1
        -- normalize the fact's right side (the state functions' `ffi` lemmas)
        g := g'
        if let some ext ← getSimpExtension? `rel_simp then
          let ctx ← Simp.mkContext (simpTheorems := #[← ext.getTheorems])
          if let some (_, g'') := (← simpLocalDecl g' hv ctx).1 then g := g''
      catch _ => pure ()
  return g

/-- Conditionals `bif c then a else b` in `e` with a closed condition. -/
partial def condApps (e : Lean.Expr) (acc : Array Lean.Expr) : MetaM (Array Lean.Expr) := do
  let acc ← match e with
    | .app f a => do condApps a (← condApps f acc)
    | .lam _ d b _ | .forallE _ d b _ => do condApps b (← condApps d acc)
    | .letE _ t v b _ => do condApps b (← condApps v (← condApps t acc))
    | .mdata _ b => condApps b acc
    | .proj _ _ b => condApps b acc
    | _ => pure acc
  if e.isAppOfArity ``cond 4 && !(e.getArg! 1).hasLooseBVars then return acc.push (e.getArg! 1)
  if e.isAppOfArity ``Option.bind 4 && !(e.getArg! 2).hasLooseBVars then return acc.push (e.getArg! 2)
  if e.isAppOfArity ``Option.map 4 && !(e.getArg! 3).hasLooseBVars then return acc.push (e.getArg! 3)
  return acc

/-- Split a match whose discriminants occur on both sides (so both sides' matches reduce), the smallest first;
otherwise Lean's `split`. -/
def relSplit : TacticM Bool := withMainContext do
  let g ← getMainGoal
  let tgt ← instantiateMVars (← g.getType)
  let sides : Option (Lean.Expr × Lean.Expr) :=
    if tgt.isAppOfArity ``MR 5 then some (tgt.getArg! 3, tgt.getArg! 4)
    else if tgt.isAppOfArity ``Eq 3 then some (tgt.getArg! 1, tgt.getArg! 2)
    else if tgt.isAppOfArity ``StRel 5 then some (tgt.getArg! 3, tgt.getArg! 4)
    else none
  if let some (l, r) := sides then
    let cands ← matcherApps l #[]
    let cands := cands.qsort fun a b => a.approxDepth < b.approxDepth
    for e in cands do
      let some app ← matchMatcherApp? e | continue
      let shared := app.discrs.all fun d => d.isFVar || (d.occurs r)
      if shared then
        let s ← saveState
        try
          let gs ← Lean.Meta.Split.splitMatch g e
          -- every open metavariable of the split must be one of its goals
          let pe ← instantiateMVars (mkMVar g)
          let open_ ← (pe.collectMVars {}).result.filterM fun m => do return !(← m.isAssigned) && !(← m.isDelayedAssigned)
          if open_.any (fun m => !gs.contains m) then throwError "split lost a goal"
          -- rewrite the other occurrences of each non-variable discriminant by its case equation
          let mut out := #[]
          for g' in gs do
            let g'' ← g'.withContext do
              let mut hs : Array (TSyntax `term) := #[]
              for d in ← getLCtx do
                if d.isImplementationDetail then continue
                let ty ← instantiateMVars d.type
                if ty.isAppOfArity ``Eq 3 && app.discrs.any (fun x => !x.isFVar && x == ty.getArg! 1) then
                  hs := hs.push (← Term.exprToSyntax (mkFVar d.fvarId))
              if hs.isEmpty then return g'
              let s1 ← saveState
              setGoals [g']
              try
                let args ← hs.mapM fun h => `(Lean.Parser.Tactic.simpLemma| $h:term)
                evalTactic (← `(tactic| simp only [$args,*] at ⊢))
                let r ← getGoals
                return r.headD g'
              catch _ =>
                s1.restore
                return g'
            out := out.push g''
          -- unify case equations between constructor applications
          let mut out2 := #[]
          for g' in out do
            for g1 in ← destructAnds g' do
              for g'' in ← unifyCtorEqs g1 do
                out2 := out2.push (← addFfiFacts g'')
          replaceMainGoal out2.toList
          discard <| runTac (← `(tactic| all_goals (try (first | contradiction |
            (simp only [List.cons.injEq, Prod.mk.injEq, Option.some.injEq, reduceCtorEq, and_false, false_and] at *; done)))))
          return true
        catch _ =>
          s.restore
    -- a conditional on a shared Boolean
    let conds := (← condApps l #[]).qsort fun a b => a.approxDepth < b.approxDepth
    for c in conds do
      if (← isCtorApp c) then continue
      if c.isFVar || c.occurs r then
        let stx ← Term.exprToSyntax c
        if ← runTac (← `(tactic| (cases $stx:term <;> simp only [Bool.cond_true, Bool.cond_false, obind_some, obind_none,
            omap_some, omap_none]))) then
          return true
  if ← runTac (← `(tactic| split <;> (try (simp only [Prod.mk.injEq, Option.some.injEq, reduceCtorEq, and_false, false_and,
      List.cons.injEq, and_true, true_and] at *)) <;> (try contradiction) <;>
      (try subst_vars))) then
    let mut out := #[]
    for g' in ← getGoals do
      for g1 in ← destructAnds g' do
        for g'' in ← unifyCtorEqs g1 do
          out := out.push (← addFfiFacts g'')
    setGoals out.toList
    discard <| runTac (← `(tactic| all_goals (try contradiction)))
    return true
  return false

/-- Split a closed discriminant or option scrutinee of the goal (a reduced relation of two values). -/
def relSplitGoal : TacticM Bool := withMainContext do
  let tgt ← instantiateMVars (← getMainTarget)
  let conds := (← condApps tgt #[]).qsort fun a b => a.approxDepth < b.approxDepth
  for c in conds do
    if (← isCtorApp c) then continue
    let stx ← Term.exprToSyntax c
    if ← runTac (← `(tactic| (cases $stx:term <;> simp only [Bool.cond_true, Bool.cond_false, obind_some, obind_none,
        omap_some, omap_none]))) then
      return true
  for e in (← matcherApps tgt #[]).qsort (fun a b => a.approxDepth < b.approxDepth) do
    let some app ← matchMatcherApp? e | continue
    for d in app.discrs do
      if d.isFVar || (← isCtorApp d) then continue
      let stx ← Term.exprToSyntax d
      if ← runTac (← `(tactic| (cases $stx:term <;> simp only [Bool.cond_true, Bool.cond_false, obind_some, obind_none,
          omap_some, omap_none]))) then
        return true
  return false

/-- One decomposition step on the main goal; false if no rule applies. -/
def relStep : TacticM Bool := withMainContext do
  let g ← getMainGoal
  let tgt ← instantiateMVars (← g.getType)
  let tgt' ← whnfI tgt
  if tgt' != tgt then
    let g' ← g.replaceTargetDefEq tgt'
    replaceMainGoal [g']
  if tgt'.isAppOfArity ``MR 5 then
    let m1 := (tgt'.getArg! 3).headBeta
    let m2 := (tgt'.getArg! 4).headBeta
    if m1.isLet || m2.isLet then
      return ← runTac (← `(tactic| dsimp (config := { proj := false }) only))
    match m1.getAppFn with
    | .const c _ =>
      if c == ``M.fail then return ← runTac (← `(tactic| exact MR.fail))
      if c == ``M.pure then return ← runTac (← `(tactic| refine MR.pure ?_))
      if c == ``M.bind then
        -- a native call site
        let m := m1.getArg! 2
        let projIdx := match m.getAppFn with
          | .proj ``Ffi i _ => some i
          | _ => none
        let isCall := m.isAppOf ``Ffi.call || projIdx == some 1
        let isBack := m.isAppOf ``Ffi.back || projIdx == some 4
        if isCall || isBack then
          let simTerm ← if isCall then `(FfiSim.call _ _ _ _ ?_) else `(FfiSim.back _ _ _ ?_)
          if ← runTac (← `(tactic| refine MR.callSite ($simTerm) ?_ ⟨_, rfl⟩)) then
            let gs ← getGoals
            match gs with
            | g1 :: g2 :: rest =>
              setGoals [g1]
              discard <| runTac (← `(tactic| rel_disch))
              let gs1 ← getGoals
              setGoals [g2]
              discard <| runTac (← `(tactic| intro _ _ _))
              let gs2 ← getGoals
              setGoals (gs1 ++ gs2 ++ rest)
              return true
            | _ => return true
        if ← runTac (← `(tactic| refine MR.bind (R := CRel.r) ?_ ?_)) then
          let gs ← getGoals
          match gs with
          | g1 :: g2 :: rest =>
            setGoals [g2]
            introRel
            let gs2 ← getGoals
            setGoals (g1 :: gs2 ++ rest)
            return true
          | _ => return true
        return false
      if c == ``cond then return ← runTac (← `(tactic| refine MR.cond _ ?_ ?_))
      if c == ``M.bin then return ← runTac (← `(tactic| refine MR.bin fun _ => ?_))
      if c == ``M.un then return ← runTac (← `(tactic| refine MR.un fun _ => ?_))
      if c == ``M.test then return ← runTac (← `(tactic| refine MR.test fun _ => ?_))
      if c == ``M.conc then return ← runTac (← `(tactic| refine MR.conc fun _ => ?_))
      let env ← getEnv
      if env.contains (relName c) then
        let lem := mkIdent (relName c)
        if ← runTac (← `(tactic| apply $lem:ident <;> first | rel_disch | with_reducible rfl | skip)) then return true
      -- an induction hypothesis
      if ← runTac (← `(tactic| (apply_assumption <;> first | rel_disch | with_reducible rfl))) then return true
      if ← isMatcherConst c then
        return ← relSplit
      -- unfold a definition on both sides
      if let some (.defnInfo di) := env.find? c then
        let recursive := di.value.getUsedConstants.any fun d => d == c || (d.toString.splitOn "._f").length > 1 ||
          (d.toString.splitOn "._unary").length > 1 || d == ``WellFounded.fix || d == ``Nat.rec || d == ``List.rec
        if recursive then return false
        let cid := mkIdent c
        return ← runTac (← `(tactic| delta $cid:ident))
      return false
    | .fvar _ => runTac (← `(tactic| apply_assumption))
    | _ => return false
  else if tgt'.isAppOfArity ``StRel 5 then
    if ← runTac (← `(tactic| (simp only [rel_simp, stRel_iff]; try assumption))) then return true
    relSplit
  else if tgt'.isAppOfArity ``Eq 3 then
    if ← runTac (← `(tactic| with_reducible rfl)) then return true
    if ← relSplit then return true
    if ← runTac (← `(tactic| simp only [rel_simp])) then return true
    -- induction hypotheses (universally quantified equations) as rewrites
    let mut ihs : Array (TSyntax `Lean.Parser.Tactic.simpLemma) := #[]
    for d in ← getLCtx do
      if d.isImplementationDetail then continue
      let ty ← instantiateMVars d.type
      if ty.isForall then
        let concl ← forallTelescopeReducing ty fun _ b => pure b
        if concl.isAppOfArity ``Eq 3 then
          ihs := ihs.push (← `(Lean.Parser.Tactic.simpLemma| $(← Term.exprToSyntax (mkFVar d.fvarId)):term))
    if ihs.isEmpty then return false
    runTac (← `(tactic| simp (disch := rel_disch) only [rel_simp, $ihs,*]))
  else if tgt'.isAppOfArity ``And 2 then
    runTac (← `(tactic| constructor))
  else if tgt'.isConstOf ``True then
    runTac (← `(tactic| trivial))
  else if tgt'.isForall then
    let s ← saveState
    try
      introRel
      return true
    catch _ =>
      s.restore
      return ← runTac (← `(tactic| intro _ _ _))
  else
    if ← runTac (← `(tactic| first | rel_disch | with_reducible rfl | trivial | (simp only [CRel.r]; done))) then return true
    if ← relSplitGoal then return true
    runTac (← `(tactic| simp only [CRel.r]))

/-- Normalize the second world's terms: `rel_simp`, and native reads through each related pair. -/
def relNorm : TacticM Bool := withMainContext do
  let mut args : Array (TSyntax `Lean.Parser.Tactic.simpLemma) := #[]
  for d in ← getLCtx do
    if d.isImplementationDetail then continue
    let ty ← instantiateMVars d.type
    if ty.isAppOf ``FfiRel.R then
      let h ← Term.exprToSyntax (mkFVar d.fvarId)
      args := args.push (← `(Lean.Parser.Tactic.simpLemma| ← FfiReadSim.read _ _ $h:term))
    -- symbol addresses of the second world: the first's (the worlds are explicit, the lemma's left side
    -- does not determine the first)
    else if (ty.isAppOf ``FfiSim || ty.isAppOf ``FfiReadSim) && ty.getAppNumArgs ≥ 2 then
      let f1 ← Term.exprToSyntax (ty.getArg! 0)
      let f2 ← Term.exprToSyntax (ty.getArg! 1)
      args := args.push (← `(Lean.Parser.Tactic.simpLemma| rel_addr (F1 := $f1) (F2 := $f2)))
    -- case equations of earlier splits: a closed term equal to a constructor application
    else if ty.isAppOfArity ``Eq 3 then
      let lhs := ty.getArg! 1
      let rhs := ty.getArg! 2
      if !lhs.isFVar && !lhs.hasLooseBVars && !(← isCtorApp lhs) && (← isCtorApp rhs) && !(lhs.occurs rhs) then
        let h ← Term.exprToSyntax (mkFVar d.fvarId)
        args := args.push (← `(Lean.Parser.Tactic.simpLemma| $h:term))
  if args.isEmpty then
    runTac (← `(tactic| simp (disch := rel_disch) only [rel_simp]))
  else
    runTac (← `(tactic| simp (disch := rel_disch) only [rel_simp, $args,*]))

/-- Normalize, then decompose, until no rule applies; goals no rule applies to are left. -/
def relLoop (fuel : Nat) : TacticM Unit := do
  let mut stuck : Array MVarId := #[]
  let mut n := fuel
  while n > 0 do
    n := n - 1
    match ← getGoals with
    | [] => break
    | g :: rest =>
      if ← g.isAssigned then
        setGoals rest
        continue
      setGoals [g]
      let ok ← (do if ← relNorm then pure true else relStep)
      if ok then
        setGoals ((← getGoals) ++ rest)
      else
        -- the goal may have been replaced by a definitionally equal one
        stuck := stuck ++ (← getGoals).toArray
        setGoals rest
  setGoals (stuck.toList ++ (← getGoals))

elab "rel_auto" : tactic => relLoop 4000

elab "rel_step" : tactic => do
  unless ← relStep do throwError "rel_step: no rule"

end Host.Ts.FfiNat
