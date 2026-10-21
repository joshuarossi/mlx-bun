import host.sim.template.Build
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

/-! # Final case streams split at the epilogue spread

A final case (`FINAL`, `FINALC0`, `FINALC1`) starts from
`finalStart T.s0 T.S0.tab.length` (the template with its look-ahead token
reference) and runs to halt. Its run is cut at the epilogue's spread of the framed
`forwarded` array (the first state returning `forwarded` into an array literal's
last spread, `Host.Ts.Sim.FinalCase.ctlA`/`stackA`): boundary `X.ia` is that state, `X.ia - 1`
the state before it (the first segment ends there: the acceptance rejects the spread's state),
`X.ia + 1` the state after its step, and the second segment's acceptance frames the new
array `X.aN` (the spread's `next`). -/

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

private def addDefS (name : Lean.Name) (type value : Lean.Expr) (compile : Bool := false) : TermElabM Unit := do
  let d := Declaration.defnDecl { name, levelParams := [], type, value, hints := .abbrev, safety := .safe }
  addDecl d
  if compile then compileDecl d

/-- `tpl_case_split X from T : "NAME"`: run final case `NAME` from `finalStart T.s0 n`
(`n` the template table's length) to halt natively, writing boundaries every 10 000
steps, before the spread (`X.ia - 1`), at it (`X.ia`) and after its step; defines `X.F`, `X.O`, `X.ks`,
`X.nonce`, `X.srv`, `X.T1`, `X.steps`, `X.ia` and `X.aN`. -/
unsafe def caseSplitCmd (pre base : Lean.Name) (nm : String) : TermElabM Unit := do
    let some cs := cases.find? (·.name == nm) | throwError "tpl_case_split: unknown case {nm}"
    unless cs.extraToken && !cs.loop do throwError "tpl_case_split: {nm} is not a final case"
    astTabRef.set (← loadAstTab)
    Memo.reset
    let t0 ← IO.monoMsNow
    let (s0, c0, g0) ← restore (mkConst (base ++ `s0)) (mkConst (base ++ `S0)) pre
    let t1 ← IO.monoMsNow
    let r := c0.tab.length
    let m := s0.aux.ffi.mlx
    let s := s0.setFfi { s0.aux.ffi with mlx := { m with tokens := m.tokens ++ [.ref r] } }
    let tab := c0.tab ++ [.var 17]
    let stE0 := mkApp2 (mkConst ``Host.Ts.Sim.Template.finalStart0) (mkConst (base ++ `s0)) (mkRawNatLit r)
    let nonce := s!"{pre}:{← IO.monoNanosNow}"
    let dir ← streamDir
    IO.FS.createDirAll (dir / pre.toString)
    let oE := mkConst (pre ++ `O)
    let drop (k : Nat) := mkApp3 (mkConst ``List.drop [.zero]) (mkConst ``Ans) (mkRawNatLit k) oE
    let ρ := cs.valuation
    let (g, b0) ← writeBoundary pre nonce dir g0 0 s tab (drop 0) (some stE0)
    let mut g := g
    let mut bytes := b0
    let mut st := s
    let mut c : SSrv := ⟨tab, []⟩
    let mut o : Array Ans := #[]
    let mut steps : Nat := 0
    let mut ks : Array Nat := #[]
    let mut ia : Option Nat := none
    let mut aN : Nat := 0
    let mut spreads : Nat := 0
    let mut halted := false
    while !halted do
      let mut n : Nat := 0
      let mut cut := false
      while n < 10000 do
        if isHalt st.ctl then halted := true; break
        match interpRec ρ (step Host.Load.ffi st).run c [] with
        | some (s', c', a) =>
          if atSpread s' then
            spreads := spreads + 1
            -- `st` is the state before the spread's (`sP`): end the chunk here
            if ia.isNone then cut := true; break
          st := s'; c := c'; o := o ++ a.reverse.toArray; steps := steps + 1; n := n + 1
        | none => throwError "tpl_case_split {pre}: stuck after {steps} steps"
      if n > 0 then
        ks := ks.push n
        let (g', b) ← writeBoundary pre nonce dir g ks.size st c.tab (drop o.size) none
        g := g'
        bytes := bytes + b
      if cut then
        -- one-step chunks to the spread's state (boundary `ia`, `sA`) and the state after it (`sB`)
        for k in [0:2] do
          match interpRec ρ (step Host.Load.ffi st).run c [] with
          | some (s', c', a) => st := s'; c := c'; o := o ++ a.reverse.toArray; steps := steps + 1
          | none => throwError "tpl_case_split {pre}: stuck at the spread"
          ks := ks.push 1
          if k == 0 then
            ia := some ks.size
            aN := st.next
          let (g', b) ← writeBoundary pre nonce dir g ks.size st c.tab (drop o.size) none
          g := g'
          bytes := bytes + b
      if steps > 8000000 then throwError "tpl_case_split {pre}: no halt within 8000000 steps"
    let some iA := ia | throwError "tpl_case_split {pre}: no spread of forwarded before halt"
    let nA := (ks.toList.take (iA - 1)).foldl (· + ·) 0
    -- the split for the module generators (`gen.ts`, `genFinal.ts`): T1, ia, aN, steps, and nA
    -- the steps to the state before the spread's (boundary `ia - 1`)
    IO.FS.writeFile (dir / pre.toString / "split.txt") s!"{ks.size} {iA} {aN} {steps} {nA}\n"
    let t2 ← IO.monoMsNow
    let ansL := mkApp (mkConst ``List [.zero]) (mkConst ``Ans)
    addDefS (pre ++ `O) ansL (toExpr o.toList)
    addDefS (pre ++ `F) (mkConst ``Ffi) (mkConst ``Host.Load.ffi)
    addDefS (pre ++ `ks) (mkApp (mkConst ``List [.zero]) (mkConst ``Nat)) (toExpr ks.toList) (compile := true)
    addDefS (pre ++ `nonce) (mkConst ``String) (toExpr nonce) (compile := true)
    addDefS (pre ++ `srv) (mkConst ``SSrv) (mkApp2 (mkConst ``SSrv.mk) (toExpr tab) oE)
    addDefS (pre ++ `T1) (mkConst ``Nat) (mkRawNatLit ks.size) (compile := true)
    addDefS (pre ++ `steps) (mkConst ``Nat) (mkRawNatLit steps)
    addDefS (pre ++ `ia) (mkConst ``Nat) (mkRawNatLit iA) (compile := true)
    addDefS (pre ++ `aN) (mkConst ``Nat) (mkRawNatLit aN)
    logInfo m!"tpl_case_split {pre} ({cs.name}): restore {t1 - t0} ms, run+write {t2 - t1} ms; {steps} steps to halt, {ks.size} chunks (T1 = {pre}.s{ks.size}); spread at boundary {iA} (step {nA + 1}, aN = {aN}; {spreads} spread states in all), oracle {o.size} answers, {bytes} bytes"

elab "tpl_case_split " p:ident " from " b:ident " : " nm:str : command =>
  liftTermElabM <| withOptions (fun o => o.setBool `Elab.async false) do
    unsafe caseSplitCmd ((← getCurrNamespace) ++ p.getId) ((← getCurrNamespace) ++ b.getId) nm.getString

end Host.Ts.Sim.Template
