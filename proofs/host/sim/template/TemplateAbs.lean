import host.sim.template.Build
set_option Elab.async false
namespace Host.Ts.Sim.Template
open Lean Elab Command Meta Host.Ts Host.Ts.Sim Host.Load Host.Ts.Stream

/-! # A template with more of its numbers abstracted

`tpl_abstract X from T : "spec.json" (world := w)` is the template `T` with the listed number sites of its nodes as references
to fresh table entries, one per variable of the spec. The rest of `T` is unchanged. A node's number sites are its shape's dims, then
its primitive's numbers, numbered in that order (`mapNode`). Its `ghostCells` are reset and framed as ghosts. The spec's `sites` are `{node, site, var, value}`, `value` the literal
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
  /-- Cells and maps no later step of a chain from this template reads: reset to `undefined` or empty, what only they held collected. -/
  ghostCells : Option (Array Nat) := none
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
  -- a template over a native-bridge world is decoded through its bridge-free view (`bridge_empty`)
  let hasView := (← getEnv).contains (base ++ `chooser)
  let (s, c, _) ← restoreAny (S := F.S) (mkConst (base ++ (if hasView then `chooser else `s0)))
    (mkConst (base ++ (if hasView then `chooserSrv else `S0))) pre
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
  let ghostCells := (spec.ghostCells.getD #[]).toList
  let mut heap0 := l.heap
  for a in ghostCells do
    match l.heap.get a with
    | some (.cell _) => heap0 := heap0.set a (.cell (some .undef))
    | some (.obj o) => match o.kind with
      | .map _ => heap0 := heap0.set a (.obj { o with kind := .map [] })
      | _ => throwError "tpl_abstract: ghost {a} is not a cell or a map"
    | _ => throwError "tpl_abstract: ghost {a} is not a cell or a map"
  let l1 : St LSt := { l with heap := heap0 }
  let l1 := l1.setFfi { l1.aux.ffi with mlx := { m with nodes } }
  let s1 := w.unproj s l1
  -- what the reset cells alone held goes, as in the template's own collection
  let (T0, dropped) : (St F.S × Nat) ← if ghostCells.isEmpty then pure (s1, (0 : Nat)) else do
    let m1 := l1.aux.ffi.mlx
    let roots := ((List.range 40).filter fun a => (l1.heap.get a).isSome) ++ nativeHeapRefs m1
    let ctx : Ctx := { s1 := l1, s2 := l1, t1 := c.tab.toArray, t2 := c.tab.toArray, env := ← getEnv, traceNodes := traceNodesOf m1 }
    let ((), wk) ← ((do
        for k in w.extraNodes s1.aux.ffi do pairNode k k (.root "extra") ""
        walkRoots (roots.map fun a => (a, a))).run ctx).run {}
    unless wk.mism.isEmpty do throwError "tpl_abstract: the identity walk found {wk.mism.size} mismatches"
    let heap := ptrieFold (fun (acc : PTrie Host.Ts.HObj) a o => if wk.sig.contains a then acc.set a o else acc) l1.heap PTrie.nil
    let before := ptrieFold (fun (k : Nat) _ _ => k + 1) l1.heap 0
    let after := ptrieFold (fun (k : Nat) _ _ => k + 1) heap 0
    let l2 : St LSt := { l1 with heap }
    pure (w.unproj s1 l2 |>.setFfi (w.restrict s1.aux.ffi wk.hnd.contains wk.nod.contains), before - after)
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
  for k in [`maps, `frozen] do
    addAbsDef (pre ++ k) natsTy (mkConst (base ++ k)) (compile := true)
  if ghostCells.isEmpty then
    for k in [`frames, `ghosts] do
      addAbsDef (pre ++ k) natsTy (mkConst (base ++ k)) (compile := true)
  else
    let baseFrames ← evalConst (List Nat) (base ++ `frames)
    addAbsDef (pre ++ `frames) natsTy (toExpr (baseFrames ++ ghostCells)) (compile := true)
    addAbsDef (pre ++ `ghosts) natsTy (toExpr ghostCells) (compile := true)
  -- `template.json`: the base's, with the fresh entries and the table's new length
  let baseJ ← IO.FS.readFile (dir / base.toString / "template.json")
  let j ← match Json.parse baseJ with | .ok j => pure j | .error e => throwError "tpl_abstract: {e}"
  let ents := match j.getObjVal? "entries" with | .ok (.arr es) => es | _ => #[]
  let more := fresh.toArray.map fun (r, v) => Json.mkObj [("name", toJson s!"abstract v{v.var}"), ("ref", toJson r),
    ("var", toJson v.var), ("orig", toJson (toString v.value))]
  let start := (j.getObjValD "start").setObjVal! "n" (toJson tab.length)
  let j := (j.setObjVal! "entries" (Json.arr (ents ++ more))).setObjVal! "start" start
  IO.FS.writeFile (dir / pre.toString / "template.json") (j.pretty ++ "\n")
  logInfo m!"tpl_abstract {pre}: {spec.sites.size} sites over {spec.vars.size} variables at {nodeIds.size} nodes; ghosts {ghostCells}, {dropped} heap entries dropped; table {n} -> {tab.length}; {bytes} bytes"

elab "tpl_abstract " p:ident " from " b:ident " : " path:str os:(tplOpts)? : command =>
  liftTermElabM <| withOptions (fun o => o.setBool `Elab.async false) do
    let os : TplOpts := tplOptsOf (os.map (·.raw))
    os.check [`world]
    let pre := (← getCurrNamespace) ++ p.getId
    let base := (← getCurrNamespace) ++ b.getId
    let some n := os.ident `world | throwError "tpl_abstract: give a world"
    unsafe inWorld ``abstractCmdW (← worldConst n) #[toExpr pre, toExpr base, toExpr path.getString]

end Host.Ts.Sim.Template
