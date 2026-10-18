import host.mlx.NativeConfigOutputRetained
import host.ts.RenameRuntimeSourceCut
import host.ts.RenameRuntimeDriverValues

set_option Elab.async false
namespace Host.Ts.Owned.Annotated.Driver
open Lean Elab Command Meta Parametric.Driver

private partial def configOutputIntegers (dimensions : Lean.Expr) : TermElabM Lean.Expr := do
  let dimensions ← whnf dimensions
  if dimensions.isAppOfArity ``List.nil 1 then return toExpr ([] : List Int)
  let head ← field (← field dimensions ``List.cons 3 1) ``Host.Mlx.Ffi.Dim.lit 1 0
  let tail ← configOutputIntegers (← field dimensions ``List.cons 3 2)
  mkAppM ``List.cons #[head,tail]

/-- Decode source metadata only. Output dimension meanings are supplied by
the current coherent byte notes, with exact integer recovery on each side. -/
elab "host_retained_configOutput " f:term ", " s:term " using " initial:term " to " t:term " using " next:term " as " name:ident : command => do
  let pre := (← getCurrNamespace) ++ name.getId
  liftTermElabM do
    let f ← Term.elabTermEnsuringType f (mkConst ``Ffi)
    unless ← isDefEq f (mkConst ``Host.Load.ffi) do throwError "host_retained_configOutput: expected original load FFI"
    let stateTy := mkApp (mkConst ``St) (mkApp (mkConst ``Ffi.S) f)
    let s ← Term.elabTermEnsuringType s stateTy
    let t ← Term.elabTermEnsuringType t stateTy
    let control ← whnf (← mkAppM ``St.ctl #[s])
    unless control.isAppOfArity ``Ctl.call 3 do throwError "host_retained_configOutput: expected source call"
    let fn ← field control.getAppArgs[0]! ``Val.obj 1 0
    let args := control.getAppArgs[2]!
    let handle ← mkAppM ``Int.toNat #[← field (← field args ``List.cons 3 1) ``Val.big 1 0]
    let rest ← field args ``List.cons 3 2
    let buffer ← field (← field (← field rest ``List.cons 3 1) ``Val.ptr 2 0) ``Mem.js 1 0
    let rest ← field rest ``List.cons 3 2
    let count ← mkAppM ``Int.toNat #[← field (← field rest ``List.cons 3 1) ``Val.big 1 0]
    let rest ← field rest ``List.cons 3 2
    let value ← field (← field (← field rest ``List.cons 3 1) ``Val.num 1 0) ``NumV.lit 1 0
    let dtype ← field (← mkAppM ``Host.Mlx.Ffi.argNat #[← mkAppM ``Arg.num #[← mkAppM ``NumV.lit #[value]]]) ``Option.some 2 1
    let function ← field (← mkAppM ``St.obj? #[s,fn]) ``Option.some 2 1
    let code ← whnf (← field (← mkAppM ``Obj.kind #[function]) ``Kind.fn 1 0)
    let captures ← field code ``Code.native 2 1
    let captures ← field captures ``List.cons 3 2
    let types ← field (← field captures ``List.cons 3 1) ``Val.obj 1 0
    let returns ← field (← field (← field captures ``List.cons 3 2) ``List.cons 3 1) ``Val.str 1 0
    let signature ← field (← mkAppM ``St.obj? #[s,types]) ``Option.some 2 1
    let bufferObject ← field (← mkAppM ``St.obj? #[s,buffer]) ``Option.some 2 1
    let bytes ← field (← mkAppM ``Obj.kind #[bufferObject]) ``Kind.buf 1 0
    let shape ← field (← mkAppM ``Host.Mlx.Ffi.dimsArg #[← mkAppM ``Arg.jsPtr #[buffer,mkNatLit 0,bytes],
      ← mkAppM ``Arg.big #[← mkAppM ``Int.ofNat #[count]]]) ``Option.some 2 1
    let integers ← configOutputIntegers shape
    let native ← mkAppM ``Host.Load.LSt.mlx #[← mkAppM ``St.ffi #[s]]
    let config ← field (← field (← mkAppM ``Host.Mlx.Ffi.St.obj? #[native,handle]) ``Option.some 2 1) ``Host.Mlx.Ffi.Obj.cfg 1 0
    for (tag,value) in [("F",f),("input",s),("output",t),("sourceFn",fn),("sourceHandle",handle),
      ("sourceBuffer",buffer),("sourceDtype",dtype),("sourceValue",value),("sourceIntegers",integers),
      ("sourceFunction",function),("sourceTypes",types),("sourceReturns",returns),("sourceSignature",signature),
      ("sourceBufferObject",bufferObject),("sourceBytes",bytes),("sourceConfig",config),("sourceThis",control.getAppArgs[1]!)] do
      addData (pre ++ Name.mkSimple tag) value (if tag == "input" || tag == "output" then some stateTy else none)
    addData (pre ++ `initialServer) (← mkAppM ``numberServer #[← Term.elabTermEnsuringType initial (mkConst ``SSrv)])
    addData (pre ++ `nextServer) (← mkAppM ``numberServer #[← Term.elabTermEnsuringType next (mkConst ``SSrv)])
  let n := "_root_." ++ pre.toString
  let header := "open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated Host.Mlx.Ffi Host.Mlx.Ffi.NativeRoles Host.Mlx.Ffi.Annotated Host.Load.Run.Full.Ordinary in\n"
  for (tag,type) in [
    ("source_control",s!"{n}.input.ctl = .call (.obj {n}.sourceFn) {n}.sourceThis [.big (Int.ofNat {n}.sourceHandle),.ptr (.js {n}.sourceBuffer) 0,.big (Int.ofNat {n}.sourceIntegers.length),.num (.lit {n}.sourceValue)]"),
    ("source_function_read",s!"{n}.input.heap.get {n}.sourceFn = some (.obj {n}.sourceFunction)"),
    ("source_function_kind",s!"{n}.sourceFunction.kind = .fn (.native (.ffi .symbol) [.str ConfigOutputHost.symbol,.obj {n}.sourceTypes,.str {n}.sourceReturns])"),
    ("source_signature_read",s!"{n}.input.heap.get {n}.sourceTypes = some (.obj {n}.sourceSignature)"),
    ("source_signature_kind",s!"{n}.sourceSignature.kind = .array ConfigOutputHost.signature"),
    ("source_buffer_read",s!"{n}.input.heap.get {n}.sourceBuffer = some (.obj {n}.sourceBufferObject)"),
    ("source_buffer_kind",s!"{n}.sourceBufferObject.kind = .buf {n}.sourceBytes"),
    ("source_bytes",s!"{n}.sourceBytes = shapeBytes ({n}.sourceIntegers.map Dim.lit)"),
    ("source_config_read",s!"{n}.input.ffi.mlx.obj? {n}.sourceHandle = some (.cfg {n}.sourceConfig)"),
    ("source_dtype",s!"argNat (.num (.lit {n}.sourceValue)) = some {n}.sourceDtype"),
    ("source_cast",s!"F64.un .int32 {n}.sourceValue = {n}.sourceValue"),
    ("source_servers",s!"{n}.initialServer = {n}.nextServer")]
    do Parametric.Driver.emit (header ++ s!"theorem {n}.{tag} : {type} := by host_kernel_rfl")
  Parametric.Driver.emit (header ++ s!"theorem {n}.source_bound : {n}.sourceHandle < 2^64 := by decide +kernel")
  Parametric.Driver.emit (header ++ s!"theorem {n}.source_run (C : CSrv) : interpC (step {n}.F {n}.input).run C = some ({n}.output,C) := by host_kernel_rfl")
  Parametric.Driver.emit (header ++ s!"theorem {n}.source_step : interpS (step {n}.F {n}.input).run {n}.initialServer = some ({n}.output,{n}.nextServer) := by host_kernel_rfl")
  let updateText := "objectWrite objects " ++ n ++ ".sourceHandle (.config {configRole with outs := configRole.outs ++ [(expressions.map Dimension.literal," ++ n ++ ".sourceDtype)]})"
  let notesText := "notes.withRuntime {notes.runtime with control := returnNote nativeStatusRole}"
  Parametric.Driver.emit (header ++ s!"theorem {n}.retained_transport
      (notes : RetainedNotes) (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
      (nodes : Nat → GraphNode) (boundary : Nat → Prop) (objects : Nat → Object)
      (roots H N : Nat → Prop) (tail : List NumV) (host : Host.Load.HostSt → Host.Load.HostSt → Prop)
      (live framed : Nat → Prop) (before after : List Val) (old old' : List Event) (s : St {n}.F.S)
      (inst : Inst ν₀ {n}.initialServer C₀)
      (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) (VectorHost.NativeRelation ν₀ ν C₀ C nodes boundary objects H N tail host)
        R live framed before after old old' {n}.input s)
      (inventory : RetainedInventory notes ν₀ ν C₀ C R live {n}.input s)
      (policy : ProducerAnnotations roots H N nodes objects)
      (signatureFrame : ¬ framed {n}.sourceTypes) (handleLive : H {n}.sourceHandle)
      (configRole : Config) (objectRole : objects {n}.sourceHandle = .config configRole)
      (expressions : List SymE) (integers : List Int)
      (sourceDimensions : LiteralDimensions ν₀ (expressions.map Dimension.literal) {n}.sourceIntegers)
      (targetDimensions : LiteralDimensions ν (expressions.map Dimension.literal) integers)
      (fnRole thisRole : Annotated.Value)
      (controlNote : notes.runtime.control = callNote fnRole thisRole [.handle {n}.sourceHandle,.ptr (.js {n}.sourceBuffer) 0,.ordinaryBig (Int.ofNat {n}.sourceIntegers.length),.literal (.lit {n}.sourceValue)])
      (selected : notes.buffers.owners {n}.sourceBuffer = some (literalShapeByteNotes expressions))
      (targetBound : R.handle {n}.sourceHandle < 2^64) :
      let updated := {updateText}
      ∃ result, interpC (step {n}.F {n}.input).run C₀ = some ({n}.output,C₀) ∧
        interpC (step {n}.F s).run C = some (result,C) ∧
        Parametric.StateR (NumberRoles ν₀ ν C₀ C) (VectorHost.NativeRelation ν₀ ν C₀ C nodes boundary updated H N tail host)
          R live framed before after old old' {n}.output result ∧
        RetainedInventory ({notesText}) ν₀ ν C₀ C R live {n}.output result ∧
        Inst ν₀ {n}.nextServer C₀ ∧ ProducerAnnotations roots H N nodes updated := by
      dsimp only
      have length : expressions.length = {n}.sourceIntegers.length := by
        simpa only [len_list_length,List.length_map] using (sourceDimensions.holds C₀).len_eq
      obtain ⟨bytes,shape,config,left,right,post,retained,policy'⟩ :=
        ConfigOutputInventory.retained_from_source ν₀ ν C₀ C R nodes boundary objects roots H N tail host
          live framed before after old old' {n}.input s h inventory policy {n}.sourceFn {n}.sourceTypes
          {n}.sourceHandle {n}.sourceBuffer {n}.sourceDtype {n}.sourceValue {n}.sourceFunction {n}.sourceSignature
          {n}.sourceReturns {n}.sourceThis expressions {n}.sourceIntegers integers sourceDimensions targetDimensions
          (by simpa only [length] using {n}.source_control) {n}.source_function_read {n}.source_function_kind
          {n}.source_signature_read {n}.source_signature_kind {n}.source_cast {n}.source_dtype signatureFrame handleLive
          configRole {n}.sourceConfig objectRole {n}.source_config_read fnRole thisRole
          (by simpa only [length] using controlNote) selected {n}.source_bound targetBound
      simp only [length] at left right post retained
      have source := {n}.source_run C₀
      have same := congrArg Prod.fst (Option.some.inj (left.symm.trans source))
      dsimp only at same
      rw [same] at post retained
      exact ⟨_,source,right,post,retained,{n}.source_servers ▸ inst,policy'⟩")

end Host.Ts.Owned.Annotated.Driver
