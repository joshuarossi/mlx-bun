import host.load.Stream
import host.load.Segment
import host.ts.DecodeExpr
import host.load.Native

namespace Host.Load
open Lean Elab Command Meta Host.Ts Host.Ts.Stream

private def boundaryName (pre : Lean.Name) (tag : String) (i : Nat) : Lean.Name :=
  pre ++ Name.mkSimple s!"{tag}{i}"

private def addDefinition (name : Lean.Name) (type value : Lean.Expr) : TermElabM Unit :=
  addDecl (.defnDecl { name, levelParams := [], type, value, hints := .regular 0, safety := .safe })

private def addProof (name : Lean.Name) (type value : Lean.Expr) : TermElabM Unit :=
  addDecl (.thmDecl { name, levelParams := [], type, value })

private def controlLabel (s : St LSt) : String := Id.run do
  let object (v : Val) := match v with
    | .obj a => match s.obj? a with
      | some o => match o.kind with
        | .map xs => s!"object{a}(map {xs.length},props {o.props.length})"
        | .array xs => s!"object{a}(array {xs.length},props {o.props.length})"
        | _ => s!"object{a}(props {o.props.length})"
      | none => s!"object{a}(missing)"
    | .str xs => s!"string({xs.length})"
    | _ => "scalar"
  match s.ctl with
  | .call f this args =>
    let code := match f with
      | .obj a => match s.obj? a with
        | some o => match o.kind with
          | .fn (.native n _) => s!"native {toExpr n}"
          | .fn (.closure _ _ _ _) => "closure"
          | _ => "other"
        | none => "missing"
      | _ => "nonobject"
    return s!"call {code}, receiver {object this}, args {args.map object}"
  | .ev e _ => return s!"eval {(toExpr e).getAppFn}"
  | .ex st _ => return s!"exec {(toExpr st).getAppFn}"
  | .ret _ =>
    let frame := match s.stack.head? with
      | some (.k f) => s!"function {(toExpr f).getAppFn}"
      | some f => s!"{(toExpr f).getAppFn}"
      | none => "none"
    return s!"return, frame {frame}"
  | _ => return s!"{(toExpr s.ctl).getAppFn}"

private unsafe def restore (state server : Lean.Expr) (pre : Lean.Name) :
    TermElabM (St LSt × SSrv × G × Nat × Nat) := do
  let (sNative, decoded) ← (ConstructorDecode.decode state).run {}
  let (cNative, decoded) ← (ConstructorDecode.decode server).run decoded
  let mut g : G := { pre }
  let aliasNames : Std.HashSet Lean.Name := decoded.aliases.foldl (fun names alias => names.insert alias.1) {}
  let env ← getEnv
  for (name, type, value) in decoded.aliases do
    let bodyConstants := match env.find? name with
      | some (.defnInfo d) => d.value.getUsedConstants
      | _ => #[]
    let deps := (type.getUsedConstants ++ bodyConstants).filter aliasNames.contains
    g := { g with memo := g.memo.insert (ptrAddrUnsafe value, type) (name, value), deps := g.deps.insert name deps }
  -- The expression-value table is local to this call, so it cannot remain
  -- live while the caller checks reductions. Named objects survive in G.
  return (unsafeCast sNative, unsafeCast cNative, g, decoded.values.size, decoded.aliases.size)

/-- Restore a native value only to choose smaller boundaries. Every chosen
boundary is subsequently used in an ordinary kernel reduction, including the
last boundary's equality to the original outer chunk endpoint. -/
private unsafe def microChunk (pre : Lean.Name) (i width : Nat) (refine : Option (Nat × Nat × Nat))
    (checked : Bool) : TermElabM Unit := do
  if width == 0 then throwError "host_micro_chunk: width must be positive"
  if let some (start, stop, fine) := refine then
    unless start < stop && fine > 0 do throwError "host_micro_chunk: invalid refinement interval"
  let ks ← evalConst (List Nat) (pre ++ `ks)
  let some fuel := ks[i]? | throwError "host_micro_chunk: no outer chunk {i}"
  let F := mkConst (pre ++ `F)
  unless ← isDefEq F (mkConst ``Host.Load.ffi) do
    throwError "host_micro_chunk: expected the actual load FFI"
  let sTy := mkApp (mkConst ``St) (mkConst ``LSt)
  let srvTy := mkConst ``SSrv
  let pairTy := mkApp2 (mkConst ``Prod [.zero, .zero]) sTy srvTy
  let startS := mkConst (boundaryName pre "s" i)
  let startC := mkConst (boundaryName pre "S" i)
  let endS := mkConst (boundaryName pre "s" (i+1))
  let endC := mkConst (boundaryName pre "S" (i+1))
  let run (k : Nat) (s c : Lean.Expr) := mkAppN (mkConst ``runS) #[F, mkRawNatLit k, s, c]
  let result (s c : Lean.Expr) := mkApp2 (mkConst ``Option.some [.zero]) pairTy
    (mkApp4 (mkConst ``Prod.mk [.zero, .zero]) sTy srvTy s c)
  let started ← IO.monoMsNow
  let traceFile ← IO.getEnv "HOST_MICRO_TRACE"
  let trace (message : String) : IO Unit := match traceFile with
    | none => pure ()
    | some path => IO.FS.withFile path .append fun handle => handle.putStrLn message
  astTabRef.set (← loadAstTab)
  Memo.reset
  let microPre := pre ++ Name.mkSimple s!"micro{i}"
  addDefinition (microPre ++ `F) (mkConst ``Ffi) F
  addDefinition (boundaryName microPre "s" 0) sTy startS
  addDefinition (boundaryName microPre "S" 0) srvTy startC
  let (initialS, initialC, initialG, valueCount, aliasCount) ← restore startS startC microPre
  let mut s := initialS
  let mut c := initialC
  let mut g := initialG
  let mut peakAliases := g.memo.size
  let restored ← IO.monoMsNow
  trace s!"micro {i}: restored {valueCount} values, {aliasCount} aliases in {restored-started} ms"
  -- The alias memo keeps restored objects alive while their named data is
  -- reachable. Expression decoding caches are no longer needed here.
  let mut previousS := mkConst (boundaryName microPre "s" 0)
  let mut previousC := mkConst (boundaryName microPre "S" 0)
  let mut consumed := 0
  let mut index := 0
  let mut composed : Option Lean.Expr := none
  let mut sizes : List Nat := []
  while consumed < fuel do
    let chosenWidth := match refine with
      | some (start, stop, fine) =>
        if consumed < start then min width (start-consumed)
        else if consumed < stop then min fine (stop-consumed)
        else width
      | none => width
    let k := min chosenWidth (fuel-consumed)
    if k == 1 then trace s!"micro {i}.{index} at {consumed}: {controlLabel s}"
    let some (nextS, nextC) := runFast Host.Load.ffi k s c
      | throwError "host_micro_chunk: native choice stuck after {consumed} steps of chunk {i}"
    s := nextS
    c := nextC
    if k == 1 then trace s!"micro {i}.{index} next: {controlLabel s}"
    let last := consumed+k == fuel
    let (chosenS, chosenC) ← if last then do
      let sn := boundaryName microPre "s" (index+1)
      let cn := boundaryName microPre "S" (index+1)
      addDefinition sn sTy endS
      addDefinition cn srvTy endC
      pure (mkConst sn, mkConst cn)
    else do
      Memo.beginEpoch
      let (state, nextG) ← (stE StreamExpr.ser (mkConst ``LSt) s).run
        { g with idx := index+1, count := 0, defs := #[] }
      g := nextG
      for (name, type, value) in g.defs do addDefinition name type value
      let sn := boundaryName microPre "s" (index+1)
      let cn := boundaryName microPre "S" (index+1)
      addDefinition sn sTy state
      let server := toExpr c
      addDefinition cn srvTy server
      trace s!"micro {i}.{index}: {g.defs.size} definitions serialized"
      g := sweep { g with defs := #[] } #[state, server]
      peakAliases := max peakAliases g.memo.size
      if index % 100 == 0 then
        trace s!"micro {i}.{index}: {g.memo.size} live native aliases, {g.deps.size} dependency entries"
      pure (mkConst sn, mkConst cn)
    if checked then
      let lhs := run k previousS previousC
      let ty ← mkEq lhs (result chosenS chosenC)
      let name := boundaryName microPre "c" index
      addProof name ty (← mkEqRefl lhs)
      trace s!"micro {i}.{index}: {k} steps checked"
      let nextProof := mkConst name
      let prefixProof := match composed with
        | none => nextProof
        | some proof => mkAppN (mkConst ``runS_trans) #[F, mkRawNatLit consumed, mkRawNatLit k,
            startS, previousS, chosenS, startC, previousC, chosenC, proof, nextProof]
      let prefixName := boundaryName microPre "up" (index+1)
      addProof prefixName (← mkEq (run (consumed+k) startS startC) (result chosenS chosenC)) prefixProof
      composed := some (mkConst prefixName)
    sizes := k :: sizes
    consumed := consumed+k
    index := index+1
    previousS := chosenS
    previousC := chosenC
  let ksDecl := Declaration.defnDecl { name := microPre ++ `ks, levelParams := [], type := mkApp (mkConst ``List [.zero]) (mkConst ``Nat), value := toExpr sizes.reverse, hints := .abbrev, safety := .safe }
  addDecl ksDecl
  compileDecl ksDecl
  if checked then
    let lhs := run fuel startS startC
    let proof ← match composed with
      | some proof => pure proof
      | none => mkEqRefl lhs
    addProof (boundaryName pre "c" i) (← mkEq lhs (result endS endC)) proof
  Memo.reset
  logInfo m!"host_micro {pre} {i}: {fuel} steps, {index} segments, checked={checked}; restore {restored-started} ms, total {(← IO.monoMsNow)-started} ms; {g.memo.size} live native aliases, peak {peakAliases}"

/-- Subdivide one outer source-execution chunk without changing its statement
or any outer boundary. Native restoration chooses data; `Eq.refl` proves each
small transition, and `runS_trans` composes the original chunk theorem. -/
elab "host_micro_chunk " p:ident i:num ", " width:num
    fine:((" refine " num ", " num ", " num)?) : command =>
  liftTermElabM <| withOptions (fun o => o.setBool `Elab.async false) do
    let refine := match fine.raw.getArgs.toList with
      | [_, a, _, b, _, c] => do pure (← a.isNatLit?, ← b.isNatLit?, ← c.isNatLit?)
      | _ => none
    unsafe microChunk ((← getCurrNamespace) ++ p.getId) i.getNat width.getNat refine true

/-- Choose a subdivided chain for the existing read-tail and prefix-frame
commands. `P.micro<i>` exports `F`, `ks`, `s0…sN`, and `S0…SN`; its endpoints
are aliases of the original outer boundaries. This command proves no run. -/
elab "host_micro_states " p:ident i:num ", " width:num : command =>
  liftTermElabM <| withOptions (fun o => o.setBool `Elab.async false) do
    unsafe microChunk ((← getCurrNamespace) ++ p.getId) i.getNat width.getNat none false

/-- Compose checked (possibly framed) microchunk theorems into the original
outer chunk statement. This command performs no native state restoration. -/
elab "host_micro_run " p:ident i:num : command =>
  liftTermElabM <| withOptions (fun o => o.setBool `Elab.async false) do
    let pre := (← getCurrNamespace) ++ p.getId
    let i := i.getNat
    let micro := pre ++ Name.mkSimple s!"micro{i}"
    let ks ← unsafe evalConst (List Nat) (micro ++ `ks)
    let outerKs ← unsafe evalConst (List Nat) (pre ++ `ks)
    let some fuel := outerKs[i]? | throwError "host_micro_run: no outer chunk {i}"
    unless ks.foldl (·+·) 0 == fuel do throwError "host_micro_run: micro sizes do not sum to outer fuel"
    let F := mkConst (pre ++ `F)
    let sTy := mkApp (mkConst ``St) (mkConst ``LSt)
    let srvTy := mkConst ``SSrv
    let pairTy := mkApp2 (mkConst ``Prod [.zero, .zero]) sTy srvTy
    let run (fuel : Nat) := mkAppN (mkConst ``runS) #[F, mkRawNatLit fuel,
      mkConst (boundaryName pre "s" i), mkConst (boundaryName pre "S" i)]
    let result (j : Nat) := mkApp2 (mkConst ``Option.some [.zero]) pairTy
      (mkApp4 (mkConst ``Prod.mk [.zero, .zero]) sTy srvTy
        (mkConst (boundaryName micro "s" j)) (mkConst (boundaryName micro "S" j)))
    let mut total := 0
    let mut proof : Option Lean.Expr := none
    for (k,j) in ks.zipIdx do
      let next := mkConst (boundaryName micro "c" j)
      let prefixProof := match proof with
        | none => next
        | some previous => mkAppN (mkConst ``runS_trans) #[F, mkRawNatLit total, mkRawNatLit k,
            mkConst (boundaryName micro "s" 0), mkConst (boundaryName micro "s" j),
            mkConst (boundaryName micro "s" (j+1)), mkConst (boundaryName micro "S" 0),
            mkConst (boundaryName micro "S" j), mkConst (boundaryName micro "S" (j+1)), previous, next]
      total := total+k
      let prefixName := boundaryName micro "up" (j+1)
      addProof prefixName (← mkEq (run total) (result (j+1))) prefixProof
      proof := some (mkConst prefixName)
    let lhs := mkAppN (mkConst ``runS) #[F, mkRawNatLit fuel,
      mkConst (boundaryName pre "s" i), mkConst (boundaryName pre "S" i)]
    let rhs := mkApp2 (mkConst ``Option.some [.zero]) pairTy
      (mkApp4 (mkConst ``Prod.mk [.zero, .zero]) sTy srvTy
        (mkConst (boundaryName pre "s" (i+1))) (mkConst (boundaryName pre "S" (i+1))))
    let finalProof ← match proof with | some doneProof => pure doneProof | none => mkEqRefl lhs
    addProof (boundaryName pre "c" i) (← mkEq lhs rhs) finalProof

end Host.Load
