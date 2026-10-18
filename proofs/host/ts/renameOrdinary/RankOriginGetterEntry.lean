import host.ts.renameOrdinary.RankOriginBody
import host.ts.RenameClosureEffects
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
namespace Host.Load.Run.Full.Ordinary.RankOrigin
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric

def GetterLive (live : Nat → Prop) : Nat → Prop :=
  ClosureLive live EnterGetter28.input.next EnterGetter28.sourceArrow EnterGetter28.sourceHome EnterGetter28.sourceFunction

theorem getter_next : P.micro3275.s29.next = P.micro3275.s28.next+2 := by host_kernel_rfl

theorem getter_entry_transport (NR : NumV → NumV → Prop) (FR : Ren → LSt → LSt → Prop)
    (R : Ren) (C₀ C : CSrv) (live framed : Nat → Prop) (before after : List Val)
    (old old' : List Event) (s : St LSt)
    (h : StateR NR FR R live framed before after old old' P.micro3275.s28 s)
    (bound : s.next + 2 + (paramNames EnterGetter28.sourceFunction).length ≤ 2^64) :
    ∃ result, runC P.F 2 s C = some (result,C) ∧
      StateR NR FR R (GetterLive live) framed before after old old' P.micro3275.s30 result ∧
      (∀ a, a < s.next → result.heap.get a = s.heap.get a) := by
  obtain ⟨s29,hr28,h29⟩ := EnterGetter28.transport NR FR R C₀ C live framed before after old old' s h bound
  have hn29 : s29.next = s.next+2 := h.target_next_add h29 2 getter_next
  have hb29 : s29.next ≤ 2^64 := by rw [hn29]; omega
  obtain ⟨result,hr29,h30,hh30⟩ := getter_body_transport NR FR R C₀ C (GetterLive live) framed before after old old' s29 h29 hb29
  have hh29 := step_closure_heap_below P.F NR FR R live framed before after old old' EnterGetter28.input s s29 C C h
    EnterGetter28.address EnterGetter28.object EnterGetter28.sourceFunction EnterGetter28.sourceEnv
    EnterGetter28.sourceArrow EnterGetter28.sourceHome EnterGetter28.sourceThis EnterGetter28.sourceArgs
    EnterGetter28.source_control EnterGetter28.source_heap EnterGetter28.source_kind bound hr28
  refine ⟨result,?_,h30,?_⟩
  · apply runC_cons P.F 1 s s29 result C C C (h.control.isHalt_eq.trans (by host_kernel_rfl)) hr28
    apply runC_cons P.F 0 s29 result result C C C (h29.control.isHalt_eq.trans (by host_kernel_rfl)) hr29
    rfl
  · intro a ha
    rw [hh30]
    exact hh29 a ha
end Host.Load.Run.Full.Ordinary.RankOrigin
