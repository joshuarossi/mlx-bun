import host.mlx.NativeConfigDtypeRetained
import host.ts.RenameRuntimeSourceCut
import host.ts.RenameRuntimeDriverValues

set_option Elab.async false
namespace Host.Ts.Owned.Annotated.Driver
open Lean Elab Command Meta Parametric.Driver

/-- Select the original configuration integer setter. Current literal operand
notes fix its meaning; the i32 decoder, updated native object annotation and
producer policy are derived by the reusable transport theorem. -/
elab "host_retained_configDtype " f:term ", " s:term " using " initial:term " to " t:term " using " next:term " as " name:ident : command => do
  let pre := (← getCurrNamespace) ++ name.getId
  liftTermElabM do
    let f ← Term.elabTermEnsuringType f (mkConst ``Ffi)
    let stateTy := mkApp (mkConst ``St) (mkApp (mkConst ``Ffi.S) f)
    let s ← Term.elabTermEnsuringType s stateTy
    let t ← Term.elabTermEnsuringType t stateTy
    let control ← whnf (← mkAppM ``St.ctl #[s])
    unless control.isAppOfArity ``Ctl.call 3 do throwError "host_retained_configDtype: expected source call"
    let fn ← field control.getAppArgs[0]! ``Val.obj 1 0
    let args := control.getAppArgs[2]!
    let integer ← field (← field args ``List.cons 3 1) ``Val.big 1 0
    let handle ← mkAppM ``Int.toNat #[integer]
    let rest ← field args ``List.cons 3 2
    let pointer ← field rest ``List.cons 3 1
    let buffer ← field (← field pointer ``Val.ptr 2 0) ``Mem.js 1 0
    let rest ← field rest ``List.cons 3 2
    let value ← field (← field rest ``List.cons 3 1) ``Val.num 1 0
    let sourceValue ← field value ``NumV.lit 1 0
    let dtype ← field (← mkAppM ``Host.Mlx.Ffi.argNat #[← mkAppM ``Arg.num #[value]]) ``Option.some 2 1
    let function ← field (← mkAppM ``St.obj? #[s,fn]) ``Option.some 2 1
    let code ← whnf (← field (← mkAppM ``Obj.kind #[function]) ``Kind.fn 1 0)
    let captures ← field code ``Code.native 2 1
    let captures ← field captures ``List.cons 3 2
    let types ← field (← field captures ``List.cons 3 1) ``Val.obj 1 0
    let returns ← field (← field (← field captures ``List.cons 3 2) ``List.cons 3 1) ``Val.str 1 0
    let signature ← field (← mkAppM ``St.obj? #[s,types]) ``Option.some 2 1
    let bufferObject ← field (← mkAppM ``St.obj? #[s,buffer]) ``Option.some 2 1
    let bytes ← field (← mkAppM ``Obj.kind #[bufferObject]) ``Kind.buf 1 0
    let native ← mkAppM ``Host.Load.LSt.mlx #[← mkAppM ``St.ffi #[s]]
    let config ← field (← field (← mkAppM ``Host.Mlx.Ffi.St.obj? #[native,handle]) ``Option.some 2 1) ``Host.Mlx.Ffi.Obj.cfg 1 0
    let nativeName ← field (← mkAppM ``Host.Mlx.Ffi.cstrArg #[← mkAppM ``Arg.jsPtr #[buffer,mkNatLit 0,bytes]]) ``Option.some 2 1
    for (tag,value) in [("F",f),("input",s),("output",t),("sourceFn",fn),("sourceHandle",handle),
      ("sourceBuffer",buffer),("sourceValue",sourceValue),("sourceDtype",dtype),("sourceFunction",function),("sourceTypes",types),
      ("sourceReturns",returns),("sourceSignature",signature),("sourceBufferObject",bufferObject),
      ("sourceBytes",bytes),("sourceConfig",config),("sourceName",nativeName),("sourceThis",control.getAppArgs[1]!)] do
      addData (pre ++ Name.mkSimple tag) value (if tag == "input" || tag == "output" then some stateTy else none)
    addData (pre ++ `initialServer) (← mkAppM ``numberServer #[← Term.elabTermEnsuringType initial (mkConst ``SSrv)])
    addData (pre ++ `nextServer) (← mkAppM ``numberServer #[← Term.elabTermEnsuringType next (mkConst ``SSrv)])
  let n := "_root_." ++ pre.toString
  let header := "open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated Host.Mlx.Ffi Host.Mlx.Ffi.NativeRoles Host.Mlx.Ffi.Annotated Host.Load.Run.Full.Ordinary in\n"
  let fact (tag proposition : String) := Parametric.Driver.emit (header ++ s!"theorem {n}.{tag} : {proposition} := by host_kernel_rfl")
  for (tag,type) in [
    ("source_control",s!"{n}.input.ctl = .call (.obj {n}.sourceFn) {n}.sourceThis [.big (Int.ofNat {n}.sourceHandle),.ptr (.js {n}.sourceBuffer) 0,.num (.lit {n}.sourceValue)]"),
    ("source_function_read",s!"{n}.input.heap.get {n}.sourceFn = some (.obj {n}.sourceFunction)"),
    ("source_function_kind",s!"{n}.sourceFunction.kind = .fn (.native (.ffi .symbol) [.str ConfigDtypeHost.symbol,.obj {n}.sourceTypes,.str {n}.sourceReturns])"),
    ("source_signature_read",s!"{n}.input.heap.get {n}.sourceTypes = some (.obj {n}.sourceSignature)"),
    ("source_signature_kind",s!"{n}.sourceSignature.kind = .array ConfigDtypeHost.signature"),
    ("source_buffer_read",s!"{n}.input.heap.get {n}.sourceBuffer = some (.obj {n}.sourceBufferObject)"),
    ("source_buffer_kind",s!"{n}.sourceBufferObject.kind = .buf {n}.sourceBytes"),
    ("source_name",s!"cstrArg (.jsPtr {n}.sourceBuffer 0 {n}.sourceBytes) = some {n}.sourceName"),
    ("source_config_read",s!"{n}.input.ffi.mlx.obj? {n}.sourceHandle = some (.cfg {n}.sourceConfig)"),
    ("source_dtype",s!"argNat (.num (.lit {n}.sourceValue)) = some {n}.sourceDtype"),
    ("source_cast",s!"F64.un .int32 {n}.sourceValue = {n}.sourceValue"),
    ("source_servers",s!"{n}.initialServer = {n}.nextServer")]
    do fact tag type
  Parametric.Driver.emit (header ++ s!"theorem {n}.source_bound : {n}.sourceHandle < 2^64 := by decide +kernel")
  Parametric.Driver.emit (header ++ s!"theorem {n}.source_run (C : CSrv) : interpC (step {n}.F {n}.input).run C = some ({n}.output,C) := by host_kernel_rfl")
  Parametric.Driver.emit (header ++ s!"theorem {n}.source_step : interpS (step {n}.F {n}.input).run {n}.initialServer = some ({n}.output,{n}.nextServer) := by host_kernel_rfl")
  let updateText := "objectWrite objects " ++ n ++ ".sourceHandle (.config {configRole with dtypes := configRole.dtypes ++ [(" ++ n ++ ".sourceName," ++ n ++ ".sourceDtype)]})"
  let notesText := "notes.withRuntime {notes.runtime with control := returnNote nativeStatusRole}"
  Parametric.Driver.emit (header ++ s!"theorem {n}.retained_transport
      (notes : RetainedNotes) (\u03BD\u2080 \u03BD : Nat \u2192 F64) (C\u2080 C : CSrv) (R : Ren)
      (nodes : Nat \u2192 GraphNode) (boundary : Nat \u2192 Prop) (objects : Nat \u2192 Object)
      (roots H N : Nat \u2192 Prop) (tail : List NumV) (host : Host.Load.HostSt \u2192 Host.Load.HostSt \u2192 Prop)
      (live framed : Nat \u2192 Prop) (before after : List Val) (old old' : List Event) (s : St {n}.F.S)
      (inst : Inst \u03BD\u2080 {n}.initialServer C\u2080)
      (h : Parametric.StateR (NumberRoles \u03BD\u2080 \u03BD C\u2080 C) (VectorHost.NativeRelation \u03BD\u2080 \u03BD C\u2080 C nodes boundary objects H N tail host)
        R live framed before after old old' {n}.input s)
      (inventory : RetainedInventory notes \u03BD\u2080 \u03BD C\u2080 C R live {n}.input s)
      (policy : ProducerAnnotations roots H N nodes objects)
      (signatureFrame : \u00AC framed {n}.sourceTypes) (handleLive : H {n}.sourceHandle)
      (configRole : Config) (objectRole : objects {n}.sourceHandle = .config configRole)
      (fnRole thisRole : Annotated.Value)
      (controlNote : notes.runtime.control = callNote fnRole thisRole [.handle {n}.sourceHandle,.ptr (.js {n}.sourceBuffer) 0,.literal (.lit {n}.sourceValue)])
      (targetBound : R.handle {n}.sourceHandle < 2^64) :
      let updated := {updateText}
      \u2203 result, interpC (step {n}.F {n}.input).run C\u2080 = some ({n}.output,C\u2080) \u2227
        interpC (step {n}.F s).run C = some (result,C) \u2227
        Parametric.StateR (NumberRoles \u03BD\u2080 \u03BD C\u2080 C) (VectorHost.NativeRelation \u03BD\u2080 \u03BD C\u2080 C nodes boundary updated H N tail host)
          R live framed before after old old' {n}.output result \u2227
        RetainedInventory ({notesText}) \u03BD\u2080 \u03BD C\u2080 C R live {n}.output result \u2227
        Inst \u03BD\u2080 {n}.nextServer C\u2080 \u2227 ProducerAnnotations roots H N nodes updated := by
      dsimp only
      obtain \u27E8bytes,target,left,right,post,retained,policy'\u27E9 :=
        ConfigDtypeInventory.retained_from_source \u03BD\u2080 \u03BD C\u2080 C R nodes boundary objects roots H N tail host
          live framed before after old old' {n}.input s h inventory policy {n}.sourceFn {n}.sourceTypes
          {n}.sourceHandle {n}.sourceBuffer {n}.sourceDtype {n}.sourceValue {n}.sourceFunction {n}.sourceSignature
          {n}.sourceBufferObject {n}.sourceReturns {n}.sourceThis {n}.sourceBytes {n}.sourceName
          {n}.source_control {n}.source_function_read {n}.source_function_kind {n}.source_signature_read
          {n}.source_signature_kind {n}.source_buffer_read {n}.source_buffer_kind {n}.source_name
          {n}.source_cast {n}.source_dtype signatureFrame handleLive configRole {n}.sourceConfig objectRole
          {n}.source_config_read fnRole thisRole controlNote {n}.source_bound targetBound
      have source := {n}.source_run C\u2080
      have same := congrArg Prod.fst (Option.some.inj (left.symm.trans source))
      dsimp only at same
      rw [same] at post retained
      exact \u27E8_,source,right,post,retained,{n}.source_servers \u25B8 inst,policy'\u27E9")

end Host.Ts.Owned.Annotated.Driver
