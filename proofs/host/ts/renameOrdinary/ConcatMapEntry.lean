import host.ts.renameOrdinary.CallbackPath
import host.ts.renameOrdinary.MapEntryPath
import host.ts.RenameLiveAddress
import host.ts.RenameParametricArrayIndex

set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
namespace Host.Load.Run.Full.Ordinary
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric

def concatMapLive (live : Nat → Prop) : Nat → Prop :=
  mapBodyLive (LiveAfter live P.RestStream.micro0.micro0.s58.next)

/-- Actual evaluation of the map callback, closure parameters and helper body
adds only fresh cells and preserves every pre-existing caller heap slot. -/
theorem concat_map_entry (NR : NumV → NumV → Prop) (FR : Ren → P.F.S → P.F.S → Prop)
    (R : Ren) (C₀ C : CSrv) (live framed : Nat → Prop) (before after : List Val)
    (old old' : List Event) (s : St P.F.S)
    (h : StateR NR FR R live framed before after old old' Callback49.input s)
    (inputNotFramed : ¬ framed Callback56.sourceAddress)
    (prototypeLive : live aFunctionProto) (prototypeFixed : R.a aFunctionProto = aFunctionProto)
    (globalLive : live aGlobal) (globalFixed : R.a aGlobal = aGlobal)
    (bound : s.next+7 ≤ 2^64) :
    ∃ result, runC P.F 25 s C = some (result,C) ∧
      StateR NR FR R (concatMapLive live) framed before after old old' P.RestStream.micro0.micro0.s74 result ∧
      (∀ a, a < s.next → result.heap.get a = s.heap.get a) := by
  obtain ⟨s60,run60,h60,frame60⟩ := concat_callback_fields NR FR R C₀ C live framed before after old old'
    s h inputNotFramed prototypeLive prototypeFixed globalLive globalFixed (by omega)
  have next60 : s60.next = s.next+1 := h.target_next_add h60 1 (by host_kernel_rfl)
  have bodyCost : 4+(blockNames MapEntry65.sourceBody).length = 6 := by host_kernel_rfl
  obtain ⟨result,run74,h74,frame74⟩ := map_entry_fields NR FR R C₀ C
    (LiveAfter live P.RestStream.micro0.micro0.s58.next) framed before after old old' s60 h60 (Or.inl globalLive) globalFixed
    (by rw [Nat.add_assoc,bodyCost,next60]; omega)
  refine ⟨result,runC_join P.F run60 run74,h74,?_⟩
  intro a ha
  exact (frame74 a (by rw [next60]; omega)).trans (frame60 a ha)

/-- The original argument cell and array own both callback receivers; the
original global object owns the typed-array constructor before evaluation. -/
theorem concat_initial_live (NR : NumV → NumV → Prop) (FR : Ren → P.F.S → P.F.S → Prop)
    (R : Ren) (live framed : Nat → Prop) (before after : List Val) (old old' : List Event)
    (s : St P.F.S) (h : StateR NR FR R live framed before after old old' Callback49.input s)
    (inputNotFramed : ¬ framed Callback56.sourceAddress) (globalLive : live aGlobal) :
    live 2978923 ∧ live 3126165 ∧ live 95 := by
  have arrayCell := h.stack_address_live Callback55.address (by host_kernel_rfl)
  have sourceCell : Callback49.input.heap.get Callback55.address = some (.cell (some Callback55.sourceValue)) := by host_kernel_rfl
  obtain ⟨_,_,_,inputLive⟩ := h.heap.readCell _ _ arrayCell sourceCell
  have sourceInput : Callback49.input.heap.get Callback56.sourceAddress = some (.obj Callback56.sourceObject) := by host_kernel_rfl
  obtain ⟨_,_,_,_,_,valuesLive⟩ := h.heap.read_array Callback56.sourceAddress Callback56.sourceObject Callback56.sourceElements
    inputLive inputNotFramed sourceInput Callback56.source_kind
  have firstLive := listSupport_nth (valueSupport live) Callback56.sourceElements valuesLive 0 (.obj 2978923) (by host_kernel_rfl)
  have secondLive := listSupport_nth (valueSupport live) Callback56.sourceElements valuesLive 1 (.obj 3126165) (by host_kernel_rfl)
  have sourceGlobal : Callback49.input.heap.get aGlobal = some (.obj Callback52.sourceObject) := by host_kernel_rfl
  obtain ⟨_,_,_,globalSupport⟩ := h.heap.readOrdinary aGlobal Callback52.sourceObject globalLive sourceGlobal Callback52.source_kind
  have constructorLive := treeHasAddress_live live 95 (Encode.obj Callback52.sourceObject) globalSupport (by host_kernel_rfl)
  exact ⟨firstLive,secondLive,constructorLive⟩

end Host.Load.Run.Full.Ordinary
