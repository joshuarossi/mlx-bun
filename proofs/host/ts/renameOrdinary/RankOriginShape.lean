import host.ts.renameOrdinary.RankOriginHandle
import host.ts.RenameParametricRankNative
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
namespace Host.Load.Run.Full.Ordinary.RankOrigin.ShapeNative
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric
noncomputable def input : St LSt := P.micro3275.s46
noncomputable def output : St LSt := P.micro3275.s47
noncomputable def functionObject : Obj := match input.heap.get 4636 with
  | some (.obj o) => o | _ => ⟨.ordinary,.null,[],[],true⟩
noncomputable def signature : Nat := match functionObject.kind with
  | .fn (.native (.ffi .symbol) [_,.obj a,_]) => a | _ => 0
noncomputable def returns : Name := match functionObject.kind with
  | .fn (.native (.ffi .symbol) [_,_,.str rt]) => rt | _ => []
noncomputable def signatureObject : Obj := match input.heap.get signature with
  | some (.obj o) => o | _ => ⟨.ordinary,.null,[],[],true⟩
noncomputable def node : Host.Mlx.Ffi.Node := match input.ffi.mlx.node? 29363 with
  | some n => n | _ => ⟨.zeros,[],[],0⟩
theorem source_control : input.ctl = .call (.obj 4636) (.obj 4817) [.big (Int.ofNat 29363)] := by host_kernel_rfl
theorem source_heap : input.heap.get 4636 = some (.obj functionObject) := by host_kernel_rfl
theorem source_kind : functionObject.kind = .fn (.native (.ffi .symbol)
    [.str chars!"mlx_array_shape",.obj signature,.str returns]) := by host_kernel_rfl
theorem source_signature : input.heap.get signature = some (.obj signatureObject) := by host_kernel_rfl
theorem source_types : signatureObject.kind = .array [.str chars!"u64"] := by host_kernel_rfl
theorem source_node : input.ffi.mlx.node? 29363 = some node := by host_kernel_rfl
theorem source_post : finishPointer input input.ffi chars!"mlx_array_shape" [.big (Int.ofNat 29363)]
    (4*29363) 0 = output := by host_kernel_rfl

theorem transport (NR : NumV → NumV → Prop) (FR : Ren → LSt → LSt → Prop)
    (R : Ren) (C₀ C : CSrv) (ν : Nat → F64) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s : St LSt)
    (h : StateR NR FR R live framed before after old old' input s)
    (NodeRel : Nat → Host.Mlx.Ffi.Node → Host.Mlx.Ffi.Node → Prop)
    (ObjRel : Nat → Host.Mlx.Ffi.Obj → Host.Mlx.Ffi.Obj → Prop)
    (H N : Nat → Prop) (tail : List NumV)
    (native : Host.Mlx.Ffi.NativeRoles.Live NR R NodeRel ObjRel H N tail input.ffi.mlx s.ffi.mlx)
    (signatureFrame : ¬ framed signature) (handleLive : H 29363)
    (region : R.region (4*29363) = 4*R.handle 29363)
    (handleRole : (Annotated.Value.handle 29363).Holds ν C R (callArgument s.ctl 0)) :
    ∃ result, interpC (step P.F s).run C = some (result,C) ∧
      StateR NR FR R live framed before after old old' output result ∧
      result.ctl = .ret (.ptr (.ext (R.region (4*29363))) 0) ∧ result.heap = s.heap := by
  obtain ⟨_,hr,hs⟩ := step_shape_from_source NR FR R C₀ C ν live framed before after old old' input s h
    NodeRel ObjRel H N tail native 4636 signature 29363 functionObject signatureObject returns (.obj 4817) node
    source_control source_heap source_kind source_signature source_types signatureFrame handleLive source_node region handleRole
  have hs' : StateR NR FR R live framed before after old old' output
      (finishPointer s s.ffi chars!"mlx_array_shape" [.big (Int.ofNat (R.handle 29363))] (R.region (4*29363)) 0) := source_post ▸ hs
  exact ⟨_,hr,hs',rfl,rfl⟩
end Host.Load.Run.Full.Ordinary.RankOrigin.ShapeNative
