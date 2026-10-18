import host.ts.renameOrdinary.ConvWeightRankGuard
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
namespace Host.Load.Run.Full.Ordinary.VectorToConcat
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Mlx.Ffi.Annotated

/-- Executed rank metadata, Number conversion and binding decide the original
zero-rank branch. The older caller heap is framed across the entire block. -/
theorem conv_weight_rank_and_guard (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (nodes : Nat → GraphNode) (boundary : Nat → Prop) (objects : Nat → Object)
    (H N : Nat → Prop) (tail : List NumV) (host : HostSt → HostSt → Prop)
    (live framed : Nat → Prop) (before after : List Val) (old old' : List Event) (s : St LSt)
    (h : StateR (NumberRoles ν₀ ν C₀ C) (VectorHost.NativeRelation ν₀ ν C₀ C nodes boundary objects H N tail host)
      R live framed before after old old' WeightShapeGetter445.input s)
    (field : PrivateData s (R.a WeightHandleValue478.sourceAddress) (R.a WeightHandleValue478.sourceBrand)
      WeightHandleValue478.sourceName (.big (Int.ofNat (R.handle 1365))))
    (globalLive : live aGlobal) (globalFixed : R.a aGlobal = aGlobal)
    (signatureFrame : ¬ framed 4263) (handleLive : H 1365) (bound : s.next+20 ≤ 2^64) :
    ∃ result, runC P.F 57 s C = some (result,C) ∧
      StateR (NumberRoles ν₀ ν C₀ C) (VectorHost.NativeRelation ν₀ ν C₀ C nodes boundary objects H N tail host)
        R (WeightLive468 live) framed before after old old' WeightGuard18.output result ∧
      result.heap.get (R.a WeightInitialize9.sourceAddress) = some (.cell (some (natV 3))) ∧ (∀ a, a < s.next → result.heap.get a = s.heap.get a) := by
  let NR := NumberRoles ν₀ ν C₀ C
  let FR := VectorHost.NativeRelation ν₀ ν C₀ C nodes boundary objects H N tail host
  obtain ⟨s485,run40,h485,rank,frame485⟩ := conv_weight_rank ν₀ ν C₀ C R nodes boundary objects H N tail host
    live framed before after old old' s h field globalLive globalFixed signatureFrame handleLive bound
  have next485 := h.heap.target_next_add h485.heap (WeightCollect2.input.next-WeightShapeGetter445.input.next) (by host_kernel_rfl)
  have budget485 : WeightCollect2.input.next-WeightShapeGetter445.input.next ≤ 20 := by decide +kernel
  have bound485 : s485.next ≤ 2^64 := by omega
  obtain ⟨s493,run8,h493,rank493,frame493⟩ := conv_weight_rank_binding FR R ν₀ ν C₀ C (WeightLive468 live)
    framed before after old old' s485 h485 rank bound485
  obtain ⟨result,run9,hr,heap⟩ := conv_weight_rank_guard FR R ν₀ ν C₀ C (WeightLive468 live)
    framed before after old old' s493 h493 rank493
  have rankResult : result.heap.get (R.a WeightInitialize9.sourceAddress) = some (.cell (some (natV 3))) := by
    rw [heap]; exact rank493
  have sourceFresh : WeightShapeGetter445.input.next+(WeightInitialize9.sourceAddress-WeightShapeGetter445.input.next) = WeightInitialize9.sourceAddress := by decide +kernel
  have mappedFresh := h.heap.fresh (WeightInitialize9.sourceAddress-WeightShapeGetter445.input.next)
  rw [sourceFresh] at mappedFresh
  have frame (a : Nat) (below : a < s.next) : result.heap.get a = s.heap.get a := by
    have other : a ≠ R.a WeightInitialize9.sourceAddress := by omega
    exact (congrArg (fun hp => hp.get a) heap).trans ((frame493 a other).trans (frame485 a below))
  exact ⟨result,runC_join P.F (m:=48) (n:=9) (runC_join P.F (m:=40) (n:=8) run40 run8) run9,hr,rankResult,frame⟩
end Host.Load.Run.Full.Ordinary.VectorToConcat
