import host.sim.template.Build
import host.sim.template.Sigma
set_option Elab.async false
namespace Host.Ts.Sim.Template
open Lean Elab Command Meta Host.Ts Host.Ts.Sim Host.Load Host.Ts.Stream

/-! # A template with a lower address counter

`tpl_lower X from T : lim (world := w)` is the template `T` with its address counter at `lim`. The classes that share a template differ in how
many addresses they used before it; a link needs the template's counter at or below every class's. The few live addresses at or above `lim` move
just below it, in order, into free addresses, and everything mentioning them follows. An identity walk checks nothing still points at the old ones. The
template is a choice: every use of it is a kernel check. -/

private def addLowerDef (name : Lean.Name) (type value : Lean.Expr) (compile : Bool := false) : TermElabM Unit := do
  let d := Declaration.defnDecl { name, levelParams := [], type, value, hints := .abbrev, safety := .safe }
  addDecl d
  if compile then compileDecl d

/-- The body of `tpl_lower`. -/
unsafe def lowerCmdW {F : Ffi} (w : TWorld F) (pre base : Lean.Name) (lim : Nat) : TermElabM Unit := do
  astTabRef.set (← loadAstTab)
  Memo.reset
  let hasView := (← getEnv).contains (base ++ `chooser)
  let (s, c, _) ← restoreAny (S := F.S) (mkConst (base ++ (if hasView then `chooser else `s0)))
    (mkConst (base ++ (if hasView then `chooserSrv else `S0))) pre
  let l := w.proj s
  let m := l.aux.ffi.mlx
  let keys := (ptrieFold (fun (acc : Array Nat) a _ => acc.push a) l.heap #[]).qsort (· < ·)
  let hi := keys.filter (· ≥ lim)
  let first := lim - hi.size
  if keys.any (fun a => first ≤ a && a < lim) then
    throwError "tpl_lower: an address in [{first}, {lim}) is taken"
  let heapP : PTrie Nat := hi.foldl (init := (PTrie.nil, first)) (fun (t, b) a => (t.set a b, b + 1)) |>.1
  let D : RData := ⟨l.next, lim, heapP, PTrie.nil, m.next, m.next, m.nnext, m.nnext, PTrie.nil, PTrie.nil⟩
  let σ := D.map
  -- what mentions no moved address stays the same object, so its sharing survives
  let below : Nat → Bool := fun a => a < lim
  let nBig := c.tab.length + 1
  let heap := ptrieFold (fun (acc : PTrie Host.Ts.HObj) a h =>
    acc.set (σ.a a) (if bHobj below nBig h then h else σ.hobj h)) l.heap PTrie.nil
  let aux := { l.aux with jobs := l.aux.jobs.map σ.job, stores := σ.stores l.aux.stores }
  let l1 : St LSt := { l with heap, next := lim, ctl := σ.ctl l.ctl, stack := l.stack.map σ.frame, aux }
  let T0 := w.unproj s l1
  let roots := ((List.range 40).filter fun a => (l1.heap.get a).isSome) ++ nativeHeapRefs l1.aux.ffi.mlx
  let ctx : Ctx := { s1 := l1, s2 := l1, t1 := c.tab.toArray, t2 := c.tab.toArray, env := ← getEnv, traceNodes := traceNodesOf l1.aux.ffi.mlx }
  let ((), wk) ← ((do
      for k in w.extraNodes T0.aux.ffi do pairNode k k (.root "extra") ""
      walkRoots (roots.map fun a => (a, a))).run ctx).run {}
  unless wk.mism.isEmpty do throwError "tpl_lower: the identity walk found {wk.mism.size} mismatches"
  for a in hi do
    if wk.sig.contains a then throwError "tpl_lower: {a} is still reached"
  let nonce := s!"{pre}:{← IO.monoNanosNow}"
  let dir ← streamDir
  IO.FS.createDirAll (dir / pre.toString)
  let nilAns := mkApp (mkConst ``List.nil [.zero]) (mkConst ``Ans)
  let (_, bytes) ← writeBoundaryW w pre nonce dir { pre } 0 T0 c.tab nilAns none
  let natsTy := mkApp (mkConst ``List [.zero]) (mkConst ``Nat)
  let pairTy := mkApp2 (mkConst ``Prod [.zero, .zero]) (mkConst ``Nat) (mkConst ``Nat)
  let origTy := mkApp2 (mkConst ``Prod [.zero, .zero]) (mkConst ``Nat) (mkConst ``NumV)
  addLowerDef (pre ++ `F) (mkConst ``Ffi) (mkConst w.ffiC)
  addLowerDef (pre ++ `nonce) (mkConst ``String) (toExpr nonce) (compile := true)
  addLowerDef (pre ++ `ks) natsTy (toExpr ([] : List Nat)) (compile := true)
  addLowerDef (pre ++ `entries) (mkApp (mkConst ``List [.zero]) pairTy) (mkConst (base ++ `entries))
  addLowerDef (pre ++ `orig) (mkApp (mkConst ``List [.zero]) origTy) (mkConst (base ++ `orig))
  for k in [`maps, `frozen, `frames, `ghosts] do
    addLowerDef (pre ++ k) natsTy (mkConst (base ++ k)) (compile := true)
  let baseJ ← IO.FS.readFile (dir / base.toString / "template.json")
  let j ← match Json.parse baseJ with | .ok j => pure j | .error e => throwError "tpl_lower: {e}"
  let start := (j.getObjValD "start").setObjVal! "next" (toJson lim)
  IO.FS.writeFile (dir / pre.toString / "template.json") ((j.setObjVal! "start" start).pretty ++ "\n")
  logInfo m!"tpl_lower {pre}: next {l.next} -> {lim}; moved {hi.toList} to [{first}, {lim}); {bytes} bytes"

elab "tpl_lower " p:ident " from " b:ident " : " n:num os:(tplOpts)? : command =>
  liftTermElabM <| withOptions (fun o => o.setBool `Elab.async false) do
    let os : TplOpts := tplOptsOf (os.map (·.raw))
    os.check [`world]
    let pre := (← getCurrNamespace) ++ p.getId
    let base := (← getCurrNamespace) ++ b.getId
    let some wc := os.ident `world | throwError "tpl_lower: give a world"
    unsafe inWorld ``lowerCmdW (← worldConst wc) #[toExpr pre, toExpr base, toExpr n.getNat]

end Host.Ts.Sim.Template
