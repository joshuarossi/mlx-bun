import host.sim.template.Chain
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

/-! # `tpl_chain` with literal lengths

`tpl_chain_lit` is `tpl_chain` (the plan's further key `litLens`: framed arrays' literal lengths, pairs of address and value), for a row
count the program must read as a literal (`arange`'s cache key): at those arrays' `length` reads B-len-lit returns `.lit x` and adds no table
entry (`Bridge.lenLitPatch`, bridge kind `lenLit`). -/

namespace Host.Ts.Sim.Template
open Lean Elab Command Meta Host.Ts _root_.Host.Load Host.Ts.Stream

namespace Bridge

/-- B-len-lit: the member frame popped, the literal length returned. -/
def lenLitPatch {S : Type} (s : St S) (Sv : SSrv) (x : F64) : St S × SSrv :=
  ({ s with stack := s.stack.tail }.ret (.num (.lit x)), Sv)

/-- A `length` read of a framed array with a literal length. -/
def litHit (lits : List (Nat × Nat)) (frames : List Nat) (s : St Host.Load.LSt) (Sv : SSrv) : Option BridgeHit :=
  match s.ctl, s.stack with
  | .ret (.obj a), stk =>
    if isLenFrame stk && frames.contains a then
      match lits.find? (·.1 == a) with
      | some (_, x) => some { kind := "lenLit", patch := some ((lenLitPatch s Sv (F64.ofNat x)).1, []),
                              extra := [("lit", Lean.toJson x)] }
      | none => none
    else none
  | _, _ => none

end Bridge

/-- The plan's `litLens`. -/
def litLensOf (planArg : String) : IO (List (Nat × Nat)) := do
  let text ← if planArg.startsWith "{" then pure planArg else IO.FS.readFile planArg
  match Lean.Json.parse text with
  | .error e => throw (IO.userError e)
  | .ok j => match SpecJ.pairsOf (SpecJ.optD j "litLens" (.arr #[])) with
    | .ok ps => pure ps
    | .error e => throw (IO.userError e)

/-- `tpl_chain`'s work: see the module doc. -/
unsafe def chainLitCmdW {F : Ffi} (w : TWorld F) (pre srcName srvName : Lean.Name) (planArg : String) (capO : Option Nat)
    (argE : Option Lean.Expr := none) : TermElabM Unit := do
  astTabRef.set (← loadAstTab)
  Memo.reset
  let plan ← loadPlan planArg
  let litLens ← litLensOf planArg
  let cap := capO.getD plan.cap
  let t0 ← IO.monoMsNow
  -- an abstracted boundary (`host_stream … abs`, e.g. the prompt boot's `P.a2818 fw`) at the argument `arg`
  let srcE ← match argE with
    | some a => pure ((← getConstInfo srcName).value!.beta #[← Meta.reduce a (skipTypes := true)])
    | none => pure (mkConst srcName)
  let fromLoad ← isDefEq (← inferType (match argE with | some a => mkApp (mkConst srcName) a | none => mkConst srcName))
    (mkApp (mkConst ``St) (mkConst ``LSt))
  let (s, c0, g0) ← if fromLoad then do
      let (l, c, g) ← restoreAny (S := LSt) srcE (mkConst srvName) pre
      pure (w.lift l, c, g)
    else restoreAny (S := F.S) srcE (mkConst srvName) pre
  -- a fast-forward to the start (no boundaries): the `count`-th call of `fn`
  let (s, c0) ← match plan.skipTo with
    | none => pure (s, c0)
    | some (fn, d, n) => do
      let ρs : Nat → F64 := fun i => match plan.baseVals.find? (·.1 == i) with
        | some (_, v) => F64.ofNat v
        | none => Host.Load.Decode.valuation i
      let mut st := s
      let mut c : SSrv := ⟨c0.tab, []⟩
      let mut k : Nat := 0
      let mut n0 : Nat := 0
      while k < n do
        match interpRec ρs (step F st).run c [] with
        | some (s', c', _) =>
          st := s'; c := c'; n0 := n0 + 1
          if isCallOf st fn d then k := k + 1
        | none => throwError "tpl_chain {pre}: stuck after {n0} steps of the fast-forward at {ctlNote st}: {whyStuck ρs (step F st).run c}"
      logInfo m!"tpl_chain {pre}: fast-forward {n0} steps to call {n} of {fn}"
      pure (st, ({ c with oracle := [] } : SSrv))
  -- an isolated start: the call without the caller's frames, the spec's places symbolized
  let spec := (← specOfPath plan.spec).getD {}
  let (s, c0, isoEnts) ← if plan.isolate then do
      let (s0, cI, ents, _, stats) ← isolate w s c0 spec plan.static "none"
      logInfo m!"tpl_chain {pre}: isolated start: {stats}, {ents.size} symbolized places"
      pure (s0, cI, ents)
    else pure (s, c0, #[])
  -- the start's token queue replaced
  let s := match plan.startTokens with
    | none => s
    | some ts => let l := (w.proj s).aux.ffi
      s.setFfi (w.setLoad s.aux.ffi { l with mlx := { l.mlx with tokens := ts.map NumV.ref } })
  let t1 ← IO.monoMsNow
  let nonce := s!"{pre}:{← IO.monoNanosNow}"
  let dir ← streamDir
  IO.FS.createDirAll (dir / pre.toString)
  let oE := mkConst (pre ++ `O)
  let drop (m : Nat) := mkApp3 (mkConst ``List.drop [.zero]) (mkConst ``Ans) (mkRawNatLit m) oE
  let mut ρ : Nat → F64 := fun i => match plan.baseVals.find? (·.1 == i) with
    | some (_, v) => F64.ofNat v
    | none => match isoEnts.find? (·.var == i) with
      | some e => match e.orig with
        | .lit x => x
        | .ref _ => Host.Load.Decode.valuation i
      | none => Host.Load.Decode.valuation i
  let (g, b0) ← writeBoundaryW w pre nonce dir { g0 with pre } 0 s c0.tab (drop 0)
    (if fromLoad || argE.isSome || plan.isolate || plan.startTokens.isSome then none else some (mkConst srcName))
  let mut g := g
  let mut bytes := b0
  let mut st := s
  let mut c : SSrv := ⟨c0.tab, []⟩
  -- the glue piece's start (its native bookkeeping's `a`)
  let mut segSt := s
  -- the canonical result variables' defining terms (the stage's results over the call's variables), earlier ones
  -- substituted: the chain end's table de-canonicalized (`chain.json` "dtheta", the end facts' `<Name>.dθ`)
  let mut dws : Array Nat := #[]
  let mut drs : Array SymE := #[]
  let mut segTab := c0.tab.length
  let mut o : Array Ans := #[]
  let mut steps : Nat := 0
  let mut ks : Array Nat := #[]
  let mut bs : Array SegBridge := #[]
  let mut pieces : Array Lean.Json := #[]
  let mut segStart : Nat := 0
  let mut segSteps : Nat := 0
  let mut fresh := plan.fresh
  let mut stop := ""
  let mut site : Nat := 0
  let mut segO : Nat := 0
  let mut frames : List Nat := plan.frames
  -- the chain's load parameters, from its start's counters (`LoadP`: lo, E, NE, NL, N0): its acceptance's and its
  -- compactions' (`fullJSPP`, `Conv.FullShiftQ`)
  let loadPJ : Lean.Json := match plan.loadP with
    | some p => Lean.toJson p
    | none => let m := (w.proj s).aux.ffi.mlx; Lean.toJson [m.next, 131072, 2 ^ 40, m.nnext, m.nnext]
  let mut nBridges : Nat := 0
  let mut seg0 : Nat := 0
  let mut gvars : List (Nat × String) := plan.vars
  -- result variables derived from a mapped variable by another expression (variable, quantity, the expression)
  let mut gderived : List (Nat × String × String) := []
  let mut first := true
  let mut startEmpty := false
  -- the closure the last stage returned (a stage `fn` "@ret": its call, as a dispatch's forward)
  let mut lastRet : Option Nat := none
  let isStage (r : Option Nat) (x : St F.S) : Option ChainStage := plan.stages.find? fun cs =>
    if cs.fn == "@ret" then r.any fun a => isCallOf x s!"#{a}" cs.depth else isCallOf x cs.fn cs.depth
  -- glue `k`'s name: the plan's, else `start` for an empty glue 0 (a chain from a call), else `g<k>`
  let glueName (empty0 : Bool) (k : Nat) : String :=
    plan.glue[k]?.getD (if k == 0 && empty0 then "start" else s!"g{k}")
  -- glue `k`'s oracle (the answers of its run, `X.O`'s slice) and variable map, beside `X`'s boundaries
  -- `k` the glue's index, its run the segments `runSeg<seg0>` … `runSeg<seg1>` between the bridges inside it
  let writeGlue (k : Nat) (nm : String) (a b o0 o1 steps seg0 seg1 : Nat) (vars : List (Nat × String))
      (derived : List (Nat × String × String) := []) (ncl : Lean.Json := .null) : IO Lean.Json := do
    let lean := if a ≥ b then Lean.Json.null else if seg0 == seg1 then Lean.toJson s!"{pre}.runSeg{seg0}"
      else Lean.toJson ((List.range' seg0 (seg1 + 1 - seg0)).map fun j => s!"{pre}.runSeg{j}")
    let j := Lean.Json.mkObj [("glue", Lean.toJson nm), ("chain", Lean.toJson pre.toString), ("index", Lean.toJson k),
      ("lean", lean), ("world", Lean.toJson w.name), ("from", Lean.toJson a), ("to", Lean.toJson b), ("steps", Lean.toJson steps),
      ("vars", Lean.Json.arr (vars.toArray.map fun (v, q) => Lean.Json.arr #[Lean.toJson v, Lean.toJson q])),
      ("oracle", Lean.toJson s!"List.take {o1 - o0} (List.drop {o0} {pre}.O)"), ("answers", Lean.toJson (o1 - o0)),
      ("derived", Lean.Json.arr (derived.toArray.map fun (v, q, e) => Lean.Json.arr #[Lean.toJson v, Lean.toJson q, Lean.toJson e])),
      ("bridges", Lean.toJson (seg1 - seg0)), ("ncl", ncl)]
    IO.FS.writeFile (dir / pre.toString / s!"glue{k}.json") (j.pretty ++ "\n")
    pure (Lean.Json.mkObj [("glue", Lean.toJson nm), ("lean", lean), ("from", Lean.toJson a), ("to", Lean.toJson b),
      ("steps", Lean.toJson steps), ("meta", Lean.toJson s!"glue{k}.json")])
  -- the readback stop: the start's callee called again at the start's depth
  let (fa0, depth0) := match s.ctl with
    | .call (.obj a) _ _ => (a, s.stack.length)
    | _ => (0, 0)
  while stop.isEmpty do
    -- glue, to the next stage call or the stop
    let mut n : Nat := 0
    let mut call : Option (ChainStage × St F.S × SSrv × List Ans) := none
    let mut bridge : Option (BridgeHit × St F.S × SSrv × List Ans) := none
    -- a chain from a call: the start state is the site (no step into it, an empty glue 0)
    let mut stepped := true
    if first then
      first := false
      if let some cs := isStage lastRet st then
        call := some (cs, st, c, [])
        stepped := false
    while call.isNone && bridge.isNone && n < plan.chunk do
      match plan.stop with
      | .readback => match st.ctl with
        | .call (.obj a) _ _ => if steps > 0 && a == fa0 && st.stack.length == depth0 then stop := "readback"; break
        | _ => pure ()
      | .call f d => if steps > 0 && isCallOf st f d then stop := plan.stop.name; break
      | .below d => if st.stack.length < d then stop := plan.stop.name; break
      | .steps k => if steps ≥ k then stop := plan.stop.name; break
      | .ret => if steps > 0 && isRetAt st s.stack.length then stop := "ret"; break
      | _ => pure ()
      if isHalt st.ctl then stop := "halt"; break
      match interpRec ρ (step F st).run c [] with
      | some (s', c', a) =>
        -- the stop's call ends the chain before a stage of the same function (a decode iteration's next readback)
        let stopHere := match plan.stop, s'.ctl with
          | .readback, .call (.obj f) _ _ => f == fa0 && s'.stack.length == depth0
          | .call fn d, _ => isCallOf s' fn d
          | _, _ => false
        if stopHere then
          st := s'; c := c'; o := o ++ a.reverse.toArray; steps := steps + 1; n := n + 1; segSteps := segSteps + 1
          stop := plan.stop.name
          break
        if let some cs := isStage lastRet s' then call := some (cs, s', c', a); break
        if !plan.bridges.isEmpty then
          let bp : Bridge.RouteB := { kinds := plan.bridges, lens := plan.lens.map (fun (a, v) => (a, SymE.var v)) }
          if let some hit := Bridge.litHit litLens frames (w.proj s') c' then
            bridge := some (hit, s', c', a); break
          if let some hit := Bridge.routeBridges bp frames (w.proj s') c' then
            bridge := some (hit, s', c', a); break
        st := s'; c := c'; o := o ++ a.reverse.toArray; steps := steps + 1; n := n + 1; segSteps := segSteps + 1
      | none =>
        let why := s!"stuck after {steps} steps at {ctlNote st}: {whyStuck ρ (step F st).run c}"
        if plan.stuckStop then
          stop := s!"stuck: {why}"
          logInfo m!"tpl_chain {pre}: {why}"
          break
        throwError "tpl_chain {pre}: {why}"
      if segSteps > cap then throwError "tpl_chain {pre}: a glue piece exceeds {cap} steps"
    if n > 0 then
      ks := ks.push n
      let (g', b) ← writeBoundaryW w pre nonce dir g ks.size st c.tab (drop o.size) none
      g := g'; bytes := bytes + b
    -- a bridge point inside the glue: the step into the bridge state (boundary `ia`), then its transition (`ia + 1`):
    -- a patch, B-newdata's or B-size's patched step, or the state's own step (as `tpl_case_split`)
    if let some (hit, sA, cA, aA) := bridge then
      let nA := steps
      st := sA; c := cA; o := o ++ aA.reverse.toArray; steps := steps + 1; segSteps := segSteps + 1
      ks := ks.push 1
      let (g', b) ← writeBoundaryW w pre nonce dir g ks.size st c.tab (drop o.size) none
      g := g'; bytes := bytes + b
      let ia := ks.size
      let arr := match st.ctl with
        | .ret (.obj a) => a
        | _ => 0
      let aN := st.next
      let mut nT := 1
      if hit.size then
        match interpRec ρ (Disp.sizeS F st).run c [] with
        | some (s', c', a') => st := s'; c := c'; o := o ++ a'.reverse.toArray; nT := 3
        | none => throwError "tpl_chain {pre}: the patched B-size transition is stuck"
      else match hit.patch, hit.ndBytes.bind fun bsT => (Bridge.ndParts st).map (·, bsT) with
        | some (lB, es), _ => st := w.unproj st lB; c := { c with tab := c.tab ++ es }
        | none, some ((name, rt, tys, rest, bb), bsT) =>
          match interpRec ρ (Disp.newDataS F st name rt tys rest bb bsT).run c [] with
          | some (s', c', a') => st := s'; c := c'; o := o ++ a'.reverse.toArray
          | none => throwError "tpl_chain {pre}: the patched B-newdata step is stuck"
        | none, none =>
          match interpRec ρ (step F st).run c [] with
          | some (s', c', a') => st := s'; c := c'; o := o ++ a'.reverse.toArray
          | none => throwError "tpl_chain {pre}: stuck at the bridge"
      steps := steps + nT; segSteps := segSteps + nT
      ks := ks.push nT
      let (g', b) ← writeBoundaryW w pre nonce dir g ks.size st c.tab (drop o.size) none
      g := g'; bytes := bytes + b
      let patched := hit.patch.isSome || hit.ndBytes.isSome || hit.size
      bs := bs.push { kind := hit.kind, ia, aN, nA, arr, extra := hit.extra ++ (if patched then [("patched", Lean.toJson true)] else []) }
      if hit.kind == "spread" then frames := frames ++ [aN]
      frames := frames ++ hit.frames
      nBridges := nBridges + 1
      continue
    let some (cs, sC, cC, a) := call | continue
    if site == 0 then startEmpty := segSteps == 0
    let oEnd := o.size
    -- the step into the call state, a chunk of its own (boundary `ia`)
    if stepped then
      st := sC; c := cC; o := o ++ a.reverse.toArray; steps := steps + 1
      ks := ks.push 1
      let (g', b) ← writeBoundaryW w pre nonce dir g ks.size st c.tab (drop o.size) none
      g := g'; bytes := bytes + b
    let ia := ks.size
    pieces := pieces.push (← writeGlue site (glueName startEmpty site) segStart (if stepped then ia - 1 else ia) segO oEnd
      segSteps seg0 bs.size gvars gderived (nclJson w segSt st segTab c.tab.length segStart ia))
    -- the site template and its run, in the instance's own stream with `X`'s page names
    let ipre := pre ++ Lean.Name.mkSimple s!"st{site}"
    let inonce := s!"{ipre}:{← IO.monoNanosNow}"
    IO.FS.createDirAll (dir / ipre.toString)
    let (s0, cI, _, ifr, stats) ← isolate w st c { frames := some frames } plan.static "none"
    let iwide := plan.wide.filter fun (a, _) => ((w.proj s0).heap.get a).isSome
    let iO := mkConst (ipre ++ `O)
    let (gI, bI0) ← writeBoundaryW w ipre inonce dir { g with pre := ipre } 0 s0 cI.tab
      (mkApp3 (mkConst ``List.drop [.zero]) (mkConst ``Ans) (mkRawNatLit 0) iO) none
    let (s2, c2, out) ← runLocal w ipre inonce dir ρ s0 cI.tab { g := gI, bytes := bI0 } cap plan.chunk
    defineStream ipre w.ffiC out.o cI.tab out.ks inonce out.steps
    defineEntries ipre #[] ifr
    let cls := cs.cls.getD ((plan.tags.find? (·.1 == cs.piece)).map (·.2) |>.getD "")
    -- the called function as recorded: `@ret` with the closure's address
    let fnR := match cs.fn, st.ctl with
      | "@ret", .call (.obj a) _ _ => s!"@ret #{a}"
      | f, _ => f
    let sname := cs.name.getD (if cls.isEmpty then cs.piece else s!"{cs.piece}_{cls}")
    let callName := s!"{sname}__{glueName startEmpty site}__{glueName startEmpty (site + 1)}"
    let n0 := c.tab.length
    -- the stage's new table entries become fresh variables, bound to the stage's values
    let ws := (List.range (c2.tab.length - n0)).map (fresh + ·)
    let vals := (c2.tab.drop n0).map fun e => e.eval ρ
    let ρ0 := ρ
    ρ := fun v => match (ws.zip vals).find? (·.1 == v) with
      | some (_, x) => x
      | none => ρ0 v
    fresh := fresh + ws.length
    -- the merge: `Conv.mergeSt` at the instance's own site (σ = Map.id)
    let rs := st.stack
    let wr := wrOf (w.proj s0) (w.proj s2)
    let τ := Map.res Map.id n0 n0
    let sr := Conv.mergeSt Map.id τ rs wr st s2 s0 s2.aux.ffi
    let stage := Lean.Json.mkObj [("name", Lean.toJson callName), ("stage", Lean.toJson sname),
      ("fn", Lean.toJson fnR), ("piece", Lean.toJson cs.piece), ("class", Lean.toJson cls),
      ("site", Lean.toJson site), ("instance", Lean.toJson ipre.toString), ("T1", Lean.toJson out.ks.size),
      ("steps", Lean.toJson out.steps), ("callSteps", Lean.toJson steps), ("rs", Lean.toJson rs.length),
      ("n0", Lean.toJson n0), ("ws", Lean.toJson ws), ("wr", Lean.toJson wr.length), ("stepped", Lean.toJson stepped),
      ("stepAnswers", Lean.toJson (o.size - oEnd)),
      ("conv", Lean.Json.mkObj [("sigma", Lean.toJson "id"), ("theta", Lean.toJson "id"), ("compaction", Lean.toJson plan.compact)])]
    IO.FS.writeFile (dir / ipre.toString / "stage.json")
      ((stageJson ipre fnR cs.piece w.name out.ks.size out.steps plan.vars ifr #[] cI.tab.toArray
        ([("site", Lean.toJson site), ("class", Lean.toJson cls), ("name", Lean.toJson callName), ("chain", Lean.toJson pre.toString),
          ("callBoundary", Lean.toJson ia), ("callSteps", Lean.toJson steps), ("callDepth", Lean.toJson rs.length),
          ("wide", Lean.toJson iwide), ("loadP", loadPJ), ("accept", Lean.toJson plan.accept), ("D0", Lean.toJson plan.D0),
          ("traceNew", Lean.toJson ((w.proj s2).aux.trace.length - (w.proj s0).aux.trace.length)),
          ("tab0", Lean.toJson cI.tab.length)] ++ footJson (w.proj s0) (w.proj s2) plan.static ++ [("wrRs", wrRsJson out.wrRs)])).pretty ++ "\n")
    writeSeg dir ipre (segJson cs.piece "return" out.ks.size out.steps ifr [] (segMore w (w.proj s0) (w.proj s2) false))
    -- the merged state at boundary `ia + 1` (zero steps), the table with the fresh variables
    let callSt := st
    let callTab := c.tab
    st := sr
    c := { c with tab := c.tab ++ resTab' ws }
    ks := ks.push 0
    let (g', b) ← writeBoundaryW w pre nonce dir g ks.size st c.tab (drop o.size) none
    g := g'; bytes := bytes + b
    -- the compaction: the canonical state at the next boundary (another zero-step chunk)
    let mut compJ := Lean.Json.null
    let mut kdWs : List Nat := []
    let mut kdNr : List Nat := []
    if plan.compact then
      let (cs', ctab, kd, ρ') ← compactNative w callSt sr callTab c.tab fresh ρ frames (some s)
      fresh := fresh + kd.ws.length
      ρ := ρ'
      st := cs'
      c := { c with tab := ctab }
      ks := ks.push 0
      let (g', b) ← writeBoundaryW w pre nonce dir g ks.size st c.tab (drop o.size) none
      g := g'; bytes := bytes + b
      compJ := (kd.json.setObjVal! "cCall" (nclCnt w callSt callTab.length)).setObjVal! "cCan" (nclCnt w cs' ctab.length)
        |>.setObjVal! "removed" (let mc := (w.proj callSt).aux.ffi.mlx; let mk := (w.proj cs').aux.ffi.mlx
          Lean.toJson (removedKeys mc.arrs mk.arrs ++ removedKeys mc.objs mk.objs ++ removedKeys mc.nodes mk.nodes ++ removedKeys mc.items mk.items))
        -- the canonical results' values: the instance's end table at the result references (Lean terms)
        |>.setObjVal! "rsLean" (Lean.toJson (kd.nr.map fun r => (c2.tab[r]?.map leanSym).getD "none"))
      kdWs := kd.ws
      let dsub : Nat → SymE := fun v => match dws.toList.idxOf? v with
        | some j => drs[j]?.getD (.var v)
        | none => .var v
      for (wv, r) in kd.ws.zip kd.nr do
        dws := dws.push wv
        drs := drs.push (((c2.tab[r]?).getD (.var wv)).subst dsub)
      kdNr := kd.nr
    -- the result variables' quantities for the glue after the call: the plan's `results`, else the one mapped variable
    -- the value mentions (exact up to casts; otherwise listed as derived, with its expression)
    let stageE := c2.tab.drop n0
    let resEnts : List (Nat × Nat × SymE) := match plan.compact, compJ with
      | true, .null => []
      | true, _ => (kdWs.zip kdNr).filterMap fun (v, r) => (stageE[r - n0]?).map fun e => (v, r - n0, e)
      | false, _ => (ws.zipIdx.filterMap fun (v, j) => (stageE[j]?).map fun e => (v, j, e))
    for (w, j, e) in resEnts do
      match cs.results[j]? with
      | some q => gvars := gvars ++ [(w, q)]
      | none => match resQty gvars e with
        | some (q, true) => gvars := gvars ++ [(w, q)]
        | some (q, false) => gderived := gderived ++ [(w, q, fmtSym e)]
        | none => pure ()
    bs := bs.push { kind := "stage", ia, aN := st.next, nA := steps, arr := 0, extra := [("fn", Lean.toJson fnR),
      ("piece", Lean.toJson cs.piece), ("class", Lean.toJson cls), ("site", Lean.toJson site), ("name", Lean.toJson callName),
      ("instance", Lean.toJson ipre.toString), ("T1", Lean.toJson out.ks.size), ("n0", Lean.toJson n0), ("ws", Lean.toJson ws),
      ("compaction", compJ), ("arrs", arrsJson s sr frames)] }
    pieces := pieces.push (Lean.Json.mkObj [("stage", stage)])
    lastRet := match st.ctl with | .ret (.obj f) => some f | _ => none
    logInfo m!"tpl_chain {pre}: site {site} {callName} ({fnR}) at boundary {ia}: {stats}; stage {out.steps} steps, {out.ks.size} chunks, {ws.length} fresh variables, {wr.length} written entries"
    site := site + 1
    segStart := if plan.compact then ia + 2 else ia + 1
    segSt := st
    segTab := c.tab.length
    segSteps := 0
    segO := o.size
    seg0 := bs.size
  pieces := pieces.push (← writeGlue site (glueName startEmpty site) segStart ks.size segO o.size segSteps seg0 bs.size gvars gderived
    (nclJson w segSt st segTab c.tab.length segStart ks.size))
  writeSeg dir pre (segJson "chain" stop ks.size steps plan.frames bs.toList
    (segMore w (w.proj s) (w.proj st) false ++ [("row", Lean.toJson plan.row), ("wide", Lean.toJson plan.wide),
      ("accept", Lean.toJson plan.accept), ("D0", Lean.toJson plan.D0),
      ("loadP", loadPJ)]))
  IO.FS.writeFile (dir / pre.toString / "chain.json") ((Lean.Json.mkObj [("chain", Lean.toJson pre.toString),
    ("world", Lean.toJson w.name), ("row", Lean.toJson plan.row), ("stop", Lean.toJson stop), ("T1", Lean.toJson ks.size),
    ("start", let l := w.proj s; Lean.Json.mkObj [("next", Lean.toJson l.next), ("mnext", Lean.toJson l.aux.ffi.mlx.next),
      ("nnext", Lean.toJson l.aux.ffi.mlx.nnext)]),
    -- the native bookkeeping's full check at the start (`Conv.ncleanB`): its counters and the key counts
    ("ncl0", let m := (w.proj s).aux.ffi.mlx; Lean.Json.mkObj [("c", nclCnt w s c0.tab.length),
      ("counts", Lean.toJson [(changedKeys PTrie.nil m.arrs (2 ^ 62)).length, (changedKeys PTrie.nil m.objs (2 ^ 62)).length,
        (changedKeys PTrie.nil m.nodes (2 ^ 62)).length, (changedKeys PTrie.nil m.items (2 ^ 62)).length])]),
    ("endArrs", arrsJson s st frames),
    ("source", Lean.toJson srcName.toString), ("startTokens", Lean.toJson plan.startTokens),
    ("dtheta", let keep := (dws.toList.zip drs.toList).filter fun (v, _) => c.tab.any fun e => !e.noVar v
      Lean.Json.mkObj [("ws", Lean.toJson (keep.map (·.1))), ("rs", Lean.toJson (keep.map (leanSym ·.2))),
      ("endTab", Lean.toJson (c.tab.map fun e => leanSym (e.subst fun v => match dws.toList.idxOf? v with
        | some j => drs[j]?.getD (.var v)
        | none => .var v)))]),
    ("steps", Lean.toJson steps), ("pieces", Lean.Json.arr pieces)]).pretty ++ "\n")
  defineStream pre w.ffiC o c0.tab ks nonce steps
  let t2 ← IO.monoMsNow
  logInfo m!"tpl_chain {pre}: restore {t1 - t0} ms, run {t2 - t1} ms; {steps} glue steps to {stop}, {site} stage calls, {nBridges} bridges, {ks.size} chunks (T1 = {pre}.s{ks.size}), {bytes} bytes"
where
  resTab' (ws : List Nat) : List SymE := ws.map SymE.var

/-- A closed term as the term denoting it: `tpl_chain`'s `arg`, an argument of the command run in the world. -/
private partial def quoteLevel : Level → Lean.Expr
  | .zero => mkConst ``Level.zero
  | .succ l => mkApp (mkConst ``Level.succ) (quoteLevel l)
  | .max a b => mkApp2 (mkConst ``Level.max) (quoteLevel a) (quoteLevel b)
  | .imax a b => mkApp2 (mkConst ``Level.imax) (quoteLevel a) (quoteLevel b)
  | .param n => mkApp (mkConst ``Level.param) (toExpr n)
  | .mvar _ => panic! "tpl_chain: a level metavariable in arg"

private def quoteBinder : BinderInfo → Lean.Expr
  | .default => mkConst ``BinderInfo.default
  | .implicit => mkConst ``BinderInfo.implicit
  | .strictImplicit => mkConst ``BinderInfo.strictImplicit
  | .instImplicit => mkConst ``BinderInfo.instImplicit

private partial def quoteExpr : Lean.Expr → Lean.Expr
  | .bvar i => mkApp (mkConst ``Lean.Expr.bvar) (toExpr i)
  | .sort l => mkApp (mkConst ``Lean.Expr.sort) (quoteLevel l)
  | .const n ls => mkApp2 (mkConst ``Lean.Expr.const) (toExpr n) (ls.foldr (fun l r => mkApp3 (mkConst ``List.cons [.zero]) (mkConst ``Level) (quoteLevel l) r) (mkApp (mkConst ``List.nil [.zero]) (mkConst ``Level)))
  | .app f a => mkApp2 (mkConst ``Lean.Expr.app) (quoteExpr f) (quoteExpr a)
  | .lam n t b bi => mkApp4 (mkConst ``Lean.Expr.lam) (toExpr n) (quoteExpr t) (quoteExpr b) (quoteBinder bi)
  | .forallE n t b bi => mkApp4 (mkConst ``Lean.Expr.forallE) (toExpr n) (quoteExpr t) (quoteExpr b) (quoteBinder bi)
  | .lit (.natVal v) => mkApp (mkConst ``Lean.Expr.lit) (mkApp (mkConst ``Literal.natVal) (toExpr v))
  | .lit (.strVal s) => mkApp (mkConst ``Lean.Expr.lit) (mkApp (mkConst ``Literal.strVal) (toExpr s))
  | .mdata _ e => quoteExpr e
  | .proj s i e => mkApp3 (mkConst ``Lean.Expr.proj) (toExpr s) (toExpr i) (quoteExpr e)
  | _ => panic! "tpl_chain: a free or let variable in arg"

private def quoteOptExpr : Option Lean.Expr → Lean.Expr
  | none => mkApp (mkConst ``Option.none [.zero]) (mkConst ``Lean.Expr)
  | some e => mkApp2 (mkConst ``Option.some [.zero]) (mkConst ``Lean.Expr) (quoteExpr e)

/-- `tpl_chain X from s, S : "<plan>" [(world := w, cap := n, arg := t)]` (`arg`: `s` is an abstracted boundary,
`host_stream … abs`, applied to `t`, e.g. the prompt boot's `P.a2818 (π.map natV)`). -/
elab "tpl_chain_lit " p:ident " from " src:ident ", " srv:ident " : " plan:str os:(tplOpts)? : command =>
  liftTermElabM <| withOptions (fun o => o.setBool `Elab.async false) do
    let os : TplOpts := tplOptsOf (os.map (·.raw))
    os.check [`world, `cap, `arg]
    let pre := (← getCurrNamespace) ++ p.getId
    let srcN ← resolveGlobalConstNoOverload src
    let srvN ← resolveGlobalConstNoOverload srv
    let argE ← match os.find? (·.1 == `arg) with
      | some (_, t) => some <$> (instantiateMVars (← Term.elabTermAndSynthesize t none))
      | none => pure none
    match os.ident `world with
    | none | some `lf => unsafe chainLitCmdW lfWorld pre srcN srvN plan.getString (os.num `cap) argE
    | some n =>
      let args := #[toExpr pre, toExpr srcN, toExpr srvN, toExpr plan.getString, toExpr (os.num `cap), quoteOptExpr argE]
      unsafe inWorld ``chainLitCmdW (← worldConst n) args

end Host.Ts.Sim.Template
