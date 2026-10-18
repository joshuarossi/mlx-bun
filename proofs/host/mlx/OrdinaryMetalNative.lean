import host.mlx.OrdinaryMetalCut

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

namespace Host.Load.Run.Full.Ordinary.MetalNative
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric
open Host.Mlx.Ffi Host.Mlx.Ffi.NativeRoles Host.Mlx.Ffi.Annotated

noncomputable def result : Host.Mlx.Ffi.St × List Nat :=
  kernelApply.outs 18215 MetalCall.inputs MetalCall.config MetalCall.native 0 MetalCall.config.outs
noncomputable def final : Host.Mlx.Ffi.St := result.1.setObj 29388 (.vec result.2)
noncomputable def sourceArgs : List Arg := [.jsPtr 3127256 0 (cellParts .u64 (.big (Int.ofNat 29388)) 8 0),
  .big (Int.ofNat 18215),.big (Int.ofNat 29387),.big (Int.ofNat 29386),.big (Int.ofNat 2)]
noncomputable def targetArgs (R : Ren) : List Arg := [.jsPtr (R.a 3127256) 0 (cellParts .u64 (.big (Int.ofNat (R.handle 29388))) 8 0),
  .big (Int.ofNat (R.handle 18215)),.big (Int.ofNat (R.handle 29387)),.big (Int.ofNat (R.handle 29386)),.big (Int.ofNat (R.handle 2))]

theorem result_nodes : result.2 = [22603,22604] := by host_kernel_rfl

theorem source_native_call : Host.Mlx.Ffi.call MetalCall.native chars!"mlx_fast_metal_kernel_apply" sourceArgs =
    okW final status0 [u64Write 3127256 0 29388] := by
  have frame := kernel_outputs_objs 18215 MetalCall.inputs MetalCall.config MetalCall.config.outs MetalCall.native 0
  have hv : result.1.obj? 29388 = some (.vec []) := by
    change result.1.objs.get 29388 = some (.vec [])
    simp only [result,frame]; exact MetalCall.source_output
  rw [sourceArgs,call_kernelApply]
  exact NativeRoles.kernelApply_existing MetalCall.native result.1 _ 3127256 0 29388 18215 29387 29386
    MetalCall.kernelName MetalCall.kernelSource MetalCall.kernelHeader 7 2 MetalCall.inputs result.2 [] MetalCall.config
    rfl MetalCall.source_kernel MetalCall.source_inputs MetalCall.source_config rfl hv

/-- The real first ordinary Metal application uses its exact kernel source,
input vector and configuration. All output occurrence meanings are derived
from the fixed configuration role already carried by the native invariant. -/
theorem transport {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren}
    (roles : Nat → GraphNode) (boundary : Nat → Prop) (objects : Nat → Object) (configRole : Config)
    {H N : Nat → Prop} {tail : List NumV} {target : Host.Mlx.Ffi.St}
    (h : Live (NumberRoles ν₀ ν C₀ C) R (NodeRel roles ν₀ ν C₀ C R boundary)
      (ObjectRel objects ν₀ ν C₀ C R) H N tail MetalCall.native target)
    (kernelLive : H 18215) (inputsLive : H 29387) (configLive : H 29386) (outputLive : H 29388)
    (fixedConfig : objects 29386 = .config configRole)
    (targetNodes : target.nnext + configRole.outs.length < 2^64) (targetHandles : target.next < 2^64) :
    ∃ c' K,
      let targetResult := kernelApply.outs (R.handle 18215) (MetalCall.inputs.map R.node) c' target 0 c'.outs
      Host.Mlx.Ffi.call target chars!"mlx_fast_metal_kernel_apply" (targetArgs R) =
        okW (targetResult.1.setObj (R.handle 29388) (.vec targetResult.2)) status0 [u64Write (R.a 3127256) 0 (R.handle 29388)] ∧
      Live (NumberRoles ν₀ ν C₀ C) R
        (NodeRel (kernelOutputRoles roles 18215 MetalCall.inputs configRole 22603 0 configRole.outs) ν₀ ν C₀ C R boundary)
        (ObjectRel (objectWrite objects 29388 (.vec [22603,22604])) ν₀ ν C₀ C R) H K tail
        final (targetResult.1.setObj (R.handle 29388) (.vec targetResult.2)) ∧
      targetResult.2 = [22603,22604].map R.node ∧ (∀ i, N i → K i) ∧ listSupport K [22603,22604] := by
  obtain ⟨_,_,hs,_⟩ := h.config_view_roles 29386 configLive configRole MetalCall.config fixedConfig MetalCall.source_config
  have lengths : configRole.outs.length = MetalCall.config.outs.length := by
    have hl : ∀ {xs : List (Shape × Nat)} {ys : List (List Dim × Nat)},
        ListR (fun r v => Shape.Holds ν₀ C₀ r.1 v.1 ∧ v.2 = r.2) xs ys → xs.length = ys.length := by
      intro xs ys hh
      induction hh with
      | nil => rfl
      | cons _ _ ih => exact congrArg Nat.succ ih
    exact hl hs.output
  have sourceBound : MetalCall.native.nnext + configRole.outs.length < 2^64 := by
    rw [lengths,MetalCall.source_output_count,MetalCall.source_node_counter]
    decide +kernel
  have targetSlot : R.handle 29388 < 2^64 :=
    Nat.lt_trans (h.handleMap.bound 29388 (h.liveHandleBound 29388 outputLive)) targetHandles
  obtain ⟨c',K,_,hs',ht,hl,hm,hinc,hsup,_⟩ := h.kernelApply_existing_roles
    (.jsPtr 3127256 0 (cellParts .u64 (.big (Int.ofNat 29388)) 8 0))
    (.jsPtr (R.a 3127256) 0 (cellParts .u64 (.big (Int.ofNat (R.handle 29388))) 8 0))
    3127256 0 29388 18215 29387 29386 MetalCall.kernelName MetalCall.kernelSource MetalCall.kernelHeader 7 2
    MetalCall.inputs [] configRole MetalCall.config outputLive kernelLive inputsLive configLive rfl rfl
    MetalCall.source_kernel MetalCall.source_inputs MetalCall.source_output MetalCall.source_config fixedConfig sourceBound targetNodes
    (by decide +kernel) targetSlot
  rw [← result,result_nodes,MetalCall.source_node_counter] at hl
  rw [← result,result_nodes] at hm hsup
  refine ⟨c',K,?_,hl,hm,hinc,hsup⟩
  rw [targetArgs,call_kernelApply]
  exact ht

end Host.Load.Run.Full.Ordinary.MetalNative
