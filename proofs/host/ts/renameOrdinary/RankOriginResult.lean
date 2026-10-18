import host.ts.renameOrdinary.RankOriginPath
import host.ts.renameOrdinary.RankOriginOwnership
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
namespace Host.Load.Run.Full.Ordinary.RankOrigin
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric

theorem prefix_entry : P.micro3275.s59 = Prefix.input := by host_kernel_rfl

/-- The actual native rank call initializes the rank cell, takes the nonzero
branch, calls the real handle getter and shape symbol, and reaches the existing
ordinary-body entry. Only initial ownership/intrinsic/native invariants occur
as premises; rank, guards and native call arguments are derived by execution. -/
theorem initialize_shape_entry (FR : Ren → LSt → LSt → Prop) (R : Ren) (ν₀ ν : Nat → F64)
    (C₀ C : CSrv) (live framed : Nat → Prop) (before after : List Val) (old old' : List Event)
    (s : St LSt) (h : StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' input s)
    (NodeRel : Nat → Host.Mlx.Ffi.Node → Host.Mlx.Ffi.Node → Prop)
    (ObjRel : Nat → Host.Mlx.Ffi.Obj → Host.Mlx.Ffi.Obj → Prop)
    (H N : Nat → Prop) (tail : List NumV)
    (native : Host.Mlx.Ffi.NativeRoles.Live (NumberRoles ν₀ ν C₀ C) R NodeRel ObjRel H N tail input.ffi.mlx s.ffi.mlx)
    (shape : ∀ i n n', NodeRel i n n' → Host.Mlx.Ffi.Parametric.ShapeR (NumberRoles ν₀ ν C₀ C) n.shape n'.shape)
    (rankSignature : ¬ framed signature) (shapeSignature : ¬ framed ShapeNative.signature) (handleLive : H 29363)
    (handleRole : (Annotated.Value.handle 29363).Holds ν C R (callArgument s.ctl 0))
    (field : PrivateData s (R.a Handle40.sourceAddress) (R.a Handle40.sourceBrand)
      Handle40.sourceName (.big (Int.ofNat (R.handle 29363))))
    (region : R.region (4*29363) = 4*R.handle 29363)
    (bound : s.next + 2 + (paramNames EnterGetter28.sourceFunction).length ≤ 2^64)
    (globalLive : live aGlobal) (globalFixed : R.a aGlobal = aGlobal) :
    ∃ result, runC P.F 58 s C = some (result,C) ∧
      StateR (NumberRoles ν₀ ν C₀ C) FR R (GetterLive live) framed before after old old' Prefix.input result ∧
      result.heap.get (R.a Variable5.address) = some (.cell (some (natV 3))) ∧
      PrivateData result (R.a Handle40.sourceAddress) (R.a Handle40.sourceBrand)
        Handle40.sourceName (.big (Int.ofNat (R.handle 29363))) ∧
      (∀ a, a < s.next → a ≠ R.a Variable5.address → a ≠ R.a PointerBinding48.sourceAddress →
        result.heap.get a = s.heap.get a) := by
  let NR := NumberRoles ν₀ ν C₀ C
  let GR : Ren → LSt → LSt → Prop := fun Q x y => FR Q x y ∧
    Host.Mlx.Ffi.NativeRoles.Live NR Q NodeRel ObjRel H N tail x.mlx y.mlx
  have hg : StateR NR GR R live framed before after old old' input s :=
    ⟨h.heap,h.control,h.controlLive,h.stack,h.stackLive,h.jobs,h.jobsLive,h.stores,h.storesLive,⟨h.native,native⟩,h.trace⟩
  obtain ⟨rankLive,receiverLive⟩ := initial_owned_addresses NR FR R live framed before after old old' s h
  have distinct : R.a Handle40.sourceAddress ≠ R.a Variable5.address := by
    intro he
    exact receiver_not_rank (h.heap.inj _ _ receiverLive rankLive he)
  have hb : s.next ≤ 2^64 := by omega
  obtain ⟨s10,hr10,h10,rank10,frame10⟩ := initialize_rank_framed GR R ν₀ ν C₀ C live framed before after old old' s hg
    NodeRel ObjRel H N tail native shape rankSignature handleLive handleRole hb
  have field10 := field.heap_at (frame10 _ distinct)
  obtain ⟨s19,hr19,h19,heap19⟩ := rank_guard_transport GR R ν₀ ν C₀ C live framed before after old old' s10 h10 rank10
  have rank19 : s19.heap.get (R.a Variable5.address) = some (.cell (some (natV 3))) := heap19 ▸ rank10
  have field19 := field10.heap_eq heap19
  have hn19 : s19.next = s.next := hg.target_next_eq h19 (by host_kernel_rfl)
  have hb19 : s19.next + 2 + (paramNames EnterGetter28.sourceFunction).length ≤ 2^64 := hn19 ▸ bound
  obtain ⟨result,hr59,h59,rank59,field59,frame59⟩ := shape_path_transport NR GR R ν C₀ C live framed before after old old'
    s19 h19 rank19 rankLive receiverLive field19 NodeRel ObjRel H N tail h19.native.2 shapeSignature handleLive region
    hb19 globalLive globalFixed
  have final := h59.native_map (fun _ _ _ p => p.1)
  have final' : StateR NR FR R (GetterLive live) framed before after old old' Prefix.input result := prefix_entry ▸ final
  refine ⟨result,?_,final',rank59,field59,?_⟩
  · have first18 : runC P.F 18 s C = some (s19,C) := runC_join P.F (m:=9) (n:=9) hr10 hr19
    exact runC_join P.F (m:=18) (n:=40) first18 hr59
  · intro a ha notRank notPointer
    have ha19 : a < s19.next := hn19.symm ▸ ha
    rw [frame59 _ ha19 notPointer,heap19,frame10 _ notRank]
end Host.Load.Run.Full.Ordinary.RankOrigin
