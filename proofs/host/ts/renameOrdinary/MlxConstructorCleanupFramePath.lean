import host.ts.renameOrdinary.MlxConstructorFramePath
import host.ts.renameOrdinary.MlxRegistryPath
import host.ts.renameOrdinary.MlxCleanupPath
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
namespace Host.Load.Run.Full.Ordinary.VectorToConcat
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric

theorem constructor_vector_lookup : lookupEnv CleanupVector419.sourceName MlxClassArgument371.sourceEnv =
    some CleanupVector419.address := by host_kernel_rfl

/-- All original constructor, registry and finalizer steps preserve the exact
caller vector occurrence while deriving the new array and its owned field. -/
theorem construct_and_enter_cleanup_framed (ν₀ ν : Nat → F64) (C₀ C : CSrv)
    (FR : Ren → LSt → LSt → Prop) (R : Ren) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s : St LSt)
    (h : StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' MlxClassArgument371.input s)
    (handle : s.ctl = .ret (.big (Int.ofNat (R.handle 29372))))
    (prototypeLive : live aObjectProto) (prototypeFixed : R.a aObjectProto = aObjectProto)
    (bound : s.next+10 ≤ 2^64) :
    ∃ result, runC P.F 50 s C = some (result,C) ∧
      StateR (NumberRoles ν₀ ν C₀ C) FR R
        (HandleLive (ConstructorBodyLive (LiveAfter (BaseClassLive live MlxClass372.input.next) TokenObject376.input.next)
          MlxBody380.input.next Sources.Mlx.Array.ast_n20)) framed before after old old' CleanupArguments420.output result ∧
      PrivateData result (R.a 3126703) (R.a HandleStore390.sourceBrand) HandleStore390.sourceName
        (.big (Int.ofNat (R.handle 29372))) ∧
      (∀ m, m < s.next → result.heap.get m = s.heap.get m) ∧
      callArgument result.ctl 0 = cellValueAt s (R.a CleanupVector419.address) := by
  let NR := NumberRoles ν₀ ν C₀ C
  obtain ⟨s391,r371,h391,field391,frame391⟩ := construct_array_with_frame ν₀ ν C₀ C FR R live framed before after old old'
    s h handle prototypeLive prototypeFixed bound
  obtain ⟨s409,r391,h409,_,heap409⟩ := register_and_return_constructor NR FR R C₀ C _ framed before after old old' s391 h391
  have next409 : s409.next = s.next+5 := h.target_next_add h409 5 (by host_kernel_rfl)
  obtain ⟨result,r409,h421,heap421,argument⟩ := enter_vector_cleanup NR FR R C₀ C _ framed before after old old' s409 h409
    (by rw [next409]; omega)
  have frame (m : Nat) (below : m < s.next) : result.heap.get m = s.heap.get m :=
    (congrArg (fun heap => heap.get m) (heap421.trans heap409)).trans (frame391 m below)
  have vectorLive : live CleanupVector419.address := by
    have hl := h.stackLive
    rw [MlxClassArgument371.source_frame] at hl
    have envLive : treeSupport live (Encode.env MlxClassArgument371.sourceEnv) := hl.1.1.2.2.2.2.2.1
    exact env_lookup_live _ _ _ envLive constructor_vector_lookup
  have below : R.a CleanupVector419.address < s.next := h.heap.targetBound _ vectorLive
  have entryHeap : s409.heap.get (R.a CleanupVector419.address) = s.heap.get (R.a CleanupVector419.address) :=
    (congrArg (fun heap => heap.get (R.a CleanupVector419.address)) heap409).trans (frame391 _ below)
  have entryValue := cellValueAt_heap_at s s409 _ entryHeap
  have middle := runC_join P.F (m := 20) (n := 18) r371 r391
  exact ⟨result,runC_join P.F (m := 38) (n := 12) middle r409,h421,
    field391.heap_eq (heap421.trans heap409),frame,argument.trans entryValue⟩
end Host.Load.Run.Full.Ordinary.VectorToConcat
