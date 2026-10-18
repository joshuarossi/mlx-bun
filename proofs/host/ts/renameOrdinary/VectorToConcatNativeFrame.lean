import host.mlx.NativeVectorDataHost
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
namespace Host.Load.Run.Full.Ordinary.VectorToConcat
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Mlx.Ffi.Annotated

/-- Specializing the existing generic constructor's exact target equation
shows that the actual native vector creation preserves the entire JS heap
and its allocation counter. The original native/host transport is reused. -/
theorem vector_native_transport_heap (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (nodes : Nat → GraphNode) (boundary : Nat → Prop) (objects : Nat → Object)
    (H N : Nat → Prop) (tail : List NumV) (host : HostSt → HostSt → Prop)
    (live framed : Nat → Prop) (before after : List Val) (old old' : List Event) (s : St LSt)
    (h : StateR (NumberRoles ν₀ ν C₀ C) (VectorHost.NativeRelation ν₀ ν C₀ C nodes boundary objects H N tail host)
      R live framed before after old old' VectorCall.input s)
    (countRole : (Annotated.Value.ordinaryBig (Int.ofNat 2)).Holds ν C R (callArgument s.ctl 1))
    (bufferRole : (VectorBuffer.role [25732,29363]).Holds ν C R (objectKindAt s (R.a 3126688)))
    (signatureFrame : ¬ framed 4411) (firstLive : H 25732) (secondLive : H 29363)
    (nativeBound : s.ffi.mlx.next < 2^64) :
    ∃ result, interpC (step P.F s).run C = some (result,C) ∧
      StateR (NumberRoles ν₀ ν C₀ C)
        (VectorHost.NativeRelation ν₀ ν C₀ C nodes boundary (objectWrite objects 29371 (.vec [20208,22582]))
          (fun a => a = 29371 ∨ H a) N tail host)
        R live framed before after old old' VectorCall.output result ∧
      result.ctl = .ret (.big (Int.ofNat (R.handle 29371))) ∧ result.heap = s.heap ∧ result.next = s.next := by
  have hk := VectorCall.source_callee_kind
  rw [VectorCall.source_caps] at hk
  have hb := VectorCall.source_buffer_kind
  rw [VectorCall.source_bytes] at hb
  obtain ⟨_,exactRun,_⟩ := VectorDataHost.from_source ν₀ ν C₀ C R nodes boundary objects H N tail host
    live framed before after old old' VectorCall.input s h 4709 4411 3126688 VectorCall.calleeObject VectorCall.signatureObject
    VectorCall.bufferObject chars!"u64" (.obj 4817) [25732,29363] [20208,22582]
    VectorCall.source_control VectorCall.source_callee hk VectorCall.source_signature VectorCall.source_signature_kind
    VectorCall.source_buffer hb signatureFrame ⟨firstLive,secondLive,True.intro⟩ VectorCall.source_inputs
    (by change VectorCall.native.next < 2^64; rw [VectorCall.source_counter]; decide +kernel) nativeBound countRole bufferRole
  obtain ⟨result,_,run,hr,hc⟩ := VectorHost.transport ν₀ ν C₀ C R nodes boundary objects H N tail host
    live framed before after old old' s h countRole bufferRole signatureFrame firstLive secondLive nativeBound
  have he := congrArg Prod.fst (Option.some.inj (run.symm.trans exactRun))
  dsimp only at he
  refine ⟨result,run,hr,hc,?_,?_⟩
  · have hh := congrArg (fun t : St LSt => t.heap) he
    exact hh
  · have hn := congrArg (fun t : St LSt => t.next) he
    exact hn
end Host.Load.Run.Full.Ordinary.VectorToConcat
