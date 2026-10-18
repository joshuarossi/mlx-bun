import host.ts.renameOrdinary.DriverMapEntry
import host.ts.RenameClosureEffects
import host.ts.RenameMapBodyEffects
import host.ts.RenameParameterBodyFrame
import host.ts.RenameRoutePrivateFields
import host.ts.RenameRouteHeapFields
import host.ts.RenameCallbackEffects

set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
namespace Host.Load.Run.Full.Ordinary
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric

theorem map_entry_fields (NR : NumV → NumV → Prop) (FR : Ren → P.F.S → P.F.S → Prop)
    (R : Ren) (C₀ C : CSrv) (live framed : Nat → Prop) (before after : List Val) (old old' : List Event)
    (s : St P.F.S) (h : StateR NR FR R live framed before after old old' P.RestStream.micro0.micro0.s60 s)
    (globalLive : live aGlobal) (globalFixed : R.a aGlobal = aGlobal)
    (targetBound : s.next+4+(blockNames MapEntry65.sourceBody).length ≤ 2^64) :
    ∃ result, runC P.F 14 s C = some (result,C) ∧
      StateR NR FR R (mapBodyLive live) framed before after old old' P.RestStream.micro0.micro0.s74 result ∧
      (∀ a, a < s.next → result.heap.get a = s.heap.get a) := by
  have hbcall : s.next+2+(paramNames MapEntry60.sourceFunction).length ≤ 2^64 := by
    rw [Nat.add_assoc,map_call_cost]
    omega
  obtain ⟨s61,hr60,h61⟩ := MapEntry60.transport NR FR R C₀ C live framed before after old old' s h hbcall
  have heap61 := step_closure_heap_below P.F NR FR R live framed before after old old' MapEntry60.input s s61 C C h MapEntry60.address MapEntry60.object MapEntry60.sourceFunction MapEntry60.sourceEnv MapEntry60.sourceArrow MapEntry60.sourceHome MapEntry60.sourceThis MapEntry60.sourceArgs MapEntry60.source_control MapEntry60.source_heap MapEntry60.source_kind hbcall hr60
  obtain ⟨s62,hr61,h62⟩ := MapEntry61.transport NR FR R C₀ C (mapCallLive live) framed before after old old' s61 h61
  have heap62 := step_parameter_id_heap_from_source P.F NR FR R (mapCallLive live) framed before after old old' MapEntry61.input s61 s62 C C h61 MapEntry61.sourceValue MapEntry61.sourceFunction MapEntry61.sourceName MapEntry61.sourceParams MapEntry61.sourceArgs MapEntry61.sourceEnv MapEntry61.sourceTail MapEntry61.source_control MapEntry61.source_frame hr61
  have hb62 : s62.next ≤ 2^64 := by rw [h.target_next_add h62 3 map_next62]; omega
  obtain ⟨s63,hr62,h63⟩ := MapEntry62.transport NR FR R C₀ C (mapCallLive live) framed before after old old' s62 h62 hb62
  have heap63 := step_bind_init_heap_other P.F NR FR R (mapCallLive live) framed before after old old' MapEntry62.input s62 s63 C C h62 MapEntry62.sourceName MapEntry62.sourceValue MapEntry62.sourceEnv MapEntry62.sourceKind MapEntry62.sourceAddress MapEntry62.source_control MapEntry62.source_lookup hb62 hr62
  obtain ⟨s64,hr63,h64⟩ := MapEntry63.transport NR FR R C₀ C (mapCallLive live) framed before after old old' s63 h63
  have heap64 := step_parameter_id_heap_from_source P.F NR FR R (mapCallLive live) framed before after old old' MapEntry63.input s63 s64 C C h63 MapEntry63.sourceValue MapEntry63.sourceFunction MapEntry63.sourceName MapEntry63.sourceParams MapEntry63.sourceArgs MapEntry63.sourceEnv MapEntry63.sourceTail MapEntry63.source_control MapEntry63.source_frame hr63
  have hb64 : s64.next ≤ 2^64 := by rw [h.target_next_add h64 3 map_next64]; omega
  obtain ⟨s65,hr64,h65⟩ := MapEntry64.transport NR FR R C₀ C (mapCallLive live) framed before after old old' s64 h64 hb64
  have heap65 := step_bind_init_heap_other P.F NR FR R (mapCallLive live) framed before after old old' MapEntry64.input s64 s65 C C h64 MapEntry64.sourceName MapEntry64.sourceValue MapEntry64.sourceEnv MapEntry64.sourceKind MapEntry64.sourceAddress MapEntry64.source_control MapEntry64.source_lookup hb64 hr64
  have hb65 : s65.next+(blockNames MapEntry65.sourceBody).length ≤ 2^64 := by
    rw [h.target_next_add h65 3 map_next65]; omega
  obtain ⟨s66,hr65,h66⟩ := MapEntry65.transport NR FR R C₀ C (mapCallLive live) framed before after old old' s65 h65 hb65
  have heap66 := step_parameter_body_heap_below P.F NR FR R (mapCallLive live) framed before after old old' MapEntry65.input s65 s66 C C h65 MapEntry65.sourceValue MapEntry65.sourceName MapEntry65.sourceParams MapEntry65.sourceBody MapEntry65.sourceArgs MapEntry65.sourceEnv MapEntry65.sourceTail MapEntry65.source_control MapEntry65.source_frame MapEntry65.source_hoist hb65 hr65
  obtain ⟨s67,hr66,h67⟩ := MapEntry66.transport NR FR R C₀ C (mapBodyLive live) framed before after old old' s66 h66
  have heap67 := step_block_next_heap P.F NR FR R (mapBodyLive live) framed before after old old' MapEntry66.input s66 s67 C C h66 MapEntry66.sourceValue MapEntry66.sourceStatement MapEntry66.sourceRest MapEntry66.sourceEnv MapEntry66.sourceTail MapEntry66.source_control MapEntry66.source_frame hr66
  obtain ⟨s68,hr67,h68⟩ := MapEntry67.transport NR FR R C₀ C (mapBodyLive live) framed before after old old' s67 h67
  have heap68 := step_statement_heap P.F NR FR R (mapBodyLive live) framed before after old old' MapEntry67.input s67 s68 C C h67 MapEntry67.sourceAction MapEntry67.sourceEnv MapEntry67.source_control hr67
  obtain ⟨s69,hr68,h69⟩ := MapEntry68.transport NR FR R C₀ C (mapBodyLive live) framed before after old old' s68 h68
  have heap69 := step_descent_heap_from_source P.F NR FR R (mapBodyLive live) framed before after old old' MapEntry68.input s68 s69 C C h68 MapEntry68.descent MapEntry68.sourceEnv MapEntry68.source_control hr68
  obtain ⟨v69,hr69,h70,_⟩ := MapEntry69.transport NR FR R C₀ C (mapBodyLive live) framed before after old old' s69 h69
  let s70 := s69.ret v69
  have heap70 : s70.heap = s69.heap := rfl
  obtain ⟨s71,hr70,h71⟩ := MapEntry70.transport NR FR R C₀ C (mapBodyLive live) framed before after old old' s70 h70
  have heap71 := step_binary_left_heap_from_source P.F NR FR R (mapBodyLive live) framed before after old old' MapEntry70.input s70 s71 C C h70 MapEntry70.sourceValue MapEntry70.sourceOp MapEntry70.sourceRight MapEntry70.sourceEnv MapEntry70.sourceTail MapEntry70.source_control MapEntry70.source_frame hr70
  have hg : mapBodyLive live aGlobal := CellsLive.grow _ _ _ _ (ClosureLive.grow _ _ _ _ _ _ globalLive)
  obtain ⟨v71,hr71,h72,_⟩ := MapEntry71.transport NR FR R C₀ C (mapBodyLive live) framed before after old old' s71 h71 hg globalFixed
  let s72 := s71.ret v71
  have heap72 : s72.heap = s71.heap := rfl
  obtain ⟨s73,hr72,h73⟩ := MapEntry72.transport NR FR R C₀ C (mapBodyLive live) framed before after old old' s72 h72
  have heap73 := step_undefined_sne_heap P.F NR FR R (mapBodyLive live) framed before after old old' MapEntry72.input s72 s73 C C h72 MapEntry72.sourceTail MapEntry72.source_control MapEntry72.source_frame hr72
  obtain ⟨result,hr73,h74⟩ := MapEntry73.transport NR FR R C₀ C (mapBodyLive live) framed before after old old' s73 h73
  have heap74 := step_if_heap P.F NR FR R (mapBodyLive live) framed before after old old' MapEntry73.input s73 result C C h73 MapEntry73.sourceGuard MapEntry73.sourceYes MapEntry73.sourceNo MapEntry73.sourceEnv MapEntry73.sourceTail MapEntry73.source_control MapEntry73.source_frame hr73
  have next61 : s61.next = s.next+3 := h.target_next_add h61 3 (by host_kernel_rfl)
  have next65 : s65.next = s.next+3 := h.target_next_add h65 3 (by host_kernel_rfl)
  have firstCell : R.a MapEntry62.sourceAddress = s.next+1 := by
    have src : MapEntry62.sourceAddress = MapEntry60.input.next+1 := by host_kernel_rfl
    rw [src]
    exact h.heap.fresh 1
  have secondCell : R.a MapEntry64.sourceAddress = s.next+2 := by
    have src : MapEntry64.sourceAddress = MapEntry60.input.next+2 := by host_kernel_rfl
    rw [src]
    exact h.heap.fresh 2
  refine ⟨result,?_,h74,?_⟩
  · apply runC_cons P.F 13 s s61 result C C C (h.control.isHalt_eq.trans map_active60) hr60
    apply runC_cons P.F 12 s61 s62 result C C C (h61.control.isHalt_eq.trans map_active61) hr61
    apply runC_cons P.F 11 s62 s63 result C C C (h62.control.isHalt_eq.trans map_active62) hr62
    apply runC_cons P.F 10 s63 s64 result C C C (h63.control.isHalt_eq.trans map_active63) hr63
    apply runC_cons P.F 9 s64 s65 result C C C (h64.control.isHalt_eq.trans map_active64) hr64
    apply runC_cons P.F 8 s65 s66 result C C C (h65.control.isHalt_eq.trans map_active65) hr65
    apply runC_cons P.F 7 s66 s67 result C C C (h66.control.isHalt_eq.trans map_active66) hr66
    apply runC_cons P.F 6 s67 s68 result C C C (h67.control.isHalt_eq.trans map_active67) hr67
    apply runC_cons P.F 5 s68 s69 result C C C (h68.control.isHalt_eq.trans map_active68) hr68
    apply runC_cons P.F 4 s69 s70 result C C C (h69.control.isHalt_eq.trans map_active69) hr69
    apply runC_cons P.F 3 s70 s71 result C C C (h70.control.isHalt_eq.trans map_active70) hr70
    apply runC_cons P.F 2 s71 s72 result C C C (h71.control.isHalt_eq.trans map_active71) hr71
    apply runC_cons P.F 1 s72 s73 result C C C (h72.control.isHalt_eq.trans map_active72) hr72
    apply runC_cons P.F 0 s73 result result C C C (h73.control.isHalt_eq.trans map_active73) hr73
    rfl
  · intro a ha
    rw [heap74,heap73,heap72,heap71,heap70,heap69,heap68,heap67,
      heap66 a (by rw [next65]; omega),heap65 a (by rw [secondCell]; omega),
      heap64,heap63 a (by rw [firstCell]; omega),heap62,heap61 a ha]


end Host.Load.Run.Full.Ordinary
