import host.ts.renameOrdinary.MlxConstructorCleanupFramePath
import host.mlx.OrdinaryMetadataHost
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
namespace Host.Load.Run.Full.Ordinary.VectorToConcat
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric

/-- The actual constructor and finalizer free the saved vector through the
original native call. Its argument role comes from the earlier saved cell and
fifty checked source transitions, rather than an annotation supplied at421. -/
theorem construct_and_free_vector (ν₀ ν : Nat → F64) (C₀ C : CSrv)
    (FR : Ren → LSt → LSt → Prop) (R : Ren) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s : St LSt)
    (h : StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' MlxClassArgument371.input s)
    (handle : s.ctl = .ret (.big (Int.ofNat (R.handle 29372))))
    (vector : (Annotated.Value.handle 29371).Holds ν C R (cellValueAt s (R.a CleanupVector419.address)))
    (prototypeLive : live aObjectProto) (prototypeFixed : R.a aObjectProto = aObjectProto)
    (signatureFrame : ¬ framed 4413) (bound : s.next+10 ≤ 2^64) :
    ∃ result, runC P.F 51 s C = some (result,C) ∧
      StateR (NumberRoles ν₀ ν C₀ C) FR R
        (HandleLive (ConstructorBodyLive (LiveAfter (BaseClassLive live MlxClass372.input.next) TokenObject376.input.next)
          MlxBody380.input.next Sources.Mlx.Array.ast_n20)) framed before after old old' FreeCall.output result ∧
      PrivateData result (R.a 3126703) (R.a HandleStore390.sourceBrand) HandleStore390.sourceName
        (.big (Int.ofNat (R.handle 29372))) ∧
      (∀ m, m < s.next → result.heap.get m = s.heap.get m) ∧ result.ctl = .ret (.num zeroN) := by
  obtain ⟨s421,r371,h421,field,frame,argument⟩ := construct_and_enter_cleanup_framed ν₀ ν C₀ C FR R live framed
    before after old old' s h handle prototypeLive prototypeFixed bound
  have vector421 : (Annotated.Value.handle 29371).Holds ν C R (callArgument s421.ctl 0) := by rw [argument]; exact vector
  obtain ⟨result,_,r421,h422,_,ctl,heap,_⟩ := MetadataHost.free_transport_heap ν₀ ν C₀ C R FR _ framed before after old old'
    s421 h421 vector421 signatureFrame
  have lastRun : runC P.F 1 s421 C = some (result,C) := by
    apply runC_cons P.F 0 s421 result result C C C (h421.control.isHalt_eq.trans (by host_kernel_rfl)) r421
    rfl
  exact ⟨result,runC_join P.F (m := 50) (n := 1) r371 lastRun,h422,field.heap_eq heap,
    fun m below => (congrArg (fun hp => hp.get m) heap).trans (frame m below),ctl⟩
end Host.Load.Run.Full.Ordinary.VectorToConcat
