import host.ts.renameOrdinary.MapSecondIndex
import host.ts.RenameClosureEffects

set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
namespace Host.Load.Run.Full.Ordinary
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric

def mapSecondCallbackLive (live : Nat → Prop) : Nat → Prop := ClosureLive live MapBody176.input.next
  MapBody176.sourceArrow MapBody176.sourceHome MapBody176.sourceFunction

def mapSecondGetterLive (live : Nat → Prop) : Nat → Prop := ClosureLive (mapSecondCallbackLive live) MapBody183.input.next
  MapBody183.sourceArrow MapBody183.sourceHome MapBody183.sourceFunction

def mapSecondCallbackGetterLive (live : Nat → Prop) : Nat → Prop :=
  CellsLive (mapSecondGetterLive live) MapBody184.input.next (blockNames MapBody184.sourceBody)

theorem map_second_callback_params : (paramNames MapBody176.sourceFunction).length = 1 := by host_kernel_rfl
theorem map_second_getter_params : (paramNames MapBody183.sourceFunction).length = 0 := by host_kernel_rfl
theorem map_second_getter_no_cells : blockNames MapBody184.sourceBody = [] := by host_kernel_rfl

theorem MapBody170.active : isHalt MapBody170.input.ctl = false := by host_kernel_rfl

theorem MapBody171.active : isHalt MapBody171.input.ctl = false := by host_kernel_rfl

theorem MapBody172.active : isHalt MapBody172.input.ctl = false := by host_kernel_rfl

theorem MapBody173.active : isHalt MapBody173.input.ctl = false := by host_kernel_rfl

theorem MapBody174.active : isHalt MapBody174.input.ctl = false := by host_kernel_rfl

theorem MapBody175.active : isHalt MapBody175.input.ctl = false := by host_kernel_rfl

theorem MapBody176.active : isHalt MapBody176.input.ctl = false := by host_kernel_rfl

theorem MapBody177.active : isHalt MapBody177.input.ctl = false := by host_kernel_rfl

theorem MapBody178.active : isHalt MapBody178.input.ctl = false := by host_kernel_rfl

theorem MapBody179.active : isHalt MapBody179.input.ctl = false := by host_kernel_rfl

theorem MapBody180.active : isHalt MapBody180.input.ctl = false := by host_kernel_rfl

theorem MapBody181.active : isHalt MapBody181.input.ctl = false := by host_kernel_rfl

theorem MapBody182.active : isHalt MapBody182.input.ctl = false := by host_kernel_rfl

theorem MapBody183.active : isHalt MapBody183.input.ctl = false := by host_kernel_rfl

theorem MapBody184.active : isHalt MapBody184.input.ctl = false := by host_kernel_rfl

theorem map_second_callback_receiver_live (NR : NumV → NumV → Prop) (FR : Ren → P.F.S → P.F.S → Prop)
    (R : Ren) (live framed : Nat → Prop) (before after : List Val) (old old' : List Event)
    (s : St P.F.S) (h : StateR NR FR R live framed before after old old' MapBody170.input s)
    (inputNotFramed : ¬ framed MapBody170.sourceAddress) : live 3126165 := by
  have hl := h.stackLive
  rw [MapBody170.source_frame] at hl
  have ha : live MapBody170.sourceAddress := hl.1.1.1
  obtain ⟨_,_,_,_,_,support⟩ := h.heap.read_array MapBody170.sourceAddress MapBody170.sourceObject
    MapBody170.sourceValues ha inputNotFramed MapBody170.source_heap MapBody170.source_kind
  have hv := listSupport_nth (valueSupport live) MapBody170.sourceValues support
    MapBody170.sourceIndex MapBody170.sourceSelected MapBody170.source_selected
  exact hv

/-- Real argument evaluation and both closure entries preserve every heap
address below the original allocation counter. The callback parameter write
is proved to target its freshly allocated cell. -/
theorem map_second_callback_getter_entry (NR : NumV → NumV → Prop)
    (FR : Ren → P.F.S → P.F.S → Prop) (R : Ren) (C₀ C : CSrv)
    (live framed : Nat → Prop) (before after : List Val) (old old' : List Event)
    (s : St P.F.S) (h : StateR NR FR R live framed before after old old' MapBody170.input s)
    (inputNotFramed : ¬ framed MapBody170.sourceAddress)
    (fixedIndex : s.ctl = .ret MapBody170.sourceValue)
    (bound : s.next+3 ≤ 2^64) :
    ∃ result, runC P.F 15 s C = some (result,C) ∧
      StateR NR FR R (mapSecondCallbackGetterLive live) framed before after old old' MapBody185.input result ∧
      (∀ a, a < s.next → result.heap.get a = s.heap.get a) := by
  obtain ⟨value,s114,hr₀,hr113,h114,_,_,heap114⟩ := step_array_index_from_source_fields P.F NR FR R C₀ C
    live framed before after old old' MapBody170.input s h MapBody170.sourceValue MapBody170.sourceAddress
    MapBody170.sourceIndex MapBody170.sourceObject MapBody170.sourceValues MapBody170.sourceSelected MapBody170.sourceTail
    MapBody170.source_control MapBody170.source_frame MapBody170.source_index MapBody170.source_heap MapBody170.source_kind
    MapBody170.source_selected inputNotFramed fixedIndex
  have sourceRun : interpC (step P.F MapBody170.input).run C₀ = some (MapBody170.output,C₀) :=
    MapBody170.source_run C₀
  rw [sourceRun] at hr₀
  have source114 := congrArg Prod.fst (Option.some.inj hr₀)
  dsimp only at source114
  rw [← source114] at h114
  obtain ⟨s115,hr114,h115⟩ := MapBody171.transport NR FR R C₀ C live framed before after old old' s114 h114
  have heap115 : s115.heap = s114.heap := step_argument_heap_from_source P.F NR FR R live framed before after old old' MapBody171.input s114 s115 C C h114 MapBody171.sourceValue MapBody171.sourceKind MapBody171.sourceFunction MapBody171.sourceThis MapBody171.sourceAcc MapBody171.sourceRest MapBody171.sourceEnv MapBody171.sourceTail MapBody171.source_control MapBody171.source_frame (by decide) hr114
  obtain ⟨v115,hr115,h116,_⟩ := MapBody172.transport NR FR R C₀ C live framed before after old old' s115 h115
  let s116 := s115.ret v115
  have heap116 : s116.heap = s115.heap := rfl
  obtain ⟨s117,hr116,h117⟩ := MapBody173.transport NR FR R C₀ C live framed before after old old' s116 h116
  have heap117 : s117.heap = s116.heap := step_argument_heap_from_source P.F NR FR R live framed before after old old' MapBody173.input s116 s117 C C h116 MapBody173.sourceValue MapBody173.sourceKind MapBody173.sourceFunction MapBody173.sourceThis MapBody173.sourceAcc MapBody173.sourceRest MapBody173.sourceEnv MapBody173.sourceTail MapBody173.source_control MapBody173.source_frame (by decide) hr116
  obtain ⟨s118,hr117,h118⟩ := MapBody174.transport NR FR R C₀ C live framed before after old old' s117 h117
  have heap118 : s118.heap = s117.heap := step_this_heap_from_source P.F NR FR R live framed before after old old' MapBody174.input s117 s118 C₀ C C h117 MapBody174.sourceEnv MapBody174.sourceAddress MapBody174.sourceValue MapBody174.source_control MapBody174.source_lookup MapBody174.source_cell hr117
  obtain ⟨s119,hr118,h119⟩ := MapBody175.transport NR FR R C₀ C live framed before after old old' s118 h118
  have heap119 : s119.heap = s118.heap := step_argument_heap_from_source P.F NR FR R live framed before after old old' MapBody175.input s118 s119 C C h118 MapBody175.sourceValue MapBody175.sourceKind MapBody175.sourceFunction MapBody175.sourceThis MapBody175.sourceAcc MapBody175.sourceRest MapBody175.sourceEnv MapBody175.sourceTail MapBody175.source_control MapBody175.source_frame (by decide) hr118
  have next119 : s119.next = s.next := h.target_next_eq h119 (by host_kernel_rfl)
  have bound119 : s119.next + 2 + (paramNames MapBody176.sourceFunction).length ≤ 2^64 := by
    rw [next119,map_second_callback_params]
    omega
  obtain ⟨s120,hr119,h120⟩ := MapBody176.transport NR FR R C₀ C live framed before after old old' s119 h119 bound119
  have frame120 := step_closure_heap_below P.F NR FR R live framed before after old old' MapBody176.input s119 s120 C C h119 MapBody176.address MapBody176.object MapBody176.sourceFunction MapBody176.sourceEnv MapBody176.sourceArrow MapBody176.sourceHome MapBody176.sourceThis MapBody176.sourceArgs MapBody176.source_control MapBody176.source_heap MapBody176.source_kind bound119 hr119
  obtain ⟨s121,hr120,h121⟩ := MapBody177.transport NR FR R C₀ C (mapSecondCallbackLive live) framed before after old old' s120 h120
  have heap121 : s121.heap = s120.heap := step_parameter_id_heap_from_source P.F NR FR R (mapSecondCallbackLive live) framed before after old old' MapBody177.input s120 s121 C C h120 MapBody177.sourceValue MapBody177.sourceFunction MapBody177.sourceName MapBody177.sourceParams MapBody177.sourceArgs MapBody177.sourceEnv MapBody177.sourceTail MapBody177.source_control MapBody177.source_frame hr120
  have bound121 : s121.next ≤ 2^64 := by
    rw [h.target_next_add h121 1 (by host_kernel_rfl)]
    omega
  obtain ⟨s122,hr121,h122⟩ := MapBody178.transport NR FR R C₀ C (mapSecondCallbackLive live) framed before after old old' s121 h121 bound121
  have frame122 := step_bind_init_heap_other P.F NR FR R (mapSecondCallbackLive live) framed before after old old' MapBody178.input s121 s122 C C h121 MapBody178.sourceName MapBody178.sourceValue MapBody178.sourceEnv MapBody178.sourceKind MapBody178.sourceAddress MapBody178.source_control MapBody178.source_lookup bound121 hr121
  have freshParameter : R.a MapBody178.sourceAddress = s119.next := by
    have hs : MapBody178.sourceAddress = MapBody175.output.next + 0 := by host_kernel_rfl
    rw [hs]
    exact h119.heap.fresh 0
  obtain ⟨s123,hr122,h123,heap123⟩ := MapBody179.transport NR FR R C₀ C (mapSecondCallbackLive live) framed before after old old' s122 h122
  obtain ⟨s124,hr123,h124⟩ := MapBody180.transport NR FR R C₀ C (mapSecondCallbackLive live) framed before after old old' s123 h123
  have heap124 : s124.heap = s123.heap := step_descent_heap_from_source P.F NR FR R (mapSecondCallbackLive live) framed before after old old' MapBody180.input s123 s124 C C h123 MapBody180.descent MapBody180.sourceEnv MapBody180.source_control hr123
  obtain ⟨v124,hr124,h125,_⟩ := MapBody181.transport NR FR R C₀ C (mapSecondCallbackLive live) framed before after old old' s124 h124
  let s125 := s124.ret v124
  have heap125 : s125.heap = s124.heap := rfl
  obtain ⟨s126,hr125,h126⟩ := MapBody182.transport NR FR R C₀ C (mapSecondCallbackLive live) framed before after old old' s125 h125
  have heap126 : s126.heap = s125.heap := MapBody182.heap_frame NR FR R C₀ C C (mapSecondCallbackLive live) framed before after old old' s125 s126 h125 hr125
  have next126 : s126.next = s.next+1 := h.target_next_add h126 1 (by host_kernel_rfl)
  have bound126 : s126.next + 2 + (paramNames MapBody183.sourceFunction).length ≤ 2^64 := by
    rw [next126,map_second_getter_params]
    omega
  obtain ⟨s127,hr126,h127⟩ := MapBody183.transport NR FR R C₀ C (mapSecondCallbackLive live) framed before after old old' s126 h126 bound126
  have frame127 := step_closure_heap_below P.F NR FR R (mapSecondCallbackLive live) framed before after old old' MapBody183.input s126 s127 C C h126 MapBody183.address MapBody183.object MapBody183.sourceFunction MapBody183.sourceEnv MapBody183.sourceArrow MapBody183.sourceHome MapBody183.sourceThis MapBody183.sourceArgs MapBody183.source_control MapBody183.source_heap MapBody183.source_kind bound126 hr126
  have bound127 : s127.next + (blockNames MapBody184.sourceBody).length ≤ 2^64 := by
    rw [h.target_next_add h127 3 (by host_kernel_rfl),map_second_getter_no_cells]
    simp only [List.length_nil,Nat.add_zero]
    exact bound
  obtain ⟨s128,hr127,h128⟩ := MapBody184.transport NR FR R C₀ C (mapSecondGetterLive live) framed before after old old' s127 h127 bound127
  have heap128 : s128.heap = s127.heap := step_parameter_body_heap_empty_from_source P.F NR FR R (mapSecondGetterLive live) framed before after old old' MapBody184.input s127 s128 C C h127 MapBody184.sourceValue MapBody184.sourceName MapBody184.sourceParams MapBody184.sourceBody MapBody184.sourceArgs MapBody184.sourceEnv MapBody184.sourceTail MapBody184.source_control MapBody184.source_frame map_second_getter_no_cells MapBody184.source_hoist hr127
  refine ⟨s128,?_,h128,?_⟩
  · apply runC_cons P.F 14 s s114 s128 C C C (h.control.isHalt_eq.trans MapBody170.active) hr113
    apply runC_cons P.F 13 s114 s115 s128 C C C (h114.control.isHalt_eq.trans MapBody171.active) hr114
    apply runC_cons P.F 12 s115 s116 s128 C C C (h115.control.isHalt_eq.trans MapBody172.active) hr115
    apply runC_cons P.F 11 s116 s117 s128 C C C (h116.control.isHalt_eq.trans MapBody173.active) hr116
    apply runC_cons P.F 10 s117 s118 s128 C C C (h117.control.isHalt_eq.trans MapBody174.active) hr117
    apply runC_cons P.F 9 s118 s119 s128 C C C (h118.control.isHalt_eq.trans MapBody175.active) hr118
    apply runC_cons P.F 8 s119 s120 s128 C C C (h119.control.isHalt_eq.trans MapBody176.active) hr119
    apply runC_cons P.F 7 s120 s121 s128 C C C (h120.control.isHalt_eq.trans MapBody177.active) hr120
    apply runC_cons P.F 6 s121 s122 s128 C C C (h121.control.isHalt_eq.trans MapBody178.active) hr121
    apply runC_cons P.F 5 s122 s123 s128 C C C (h122.control.isHalt_eq.trans MapBody179.active) hr122
    apply runC_cons P.F 4 s123 s124 s128 C C C (h123.control.isHalt_eq.trans MapBody180.active) hr123
    apply runC_cons P.F 3 s124 s125 s128 C C C (h124.control.isHalt_eq.trans MapBody181.active) hr124
    apply runC_cons P.F 2 s125 s126 s128 C C C (h125.control.isHalt_eq.trans MapBody182.active) hr125
    apply runC_cons P.F 1 s126 s127 s128 C C C (h126.control.isHalt_eq.trans MapBody183.active) hr126
    apply runC_cons P.F 0 s127 s128 s128 C C C (h127.control.isHalt_eq.trans MapBody184.active) hr127
    rfl
  · intro a ha
    rw [heap128,frame127 a (by rw [next126]; omega),heap126,heap125,heap124,heap123,
      frame122 a (by rw [freshParameter,next119]; omega),heap121,frame120 a (by rw [next119]; exact ha),
      heap119,heap118,heap117,heap116,heap115,heap114]

end Host.Load.Run.Full.Ordinary
