import host.mlx.NativeRopeRetained
import host.ts.RenameRuntimeSourceCut
import host.ts.RenameRouteDriver

set_option Elab.async false

namespace Host.Ts.Owned.Annotated.Driver
open Lean Elab Command Meta
open Parametric.Driver

private def ropeHeader : String := "open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated Host.Mlx.Ffi Host.Mlx.Ffi.NativeRoles Host.Mlx.Ffi.NativeRoles.Arguments Host.Mlx.Ffi.Annotated in\n"

/-- Source-selected RoPE keeps the current literal offset expression open.
Its exact original i32 decoding is pure on both numeric servers. -/
elab "host_retained_rope " f:term ", " s:term " using " initial:term " to " t:term " using " next:term " as " name:ident : command => do
  let pre := (← getCurrNamespace) ++ name.getId
  liftTermElabM do
    let f ← Term.elabTermEnsuringType f (mkConst ``Ffi)
    unless ← isDefEq f (mkConst ``Host.Load.ffi) do throwError "host_retained_rope: expected original load FFI"
    let stateTy := mkApp (mkConst ``St) (mkApp (mkConst ``Ffi.S) f)
    let s ← Term.elabTermEnsuringType s stateTy
    let t ← Term.elabTermEnsuringType t stateTy
    let ctl ← whnf (← mkAppM ``St.ctl #[s])
    unless ctl.isAppOfArity ``Ctl.call 3 do throwError "host_retained_rope: expected source call"
    let address ← field ctl.getAppArgs[0]! ``Val.obj 1 0
    let mut arguments := ctl.getAppArgs[2]!
    let mut values : Array Lean.Expr := #[]
    for _ in [:9] do
      values := values.push (← field arguments ``List.cons 3 1)
      arguments ← field arguments ``List.cons 3 2
    unless (← whnf arguments).isAppOfArity ``List.nil 1 do throwError "host_retained_rope: expected nine arguments"
    let out ← field (← field values[0]! ``Val.ptr 2 0) ``Mem.js 1 0
    unless ← isDefEq (← field values[0]! ``Val.ptr 2 1) (mkNatLit 0) do throwError "host_retained_rope: expected zero pointer offset"
    let natural (value : Lean.Expr) := do mkAppM ``Int.toNat #[← field value ``Val.big 1 0]
    let literal (value : Lean.Expr) := do field (← field value ``Val.num 1 0) ``NumV.lit 1 0
    let handle ← natural values[1]!
    let dimValue ← literal values[2]!
    let dimNumber ← mkAppM ``Arg.num #[← mkAppM ``NumV.lit #[dimValue]]
    let dims ← field (← mkAppM ``Host.Mlx.Ffi.argNat #[dimNumber]) ``Option.some 2 1
    let traditional ← field values[3]! ``Val.bool 1 0
    let base ← field values[4]! ``Val.big 1 0
    let scale ← literal values[5]!
    let offsetNumber ← whnf (← field values[6]! ``Val.num 1 0)
    unless offsetNumber.isAppOfArity ``NumV.lit 1 do throwError "host_retained_rope: expected literal offset occurrence"
    let offsetValue := offsetNumber.getAppArgs[0]!
    unless ← isDefEq (← field values[7]! ``Val.big 1 0) (toExpr (0 : Int)) do throwError "host_retained_rope: expected zero frequency handle"
    let stream ← natural values[8]!
    let object ← field (← mkAppM ``St.obj? #[s,address]) ``Option.some 2 1
    let code ← whnf (← field (← mkAppM ``Obj.kind #[object]) ``Kind.fn 1 0)
    let native ← whnf (← field code ``Code.native 2 0)
    unless (← whnf (← field native ``Native.ffi 1 0)).isConstOf ``FfiN.symbol do throwError "host_retained_rope: expected FFI symbol"
    let caps := code.getAppArgs[1]!
    let symbol ← field (← field caps ``List.cons 3 1) ``Val.str 1 0
    unless ← isDefEq symbol (toExpr chars!"mlx_fast_rope") do throwError "host_retained_rope: expected mlx_fast_rope"
    let rest ← field caps ``List.cons 3 2
    let types ← field (← field rest ``List.cons 3 1) ``Val.obj 1 0
    let rest ← field rest ``List.cons 3 2
    let returns ← field (← field rest ``List.cons 3 1) ``Val.str 1 0
    unless (← whnf (← field rest ``List.cons 3 2)).isAppOfArity ``List.nil 1 do throwError "host_retained_rope: expected three symbol captures"
    let signatureObject ← field (← mkAppM ``St.obj? #[s,types]) ``Option.some 2 1
    let mlx ← mkAppM ``Host.Load.LSt.mlx #[← mkAppM ``St.ffi #[s]]
    let input ← field (← mkAppM ``Host.Mlx.Ffi.St.nodeId? #[mlx,handle]) ``Option.some 2 1
    let node ← field (← mkAppM ``PTrie.get #[← mkAppM ``Host.Mlx.Ffi.St.nodes #[mlx],input]) ``Option.some 2 1
    let rank ← mkAppM ``List.length #[← mkAppM ``Host.Mlx.Ffi.Node.shape #[node]]
    unless ← isDefEq (← mkAppM ``Nat.ble #[mkNatLit 3,rank]) (mkConst ``Bool.true) do throwError "host_retained_rope: expected input rank at least three"
    for (tag,value) in [("F",f),("input",s),("output",t),("address",address),("object",object),
      ("types",types),("signatureObject",signatureObject),("returns",returns),("sourceThis",ctl.getAppArgs[1]!),
      ("out",out),("handle",handle),("stream",stream),("dims",dims),("dimValue",dimValue),("traditional",traditional),
      ("base",base),("scale",scale),("offsetValue",offsetValue),("producer",input),("node",node)] do
      addData (pre ++ Name.mkSimple tag) value (if tag == "input" || tag == "output" then some stateTy else none)
    let initial ← Term.elabTermEnsuringType initial (mkConst ``SSrv)
    let next ← Term.elabTermEnsuringType next (mkConst ``SSrv)
    addData (pre ++ `initialServer) (← mkAppM ``numberServer #[initial])
    addData (pre ++ `nextServer) (← mkAppM ``numberServer #[next])
  let n := "_root_." ++ pre.toString
  for (fact,type) in [
    ("source_control",s!"{n}.input.ctl = .call (.obj {n}.address) {n}.sourceThis (Host.Load.Run.Full.Ordinary.RopeHost.rawArgs {n}.out {n}.handle {n}.stream {n}.dimValue {n}.traditional {n}.base {n}.scale (.lit {n}.offsetValue))"),
    ("source_heap",s!"{n}.input.heap.get {n}.address = some (.obj {n}.object)"),
    ("source_kind",s!"{n}.object.kind = .fn (.native (.ffi .symbol) [.str Host.Load.Run.Full.Ordinary.RopeHost.symbol,.obj {n}.types,.str {n}.returns])"),
    ("source_signature",s!"{n}.input.heap.get {n}.types = some (.obj {n}.signatureObject)"),
    ("signature_kind",s!"{n}.signatureObject.kind = .array Host.Load.Run.Full.Ordinary.RopeHost.signature"),
    ("source_producer",s!"nodesOf {n}.input.ffi.mlx [{n}.handle] = some [{n}.producer]"),
    ("source_node",s!"{n}.input.ffi.mlx.nodes.get {n}.producer = some {n}.node"),
    ("source_allocation",s!"{n}.output.ffi.mlx.nnext = {n}.input.ffi.mlx.nnext + 1")]
    do Parametric.Driver.emit (ropeHeader ++ s!"theorem {n}.{fact} : {type} := by host_kernel_rfl")
  for (fact,type) in [
    ("source_native_bound",s!"{n}.input.ffi.mlx.next < 2^64"),("source_node_bound",s!"{n}.input.ffi.mlx.nnext < 2^64"),
    ("source_output_bound",s!"{n}.out < 2^64"),("dimension",s!"F64.toInt? {n}.dimValue = some (Int.ofNat {n}.dims)"),
    ("dim_fixed",s!"F64.un .int32 {n}.dimValue = {n}.dimValue"),("positive",s!"0 < {n}.dims"),
    ("source_rank",s!"Nat.ble 3 {n}.node.shape.length = true")]
    do Parametric.Driver.emit (ropeHeader ++ s!"theorem {n}.{fact} : {type} := by decide +kernel")
  Parametric.Driver.emit (ropeHeader ++ s!"theorem {n}.source_run (C : CSrv) : interpC (step {n}.F {n}.input).run C = some ({n}.output,C) := by host_kernel_rfl")
  Parametric.Driver.emit (ropeHeader ++ s!"theorem {n}.source_step : interpS (step {n}.F {n}.input).run {n}.initialServer = some ({n}.output,{n}.nextServer) := by host_kernel_rfl")
  Parametric.Driver.emit (ropeHeader ++ s!"theorem {n}.retained_transport
      (notes : RetainedNotes) (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
      (roles : Nat → GraphNode) (boundary : Nat → Prop) (objects : Nat → Object)
      (H N : Nat → Prop) (tail : List NumV) (host : HostSt → HostSt → Prop)
      (live framed : Nat → Prop) (before after : List Val) (old old' : List Event)
      (s : St {n}.F.S) (inst : Inst ν₀ {n}.initialServer C₀)
      (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C)
        (Host.Load.Run.Full.Ordinary.VectorHost.NativeRelation ν₀ ν C₀ C roles boundary objects H N tail host)
        R live framed before after old old' {n}.input s)
      (inventory : RetainedInventory notes ν₀ ν C₀ C R live {n}.input s)
      (signatureFrame : ¬ framed {n}.types) (handleLive : H {n}.handle)
      (targetNodes : s.ffi.mlx.nnext < 2^64) (targetHandles : s.ffi.mlx.next < 2^64) (targetHeap : s.next < 2^64)
      (roots : Nat → Prop) (policy : ProducerAnnotations roots H N roles objects)
      (fnRole thisRole : Annotated.Value) (offset : SymE)
      (note : notes.runtime.control = callNote fnRole thisRole
        (Host.Load.Run.Full.Ordinary.RopeHost.literalArgumentNotes {n}.out {n}.handle {n}.stream {n}.dimValue {n}.traditional {n}.base {n}.scale offset))
      (selected : notes.buffers.owners {n}.out = some (handleSlotNotes 0)) :
      let newRoles := nodeWrite roles {n}.input.ffi.mlx.nnext (ropeRole roles {n}.producer {n}.dims {n}.traditional
        (Host.Load.Run.Full.Ordinary.RopeHost.baseRole {n}.base) (Host.Load.Run.Full.Ordinary.RopeHost.scaleRole {n}.scale) ((Number.literal offset).decoded .i32))
      let newObjects := objectWrite objects {n}.input.ffi.mlx.next .stream
      let newH := fun a => a = {n}.input.ffi.mlx.next ∨ H a
      let newN := fun i => i = {n}.input.ffi.mlx.nnext ∨ N i
      ∃ result, interpC (step {n}.F {n}.input).run C₀ = some ({n}.output,C₀) ∧ interpC (step {n}.F s).run C = some (result,C) ∧
        Parametric.StateR (NumberRoles ν₀ ν C₀ C)
          (Host.Load.Run.Full.Ordinary.VectorHost.NativeRelation ν₀ ν C₀ C newRoles boundary newObjects newH newN tail host)
          R live framed before after old old' {n}.output result ∧
        RetainedInventory (notes.nativeHandleResult {n}.out {n}.input.ffi.mlx.next) ν₀ ν C₀ C R live {n}.output result ∧
        ProducerAnnotations roots newH newN newRoles newObjects ∧ ProducerSupport roots newH newN {n}.output.ffi.mlx ∧ Inst ν₀ {n}.nextServer C₀ := by
      obtain ⟨sourcePost,result,left,right,post,retained,policyPost,support⟩ :=
        Host.Load.Run.Full.Ordinary.RopeHost.retained_from_source ν₀ ν C₀ C R roles boundary objects H N tail host
          live framed before after old old' {n}.input s h inventory {n}.address {n}.types {n}.out {n}.handle {n}.producer {n}.stream {n}.dims
          {n}.dimValue {n}.traditional {n}.base {n}.scale offset {n}.offsetValue {n}.object {n}.signatureObject {n}.returns {n}.sourceThis {n}.node
          {n}.source_control {n}.source_heap {n}.source_kind {n}.source_signature {n}.signature_kind signatureFrame handleLive
          {n}.source_producer {n}.source_node {n}.dimension {n}.dim_fixed {n}.positive {n}.source_rank
          {n}.source_node_bound targetNodes {n}.source_native_bound targetHandles {n}.source_output_bound targetHeap roots policy fnRole thisRole note selected
      obtain ⟨D,actual,instAfter⟩ := interp_sim ν₀ (step {n}.F {n}.input).run {n}.initialServer C₀ {n}.output {n}.nextServer inst {n}.source_step
      have equality := Option.some.inj (left.symm.trans actual)
      have same : sourcePost = {n}.output := congrArg Prod.fst equality
      have table : C₀ = D := congrArg Prod.snd equality
      rw [same] at left post retained support
      exact ⟨result,left,right,post,retained,policyPost,support,table ▸ instAfter⟩")

end Host.Ts.Owned.Annotated.Driver
