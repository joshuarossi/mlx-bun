import host.ts.renameOrdinary.MapSecondCallbackEntry
import host.ts.renameOrdinary.MapSecondGetterHandle

set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
namespace Host.Load.Run.Full.Ordinary
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric

/-- The executed map index, argument evaluation, callback and handle getter
derive the first Array.push argument. Only the initial owning field carries
the handle annotation; the intermediate argument is a conclusion. -/
theorem map_second_callback_handle (NR : NumV → NumV → Prop)
    (FR : Ren → P.F.S → P.F.S → Prop) (R : Ren) (C₀ C : CSrv)
    (live framed : Nat → Prop) (before after : List Val) (old old' : List Event)
    (s : St P.F.S) (h : StateR NR FR R live framed before after old old' MapBody157.input s)
    (resultNotFramed : ¬ framed 3126677)
    (inputNotFramed : ¬ framed MapBody170.sourceAddress)
    (indexCell : s.heap.get (R.a 3126683) = some (.cell (some (natV 1))))
    (field : PrivateData s (R.a MapBody195.sourceAddress) (R.a MapBody195.sourceBrand)
      MapBody195.sourceName (.big (Int.ofNat (R.handle 29363))))
    (bound : s.next+3 ≤ 2^64) :
    ∃ result, runC P.F 46 s C = some (result,C) ∧
      StateR NR FR R (mapSecondCallbackGetterLive live) framed before after old old' MapBody202.output result ∧
      callArgument result.ctl 0 = .big (Int.ofNat (R.handle 29363)) ∧
      (∀ a, a < s.next → result.heap.get a = s.heap.get a) := by
  obtain ⟨s113,hr113,h113,hindex,heap113⟩ := map_second_body_to_index NR FR R C₀ C live framed before after old old'
    s h resultNotFramed indexCell
  have next113 : s113.next = s.next := h.target_next_eq h113 (by host_kernel_rfl)
  have bound113 : s113.next+3 ≤ 2^64 := by rw [next113]; exact bound
  have fixedIndex : s113.ctl = .ret MapBody170.sourceValue := hindex
  obtain ⟨s128,hr128,h128,frame128⟩ := map_second_callback_getter_entry NR FR R C₀ C live framed before after old old'
    s113 h113 inputNotFramed fixedIndex bound113
  have receiverLive := map_second_callback_receiver_live NR FR R live framed before after old old' s113 h113 inputNotFramed
  have sourceReceiver : MapBody195.sourceAddress = 3126165 := by host_kernel_rfl
  have receiverBound : R.a MapBody195.sourceAddress < s113.next := by
    rw [sourceReceiver]
    exact h113.heap.targetBound _ receiverLive
  have field128 := (field.heap_eq heap113).heap_at (frame128 _ receiverBound)
  obtain ⟨result,hr146,h146,argument,heap146⟩ := map_second_getter_handle_transport NR FR R C₀ C
    (mapSecondCallbackGetterLive live) framed before after old old' s128 h128 field128
  have bodyRun : runC P.F 28 s C = some (s128,C) := runC_join P.F hr113 hr128
  refine ⟨result,runC_join P.F bodyRun hr146,h146,argument,?_⟩
  intro a ha
  rw [heap146,frame128 a (by rw [next113]; exact ha)]
  exact congrArg (fun heap => heap.get a) heap113

end Host.Load.Run.Full.Ordinary
