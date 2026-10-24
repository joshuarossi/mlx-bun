import host.sim.template.Build
import host.sim.dispatch.BridgeNewData
import host.sim.full.BridgeSize
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

/-! # Final and exit case streams split at the epilogue spread

A final case (`FINAL`, `FINALC0`, `FINALC1`, and the EOS final cases `FINALE`, `FINALEC0`)
starts from `finalStart T.s0 T.S0.tab.length` (the template with its look-ahead token
reference) and runs to halt; the EOS exit case `EOSX` (no look-ahead token) starts from
`T.s0` itself. Its run is cut at the epilogue's spread of the framed
`forwarded` array (the first state returning `forwarded` into an array literal's
last spread, `Host.Ts.Sim.FinalCase.ctlA`/`stackA`): boundary `X.ia` is that state, `X.ia - 1`
the state before it (the first segment ends there: the acceptance rejects the spread's state),
`X.ia + 1` the state after its step, and the second segment's acceptance frames the new
array `X.aN` (the spread's `next`).

With `bridging B` (`B : List Nat → St LSt → Option String`, e.g. `spreadBridge`) the run is cut at
every state `s` with `B frames s = some kind` (`frames`: the arrays framed so far; a `"spread"`
bridge frames its new array for the following segments), each as above. With a bridge function
`B : List Nat → St LSt → SSrv → Option BridgeHit` (`host.sim.template.Bridges`, `routeBridges`)
a bridge may also patch the template: the state after the bridge state is the hit's `patch`
(the patched template of the bridge lemma, with the table entries it adds) instead of the bridge
state's own step, and the hit frames its addresses for the following segments. Both forms write
`seg.json` (`Build.writeSeg`: every bridge point) beside `split.txt` (the first).

The options `(world := w, spec := "…", cap := n)` are as for `tpl_case`; bridges look at the load
world's projection. -/

namespace Host.Ts.Sim.Template
open Lean Elab Command Meta Host.Ts Host.Load Host.Ts.Stream

/-- The final template start, `Host.Ts.Sim.finalStart` (restated so that the final streams do not
depend on `host.sim.LoopFinal`; each case's `start` proves the two equal). -/
def finalStart0 (s0 : St LSt) (n : Nat) : St LSt :=
  s0.setFfi { s0.ffi with mlx := { s0.ffi.mlx with tokens := s0.ffi.mlx.tokens ++ [.ref n] } }

/-- The spread's state: `forwarded` returned into the last spread of an array literal. -/
def atSpread (s : St LSt) : Bool :=
  match s.ctl, s.stack with
  | .ret (.obj 2673447), .l (.spread _ [] _) :: _ => true
  | _, _ => false

/-- A spread bridge: a framed array returned into the last spread of an array literal. -/
def spreadBridge (frames : List Nat) (s : St LSt) : Option String :=
  match s.ctl, s.stack with
  | .ret (.obj a), .l (.spread _ [] _) :: _ => if frames.contains a then some "spread" else none
  | _, _ => none

/-- A bridge point (`host.sim.template.Bridges`): its kind; the patched state after it with the
table entries the patch adds (`none`: the bridge state's own step); the addresses it frames for
the following segments; its kind-specific `seg.json` fields. -/
structure BridgeHit where
  kind : String
  patch : Option (St LSt × List SymE) := none
  /-- B-newdata: the patched step `Disp.newDataS` with these template bytes, run in the case's world. -/
  ndBytes : Option (List Byte) := none
  /-- B-size: the patched transition `Disp.sizeS` (the native call, `Number`'s argument frame, `Number`). -/
  size : Bool := false
  frames : List Nat := []
  extra : List (String × Lean.Json) := []

/-- B-newdata's call (`Disp.bridge_newdata`): the symbol's name and return type, the signature's
argument types, the remaining arguments and the buffer the first argument points into. -/
def Bridge.ndParts {S : Type} (s : St S) : Option (Name × Name × List Val × List Val × Nat) :=
  match s.ctl with
  | .call (.obj fsym) _ (.ptr (.js b) 0 :: rest) => match s.obj? fsym with
    | some fo => match fo.kind with
      | .fn (.native (.ffi .symbol) [.str name, .obj ta, .str rt]) => match s.obj? ta with
        | some oa => match oa.kind with
          | .array (.str _ :: tys) => some (name, rt, tys, rest, b)
          | _ => none
        | none => none
      | _ => none
    | none => none
  | _ => none

private def addDefS (name : Lean.Name) (type value : Lean.Expr) (compile : Bool := false) : TermElabM Unit := do
  let d := Declaration.defnDecl { name, levelParams := [], type, value, hints := .abbrev, safety := .safe }
  addDecl d
  if compile then compileDecl d

/-- A bridging term: the old form (kinds only, spreads frame their new array) or bridge hits. -/
inductive BridgeArg where
  | kinds (B : List Nat → St LSt → Option String)
  | hits (B : List Nat → St LSt → SSrv → Option BridgeHit)

/-- The halting case `nm` run in the world `w` from `finalStart T.s0 n` (`n` the template table's
length; from `T.s0` when the case reads no look-ahead token) to halt natively, writing boundaries
every 10 000 steps, before each bridge state (`ia - 1`), at it (`ia`) and after it (`ia + 1`);
defines `X.F`, `X.O`, `X.ks`, `X.nonce`, `X.srv`, `X.T1`, `X.steps`, `X.ia` and `X.aN` (of the first
bridge). -/
unsafe def caseSplitCmdW {F : Ffi} (w : TWorld F) (pre base : Lean.Name) (nm : String) (bridge : Option BridgeArg)
    (specPath : Option String) (capO : Option Nat) : TermElabM Unit := do
    let spec? ← specOfPath specPath
    let spec := spec?.getD {}
    let some cs := spec.case? nm | throwError "tpl_case_split: unknown case {nm}"
    if cs.loop then throwError "tpl_case_split: {nm} is a loop case"
    let cap := capO.getD 8000000
    astTabRef.set (← loadAstTab)
    Memo.reset
    let t0 ← IO.monoMsNow
    let (s0, c0, g0) ← restoreAny (S := F.S) (mkConst (base ++ `s0)) (mkConst (base ++ `S0)) pre
    let t1 ← IO.monoMsNow
    let r := c0.tab.length
    let l0 := w.proj s0
    let m := l0.aux.ffi.mlx
    let (s, tab, stE0) :=
      if cs.extraToken then
        (w.unproj s0 (l0.setFfi { l0.aux.ffi with mlx := { m with tokens := m.tokens ++ [.ref r] } }), c0.tab ++ [.var 17],
          -- the load world's start is `finalStart0`'s expression; another world's is serialized
          if w.name == "lf" then some (mkApp2 (mkConst ``Host.Ts.Sim.Template.finalStart0) (mkConst (base ++ `s0)) (mkRawNatLit r))
          else none)
      else (s0, c0.tab, some (mkConst (base ++ `s0)))
    let nonce := s!"{pre}:{← IO.monoNanosNow}"
    let dir ← streamDir
    IO.FS.createDirAll (dir / pre.toString)
    let oE := mkConst (pre ++ `O)
    let drop (k : Nat) := mkApp3 (mkConst ``List.drop [.zero]) (mkConst ``Ans) (mkRawNatLit k) oE
    let ρ := if spec?.isSome then spec.valuation cs else cs.valuation
    let (g, b0) ← writeBoundaryW w pre nonce dir g0 0 s tab (drop 0) stE0
    let mut g := g
    let mut bytes := b0
    let mut st := s
    let mut c : SSrv := ⟨tab, []⟩
    let mut o : Array Ans := #[]
    let mut steps : Nat := 0
    let mut ks : Array Nat := #[]
    let mut bs : Array SegBridge := #[]
    let mut frames : List Nat := spec.framesD
    let mut spreads : Nat := 0
    let mut halted := false
    -- without `bridging`, only the first spread of `forwarded` is a bridge
    let maxB := if bridge.isSome then 1000000 else 1
    while !halted do
      let mut n : Nat := 0
      let mut cut : Option BridgeHit := none
      while n < 10000 do
        if isHalt st.ctl then halted := true; break
        match interpRec ρ (step F st).run c [] with
        | some (s', c', a) =>
          let hit? : Option BridgeHit := match bridge with
            | none => if atSpread (w.proj s') then some { kind := "spread" } else none
            | some (.kinds B) => (B frames (w.proj s')).map fun kd => { kind := kd }
            | some (.hits B) => B frames (w.proj s') c'
          if let some hit := hit? then
            spreads := spreads + 1
            -- `st` is the state before the bridge state (`sP`): end the chunk here
            if bs.size < maxB then cut := some hit; break
          st := s'; c := c'; o := o ++ a.reverse.toArray; steps := steps + 1; n := n + 1
        | none => throwError "tpl_case_split {pre}: stuck after {steps} steps"
      if n > 0 then
        ks := ks.push n
        let (g', b) ← writeBoundaryW w pre nonce dir g ks.size st c.tab (drop o.size) none
        g := g'
        bytes := bytes + b
      if let some hit := cut then
        -- one-step chunks to the bridge state (boundary `ia`, `sA`) and the state after it (`sB`):
        -- the bridge state's step, or the hit's patch
        let nA := ks.foldl (· + ·) 0
        for k in [0:2] do
          if k == 1 && hit.size then
            match interpRec ρ (Disp.sizeS F st).run c [] with
            | some (s', c', a) => st := s'; c := c'; o := o ++ a.reverse.toArray; steps := steps + 3
            | none => throwError "tpl_case_split {pre}: the patched B-size transition is stuck"
          else
            match k, hit.patch, hit.ndBytes.bind fun bsT => (Bridge.ndParts st).map (·, bsT) with
            | 1, some (lB, es), _ =>
              st := w.unproj st lB; c := { c with tab := c.tab ++ es }; steps := steps + 1
            | 1, none, some ((name, rt, tys, rest, b), bsT) =>
              match interpRec ρ (Disp.newDataS F st name rt tys rest b bsT).run c [] with
              | some (s', c', a) => st := s'; c := c'; o := o ++ a.reverse.toArray; steps := steps + 1
              | none => throwError "tpl_case_split {pre}: the patched B-newdata step is stuck"
            | _, _, _ =>
              match interpRec ρ (step F st).run c [] with
              | some (s', c', a) => st := s'; c := c'; o := o ++ a.reverse.toArray; steps := steps + 1
              | none => throwError "tpl_case_split {pre}: stuck at the bridge"
          -- B-size's transition is three steps of the machine
          ks := ks.push (if k == 1 && hit.size then 3 else 1)
          if k == 0 then
            let arr := match st.ctl with
              | .ret (.obj a) => a
              | _ => 0
            let extra := hit.extra ++ (if hit.patch.isSome || hit.ndBytes.isSome || hit.size then [("patched", Lean.toJson true)] else [])
            bs := bs.push { kind := hit.kind, ia := ks.size, aN := st.next, nA := nA, arr := arr, extra := extra }
            if hit.kind == "spread" then frames := frames ++ [st.next]
            frames := frames ++ hit.frames
          let (g', b) ← writeBoundaryW w pre nonce dir g ks.size st c.tab (drop o.size) none
          g := g'
          bytes := bytes + b
      if steps > cap then throwError "tpl_case_split {pre}: no halt within {cap} steps"
    let some b1 := bs[0]? | throwError "tpl_case_split {pre}: no spread of forwarded before halt"
    let iA := b1.ia
    let aN := b1.aN
    let nA := b1.nA
    -- the split for the module generators (`gen.ts`, `genFinal.ts`): T1, ia, aN, steps, and nA
    -- the steps to the state before the spread's (boundary `ia - 1`)
    IO.FS.writeFile (dir / pre.toString / "split.txt") s!"{ks.size} {iA} {aN} {steps} {nA}\n"
    writeSeg dir pre (segJson cs.name "halt" ks.size steps spec.framesD bs.toList
      (segMore w (w.proj s) (w.proj st) (spec.grows cs.name) ++ [("framesEnd", Lean.toJson frames)]))
    let t2 ← IO.monoMsNow
    let ansL := mkApp (mkConst ``List [.zero]) (mkConst ``Ans)
    addDefS (pre ++ `O) ansL (toExpr o.toList)
    addDefS (pre ++ `F) (mkConst ``Ffi) (mkConst w.ffiC)
    addDefS (pre ++ `ks) (mkApp (mkConst ``List [.zero]) (mkConst ``Nat)) (toExpr ks.toList) (compile := true)
    addDefS (pre ++ `nonce) (mkConst ``String) (toExpr nonce) (compile := true)
    addDefS (pre ++ `srv) (mkConst ``SSrv) (mkApp2 (mkConst ``SSrv.mk) (toExpr tab) oE)
    addDefS (pre ++ `T1) (mkConst ``Nat) (mkRawNatLit ks.size) (compile := true)
    addDefS (pre ++ `steps) (mkConst ``Nat) (mkRawNatLit steps)
    addDefS (pre ++ `ia) (mkConst ``Nat) (mkRawNatLit iA) (compile := true)
    addDefS (pre ++ `aN) (mkConst ``Nat) (mkRawNatLit aN)
    logInfo m!"tpl_case_split {pre} ({cs.name}): restore {t1 - t0} ms, run+write {t2 - t1} ms; {steps} steps to halt, {ks.size} chunks (T1 = {pre}.s{ks.size}); spread at boundary {iA} (step {nA + 1}, aN = {aN}; {spreads} spread states in all; {bs.size} bridges), oracle {o.size} answers, {bytes} bytes{if w.name == "lf" then "" else s!"; world {w.name}: {w.describe st.aux.ffi}"}"

/-- `caseSplitCmdW` at the load world. -/
unsafe def caseSplitCmd (pre base : Lean.Name) (nm : String) (bridge : Option BridgeArg) : TermElabM Unit :=
  caseSplitCmdW lfWorld pre base nm bridge none none

/-- Evaluate a `bridging` term: a bridge-hit function, else a kind function. -/
unsafe def bridgeArgOf (e : Lean.Expr) : TermElabM BridgeArg := do
  let natsT := mkApp (mkConst ``List [.zero]) (mkConst ``Nat)
  let stT := mkApp (mkConst ``St) (mkConst ``LSt)
  let hitsT ← mkArrow natsT (← mkArrow stT (← mkArrow (mkConst ``SSrv) (mkApp (mkConst ``Option [.zero]) (mkConst ``BridgeHit))))
  if ← isDefEq (← inferType e) hitsT then
    return .hits (← evalExpr (List Nat → St LSt → SSrv → Option BridgeHit) hitsT e)
  let ty ← mkArrow natsT (← mkArrow stT (mkApp (mkConst ``Option [.zero]) (mkConst ``String)))
  return .kinds (← evalExpr (List Nat → St LSt → Option String) ty e)

/-- `tpl_case_split X from T : "NAME" [bridging B] [(world := w, spec := "…", cap := n)]`. -/
elab "tpl_case_split " p:ident " from " b:ident " : " nm:str br:((" bridging " term)?) os:(tplOpts)? : command =>
  liftTermElabM <| withOptions (fun o => o.setBool `Elab.async false) do
    let os : TplOpts := tplOptsOf (os.map (·.raw))
    os.check [`world, `spec, `cap]
    let e ← match br.raw.getArgs.toList with
      | [_, t] => pure (some (← instantiateMVars (← Term.elabTermAndSynthesize t none)))
      | _ => pure none
    let ns ← getCurrNamespace
    let pre := ns ++ p.getId
    let base := ns ++ b.getId
    match os.ident `world with
    | none | some `lf =>
      let barg ← match e with
        | some e => some <$> unsafe bridgeArgOf e
        | none => pure none
      unsafe caseSplitCmdW lfWorld pre base nm.getString barg (os.str `spec) (os.num `cap)
    | some n =>
      -- another world: the bridging term is passed as an expression and evaluated there
      let bE ← match e with
        | some e => do
          let natsT := mkApp (mkConst ``List [.zero]) (mkConst ``Nat)
          let stT := mkApp (mkConst ``St) (mkConst ``LSt)
          let hitsT ← mkArrow natsT (← mkArrow stT (← mkArrow (mkConst ``SSrv) (mkApp (mkConst ``Option [.zero]) (mkConst ``BridgeHit))))
          let arg := if ← isDefEq (← inferType e) hitsT then mkApp (mkConst ``BridgeArg.hits) e else mkApp (mkConst ``BridgeArg.kinds) e
          pure (mkApp2 (mkConst ``Option.some [.zero]) (mkConst ``BridgeArg) arg)
        | none => pure (mkApp (mkConst ``Option.none [.zero]) (mkConst ``BridgeArg))
      let args := #[toExpr pre, toExpr base, toExpr nm.getString, bE, toExpr (os.str `spec), toExpr (os.num `cap)]
      unsafe inWorld ``caseSplitCmdW (← worldConst n) args

end Host.Ts.Sim.Template
