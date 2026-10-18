import host.ts.renameOrdinary.ConvWeightGetterPath
import host.mlx.OrdinaryMetadataHost
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
namespace Host.Load.Run.Full.Ordinary.VectorToConcat
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Mlx.Ffi.Annotated

/-- The real nested getters and native rank read form one source execution.
The private handle annotation is required at entry and consumed by its actual
read; rank three follows from the owned carrier, rather than a later premise. -/
theorem conv_weight_rank_framed (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (nodes : Nat → GraphNode) (boundary : Nat → Prop) (objects : Nat → Object)
    (H N : Nat → Prop) (tail : List NumV) (host : HostSt → HostSt → Prop)
    (live framed : Nat → Prop) (before after : List Val) (old old' : List Event) (s : St LSt)
    (h : StateR (NumberRoles ν₀ ν C₀ C) (VectorHost.NativeRelation ν₀ ν C₀ C nodes boundary objects H N tail host)
      R live framed before after old old' WeightShapeGetter445.input s)
    (field : PrivateData s (R.a WeightHandleValue478.sourceAddress) (R.a WeightHandleValue478.sourceBrand)
      WeightHandleValue478.sourceName (.big (Int.ofNat (R.handle 1365))))
    (globalLive : live aGlobal) (globalFixed : R.a aGlobal = aGlobal)
    (signatureFrame : ¬ framed 4263) (handleLive : H 1365) (bound : s.next+20 ≤ 2^64) :
    ∃ result, runC P.F 40 s C = some (result,C) ∧
      StateR (NumberRoles ν₀ ν C₀ C) (VectorHost.NativeRelation ν₀ ν C₀ C nodes boundary objects H N tail host)
        R (WeightLive468 live) framed before after old old' NdimCall.output result ∧
      result.ctl = .ret (.big 3) ∧ (∀ a, a < s.next → result.heap.get a = s.heap.get a) ∧ result.stack.drop 9 = s.stack := by
  let NR := NumberRoles ν₀ ν C₀ C
  let FR := VectorHost.NativeRelation ν₀ ν C₀ C nodes boundary objects H N tail host
  obtain ⟨s484,run39,h484,argument,frame484,stack484⟩ := conv_weight_rank_argument_framed NR FR R C₀ C live framed before after old old'
    s h field globalLive globalFixed bound
  have role : (Annotated.Value.handle 1365).Holds ν C R (callArgument s484.ctl 0) := by
    rw [argument]
    exact .handle _
  obtain ⟨result,_,run484,h485,_,heap,_,rank,stack485⟩ := MetadataHost.ndim_transport_heap_literal_stack ν₀ ν C₀ C R nodes boundary objects H N tail host
    (WeightLive468 live) framed before after old old' s484 h484 role signatureFrame handleLive
  have one : runC P.F 1 s484 C = some (result,C) := runC_cons P.F 0 s484 result result C C C
    (h484.control.isHalt_eq.trans (by host_kernel_rfl)) run484 rfl
  exact ⟨result,runC_join P.F (m:=39) (n:=1) run39 one,h485,rank,
    (fun a below => (congrArg (fun hp => hp.get a) heap).trans (frame484 a below)),
    (congrArg (List.drop 9) stack485).trans stack484⟩
theorem conv_weight_rank (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (nodes : Nat → GraphNode) (boundary : Nat → Prop) (objects : Nat → Object)
    (H N : Nat → Prop) (tail : List NumV) (host : HostSt → HostSt → Prop)
    (live framed : Nat → Prop) (before after : List Val) (old old' : List Event) (s : St LSt)
    (h : StateR (NumberRoles ν₀ ν C₀ C) (VectorHost.NativeRelation ν₀ ν C₀ C nodes boundary objects H N tail host)
      R live framed before after old old' WeightShapeGetter445.input s)
    (field : PrivateData s (R.a WeightHandleValue478.sourceAddress) (R.a WeightHandleValue478.sourceBrand)
      WeightHandleValue478.sourceName (.big (Int.ofNat (R.handle 1365))))
    (globalLive : live aGlobal) (globalFixed : R.a aGlobal = aGlobal)
    (signatureFrame : ¬ framed 4263) (handleLive : H 1365) (bound : s.next+20 ≤ 2^64) :
    ∃ result, runC P.F 40 s C = some (result,C) ∧
      StateR (NumberRoles ν₀ ν C₀ C) (VectorHost.NativeRelation ν₀ ν C₀ C nodes boundary objects H N tail host)
        R (WeightLive468 live) framed before after old old' NdimCall.output result ∧
      result.ctl = .ret (.big 3) ∧ (∀ a, a < s.next → result.heap.get a = s.heap.get a) := by
  obtain ⟨result,run,hresult,rank,heap,_⟩ := conv_weight_rank_framed ν₀ ν C₀ C R nodes boundary objects H N tail host
    live framed before after old old' s h field globalLive globalFixed signatureFrame handleLive bound
  exact ⟨result,run,hresult,rank,heap⟩

end Host.Load.Run.Full.Ordinary.VectorToConcat
