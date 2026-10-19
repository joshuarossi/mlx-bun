import host.mlx.NativeShapeCallTail
import host.ts.RenameRuntimeDriverValues

set_option Elab.async false
namespace Host.Ts.Owned.Annotated.Driver
open Lean Elab Command Meta Parametric.Driver

private def emitShapeTailChecked (source : String) : CommandElabM Unit := do
  let count := (← get).messages.reportedPlusUnreported.toList.length
  Parametric.Driver.emit source
  let errors := ((← get).messages.reportedPlusUnreported.toList.drop count).filter (fun m => m.severity == .error)
  unless errors.isEmpty do
    let rendered ← errors.mapM fun m => m.data.toString
    throwError "host_retained_shape_tail: kernel rejected generated source contract\n{String.intercalate "\n" rendered}"

private def generateShapeTail (f s initial t next : Syntax) (name : TSyntax `ident) : CommandElabM Unit := do
  let pre := (← getCurrNamespace) ++ name.getId
  let n := "_root_." ++ pre.toString
  let header := "open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated Host.Load.Run.Full.Ordinary Host.Mlx.Ffi.Annotated Host.Mlx.Ffi.NativeRoles in\n"
  let fact (tag proposition : String) := emitShapeTailChecked (header ++ s!"theorem {n}.{tag} : {proposition} := by host_kernel_rfl")
  liftTermElabM do
    let stateTy := mkApp (mkConst ``St) (mkConst ``Host.Load.LSt)
    let f ← Term.elabTermEnsuringType f (mkConst ``Ffi)
    let source ← Term.elabTermEnsuringType s stateTy
    let target ← Term.elabTermEnsuringType t stateTy
    let control ← mkAppM ``St.ctl #[source]
    let bufferFn ← field (← field control ``Ctl.call 3 0) ``Val.obj 1 0
    let bufferThis ← field control ``Ctl.call 3 1
    let args ← field control ``Ctl.call 3 2
    let pointer ← field args ``List.cons 3 1
    let region ← field (← field pointer ``Val.ptr 2 0) ``Mem.ext 1 0
    let handle ← whnf (← mkAppM ``Nat.div #[region,mkNatLit 4])
    let args ← field args ``List.cons 3 2
    let args ← field args ``List.cons 3 2
    let count ← field (← field (← field args ``List.cons 3 1) ``Val.num 1 0) ``NumV.lit 1 0
    let stack ← mkAppM ``St.stack #[source]
    let argFrame ← field (← field stack ``List.cons 3 1) ``Frame.c 1 0
    let typedFn ← field (← field argFrame ``CallF.args 6 1) ``Val.obj 1 0
    let env ← field argFrame ``CallF.args 6 5
    let rec drop (xs : Lean.Expr) : Nat → TermElabM Lean.Expr
      | 0 => pure xs
      | k+1 => do drop (← field xs ``List.cons 3 2) k
    let block ← field (← field (← drop stack 3) ``List.cons 3 1) ``Frame.s 1 0
    let bodyEnv ← field block ``StmtF.block 2 1
    let caller ← drop stack 6
    let object (a : Lean.Expr) : TermElabM Lean.Expr := do field (← mkAppM ``St.obj? #[source,a]) ``Option.some 2 1
    let bufferObject ← object bufferFn
    let bufferData ← field (← field (← mkAppM ``Obj.kind #[bufferObject]) ``Kind.fn 1 0) ``Code.native 2 1
    let typedObject ← object typedFn
    let typedData ← field (← field (← mkAppM ``Obj.kind #[typedObject]) ``Kind.fn 1 0) ``Code.native 2 1
    let kindValue ← field (← field (← field typedData ``List.cons 3 1) ``Val.num 1 0) ``NumV.lit 1 0
    let typedData ← field typedData ``List.cons 3 2
    let protoValue ← field (← field (← field typedData ``List.cons 3 1) ``Val.num 1 0) ``NumV.lit 1 0
    let typedProto ← field (← mkAppM ``F64.toIndex? #[protoValue]) ``Option.some 2 1
    let native ← mkAppM ``Host.Load.LSt.mlx #[← mkAppM ``St.ffi #[source]]
    let node ← field (← mkAppM ``Host.Mlx.Ffi.St.node? #[native,handle]) ``Option.some 2 1
    let producer ← field (← mkAppM ``PTrie.get #[← mkAppM ``Host.Mlx.Ffi.St.arrs #[native],handle]) ``Option.some 2 1
    for (tag,value) in [("F",f),("input",source),("output",target),("sourceBufferFn",bufferFn),("sourceBufferThis",bufferThis),
      ("sourceTypedFn",typedFn),("sourceTypedProto",typedProto),("sourceHandle",handle),("sourceProducer",producer),
      ("sourceBufferObject",bufferObject),("sourceBufferData",bufferData),("sourceTypedObject",typedObject),
      ("sourceKind",kindValue),("sourceProto",protoValue),("sourceCount",count),("sourceEnv",env),
      ("sourceBodyEnv",bodyEnv),("sourceCaller",caller),("sourceNode",node)] do
      addData (pre ++ Name.mkSimple tag) value (if tag == "input" || tag == "output" then some stateTy else none)
    addData (pre ++ `span) (mkNatLit 8)
    addData (pre ++ `initialServer) (← mkAppM ``numberServer #[← Term.elabTermEnsuringType initial (mkConst ``SSrv)])
    addData (pre ++ `nextServer) (← mkAppM ``numberServer #[← Term.elabTermEnsuringType next (mkConst ``SSrv)])
  for (tag,proposition) in [
    ("source_ffi",s!"{n}.F = Host.Load.ffi"),
    ("source_control",s!"{n}.input.ctl = .call (.obj {n}.sourceBufferFn) {n}.sourceBufferThis [.ptr (.ext (4*{n}.sourceHandle)) 0,.num (.lit (F64.zero false)),.num (.lit {n}.sourceCount)]"),
    ("source_stack",s!"{n}.input.stack = .c (.args 1 (.obj {n}.sourceTypedFn) .undef [] [] {n}.sourceEnv)::.l (.spread [] [] {n}.sourceEnv)::.s .ret::.s (.block [] {n}.sourceBodyEnv)::.s (.scope [])::.k (.fn .call)::{n}.sourceCaller"),
    ("source_buffer_read",s!"{n}.input.heap.get {n}.sourceBufferFn = some (.obj {n}.sourceBufferObject)"),
    ("source_buffer_kind",s!"{n}.sourceBufferObject.kind = .fn (.native (.ffi .toArrayBuffer) {n}.sourceBufferData)"),
    ("source_typed_read",s!"{n}.input.heap.get {n}.sourceTypedFn = some (.obj {n}.sourceTypedObject)"),
    ("source_typed_kind",s!"{n}.sourceTypedObject.kind = .fn (.native (.buf .typedCtor) [.num (.lit {n}.sourceKind),.num (.lit {n}.sourceProto)])"),
    ("source_kind",s!"F64.toIndex? {n}.sourceKind = some 4"),
    ("source_proto",s!"F64.toIndex? {n}.sourceProto = some {n}.sourceTypedProto"),
    ("source_count",s!"F64.toIndex? {n}.sourceCount = some (len {n}.sourceNode.shape*4)"),
    ("source_node",s!"{n}.input.ffi.mlx.node? {n}.sourceHandle = some {n}.sourceNode"),
    ("source_producer",s!"{n}.input.ffi.mlx.arrs.get {n}.sourceHandle = some {n}.sourceProducer"),
    ("source_endpoint",s!"ShapeCall.tailResult {n}.input {n}.sourceHandle {n}.sourceNode {n}.sourceTypedProto {n}.sourceCaller = {n}.output"),
    ("source_servers",s!"{n}.initialServer = {n}.nextServer")]
    do fact tag proposition
  emitShapeTailChecked (header ++ s!"theorem {n}.source_bound : {n}.input.next+3 ≤ 2^64 := by decide +kernel")
  emitShapeTailChecked (header ++ s!"theorem {n}.retained_transport
    (notes : RetainedNotes) (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (nodes : Nat → GraphNode) (boundary : Nat → Prop) (objects : Nat → Object)
    (roots H N : Nat → Prop) (tokens : List NumV) (host : Host.Load.HostSt → Host.Load.HostSt → Prop)
    (live framed : Nat → Prop) (before after : List Val) (old old' : List Event) (s : St Host.Load.LSt)
    (inst : Inst ν₀ {n}.initialServer C₀)
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) (VectorHost.NativeRelation ν₀ ν C₀ C nodes boundary objects H N tokens host) R live framed before after old old' {n}.input s)
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live {n}.input s) (policy : ProducerAnnotations roots H N nodes objects)
    (constructor : NativeCaptureNote) (countMeaning : SymE) (bufferFnRole bufferThisRole : Value)
    (spreadNote retNote blockNote scopeNote boundaryNote : Annotated.Tree) (callerNotes : List Annotated.Tree)
    (countClosed : ∀ valuation, countMeaning.eval valuation = {n}.sourceCount)
    (capture : notes.captures.owners {n}.sourceTypedFn = some constructor)
    (codeNote : constructor.roles 0 = some (.literal (.lit {n}.sourceKind)))
    (protoNote : constructor.roles 1 = some (.literal (.lit {n}.sourceProto)))
    (owned : H {n}.sourceHandle) (region : R.region (4*{n}.sourceHandle) = 4*R.handle {n}.sourceHandle)
    (arrayLive : live aArrayProto) (arrayFixed : R.a aArrayProto = aArrayProto)
    (bufferLive : live aArrayBufferProto) (bufferFixed : R.a aArrayBufferProto = aArrayBufferProto)
    (typedLive : live {n}.sourceTypedProto) (typedFixed : R.a {n}.sourceTypedProto = {n}.sourceTypedProto)
    (controlNote : notes.runtime.control = callNote bufferFnRole bufferThisRole [.ptr (.ext (4*{n}.sourceHandle)) 0,.literal (.lit (F64.zero false)),.literal countMeaning])
    (stackNotes : notes.runtime.stack = argumentFrameNote false 1 (.obj {n}.sourceTypedFn) .undef [] [] {n}.sourceEnv::spreadNote::retNote::blockNote::scopeNote::boundaryNote::callerNotes)
    (targetBound : s.next+3 ≤ 2^64) :
    ∃ result, runC Host.Load.ffi 8 s C = some (result,C) ∧ runC Host.Load.ffi 8 {n}.input C₀ = some ({n}.output,C₀) ∧
      Parametric.StateR (NumberRoles ν₀ ν C₀ C) (VectorHost.NativeRelation ν₀ ν C₀ C nodes boundary objects H N tokens host) R (ShapeCall.tailLive live {n}.input.next) framed before after old old' {n}.output result ∧
      RetainedInventory (ShapeCall.tailNotes notes {n}.input.next (nodes {n}.sourceProducer).shape.valueRoles callerNotes) ν₀ ν C₀ C R (ShapeCall.tailLive live {n}.input.next) {n}.output result ∧
      Inst ν₀ {n}.nextServer C₀ ∧ ProducerAnnotations roots H N nodes objects ∧ ProducerSupport roots H N {n}.output.ffi.mlx ∧
      ProducerSupport (resourceImage R.node (fun i => N i ∧ roots i)) (resourceImage R.handle H) (resourceImage R.node N) result.ffi.mlx := by
    obtain ⟨result,left,right,post,retained,_,_,_,policy',support,targetSupport⟩ := inventory.shape_buffer_spread_return h policy
      {n}.sourceBufferFn {n}.sourceTypedFn {n}.sourceTypedProto {n}.sourceHandle {n}.sourceProducer
      {n}.sourceBufferObject {n}.sourceTypedObject {n}.sourceBufferData {n}.sourceBufferThis constructor
      {n}.sourceNode {n}.sourceCount {n}.sourceKind {n}.sourceProto countMeaning {n}.sourceEnv {n}.sourceBodyEnv {n}.sourceCaller
      bufferFnRole bufferThisRole spreadNote retNote blockNote scopeNote boundaryNote callerNotes
      {n}.source_control {n}.source_stack {n}.source_buffer_read {n}.source_buffer_kind {n}.source_typed_read {n}.source_typed_kind
      {n}.source_kind {n}.source_proto {n}.source_count countClosed capture codeNote protoNote {n}.source_node {n}.source_producer
      owned region arrayLive arrayFixed bufferLive bufferFixed typedLive typedFixed controlNote stackNotes {n}.source_bound targetBound
    rw [{n}.source_endpoint] at left post retained support
    exact ⟨result,right,left,post,retained,{n}.source_servers ▸ inst,policy',support,targetSupport⟩")

/-- A failed shape-tail selection restores every part of Command.State. -/
def elaborateShapeTail (f s initial t next : Syntax) (name : TSyntax `ident) : CommandElabM Unit := do
  let saved : Command.State ← get
  try generateShapeTail f s initial t next name
  catch error =>
    set saved
    throw error

elab "host_retained_shape_tail " f:term ", " s:term " using " initial:term " to " t:term " using " next:term " as " name:ident : command =>
  elaborateShapeTail f.raw s.raw initial.raw t.raw next.raw name

end Host.Ts.Owned.Annotated.Driver
