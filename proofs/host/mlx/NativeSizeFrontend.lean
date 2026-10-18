import host.mlx.NativeSizeRetained
import host.ts.RenameRuntimeSourceCut
import host.ts.RenameRouteDriver

set_option Elab.async false

namespace Host.Ts.Owned.Annotated.Driver
open Lean Elab Command Meta
open Parametric.Driver

/-- Source-selected array size uses the selected current closed literal shape. -/
elab "host_retained_size " f:term ", " s:term " using " initial:term " to " t:term " using " next:term " as " name:ident : command => do
  let pre := (← getCurrNamespace) ++ name.getId
  liftTermElabM do
    let f ← Term.elabTermEnsuringType f (mkConst ``Ffi)
    unless ← isDefEq f (mkConst ``Host.Load.ffi) do throwError "host_retained_size: expected original load FFI"
    let stateTy := mkApp (mkConst ``St) (mkApp (mkConst ``Ffi.S) f)
    let s ← Term.elabTermEnsuringType s stateTy
    let t ← Term.elabTermEnsuringType t stateTy
    let ctl ← whnf (← mkAppM ``St.ctl #[s])
    unless ctl.isAppOfArity ``Ctl.call 3 do throwError "host_retained_size: expected source call"
    let address ← field ctl.getAppArgs[0]! ``Val.obj 1 0
    let values := ctl.getAppArgs[2]!
    let handle ← mkAppM ``Int.toNat #[← field (← field values ``List.cons 3 1) ``Val.big 1 0]
    unless (← whnf (← field values ``List.cons 3 2)).isAppOfArity ``List.nil 1 do
      throwError "host_retained_size: expected exactly one argument"
    let object ← field (← mkAppM ``St.obj? #[s,address]) ``Option.some 2 1
    let code ← whnf (← field (← mkAppM ``Obj.kind #[object]) ``Kind.fn 1 0)
    let native ← whnf (← field code ``Code.native 2 0)
    let builtin ← field native ``Native.ffi 1 0
    unless (← whnf builtin).isConstOf ``FfiN.symbol do throwError "host_retained_size: expected native FFI symbol"
    let caps := code.getAppArgs[1]!
    let symbol ← field (← field caps ``List.cons 3 1) ``Val.str 1 0
    unless ← isDefEq symbol (toExpr chars!"mlx_array_size") do
      throwError "host_retained_size: expected mlx_array_size"
    let rest ← field caps ``List.cons 3 2
    let types ← field (← field rest ``List.cons 3 1) ``Val.obj 1 0
    let rest ← field rest ``List.cons 3 2
    let returns ← field (← field rest ``List.cons 3 1) ``Val.str 1 0
    unless (← whnf (← field rest ``List.cons 3 2)).isAppOfArity ``List.nil 1 do
      throwError "host_retained_size: expected three symbol captures"
    let signatureObject ← field (← mkAppM ``St.obj? #[s,types]) ``Option.some 2 1
    let world ← mkAppM ``St.ffi #[s]
    let mlx ← mkAppM ``Host.Load.LSt.mlx #[world]
    let producer ← field (← mkAppM ``Host.Ts.PTrie.get #[← mkAppM ``Host.Mlx.Ffi.St.arrs #[mlx],handle]) ``Option.some 2 1
    let node ← field (← mkAppM ``Host.Ts.PTrie.get #[← mkAppM ``Host.Mlx.Ffi.St.nodes #[mlx],producer]) ``Option.some 2 1
    let dims ← field (← mkAppM ``Host.Mlx.Ffi.natsOfDims #[← mkAppM ``Host.Mlx.Ffi.Node.shape #[node]]) ``Option.some 2 1
    for (tag,value) in [("F",f),("input",s),("output",t),("address",address),("object",object),("handle",handle),
      ("node",node),("producer",producer),("sourceDims",dims),("types",types),("signatureObject",signatureObject),("returns",returns),("sourceThis",ctl.getAppArgs[1]!)] do
      let type? := if tag == "input" || tag == "output" then
        some (mkApp (mkConst ``St) (mkApp (mkConst ``Ffi.S) (mkConst (pre ++ `F)))) else none
      addData (pre ++ Name.mkSimple tag) value type?
    let initial ← Term.elabTermEnsuringType initial (mkConst ``SSrv)
    let next ← Term.elabTermEnsuringType next (mkConst ``SSrv)
    addData (pre ++ `initialServer) (← mkAppM ``numberServer #[initial])
    addData (pre ++ `nextServer) (← mkAppM ``numberServer #[next])
  let symbol := "mlx_array_size"
  let n := "_root_." ++ pre.toString
  let header := "open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated Host.Mlx.Ffi.Annotated in\n"
  for (fact,type) in [
    ("source_control",s!"{n}.input.ctl = .call (.obj {n}.address) {n}.sourceThis [.big (Int.ofNat {n}.handle)]"),
    ("source_heap",s!"{n}.input.heap.get {n}.address = some (.obj {n}.object)"),
    ("source_kind",s!"{n}.object.kind = .fn (.native (.ffi .symbol) [.str chars!\"{symbol}\",.obj {n}.types,.str {n}.returns])"),
    ("source_signature",s!"{n}.input.heap.get {n}.types = some (.obj {n}.signatureObject)"),
    ("signature_kind",s!"{n}.signatureObject.kind = .array [.str chars!\"u64\"]"),
    ("source_producer",s!"{n}.input.ffi.mlx.arrs.get {n}.handle = some {n}.producer"),
    ("source_node",s!"{n}.input.ffi.mlx.nodes.get {n}.producer = some {n}.node"),
    ("source_shape",s!"{n}.node.shape = {n}.sourceDims.map (fun d => .lit (Int.ofNat d))"),
    ("source_ffi",s!"{n}.output.ffi = {n}.input.ffi")]
    do Parametric.Driver.emit (header ++ s!"theorem {n}.{fact} : {type} := by host_kernel_rfl")
  Parametric.Driver.emit (header ++ s!"theorem {n}.source_run (C : CSrv) : interpC (step {n}.F {n}.input).run C = some ({n}.output,C) := by host_kernel_rfl")
  Parametric.Driver.emit (header ++ s!"theorem {n}.source_step : interpS (step {n}.F {n}.input).run {n}.initialServer = some ({n}.output,{n}.nextServer) := by host_kernel_rfl")
  Parametric.Driver.emit (header ++ s!"theorem {n}.dimension_bounds : NaturalSizeBounds {n}.sourceDims := by decide +kernel")
  let returnRole := s!".exactInteger (roles {n}.producer).shape.sizeMeaning"
  let theoremName := "retained_size_from_source"
  Parametric.Driver.emit (header ++ s!"theorem {n}.retained_transport
      (notes : RetainedNotes) (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
      (roles : Nat → GraphNode) (boundary : Nat → Prop) (objects : Nat → Object)
      (H N : Nat → Prop) (tail : List NumV) (host : HostSt → HostSt → Prop)
      (live framed : Nat → Prop) (before after : List Val) (old old' : List Event)
      (s : St {n}.F.S) (inst : Inst ν₀ {n}.initialServer C₀)
      (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C)
        (Host.Load.Run.Full.Ordinary.VectorHost.NativeRelation ν₀ ν C₀ C roles boundary objects H N tail host)
        R live framed before after old old' {n}.input s)
      (inventory : RetainedInventory notes ν₀ ν C₀ C R live {n}.input s)
      (signatureFrame : ¬ framed {n}.types) (owned : H {n}.handle)
      (closed : closedLiteralShape (roles {n}.producer).shape = true) 
      (fnRole thisRole : Annotated.Value) (note : notes.runtime.control = callNote fnRole thisRole [.handle {n}.handle]) :
      ∃ result, interpC (step {n}.F {n}.input).run C₀ = some ({n}.output,C₀) ∧
        interpC (step {n}.F s).run C = some (result,C) ∧
        Parametric.StateR (NumberRoles ν₀ ν C₀ C)
          (Host.Load.Run.Full.Ordinary.VectorHost.NativeRelation ν₀ ν C₀ C roles boundary objects H N tail host)
          R live framed before after old old' {n}.output result ∧
        RetainedInventory (notes.withRuntime ⟨returnNote ({returnRole}),notes.runtime.stack,notes.runtime.cells⟩)
          ν₀ ν C₀ C R live {n}.output result ∧ result.ffi = s.ffi ∧ Inst ν₀ {n}.nextServer C₀ := by
      have geometry := Host.Load.Run.Full.Ordinary.MetadataSizeInventory.current_closed_geometry h.native.2
        {n}.producer {n}.node {n}.sourceDims (h.native.2.arrLive {n}.handle {n}.producer owned {n}.source_producer)
        {n}.source_node {n}.source_shape {n}.dimension_bounds closed
      obtain ⟨result,left,right,post,retained,native⟩ := Host.Load.Run.Full.Ordinary.MetadataSizeInventory.{theoremName}
        ν₀ ν C₀ C R roles boundary objects H N tail host live framed before after old old' {n}.input s h inventory
        {n}.address {n}.types {n}.handle {n}.producer {n}.object {n}.signatureObject {n}.returns {n}.sourceThis {n}.node {n}.sourceDims {n}.sourceDims
        {n}.source_control {n}.source_heap {n}.source_kind {n}.source_signature {n}.signature_kind signatureFrame
        owned {n}.source_producer {n}.source_node geometry.1 geometry.2 fnRole thisRole note
      have source := {n}.source_run C₀
      have same := congrArg Prod.fst (Option.some.inj (left.symm.trans source))
      dsimp only at same
      rw [same] at post retained
      exact ⟨result,source,right,post,retained,native,pure_step_inst {n}.F ν₀ {n}.initialServer {n}.nextServer C₀
        {n}.input {n}.output inst {n}.source_step source⟩")

end Host.Ts.Owned.Annotated.Driver
