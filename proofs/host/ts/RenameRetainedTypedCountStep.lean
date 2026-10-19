import host.ts.RenameRetainedTypedCount
import host.ts.RenameRuntimeSourceCut
import host.ts.RenameRouteDriver
import host.ts.RenameKernelRfl
set_option Elab.async false
namespace Host.Ts.Owned.Annotated.Driver
open Lean Elab Command Meta
open Parametric.Driver

elab "host_retained_typed_count " f:term ", " s:term " using " initial:term
    " to " t:term " using " next:term " as " name:ident : command => do
  let saved ← get
  try
    let pre := (← getCurrNamespace) ++ name.getId
    liftTermElabM do
      let f ← Term.elabTermEnsuringType f (mkConst ``Ffi)
      let stateTy := mkApp (mkConst ``St) (mkApp (mkConst ``Ffi.S) f)
      let s ← Term.elabTermEnsuringType s stateTy
      let t ← Term.elabTermEnsuringType t stateTy
      let control ← whnf (← mkAppM ``St.ctl #[s])
      unless control.isAppOfArity ``Ctl.construct 3 do throwError "typed count: expected constructor"
      let address ← field control.getAppArgs[0]! ``Val.obj 1 0
      let args := control.getAppArgs[1]!
      let value ← field (← field args ``List.cons 3 1) ``Val.num 1 0
      let countLiteral ← field value ``NumV.lit 1 0
      unless (← whnf (← field args ``List.cons 3 2)).isAppOfArity ``List.nil 1 do
        throwError "typed count: expected exactly one length argument"
      let object ← field (← mkAppM ``St.obj? #[s,address]) ``Option.some 2 1
      let code ← whnf (← field (← mkAppM ``Obj.kind #[object]) ``Kind.fn 1 0)
      let native ← field code ``Code.native 2 0
      unless (← whnf (← field native ``Native.buf 1 0)).isConstOf ``BufN.typedCtor do
        throwError "typed count: expected typedCtor"
      let data := code.getAppArgs[1]!
      let x ← field (← field (← field data ``List.cons 3 1) ``Val.num 1 0) ``NumV.lit 1 0
      let rest ← field data ``List.cons 3 2
      let y ← field (← field (← field rest ``List.cons 3 1) ``Val.num 1 0) ``NumV.lit 1 0
      unless (← whnf (← field rest ``List.cons 3 2)).isAppOfArity ``List.nil 1 do
        throwError "typed count: expected exactly two builtin captures"
      let codeIndex ← field (← mkAppM ``F64.toIndex? #[x]) ``Option.some 2 1
      let proto ← field (← mkAppM ``F64.toIndex? #[y]) ``Option.some 2 1
      let count ← field (← mkAppM ``F64.toIndex? #[countLiteral]) ``Option.some 2 1
      for (tag,value) in [("F",f),("input",s),("output",t),("address",address),("object",object),
          ("newTarget",control.getAppArgs[2]!),("codeLiteral",x),("protoLiteral",y),("countLiteral",countLiteral),
          ("codeIndex",codeIndex),("protoIndex",proto),("count",count)] do
        let type? := if tag == "input" || tag == "output" then
          some (mkApp (mkConst ``St) (mkApp (mkConst ``Ffi.S) (mkConst (pre ++ `F)))) else none
        addData (pre ++ Name.mkSimple tag) value type?
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
        throwError "typed count source proof failed: {detail}"
    let fact (tag proposition : String) := emit s!"theorem {n}.{tag} : {proposition} := by host_kernel_rfl"
    fact "source_control" s!"{n}.input.ctl = .construct (.obj {n}.address) [.num (.lit {n}.countLiteral)] {n}.newTarget"
    fact "source_heap" s!"{n}.input.heap.get {n}.address = some (.obj {n}.object)"
    fact "source_kind" s!"{n}.object.kind = .fn (.native (.buf .typedCtor) [.num (.lit {n}.codeLiteral),.num (.lit {n}.protoLiteral)])"
    fact "code_index" s!"F64.toIndex? {n}.codeLiteral = some {n}.codeIndex"
    fact "proto_index" s!"F64.toIndex? {n}.protoLiteral = some {n}.protoIndex"
    fact "count_index" s!"F64.toIndex? {n}.countLiteral = some {n}.count"
    emit s!"theorem {n}.source_bound : {n}.input.next+1 < 2^64 := by decide +kernel"
    emit s!"theorem {n}.source_run (C : CSrv) : interpC (step {n}.F {n}.input).run C = some ({n}.output,C) := by host_kernel_rfl"
    fact "source_step" s!"interpS (step {n}.F {n}.input).run {n}.initialServer = some ({n}.output,{n}.nextServer)"
    emit s!"theorem {n}.retained_transport
        (notes : RetainedNotes) (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
        (FR : Ren → {n}.F.S → {n}.F.S → Prop) (live framed : Nat → Prop)
        (before after : List Val) (old old' : List Event) (s : St {n}.F.S)
        (inst : Inst ν₀ {n}.initialServer C₀)
        (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' {n}.input s)
        (inventory : RetainedInventory notes ν₀ ν C₀ C R live {n}.input s)
        (metadata : NativeCaptureNote) (fnRole : Annotated.Value)
        (selected : notes.captures.owners {n}.address = some metadata)
        (codeNote : metadata.roles 0 = some (.literal (.lit {n}.codeLiteral)))
        (protoNote : metadata.roles 1 = some (.literal (.lit {n}.protoLiteral)))
        (controlNote : notes.runtime.control = constructNote fnRole [.literal (.lit {n}.countLiteral)])
        (bufferProtoLive : live aArrayBufferProto) (bufferProtoFixed : R.a aArrayBufferProto = aArrayBufferProto)
        (protoLive : live {n}.protoIndex) (protoFixed : R.a {n}.protoIndex = {n}.protoIndex)
        (targetBound : s.next+2 ≤ 2^64) :
        ∃ result, interpC (step {n}.F {n}.input).run C₀ = some ({n}.output,C₀) ∧
          interpC (step {n}.F s).run C = some (result,C) ∧
          Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R (LiveAfter (LiveAfter live {n}.input.next) ({n}.input.next+1))
            framed before after old old' {n}.output result ∧
          RetainedInventory (notes.typedBytes {n}.input.next (zeroByteNotes ({n}.count * (eltOfCode {n}.codeIndex).size)))
            ν₀ ν C₀ C R (LiveAfter (LiveAfter live {n}.input.next) ({n}.input.next+1)) {n}.output result ∧ Inst ν₀ {n}.nextServer C₀ := by
        obtain ⟨left,right,post,retained⟩ := inventory.typed_count_step {n}.F FR h
          {n}.address {n}.codeIndex {n}.protoIndex {n}.count {n}.object {n}.newTarget {n}.codeLiteral {n}.protoLiteral {n}.countLiteral metadata fnRole
          {n}.source_control {n}.source_heap {n}.source_kind {n}.code_index {n}.proto_index {n}.count_index selected codeNote protoNote controlNote
          bufferProtoLive bufferProtoFixed protoLive protoFixed {n}.source_bound (by omega)
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
