import host.ts.renameOrdinary.MapCallbackHandle
import host.ts.renameOrdinary.DriverMapPush
import host.ts.RenameArrayPushFields

set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
namespace Host.Load.Run.Full.Ordinary
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric

/-- The first actual push stores the getter's owned handle in the fresh map
result array. The array's emptiness is derived from the source heap relation. -/
theorem map_first_push (FR : Ren → P.F.S → P.F.S → Prop) (R : Ren)
    (ν₀ ν : Nat → F64) (C₀ C : CSrv) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s : St P.F.S)
    (h : StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' MapPush146.input s)
    (notFramed : ¬ framed MapPush146.sourceAddress) (bound : s.next ≤ 2^64)
    (argument : callArgument s.ctl 0 = .big (Int.ofNat (R.handle 25732))) :
    ∃ result, interpC (step P.F s).run C = some (result,C) ∧
      StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' MapPush146.output result ∧
      ArrayData result (R.a MapPush146.sourceAddress) [.big (Int.ofNat (R.handle 25732))] ∧
      (∀ a, a ≠ R.a MapPush146.sourceAddress → result.heap.get a = s.heap.get a) := by
  let NR := NumberRoles ν₀ ν C₀ C
  obtain ⟨result,hr,hpost,_⟩ := MapPush146.transport FR R ν₀ ν C₀ C live framed before after old old'
    s h notFramed bound
  have ha : live MapPush146.sourceAddress := by
    have hl := h.controlLive
    rw [MapPush146.source_control] at hl
    exact hl.2.1
  have emptyKind : MapPush146.sourceObject.kind = .array [] := by host_kernel_rfl
  obtain ⟨o,values,ho,hk,hrvalues,_⟩ := h.heap.read_array MapPush146.sourceAddress MapPush146.sourceObject
    [] ha notFramed MapPush146.source_heap emptyKind
  cases hrvalues
  have arrayData : ArrayData s (R.a MapPush146.sourceAddress) [] := ⟨o,ho,hk⟩
  have control : MapPush146.input.ctl = .call (.obj MapPush146.sourceFunction) (.obj MapPush146.sourceAddress)
      [.big (Int.ofNat 25732)] := by host_kernel_rfl
  obtain ⟨stored,frame⟩ := step_array_push_owned_fields P.F NR FR R live framed before after old old'
    MapPush146.input s result C C h MapPush146.sourceFunction MapPush146.sourceAddress MapPush146.sourceCallee
    MapPush146.sourceObject MapPush146.sourceData (.big (Int.ofNat 25732)) (.big (Int.ofNat (R.handle 25732))) []
    control MapPush146.source_callee MapPush146.source_code MapPush146.source_heap MapPush146.source_extensible
    notFramed bound arrayData argument hr
  exact ⟨result,hr,hpost,stored,frame⟩

theorem map_first_iteration (FR : Ren → P.F.S → P.F.S → Prop) (R : Ren)
    (ν₀ ν : Nat → F64) (C₀ C : CSrv) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s : St P.F.S)
    (h : StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' MapBody100.input s)
    (resultNotFramed : ¬ framed 3126677) (inputNotFramed : ¬ framed MapBody113.sourceAddress)
    (indexCell : s.heap.get (R.a 3126679) = some (.cell (some (natV 0))))
    (field : PrivateData s (R.a MapBody138.sourceAddress) (R.a MapBody138.sourceBrand)
      MapBody138.sourceName (.big (Int.ofNat (R.handle 25732))))
    (bound : s.next+3 ≤ 2^64) :
    ∃ result, runC P.F 47 s C = some (result,C) ∧
      StateR (NumberRoles ν₀ ν C₀ C) FR R (mapCallbackGetterLive live) framed before after old old'
        MapPush146.output result ∧
      ArrayData result (R.a 3126677) [.big (Int.ofNat (R.handle 25732))] ∧
      (∀ a, a < s.next → a ≠ R.a 3126677 → result.heap.get a = s.heap.get a) := by
  obtain ⟨s146,hr146,h146,argument,frame146⟩ := map_callback_handle (NumberRoles ν₀ ν C₀ C) FR R C₀ C
    live framed before after old old' s h resultNotFramed inputNotFramed indexCell field bound
  have next146 : s146.next = s.next+3 := h.target_next_add h146 3 (by host_kernel_rfl)
  have bound146 : s146.next ≤ 2^64 := by rw [next146]; exact bound
  obtain ⟨result,hr,hpost,stored,frame⟩ := map_first_push FR R ν₀ ν C₀ C (mapCallbackGetterLive live)
    framed before after old old' s146 h146 resultNotFramed bound146 argument
  have one : runC P.F 1 s146 C = some (result,C) := by
    apply runC_cons P.F 0 s146 result result C C C (h146.control.isHalt_eq.trans (by host_kernel_rfl)) hr
    rfl
  refine ⟨result,runC_join P.F hr146 one,hpost,stored,?_⟩
  intro a ha other
  rw [frame a other]
  exact frame146 a ha

end Host.Load.Run.Full.Ordinary
