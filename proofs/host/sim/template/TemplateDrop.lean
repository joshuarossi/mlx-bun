import host.sim.template.Build
import host.sim.template.Sigma
set_option Elab.async false
namespace Host.Ts.Sim.Template
open Lean Elab Command Meta Host.Ts Host.Ts.Sim Host.Load Host.Ts.Stream

/-! # A template without some dead native handles

`tpl_drop X from T : objs [h, …] arrs [h, …] (world := w)` is the template `T` without the listed native objects and arrays. For handles no class
relates to the template: they are not reached from the heap, and classes that share the template hold them differently or not at all. An identity
walk checks nothing still reaches them. The template is a choice: a chain that read a dropped handle would be rejected there. -/

private def addDropDef (name : Lean.Name) (type value : Lean.Expr) (compile : Bool := false) : TermElabM Unit := do
  let d := Declaration.defnDecl { name, levelParams := [], type, value, hints := .abbrev, safety := .safe }
  addDecl d
  if compile then compileDecl d

/-- The body of `tpl_drop`. -/
unsafe def dropCmdW {F : Ffi} (w : TWorld F) (pre base : Lean.Name) (objs arrs : List Nat) : TermElabM Unit := do
  astTabRef.set (← loadAstTab)
  Memo.reset
  let hasView := (← getEnv).contains (base ++ `chooser)
  let (s, c, _) ← restoreAny (S := F.S) (mkConst (base ++ (if hasView then `chooser else `s0)))
    (mkConst (base ++ (if hasView then `chooserSrv else `S0))) pre
  let l := w.proj s
  let m := l.aux.ffi.mlx
  for h in objs do
    unless (m.objs.get h).isSome do throwError "tpl_drop: {h} is not an object"
  for h in arrs do
    unless (m.arrs.get h).isSome do throwError "tpl_drop: {h} is not an array"
  let objs1 := ptrieFold (fun acc k v => if objs.contains k then acc else acc.set k v) m.objs PTrie.nil
  let arrs1 := ptrieFold (fun acc k v => if arrs.contains k then acc else acc.set k v) m.arrs PTrie.nil
  let l1 : St LSt := l.setFfi { l.aux.ffi with mlx := { m with objs := objs1, arrs := arrs1 } }
  let s1 := w.unproj s l1
  let roots := ((List.range 40).filter fun a => (l1.heap.get a).isSome) ++ nativeHeapRefs l1.aux.ffi.mlx
  let ctx : Ctx := { s1 := l1, s2 := l1, t1 := c.tab.toArray, t2 := c.tab.toArray, env := ← getEnv, traceNodes := traceNodesOf l1.aux.ffi.mlx }
  let ((), wk) ← ((do
      for k in w.extraNodes s1.aux.ffi do pairNode k k (.root "extra") ""
      walkRoots (roots.map fun a => (a, a))).run ctx).run {}
  unless wk.mism.isEmpty do throwError "tpl_drop: the identity walk found {wk.mism.size} mismatches"
  for h in objs ++ arrs do
    if wk.hnd.contains h then throwError "tpl_drop: {h} is still reached"
  let gone : Nat → Bool := fun h => objs.contains h || arrs.contains h
  let T0 := s1.setFfi (w.restrict s1.aux.ffi (fun h => !gone h) (fun _ => true))
  let nonce := s!"{pre}:{← IO.monoNanosNow}"
  let dir ← streamDir
  IO.FS.createDirAll (dir / pre.toString)
  let nilAns := mkApp (mkConst ``List.nil [.zero]) (mkConst ``Ans)
  let (_, bytes) ← writeBoundaryW w pre nonce dir { pre } 0 T0 c.tab nilAns none
  let natsTy := mkApp (mkConst ``List [.zero]) (mkConst ``Nat)
  let pairTy := mkApp2 (mkConst ``Prod [.zero, .zero]) (mkConst ``Nat) (mkConst ``Nat)
  let origTy := mkApp2 (mkConst ``Prod [.zero, .zero]) (mkConst ``Nat) (mkConst ``NumV)
  addDropDef (pre ++ `F) (mkConst ``Ffi) (mkConst w.ffiC)
  addDropDef (pre ++ `nonce) (mkConst ``String) (toExpr nonce) (compile := true)
  addDropDef (pre ++ `ks) natsTy (toExpr ([] : List Nat)) (compile := true)
  addDropDef (pre ++ `entries) (mkApp (mkConst ``List [.zero]) pairTy) (mkConst (base ++ `entries))
  addDropDef (pre ++ `orig) (mkApp (mkConst ``List [.zero]) origTy) (mkConst (base ++ `orig))
  for k in [`maps, `frozen, `frames, `ghosts] do
    addDropDef (pre ++ k) natsTy (mkConst (base ++ k)) (compile := true)
  let baseJ ← IO.FS.readFile (dir / base.toString / "template.json")
  IO.FS.writeFile (dir / pre.toString / "template.json") baseJ
  logInfo m!"tpl_drop {pre}: objects {objs}, arrays {arrs}; {bytes} bytes"

declare_syntax_cat dropList
syntax "[" num,* "]" : dropList

private def dropNums : Syntax → List Nat
  | `(dropList| [$ns,*]) => ns.getElems.toList.map (·.getNat)
  | _ => []

elab "tpl_drop " p:ident " from " b:ident " : " "objs " o:dropList " arrs " a:dropList os:(tplOpts)? : command =>
  liftTermElabM <| withOptions (fun o => o.setBool `Elab.async false) do
    let os : TplOpts := tplOptsOf (os.map (·.raw))
    os.check [`world]
    let pre := (← getCurrNamespace) ++ p.getId
    let base := (← getCurrNamespace) ++ b.getId
    let some wc := os.ident `world | throwError "tpl_drop: give a world"
    unsafe inWorld ``dropCmdW (← worldConst wc) #[toExpr pre, toExpr base, toExpr (dropNums o), toExpr (dropNums a)]

end Host.Ts.Sim.Template
