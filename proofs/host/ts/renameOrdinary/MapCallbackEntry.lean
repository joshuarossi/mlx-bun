import host.ts.renameOrdinary.MapBodyIndex
import host.ts.RenameClosureEffects

set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
namespace Host.Load.Run.Full.Ordinary
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric

def mapCallbackLive (live : Nat → Prop) : Nat → Prop := ClosureLive live MapBody119.input.next
  MapBody119.sourceArrow MapBody119.sourceHome MapBody119.sourceFunction

def mapGetterLive (live : Nat → Prop) : Nat → Prop := ClosureLive (mapCallbackLive live) MapBody126.input.next
  MapBody126.sourceArrow MapBody126.sourceHome MapBody126.sourceFunction

def mapCallbackGetterLive (live : Nat → Prop) : Nat → Prop :=
  CellsLive (mapGetterLive live) MapBody127.input.next (blockNames MapBody127.sourceBody)

theorem map_callback_params : (paramNames MapBody119.sourceFunction).length = 1 := by host_kernel_rfl
theorem map_getter_params : (paramNames MapBody126.sourceFunction).length = 0 := by host_kernel_rfl
theorem map_getter_no_cells : blockNames MapBody127.sourceBody = [] := by host_kernel_rfl

theorem MapBody113.active : isHalt MapBody113.input.ctl = false := by host_kernel_rfl

theorem MapBody114.active : isHalt MapBody114.input.ctl = false := by host_kernel_rfl

theorem MapBody115.active : isHalt MapBody115.input.ctl = false := by host_kernel_rfl

theorem MapBody116.active : isHalt MapBody116.input.ctl = false := by host_kernel_rfl

theorem MapBody117.active : isHalt MapBody117.input.ctl = false := by host_kernel_rfl

theorem MapBody118.active : isHalt MapBody118.input.ctl = false := by host_kernel_rfl

theorem MapBody119.active : isHalt MapBody119.input.ctl = false := by host_kernel_rfl

theorem MapBody120.active : isHalt MapBody120.input.ctl = false := by host_kernel_rfl

theorem MapBody121.active : isHalt MapBody121.input.ctl = false := by host_kernel_rfl

theorem MapBody122.active : isHalt MapBody122.input.ctl = false := by host_kernel_rfl

theorem MapBody123.active : isHalt MapBody123.input.ctl = false := by host_kernel_rfl

theorem MapBody124.active : isHalt MapBody124.input.ctl = false := by host_kernel_rfl

theorem MapBody125.active : isHalt MapBody125.input.ctl = false := by host_kernel_rfl

theorem MapBody126.active : isHalt MapBody126.input.ctl = false := by host_kernel_rfl

theorem MapBody127.active : isHalt MapBody127.input.ctl = false := by host_kernel_rfl

theorem map_callback_receiver_live (NR : NumV → NumV → Prop) (FR : Ren → P.F.S → P.F.S → Prop)
    (R : Ren) (live framed : Nat → Prop) (before after : List Val) (old old' : List Event)
    (s : St P.F.S) (h : StateR NR FR R live framed before after old old' MapBody113.input s)
    (inputNotFramed : ¬ framed MapBody113.sourceAddress) : live 2978923 := by
  have hl := h.stackLive
  rw [MapBody113.source_frame] at hl
  have ha : live MapBody113.sourceAddress := hl.1.1.1
  obtain ⟨_,_,_,_,_,support⟩ := h.heap.read_array MapBody113.sourceAddress MapBody113.sourceObject
    MapBody113.sourceValues ha inputNotFramed MapBody113.source_heap MapBody113.source_kind
  have hv := listSupport_nth (valueSupport live) MapBody113.sourceValues support
    MapBody113.sourceIndex MapBody113.sourceSelected MapBody113.source_selected
  exact hv

/-- Real argument evaluation and both closure entries preserve every heap
address below the original allocation counter. The callback parameter write
is proved to target its freshly allocated cell. -/
theorem map_callback_getter_entry (NR : NumV → NumV → Prop)
    (FR : Ren → P.F.S → P.F.S → Prop) (R : Ren) (C₀ C : CSrv)
    (live framed : Nat → Prop) (before after : List Val) (old old' : List Event)
    (s : St P.F.S) (h : StateR NR FR R live framed before after old old' MapBody113.input s)
    (inputNotFramed : ¬ framed MapBody113.sourceAddress)
    (fixedIndex : s.ctl = .ret MapBody113.sourceValue)
    (bound : s.next+3 ≤ 2^64) :
    ∃ result, runC P.F 15 s C = some (result,C) ∧
      StateR NR FR R (mapCallbackGetterLive live) framed before after old old' MapBody128.input result ∧
      (∀ a, a < s.next → result.heap.get a = s.heap.get a) := by
  obtain ⟨value,s114,hr₀,hr113,h114,_,_,heap114⟩ := step_array_index_from_source_fields P.F NR FR R C₀ C
    live framed before after old old' MapBody113.input s h MapBody113.sourceValue MapBody113.sourceAddress
    MapBody113.sourceIndex MapBody113.sourceObject MapBody113.sourceValues MapBody113.sourceSelected MapBody113.sourceTail
    MapBody113.source_control MapBody113.source_frame MapBody113.source_index MapBody113.source_heap MapBody113.source_kind
    MapBody113.source_selected inputNotFramed fixedIndex
  have sourceRun : interpC (step P.F MapBody113.input).run C₀ = some (MapBody113.output,C₀) :=
    MapBody113.source_run C₀
  rw [sourceRun] at hr₀
  have source114 := congrArg Prod.fst (Option.some.inj hr₀)
  dsimp only at source114
  rw [← source114] at h114
  obtain ⟨s115,hr114,h115⟩ := MapBody114.transport NR FR R C₀ C live framed before after old old' s114 h114
  have heap115 : s115.heap = s114.heap := step_argument_heap_from_source P.F NR FR R live framed before after old old' MapBody114.input s114 s115 C C h114 MapBody114.sourceValue MapBody114.sourceKind MapBody114.sourceFunction MapBody114.sourceThis MapBody114.sourceAcc MapBody114.sourceRest MapBody114.sourceEnv MapBody114.sourceTail MapBody114.source_control MapBody114.source_frame (by decide) hr114
  obtain ⟨v115,hr115,h116,_⟩ := MapBody115.transport NR FR R C₀ C live framed before after old old' s115 h115
  let s116 := s115.ret v115
  have heap116 : s116.heap = s115.heap := rfl
  obtain ⟨s117,hr116,h117⟩ := MapBody116.transport NR FR R C₀ C live framed before after old old' s116 h116
  have heap117 : s117.heap = s116.heap := step_argument_heap_from_source P.F NR FR R live framed before after old old' MapBody116.input s116 s117 C C h116 MapBody116.sourceValue MapBody116.sourceKind MapBody116.sourceFunction MapBody116.sourceThis MapBody116.sourceAcc MapBody116.sourceRest MapBody116.sourceEnv MapBody116.sourceTail MapBody116.source_control MapBody116.source_frame (by decide) hr116
  obtain ⟨s118,hr117,h118⟩ := MapBody117.transport NR FR R C₀ C live framed before after old old' s117 h117
  have heap118 : s118.heap = s117.heap := step_this_heap_from_source P.F NR FR R live framed before after old old' MapBody117.input s117 s118 C₀ C C h117 MapBody117.sourceEnv MapBody117.sourceAddress MapBody117.sourceValue MapBody117.source_control MapBody117.source_lookup MapBody117.source_cell hr117
  obtain ⟨s119,hr118,h119⟩ := MapBody118.transport NR FR R C₀ C live framed before after old old' s118 h118
  have heap119 : s119.heap = s118.heap := step_argument_heap_from_source P.F NR FR R live framed before after old old' MapBody118.input s118 s119 C C h118 MapBody118.sourceValue MapBody118.sourceKind MapBody118.sourceFunction MapBody118.sourceThis MapBody118.sourceAcc MapBody118.sourceRest MapBody118.sourceEnv MapBody118.sourceTail MapBody118.source_control MapBody118.source_frame (by decide) hr118
  have next119 : s119.next = s.next := h.target_next_eq h119 (by host_kernel_rfl)
  have bound119 : s119.next + 2 + (paramNames MapBody119.sourceFunction).length ≤ 2^64 := by
    rw [next119,map_callback_params]
    omega
  obtain ⟨s120,hr119,h120⟩ := MapBody119.transport NR FR R C₀ C live framed before after old old' s119 h119 bound119
  have frame120 := step_closure_heap_below P.F NR FR R live framed before after old old' MapBody119.input s119 s120 C C h119 MapBody119.address MapBody119.object MapBody119.sourceFunction MapBody119.sourceEnv MapBody119.sourceArrow MapBody119.sourceHome MapBody119.sourceThis MapBody119.sourceArgs MapBody119.source_control MapBody119.source_heap MapBody119.source_kind bound119 hr119
  obtain ⟨s121,hr120,h121⟩ := MapBody120.transport NR FR R C₀ C (mapCallbackLive live) framed before after old old' s120 h120
  have heap121 : s121.heap = s120.heap := step_parameter_id_heap_from_source P.F NR FR R (mapCallbackLive live) framed before after old old' MapBody120.input s120 s121 C C h120 MapBody120.sourceValue MapBody120.sourceFunction MapBody120.sourceName MapBody120.sourceParams MapBody120.sourceArgs MapBody120.sourceEnv MapBody120.sourceTail MapBody120.source_control MapBody120.source_frame hr120
  have bound121 : s121.next ≤ 2^64 := by
    rw [h.target_next_add h121 1 (by host_kernel_rfl)]
    omega
  obtain ⟨s122,hr121,h122⟩ := MapBody121.transport NR FR R C₀ C (mapCallbackLive live) framed before after old old' s121 h121 bound121
  have frame122 := step_bind_init_heap_other P.F NR FR R (mapCallbackLive live) framed before after old old' MapBody121.input s121 s122 C C h121 MapBody121.sourceName MapBody121.sourceValue MapBody121.sourceEnv MapBody121.sourceKind MapBody121.sourceAddress MapBody121.source_control MapBody121.source_lookup bound121 hr121
  have freshParameter : R.a MapBody121.sourceAddress = s119.next := by
    have hs : MapBody121.sourceAddress = MapBody118.output.next + 0 := by host_kernel_rfl
    rw [hs]
    exact h119.heap.fresh 0
  obtain ⟨s123,hr122,h123,heap123⟩ := MapBody122.transport NR FR R C₀ C (mapCallbackLive live) framed before after old old' s122 h122
  obtain ⟨s124,hr123,h124⟩ := MapBody123.transport NR FR R C₀ C (mapCallbackLive live) framed before after old old' s123 h123
  have heap124 : s124.heap = s123.heap := step_descent_heap_from_source P.F NR FR R (mapCallbackLive live) framed before after old old' MapBody123.input s123 s124 C C h123 MapBody123.descent MapBody123.sourceEnv MapBody123.source_control hr123
  obtain ⟨v124,hr124,h125,_⟩ := MapBody124.transport NR FR R C₀ C (mapCallbackLive live) framed before after old old' s124 h124
  let s125 := s124.ret v124
  have heap125 : s125.heap = s124.heap := rfl
  obtain ⟨s126,hr125,h126⟩ := MapBody125.transport NR FR R C₀ C (mapCallbackLive live) framed before after old old' s125 h125
  have heap126 : s126.heap = s125.heap := MapBody125.heap_frame NR FR R C₀ C C (mapCallbackLive live) framed before after old old' s125 s126 h125 hr125
  have next126 : s126.next = s.next+1 := h.target_next_add h126 1 (by host_kernel_rfl)
  have bound126 : s126.next + 2 + (paramNames MapBody126.sourceFunction).length ≤ 2^64 := by
    rw [next126,map_getter_params]
    omega
  obtain ⟨s127,hr126,h127⟩ := MapBody126.transport NR FR R C₀ C (mapCallbackLive live) framed before after old old' s126 h126 bound126
  have frame127 := step_closure_heap_below P.F NR FR R (mapCallbackLive live) framed before after old old' MapBody126.input s126 s127 C C h126 MapBody126.address MapBody126.object MapBody126.sourceFunction MapBody126.sourceEnv MapBody126.sourceArrow MapBody126.sourceHome MapBody126.sourceThis MapBody126.sourceArgs MapBody126.source_control MapBody126.source_heap MapBody126.source_kind bound126 hr126
  have bound127 : s127.next + (blockNames MapBody127.sourceBody).length ≤ 2^64 := by
    rw [h.target_next_add h127 3 (by host_kernel_rfl),map_getter_no_cells]
    simp only [List.length_nil,Nat.add_zero]
    exact bound
  obtain ⟨s128,hr127,h128⟩ := MapBody127.transport NR FR R C₀ C (mapGetterLive live) framed before after old old' s127 h127 bound127
  have heap128 : s128.heap = s127.heap := step_parameter_body_heap_empty_from_source P.F NR FR R (mapGetterLive live) framed before after old old' MapBody127.input s127 s128 C C h127 MapBody127.sourceValue MapBody127.sourceName MapBody127.sourceParams MapBody127.sourceBody MapBody127.sourceArgs MapBody127.sourceEnv MapBody127.sourceTail MapBody127.source_control MapBody127.source_frame map_getter_no_cells MapBody127.source_hoist hr127
  refine ⟨s128,?_,h128,?_⟩
  · apply runC_cons P.F 14 s s114 s128 C C C (h.control.isHalt_eq.trans MapBody113.active) hr113
    apply runC_cons P.F 13 s114 s115 s128 C C C (h114.control.isHalt_eq.trans MapBody114.active) hr114
    apply runC_cons P.F 12 s115 s116 s128 C C C (h115.control.isHalt_eq.trans MapBody115.active) hr115
    apply runC_cons P.F 11 s116 s117 s128 C C C (h116.control.isHalt_eq.trans MapBody116.active) hr116
    apply runC_cons P.F 10 s117 s118 s128 C C C (h117.control.isHalt_eq.trans MapBody117.active) hr117
    apply runC_cons P.F 9 s118 s119 s128 C C C (h118.control.isHalt_eq.trans MapBody118.active) hr118
    apply runC_cons P.F 8 s119 s120 s128 C C C (h119.control.isHalt_eq.trans MapBody119.active) hr119
    apply runC_cons P.F 7 s120 s121 s128 C C C (h120.control.isHalt_eq.trans MapBody120.active) hr120
    apply runC_cons P.F 6 s121 s122 s128 C C C (h121.control.isHalt_eq.trans MapBody121.active) hr121
    apply runC_cons P.F 5 s122 s123 s128 C C C (h122.control.isHalt_eq.trans MapBody122.active) hr122
    apply runC_cons P.F 4 s123 s124 s128 C C C (h123.control.isHalt_eq.trans MapBody123.active) hr123
    apply runC_cons P.F 3 s124 s125 s128 C C C (h124.control.isHalt_eq.trans MapBody124.active) hr124
    apply runC_cons P.F 2 s125 s126 s128 C C C (h125.control.isHalt_eq.trans MapBody125.active) hr125
    apply runC_cons P.F 1 s126 s127 s128 C C C (h126.control.isHalt_eq.trans MapBody126.active) hr126
    apply runC_cons P.F 0 s127 s128 s128 C C C (h127.control.isHalt_eq.trans MapBody127.active) hr127
    rfl
  · intro a ha
    rw [heap128,frame127 a (by rw [next126]; omega),heap126,heap125,heap124,heap123,
      frame122 a (by rw [freshParameter,next119]; omega),heap121,frame120 a (by rw [next119]; exact ha),
      heap119,heap118,heap117,heap116,heap115,heap114]

end Host.Load.Run.Full.Ordinary
