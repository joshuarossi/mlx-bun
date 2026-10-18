import host.ts.renameOrdinary.DriverBinding
import host.ts.RenameShapeBindingEffects
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
namespace Host.Load.Run.Full.Ordinary
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric

theorem nthD_one (vs : List Val) (h : vs[1]? = some (natV 1)) : nthD .undef vs 1 = natV 1 := by
  cases vs with
  | nil => simp at h
  | cons x xs => cases xs with
    | nil => simp at h
    | cons y ys => exact Option.some.inj h

theorem sequence_binding_control {S : Type} (s : St S) (R : Ren) (vs : List Val) :
    (arrayBinding s Binding19.sourcePatterns vs (R.env Binding19.sourceEnv) Binding19.sourceMode Binding19.sourceKind).ctl =
      .bind (.id Binding20.sourceName) (nthD .undef vs 1) (R.env Binding20.sourceEnv) .init Binding20.sourceKind := by
  have hp : Binding19.sourcePatterns = [none,some (.id Binding20.sourceName),some (.id Binding22.sourceName)] := by host_kernel_rfl
  have he : Binding19.sourceEnv = Binding20.sourceEnv := by host_kernel_rfl
  have hm : Binding19.sourceMode = .init := by host_kernel_rfl
  have hk : Binding19.sourceKind = Binding20.sourceKind := by host_kernel_rfl
  rw [hp,he,hm,hk]
  cases vs <;> rfl

theorem shape_binding_sequence_transport (NR : NumV → NumV → Prop) (FR : Ren → P.F.S → P.F.S → Prop)
    (R : Ren) (C₀ C : CSrv) (live framed : Nat → Prop) (before after : List Val)
    (old old' : List Event) (s : St P.F.S)
    (h : StateR NR FR R live framed before after old old' P.RestStream.micro0.micro0.s18 s)
    (notFramed : ¬ framed Binding19.sourceAddress) (targetBound : s.next ≤ 2^64)
    (vs : List Val) (sequence : vs[1]? = some (natV 1))
    (arrayHeap : s.heap.get (R.a Binding19.sourceAddress) = some (valueArray vs)) :
    ∃ result, runC P.F 7 s C = some (result,C) ∧
      StateR NR FR R live framed before after old old' P.RestStream.micro0.micro0.s25 result ∧
      result.heap.get (R.a Binding20.sourceAddress) = some (.cell (some (natV 1))) ∧ live Binding20.sourceAddress := by
  obtain ⟨s19,hr18,h19⟩ := Binding18.transport NR FR R C₀ C live framed before after old old' s h
  have heap19 := step_declaration_value_heap P.F NR FR R live framed before after old old'
    Binding18.input s s19 C C h Binding18.sourceValue Binding18.sourceKind Binding18.sourcePattern
    Binding18.sourceRest Binding18.sourceEnv Binding18.sourceTail Binding18.source_control Binding18.source_frame
    Binding18.source_kind hr18
  obtain ⟨s20,hr19,h20⟩ := Binding19.transport NR FR R C₀ C live framed before after old old' s19 h19 notFramed
  have array19 : s19.heap.get (R.a Binding19.sourceAddress) = some (valueArray vs) := by rw [heap19]; exact arrayHeap
  have exact20 := step_bind_array_fields P.F NR FR R live framed before after old old' Binding19.input s19 s20 C C h19
    Binding19.sourcePatterns Binding19.sourceAddress ⟨.array vs,.obj aArrayProto,[],[],true⟩ vs
    Binding19.sourceEnv Binding19.sourceMode Binding19.sourceKind Binding19.source_control array19 rfl hr19
  have control20 : s20.ctl = .bind (.id Binding20.sourceName) (natV 1) (R.env Binding20.sourceEnv) .init Binding20.sourceKind := by
    rw [exact20]
    have hc := sequence_binding_control s19 R vs
    rw [nthD_one vs sequence] at hc
    exact hc
  have hb20 : s20.next ≤ 2^64 := by rw [h.target_next_eq h20 binding_next20]; exact targetBound
  obtain ⟨s21,hr20,h21⟩ := Binding20.transport NR FR R C₀ C live framed before after old old' s20 h20 hb20
  have stored := step_bind_init_cell_fields P.F NR FR R live framed before after old old' Binding20.input s20 s21 C C h20
    Binding20.sourceName Binding20.sourceValue (natV 1) Binding20.sourceEnv Binding20.sourceKind Binding20.sourceAddress
    Binding20.source_control control20 Binding20.source_lookup hb20 hr20
  obtain ⟨s22,hr21,h22⟩ := Binding21.transport NR FR R C₀ C live framed before after old old' s21 h21
  have heap22 := step_array_binding_next_heap P.F NR FR R live framed before after old old' Binding21.input s21 s22 C C h21
    Binding21.sourceValue Binding21.sourcePatterns Binding21.sourceValues Binding21.sourceEnv Binding21.sourceMode Binding21.sourceKind
    Binding21.sourceTail Binding21.source_control Binding21.source_frame hr21
  have hb22 : s22.next ≤ 2^64 := by rw [h.target_next_eq h22 binding_next22]; exact targetBound
  obtain ⟨s23,hr22,h23⟩ := Binding22.transport NR FR R C₀ C live framed before after old old' s22 h22 hb22
  have liveS : live Binding20.sourceAddress := by
    have hl := h20.controlLive
    change treeSupport live (Encode.ctl Binding20.input.ctl) at hl
    rw [Binding20.source_control] at hl
    exact env_lookup_live _ _ _ hl.2.2.1 Binding20.source_lookup
  have liveD : live Binding22.sourceAddress := by
    have hl := h22.controlLive
    change treeSupport live (Encode.ctl Binding22.input.ctl) at hl
    rw [Binding22.source_control] at hl
    exact env_lookup_live _ _ _ hl.2.2.1 Binding22.source_lookup
  have neq : R.a Binding20.sourceAddress ≠ R.a Binding22.sourceAddress := by
    intro he
    have same := h20.heap.inj _ _ liveS liveD he
    have hn : Binding20.sourceAddress ≠ Binding22.sourceAddress := by decide +kernel
    exact hn same
  have heap23 := step_bind_init_heap_other P.F NR FR R live framed before after old old' Binding22.input s22 s23 C C h22
    Binding22.sourceName Binding22.sourceValue Binding22.sourceEnv Binding22.sourceKind Binding22.sourceAddress
    Binding22.source_control Binding22.source_lookup hb22 hr22 (R.a Binding20.sourceAddress) neq
  obtain ⟨s24,hr23,h24⟩ := Binding23.transport NR FR R C₀ C live framed before after old old' s23 h23
  obtain ⟨result,hr24,h25⟩ := Binding24.transport NR FR R C₀ C live framed before after old old' s24 h24
  have heap24 := step_array_binding_next_heap P.F NR FR R live framed before after old old' Binding23.input s23 s24 C C h23
    Binding23.sourceValue Binding23.sourcePatterns Binding23.sourceValues Binding23.sourceEnv Binding23.sourceMode Binding23.sourceKind
    Binding23.sourceTail Binding23.source_control Binding23.source_frame hr23
  have frame24 : Binding24.input.stack = .s (.declNext Binding24.sourceKind [] Binding24.sourceEnv)::Binding24.sourceTail := by host_kernel_rfl
  have heap25 := step_empty_declaration_next_heap P.F NR FR R live framed before after old old' Binding24.input s24 result C C h24
    Binding24.sourceValue Binding24.sourceEnv Binding24.sourceKind Binding24.sourceTail Binding24.source_control frame24 hr24
  refine ⟨result,?_,h25,?_,liveS⟩
  ·
    apply runC_cons P.F 6 s s19 result C C C (h.control.isHalt_eq.trans binding_active18) hr18
    apply runC_cons P.F 5 s19 s20 result C C C (h19.control.isHalt_eq.trans binding_active19) hr19
    apply runC_cons P.F 4 s20 s21 result C C C (h20.control.isHalt_eq.trans binding_active20) hr20
    apply runC_cons P.F 3 s21 s22 result C C C (h21.control.isHalt_eq.trans binding_active21) hr21
    apply runC_cons P.F 2 s22 s23 result C C C (h22.control.isHalt_eq.trans binding_active22) hr22
    apply runC_cons P.F 1 s23 s24 result C C C (h23.control.isHalt_eq.trans binding_active23) hr23
    apply runC_cons P.F 0 s24 result result C C C (h24.control.isHalt_eq.trans binding_active24) hr24
    rfl

  · rw [heap25,heap24,heap23,heap22]
    exact stored

end Host.Load.Run.Full.Ordinary
