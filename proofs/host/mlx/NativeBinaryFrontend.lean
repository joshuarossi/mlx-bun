import host.mlx.NativeBinaryRetained
import host.ts.RenameRuntimeSourceCut
import host.ts.RenameRouteDriver

set_option Elab.async false
namespace Host.Ts.Owned.Annotated.Driver
open Lean Elab Command Meta Parametric.Driver

/-- Source-selected binary FFI transport from the current operand, broadcast
layout and null-slot inventories. -/
elab "host_retained_binary " f:term ", " s:term " using " initial:term " to " t:term " using " next:term " as " name:ident : command => do
  let pre := (← getCurrNamespace) ++ name.getId
  liftTermElabM do
    let f ← Term.elabTermEnsuringType f (mkConst ``Ffi)
    unless ← isDefEq f (mkConst ``Host.Load.ffi) do throwError "host_retained_binary: expected original load FFI"
    let stateTy := mkApp (mkConst ``St) (mkApp (mkConst ``Ffi.S) f)
    let s ← Term.elabTermEnsuringType s stateTy
    let t ← Term.elabTermEnsuringType t stateTy
    let control ← whnf (← mkAppM ``St.ctl #[s])
    unless control.isAppOfArity ``Ctl.call 3 do throwError "host_retained_binary: expected source call"
    let fn ← field control.getAppArgs[0]! ``Val.obj 1 0
    let args := control.getAppArgs[2]!
    let out ← field (← field (← field args ``List.cons 3 1) ``Val.ptr 2 0) ``Mem.js 1 0
    let rest ← field args ``List.cons 3 2
    let hx ← mkAppM ``Int.toNat #[← field (← field rest ``List.cons 3 1) ``Val.big 1 0]
    let rest ← field rest ``List.cons 3 2
    let hy ← mkAppM ``Int.toNat #[← field (← field rest ``List.cons 3 1) ``Val.big 1 0]
    let rest ← field rest ``List.cons 3 2
    let stream ← mkAppM ``Int.toNat #[← field (← field rest ``List.cons 3 1) ``Val.big 1 0]
    unless (← whnf (← field rest ``List.cons 3 2)).isAppOfArity ``List.nil 1 do
      throwError "host_retained_binary: expected four arguments"
    let function ← field (← mkAppM ``St.obj? #[s,fn]) ``Option.some 2 1
    let code ← whnf (← field (← mkAppM ``Obj.kind #[function]) ``Kind.fn 1 0)
    let native ← whnf (← field code ``Code.native 2 0)
    unless (← whnf (← field native ``Native.ffi 1 0)).isConstOf ``FfiN.symbol do
      throwError "host_retained_binary: expected native FFI symbol"
    let captures := code.getAppArgs[1]!
    let symbol ← field (← field captures ``List.cons 3 1) ``Val.str 1 0
    let category ← field (← mkAppM ``Host.Mlx.Ffi.symOf #[symbol]) ``Option.some 2 1
    unless (← whnf category).isConstOf ``Host.Mlx.Ffi.Sym.binary do
      throwError "host_retained_binary: expected binary MLX operation"
    let captures ← field captures ``List.cons 3 2
    let types ← field (← field captures ``List.cons 3 1) ``Val.obj 1 0
    let returns ← field (← field (← field captures ``List.cons 3 2) ``List.cons 3 1) ``Val.str 1 0
    let signature ← field (← mkAppM ``St.obj? #[s,types]) ``Option.some 2 1
    let nativeState ← mkAppM ``Host.Load.LSt.mlx #[← mkAppM ``St.ffi #[s]]
    let producer (handle : Lean.Expr) := do field (← mkAppM ``Host.Mlx.Ffi.St.nodeId? #[nativeState,handle]) ``Option.some 2 1
    let x ← producer hx
    let y ← producer hy
    let nodes ← mkAppM ``Host.Mlx.Ffi.St.nodes #[nativeState]
    let xn ← field (← mkAppM ``PTrie.get #[nodes,x]) ``Option.some 2 1
    let yn ← field (← mkAppM ``PTrie.get #[nodes,y]) ``Option.some 2 1
    for (tag,value) in [("F",f),("input",s),("output",t),("fn",fn),("out",out),("hx",hx),("hy",hy),("stream",stream),
      ("function",function),("types",types),("returns",returns),("signature",signature),("symbol",symbol),
      ("x",x),("y",y),("xn",xn),("yn",yn),("sourceThis",control.getAppArgs[1]!)] do
      addData (pre ++ Name.mkSimple tag) value (if tag == "input" || tag == "output" then some stateTy else none)
    addData (pre ++ `initialServer) (← mkAppM ``numberServer #[← Term.elabTermEnsuringType initial (mkConst ``SSrv)])
    addData (pre ++ `nextServer) (← mkAppM ``numberServer #[← Term.elabTermEnsuringType next (mkConst ``SSrv)])
  let n := "_root_." ++ pre.toString
  let header := "open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated Host.Mlx.Ffi Host.Mlx.Ffi.NativeRoles Host.Mlx.Ffi.Annotated Host.Load.Run.Full.Ordinary in\n"
  for (tag,type) in [
    ("source_control",s!"{n}.input.ctl = .call (.obj {n}.fn) {n}.sourceThis [.ptr (.js {n}.out) 0,.big (Int.ofNat {n}.hx),.big (Int.ofNat {n}.hy),.big (Int.ofNat {n}.stream)]"),
    ("source_function_read",s!"{n}.input.heap.get {n}.fn = some (.obj {n}.function)"),
    ("source_function_kind",s!"{n}.function.kind = .fn (.native (.ffi .symbol) [.str {n}.symbol,.obj {n}.types,.str {n}.returns])"),
    ("source_signature_read",s!"{n}.input.heap.get {n}.types = some (.obj {n}.signature)"),
    ("source_signature_kind",s!"{n}.signature.kind = .array BinaryHost.signature"),
    ("source_producers",s!"nodesOf {n}.input.ffi.mlx [{n}.hx,{n}.hy] = some [{n}.x,{n}.y]"),
    ("source_x",s!"{n}.input.ffi.mlx.nodes.get {n}.x = some {n}.xn"),
    ("source_y",s!"{n}.input.ffi.mlx.nodes.get {n}.y = some {n}.yn"),
    ("source_servers",s!"{n}.initialServer = {n}.nextServer")]
    do Parametric.Driver.emit (header ++ s!"theorem {n}.{tag} : {type} := by host_kernel_rfl")
  for (tag,type) in [
    ("source_mlx",s!"isMlx {n}.symbol = true"),("source_binary",s!"symOf {n}.symbol = some .binary"),
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
      (signatureFrame : ¬ framed {n}.types) (handlesLive : listSupport H [{n}.hx,{n}.hy])
      (output : Shape) (layout : BinaryLayout (roles {n}.x).shape (roles {n}.y).shape output)
      (targetNodes : s.ffi.mlx.nnext < 2^64) (targetHandles : s.ffi.mlx.next < 2^64) (targetHeap : s.next < 2^64)
      (fnRole thisRole : Annotated.Value)
      (controlNote : notes.runtime.control = callNote fnRole thisRole [.ptr (.js {n}.out) 0,.handle {n}.hx,.handle {n}.hy,.handle {n}.stream])
      (slotNote : notes.buffers.owners {n}.out = some (handleSlotNotes 0)) :
      let newRoles := nodeWrite roles {n}.input.ffi.mlx.nnext (binaryRole roles {n}.symbol {n}.x {n}.y output)
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
      obtain ⟨sourcePost,result,left,right,post,retained,policy',support⟩ := BinaryHost.retained_from_source
        ν₀ ν C₀ C R roles boundary objects roots H N tail host live framed before after old old' {n}.input s h inventory policy
        {n}.fn {n}.types {n}.out {n}.hx {n}.hy {n}.x {n}.y {n}.stream {n}.symbol {n}.returns
        {n}.function {n}.signature {n}.sourceThis {n}.xn {n}.yn output
        {n}.source_control {n}.source_function_read {n}.source_function_kind {n}.source_signature_read {n}.source_signature_kind
        signatureFrame {n}.source_mlx {n}.source_binary handlesLive {n}.source_producers {n}.source_x {n}.source_y layout
        {n}.source_node_bound targetNodes
        {n}.source_handle_bound targetHandles {n}.source_heap_bound targetHeap fnRole thisRole controlNote slotNote
      have source := {n}.source_run C₀
      have same := congrArg Prod.fst (Option.some.inj (left.symm.trans source))
      dsimp only at same
      rw [same] at post retained support
      exact ⟨_,source,right,post,retained,policy',support,{n}.source_servers ▸ inst⟩")

end Host.Ts.Owned.Annotated.Driver
