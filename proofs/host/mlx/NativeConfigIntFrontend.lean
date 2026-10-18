import host.mlx.NativeConfigIntRetained
import host.ts.RenameRuntimeSourceCut
import host.ts.RenameRuntimeDriverValues

set_option Elab.async false
namespace Host.Ts.Owned.Annotated.Driver
open Lean Elab Command Meta Parametric.Driver

/-- Select the original configuration integer setter. Current literal operand
notes fix its meaning; the i32 decoder, updated native object annotation and
producer policy are derived by the reusable transport theorem. -/
elab "host_retained_configInt " f:term ", " s:term " using " initial:term " to " t:term " using " next:term " as " name:ident : command => do
  let pre := (← getCurrNamespace) ++ name.getId
  liftTermElabM do
    let f ← Term.elabTermEnsuringType f (mkConst ``Ffi)
    let stateTy := mkApp (mkConst ``St) (mkApp (mkConst ``Ffi.S) f)
    let s ← Term.elabTermEnsuringType s stateTy
    let t ← Term.elabTermEnsuringType t stateTy
    let control ← whnf (← mkAppM ``St.ctl #[s])
    unless control.isAppOfArity ``Ctl.call 3 do throwError "host_retained_configInt: expected source call"
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
      ("sourceBuffer",buffer),("sourceValue",sourceValue),("sourceFunction",function),("sourceTypes",types),
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
    ("source_function_kind",s!"{n}.sourceFunction.kind = .fn (.native (.ffi .symbol) [.str ConfigIntHost.symbol,.obj {n}.sourceTypes,.str {n}.sourceReturns])"),
    ("source_signature_read",s!"{n}.input.heap.get {n}.sourceTypes = some (.obj {n}.sourceSignature)"),
    ("source_signature_kind",s!"{n}.sourceSignature.kind = .array ConfigIntHost.signature"),
    ("source_buffer_read",s!"{n}.input.heap.get {n}.sourceBuffer = some (.obj {n}.sourceBufferObject)"),
    ("source_buffer_kind",s!"{n}.sourceBufferObject.kind = .buf {n}.sourceBytes"),
    ("source_name",s!"cstrArg (.jsPtr {n}.sourceBuffer 0 {n}.sourceBytes) = some {n}.sourceName"),
    ("source_config_read",s!"{n}.input.ffi.mlx.obj? {n}.sourceHandle = some (.cfg {n}.sourceConfig)"),
    ("source_servers",s!"{n}.initialServer = {n}.nextServer")]
    do fact tag type
  Parametric.Driver.emit (header ++ s!"theorem {n}.source_bound : {n}.sourceHandle < 2^64 := by decide +kernel")
  Parametric.Driver.emit (header ++ s!"theorem {n}.source_run (C : CSrv) : interpC (step {n}.F {n}.input).run C = some ({n}.output,C) := by host_kernel_rfl")
  Parametric.Driver.emit (header ++ s!"theorem {n}.source_step : interpS (step {n}.F {n}.input).run {n}.initialServer = some ({n}.output,{n}.nextServer) := by host_kernel_rfl")
  let updateText := "objectWrite objects " ++ n ++ ".sourceHandle (.config {configRole with ints := configRole.ints ++ [(" ++ n ++ ".sourceName,(Number.literal meaning).decoded .i32)]})"
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
      (fnRole thisRole : Annotated.Value) (meaning : SymE)
      (controlNote : notes.runtime.control = callNote fnRole thisRole [.handle {n}.sourceHandle,.ptr (.js {n}.sourceBuffer) 0,.literal meaning])
      (targetBound : R.handle {n}.sourceHandle < 2^64) :
      let updated := {updateText}
      ∃ result, interpC (step {n}.F {n}.input).run C₀ = some ({n}.output,C₀) ∧
        interpC (step {n}.F s).run C = some (result,C) ∧
        Parametric.StateR (NumberRoles ν₀ ν C₀ C) (VectorHost.NativeRelation ν₀ ν C₀ C nodes boundary updated H N tail host)
          R live framed before after old old' {n}.output result ∧
        RetainedInventory ({notesText})
          ν₀ ν C₀ C R live {n}.output result ∧ Inst ν₀ {n}.nextServer C₀ ∧
        ProducerAnnotations roots H N nodes updated ∧ ProducerSupport roots H N {n}.output.ffi.mlx ∧
        ProducerSupport (resourceImage R.node (fun i => N i ∧ roots i)) (resourceImage R.handle H) (resourceImage R.node N) result.ffi.mlx := by
      dsimp only
      obtain ⟨value₀,value,bytes,target,D₀,D,left,right,post,retained,policy',sourceSupport,targetSupport,_,_,literalServers⟩ :=
        ConfigIntInventory.retained_int_from_source ν₀ ν C₀ C R nodes boundary objects roots H N tail host
          live framed before after old old' {n}.input s h inventory policy
          {n}.sourceFn {n}.sourceTypes {n}.sourceHandle {n}.sourceBuffer (.lit {n}.sourceValue)
          {n}.sourceFunction {n}.sourceSignature {n}.sourceBufferObject {n}.sourceReturns {n}.sourceThis {n}.sourceBytes {n}.sourceName
          {n}.source_control {n}.source_function_read {n}.source_function_kind {n}.source_signature_read {n}.source_signature_kind
          {n}.source_buffer_read {n}.source_buffer_kind {n}.source_name signatureFrame handleLive configRole {n}.sourceConfig objectRole
          {n}.source_config_read (.literal meaning) fnRole thisRole (.literal meaning) (.literal meaning) controlNote {n}.source_bound targetBound
      have source := {n}.source_run C₀
      have pair := Option.some.inj (left.symm.trans source)
      have tables : D₀ = C₀ := congrArg Prod.snd pair
      subst D₀
      have targetTable : D = C := (literalServers meaning rfl).2
      subst D
      have states := congrArg Prod.fst pair
      dsimp only at states
      rw [states] at post retained sourceSupport
      exact ⟨_,source,right,post,retained,{n}.source_servers ▸ inst,policy',sourceSupport,targetSupport⟩")

end Host.Ts.Owned.Annotated.Driver
