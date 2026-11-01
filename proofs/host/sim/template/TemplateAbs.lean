import host.sim.template.Build
set_option Elab.async false
namespace Host.Ts.Sim.Template
open Lean Elab Command Meta Host.Ts Host.Ts.Sim Host.Load Host.Ts.Stream

/-! # A template with more of its numbers abstracted

`tpl_abstract X from T : "spec.json" (world := w)` is the template `T` with the listed number sites of its nodes as references
to fresh table entries, one per variable of the spec. The rest of `T` is unchanged. A node's number sites are its shape's dims, then
its primitive's numbers, numbered in that order (`mapNode`). The spec's `sites` are `{node, site, var, value}`, `value` the literal
the site must hold, and its `vars` the variables, in table order. `DecodeAbs`'s template is the decode template with the dims of the
prompt's end at its row count abstracted. -/

inductive Site where
  | dim (x : Host.Mlx.Ffi.Dim)
  | num (x : NumV)

abbrev SiteM := StateM (Nat × Array Site)

def visitDim (f : Nat → Option Nat) (d : Host.Mlx.Ffi.Dim) : SiteM Host.Mlx.Ffi.Dim := do
  let (k, a) ← get
  set (k + 1, a.push (.dim d))
  pure (match f k with | some r => .sym (.ref r) | none => d)

def visitNum (f : Nat → Option Nat) (x : NumV) : SiteM NumV := do
  let (k, a) ← get
  set (k + 1, a.push (.num x))
  pure (match f k with | some r => .ref r | none => x)

def mapCfg (f : Nat → Option Nat) (c : Host.Mlx.Ffi.Cfg) : SiteM Host.Mlx.Ffi.Cfg := do
  let outs ← c.outs.mapM fun (ds, t) => do pure (← ds.mapM (visitDim f), t)
  let grid ← c.grid.mapM (visitNum f)
  let group ← c.group.mapM (visitNum f)
  let ints ← c.ints.mapM fun (k, x) => do pure (k, ← visitNum f x)
  let init ← c.init.mapM (visitNum f)
  pure { c with outs, grid, group, ints, init }

def mapPrim (f : Nat → Option Nat) : Host.Mlx.Ffi.Prim → SiteM Host.Mlx.Ffi.Prim
  | .arange a b c => do pure (.arange (← visitNum f a) (← visitNum f b) (← visitNum f c))
  | .reshape s => do pure (.reshape (← s.mapM (visitDim f)))
  | .slice a b c => do pure (.slice (← a.mapM (visitDim f)) (← b.mapM (visitDim f)) (← c.mapM (visitDim f)))
  | .sliceUpdate a b c => do pure (.sliceUpdate (← a.mapM (visitDim f)) (← b.mapM (visitDim f)) (← c.mapM (visitDim f)))
  | .sliceDynamic x s => do pure (.sliceDynamic x (← s.mapM (visitDim f)))
  | .rmsNorm e => do pure (.rmsNorm (← visitNum f e))
  | .rope d t b s o => do pure (.rope d t b (← visitNum f s) (← visitNum f o))
  | .sdpa s m => do pure (.sdpa (← visitNum f s) m)
  | .kernel k c o => do pure (.kernel k (← mapCfg f c) o)
  | .replayed c p => do pure (.replayed c (← mapPrim f p))
  | p => pure p

def mapNode (f : Nat → Option Nat) (nd : Host.Mlx.Ffi.Node) : SiteM Host.Mlx.Ffi.Node := do
  let shape ← nd.shape.mapM (visitDim f)
  let prim ← mapPrim f nd.prim
  pure { nd with shape, prim }

/-- A node's number sites, in order. -/
def nodeSites (nd : Host.Mlx.Ffi.Node) : Array Site :=
  ((mapNode (fun _ => none) nd).run (0, #[])).2.2

/-- A site's literal, if it holds one. -/
def siteLit : Site → Option F64
  | .dim (.lit i) => some (F64.ofInt i)
  | .dim (.sym (.lit x)) => some x
  | .num (.lit x) => some x
  | _ => none

/-- A site's table reference, if it holds one. -/
def siteRef : Site → Option Nat
  | .dim (.sym (.ref r)) => some r
  | .num (.ref r) => some r
  | _ => none

structure AbsSite where
  node : Nat
  site : Nat
  var : Nat
  value : Nat
deriving FromJson, ToJson

structure AbsVar where
  var : Nat
  value : Nat
deriving FromJson, ToJson

structure AbsSpec where
  sites : Array AbsSite
  vars : Array AbsVar
deriving FromJson, ToJson

private def addAbsDef (name : Lean.Name) (type value : Lean.Expr) (compile : Bool := false) : TermElabM Unit := do
  let d := Declaration.defnDecl { name, levelParams := [], type, value, hints := .abbrev, safety := .safe }
  addDecl d
  if compile then compileDecl d

/-- The body of `tpl_abstract`. -/
unsafe def abstractCmdW {F : Ffi} (w : TWorld F) (pre base : Lean.Name) (specPath : String) : TermElabM Unit := do
  astTabRef.set (← loadAstTab)
  Memo.reset
  let text ← IO.FS.readFile specPath
  let spec ← match Json.parse text >>= fromJson? (α := AbsSpec) with
    | .ok s => pure s
    | .error e => throwError "tpl_abstract: {e}"
  let (s, c, _) ← restoreAny (S := F.S) (mkConst (base ++ `s0)) (mkConst (base ++ `S0)) pre
  let l := w.proj s
  let m := l.aux.ffi.mlx
  let n := c.tab.length
  let refOf (v : Nat) : Option Nat := (spec.vars.findIdx? (·.var == v)).map (n + ·)
  let mut nodes := m.nodes
  let nodeIds := spec.sites.foldl (fun (acc : Array Nat) x => if acc.contains x.node then acc else acc.push x.node) #[]
  for id in nodeIds do
    let some nd := m.nodes.get id | throwError "tpl_abstract: no node {id}"
    let here := spec.sites.filter (·.node == id)
    let sites := nodeSites nd
    for x in here do
      let some st := sites[x.site]? | throwError "tpl_abstract: N{id} has no site {x.site}"
      unless siteLit st == some (F64.ofNat x.value) do
        throwError "tpl_abstract: N{id} site {x.site} does not hold {x.value}"
      unless (refOf x.var).isSome do throwError "tpl_abstract: site's variable {x.var} is not listed"
    let f (k : Nat) : Option Nat := (here.find? (·.site == k)).bind fun x => refOf x.var
    nodes := nodes.set id ((mapNode f nd).run (0, #[])).1
  let T0 := w.unproj s (l.setFfi { l.aux.ffi with mlx := { m with nodes } })
  let tab := c.tab ++ spec.vars.toList.map fun v => SymE.var v.var
  let nonce := s!"{pre}:{← IO.monoNanosNow}"
  let dir ← streamDir
  IO.FS.createDirAll (dir / pre.toString)
  let nilAns := mkApp (mkConst ``List.nil [.zero]) (mkConst ``Ans)
  let (_, bytes) ← writeBoundaryW w pre nonce dir { pre } 0 T0 tab nilAns none
  let natsTy := mkApp (mkConst ``List [.zero]) (mkConst ``Nat)
  let pairTy := mkApp2 (mkConst ``Prod [.zero, .zero]) (mkConst ``Nat) (mkConst ``Nat)
  let origTy := mkApp2 (mkConst ``Prod [.zero, .zero]) (mkConst ``Nat) (mkConst ``NumV)
  addAbsDef (pre ++ `F) (mkConst ``Ffi) (mkConst w.ffiC)
  addAbsDef (pre ++ `nonce) (mkConst ``String) (toExpr nonce) (compile := true)
  addAbsDef (pre ++ `ks) natsTy (toExpr ([] : List Nat)) (compile := true)
  let fresh := spec.vars.toList.zipIdx.map fun (v, i) => (n + i, v)
  addAbsDef (pre ++ `entries) (mkApp (mkConst ``List [.zero]) pairTy)
    (mkAppN (mkConst ``List.append [.zero]) #[pairTy, mkConst (base ++ `entries), toExpr (fresh.map fun (r, v) => (r, v.var))])
  addAbsDef (pre ++ `orig) (mkApp (mkConst ``List [.zero]) origTy)
    (mkAppN (mkConst ``List.append [.zero]) #[origTy, mkConst (base ++ `orig),
      toExpr (fresh.map fun (r, v) => (r, NumV.lit (F64.ofNat v.value)))])
  for k in [`frames, `ghosts, `maps, `frozen] do
    addAbsDef (pre ++ k) natsTy (mkConst (base ++ k)) (compile := true)
  -- `template.json`: the base's, with the fresh entries and the table's new length
  let baseJ ← IO.FS.readFile (dir / base.toString / "template.json")
  let j ← match Json.parse baseJ with | .ok j => pure j | .error e => throwError "tpl_abstract: {e}"
  let ents := match j.getObjVal? "entries" with | .ok (.arr es) => es | _ => #[]
  let more := fresh.toArray.map fun (r, v) => Json.mkObj [("name", toJson s!"abstract v{v.var}"), ("ref", toJson r),
    ("var", toJson v.var), ("orig", toJson (toString v.value))]
  let start := (j.getObjValD "start").setObjVal! "n" (toJson tab.length)
  let j := (j.setObjVal! "entries" (Json.arr (ents ++ more))).setObjVal! "start" start
  IO.FS.writeFile (dir / pre.toString / "template.json") (j.pretty ++ "\n")
  logInfo m!"tpl_abstract {pre}: {spec.sites.size} sites over {spec.vars.size} variables at {nodeIds.size} nodes; table {n} -> {tab.length}; {bytes} bytes"

elab "tpl_abstract " p:ident " from " b:ident " : " path:str os:(tplOpts)? : command =>
  liftTermElabM <| withOptions (fun o => o.setBool `Elab.async false) do
    let os : TplOpts := tplOptsOf (os.map (·.raw))
    os.check [`world]
    let pre := (← getCurrNamespace) ++ p.getId
    let base := (← getCurrNamespace) ++ b.getId
    let some n := os.ident `world | throwError "tpl_abstract: give a world"
    unsafe inWorld ``abstractCmdW (← worldConst n) #[toExpr pre, toExpr base, toExpr path.getString]

end Host.Ts.Sim.Template
