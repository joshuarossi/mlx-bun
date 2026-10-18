import host.mlx.NativeUnaryRetained
import host.ts.RenameRuntimeSourceCut
import host.ts.RenameRouteDriver

set_option Elab.async false
namespace Host.Ts.Owned.Annotated.Driver
open Lean Elab Command Meta Parametric.Driver

/-- Source-selected unary FFI transport, using the current input handle and
null output-slot notes for the complete retained result. -/
elab "host_retained_unary " f:term ", " s:term " using " initial:term " to " t:term " using " next:term " as " name:ident : command => do
  let pre := (← getCurrNamespace) ++ name.getId
  liftTermElabM do
    let f ← Term.elabTermEnsuringType f (mkConst ``Ffi)
    unless ← isDefEq f (mkConst ``Host.Load.ffi) do throwError "host_retained_unary: expected original load FFI"
    let stateTy := mkApp (mkConst ``St) (mkApp (mkConst ``Ffi.S) f)
    let s ← Term.elabTermEnsuringType s stateTy
    let t ← Term.elabTermEnsuringType t stateTy
    let control ← whnf (← mkAppM ``St.ctl #[s])
    unless control.isAppOfArity ``Ctl.call 3 do throwError "host_retained_unary: expected source call"
    let fn ← field control.getAppArgs[0]! ``Val.obj 1 0
    let args := control.getAppArgs[2]!
    let out ← field (← field (← field args ``List.cons 3 1) ``Val.ptr 2 0) ``Mem.js 1 0
    let rest ← field args ``List.cons 3 2
    let handle ← mkAppM ``Int.toNat #[← field (← field rest ``List.cons 3 1) ``Val.big 1 0]
    let rest ← field rest ``List.cons 3 2
    let stream ← mkAppM ``Int.toNat #[← field (← field rest ``List.cons 3 1) ``Val.big 1 0]
    unless (← whnf (← field rest ``List.cons 3 2)).isAppOfArity ``List.nil 1 do
      throwError "host_retained_unary: expected three arguments"
    let function ← field (← mkAppM ``St.obj? #[s,fn]) ``Option.some 2 1
    let code ← whnf (← field (← mkAppM ``Obj.kind #[function]) ``Kind.fn 1 0)
    let native ← whnf (← field code ``Code.native 2 0)
    unless (← whnf (← field native ``Native.ffi 1 0)).isConstOf ``FfiN.symbol do
      throwError "host_retained_unary: expected native FFI symbol"
    let captures := code.getAppArgs[1]!
    let symbol ← field (← field captures ``List.cons 3 1) ``Val.str 1 0
    let category ← field (← mkAppM ``Host.Mlx.Ffi.symOf #[symbol]) ``Option.some 2 1
    unless (← whnf category).isConstOf ``Host.Mlx.Ffi.Sym.unary do
      throwError "host_retained_unary: expected unary MLX operation"
    let captures ← field captures ``List.cons 3 2
    let types ← field (← field captures ``List.cons 3 1) ``Val.obj 1 0
    let returns ← field (← field (← field captures ``List.cons 3 2) ``List.cons 3 1) ``Val.str 1 0
    let signature ← field (← mkAppM ``St.obj? #[s,types]) ``Option.some 2 1
    let nativeState ← mkAppM ``Host.Load.LSt.mlx #[← mkAppM ``St.ffi #[s]]
    let producer ← field (← mkAppM ``Host.Mlx.Ffi.St.nodeId? #[nativeState,handle]) ``Option.some 2 1
    let node ← field (← mkAppM ``PTrie.get #[← mkAppM ``Host.Mlx.Ffi.St.nodes #[nativeState],producer]) ``Option.some 2 1
    for (tag,value) in [("F",f),("input",s),("output",t),("fn",fn),("out",out),("handle",handle),("stream",stream),
      ("function",function),("types",types),("returns",returns),("signature",signature),("symbol",symbol),
      ("producer",producer),("node",node),("sourceThis",control.getAppArgs[1]!)] do
      addData (pre ++ Name.mkSimple tag) value (if tag == "input" || tag == "output" then some stateTy else none)
    addData (pre ++ `initialServer) (← mkAppM ``numberServer #[← Term.elabTermEnsuringType initial (mkConst ``SSrv)])
    addData (pre ++ `nextServer) (← mkAppM ``numberServer #[← Term.elabTermEnsuringType next (mkConst ``SSrv)])
  let n := "_root_." ++ pre.toString
  let header := "open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated Host.Mlx.Ffi Host.Mlx.Ffi.NativeRoles Host.Mlx.Ffi.Annotated Host.Load.Run.Full.Ordinary in\n"
  for (tag,type) in [
    ("source_control",s!"{n}.input.ctl = .call (.obj {n}.fn) {n}.sourceThis [.ptr (.js {n}.out) 0,.big (Int.ofNat {n}.handle),.big (Int.ofNat {n}.stream)]"),
    ("source_function_read",s!"{n}.input.heap.get {n}.fn = some (.obj {n}.function)"),
    ("source_function_kind",s!"{n}.function.kind = .fn (.native (.ffi .symbol) [.str {n}.symbol,.obj {n}.types,.str {n}.returns])"),
    ("source_signature_read",s!"{n}.input.heap.get {n}.types = some (.obj {n}.signature)"),
    ("source_signature_kind",s!"{n}.signature.kind = .array [.str chars!\"ptr\",.str chars!\"u64\",.str chars!\"u64\"]"),
    ("source_producer",s!"{n}.input.ffi.mlx.nodeId? {n}.handle = some {n}.producer"),
    ("source_node",s!"{n}.input.ffi.mlx.nodes.get {n}.producer = some {n}.node"),
    ("source_servers",s!"{n}.initialServer = {n}.nextServer")]
    do Parametric.Driver.emit (header ++ s!"theorem {n}.{tag} : {type} := by host_kernel_rfl")
  for (tag,type) in [
    ("source_mlx",s!"isMlx {n}.symbol = true"),("source_unary",s!"symOf {n}.symbol = some .unary"),
    ("source_node_bound",s!"{n}.input.ffi.mlx.nnext < 2^64"),
    ("source_handle_bound",s!"{n}.input.ffi.mlx.next < 2^64"),("source_heap_bound",s!"{n}.out < 2^64")]
    do Parametric.Driver.emit (header ++ s!"theorem {n}.{tag} : {type} := by decide +kernel")
  Parametric.Driver.emit (header ++ s!"theorem {n}.source_run (C : CSrv) : interpC (step {n}.F {n}.input).run C = some ({n}.output,C) := by host_kernel_rfl")
  Parametric.Driver.emit (header ++ s!"theorem {n}.source_step : interpS (step {n}.F {n}.input).run {n}.initialServer = some ({n}.output,{n}.nextServer) := by host_kernel_rfl")
  Parametric.Driver.emit (header ++ s!"theorem {n}.retained_transport
      (notes : RetainedNotes) (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
      (roles : Nat → GraphNode) (boundary : Nat → Prop) (objects : Nat → Object)
      (roots H N : Nat → Prop) (tail : List NumV) (host : Host.Load.HostSt → Host.Load.HostSt → Prop)
      (live framed : Nat → Prop) (before after : List Val) (old old' : List Event) (s : St {n}.F.S)
      (inst : Inst ν₀ {n}.initialServer C₀)
      (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) (VectorHost.NativeRelation ν₀ ν C₀ C roles boundary objects H N tail host)
        R live framed before after old old' {n}.input s)
      (inventory : RetainedInventory notes ν₀ ν C₀ C R live {n}.input s)
      (policy : ProducerAnnotations roots H N roles objects)
      (signatureFrame : ¬ framed {n}.types) (handleLive : H {n}.handle)
      (targetNodes : s.ffi.mlx.nnext < 2^64) (targetHandles : s.ffi.mlx.next < 2^64) (targetHeap : s.next < 2^64)
      (fnRole thisRole : Annotated.Value)
      (controlNote : notes.runtime.control = callNote fnRole thisRole [.ptr (.js {n}.out) 0,.handle {n}.handle,.handle {n}.stream])
      (slotNote : notes.buffers.owners {n}.out = some (handleSlotNotes 0)) :
      let newRoles := nodeWrite roles {n}.input.ffi.mlx.nnext (unaryRole roles {n}.symbol {n}.producer)
      let newObjects := objectWrite objects {n}.input.ffi.mlx.next .stream
      let newH := fun a => a = {n}.input.ffi.mlx.next ∨ H a
      let newN := fun i => i = {n}.input.ffi.mlx.nnext ∨ N i
      ∃ result, interpC (step {n}.F {n}.input).run C₀ = some ({n}.output,C₀) ∧
        interpC (step {n}.F s).run C = some (result,C) ∧
        Parametric.StateR (NumberRoles ν₀ ν C₀ C) (VectorHost.NativeRelation ν₀ ν C₀ C newRoles boundary newObjects newH newN tail host)
          R live framed before after old old' {n}.output result ∧
        RetainedInventory (notes.nativeHandleResult {n}.out {n}.input.ffi.mlx.next) ν₀ ν C₀ C R live {n}.output result ∧
        ProducerAnnotations roots newH newN newRoles newObjects ∧ ProducerSupport roots newH newN {n}.output.ffi.mlx ∧
        Inst ν₀ {n}.nextServer C₀ := by
      dsimp only
      obtain ⟨sourcePost,result,left,right,post,retained,policy',support⟩ := UnaryHost.retained_from_source
        ν₀ ν C₀ C R roles boundary objects roots H N tail host live framed before after old old' {n}.input s h inventory policy
        {n}.symbol {n}.fn {n}.types {n}.out {n}.handle {n}.stream {n}.producer {n}.node
        {n}.function {n}.signature {n}.returns {n}.sourceThis {n}.source_mlx {n}.source_unary
        {n}.source_control {n}.source_function_read {n}.source_function_kind {n}.source_signature_read {n}.source_signature_kind
        signatureFrame handleLive {n}.source_producer {n}.source_node {n}.source_node_bound targetNodes
        {n}.source_handle_bound targetHandles {n}.source_heap_bound targetHeap fnRole thisRole controlNote slotNote
      have source := {n}.source_run C₀
      have same := congrArg Prod.fst (Option.some.inj (left.symm.trans source))
      dsimp only at same
      rw [same] at post retained support
      exact ⟨_,source,right,post,retained,policy',support,{n}.source_servers ▸ inst⟩")

end Host.Ts.Owned.Annotated.Driver
