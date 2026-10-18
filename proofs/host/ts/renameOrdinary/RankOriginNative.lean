import host.ts.renameOrdinary.RankOriginH0
import host.ts.RenameParametricRankNative
import host.ts.renameOrdinary.Prefix39
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
namespace Host.Load.Run.Full.Ordinary.RankOrigin
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric

noncomputable def input : St LSt := P.micro3275.s1
noncomputable def output : St LSt := P.micro3275.s2
noncomputable def functionObject : Obj := match input.heap.get 4635 with
  | some (.obj o) => o | _ => ⟨.ordinary,.null,[],[],true⟩
noncomputable def signature : Nat := match functionObject.kind with
  | .fn (.native (.ffi .symbol) [_,.obj a,_]) => a | _ => 0
noncomputable def returns : Name := match functionObject.kind with
  | .fn (.native (.ffi .symbol) [_,_,.str rt]) => rt | _ => []
noncomputable def signatureObject : Obj := match input.heap.get signature with
  | some (.obj o) => o | _ => ⟨.ordinary,.null,[],[],true⟩
noncomputable def node : Host.Mlx.Ffi.Node := match input.ffi.mlx.node? 29363 with
  | some n => n | _ => ⟨.zeros,[],[],0⟩

theorem source_control : input.ctl = .call (.obj 4635) (.obj 4817) [.big (Int.ofNat 29363)] := by host_kernel_rfl
theorem source_heap : input.heap.get 4635 = some (.obj functionObject) := by host_kernel_rfl
theorem source_kind : functionObject.kind = .fn (.native (.ffi .symbol)
    [.str chars!"mlx_array_ndim",.obj signature,.str returns]) := by host_kernel_rfl
theorem source_signature : input.heap.get signature = some (.obj signatureObject) := by host_kernel_rfl
theorem source_types : signatureObject.kind = .array [.str chars!"u64"] := by host_kernel_rfl
theorem source_node : input.ffi.mlx.node? 29363 = some node := by host_kernel_rfl
theorem source_rank : len node.shape = 3 := by host_kernel_rfl
theorem source_post : finishBig input input.ffi chars!"mlx_array_ndim" [.big (Int.ofNat 29363)]
    (Int.ofNat 3) = output := by host_kernel_rfl

theorem transport (NR : NumV → NumV → Prop) (FR : Ren → LSt → LSt → Prop)
    (R : Ren) (C₀ C : CSrv) (ν : Nat → F64) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s : St LSt)
    (h : StateR NR FR R live framed before after old old' input s)
    (NodeRel : Nat → Host.Mlx.Ffi.Node → Host.Mlx.Ffi.Node → Prop)
    (ObjRel : Nat → Host.Mlx.Ffi.Obj → Host.Mlx.Ffi.Obj → Prop)
    (H N : Nat → Prop) (tail : List NumV)
    (native : Host.Mlx.Ffi.NativeRoles.Live NR R NodeRel ObjRel H N tail input.ffi.mlx s.ffi.mlx)
    (shape : ∀ i n n', NodeRel i n n' → Host.Mlx.Ffi.Parametric.ShapeR NR n.shape n'.shape)
    (signatureFrame : ¬ framed signature) (handleLive : H 29363)
    (handleRole : (Annotated.Value.handle 29363).Holds ν C R (callArgument s.ctl 0)) :
    ∃ result, interpC (step P.F s).run C = some (result,C) ∧
      StateR NR FR R live framed before after old old' output result ∧
      result.ctl = .ret (.big (Int.ofNat 3)) := by
  obtain ⟨_,hr,hs⟩ := step_ndim_from_source NR FR R C₀ C ν live framed before after old old' input s h
    NodeRel ObjRel H N tail native shape 4635 signature 29363 functionObject signatureObject returns (.obj 4817) node
    source_control source_heap source_kind source_signature source_types signatureFrame handleLive source_node handleRole
  rw [source_rank,source_post] at hs
  rw [source_rank] at hr
  exact ⟨_,hr,hs,rfl⟩
end Host.Load.Run.Full.Ordinary.RankOrigin
