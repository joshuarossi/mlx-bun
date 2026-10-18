import host.ts.renameOrdinary.MapFirstPush
import host.ts.renameOrdinary.MapIncrement
import host.ts.renameOrdinary.MapSecondCallbackHandle
import host.ts.renameOrdinary.MapSecondIncrement

set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
namespace Host.Load.Run.Full.Ordinary
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric

theorem map_second_push (FR : Ren → P.F.S → P.F.S → Prop) (R : Ren)
    (ν₀ ν : Nat → F64) (C₀ C : CSrv) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s : St P.F.S)
    (h : StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' MapPush203.input s)
    (notFramed : ¬ framed MapPush203.sourceAddress) (bound : s.next ≤ 2^64)
    (values : List Val) (contents : ArrayData s (R.a MapPush203.sourceAddress) values)
    (argument : callArgument s.ctl 0 = .big (Int.ofNat (R.handle 29363))) :
    ∃ result, interpC (step P.F s).run C = some (result,C) ∧
      StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' MapPush203.output result ∧
      ArrayData result (R.a MapPush203.sourceAddress) (values++[.big (Int.ofNat (R.handle 29363))]) ∧
      (∀ a, a ≠ R.a MapPush203.sourceAddress → result.heap.get a = s.heap.get a) := by
  let NR := NumberRoles ν₀ ν C₀ C
  obtain ⟨result,hr,hpost,_⟩ := MapPush203.transport FR R ν₀ ν C₀ C live framed before after old old'
    s h notFramed bound
  have control : MapPush203.input.ctl = .call (.obj MapPush203.sourceFunction) (.obj MapPush203.sourceAddress)
      [.big (Int.ofNat 29363)] := by host_kernel_rfl
  obtain ⟨stored,frame⟩ := step_array_push_owned_fields P.F NR FR R live framed before after old old'
    MapPush203.input s result C C h MapPush203.sourceFunction MapPush203.sourceAddress MapPush203.sourceCallee
    MapPush203.sourceObject MapPush203.sourceData (.big (Int.ofNat 29363)) (.big (Int.ofNat (R.handle 29363))) values
    control MapPush203.source_callee MapPush203.source_code MapPush203.source_heap MapPush203.source_extensible
    notFramed bound contents argument hr
  exact ⟨result,hr,hpost,stored,frame⟩

def mapCompleteLive (live : Nat → Prop) : Nat → Prop :=
  mapSecondNextIterationLive (mapSecondCallbackGetterLive (mapNextIterationLive (mapCallbackGetterLive live)))

/-- Both actual callbacks and pushes, their lexical index copies, and the
terminating comparison produce the two owned handles in source order. -/
theorem map_iterations (FR : Ren → P.F.S → P.F.S → Prop) (R : Ren)
    (ν₀ ν : Nat → F64) (C₀ C : CSrv) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s : St P.F.S)
    (h : StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' MapBody100.input s)
    (resultNotFramed : ¬ framed 3126677) (inputNotFramed : ¬ framed MapBody113.sourceAddress)
    (arrayLive : live 3126677) (indexLive : live 3126679) (lengthLive : live 3126675)
    (secondLive : live 3126165)
    (indexCell : s.heap.get (R.a 3126679) = some (.cell (some (natV 0))))
    (lengthCell : s.heap.get (R.a 3126675) = some (.cell (some (natV 2))))
    (firstField : PrivateData s (R.a MapBody138.sourceAddress) (R.a MapBody138.sourceBrand)
      MapBody138.sourceName (.big (Int.ofNat (R.handle 25732))))
    (secondField : PrivateData s (R.a MapBody195.sourceAddress) (R.a MapBody195.sourceBrand)
      MapBody195.sourceName (.big (Int.ofNat (R.handle 29363))))
    (bound : s.next+8 ≤ 2^64) :
    ∃ result, runC P.F 114 s C = some (result,C) ∧
      StateR (NumberRoles ν₀ ν C₀ C) FR R (mapCompleteLive live) framed before after old old'
        MapCompare213.output result ∧ result.ctl = .ret (.bool false) ∧
      ArrayData result (R.a 3126677)
        [.big (Int.ofNat (R.handle 25732)),.big (Int.ofNat (R.handle 29363))] ∧
      (∀ a, a < s.next → a ≠ R.a 3126677 → result.heap.get a = s.heap.get a) := by
  let NR := NumberRoles ν₀ ν C₀ C
  let L1 := mapCallbackGetterLive live
  let L2 := mapNextIterationLive L1
  let L3 := mapSecondCallbackGetterLive L2
  have oldIndex := h.heap.targetBound _ indexLive
  have oldLength := h.heap.targetBound _ lengthLive
  have oldSecond := h.heap.targetBound _ secondLive
  have oldArray := h.heap.targetBound _ arrayLive
  have indexOther : R.a 3126679 ≠ R.a 3126677 := fun eq => by
    have bad := h.heap.inj _ _ indexLive arrayLive eq
    omega
  have lengthOther : R.a 3126675 ≠ R.a 3126677 := fun eq => by
    have bad := h.heap.inj _ _ lengthLive arrayLive eq
    omega
  have secondOther : R.a 3126165 ≠ R.a 3126677 := fun eq => by
    have bad := h.heap.inj _ _ secondLive arrayLive eq
    omega
  obtain ⟨s147,run147,h147,array147,frame147⟩ := map_first_iteration FR R ν₀ ν C₀ C live framed before after old old'
    s h resultNotFramed inputNotFramed indexCell firstField (by omega)
  have next147 : s147.next = s.next+3 := h.target_next_add h147 3 (by host_kernel_rfl)
  have index147 : s147.heap.get (R.a MapFor147.sourceCell) = some (.cell (some MapFor147.sourceCellValue)) := by
    change s147.heap.get (R.a 3126679) = some (.cell (some (natV 0)))
    rw [frame147 _ oldIndex indexOther]
    exact indexCell
  have length147 : s147.heap.get (R.a MapTest155.address) = some (.cell (some MapTest155.sourceValue)) := by
    change s147.heap.get (R.a 3126675) = some (.cell (some (natV 2)))
    rw [frame147 _ oldLength lengthOther]
    exact lengthCell
  obtain ⟨s157,run157,h157,_,index157,frame157⟩ := map_increment FR R ν₀ ν C₀ C L1 framed before after old old'
    s147 h147 index147 length147 (by rw [next147]; omega)
  have next157 : s157.next = s.next+4 := h.target_next_add h157 4 (by host_kernel_rfl)
  have second157 := secondField.heap_at ((frame157 _ (by change R.a 3126165 < s147.next; rw [next147]; omega)).trans
    (frame147 _ oldSecond secondOther))
  obtain ⟨s203,run203,h203,argument203,frame203⟩ := map_second_callback_handle NR FR R C₀ C L2 framed before after old old'
    s157 h157 resultNotFramed inputNotFramed index157 second157 (by rw [next157]; omega)
  have next203 : s203.next = s.next+7 := h.target_next_add h203 7 (by host_kernel_rfl)
  have array203 := array147.heap_at ((frame203 _ (by rw [next157]; omega)).trans
    (frame157 _ (by rw [next147]; omega)))
  obtain ⟨s204,run204,h204,array204,frame204⟩ := map_second_push FR R ν₀ ν C₀ C L3 framed before after old old'
    s203 h203 resultNotFramed (by rw [next203]; omega) _ array203 argument203
  have next204 : s204.next = s.next+7 := h.target_next_add h204 7 (by host_kernel_rfl)
  have freshIndex : R.a 3126683 = s.next+3 := by
    have src : 3126683 = MapBody100.input.next+3 := by host_kernel_rfl
    rw [src]
    exact h.heap.fresh 3
  have nextIndexLive : L2 3126683 := by
    apply Or.inr
    rfl
  have arrayLive2 : L2 3126677 := by
    apply Or.inl
    apply CellsLive.grow
    apply ClosureLive.grow
    apply ClosureLive.grow
    exact arrayLive
  have nextIndexOther : R.a 3126683 ≠ R.a 3126677 := fun eq => by
    have bad := h157.heap.inj _ _ nextIndexLive arrayLive2 eq
    omega
  have index204 : s204.heap.get (R.a MapFor204.sourceCell) = some (.cell (some MapFor204.sourceCellValue)) := by
    change s204.heap.get (R.a 3126683) = some (.cell (some (natV 1)))
    rw [frame204 _ nextIndexOther,frame203 _ (by rw [freshIndex,next157]; omega)]
    exact index157
  have length204 : s204.heap.get (R.a MapTest212.address) = some (.cell (some MapTest212.sourceValue)) := by
    change s204.heap.get (R.a 3126675) = some (.cell (some (natV 2)))
    rw [frame204 _ lengthOther,frame203 _ (by rw [next157]; omega),frame157 _ (by rw [next147]; omega)]
    exact length147
  obtain ⟨result,run214,h214,guard214,_,frame214⟩ := map_second_increment FR R ν₀ ν C₀ C L3 framed before after old old'
    s204 h204 index204 length204 (by rw [next204]; omega)
  have one204 : runC P.F 1 s203 C = some (s204,C) :=
    runC_cons P.F 0 s203 s204 s204 C C C (h203.control.isHalt_eq.trans (by host_kernel_rfl)) run204 rfl
  have run57 : runC P.F 57 s C = some (s157,C) := runC_join P.F run147 run157
  have run104 : runC P.F 104 s C = some (s204,C) := runC_join P.F (runC_join P.F run57 run203) one204
  refine ⟨result,runC_join P.F run104 run214,h214,guard214,?_,?_⟩
  · exact array204.heap_at (frame214 _ (by change R.a 3126677 < s204.next; rw [next204]; omega))
  · intro a ha other
    rw [frame214 _ (by rw [next204]; omega),frame204 _ other,frame203 _ (by rw [next157]; omega),
      frame157 _ (by rw [next147]; omega)]
    exact frame147 a ha other

end Host.Load.Run.Full.Ordinary
