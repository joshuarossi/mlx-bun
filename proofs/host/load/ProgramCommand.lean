import host.load.ProgramValues
import host.load.Summary
namespace Host.Load.Program
open Lean Elab Command Meta Host.Mlx Host.Mlx.FfiEval

def headers (s : Ffi.St) (p : Code) (cert : List Nat) : Bool :=
  p.length == cert.length && (p.zip cert).all fun (n, i) => match s.nodes.get i with
    | some actual => n.dtype == actual.dtype &&
        actual.shape == n.shape.map (fun d => Ffi.Dim.lit (Int.ofNat d))
    | none => false

private def choose (s : Ffi.St) (ts : List Extract.Tensor) (N : Nums Int) : Except String (Code × List Nat) := do
  let mut seen : Std.HashSet Nat := {}
  let mut queue := ts.map Extract.Tensor.node
  while !queue.isEmpty do
    let i := queue.head!
    queue := queue.tail!
    if seen.contains i then continue
    let some n := s.nodes.get i | throw s!"missing parameter ancestor {i}"
    seen := seen.insert i
    queue := n.ins ++ queue
  let cert := seen.toList.mergeSort (· ≤ ·)
  let rank : Std.HashMap Nat Nat := (cert.zipIdx.map fun (n, i) => (n, i)).foldl (fun m (n,i) => m.insert n i) {}
  let mut p : Code := []
  for i in cert do
    let some n := s.nodes.get i | throw "missing ancestor"
    let some shape := n.shape.mapM Extract.dimNat | throw s!"symbolic parameter shape at {i}"
    let op ← match n.prim with
      | .load f k => pure (.load f k)
      | .data bs => match bs.mapM N.byte with
        | some bs => pure (.data bs)
        | none => throw s!"unresolved parameter data at {i}"
      | .binary name => if name == chars!"add" then pure .add else throw s!"parameter binary operation at {i}"
      | .transpose axes => pure (.transpose axes)
      | .contiguous => pure .contiguous
      | _ => throw s!"unsupported parameter operation at {i}"
    let some ins := n.ins.mapM (rank[·]?) | throw "missing ancestor rank"
    p := p ++ [⟨op, ins, shape, n.dtype⟩]
  pure (p, cert)

private def addDefinition (name : Lean.Name) (ty value : Lean.Expr) : TermElabM Unit :=
  addDecl (.defnDecl { name, levelParams := [], type := ty, value, hints := .regular 0, safety := .safe })

private def addProof (name : Lean.Name) (params : Array Lean.Expr) (ty value : Lean.Expr) : TermElabM Unit := do
  addDecl (.thmDecl { name, levelParams := [], type := ← mkForallFVars params ty, value := ← mkLambdaFVars params value })

private def trueType (value : Lean.Expr) : TermElabM Lean.Expr := mkEq value (mkConst ``Bool.true)

private def checkTrue (name : Lean.Name) (params : Array Lean.Expr) (value : Lean.Expr) : TermElabM Unit := do
  addProof name params (← trueType value) (← mkEqRefl value)

private def namedList (pre : Lean.Name) (ty : Lean.Expr) (values : List Lean.Expr) : TermElabM (Array Lean.Expr) := do
  let values := values.toArray
  let listTy := mkApp (mkConst ``List [.zero]) ty
  let mut tails := Array.replicate (values.size + 1) (mkConst ``Bool.true)
  for j in [0:values.size + 1] do
    let i := values.size - j
    let name := pre ++ Name.mkSimple s!"tail{i}"
    let value := if i == values.size then mkApp (mkConst ``List.nil [.zero]) ty
      else mkApp3 (mkConst ``List.cons [.zero]) ty values[i]! tails[i+1]!
    addDefinition name listTy value
    tails := tails.set! i (mkConst name)
  pure tails

/-- Each obligation gets its own kernel check and cache. The structural
composition never reduces the whole finite census in one conversion. -/
private def checkAll (pre : Lean.Name) (params : Array Lean.Expr) (f : Lean.Expr)
    (values : List Lean.Expr) (tails : Array Lean.Expr) : TermElabM Lean.Expr := do
  let values := values.toArray
  let mut next := mkConst ``Bool.true
  for j in [0:values.size + 1] do
    let i := values.size - j
    let name := pre ++ Name.mkSimple s!"all{i}"
    let value ← mkAppM ``allAt #[f, mkRawNatLit i, tails[i]!]
    if i == values.size then
      checkTrue name params value
    else
      let headName := pre ++ Name.mkSimple s!"head{i}"
      checkTrue headName params (mkApp2 f (mkRawNatLit i) values[i]!)
      let proof ← mkAppM ``allAt_cons #[f, mkRawNatLit i, values[i]!, tails[i+1]!, mkAppN (mkConst headName) params, next]
      addProof name params (← trueType value) proof
    next := mkAppN (mkConst name) params
  pure next

/-- Choose the complete parameter ancestor program. Every node, edge, header,
and loaded parameter carrier is checked in the kernel. Matching holds for
all concrete number-server tables and all kernel source tables. -/
elab "load_program " name:ident " : " state:term ", " tensors:term ", " valuation:term : command =>
  liftTermElabM <| withOptions (fun o => o.setBool `Elab.async false) do
  let pre := (← getCurrNamespace) ++ name.getId
  let stTy := mkConst ``Ffi.St
  let tensorTy := mkConst ``Extract.Tensor
  let listTy := mkApp (mkConst ``List [.zero]) tensorTy
  let nuTy ← mkArrow (mkConst ``Host.Ts.NumV) (mkApp (mkConst ``Option [.zero]) (mkConst ``Host.Ts.F64))
  let sE ← instantiateMVars (← Term.elabTermAndSynthesize state (some stTy))
  let tsE ← instantiateMVars (← Term.elabTermAndSynthesize tensors (some listTy))
  let nuE ← instantiateMVars (← Term.elabTermAndSynthesize valuation (some nuTy))
  let s ← unsafe evalExpr Ffi.St stTy sE
  let ts ← unsafe evalExpr (List Extract.Tensor) listTy tsE
  let nu ← unsafe evalExpr (Host.Ts.NumV → Option Host.Ts.F64) nuTy nuE
  let (p, cert) ← match choose s ts (concrete nu) with
    | .ok result => pure result
    | .error e => throwError "load_program: {e}"
  let nodeTy := mkConst ``Node
  let codeTy := mkApp (mkConst ``List [.zero]) nodeTy
  let natList := mkApp (mkConst ``List [.zero]) (mkConst ``Nat)
  let mut nodes := []
  for (n,i) in p.zipIdx do
    let nm := pre ++ Name.mkSimple s!"node{i}"
    addDefinition nm nodeTy (toExpr n)
    nodes := nodes ++ [mkConst nm]
  let tails ← namedList (pre ++ `nodes) nodeTy nodes
  addDefinition pre codeTy tails[0]!
  addDefinition (pre ++ `cert) natList (toExpr cert)
  let pE := mkConst pre
  let cE := mkConst (pre ++ `cert)
  let validF := mkApp (mkConst ``validAt) pE
  let validProof ← checkAll (pre ++ `validChecks) #[] validF nodes tails
  addProof (pre ++ `valid) #[] (mkApp (mkConst ``Valid) pE) validProof
  checkTrue (pre ++ `headers) #[] (mkApp3 (mkConst ``headers) sE pE cE)
  let mut tensorExprs := []
  for (t,i) in ts.zipIdx do
    let nm := pre ++ Name.mkSimple s!"tensor{i}"
    addDefinition nm tensorTy (toExpr t)
    tensorExprs := tensorExprs ++ [mkConst nm]
  let tensorTails ← namedList (pre ++ `tensors) tensorTy tensorExprs
  let tsC := tensorTails[0]!
  let tsEqName := pre ++ `tensorsMatch
  addProof tsEqName #[] (← mkEq tsE tsC) (← mkEqRefl tsE)
  let coverF ← withLocalDeclD `i (mkConst ``Nat) fun i => withLocalDeclD `tensor tensorTy fun t =>
    mkLambdaFVars #[i,t] (mkApp3 (mkConst ``covered) pE cE t)
  let coveredAll ← checkAll (pre ++ `coverChecks) #[] coverF tensorExprs tensorTails
  let coverProof ← mkAppM ``covers_of_allAt #[pE, cE, tsC, coveredAll]
  let finalCover ← mkAppM ``covers_congr #[pE, cE, tsE, tsC, mkConst tsEqName, coverProof]
  addProof (pre ++ `covers) #[] (← trueType (mkApp3 (mkConst ``covers) pE cE tsE)) finalCover
  let kernelTy := mkConst ``KernelSources
  let tableTy := mkApp (mkConst ``List [.zero]) (mkConst ``Host.Ts.F64)
  withLocalDeclD `table tableTy fun table => withLocalDeclD `sources kernelTy fun sources => do
    let allNu := mkApp (mkConst ``Host.Ts.CSrv.val) (mkApp (mkConst ``Host.Ts.CSrv.mk) table)
    let gE := mkAppN (mkConst ``ffiGraph) #[mkConst ``Int, mkConst ``InKey, mkApp (mkConst ``concrete) allNu, sources, sE]
    let matchF ← withLocalDeclD `i (mkConst ``Nat) fun i => withLocalDeclD `node nodeTy fun n => do
      let body ← mkAppM ``nodeOk #[gE, cE, i, mkApp (mkConst ``Node.erase) n]
      mkLambdaFVars #[i,n] body
    let matchedAll ← checkAll (pre ++ `matchChecks) #[table,sources] matchF nodes tails
    let proof ← mkAppM ``matches_of_allAt #[pE, gE, cE, matchedAll]
    addProof (pre ++ `matches) #[table,sources] (← inferType proof) proof
  logInfo m!"load_program {pre}: {p.length} nodes and {ts.length} parameter references"

end Host.Load.Program
