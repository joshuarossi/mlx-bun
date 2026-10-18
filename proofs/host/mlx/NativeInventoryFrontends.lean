import host.mlx.NativeArrayBufferClosedInventory
import host.mlx.NativeTypedBufferInventory
import host.mlx.NativeShapeSpreadInventory
import host.mlx.NativeMemoryInventory
import host.mlx.NativeTypedArrayInventory
import host.ts.RenameRuntimeSourceCut
import host.ts.RenameRouteDriver

set_option Elab.async false

namespace Host.Ts.Owned.Annotated.Driver
open Lean Elab Command Meta
open Parametric.Driver

private def servers (pre : Lean.Name) (initial next : Syntax) : CommandElabM Unit := liftTermElabM do
  let initial ← Term.elabTermEnsuringType initial (mkConst ``SSrv)
  let next ← Term.elabTermEnsuringType next (mkConst ``SSrv)
  addData (pre ++ `initialServer) (← mkAppM ``numberServer #[initial])
  addData (pre ++ `nextServer) (← mkAppM ``numberServer #[next])

private def header : String := "open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated in\n"

private def sourceFacts (n : String) (facts : List (String × String)) : CommandElabM Unit := do
  for (name,type) in facts do
    Parametric.Driver.emit (header ++ s!"theorem {n}.{name} : {type} := by host_kernel_rfl")
  Parametric.Driver.emit (header ++ s!"theorem {n}.source_bound : {n}.input.next < 2^64 := by decide +kernel")
  Parametric.Driver.emit (header ++ s!"theorem {n}.source_run (C : CSrv) : interpC (step {n}.F {n}.input).run C = some ({n}.output,C) := by host_kernel_rfl")
  Parametric.Driver.emit (header ++ s!"theorem {n}.source_step : interpS (step {n}.F {n}.input).run {n}.initialServer = some ({n}.output,{n}.nextServer) := by host_kernel_rfl")

/-- Select the original Bun external-buffer allocation. Current fixed literal
expression notes supply ABI counts through valuation-independent certificates. -/
elab "host_retained_arrayBuffer " f:term ", " s:term " using " initial:term " to " t:term " using " next:term " as " name:ident : command => do
  let pre := (← getCurrNamespace) ++ name.getId
  liftTermElabM do
    let f ← Term.elabTermEnsuringType f (mkConst ``Ffi)
    let stateTy := mkApp (mkConst ``St) (mkApp (mkConst ``Ffi.S) f)
    let s ← Term.elabTermEnsuringType s stateTy
    let t ← Term.elabTermEnsuringType t stateTy
    let ctl ← whnf (← mkAppM ``St.ctl #[s])
    unless ctl.isAppOfArity ``Ctl.call 3 do throwError "host_retained_arrayBuffer: expected source native call"
    let address ← field ctl.getAppArgs[0]! ``Val.obj 1 0
    let object ← field (← mkAppM ``St.obj? #[s,address]) ``Option.some 2 1
    let code ← whnf (← field (← mkAppM ``Obj.kind #[object]) ``Kind.fn 1 0)
    let native ← whnf (← field code ``Code.native 2 0)
    let builtin ← field native ``Native.ffi 1 0
    unless (← whnf builtin).isConstOf ``FfiN.toArrayBuffer do
      throwError "host_retained_arrayBuffer: source callee is not Bun.toArrayBuffer"
    let values := ctl.getAppArgs[2]!
    let pointer ← field values ``List.cons 3 1
    let pointer ← whnf pointer
    unless pointer.isAppOfArity ``Val.ptr 2 do throwError "host_retained_arrayBuffer: expected external pointer"
    let region ← field pointer.getAppArgs[0]! ``Mem.ext 1 0
    let rest ← field values ``List.cons 3 2
    let offset ← field (← field (← field rest ``List.cons 3 1) ``Val.num 1 0) ``NumV.lit 1 0
    let rest ← field rest ``List.cons 3 2
    let count ← field (← field (← field rest ``List.cons 3 1) ``Val.num 1 0) ``NumV.lit 1 0
    unless (← whnf (← field rest ``List.cons 3 2)).isAppOfArity ``List.nil 1 do
      throwError "host_retained_arrayBuffer: expected exactly three source arguments"
    let off ← field (← mkAppM ``F64.toIndex? #[offset]) ``Option.some 2 1
    let countIndex ← field (← mkAppM ``F64.toIndex? #[count]) ``Option.some 2 1
    for (tag,value) in [("F",f),("input",s),("output",t),("address",address),("object",object),
      ("sourceData",code.getAppArgs[1]!),("sourceThis",ctl.getAppArgs[1]!),
      ("region",region),("origin",pointer.getAppArgs[1]!),("offset",offset),("count",count),
      ("offsetIndex",off),("countIndex",countIndex)] do
      let type? := if tag == "input" || tag == "output" then
        some (mkApp (mkConst ``St) (mkApp (mkConst ``Ffi.S) (mkConst (pre ++ `F)))) else none
      addData (pre ++ Name.mkSimple tag) value type?
  servers pre initial.raw next.raw
  let n := "_root_." ++ pre.toString
  sourceFacts n [
    ("source_control",s!"{n}.input.ctl = .call (.obj {n}.address) {n}.sourceThis [.ptr (.ext {n}.region) {n}.origin,.num (.lit {n}.offset),.num (.lit {n}.count)]"),
    ("source_heap",s!"{n}.input.heap.get {n}.address = some (.obj {n}.object)"),
    ("source_kind",s!"{n}.object.kind = .fn (.native (.ffi .toArrayBuffer) {n}.sourceData)"),
    ("offset_index",s!"F64.toIndex? {n}.offset = some {n}.offsetIndex"),
    ("count_index",s!"F64.toIndex? {n}.count = some {n}.countIndex")]
  Parametric.Driver.emit (header ++ s!"theorem {n}.retained_transport
      (notes : RetainedNotes) (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
      (FR : Ren → {n}.F.S → {n}.F.S → Prop) (live framed : Nat → Prop) (before after : List Val) (old old' : List Event)
      (s : St {n}.F.S) (inst : Inst ν₀ {n}.initialServer C₀)
      (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' {n}.input s)
      (inventory : RetainedInventory notes ν₀ ν C₀ C R live {n}.input s)
      (offsetMeaning countMeaning : SymE) (fnRole thisRole pointerRole : Annotated.Value)
      (controlNote : notes.runtime.control = callNote fnRole thisRole [pointerRole,.literal offsetMeaning,.literal countMeaning])
      (offsetClosed : ∀ valuation, offsetMeaning.eval valuation = {n}.offset)
      (countClosed : ∀ valuation, countMeaning.eval valuation = {n}.count)
      (protoLive : live aArrayBufferProto) (protoFixed : R.a aArrayBufferProto = aArrayBufferProto)
      (targetBound : s.next < 2^64) :
      ∃ result, interpC (step {n}.F {n}.input).run C₀ = some ({n}.output,C₀) ∧
        interpC (step {n}.F s).run C = some (result,C) ∧
        Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R (LiveAfter live {n}.input.next)
          framed before after old old' {n}.output result ∧
        RetainedInventory (notes.withRuntime ⟨returnNote (.obj {n}.input.next),notes.runtime.stack,notes.runtime.cells⟩)
          ν₀ ν C₀ C R (LiveAfter live {n}.input.next) {n}.output result ∧
        Inst ν₀ {n}.nextServer C₀ := by
      obtain ⟨left,right,post,retained,_⟩ := inventory.toArrayBuffer_closed_step {n}.F FR h
        {n}.address {n}.object {n}.sourceData {n}.sourceThis {n}.region {n}.origin {n}.offsetIndex {n}.countIndex
        {n}.offset {n}.count offsetMeaning countMeaning fnRole thisRole pointerRole {n}.source_control
        {n}.source_heap {n}.source_kind {n}.offset_index {n}.count_index controlNote offsetClosed countClosed
        protoLive protoFixed {n}.source_bound targetBound
      have source := {n}.source_run C₀
      have same := congrArg Prod.fst (Option.some.inj (left.symm.trans source))
      dsimp only at same
      rw [same] at post retained
      exact ⟨_,source,right,post,retained,pure_step_inst {n}.F ν₀ {n}.initialServer {n}.nextServer C₀
        {n}.input {n}.output inst {n}.source_step source⟩")

/-- Select the actual typed external-buffer constructor, retaining the builtin
capture annotations that establish its code and prototype literals. -/
elab "host_retained_typedBuffer " f:term ", " s:term " using " initial:term " to " t:term " using " next:term " as " name:ident : command => do
  let pre := (← getCurrNamespace) ++ name.getId
  liftTermElabM do
    let f ← Term.elabTermEnsuringType f (mkConst ``Ffi)
    let stateTy := mkApp (mkConst ``St) (mkApp (mkConst ``Ffi.S) f)
    let s ← Term.elabTermEnsuringType s stateTy
    let t ← Term.elabTermEnsuringType t stateTy
    let ctl ← whnf (← mkAppM ``St.ctl #[s])
    unless ctl.isAppOfArity ``Ctl.construct 3 do throwError "host_retained_typedBuffer: expected source construct"
    let address ← field ctl.getAppArgs[0]! ``Val.obj 1 0
    let values := ctl.getAppArgs[1]!
    let buffer ← field (← field values ``List.cons 3 1) ``Val.obj 1 0
    unless (← whnf (← field values ``List.cons 3 2)).isAppOfArity ``List.nil 1 do
      throwError "host_retained_typedBuffer: expected exactly one source buffer argument"
    let object ← field (← mkAppM ``St.obj? #[s,address]) ``Option.some 2 1
    let code ← whnf (← field (← mkAppM ``Obj.kind #[object]) ``Kind.fn 1 0)
    let native ← whnf (← field code ``Code.native 2 0)
    let builtin ← field native ``Native.buf 1 0
    unless (← whnf builtin).isConstOf ``BufN.typedCtor do
      throwError "host_retained_typedBuffer: source callee is not typedCtor"
    let data := code.getAppArgs[1]!
    let x ← field (← field (← field data ``List.cons 3 1) ``Val.num 1 0) ``NumV.lit 1 0
    let rest ← field data ``List.cons 3 2
    let y ← field (← field (← field rest ``List.cons 3 1) ``Val.num 1 0) ``NumV.lit 1 0
    unless (← whnf (← field rest ``List.cons 3 2)).isAppOfArity ``List.nil 1 do
      throwError "host_retained_typedBuffer: expected exactly two source builtin captures"
    let codeIndex ← field (← mkAppM ``F64.toIndex? #[x]) ``Option.some 2 1
    let protoIndex ← field (← mkAppM ``F64.toIndex? #[y]) ``Option.some 2 1
    let backing ← field (← mkAppM ``St.obj? #[s,buffer]) ``Option.some 2 1
    let kind ← whnf (← mkAppM ``Obj.kind #[backing])
    unless kind.isAppOfArity ``Kind.extBuf 3 do throwError "host_retained_typedBuffer: expected source external backing buffer"
    for (tag,value) in [("F",f),("input",s),("output",t),("address",address),("object",object),
      ("buffer",buffer),("backing",backing),("newTarget",ctl.getAppArgs[2]!),
      ("region",kind.getAppArgs[0]!),("origin",kind.getAppArgs[1]!),("count",kind.getAppArgs[2]!),
      ("codeLiteral",x),("protoLiteral",y),("codeIndex",codeIndex),("protoIndex",protoIndex)] do
      let type? := if tag == "input" || tag == "output" then
        some (mkApp (mkConst ``St) (mkApp (mkConst ``Ffi.S) (mkConst (pre ++ `F)))) else none
      addData (pre ++ Name.mkSimple tag) value type?
  servers pre initial.raw next.raw
  let n := "_root_." ++ pre.toString
  sourceFacts n [
    ("source_control",s!"{n}.input.ctl = .construct (.obj {n}.address) [.obj {n}.buffer] {n}.newTarget"),
    ("source_heap",s!"{n}.input.heap.get {n}.address = some (.obj {n}.object)"),
    ("source_kind",s!"{n}.object.kind = .fn (.native (.buf .typedCtor) [.num (.lit {n}.codeLiteral),.num (.lit {n}.protoLiteral)])"),
    ("source_buffer",s!"{n}.input.heap.get {n}.buffer = some (.obj {n}.backing)"),
    ("source_buffer_kind",s!"{n}.backing.kind = .extBuf {n}.region {n}.origin {n}.count"),
    ("code_index",s!"F64.toIndex? {n}.codeLiteral = some {n}.codeIndex"),
    ("proto_index",s!"F64.toIndex? {n}.protoLiteral = some {n}.protoIndex")]
  Parametric.Driver.emit (header ++ s!"theorem {n}.retained_transport
      (notes : RetainedNotes) (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
      (FR : Ren → {n}.F.S → {n}.F.S → Prop) (live framed : Nat → Prop) (before after : List Val) (old old' : List Event)
      (s : St {n}.F.S) (inst : Inst ν₀ {n}.initialServer C₀)
      (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' {n}.input s)
      (inventory : RetainedInventory notes ν₀ ν C₀ C R live {n}.input s)
      (metadata : NativeCaptureNote) (selected : notes.captures.owners {n}.address = some metadata)
      (codeNote : metadata.roles 0 = some (.literal (.lit {n}.codeLiteral)))
      (protoNote : metadata.roles 1 = some (.literal (.lit {n}.protoLiteral)))
      (protoLive : live {n}.protoIndex) (protoFixed : R.a {n}.protoIndex = {n}.protoIndex)
      (targetBound : s.next < 2^64) :
      ∃ result, interpC (step {n}.F {n}.input).run C₀ = some ({n}.output,C₀) ∧
        interpC (step {n}.F s).run C = some (result,C) ∧
        Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R (LiveAfter live {n}.input.next)
          framed before after old old' {n}.output result ∧
        RetainedInventory (notes.withRuntime ⟨returnNote (.obj {n}.input.next),notes.runtime.stack,notes.runtime.cells⟩)
          ν₀ ν C₀ C R (LiveAfter live {n}.input.next) {n}.output result ∧
        Inst ν₀ {n}.nextServer C₀ := by
      obtain ⟨left,right,post,retained,_⟩ := inventory.typedBuffer_step {n}.F FR h
        {n}.address {n}.buffer {n}.object {n}.backing {n}.newTarget {n}.region {n}.origin {n}.count
        {n}.codeIndex {n}.protoIndex {n}.codeLiteral {n}.protoLiteral metadata
        {n}.source_control {n}.source_heap {n}.source_kind {n}.source_buffer {n}.source_buffer_kind
        {n}.code_index {n}.proto_index selected codeNote protoNote protoLive protoFixed {n}.source_bound targetBound
      have source := {n}.source_run C₀
      have same := congrArg Prod.fst (Option.some.inj (left.symm.trans source))
      dsimp only at same
      rw [same] at post retained
      exact ⟨_,source,right,post,retained,pure_step_inst {n}.F ν₀ {n}.initialServer {n}.nextServer C₀
        {n}.input {n}.output inst {n}.source_step source⟩")

/-- Select the final spread of an owned Int32 shape view. Its source carrier
fixes the dimension annotations; all target memory reads are derived. -/
elab "host_retained_shapeSpread " f:term ", " s:term " using " initial:term " to " t:term " using " next:term " as " name:ident : command => do
  let pre := (← getCurrNamespace) ++ name.getId
  liftTermElabM do
    let f ← Term.elabTermEnsuringType f (mkConst ``Ffi)
    unless ← isDefEq f (mkConst ``Host.Load.ffi) do
      throwError "host_retained_shapeSpread: expected the original load FFI"
    let stateTy := mkApp (mkConst ``St) (mkApp (mkConst ``Ffi.S) f)
    let s ← Term.elabTermEnsuringType s stateTy
    let t ← Term.elabTermEnsuringType t stateTy
    let ctl ← whnf (← mkAppM ``St.ctl #[s])
    let view ← field (← field ctl ``Ctl.ret 1 0) ``Val.obj 1 0
    let stack ← mkAppM ``St.stack #[s]
    let frame ← field stack ``List.cons 3 1
    let frames ← field stack ``List.cons 3 2
    let spread ← whnf (← field frame ``Frame.l 1 0)
    unless spread.isAppOfArity ``LitF.spread 3 do throwError "host_retained_shapeSpread: expected source spread frame"
    unless (← whnf spread.getAppArgs[0]!).isAppOfArity ``List.nil 1 &&
        (← whnf spread.getAppArgs[1]!).isAppOfArity ``List.nil 1 do
      throwError "host_retained_shapeSpread: expected final empty spread continuation"
    let object ← field (← mkAppM ``St.obj? #[s,view]) ``Option.some 2 1
    let viewKind ← whnf (← mkAppM ``Obj.kind #[object])
    unless viewKind.isAppOfArity ``Kind.typed 4 do throwError "host_retained_shapeSpread: expected source typed view"
    unless (← whnf viewKind.getAppArgs[0]!).isConstOf ``EltK.i32 do
      throwError "host_retained_shapeSpread: expected Int32 shape view"
    let buffer := viewKind.getAppArgs[1]!
    let backing ← field (← mkAppM ``St.obj? #[s,buffer]) ``Option.some 2 1
    let backingKind ← whnf (← mkAppM ``Obj.kind #[backing])
    unless backingKind.isAppOfArity ``Kind.extBuf 3 do throwError "host_retained_shapeSpread: expected source native shape region"
    let handle ← whnf (← mkAppM ``Nat.div #[backingKind.getAppArgs[0]!,mkRawNatLit 4])
    let native ← mkAppM ``Host.Load.LSt.mlx #[← mkAppM ``St.ffi #[s]]
    let node ← field (← mkAppM ``Host.Mlx.Ffi.St.node? #[native,handle]) ``Option.some 2 1
    let arrs ← mkAppM ``Host.Mlx.Ffi.St.arrs #[native]
    let index ← field (← mkAppM ``PTrie.get #[arrs,handle]) ``Option.some 2 1
    for (tag,value) in [("F",f),("input",s),("output",t),("view",view),("object",object),("buffer",buffer),
      ("backing",backing),("handle",handle),("sourceNode",node),("sourceIndex",index),
      ("sourceEnv",spread.getAppArgs[2]!),("sourceTail",frames)] do
      let type? := if tag == "input" || tag == "output" then
        some (mkApp (mkConst ``St) (mkApp (mkConst ``Ffi.S) (mkConst (pre ++ `F)))) else none
      addData (pre ++ Name.mkSimple tag) value type?
  servers pre initial.raw next.raw
  let n := "_root_." ++ pre.toString
  sourceFacts n [
    ("source_control",s!"{n}.input.ctl = .ret (.obj {n}.view)"),
    ("source_frame",s!"{n}.input.stack = .l (.spread [] [] {n}.sourceEnv)::{n}.sourceTail"),
    ("source_view",s!"{n}.input.heap.get {n}.view = some (.obj {n}.object)"),
    ("source_view_kind",s!"{n}.object.kind = .typed .i32 {n}.buffer 0 (len {n}.sourceNode.shape)"),
    ("source_buffer",s!"{n}.input.heap.get {n}.buffer = some (.obj {n}.backing)"),
    ("source_buffer_kind",s!"{n}.backing.kind = .extBuf (4*{n}.handle) 0 (len {n}.sourceNode.shape*4)"),
    ("source_node",s!"{n}.input.ffi.mlx.node? {n}.handle = some {n}.sourceNode"),
    ("source_index",s!"{n}.input.ffi.mlx.arrs.get {n}.handle = some {n}.sourceIndex")]
  Parametric.Driver.emit (header ++ s!"theorem {n}.retained_transport
      (notes : RetainedNotes) (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
      (FR : Ren → {n}.F.S → {n}.F.S → Prop) (live framed : Nat → Prop) (before after : List Val) (old old' : List Event)
      (s : St {n}.F.S) (inst : Inst ν₀ {n}.initialServer C₀)
      (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' {n}.input s)
      (inventory : RetainedInventory notes ν₀ ν C₀ C R live {n}.input s)
      (roles : Nat → Host.Mlx.Ffi.Annotated.GraphNode)
      (ObjRel : Nat → Host.Mlx.Ffi.Obj → Host.Mlx.Ffi.Obj → Prop)
      (boundary H N : Nat → Prop) (tail : List NumV)
      (native : Host.Mlx.Ffi.NativeRoles.Live (NumberRoles ν₀ ν C₀ C) R
        (Host.Mlx.Ffi.Annotated.NodeRel roles ν₀ ν C₀ C R boundary) ObjRel H N tail {n}.input.ffi.mlx s.ffi.mlx)
      (handleLive : H {n}.handle) (region : R.region (4*{n}.handle) = 4*R.handle {n}.handle)
      (protoLive : live aArrayProto) (protoFixed : R.a aArrayProto = aArrayProto) (targetBound : s.next < 2^64) :
      ∃ result, interpC (step {n}.F {n}.input).run C₀ = some ({n}.output,C₀) ∧
        interpC (step {n}.F s).run C = some (result,C) ∧
        Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R (LiveAfter live {n}.input.next)
          framed before after old old' {n}.output result ∧
        RetainedInventory (notes.shapeSpread {n}.input.next (roles {n}.sourceIndex).shape.valueRoles)
          ν₀ ν C₀ C R (LiveAfter live {n}.input.next) {n}.output result ∧
        Inst ν₀ {n}.nextServer C₀ := by
      obtain ⟨i,node,frames,index,_,nodeRole,left,right,post,retained⟩ := inventory.shape_spread_step FR h
        roles ObjRel boundary H N tail native {n}.view {n}.buffer {n}.handle {n}.object {n}.backing
        {n}.sourceNode {n}.sourceEnv {n}.sourceTail {n}.source_control {n}.source_frame {n}.source_view
        {n}.source_view_kind {n}.source_buffer {n}.source_buffer_kind {n}.source_node handleLive region
        protoLive protoFixed {n}.source_bound targetBound
      have indexSame : i = {n}.sourceIndex := Option.some.inj (index.symm.trans {n}.source_index)
      subst i
      have source := {n}.source_run C₀
      have same := congrArg Prod.fst (Option.some.inj (left.symm.trans source))
      dsimp only at same
      rw [same] at post retained
      exact ⟨_,source,right,post,retained,pure_step_inst {n}.F ν₀ {n}.initialServer {n}.nextServer C₀
        {n}.input {n}.output inst {n}.source_step source⟩")

/-- Select the real Bun pointer builtin over a nonempty typed JS buffer. -/
elab "host_retained_pointer " f:term ", " s:term " using " initial:term " to " t:term " using " next:term " as " name:ident : command => do
  let pre := (← getCurrNamespace) ++ name.getId
  liftTermElabM do
    let f ← Term.elabTermEnsuringType f (mkConst ``Ffi)
    let stateTy := mkApp (mkConst ``St) (mkApp (mkConst ``Ffi.S) f)
    let s ← Term.elabTermEnsuringType s stateTy
    let t ← Term.elabTermEnsuringType t stateTy
    let ctl ← whnf (← mkAppM ``St.ctl #[s])
    unless ctl.isAppOfArity ``Ctl.call 3 do throwError "host_retained_pointer: expected source call"
    let address ← field ctl.getAppArgs[0]! ``Val.obj 1 0
    let object ← field (← mkAppM ``St.obj? #[s,address]) ``Option.some 2 1
    let code ← whnf (← field (← mkAppM ``Obj.kind #[object]) ``Kind.fn 1 0)
    let native ← whnf (← field code ``Code.native 2 0)
    let builtin ← field native ``Native.ffi 1 0
    unless (← whnf builtin).isConstOf ``FfiN.ptr do throwError "host_retained_pointer: expected Bun.ptr callee"
    let values := ctl.getAppArgs[2]!
    let view ← field (← field values ``List.cons 3 1) ``Val.obj 1 0
    unless (← whnf (← field values ``List.cons 3 2)).isAppOfArity ``List.nil 1 do
      throwError "host_retained_pointer: expected exactly one source argument"
    let viewObject ← field (← mkAppM ``St.obj? #[s,view]) ``Option.some 2 1
    let viewKind ← whnf (← mkAppM ``Obj.kind #[viewObject])
    unless viewKind.isAppOfArity ``Kind.typed 4 do throwError "host_retained_pointer: expected source typed view"
    let buffer := viewKind.getAppArgs[1]!
    let backing ← field (← mkAppM ``St.obj? #[s,buffer]) ``Option.some 2 1
    let bytes ← field (← mkAppM ``Obj.kind #[backing]) ``Kind.buf 1 0
    for (tag,value) in [("F",f),("input",s),("output",t),("address",address),("object",object),
      ("sourceData",code.getAppArgs[1]!),("sourceThis",ctl.getAppArgs[1]!),("view",view),("viewObject",viewObject),
      ("buffer",buffer),("backing",backing),("bytes",bytes),("elementKind",viewKind.getAppArgs[0]!),
      ("offset",viewKind.getAppArgs[2]!),("count",viewKind.getAppArgs[3]!)] do
      let type? := if tag == "input" || tag == "output" then
        some (mkApp (mkConst ``St) (mkApp (mkConst ``Ffi.S) (mkConst (pre ++ `F)))) else none
      addData (pre ++ Name.mkSimple tag) value type?
  servers pre initial.raw next.raw
  let n := "_root_." ++ pre.toString
  sourceFacts n [
    ("source_control",s!"{n}.input.ctl = .call (.obj {n}.address) {n}.sourceThis [.obj {n}.view]"),
    ("source_heap",s!"{n}.input.heap.get {n}.address = some (.obj {n}.object)"),
    ("source_kind",s!"{n}.object.kind = .fn (.native (.ffi .ptr) {n}.sourceData)"),
    ("source_view",s!"{n}.input.heap.get {n}.view = some (.obj {n}.viewObject)"),
    ("source_view_kind",s!"{n}.viewObject.kind = .typed {n}.elementKind {n}.buffer {n}.offset {n}.count"),
    ("source_buffer",s!"{n}.input.heap.get {n}.buffer = some (.obj {n}.backing)"),
    ("source_buffer_kind",s!"{n}.backing.kind = .buf {n}.bytes")]
  Parametric.Driver.emit (header ++ s!"theorem {n}.source_nonempty : {n}.count ≠ 0 := by decide +kernel")
  Parametric.Driver.emit (header ++ s!"theorem {n}.retained_transport
      (notes : RetainedNotes) (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
      (FR : Ren → {n}.F.S → {n}.F.S → Prop) (live framed : Nat → Prop) (before after : List Val) (old old' : List Event)
      (s : St {n}.F.S) (inst : Inst ν₀ {n}.initialServer C₀)
      (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' {n}.input s)
      (inventory : RetainedInventory notes ν₀ ν C₀ C R live {n}.input s) :
      ∃ result, interpC (step {n}.F {n}.input).run C₀ = some ({n}.output,C₀) ∧
        interpC (step {n}.F s).run C = some (result,C) ∧
        Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' {n}.output result ∧
        RetainedInventory (notes.withRuntime ⟨returnNote (.ptr (.js {n}.buffer) {n}.offset),notes.runtime.stack,notes.runtime.cells⟩)
          ν₀ ν C₀ C R live {n}.output result ∧ Inst ν₀ {n}.nextServer C₀ := by
      obtain ⟨left,right,post,retained⟩ := inventory.pointer_step {n}.F FR h
        {n}.address {n}.view {n}.buffer {n}.offset {n}.count {n}.object {n}.viewObject {n}.backing {n}.elementKind
        {n}.sourceData {n}.sourceThis {n}.bytes {n}.source_control {n}.source_heap {n}.source_kind {n}.source_view
        {n}.source_view_kind {n}.source_buffer {n}.source_buffer_kind {n}.source_nonempty
      have source := {n}.source_run C₀
      have same := congrArg Prod.fst (Option.some.inj (left.symm.trans source))
      dsimp only at same
      rw [same] at post retained
      exact ⟨_,source,right,post,retained,pure_step_inst {n}.F ν₀ {n}.initialServer {n}.nextServer C₀
        {n}.input {n}.output inst {n}.source_step source⟩")

/-- Select an owned-handle read from a slot whose current fixed byte notes
were established by initialization or a preceding checked native write. -/
elab "host_retained_readU64 " f:term ", " s:term " using " initial:term " to " t:term " using " next:term " as " name:ident : command => do
  let pre := (← getCurrNamespace) ++ name.getId
  liftTermElabM do
    let f ← Term.elabTermEnsuringType f (mkConst ``Ffi)
    let stateTy := mkApp (mkConst ``St) (mkApp (mkConst ``Ffi.S) f)
    let s ← Term.elabTermEnsuringType s stateTy
    let t ← Term.elabTermEnsuringType t stateTy
    let ctl ← whnf (← mkAppM ``St.ctl #[s])
    unless ctl.isAppOfArity ``Ctl.call 3 do throwError "host_retained_readU64: expected source call"
    let address ← field ctl.getAppArgs[0]! ``Val.obj 1 0
    let object ← field (← mkAppM ``St.obj? #[s,address]) ``Option.some 2 1
    let code ← whnf (← field (← mkAppM ``Obj.kind #[object]) ``Kind.fn 1 0)
    let native ← whnf (← field code ``Code.native 2 0)
    let builtin ← field native ``Native.ffi 1 0
    unless (← whnf builtin).isConstOf ``FfiN.readU64 do throwError "host_retained_readU64: expected Bun.read.u64 callee"
    let values := ctl.getAppArgs[2]!
    let pointer ← whnf (← field values ``List.cons 3 1)
    unless pointer.isAppOfArity ``Val.ptr 2 do throwError "host_retained_readU64: expected source JS pointer"
    let buffer ← field pointer.getAppArgs[0]! ``Mem.js 1 0
    for (tag,value) in [("F",f),("input",s),("output",t),("address",address),("object",object),
      ("sourceData",code.getAppArgs[1]!),("sourceThis",ctl.getAppArgs[1]!),("buffer",buffer)] do
      let type? := if tag == "input" || tag == "output" then
        some (mkApp (mkConst ``St) (mkApp (mkConst ``Ffi.S) (mkConst (pre ++ `F)))) else none
      addData (pre ++ Name.mkSimple tag) value type?
  servers pre initial.raw next.raw
  let n := "_root_." ++ pre.toString
  sourceFacts n [
    ("source_control",s!"{n}.input.ctl = .call (.obj {n}.address) {n}.sourceThis [.ptr (.js {n}.buffer) 0,.num zeroN]"),
    ("source_heap",s!"{n}.input.heap.get {n}.address = some (.obj {n}.object)"),
    ("source_kind",s!"{n}.object.kind = .fn (.native (.ffi .readU64) {n}.sourceData)")]
  Parametric.Driver.emit (header ++ s!"theorem {n}.retained_transport
      (notes : RetainedNotes) (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
      (FR : Ren → {n}.F.S → {n}.F.S → Prop) (live framed : Nat → Prop) (before after : List Val) (old old' : List Event)
      (s : St {n}.F.S) (inst : Inst ν₀ {n}.initialServer C₀)
      (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' {n}.input s)
      (inventory : RetainedInventory notes ν₀ ν C₀ C R live {n}.input s)
      (handle : Nat) (fnRole thisRole : Annotated.Value)
      (controlNote : notes.runtime.control = callNote fnRole thisRole
        ([FixedArgument.pointer {n}.buffer 0,FixedArgument.literal (F64.zero false)].map FixedArgument.role))
      (selected : notes.buffers.owners {n}.buffer = some (handleSlotNotes handle)) :
      ∃ result, interpC (step {n}.F {n}.input).run C₀ = some ({n}.output,C₀) ∧
        interpC (step {n}.F s).run C = some (result,C) ∧
        Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' {n}.output result ∧
        RetainedInventory (notes.withRuntime ⟨returnNote (.handle handle),notes.runtime.stack,notes.runtime.cells⟩)
          ν₀ ν C₀ C R live {n}.output result ∧ Inst ν₀ {n}.nextServer C₀ := by
      obtain ⟨left,right,post,retained⟩ := inventory.read_handle_step {n}.F FR h
        {n}.address {n}.buffer handle {n}.object {n}.sourceData {n}.sourceThis fnRole thisRole
        {n}.source_control {n}.source_heap {n}.source_kind controlNote selected
      have source := {n}.source_run C₀
      have same := congrArg Prod.fst (Option.some.inj (left.symm.trans source))
      dsimp only at same
      rw [same] at post retained
      exact ⟨_,source,right,post,retained,pure_step_inst {n}.F ν₀ {n}.initialServer {n}.nextServer C₀
        {n}.input {n}.output inst {n}.source_step source⟩")

/-- Select the original BigUint64Array([0n]) initialization. Fixed array and
builtin capture notes establish its operand meanings, and native Live fixes
the null handle before byte notes are installed at the fresh buffer owner. -/
elab "host_retained_nullTyped " f:term ", " s:term " using " initial:term " to " t:term " using " next:term " as " name:ident : command => do
  let pre := (← getCurrNamespace) ++ name.getId
  liftTermElabM do
    let f ← Term.elabTermEnsuringType f (mkConst ``Ffi)
    unless ← isDefEq f (mkConst ``Host.Load.ffi) do throwError "host_retained_nullTyped: expected original load FFI"
    let stateTy := mkApp (mkConst ``St) (mkApp (mkConst ``Ffi.S) f)
    let s ← Term.elabTermEnsuringType s stateTy
    let t ← Term.elabTermEnsuringType t stateTy
    let ctl ← whnf (← mkAppM ``St.ctl #[s])
    unless ctl.isAppOfArity ``Ctl.construct 3 do throwError "host_retained_nullTyped: expected source construct"
    let address ← field ctl.getAppArgs[0]! ``Val.obj 1 0
    let values := ctl.getAppArgs[1]!
    let arrayOwner ← field (← field values ``List.cons 3 1) ``Val.obj 1 0
    unless (← whnf (← field values ``List.cons 3 2)).isAppOfArity ``List.nil 1 do
      throwError "host_retained_nullTyped: expected exactly one source argument"
    let object ← field (← mkAppM ``St.obj? #[s,address]) ``Option.some 2 1
    let code ← whnf (← field (← mkAppM ``Obj.kind #[object]) ``Kind.fn 1 0)
    let native ← whnf (← field code ``Code.native 2 0)
    let builtin ← field native ``Native.buf 1 0
    unless (← whnf builtin).isConstOf ``BufN.typedCtor do throwError "host_retained_nullTyped: expected typedCtor callee"
    let data := code.getAppArgs[1]!
    let x ← field (← field (← field data ``List.cons 3 1) ``Val.num 1 0) ``NumV.lit 1 0
    let rest ← field data ``List.cons 3 2
    let y ← field (← field (← field rest ``List.cons 3 1) ``Val.num 1 0) ``NumV.lit 1 0
    unless (← whnf (← field rest ``List.cons 3 2)).isAppOfArity ``List.nil 1 do
      throwError "host_retained_nullTyped: expected exactly two source builtin captures"
    let proto ← field (← mkAppM ``F64.toIndex? #[y]) ``Option.some 2 1
    let arrayObject ← field (← mkAppM ``St.obj? #[s,arrayOwner]) ``Option.some 2 1
    let _ ← field (← mkAppM ``Obj.kind #[arrayObject]) ``Kind.array 1 0
    for (tag,value) in [("F",f),("input",s),("output",t),("address",address),("object",object),
      ("arrayOwner",arrayOwner),("arrayObject",arrayObject),("newTarget",ctl.getAppArgs[2]!),
      ("codeLiteral",x),("protoLiteral",y),("protoIndex",proto)] do
      let type? := if tag == "input" || tag == "output" then
        some (mkApp (mkConst ``St) (mkApp (mkConst ``Ffi.S) (mkConst (pre ++ `F)))) else none
      addData (pre ++ Name.mkSimple tag) value type?
  servers pre initial.raw next.raw
  let n := "_root_." ++ pre.toString
  sourceFacts n [
    ("source_control",s!"{n}.input.ctl = .construct (.obj {n}.address) [.obj {n}.arrayOwner] {n}.newTarget"),
    ("source_heap",s!"{n}.input.heap.get {n}.address = some (.obj {n}.object)"),
    ("source_kind",s!"{n}.object.kind = .fn (.native (.buf .typedCtor) [.num (.lit {n}.codeLiteral),.num (.lit {n}.protoLiteral)])"),
    ("source_array",s!"{n}.input.heap.get {n}.arrayOwner = some (.obj {n}.arrayObject)"),
    ("source_elements",s!"{n}.arrayObject.kind = .array [.big 0]"),
    ("code_index",s!"F64.toIndex? {n}.codeLiteral = some 9"),
    ("proto_index",s!"F64.toIndex? {n}.protoLiteral = some {n}.protoIndex")]
  Parametric.Driver.emit (header ++ s!"theorem {n}.source_typed_bound : {n}.input.next+1 < 2^64 := by decide +kernel")
  Parametric.Driver.emit (header ++ s!"theorem {n}.retained_transport
      (notes : RetainedNotes) (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
      (FR : Ren → {n}.F.S → {n}.F.S → Prop) (live framed : Nat → Prop) (before after : List Val) (old old' : List Event)
      (s : St {n}.F.S) (inst : Inst ν₀ {n}.initialServer C₀)
      (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' {n}.input s)
      (inventory : RetainedInventory notes ν₀ ν C₀ C R live {n}.input s)
      (NodeRelation : Nat → Host.Mlx.Ffi.Node → Host.Mlx.Ffi.Node → Prop)
      (ObjectRelation : Nat → Host.Mlx.Ffi.Obj → Host.Mlx.Ffi.Obj → Prop) (H N : Nat → Prop) (tail : List NumV)
      (native : Host.Mlx.Ffi.NativeRoles.Live (NumberRoles ν₀ ν C₀ C) R NodeRelation ObjectRelation H N tail
        {n}.input.ffi.mlx s.ffi.mlx)
      (metadata : NativeCaptureNote) (selected : notes.captures.owners {n}.address = some metadata)
      (codeNote : metadata.roles 0 = some (.literal (.lit {n}.codeLiteral)))
      (protoNote : metadata.roles 1 = some (.literal (.lit {n}.protoLiteral)))
      (elements : notes.arrays.owners {n}.arrayOwner = some [.ordinaryBig 0])
      (bufferProtoLive : live aArrayBufferProto) (bufferProtoFixed : R.a aArrayBufferProto = aArrayBufferProto)
      (protoLive : live {n}.protoIndex) (protoFixed : R.a {n}.protoIndex = {n}.protoIndex)
      (targetBound : s.next+1 < 2^64) :
      ∃ result, interpC (step {n}.F {n}.input).run C₀ = some ({n}.output,C₀) ∧
        interpC (step {n}.F s).run C = some (result,C) ∧
        Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R (LiveAfter (LiveAfter live {n}.input.next) ({n}.input.next+1))
          framed before after old old' {n}.output result ∧
        RetainedInventory (notes.nullTyped {n}.input.next) ν₀ ν C₀ C R
          (LiveAfter (LiveAfter live {n}.input.next) ({n}.input.next+1)) {n}.output result ∧ Inst ν₀ {n}.nextServer C₀ := by
      obtain ⟨left,right,post,retained⟩ := inventory.typedArray_null_step FR h native
        {n}.address {n}.arrayOwner {n}.protoIndex {n}.object {n}.newTarget {n}.codeLiteral {n}.protoLiteral metadata
        {n}.source_control {n}.source_heap {n}.source_kind {n}.code_index {n}.proto_index
        selected codeNote protoNote elements bufferProtoLive bufferProtoFixed protoLive protoFixed {n}.source_typed_bound targetBound
      have source := {n}.source_run C₀
      have same := congrArg Prod.fst (Option.some.inj (left.symm.trans source))
      dsimp only at same
      rw [same] at post retained
      exact ⟨_,source,right,post,retained,pure_step_inst {n}.F ν₀ {n}.initialServer {n}.nextServer C₀
        {n}.input {n}.output inst {n}.source_step source⟩")

end Host.Ts.Owned.Annotated.Driver
