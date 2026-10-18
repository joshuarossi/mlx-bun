import host.mlx.NativeIntegerConversionRetained
import host.ts.RenameRuntimeSourceCut
import host.ts.RenameRouteDriver

set_option Elab.async false

namespace Host.Ts.Owned.Annotated.Driver
open Lean Elab Command Meta
open Parametric.Driver

/-- Select original BigInt conversion from a canonical integral literal. The
schema form supports variable integral meanings; the ordinary frontend form
uses a closed current expression, as produced for fixed native-vector counts. -/
elab "host_retained_bigint " f:term ", " s:term " using " initial:term " to " t:term " using " next:term " as " name:ident : command => do
  let pre := (← getCurrNamespace) ++ name.getId
  liftTermElabM do
    let f ← Term.elabTermEnsuringType f (mkConst ``Ffi)
    let stateTy := mkApp (mkConst ``St) (mkApp (mkConst ``Ffi.S) f)
    let s ← Term.elabTermEnsuringType s stateTy
    let t ← Term.elabTermEnsuringType t stateTy
    let ctl ← whnf (← mkAppM ``St.ctl #[s])
    unless ctl.isAppOfArity ``Ctl.call 3 do throwError "host_retained_bigint: expected source call"
    let address ← field ctl.getAppArgs[0]! ``Val.obj 1 0
    let values := ctl.getAppArgs[2]!
    let value ← whnf (← field (← field values ``List.cons 3 1) ``Val.num 1 0)
    unless value.isAppOfArity ``NumV.lit 1 do throwError "host_retained_bigint: expected literal numeric argument"
    let sourceValue := value.getAppArgs[0]!
    unless (← whnf (← field values ``List.cons 3 2)).isAppOfArity ``List.nil 1 do
      throwError "host_retained_bigint: expected exactly one argument"
    let object ← field (← mkAppM ``St.obj? #[s,address]) ``Option.some 2 1
    let code ← whnf (← field (← mkAppM ``Obj.kind #[object]) ``Kind.fn 1 0)
    let native ← whnf (← field code ``Code.native 2 0)
    let builtin ← whnf (← field native ``Native.num 1 0)
    unless builtin.isConstOf ``NumN.bigint do throwError "host_retained_bigint: expected native BigInt"
    let integer ← field (← mkAppM ``F64.toInt? #[sourceValue]) ``Option.some 2 1
    for (tag,value) in [("F",f),("input",s),("output",t),("address",address),("object",object),("data",code.getAppArgs[1]!),
      ("sourceValue",sourceValue),("integer",integer),("sourceThis",ctl.getAppArgs[1]!)] do
      let type? := if tag == "input" || tag == "output" then
        some (mkApp (mkConst ``St) (mkApp (mkConst ``Ffi.S) (mkConst (pre ++ `F)))) else none
      addData (pre ++ Name.mkSimple tag) value type?
    let initial ← Term.elabTermEnsuringType initial (mkConst ``SSrv)
    let next ← Term.elabTermEnsuringType next (mkConst ``SSrv)
    addData (pre ++ `initialServer) (← mkAppM ``numberServer #[initial])
    addData (pre ++ `nextServer) (← mkAppM ``numberServer #[next])
  let n := "_root_." ++ pre.toString
  let header := "open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated in\n"
  for (fact,type) in [
    ("source_control",s!"{n}.input.ctl = .call (.obj {n}.address) {n}.sourceThis [.num (.lit {n}.sourceValue)]"),
    ("source_heap",s!"{n}.input.heap.get {n}.address = some (.obj {n}.object)"),
    ("source_kind",s!"{n}.object.kind = .fn (.native (.num .bigint) {n}.data)"),
    ("source_decode",s!"F64.toInt? {n}.sourceValue = some {n}.integer"),
    ("source_roundtrip",s!"F64.ofInt {n}.integer = {n}.sourceValue")]
    do Parametric.Driver.emit (header ++ s!"theorem {n}.{fact} : {type} := by host_kernel_rfl")
  Parametric.Driver.emit (header ++ s!"theorem {n}.source_run (C : CSrv) : interpC (step {n}.F {n}.input).run C = some ({n}.output,C) := by host_kernel_rfl")
  Parametric.Driver.emit (header ++ s!"theorem {n}.source_step : interpS (step {n}.F {n}.input).run {n}.initialServer = some ({n}.output,{n}.nextServer) := by host_kernel_rfl")
  let parameters := s!"(notes : RetainedNotes) (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
      (FR : Ren → {n}.F.S → {n}.F.S → Prop) (live framed : Nat → Prop) (before after : List Val) (old old' : List Event)
      (s : St {n}.F.S) (inst : Inst ν₀ {n}.initialServer C₀)
      (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' {n}.input s)
      (inventory : RetainedInventory notes ν₀ ν C₀ C R live {n}.input s)
      (fnRole thisRole : Annotated.Value) (meaning : SymE)
      (note : notes.runtime.control = callNote fnRole thisRole [.literal meaning])"
  let conclusion := s!"∃ result, interpC (step {n}.F {n}.input).run C₀ = some ({n}.output,C₀) ∧
        interpC (step {n}.F s).run C = some (result,C) ∧
        Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' {n}.output result ∧
        RetainedInventory (notes.withRuntime ⟨returnNote (.exactInteger meaning),notes.runtime.stack,notes.runtime.cells⟩)
          ν₀ ν C₀ C R live {n}.output result ∧ result.ffi = s.ffi ∧ Inst ν₀ {n}.nextServer C₀"
  Parametric.Driver.emit (header ++ s!"theorem {n}.retained_integral_transport {parameters}
      (schema : IntegerLiteralSchema meaning) (sourceValid : schema.valid ν₀) (targetValid : schema.valid ν) :
      {conclusion} := by
      obtain ⟨result,left,right,post,retained,native⟩ := inventory.bigint_literal_step {n}.F FR h {n}.address
        {n}.object {n}.data {n}.sourceThis {n}.sourceValue {n}.source_control {n}.source_heap {n}.source_kind
        meaning schema sourceValid targetValid fnRole thisRole note
      have source := {n}.source_run C₀
      have same := congrArg Prod.fst (Option.some.inj (left.symm.trans source))
      dsimp only at same
      rw [same] at post retained
      exact ⟨result,source,right,post,retained,native,pure_step_inst {n}.F ν₀ {n}.initialServer {n}.nextServer C₀
        {n}.input {n}.output inst {n}.source_step source⟩")
  Parametric.Driver.emit (header ++ s!"theorem {n}.retained_transport {parameters}
      (closed : ∀ valuation, meaning.eval valuation = {n}.sourceValue) : {conclusion} := by
      exact {n}.retained_integral_transport notes ν₀ ν C₀ C R FR live framed before after old old' s inst h inventory
        fnRole thisRole meaning note
        (IntegerLiteralSchema.closed meaning {n}.integer (fun valuation => (closed valuation).trans {n}.source_roundtrip.symm)
          (by rw [{n}.source_roundtrip]; exact {n}.source_decode)) True.intro True.intro")

end Host.Ts.Owned.Annotated.Driver
