import host.ts.renameOrdinary.MapIndexRoles
import host.ts.RenameRouteHeapFields
import host.ts.RenameArrayLengthEffects
import host.ts.RenameRouteReadFields
import host.ts.RenameLiveAddress
import host.ts.RenameParametricArrayIndex

set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
namespace Host.Load.Run.Full.Ordinary
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric

/-- The actual map length prelude reads its inputs without writing the heap. -/
theorem map_length_fields (NR : NumV → NumV → Prop) (FR : Ren → P.F.S → P.F.S → Prop)
    (R : Ren) (C₀ C : CSrv) (live framed : Nat → Prop) (before after : List Val) (old old' : List Event)
    (s : St P.F.S) (h : StateR NR FR R live framed before after old old' P.RestStream.micro0.micro0.s74 s)
    (notFramed : ¬ framed 3126664) (literalTwo : NR (.lit (F64.ofNat 2)) (.lit (F64.ofNat 2))) :
    ∃ result, runC P.F 5 s C = some (result,C) ∧
      StateR NR FR R live framed before after old old' P.RestStream.micro0.micro0.s79 result ∧
      result.ctl = .ret (natV 2) ∧ result.heap = s.heap := by
  obtain ⟨s75,r74,h75⟩ := MapSetup74.transport NR FR R C₀ C live framed before after old old' s h
  have heap75 := step_block_next_heap P.F NR FR R live framed before after old old' MapSetup74.input s s75 C C h
    MapSetup74.sourceValue MapSetup74.sourceStatement MapSetup74.sourceRest MapSetup74.sourceEnv MapSetup74.sourceTail
    MapSetup74.source_control MapSetup74.source_frame r74
  obtain ⟨s76,r75,h76⟩ := MapSetup75.transport NR FR R C₀ C live framed before after old old' s75 h75
  have heap76 := step_statement_heap P.F NR FR R live framed before after old old' MapSetup75.input s75 s76 C C h75
    MapSetup75.sourceAction MapSetup75.sourceEnv MapSetup75.source_control r75
  obtain ⟨s77,r76,h77⟩ := MapSetup76.transport NR FR R C₀ C live framed before after old old' s76 h76
  have heap77 := step_descent_heap_from_source P.F NR FR R live framed before after old old' MapSetup76.input s76 s77 C C h76
    MapSetup76.descent MapSetup76.sourceEnv MapSetup76.source_control r76
  obtain ⟨s78,r77,h78⟩ := MapSetup77.transport NR FR R C₀ C live framed before after old old' s77 h77
  have heap78 := step_this_heap_from_source P.F NR FR R live framed before after old old' MapSetup77.input s77 s78 C₀ C C h77
    MapSetup77.sourceEnv MapSetup77.sourceAddress MapSetup77.sourceValue MapSetup77.source_control
    MapSetup77.source_lookup MapSetup77.source_cell r77
  obtain ⟨result,r78,h79,control79⟩ := MapSetup78.transport NR FR R C₀ C live framed before after old old' s78 h78 notFramed
    (by simpa only [map_length_two] using literalTwo)
  have heap79 := step_array_length_heap P.F NR FR R live framed before after old old' MapSetup78.input s78 result C C h78
    MapSetup78.sourceAddress MapSetup78.sourceObject MapSetup78.sourceElements MapSetup78.sourceOptional MapSetup78.sourceTail
    MapSetup78.source_control MapSetup78.source_frame MapSetup78.source_heap MapSetup78.source_kind notFramed r78
  refine ⟨result,?_,h79,by simpa only [map_length_two] using control79,?_⟩
  · apply runC_cons P.F 4 s s75 result C C C (h.control.isHalt_eq.trans map_setup_active74) r74
    apply runC_cons P.F 3 s75 s76 result C C C (h75.control.isHalt_eq.trans map_setup_active75) r75
    apply runC_cons P.F 2 s76 s77 result C C C (h76.control.isHalt_eq.trans map_setup_active76) r76
    apply runC_cons P.F 1 s77 s78 result C C C (h77.control.isHalt_eq.trans map_setup_active77) r77
    apply runC_cons P.F 0 s78 result result C C C (h78.control.isHalt_eq.trans map_setup_active78) r78
    rfl
  · rw [heap79,heap78,heap77,heap76,heap75]

/-- The original map prelude derives its exact length cell and preserves
all other incoming live cells except its two initialized local bindings. -/
theorem map_setup_literal_fields (NR : NumV → NumV → Prop) (FR : Ren → P.F.S → P.F.S → Prop)
    (R : Ren) (C₀ C : CSrv) (live framed : Nat → Prop) (before after : List Val) (old old' : List Event)
    (s : St P.F.S) (h : StateR NR FR R live framed before after old old' P.RestStream.micro0.micro0.s74 s)
    (notFramed : ¬ framed 3126664) (literalTwo : NR (.lit (F64.ofNat 2)) (.lit (F64.ofNat 2)))
    (prototypeLive : live aArrayProto) (prototypeFixed : R.a aArrayProto = aArrayProto)
    (targetBound : s.next+1 ≤ 2^64) :
    ∃ result, runC P.F 14 s C = some (result,C) ∧
      StateR NR FR R (LiveAfter live P.RestStream.micro0.micro0.s84.next) framed before after old old'
        P.RestStream.micro0.micro0.s88 result ∧
      result.heap.get (R.a 3126675) = some (.cell (some (natV 2))) ∧
      (∀ k, live k → k ≠ 3126675 → k ≠ 3126676 → result.heap.get (R.a k) = s.heap.get (R.a k)) := by
  obtain ⟨result,run,hresult⟩ := map_setup_transport NR FR R C₀ C live framed before after old old'
    s h notFramed literalTwo prototypeLive prototypeFixed targetBound
  obtain ⟨s79,run79,h79,control79,heap79⟩ := map_length_fields NR FR R C₀ C live framed before after old old'
    s h notFramed literalTwo
  have bound79 : s79.next < 2^64 := by rw [h.target_next_eq h79 map_setup_next79]; omega
  have restRun : runC P.F 9 s79 C = some (result,C) := by
    change runWith P.F interpC (5+9) s C = some (result,C) at run
    have first : runWith P.F interpC 5 s C = some (s79,C) := run79
    rw [runWith_add,first] at run
    exact run
  obtain ⟨length,frame⟩ := MapStorage.effects NR FR R C live framed before after old old' s79 result h79
    (natV 2) control79 bound79 restRun
  refine ⟨result,run,hresult,length,?_⟩
  intro k hk kn kr
  rw [frame k hk kn kr,heap79]

theorem map_setup_length_live (NR : NumV → NumV → Prop) (FR : Ren → P.F.S → P.F.S → Prop)
    (R : Ren) (live framed : Nat → Prop) (before after : List Val) (old old' : List Event)
    (s : St P.F.S) (h : StateR NR FR R live framed before after old old' MapSetup74.input s) : live 3126675 := by
  have hl := h.stackLive
  rw [MapSetup74.source_frame] at hl
  have lookup : lookupEnv ['n'] MapSetup74.sourceEnv = some 3126675 := by host_kernel_rfl
  exact env_lookup_live _ _ _ hl.1.1.2.1 lookup

def mapSetupCompleteLive (live : Nat → Prop) : Nat → Prop :=
  mapIterationLive (LiveAfter live P.RestStream.micro0.micro0.s84.next)

/-- Twenty-six original steps establish both loop operands in their cells,
including the first lexical copy, while framing the incoming caller cells. -/
theorem map_setup_guard_fields (FR : Ren → P.F.S → P.F.S → Prop) (R : Ren)
    (ν₀ ν : Nat → F64) (C₀ C : CSrv) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s : St P.F.S)
    (h : StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' MapSetup74.input s)
    (notFramed : ¬ framed 3126664)
    (prototypeLive : live aArrayProto) (prototypeFixed : R.a aArrayProto = aArrayProto)
    (bound : s.next+3 ≤ 2^64) :
    ∃ result, runC P.F 26 s C = some (result,C) ∧
      StateR (NumberRoles ν₀ ν C₀ C) FR R (mapSetupCompleteLive live) framed before after old old'
        P.RestStream.micro0.micro0.s100 result ∧
      result.heap.get (R.a 3126679) = some (.cell (some (natV 0))) ∧
      result.heap.get (R.a 3126675) = some (.cell (some (natV 2))) ∧
      (∀ k, live k → k ≠ 3126675 → k ≠ 3126676 → result.heap.get (R.a k) = s.heap.get (R.a k)) := by
  let NR := NumberRoles ν₀ ν C₀ C
  let L := LiveAfter live P.RestStream.micro0.micro0.s84.next
  obtain ⟨s88,run88,h88,length88,frame88⟩ := map_setup_literal_fields NR FR R C₀ C live framed before after old old'
    s h notFramed ⟨_,NumRole.literal ν₀ ν C₀ C _⟩ prototypeLive prototypeFixed (by omega)
  have next88 : s88.next = s.next+1 := h.target_next_add h88 1 (by host_kernel_rfl)
  obtain ⟨result,run100,h100,_,index100,frame100⟩ := map_for_guard_fields FR R ν₀ ν C₀ C L framed before after old old'
    s88 h88 length88 (by rw [next88]; omega)
  have lengthLive := map_setup_length_live NR FR R live framed before after old old' s h
  refine ⟨result,runC_join P.F run88 run100,h100,index100,?_,?_⟩
  · rw [frame100 3126675 (Or.inl lengthLive)]
    exact length88
  · intro k hk kn kr
    rw [frame100 k (Or.inl hk)]
    exact frame88 k hk kn kr

/-- Both callback receivers are live because the actual this-cell points to
an owned two-element input array. The constructor is in the actual caller stack. -/
theorem map_setup_receivers_live (NR : NumV → NumV → Prop) (FR : Ren → P.F.S → P.F.S → Prop)
    (R : Ren) (live framed : Nat → Prop) (before after : List Val) (old old' : List Event)
    (s : St P.F.S) (h : StateR NR FR R live framed before after old old' MapSetup74.input s)
    (notFramed : ¬ framed 3126664) : live 2978923 ∧ live 3126165 ∧ live 95 := by
  have hl := h.stackLive
  rw [MapSetup74.source_frame] at hl
  have thisLookup : lookupEnv nThis MapSetup74.sourceEnv = some MapSetup77.sourceAddress := by host_kernel_rfl
  have thisLive := env_lookup_live _ _ _ hl.1.1.2.1 thisLookup
  have thisCell : MapSetup74.input.heap.get MapSetup77.sourceAddress = some (.cell (some MapSetup77.sourceValue)) := by host_kernel_rfl
  obtain ⟨_,_,_,inputLive⟩ := h.heap.readCell _ _ thisLive thisCell
  have inputHeap : MapSetup74.input.heap.get MapSetup78.sourceAddress = some (.obj MapSetup78.sourceObject) := by host_kernel_rfl
  obtain ⟨_,_,_,_,_,valuesLive⟩ := h.heap.read_array MapSetup78.sourceAddress MapSetup78.sourceObject MapSetup78.sourceElements
    inputLive notFramed inputHeap MapSetup78.source_kind
  have firstLive := listSupport_nth (valueSupport live) MapSetup78.sourceElements valuesLive 0 (.obj 2978923) (by host_kernel_rfl)
  have secondLive := listSupport_nth (valueSupport live) MapSetup78.sourceElements valuesLive 1 (.obj 3126165) (by host_kernel_rfl)
  exact ⟨firstLive,secondLive,h.stack_address_live 95 (by host_kernel_rfl)⟩

end Host.Load.Run.Full.Ordinary
