import host.sim.template.Build
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

/-! # A template whose collection keeps the framed arrays

`tpl_template` collects the cut from its roots, so a framed array no live object reaches is dropped, and no relation
under a context framing it can hold at the template (`RelB.framedPresent`: `K.fr a = some p → Present s a`).
`tpl_template_keep` is `templateCmdW` with the spec's frames added to the roots; nothing else changes. It lives beside
`Build` so nothing above that module rebuilds. -/

namespace Host.Ts.Sim.Template
open Lean Elab Command Meta Host.Ts Host.Load Host.Ts.Stream

private def addDef (name : Lean.Name) (type value : Lean.Expr) (compile : Bool := false) : TermElabM Unit := do
  let d := Declaration.defnDecl { name, levelParams := [], type, value, hints := .abbrev, safety := .safe }
  addDecl d
  if compile then compileDecl d

private def natList (xs : List Nat) : Lean.Expr := toExpr xs

unsafe def templateKeepCmdW {F : Ffi} (w : TWorld F) (pre srcName srvName : Lean.Name) (specPath : Option String) :
    TermElabM Unit := do
    astTabRef.set (← loadAstTab)
    Memo.reset
    let spec? ← specOfPath specPath
    let spec := spec?.getD {}
    let t0 ← IO.monoMsNow
    let fromLoad ← isDefEq (← inferType (mkConst srcName)) (mkApp (mkConst ``St) (mkConst ``LSt))
    let (s, c, _) ← if fromLoad then do
        let (l, c, g) ← restoreAny (S := LSt) (mkConst srcName) (mkConst srvName) pre
        pure (w.lift l, c, g)
      else restoreAny (S := F.S) (mkConst srcName) (mkConst srvName) pre
    let t1 ← IO.monoMsNow
    let l := w.proj s
    -- reachability (identity walk) and collection
    let m := l.aux.ffi.mlx
    let traceSet := traceNodesOf m
    let natRefs := nativeHeapRefs m
    let roots := ((List.range 40).filter fun a => (l.heap.get a).isSome) ++ natRefs ++ spec.framesD.filter fun a => (l.heap.get a).isSome
    let ctx : Ctx := { s1 := l, s2 := l, t1 := c.tab.toArray, t2 := c.tab.toArray, env := ← getEnv, traceNodes := traceSet }
    let extra := w.extraNodes s.aux.ffi
    let ((), wk) ← ((do
        for n in extra do pairNode n n (.root "extra") ""
        walkRoots (roots.map fun a => (a, a))).run ctx).run {}
    unless wk.mism.isEmpty do throwError "tpl_template_keep: the identity walk found {wk.mism.size} mismatches"
    let (sg, s) :=
      if spec.collect then
        let heap := ptrieFold (fun (acc : PTrie Host.Ts.HObj) a o => if wk.sig.contains a then acc.set a o else acc) l.heap PTrie.nil
        let nodes := ptrieFold (fun (acc : PTrie Host.Mlx.Ffi.Node) n nd => if wk.nod.contains n then acc.set n nd else acc) m.nodes PTrie.nil
        let items := ptrieFold (fun (acc : PTrie NumV) n x => if wk.nod.contains n then acc.set n x else acc) m.items PTrie.nil
        let sg : St LSt := { l with heap }
        -- native handles: only the live ones (garbage vectors and configs of earlier iterations go)
        let arrs := ptrieFold (fun (acc : PTrie Nat) h n => if wk.hnd.contains h then acc.set h n else acc) m.arrs PTrie.nil
        let objs := ptrieFold (fun (acc : PTrie Host.Mlx.Ffi.Obj) h o => if wk.hnd.contains h then acc.set h o else acc) m.objs PTrie.nil
        (sg.setFfi { sg.aux.ffi with mlx := { m with nodes, items, arrs, objs } },
          s.setFfi (w.restrict s.aux.ffi wk.hnd.contains wk.nod.contains))
      else (l, s)
    let symb := match spec? with
      | some sp => symbolizeSpec sp.places sg c
      | none => symbolize sg c
    let (T0, c0, ents) ← match symb with
      | .ok r => pure r
      | .error e => throwError "tpl_template_keep: {e}"
    let T0 := w.unproj s T0
    let t2 ← IO.monoMsNow
    let nonce := s!"{pre}:{← IO.monoNanosNow}"
    let dir ← streamDir
    IO.FS.createDirAll (dir / pre.toString)
    let nilAns := mkApp (mkConst ``List.nil [.zero]) (mkConst ``Ans)
    let (_, bytes) ← writeBoundaryW w pre nonce dir { pre } 0 T0 c0.tab nilAns none
    addDef (pre ++ `F) (mkConst ``Ffi) (mkConst w.ffiC)
    addDef (pre ++ `nonce) (mkConst ``String) (toExpr nonce) (compile := true)
    addDef (pre ++ `ks) (mkApp (mkConst ``List [.zero]) (mkConst ``Nat)) (natList []) (compile := true)
    let pairTy := mkApp2 (mkConst ``Prod [.zero, .zero]) (mkConst ``Nat) (mkConst ``Nat)
    addDef (pre ++ `entries) (mkApp (mkConst ``List [.zero]) pairTy) (toExpr (ents.toList.map fun e => (e.ref, e.var)))
    let origTy := mkApp2 (mkConst ``Prod [.zero, .zero]) (mkConst ``Nat) (mkConst ``NumV)
    addDef (pre ++ `orig) (mkApp (mkConst ``List [.zero]) origTy) (toExpr (ents.toList.map fun e => (e.ref, e.orig)))
    if let some sp := spec? then
      let natsTy := mkApp (mkConst ``List [.zero]) (mkConst ``Nat)
      addDef (pre ++ `frames) natsTy (natList sp.framesD) (compile := true)
      addDef (pre ++ `ghosts) natsTy (natList sp.ghosts) (compile := true)
      addDef (pre ++ `maps) natsTy (natList sp.maps) (compile := true)
      addDef (pre ++ `frozen) natsTy (natList sp.frozen) (compile := true)
      let lT := w.proj T0
      let j := Lean.Json.mkObj [("world", Lean.toJson w.name), ("frames", Lean.toJson sp.framesD),
        ("start", Lean.Json.mkObj [("n", Lean.toJson c0.tab.length), ("next", Lean.toJson lT.next),
          ("mnext", Lean.toJson lT.aux.ffi.mlx.next), ("nnext", Lean.toJson lT.aux.ffi.mlx.nnext)]),
        ("ghosts", Lean.toJson sp.ghosts), ("maps", Lean.toJson sp.maps), ("frozen", Lean.toJson sp.frozen),
        ("entries", Lean.Json.arr (ents.map fun e => Lean.Json.mkObj [("name", Lean.toJson e.name),
          ("ref", Lean.toJson e.ref), ("var", Lean.toJson e.var), ("orig", Lean.toJson (fmtNum c.tab.toArray e.orig))]))]
      IO.FS.writeFile (dir / pre.toString / "template.json") (j.pretty ++ "\n")
    let heapN : Nat := ptrieFold (fun (k : Nat) _ _ => k + 1) l.heap 0
    let desc := w.describe T0.aux.ffi
    logInfo m!"tpl_template_keep {pre}: restore {t1 - t0} ms, collect+symbolize {t2 - t1} ms; heap {wk.sig.size}/{heapN} kept, live handles {wk.hnd.size}, live nodes {wk.nod.size} (trace {traceSet.size}); table {c.tab.length} -> {c0.tab.length}; boundary {bytes} bytes{if w.name == "lf" then "" else s!"; world {w.name}{if fromLoad then " (lifted)" else ""}: {desc}"}"


/-- `tpl_template_keep T from s, S (world := w, spec := "<file or JSON>")`: `tpl_template`, keeping the spec's frames. -/
elab "tpl_template_keep " p:ident " from " src:ident ", " srv:ident os:(tplOpts)? : command =>
  liftTermElabM <| withOptions (fun o => o.setBool `Elab.async false) do
    let os : TplOpts := tplOptsOf (os.map (·.raw))
    os.check [`world, `spec]
    let pre := (← getCurrNamespace) ++ p.getId
    let srcN ← resolveGlobalConstNoOverload src
    let srvN ← resolveGlobalConstNoOverload srv
    match os.ident `world with
    | none | some `lf => unsafe templateKeepCmdW lfWorld pre srcN srvN (os.str `spec)
    | some n => unsafe inWorld ``templateKeepCmdW (← worldConst n) #[toExpr pre, toExpr srcN, toExpr srvN, toExpr (os.str `spec)]

end Host.Ts.Sim.Template
