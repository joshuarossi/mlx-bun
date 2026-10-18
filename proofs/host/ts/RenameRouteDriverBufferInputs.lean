import host.ts.RenameRouteDriver
import host.ts.RenameParametricPointer
import host.ts.RenameFixedBigInt

namespace Host.Ts.Owned.Parametric.Driver
open Lean Elab Command Meta

/-- Follow the actual typed view and backing buffer selected by ptr(). -/
elab "host_transport_buffer_ptr " f:term ", " s:term " to " t:term " as " name:ident : command => do
  let pre := (← getCurrNamespace) ++ name.getId
  liftTermElabM do
    let f ← Term.elabTermEnsuringType f (mkConst ``Ffi)
    let ty := mkApp (mkConst ``St) (mkApp (mkConst ``Ffi.S) f)
    let s ← Term.elabTermEnsuringType s ty
    let t ← Term.elabTermEnsuringType t ty
    let add (tag : String) (v : Lean.Expr) := addData (pre ++ Name.mkSimple tag) v
    add "F" f; add "input" s; add "output" t
    let ctl ← whnf (← mkAppM ``St.ctl #[s])
    let a ← field (← field ctl ``Ctl.call 3 0) ``Val.obj 1 0
    let this ← field ctl ``Ctl.call 3 1
    let args ← field ctl ``Ctl.call 3 2
    let view ← field (← field args ``List.cons 3 1) ``Val.obj 1 0
    let fo ← field (← mkAppM ``St.obj? #[s,a]) ``Option.some 2 1
    let code ← field (← mkAppM ``Obj.kind #[fo]) ``Kind.fn 1 0
    let data ← field code ``Code.native 2 1
    let vo ← field (← mkAppM ``St.obj? #[s,view]) ``Option.some 2 1
    let kind ← whnf (← mkAppM ``Obj.kind #[vo])
    let k ← field kind ``Kind.typed 4 0
    let b ← field kind ``Kind.typed 4 1
    let off ← field kind ``Kind.typed 4 2
    let count ← field kind ``Kind.typed 4 3
    let bo ← field (← mkAppM ``St.obj? #[s,b]) ``Option.some 2 1
    let bytes ← field (← mkAppM ``Obj.kind #[bo]) ``Kind.buf 1 0
    for (tag,v) in [("sourceFunction",a),("sourceThis",this),("sourceView",view),("sourceBuffer",b),
      ("sourceCallee",fo),("sourceData",data),("sourceViewObject",vo),("sourceBufferObject",bo),
      ("sourceKind",k),("sourceOffset",off),("sourceCount",count),("sourceBytes",bytes)] do add tag v
  let n := "_root_." ++ pre.toString
  let header := "open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric in\n"
  let fact (tag prop : String) := emit (header ++ s!"theorem {n}.{tag} : {prop} := by host_kernel_rfl")
  fact "source_control" s!"{n}.input.ctl = .call (.obj {n}.sourceFunction) {n}.sourceThis [.obj {n}.sourceView]"
  fact "source_callee" s!"{n}.input.heap.get {n}.sourceFunction = some (.obj {n}.sourceCallee)"
  fact "source_code" s!"{n}.sourceCallee.kind = .fn (.native (.ffi .ptr) {n}.sourceData)"
  fact "source_view" s!"{n}.input.heap.get {n}.sourceView = some (.obj {n}.sourceViewObject)"
  fact "source_view_kind" s!"{n}.sourceViewObject.kind = .typed {n}.sourceKind {n}.sourceBuffer {n}.sourceOffset {n}.sourceCount"
  fact "source_buffer" s!"{n}.input.heap.get {n}.sourceBuffer = some (.obj {n}.sourceBufferObject)"
  fact "source_buffer_kind" s!"{n}.sourceBufferObject.kind = .buf {n}.sourceBytes"
  emit (header ++ s!"theorem {n}.source_nonempty : {n}.sourceCount ≠ 0 := by decide +kernel")
  fact "source_post" s!"{n}.input.ret (.ptr (.js {n}.sourceBuffer) {n}.sourceOffset) = {n}.output"
  emit (header ++ s!"theorem {n}.transport (NR : NumV → NumV → Prop) (FR : Ren → {n}.F.S → {n}.F.S → Prop)
      (R : Ren) (C₀ C : CSrv) (live framed : Nat → Prop)
      (before after : List Val) (old old' : List Event) (s : St {n}.F.S)
      (h : StateR NR FR R live framed before after old old' {n}.input s) :
      ∃ result, interpC (step {n}.F s).run C = some (result,C) ∧
        StateR NR FR R live framed before after old old' {n}.output result ∧
        result.ctl = .ret (.ptr (.js (R.a {n}.sourceBuffer)) {n}.sourceOffset) ∧ result.heap = s.heap := by
    obtain ⟨_,run,related⟩ := step_ptr_typed_buffer_from_source {n}.F NR FR R C₀ C live framed before after old old'
      {n}.input s h {n}.sourceFunction {n}.sourceView {n}.sourceBuffer {n}.sourceOffset {n}.sourceCount
      {n}.sourceCallee {n}.sourceViewObject {n}.sourceBufferObject {n}.sourceKind {n}.sourceData {n}.sourceThis {n}.sourceBytes
      {n}.source_control {n}.source_callee {n}.source_code {n}.source_view {n}.source_view_kind {n}.source_buffer
      {n}.source_buffer_kind {n}.source_nonempty
    exact ⟨_,run,{n}.source_post ▸ related,rfl,rfl⟩")

/-- Convert the source-selected integral literal through the actual BigInt builtin. -/
elab "host_transport_fixed_bigint " f:term ", " s:term " to " t:term " as " name:ident : command => do
  let pre := (← getCurrNamespace) ++ name.getId
  liftTermElabM do
    let f ← Term.elabTermEnsuringType f (mkConst ``Ffi)
    let ty := mkApp (mkConst ``St) (mkApp (mkConst ``Ffi.S) f)
    let s ← Term.elabTermEnsuringType s ty
    let t ← Term.elabTermEnsuringType t ty
    let add (tag : String) (v : Lean.Expr) := addData (pre ++ Name.mkSimple tag) v
    add "F" f; add "input" s; add "output" t
    let ctl ← whnf (← mkAppM ``St.ctl #[s])
    let a ← field (← field ctl ``Ctl.call 3 0) ``Val.obj 1 0
    let this ← field ctl ``Ctl.call 3 1
    let args ← field ctl ``Ctl.call 3 2
    let x ← field (← field (← field args ``List.cons 3 1) ``Val.num 1 0) ``NumV.lit 1 0
    let i ← field (← mkAppM ``F64.toInt? #[x]) ``Option.some 2 1
    let o ← field (← mkAppM ``St.obj? #[s,a]) ``Option.some 2 1
    let code ← field (← mkAppM ``Obj.kind #[o]) ``Kind.fn 1 0
    let data ← field code ``Code.native 2 1
    for (tag,v) in [("sourceFunction",a),("sourceThis",this),("sourceNumber",x),("sourceInteger",i),
      ("sourceCallee",o),("sourceData",data)] do add tag v
  let n := "_root_." ++ pre.toString
  let header := "open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric in\n"
  let fact (tag prop : String) := emit (header ++ s!"theorem {n}.{tag} : {prop} := by host_kernel_rfl")
  fact "source_control" s!"{n}.input.ctl = .call (.obj {n}.sourceFunction) {n}.sourceThis [.num (.lit {n}.sourceNumber)]"
  fact "source_callee" s!"{n}.input.heap.get {n}.sourceFunction = some (.obj {n}.sourceCallee)"
  fact "source_code" s!"{n}.sourceCallee.kind = .fn (.native (.num .bigint) {n}.sourceData)"
  fact "source_integer" s!"F64.toInt? {n}.sourceNumber = some {n}.sourceInteger"
  fact "source_post" s!"{n}.input.ret (.big {n}.sourceInteger) = {n}.output"
  emit (header ++ s!"theorem {n}.transport (NR : NumV → NumV → Prop) (FR : Ren → {n}.F.S → {n}.F.S → Prop)
      (R : Ren) (C₀ C : CSrv) (ν : Nat → F64) (live framed : Nat → Prop)
      (before after : List Val) (old old' : List Event) (s : St {n}.F.S)
      (h : StateR NR FR R live framed before after old old' {n}.input s)
      (argument : (Annotated.Value.literal (.lit {n}.sourceNumber)).Holds ν C R (callArgument s.ctl 0)) :
      ∃ result, interpC (step {n}.F s).run C = some (result,C) ∧
        StateR NR FR R live framed before after old old' {n}.output result ∧
        result.ctl = .ret (.big {n}.sourceInteger) ∧ result.heap = s.heap := by
    obtain ⟨_,run,related⟩ := step_bigint_fixed_from_source {n}.F NR FR R C₀ C ν live framed before after old old'
      {n}.input s h {n}.sourceFunction {n}.sourceCallee {n}.sourceData {n}.sourceThis {n}.sourceNumber {n}.sourceInteger
      {n}.source_control {n}.source_callee {n}.source_code {n}.source_integer argument
    exact ⟨_,run,{n}.source_post ▸ related,rfl,rfl⟩")

end Host.Ts.Owned.Parametric.Driver
