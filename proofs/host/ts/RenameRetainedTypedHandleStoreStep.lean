import host.ts.RenameRetainedTypedHandleStore
import host.ts.RenameRouteDriver
import host.ts.RenameKernelRfl

set_option Elab.async false
namespace Host.Ts.Owned.Annotated.Driver
open Lean Elab Command Meta Parametric.Driver

/-- Select the real typed-u64 store. The expected count is checked against
current source metadata, and every emitted declaration rolls back on failure. -/
elab "host_retained_typed_handle_store " f:term ", " s:term " using " initial:term
    " to " t:term " using " next:term " with " expected:term " as " name:ident : command => do
  let saved ← get
  try
    let pre := (← getCurrNamespace) ++ name.getId
    liftTermElabM do
      let f ← Term.elabTermEnsuringType f (mkConst ``Ffi)
      let stateTy := mkApp (mkConst ``St) (mkApp (mkConst ``Ffi.S) f)
      let s ← Term.elabTermEnsuringType s stateTy
      let t ← Term.elabTermEnsuringType t stateTy
      let control ← whnf (← mkAppM ``St.ctl #[s])
      unless control.isAppOfArity ``Ctl.ret 1 do throwError "typed handle store: expected returned handle"
      let integer ← field control.getAppArgs[0]! ``Val.big 1 0
      let handle ← field integer ``Int.ofNat 1 0
      let stack ← whnf (← mkAppM ``St.stack #[s])
      let assignment ← whnf (← field (← field stack ``List.cons 3 1) ``Frame.a 1 0)
      unless assignment.isAppOfArity ``AsgF.put 3 do throwError "typed handle store: expected assignment store"
      unless (← whnf assignment.getAppArgs[0]!).isAppOfArity ``Option.none 1 do
        throwError "typed handle store: expected plain assignment"
      unless (← whnf assignment.getAppArgs[2]!).isConstOf ``Val.undef do
        throwError "typed handle store: expected undefined saved value"
      let target ← whnf assignment.getAppArgs[1]!
      unless target.isAppOfArity ``Target.prop 2 do throwError "typed handle store: expected indexed property"
      let owner ← field target.getAppArgs[0]! ``Val.obj 1 0
      let key ← field target.getAppArgs[1]! ``PKey.str 1 0
      let index ← field (← mkAppM ``keyIndex #[target.getAppArgs[1]!]) ``Option.some 2 1
      let object ← field (← mkAppM ``St.obj? #[s,owner]) ``Option.some 2 1
      let kind ← whnf (← mkAppM ``Obj.kind #[object])
      unless kind.isAppOfArity ``Kind.typed 4 do throwError "typed handle store: expected typed view"
      unless (← whnf kind.getAppArgs[0]!).isConstOf ``EltK.u64 do
        throwError "typed handle store: expected BigUint64Array"
      let buffer := kind.getAppArgs[1]!
      let off := kind.getAppArgs[2]!
      let count ← Term.elabTermEnsuringType expected (mkConst ``Nat)
      let bo ← field (← mkAppM ``St.obj? #[s,buffer]) ``Option.some 2 1
      let bytes ← field (← mkAppM ``Obj.kind #[bo]) ``Kind.buf 1 0
      let frames ← field stack ``List.cons 3 2
      for (tag,value) in [("F",f),("input",s),("output",t),("owner",owner),("buffer",buffer),("offset",off),
          ("count",count),("index",index),("handle",handle),("key",key),("object",object),("bufferObject",bo),
          ("bytes",bytes),("frames",frames)] do
        addData (pre ++ Name.mkSimple tag) value (if tag == "input" || tag == "output" then some stateTy else none)
      addData (pre ++ `initialServer) (← mkAppM ``numberServer #[← Term.elabTermEnsuringType initial (mkConst ``SSrv)])
      addData (pre ++ `nextServer) (← mkAppM ``numberServer #[← Term.elabTermEnsuringType next (mkConst ``SSrv)])
    let n := "_root_." ++ pre.toString
    let header := "open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated in\n"
    let emit (text : String) : CommandElabM Unit := do
      Parametric.Driver.emit (header ++ text)
      if (← get).messages.hasErrors then
        let mut detail := ""
        for message in (← get).messages.toList.drop saved.messages.toList.length do
          detail := detail ++ (← message.data.toString) ++ "\n"
        throwError "typed handle store source proof failed: {detail}"
    let fact (tag proposition : String) := emit s!"theorem {n}.{tag} : {proposition} := by host_kernel_rfl"
    fact "source_control" s!"{n}.input.ctl = .ret (.big (Int.ofNat {n}.handle))"
    fact "source_stack" s!"{n}.input.stack = .a (.put none (.prop (.obj {n}.owner) (.str {n}.key)) .undef)::{n}.frames"
    fact "source_object" s!"{n}.input.heap.get {n}.owner = some (.obj {n}.object)"
    fact "source_kind" s!"{n}.object.kind = .typed .u64 {n}.buffer {n}.offset {n}.count"
    fact "source_index" s!"keyIndex (.str {n}.key) = some {n}.index"
    fact "source_buffer" s!"{n}.input.heap.get {n}.buffer = some (.obj {n}.bufferObject)"
    fact "source_bytes" s!"{n}.bufferObject.kind = .buf {n}.bytes"
    for (tag,proposition) in [("source_inside",s!"{n}.index < {n}.count"),
        ("source_bound",s!"{n}.buffer < 2^64"),("source_word",s!"{n}.handle < 2^64")] do
      emit s!"theorem {n}.{tag} : {proposition} := by decide +kernel"
    fact "source_output" s!"typedHandleStorePost {n}.input {n}.buffer {n}.bufferObject {n}.bytes {n}.offset {n}.index {n}.handle {n}.frames = {n}.output"
    emit s!"theorem {n}.source_run (C : CSrv) : interpC (step {n}.F {n}.input).run C = some ({n}.output,C) := by host_kernel_rfl"
    fact "source_step" s!"interpS (step {n}.F {n}.input).run {n}.initialServer = some ({n}.output,{n}.nextServer)"
    emit s!"theorem {n}.retained_transport
        (notes : RetainedNotes) (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
        (FR : Ren → {n}.F.S → {n}.F.S → Prop) (live framed : Nat → Prop)
        (before after : List Val) (old old' : List Event) (s : St {n}.F.S)
        (inst : Inst ν₀ {n}.initialServer C₀)
        (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' {n}.input s)
        (inventory : RetainedInventory notes ν₀ ν C₀ C R live {n}.input s)
        (oldRoles : List Annotated.Byte) (head : Annotated.Tree) (tail : List Annotated.Tree)
        (selected : notes.buffers.owners {n}.buffer = some oldRoles)
        (controlNote : notes.runtime.control = returnNote (.handle {n}.handle))
        (stackNotes : notes.runtime.stack = head::tail)
        (notFramed : ¬ framed {n}.buffer)
        (targetBound : R.a {n}.buffer < 2^64) (targetWord : R.handle {n}.handle < 2^64) :
        ∃ result, interpC (step {n}.F {n}.input).run C₀ = some ({n}.output,C₀) ∧
          interpC (step {n}.F s).run C = some (result,C) ∧
          Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' {n}.output result ∧
          RetainedInventory (notes.typedHandleStored {n}.buffer {n}.offset {n}.index {n}.handle oldRoles tail)
            ν₀ ν C₀ C R live {n}.output result ∧ Inst ν₀ {n}.nextServer C₀ := by
        obtain ⟨bo,bytes,frames,left,right,post,retained⟩ := inventory.typed_handle_store_step {n}.F FR h
          {n}.owner {n}.buffer {n}.offset {n}.count {n}.index {n}.handle {n}.key {n}.object {n}.bufferObject {n}.bytes {n}.frames oldRoles head tail
          {n}.source_control {n}.source_stack {n}.source_object {n}.source_kind {n}.source_index {n}.source_inside
          {n}.source_buffer {n}.source_bytes selected controlNote stackNotes notFramed {n}.source_bound targetBound {n}.source_word targetWord
        have source := {n}.source_run C₀
        have same := congrArg Prod.fst (Option.some.inj (left.symm.trans source))
        dsimp only at same
        rw [same] at post retained
        exact ⟨_,source,right,post,retained,pure_step_inst {n}.F ν₀ {n}.initialServer {n}.nextServer C₀
          {n}.input {n}.output inst {n}.source_step source⟩"
  catch exception =>
    set saved
    throw exception

end Host.Ts.Owned.Annotated.Driver
