import host.sim.template.Build
set_option Elab.async false
namespace Host.Ts.Sim.Template
open Lean Elab Command Meta Host.Ts Host.Ts.Sim Host.Load Host.Ts.Stream

/-! # A template with table entries nothing reads set to literals

`tpl_tab X from T : [r, …] (world := w)` is the template `T` with the listed table entries set to the literal `0`. For an entry no number in the
state refers to: the entry's value is then the same under every valuation, so a later map into the template need not find it an image. That
nothing refers to it is checked where it counts: an entry something did refer to would fail that map's checks. -/

private def addTabDef (name : Lean.Name) (type value : Lean.Expr) (compile : Bool := false) : TermElabM Unit := do
  let d := Declaration.defnDecl { name, levelParams := [], type, value, hints := .abbrev, safety := .safe }
  addDecl d
  if compile then compileDecl d

/-- The body of `tpl_tab`. -/
unsafe def tabCmdW {F : Ffi} (w : TWorld F) (pre base : Lean.Name) (rs : List Nat) : TermElabM Unit := do
  astTabRef.set (← loadAstTab)
  Memo.reset
  let (s, c, _) ← restoreAny (S := F.S) (mkConst (base ++ `s0)) (mkConst (base ++ `S0)) pre
  let tab := c.tab.zipIdx.map fun (e, i) => if rs.contains i then SymE.lit (F64.ofNat 0) else e
  let nonce := s!"{pre}:{← IO.monoNanosNow}"
  let dir ← streamDir
  IO.FS.createDirAll (dir / pre.toString)
  let nilAns := mkApp (mkConst ``List.nil [.zero]) (mkConst ``Ans)
  let (_, bytes) ← writeBoundaryW w pre nonce dir { pre } 0 s tab nilAns none
  let natsTy := mkApp (mkConst ``List [.zero]) (mkConst ``Nat)
  let pairTy := mkApp2 (mkConst ``Prod [.zero, .zero]) (mkConst ``Nat) (mkConst ``Nat)
  let origTy := mkApp2 (mkConst ``Prod [.zero, .zero]) (mkConst ``Nat) (mkConst ``NumV)
  addTabDef (pre ++ `F) (mkConst ``Ffi) (mkConst w.ffiC)
  addTabDef (pre ++ `nonce) (mkConst ``String) (toExpr nonce) (compile := true)
  addTabDef (pre ++ `ks) natsTy (toExpr ([] : List Nat)) (compile := true)
  addTabDef (pre ++ `entries) (mkApp (mkConst ``List [.zero]) pairTy) (mkConst (base ++ `entries))
  addTabDef (pre ++ `orig) (mkApp (mkConst ``List [.zero]) origTy) (mkConst (base ++ `orig))
  for k in [`maps, `frozen, `frames, `ghosts] do
    addTabDef (pre ++ k) natsTy (mkConst (base ++ k)) (compile := true)
  IO.FS.writeFile (dir / pre.toString / "template.json") (← IO.FS.readFile (dir / base.toString / "template.json"))
  logInfo m!"tpl_tab {pre}: entries {rs} set to 0; {bytes} bytes"

elab "tpl_tab " p:ident " from " b:ident " : " "[" rs:num,* "]" os:(tplOpts)? : command =>
  liftTermElabM <| withOptions (fun o => o.setBool `Elab.async false) do
    let os : TplOpts := tplOptsOf (os.map (·.raw))
    os.check [`world]
    let pre := (← getCurrNamespace) ++ p.getId
    let base := (← getCurrNamespace) ++ b.getId
    let some n := os.ident `world | throwError "tpl_tab: give a world"
    unsafe inWorld ``tabCmdW (← worldConst n) #[toExpr pre, toExpr base, toExpr (rs.getElems.toList.map (·.getNat))]

end Host.Ts.Sim.Template
