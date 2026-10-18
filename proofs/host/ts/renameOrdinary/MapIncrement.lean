import host.ts.renameOrdinary.DriverMapCompare
import host.ts.RenameForUpdateFields
import host.ts.RenameRouteFields

set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
namespace Host.Load.Run.Full.Ordinary
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric

def mapNextIterationLive (live : Nat → Prop) : Nat → Prop := LiveAfter live MapFor147.input.next

/-- The first actual per-iteration copy, postfix update and comparison derive
the next true guard and exact index one. Every pre-existing heap address is
preserved because both index writes address the fresh iteration cell. -/
theorem map_increment (FR : Ren → P.F.S → P.F.S → Prop) (R : Ren)
    (ν₀ ν : Nat → F64) (C₀ C : CSrv) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s : St P.F.S)
    (h : StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' MapFor147.input s)
    (indexCell : s.heap.get (R.a MapFor147.sourceCell) = some (.cell (some MapFor147.sourceCellValue)))
    (lengthCell : s.heap.get (R.a MapTest155.address) = some (.cell (some MapTest155.sourceValue)))
    (bound : s.next+1 ≤ 2^64) :
    ∃ result, runC P.F 10 s C = some (result,C) ∧
      StateR (NumberRoles ν₀ ν C₀ C) FR R (mapNextIterationLive live) framed before after old old'
        MapCompare156.output result ∧ result.ctl = .ret (.bool true) ∧
      result.heap.get (R.a MapUpdate148.sourceAddress) = some (.cell (some MapTest153.sourceValue)) ∧
      (∀ a, a < s.next → result.heap.get a = s.heap.get a) := by
  let NR := NumberRoles ν₀ ν C₀ C
  let L := mapNextIterationLive live
  have word : s.next < 2^64 := by omega
  obtain ⟨s148,hr147,h148⟩ := MapFor147.transport NR FR R C₀ C live framed before after old old' s h word
  obtain ⟨cell148,frame148⟩ := step_for_update_fixed_fields P.F NR FR R live framed before after old old'
    MapFor147.input s s148 C C h MapFor147.sourceValue MapFor147.sourceCellValue MapFor147.sourceTest
    MapFor147.sourceUpdate MapFor147.sourceBody MapFor147.sourceEnv MapFor147.sourceName MapFor147.sourceLabels
    MapFor147.sourceTail MapFor147.sourceCell MapFor147.source_control MapFor147.source_frame MapFor147.source_lookup
    indexCell word hr147
  have sourceFresh : MapUpdate148.sourceAddress = MapFor147.input.next := by host_kernel_rfl
  have mapped : R.a MapUpdate148.sourceAddress = s.next := by
    rw [sourceFresh]
    simpa only [Nat.add_zero] using h.heap.fresh 0
  have newNotFramed : ¬ framed MapUpdate149.sourceAddress := by
    intro hf
    have impossible := h.heap.sourceBound _ (h.heap.prefixLive _ hf)
    have same : MapUpdate149.sourceAddress = MapFor147.input.next := by host_kernel_rfl
    rw [same] at impossible
    exact Nat.lt_irrefl _ impossible
  have hl := h.stackLive
  rw [MapFor147.source_frame] at hl
  have lookupLength : lookupEnv MapTest155.sourceName MapFor147.sourceEnv = some MapTest155.address := by host_kernel_rfl
  have lengthLive := env_lookup_live MapTest155.sourceName MapFor147.sourceEnv MapTest155.address
    hl.1.1.2.2.2.1 lookupLength
  have lengthOld := h.heap.targetBound _ lengthLive
  have input148 : s148.heap.get (R.a MapUpdate148.sourceAddress) = some (.cell (some MapUpdate148.sourceValue)) := by
    rw [mapped]
    exact cell148
  obtain ⟨s149,hr148,h149,control149,heap149⟩ := MapUpdate148.transport FR R ν₀ ν C₀ C L framed before after old old'
    s148 h148 input148
  have input149 : s149.heap.get (R.a MapUpdate149.sourceAddress) =
      some (.cell (some (.num (.lit MapUpdate149.sourceNumber)))) := by
    rw [heap149]
    exact input148
  have bound149 : s149.next ≤ 2^64 := by
    rw [h.target_next_add h149 1 (by host_kernel_rfl)]
    exact bound
  obtain ⟨s150,hr149,h150,control150,heap150⟩ := MapUpdate149.transport FR R ν₀ ν C₀ C L framed before after old old'
    s149 h149 control149 input149 newNotFramed bound149
  have newSame : MapUpdate149.sourceAddress = MapUpdate148.sourceAddress := by host_kernel_rfl
  have newWord : R.a MapUpdate149.sourceAddress < 2^64 := by rw [newSame,mapped]; exact word
  have old150 (a : Nat) (ha : a < s.next) : s150.heap.get a = s.heap.get a := by
    rw [heap150]
    simp only [St.setCell,PTrie.get_set_u64 _ _ _ newWord,
      ite_eq_right (show a ≠ R.a MapUpdate149.sourceAddress by rw [newSame,mapped]; omega)]
    rw [heap149]
    exact frame148 a ha
  have index150 : s150.heap.get (R.a MapTest153.address) = some (.cell (some MapTest153.sourceValue)) := by
    have address : MapTest153.address = MapUpdate149.sourceAddress := by host_kernel_rfl
    rw [address,heap150]
    simp only [St.setCell,PTrie.get_set_u64 _ _ _ newWord,ite_true]
    rfl
  obtain ⟨s151,hr150,h151,heap151⟩ := MapUpdate150.transport FR R ν₀ ν C₀ C L framed before after old old' s150 h150
  obtain ⟨s152,hr151,h152⟩ := MapFor151.transport NR FR R C₀ C L framed before after old old' s151 h151
  have heap152 := step_for_test_heap_from_source P.F NR FR R L framed before after old old' MapFor151.input
    s151 s152 C C h151 MapFor151.sourceValue MapFor151.sourceTest MapFor151.sourceUpdate MapFor151.sourceBody
    MapFor151.sourceEnv MapFor151.sourceNames MapFor151.sourceLabels MapFor151.sourceTail MapFor151.source_control MapFor151.source_frame hr151
  obtain ⟨s153,hr152,h153⟩ := MapTest152.transport NR FR R C₀ C L framed before after old old' s152 h152
  have heap153 := step_descent_heap_from_source P.F NR FR R L framed before after old old' MapTest152.input s152 s153 C C
    h152 MapTest152.descent MapTest152.sourceEnv MapTest152.source_control hr152
  obtain ⟨v153,hr153,h154,_⟩ := MapTest153.transport NR FR R C₀ C L framed before after old old' s153 h153
  let s154 := s153.ret v153
  have input153 : s153.heap.get (R.a MapTest153.address) = some (.cell (some MapTest153.sourceValue)) := by
    rw [heap153,heap152,heap151]
    exact index150
  have fields154 := step_variable_fixed_fields P.F NR FR R L framed before after old old' MapTest153.input s153 s154 C C h153
    MapTest153.sourceName MapTest153.sourceEnv MapTest153.address MapTest153.sourceValue MapTest153.source_control MapTest153.source_lookup input153 hr153
  obtain ⟨s155,hr154,h155⟩ := MapTest154.transport NR FR R C₀ C L framed before after old old' s154 h154
  obtain ⟨fs,frame155,_,heap155⟩ := step_binary_left_saved_fields P.F NR FR R L framed before after old old' MapTest154.input
    s154 s155 C C h154 MapTest153.sourceValue MapTest154.sourceOp MapTest154.sourceRight MapTest154.sourceEnv MapTest154.sourceTail
    MapTest154.source_frame fields154.1 hr154
  obtain ⟨v155,hr155,h156,_⟩ := MapTest155.transport NR FR R C₀ C L framed before after old old' s155 h155
  let s156 := s155.ret v155
  have input155 : s155.heap.get (R.a MapTest155.address) = some (.cell (some MapTest155.sourceValue)) := by
    rw [heap155,fields154.2,heap153,heap152,heap151,old150 _ lengthOld]
    exact lengthCell
  have fields156 := step_variable_fixed_fields P.F NR FR R L framed before after old old' MapTest155.input s155 s156 C C h155
    MapTest155.sourceName MapTest155.sourceEnv MapTest155.address MapTest155.sourceValue MapTest155.source_control MapTest155.source_lookup input155 hr155
  have frames156 : ∃ fs, s156.stack = .e (.binR .lt (.num (.lit MapCompare156.sourceLeft)))::fs := ⟨fs,frame155⟩
  obtain ⟨result,hr156,h157,control157,heap157⟩ := MapCompare156.transport FR R ν₀ ν C₀ C L framed before after old old'
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
