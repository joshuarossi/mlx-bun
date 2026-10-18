import host.ts.renameOrdinary.VectorToConcatPointerPrefix
import host.ts.RenameRoutePrivateFields
import host.ts.RenameRouteComposition
import host.ts.RenameRouteHeapFields
import host.ts.RenameRouteFields
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
namespace Host.Load.Run.Full.Ordinary.VectorToConcat
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric

theorem slot_view_at_entry : SlotDeclaration299.input.heap.get 3126701 = some (.obj Pointer309.viewObject) := by host_kernel_rfl
theorem slot_entry_control : SlotDeclaration299.input.ctl = .ret (.obj 3126701) := by host_kernel_rfl
theorem slot_binding_other : SlotBinding300.sourceAddress ≠ 3126700 := by decide +kernel

/-- The eleven real steps after constructing the null slot initialize its
binding, evaluate ptr(slot), and return its mapped JS pointer. The slot's
existing backing buffer is framed through the entire path. -/
theorem slot_pointer_transport_heap (NR : NumV → NumV → Prop) (FR : Ren → LSt → LSt → Prop)
    (R : Ren) (C₀ C : CSrv) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s : St LSt)
    (h : StateR NR FR R live framed before after old old' SlotDeclaration299.input s)
    (bound : s.next ≤ 2^64) :
    ∃ result, runC P.F 11 s C = some (result,C) ∧
      StateR NR FR R live framed before after old old' Pointer309.output result ∧
      result.ctl = .ret (.ptr (.js (R.a 3126700)) 0) ∧
      (∀ a, live a → a ≠ SlotBinding300.sourceAddress → result.heap.get (R.a a) = s.heap.get (R.a a)) := by
  obtain ⟨s300,hr299,h300⟩ := SlotDeclaration299.transport NR FR R C₀ C live framed before after old old' s h
  have bound300 : s300.next ≤ 2^64 := by rw [h.target_next_eq h300 (by host_kernel_rfl)]; exact bound
  obtain ⟨s301,hr300,h301⟩ := SlotBinding300.transport NR FR R C₀ C live framed before after old old' s300 h300 bound300
  obtain ⟨s302,hr301,h302⟩ := SlotDone301.transport NR FR R C₀ C live framed before after old old' s301 h301
  obtain ⟨s303,hr302,h303⟩ := PointerBlock302.transport NR FR R C₀ C live framed before after old old' s302 h302
  obtain ⟨s304,hr303,h304⟩ := PointerDeclaration303.transport NR FR R C₀ C live framed before after old old' s303 h303
  obtain ⟨s305,hr304,h305⟩ := PointerCall304.transport NR FR R C₀ C live framed before after old old' s304 h304
  obtain ⟨v305,hr305,h306,_⟩ := PointerVariable305.transport NR FR R C₀ C live framed before after old old' s305 h305
  let s306 := s305.ret v305
  obtain ⟨s307,hr306,h307⟩ := PointerCallee306.transport NR FR R C₀ C live framed before after old old' s306 h306
  obtain ⟨v307,hr307,h308,_⟩ := SlotVariable307.transport NR FR R C₀ C live framed before after old old' s307 h307
  let s308 := s307.ret v307
  obtain ⟨s309,hr308,h309⟩ := SlotArgument308.transport NR FR R C₀ C live framed before after old old' s308 h308
  obtain ⟨result,hr309,h310,hc310,heap310,_⟩ := Pointer309.transport NR FR R C₀ C live framed before after old old' s309 h309
  have hh300 := step_declaration_value_heap P.F NR FR R live framed before after old old' SlotDeclaration299.input s s300 C C h
    SlotDeclaration299.sourceValue SlotDeclaration299.sourceKind SlotDeclaration299.sourcePattern SlotDeclaration299.sourceRest
    SlotDeclaration299.sourceEnv SlotDeclaration299.sourceTail SlotDeclaration299.source_control SlotDeclaration299.source_frame
    SlotDeclaration299.source_kind hr299
  have cellLive : live SlotBinding300.sourceAddress := by
    have hl := h300.controlLive
    change treeSupport live (Encode.ctl SlotBinding300.input.ctl) at hl
    rw [SlotBinding300.source_control] at hl
    exact env_lookup_live SlotBinding300.sourceName SlotBinding300.sourceEnv SlotBinding300.sourceAddress hl.2.2.1 SlotBinding300.source_lookup
  have hh301 := step_bind_init_heap_other P.F NR FR R live framed before after old old' SlotBinding300.input s300 s301 C C h300
    SlotBinding300.sourceName SlotBinding300.sourceValue SlotBinding300.sourceEnv SlotBinding300.sourceKind SlotBinding300.sourceAddress
    SlotBinding300.source_control SlotBinding300.source_lookup bound300 hr300
  have hh302 := step_declaration_next_heap P.F NR FR R live framed before after old old' SlotDone301.input s301 s302 C C h301
    SlotDone301.sourceValue SlotDone301.sourceKind SlotDone301.sourceRest SlotDone301.sourceEnv SlotDone301.sourceTail
    SlotDone301.source_control SlotDone301.source_frame hr301
  have hh303 := step_block_next_heap P.F NR FR R live framed before after old old' PointerBlock302.input s302 s303 C C h302
    PointerBlock302.sourceValue PointerBlock302.sourceStatement PointerBlock302.sourceRest PointerBlock302.sourceEnv PointerBlock302.sourceTail
    PointerBlock302.source_control PointerBlock302.source_frame hr302
  have hh304 := step_statement_heap P.F NR FR R live framed before after old old' PointerDeclaration303.input s303 s304 C C h303
    PointerDeclaration303.sourceAction PointerDeclaration303.sourceEnv PointerDeclaration303.source_control hr303
  have hh305 := step_identifier_call_heap P.F NR FR R live framed before after old old' PointerCall304.input s304 s305 C₀ C C h304
    PointerCall304.sourceName PointerCall304.sourceArgs PointerCall304.sourceOptional PointerCall304.sourceEnv PointerCall304.source_control hr304
  have hh307 := step_callStart_heap P.F NR FR R live framed before after old old' PointerCallee306.input s306 s307 C C h306
    (.callee PointerCallee306.sourceOptional) PointerCallee306.sourceAddress .undef PointerCallee306.sourceArgs PointerCallee306.sourceEnv
    PointerCallee306.sourceTail PointerCallee306.source_control PointerCallee306.source_frame hr306
  have hh309 := step_argument_heap_from_source P.F NR FR R live framed before after old old' SlotArgument308.input s308 s309 C C h308
    SlotArgument308.sourceValue SlotArgument308.sourceKind SlotArgument308.sourceFunction SlotArgument308.sourceThis
    SlotArgument308.sourceAcc SlotArgument308.sourceRest SlotArgument308.sourceEnv SlotArgument308.sourceTail
    SlotArgument308.source_control SlotArgument308.source_frame (by decide) hr308
  have framedBuffer : ∀ a, live a → a ≠ SlotBinding300.sourceAddress → result.heap.get (R.a a) = s.heap.get (R.a a) := by
    intro a ha other
    have mappedOther : R.a a ≠ R.a SlotBinding300.sourceAddress := by
      intro he
      exact other (h.heap.inj a SlotBinding300.sourceAddress ha cellLive he)
    rw [heap310,hh309]
    change s307.heap.get (R.a a) = _
    rw [hh307]
    change s305.heap.get (R.a a) = _
    rw [hh305,hh304,hh303,hh302,hh301 (R.a a) mappedOther,hh300]
  refine ⟨result,?_,h310,hc310,framedBuffer⟩
  apply runC_cons P.F 10 s s300 result C C C (h.control.isHalt_eq.trans (by host_kernel_rfl)) hr299
  apply runC_cons P.F 9 s300 s301 result C C C (h300.control.isHalt_eq.trans (by host_kernel_rfl)) hr300
  apply runC_cons P.F 8 s301 s302 result C C C (h301.control.isHalt_eq.trans (by host_kernel_rfl)) hr301
  apply runC_cons P.F 7 s302 s303 result C C C (h302.control.isHalt_eq.trans (by host_kernel_rfl)) hr302
  apply runC_cons P.F 6 s303 s304 result C C C (h303.control.isHalt_eq.trans (by host_kernel_rfl)) hr303
  apply runC_cons P.F 5 s304 s305 result C C C (h304.control.isHalt_eq.trans (by host_kernel_rfl)) hr304
  apply runC_cons P.F 4 s305 s306 result C C C (h305.control.isHalt_eq.trans (by host_kernel_rfl)) hr305
  apply runC_cons P.F 3 s306 s307 result C C C (h306.control.isHalt_eq.trans (by host_kernel_rfl)) hr306
  apply runC_cons P.F 2 s307 s308 result C C C (h307.control.isHalt_eq.trans (by host_kernel_rfl)) hr307
  apply runC_cons P.F 1 s308 s309 result C C C (h308.control.isHalt_eq.trans (by host_kernel_rfl)) hr308
  apply runC_cons P.F 0 s309 result result C C C (h309.control.isHalt_eq.trans (by host_kernel_rfl)) hr309
  rfl
theorem slot_pointer_transport (NR : NumV → NumV → Prop) (FR : Ren → LSt → LSt → Prop)
    (R : Ren) (C₀ C : CSrv) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s : St LSt)
    (h : StateR NR FR R live framed before after old old' SlotDeclaration299.input s)
    (bound : s.next ≤ 2^64) :
    ∃ result, runC P.F 11 s C = some (result,C) ∧
      StateR NR FR R live framed before after old old' Pointer309.output result ∧
      result.ctl = .ret (.ptr (.js (R.a 3126700)) 0) ∧
      result.heap.get (R.a 3126700) = s.heap.get (R.a 3126700) := by
  obtain ⟨result,run,hr,hc,frame⟩ := slot_pointer_transport_heap NR FR R C₀ C live framed before after old old' s h bound
  have viewLive : live 3126701 := by have hl := h.controlLive; rw [slot_entry_control] at hl; exact hl.1
  obtain ⟨_,_,_,bufferLive⟩ := h.heap.read_typedBuffer 3126701 3126700 0 1 Pointer309.viewObject .u64
    viewLive slot_view_at_entry Pointer309.source_view_kind
  exact ⟨result,run,hr,hc,frame _ bufferLive (Ne.symm slot_binding_other)⟩
end Host.Load.Run.Full.Ordinary.VectorToConcat
