import host.ts.renameOrdinary.DriverMapCompare
import host.ts.RenameForUpdateFields
import host.ts.RenameRouteFields

set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
namespace Host.Load.Run.Full.Ordinary
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric

def mapSecondNextIterationLive (live : Nat → Prop) : Nat → Prop := LiveAfter live MapFor204.input.next

/-- The second actual per-iteration copy, postfix update and comparison derive
the final false guard and exact index two. Every pre-existing heap address is
preserved because both index writes address the fresh iteration cell. -/
theorem map_second_increment (FR : Ren → P.F.S → P.F.S → Prop) (R : Ren)
    (ν₀ ν : Nat → F64) (C₀ C : CSrv) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s : St P.F.S)
    (h : StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' MapFor204.input s)
    (indexCell : s.heap.get (R.a MapFor204.sourceCell) = some (.cell (some MapFor204.sourceCellValue)))
    (lengthCell : s.heap.get (R.a MapTest212.address) = some (.cell (some MapTest212.sourceValue)))
    (bound : s.next+1 ≤ 2^64) :
    ∃ result, runC P.F 10 s C = some (result,C) ∧
      StateR (NumberRoles ν₀ ν C₀ C) FR R (mapSecondNextIterationLive live) framed before after old old'
        MapCompare213.output result ∧ result.ctl = .ret (.bool false) ∧
      result.heap.get (R.a MapUpdate205.sourceAddress) = some (.cell (some MapTest210.sourceValue)) ∧
      (∀ a, a < s.next → result.heap.get a = s.heap.get a) := by
  let NR := NumberRoles ν₀ ν C₀ C
  let L := mapSecondNextIterationLive live
  have word : s.next < 2^64 := by omega
  obtain ⟨s148,hr147,h148⟩ := MapFor204.transport NR FR R C₀ C live framed before after old old' s h word
  obtain ⟨cell148,frame148⟩ := step_for_update_fixed_fields P.F NR FR R live framed before after old old'
    MapFor204.input s s148 C C h MapFor204.sourceValue MapFor204.sourceCellValue MapFor204.sourceTest
    MapFor204.sourceUpdate MapFor204.sourceBody MapFor204.sourceEnv MapFor204.sourceName MapFor204.sourceLabels
    MapFor204.sourceTail MapFor204.sourceCell MapFor204.source_control MapFor204.source_frame MapFor204.source_lookup
    indexCell word hr147
  have sourceFresh : MapUpdate205.sourceAddress = MapFor204.input.next := by host_kernel_rfl
  have mapped : R.a MapUpdate205.sourceAddress = s.next := by
    rw [sourceFresh]
    simpa only [Nat.add_zero] using h.heap.fresh 0
  have newNotFramed : ¬ framed MapUpdate206.sourceAddress := by
    intro hf
    have impossible := h.heap.sourceBound _ (h.heap.prefixLive _ hf)
    have same : MapUpdate206.sourceAddress = MapFor204.input.next := by host_kernel_rfl
    rw [same] at impossible
    exact Nat.lt_irrefl _ impossible
  have hl := h.stackLive
  rw [MapFor204.source_frame] at hl
  have lookupLength : lookupEnv MapTest212.sourceName MapFor204.sourceEnv = some MapTest212.address := by host_kernel_rfl
  have lengthLive := env_lookup_live MapTest212.sourceName MapFor204.sourceEnv MapTest212.address
    hl.1.1.2.2.2.1 lookupLength
  have lengthOld := h.heap.targetBound _ lengthLive
  have input148 : s148.heap.get (R.a MapUpdate205.sourceAddress) = some (.cell (some MapUpdate205.sourceValue)) := by
    rw [mapped]
    exact cell148
  obtain ⟨s149,hr148,h149,control149,heap149⟩ := MapUpdate205.transport FR R ν₀ ν C₀ C L framed before after old old'
    s148 h148 input148
  have input149 : s149.heap.get (R.a MapUpdate206.sourceAddress) =
      some (.cell (some (.num (.lit MapUpdate206.sourceNumber)))) := by
    rw [heap149]
    exact input148
  have bound149 : s149.next ≤ 2^64 := by
    rw [h.target_next_add h149 1 (by host_kernel_rfl)]
    exact bound
  obtain ⟨s150,hr149,h150,control150,heap150⟩ := MapUpdate206.transport FR R ν₀ ν C₀ C L framed before after old old'
    s149 h149 control149 input149 newNotFramed bound149
  have newSame : MapUpdate206.sourceAddress = MapUpdate205.sourceAddress := by host_kernel_rfl
  have newWord : R.a MapUpdate206.sourceAddress < 2^64 := by rw [newSame,mapped]; exact word
  have old150 (a : Nat) (ha : a < s.next) : s150.heap.get a = s.heap.get a := by
    rw [heap150]
    simp only [St.setCell,PTrie.get_set_u64 _ _ _ newWord,
      ite_eq_right (show a ≠ R.a MapUpdate206.sourceAddress by rw [newSame,mapped]; omega)]
    rw [heap149]
    exact frame148 a ha
  have index150 : s150.heap.get (R.a MapTest210.address) = some (.cell (some MapTest210.sourceValue)) := by
    have address : MapTest210.address = MapUpdate206.sourceAddress := by host_kernel_rfl
    rw [address,heap150]
    simp only [St.setCell,PTrie.get_set_u64 _ _ _ newWord,ite_true]
    rfl
  obtain ⟨s151,hr150,h151,heap151⟩ := MapUpdate207.transport FR R ν₀ ν C₀ C L framed before after old old' s150 h150
  obtain ⟨s152,hr151,h152⟩ := MapFor208.transport NR FR R C₀ C L framed before after old old' s151 h151
  have heap152 := step_for_test_heap_from_source P.F NR FR R L framed before after old old' MapFor208.input
    s151 s152 C C h151 MapFor208.sourceValue MapFor208.sourceTest MapFor208.sourceUpdate MapFor208.sourceBody
    MapFor208.sourceEnv MapFor208.sourceNames MapFor208.sourceLabels MapFor208.sourceTail MapFor208.source_control MapFor208.source_frame hr151
  obtain ⟨s153,hr152,h153⟩ := MapTest209.transport NR FR R C₀ C L framed before after old old' s152 h152
  have heap153 := step_descent_heap_from_source P.F NR FR R L framed before after old old' MapTest209.input s152 s153 C C
    h152 MapTest209.descent MapTest209.sourceEnv MapTest209.source_control hr152
  obtain ⟨v153,hr153,h154,_⟩ := MapTest210.transport NR FR R C₀ C L framed before after old old' s153 h153
  let s154 := s153.ret v153
  have input153 : s153.heap.get (R.a MapTest210.address) = some (.cell (some MapTest210.sourceValue)) := by
    rw [heap153,heap152,heap151]
    exact index150
  have fields154 := step_variable_fixed_fields P.F NR FR R L framed before after old old' MapTest210.input s153 s154 C C h153
    MapTest210.sourceName MapTest210.sourceEnv MapTest210.address MapTest210.sourceValue MapTest210.source_control MapTest210.source_lookup input153 hr153
  obtain ⟨s155,hr154,h155⟩ := MapTest211.transport NR FR R C₀ C L framed before after old old' s154 h154
  obtain ⟨fs,frame155,_,heap155⟩ := step_binary_left_saved_fields P.F NR FR R L framed before after old old' MapTest211.input
    s154 s155 C C h154 MapTest210.sourceValue MapTest211.sourceOp MapTest211.sourceRight MapTest211.sourceEnv MapTest211.sourceTail
    MapTest211.source_frame fields154.1 hr154
  obtain ⟨v155,hr155,h156,_⟩ := MapTest212.transport NR FR R C₀ C L framed before after old old' s155 h155
  let s156 := s155.ret v155
  have input155 : s155.heap.get (R.a MapTest212.address) = some (.cell (some MapTest212.sourceValue)) := by
    rw [heap155,fields154.2,heap153,heap152,heap151,old150 _ lengthOld]
    exact lengthCell
  have fields156 := step_variable_fixed_fields P.F NR FR R L framed before after old old' MapTest212.input s155 s156 C C h155
    MapTest212.sourceName MapTest212.sourceEnv MapTest212.address MapTest212.sourceValue MapTest212.source_control MapTest212.source_lookup input155 hr155
  have frames156 : ∃ fs, s156.stack = .e (.binR .lt (.num (.lit MapCompare213.sourceLeft)))::fs := ⟨fs,frame155⟩
  obtain ⟨result,hr156,h157,control157,heap157⟩ := MapCompare213.transport FR R ν₀ ν C₀ C L framed before after old old'
    s156 h156 fields156.1 frames156
  have finalHeap : result.heap = s150.heap := by
    rw [heap157,fields156.2,heap155,fields154.2,heap153,heap152,heap151]
  refine ⟨result,?_,h157,control157,?_,?_⟩
  · apply runC_cons P.F 9 s s148 result C C C (h.control.isHalt_eq.trans (by host_kernel_rfl)) hr147
    apply runC_cons P.F 8 s148 s149 result C C C (h148.control.isHalt_eq.trans (by host_kernel_rfl)) hr148
    apply runC_cons P.F 7 s149 s150 result C C C (h149.control.isHalt_eq.trans (by host_kernel_rfl)) hr149
    apply runC_cons P.F 6 s150 s151 result C C C (h150.control.isHalt_eq.trans (by host_kernel_rfl)) hr150
    apply runC_cons P.F 5 s151 s152 result C C C (h151.control.isHalt_eq.trans (by host_kernel_rfl)) hr151
    apply runC_cons P.F 4 s152 s153 result C C C (h152.control.isHalt_eq.trans (by host_kernel_rfl)) hr152
    apply runC_cons P.F 3 s153 s154 result C C C (h153.control.isHalt_eq.trans (by host_kernel_rfl)) hr153
    apply runC_cons P.F 2 s154 s155 result C C C (h154.control.isHalt_eq.trans (by host_kernel_rfl)) hr154
    apply runC_cons P.F 1 s155 s156 result C C C (h155.control.isHalt_eq.trans (by host_kernel_rfl)) hr155
    apply runC_cons P.F 0 s156 result result C C C (h156.control.isHalt_eq.trans (by host_kernel_rfl)) hr156
    rfl
  · rw [finalHeap]
    exact index150
  · intro a ha
    rw [finalHeap]
    exact old150 a ha

end Host.Load.Run.Full.Ordinary
