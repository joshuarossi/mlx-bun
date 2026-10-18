import host.ts.RenameRouteDriver
import host.ts.RenameParametricArrayLength

namespace Host.Ts.Owned.Parametric.Driver
open Lean Elab Command Meta

/-- Select an actual array length read; all source facts and its endpoint are
checked. The resulting target length is derived from related array elements. -/
elab "host_transport_array_length " f:term ", " s:term " to " t:term " as " name:ident : command => do
  let pre := (← getCurrNamespace) ++ name.getId
  liftTermElabM do
    let f ← Term.elabTermEnsuringType f (mkConst ``Ffi)
    let stateTy := mkApp (mkConst ``St) (mkApp (mkConst ``Ffi.S) f)
    let s ← Term.elabTermEnsuringType s stateTy
    let t ← Term.elabTermEnsuringType t stateTy
    for (tag,value) in [("F",f),("input",s),("output",t)] do
      let type? := if tag == "F" then none else
        some (mkApp (mkConst ``St) (mkApp (mkConst ``Ffi.S) (mkConst (pre ++ `F))))
      addData (pre ++ Name.mkSimple tag) value type?
    let add (tag : String) (value : Lean.Expr) := addData (pre ++ Name.mkSimple tag) value
    let ctl ← mkAppM ``St.ctl #[s]
    let a ← field (← field ctl ``Ctl.ret 1 0) ``Val.obj 1 0
    let stack ← mkAppM ``St.stack #[s]
    let frame ← field (← field stack ``List.cons 3 1) ``Frame.e 1 0
    let opt ← field frame ``ExprF.member 2 1
    let obj ← field (← mkAppM ``St.obj? #[s,a]) ``Option.some 2 1
    let vs ← field (← mkAppM ``Obj.kind #[obj]) ``Kind.array 1 0
    for (tag,value) in [("sourceAddress",a),("sourceObject",obj),("sourceElements",vs),
      ("sourceOptional",opt),("sourceTail",← field stack ``List.cons 3 2),
      ("sourceLength",← whnf (← mkAppM ``len #[vs]))] do add tag value
  let n := "_root_." ++ pre.toString
  let header := "open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric in\n"
  let fact (tag proposition : String) := emit (header ++ s!"theorem {n}.{tag} : {proposition} := by host_kernel_rfl")
  fact "source_control" s!"{n}.input.ctl = .ret (.obj {n}.sourceAddress)"
  fact "source_frame" s!"{n}.input.stack = .e (.member kLength {n}.sourceOptional)::{n}.sourceTail"
  fact "source_heap" s!"{n}.input.heap.get {n}.sourceAddress = some (.obj {n}.sourceObject)"
  fact "source_kind" s!"{n}.sourceObject.kind = .array {n}.sourceElements"
  fact "source_length" s!"len {n}.sourceElements = {n}.sourceLength"
  emit (header ++ s!"theorem {n}.source_run (C₀ : CSrv) : interpC (step {n}.F {n}.input).run C₀ = some ({n}.output,C₀) := by host_kernel_rfl")
  emit (header ++ s!"theorem {n}.transport (NR : NumV → NumV → Prop) (FR : Ren → {n}.F.S → {n}.F.S → Prop)
      (R : Ren) (C₀ C : CSrv) (live framed : Nat → Prop) (before after : List Val) (old old' : List Event)
      (s : St {n}.F.S) (h : StateR NR FR R live framed before after old old' {n}.input s)
      (notFramed : ¬ framed {n}.sourceAddress)
      (literalRole : NR (.lit (F64.ofNat {n}.sourceLength)) (.lit (F64.ofNat {n}.sourceLength))) :
      ∃ result, interpC (step {n}.F s).run C = some (result,C) ∧
        StateR NR FR R live framed before after old old' {n}.output result ∧
        result.ctl = .ret (natV {n}.sourceLength) := by
    obtain ⟨result,hr₀,hr,hpost,hctl⟩ := step_array_length_from_source {n}.F NR FR R C₀ C
      live framed before after old old' {n}.input s h {n}.sourceAddress {n}.sourceObject
      {n}.sourceElements {n}.sourceOptional {n}.sourceTail {n}.source_control {n}.source_frame
      {n}.source_heap {n}.source_kind notFramed (by simpa only [{n}.source_length] using literalRole)
    rw [{n}.source_run] at hr₀
    have hs := congrArg Prod.fst (Option.some.inj hr₀)
    dsimp only at hs
    rw [← hs] at hpost
    exact ⟨result,hr,hpost,by simpa only [{n}.source_length] using hctl⟩")

end Host.Ts.Owned.Parametric.Driver
