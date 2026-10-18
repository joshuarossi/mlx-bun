import host.ts.RenameRouteDriver
import host.ts.RenameHandleTypedArray

namespace Host.Ts.Owned.Parametric.Driver
open Lean Elab Command Meta

/-- Inspect the actual BigUint64Array constructor and its source iterable.
Only source metadata is selected; all observations and the endpoint are checked. -/
elab "host_transport_handle_typed_array " f:term ", " s:term " to " t:term " as " name:ident : command => do
  let pre := (← getCurrNamespace) ++ name.getId
  liftTermElabM do
    let f ← Term.elabTermEnsuringType f (mkConst ``Ffi)
    let ty := mkApp (mkConst ``St) (mkApp (mkConst ``Ffi.S) f)
    let s ← Term.elabTermEnsuringType s ty
    let t ← Term.elabTermEnsuringType t ty
    let add (tag : String) (v : Lean.Expr) := addData (pre ++ Name.mkSimple tag) v
    add "F" f
    add "input" s
    add "output" t
    let ctl ← whnf (← mkAppM ``St.ctl #[s])
    let a ← field (← field ctl ``Ctl.construct 3 0) ``Val.obj 1 0
    let args ← field ctl ``Ctl.construct 3 1
    let b ← field (← field args ``List.cons 3 1) ``Val.obj 1 0
    let rest ← whnf (← field args ``List.cons 3 2)
    unless rest.isAppOfArity ``List.nil 1 do throwError "handle typed array: expected one iterable"
    let nt ← field ctl ``Ctl.construct 3 2
    let o ← field (← mkAppM ``St.obj? #[s,a]) ``Option.some 2 1
    let code ← field (← mkAppM ``Obj.kind #[o]) ``Kind.fn 1 0
    let native ← whnf (← field code ``Code.native 2 0)
    unless native.isAppOfArity ``Native.buf 1 && native.getAppArgs[0]!.isConstOf ``BufN.typedCtor do
      throwError "handle typed array: expected typedCtor"
    let data ← field code ``Code.native 2 1
    let x ← field (← field (← field data ``List.cons 3 1) ``Val.num 1 0) ``NumV.lit 1 0
    let tail ← field data ``List.cons 3 2
    let y ← field (← field (← field tail ``List.cons 3 1) ``Val.num 1 0) ``NumV.lit 1 0
    unless (← whnf (← field tail ``List.cons 3 2)).isAppOfArity ``List.nil 1 do
      throwError "handle typed array: expected two constructor fields"
    let proto ← field (← mkAppM ``F64.toIndex? #[y]) ``Option.some 2 1
    let bo ← field (← mkAppM ``St.obj? #[s,b]) ``Option.some 2 1
    let vals ← field (← mkAppM ``Obj.kind #[bo]) ``Kind.array 1 0
    let mut cursor := vals
    let mut hs : List Lean.Expr := []
    while true do
      let xs ← whnf cursor
      if xs.isAppOfArity ``List.nil 1 then break
      let v ← field xs ``List.cons 3 1
      let i ← field v ``Val.big 1 0
      let h ← field i ``Int.ofNat 1 0
      hs := hs ++ [h]
      cursor ← field xs ``List.cons 3 2
    let handles ← mkListLit (mkConst ``Nat) hs
    for (tag,v) in [("sourceFunction",a),("sourceAddress",b),("sourceNewTarget",nt),
      ("sourceCallee",o),("sourceObject",bo),("sourceCode",x),("sourceProtoNumber",y),("sourceProto",proto),
      ("sourceHandles",handles)] do add tag v
  let n := "_root_." ++ pre.toString
  let header := "open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Mlx.Ffi.Annotated in\n"
  let fact (tag prop : String) := emit (header ++ s!"theorem {n}.{tag} : {prop} := by host_kernel_rfl")
  fact "source_control" s!"{n}.input.ctl = .construct (.obj {n}.sourceFunction) [.obj {n}.sourceAddress] {n}.sourceNewTarget"
  fact "source_callee" s!"{n}.input.heap.get {n}.sourceFunction = some (.obj {n}.sourceCallee)"
  fact "source_code" s!"{n}.sourceCallee.kind = .fn (.native (.buf .typedCtor) [.num (.lit {n}.sourceCode),.num (.lit {n}.sourceProtoNumber)])"
  fact "source_heap" s!"{n}.input.heap.get {n}.sourceAddress = some (.obj {n}.sourceObject)"
  fact "source_array" s!"{n}.sourceObject.kind = .array ({n}.sourceHandles.map (fun h => Val.big (Int.ofNat h)))"
  fact "source_code_index" s!"F64.toIndex? {n}.sourceCode = some 9"
  fact "source_proto_index" s!"F64.toIndex? {n}.sourceProtoNumber = some {n}.sourceProto"
  emit (header ++ s!"theorem {n}.source_bound : {n}.input.next+1 < 2^64 := by decide +kernel")
  fact "source_handles_check" s!"{n}.sourceHandles.all (fun h => decide (h < 2^64)) = true"
  emit (header ++ s!"theorem {n}.source_handles : ∀ h ∈ {n}.sourceHandles, h < 2^64 := by
    intro h hh
    exact of_decide_eq_true (List.all_eq_true.mp {n}.source_handles_check h hh)")
  fact "source_post" s!"((newTyped {n}.F {n}.input .u64 {n}.sourceProto (VectorBuffer.bytes {n}.sourceHandles) {n}.sourceHandles.length).2.ret (.obj ({n}.input.next+1))) = {n}.output"
  emit (header ++ s!"theorem {n}.transport (NR : NumV → NumV → Prop) (FR : Ren → {n}.F.S → {n}.F.S → Prop)
      (R : Ren) (C₀ C : CSrv) (ν : Nat → F64) (live framed : Nat → Prop)
      (before after : List Val) (old old' : List Event) (s : St {n}.F.S)
      (h : StateR NR FR R live framed before after old old' {n}.input s)
      (contents : ArrayData s (R.a {n}.sourceAddress) (({n}.sourceHandles.map R.handle).map (fun h => Val.big (Int.ofNat h))))
      (code : (Annotated.Value.literal (.lit {n}.sourceCode)).Holds ν C R (nativeDataArgument s (R.a {n}.sourceFunction) 0))
      (proto : (Annotated.Value.literal (.lit {n}.sourceProtoNumber)).Holds ν C R (nativeDataArgument s (R.a {n}.sourceFunction) 1))
      (handles : ∀ h ∈ {n}.sourceHandles.map R.handle, h < 2^64)
      (bufferProtoLive : live aArrayBufferProto) (bufferProtoFixed : R.a aArrayBufferProto = aArrayBufferProto)
      (typedProtoLive : live {n}.sourceProto) (typedProtoFixed : R.a {n}.sourceProto = {n}.sourceProto)
      (bound : s.next+1 < 2^64) :
      ∃ result, interpC (step {n}.F s).run C = some (result,C) ∧
        StateR NR FR R (LiveAfter (LiveAfter live {n}.input.next) ({n}.input.next+1)) framed before after old old' {n}.output result ∧
        (VectorBuffer.role {n}.sourceHandles).Holds ν C R (objectKindAt result (R.a {n}.input.next)) ∧
        (∀ a, a < s.next → result.heap.get a = s.heap.get a) := by
    obtain ⟨_,run,related⟩ := step_construct_u64_handles_from_source {n}.F NR FR R C₀ C ν live framed before after old old'
      {n}.input s h {n}.sourceFunction {n}.sourceAddress {n}.sourceProto {n}.sourceCallee {n}.sourceObject {n}.sourceNewTarget
      {n}.sourceCode {n}.sourceProtoNumber {n}.sourceHandles {n}.source_control {n}.source_callee {n}.source_code {n}.source_heap
      {n}.source_array {n}.source_code_index {n}.source_proto_index contents code proto {n}.source_handles handles
      bufferProtoLive bufferProtoFixed typedProtoLive typedProtoFixed {n}.source_bound bound
    have fresh : R.a {n}.input.next = s.next := by simpa only [Nat.add_zero] using h.heap.fresh 0
    refine ⟨_,run,{n}.source_post ▸ related,?_,newTyped_heap_below {n}.F s .u64 {n}.sourceProto _ _ bound⟩
    rw [fresh]
    have object := newTyped_buffer_object {n}.F s .u64 {n}.sourceProto {n}.sourceHandles.length
      (VectorBuffer.bytes ({n}.sourceHandles.map R.handle)) bound
    simp only [objectKindAt,object]
    exact VectorBuffer.annotated ν C R {n}.sourceHandles")

end Host.Ts.Owned.Parametric.Driver
