import host.sim.template.Build
import host.sim.template.TemplateAbs
set_option Elab.async false
namespace Host.Ts.Sim.Template
open Lean Elab Command Meta Host.Ts Host.Ts.Sim Host.Load Host.Ts.Stream

/-! # A template with number sites abstracted, one table entry each

`tpl_sites X from T : "spec.json" (world := w)` is the template `T` with the listed number sites of its nodes as references to fresh table entries,
one per site, each the site's variable. `tpl_abstract` gives a variable one entry; a class can hold a variable's sites as different entries of its
own table, and a map sends an entry to one number. The spec's `sites` are `{node, site, var, value}`, as `tpl_abstract`'s. -/

structure SitesSpec where
  sites : Array AbsSite
deriving FromJson, ToJson

private def addSitesDef (name : Lean.Name) (type value : Lean.Expr) (compile : Bool := false) : TermElabM Unit := do
  let d := Declaration.defnDecl { name, levelParams := [], type, value, hints := .abbrev, safety := .safe }
  addDecl d
  if compile then compileDecl d

/-- The body of `tpl_sites`. -/
unsafe def sitesCmdW {F : Ffi} (w : TWorld F) (pre base : Lean.Name) (specPath : String) : TermElabM Unit := do
  astTabRef.set (← loadAstTab)
  Memo.reset
  let text ← IO.FS.readFile specPath
  let spec ← match Json.parse text >>= fromJson? (α := SitesSpec) with
    | .ok s => pure s
    | .error e => throwError "tpl_sites: {e}"
  let hasView := (← getEnv).contains (base ++ `chooser)
  let (s, c, _) ← restoreAny (S := F.S) (mkConst (base ++ (if hasView then `chooser else `s0)))
    (mkConst (base ++ (if hasView then `chooserSrv else `S0))) pre
  let l := w.proj s
  let m := l.aux.ffi.mlx
  let n := c.tab.length
  let fresh := spec.sites.toList.zipIdx.map fun (x, i) => (n + i, x)
  let mut nodes := m.nodes
  let nodeIds := spec.sites.foldl (fun (acc : Array Nat) x => if acc.contains x.node then acc else acc.push x.node) #[]
  for id in nodeIds do
    let some nd := m.nodes.get id | throwError "tpl_sites: no node {id}"
    let here := fresh.filter (·.2.node == id)
    let sites := nodeSites nd
    for (_, x) in here do
      let some st := sites[x.site]? | throwError "tpl_sites: N{id} has no site {x.site}"
      unless siteLit st == some (F64.ofNat x.value) do
        throwError "tpl_sites: N{id} site {x.site} does not hold {x.value}"
    let f (k : Nat) : Option Nat := (here.find? (·.2.site == k)).map (·.1)
    nodes := nodes.set id ((mapNode f nd).run (0, #[])).1
  let l1 : St LSt := l.setFfi { l.aux.ffi with mlx := { m with nodes } }
  let T0 := w.unproj s l1
  let tab := c.tab ++ spec.sites.toList.map fun x => SymE.var x.var
  let nonce := s!"{pre}:{← IO.monoNanosNow}"
  let dir ← streamDir
  IO.FS.createDirAll (dir / pre.toString)
  let nilAns := mkApp (mkConst ``List.nil [.zero]) (mkConst ``Ans)
  let (_, bytes) ← writeBoundaryW w pre nonce dir { pre } 0 T0 tab nilAns none
  let natsTy := mkApp (mkConst ``List [.zero]) (mkConst ``Nat)
  let pairTy := mkApp2 (mkConst ``Prod [.zero, .zero]) (mkConst ``Nat) (mkConst ``Nat)
  let origTy := mkApp2 (mkConst ``Prod [.zero, .zero]) (mkConst ``Nat) (mkConst ``NumV)
  addSitesDef (pre ++ `F) (mkConst ``Ffi) (mkConst w.ffiC)
  addSitesDef (pre ++ `nonce) (mkConst ``String) (toExpr nonce) (compile := true)
  addSitesDef (pre ++ `ks) natsTy (toExpr ([] : List Nat)) (compile := true)
  addSitesDef (pre ++ `entries) (mkApp (mkConst ``List [.zero]) pairTy)
    (mkAppN (mkConst ``List.append [.zero]) #[pairTy, mkConst (base ++ `entries), toExpr (fresh.map fun (r, x) => (r, x.var))])
  addSitesDef (pre ++ `orig) (mkApp (mkConst ``List [.zero]) origTy)
    (mkAppN (mkConst ``List.append [.zero]) #[origTy, mkConst (base ++ `orig),
      toExpr (fresh.map fun (r, x) => (r, NumV.lit (F64.ofNat x.value)))])
  for k in [`maps, `frozen, `frames, `ghosts] do
    addSitesDef (pre ++ k) natsTy (mkConst (base ++ k)) (compile := true)
  let baseJ ← IO.FS.readFile (dir / base.toString / "template.json")
  let j ← match Json.parse baseJ with | .ok j => pure j | .error e => throwError "tpl_sites: {e}"
  let ents := match j.getObjVal? "entries" with | .ok (.arr es) => es | _ => #[]
  let more := fresh.toArray.map fun (r, x) => Json.mkObj [("name", toJson s!"site v{x.var}"), ("ref", toJson r),
    ("var", toJson x.var), ("orig", toJson (toString x.value))]
  let start := (j.getObjValD "start").setObjVal! "n" (toJson tab.length)
  let j := (j.setObjVal! "entries" (Json.arr (ents ++ more))).setObjVal! "start" start
  IO.FS.writeFile (dir / pre.toString / "template.json") (j.pretty ++ "\n")
  logInfo m!"tpl_sites {pre}: {spec.sites.size} sites at {nodeIds.size} nodes; table {n} -> {tab.length}; {bytes} bytes"

elab "tpl_sites " p:ident " from " b:ident " : " sp:str os:(tplOpts)? : command =>
  liftTermElabM <| withOptions (fun o => o.setBool `Elab.async false) do
    let os : TplOpts := tplOptsOf (os.map (·.raw))
    os.check [`world]
    let pre := (← getCurrNamespace) ++ p.getId
    let base := (← getCurrNamespace) ++ b.getId
    let some wc := os.ident `world | throwError "tpl_sites: give a world"
    unsafe inWorld ``sitesCmdW (← worldConst wc) #[toExpr pre, toExpr base, toExpr sp.getString]

end Host.Ts.Sim.Template
