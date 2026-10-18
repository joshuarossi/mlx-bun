import host.ts.renameOrdinary.RankOriginPreparation
import host.ts.renameOrdinary.RankOriginGetterEntry
import host.ts.renameOrdinary.RankOriginShape
import host.ts.renameOrdinary.RankOriginPointer
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
namespace Host.Load.Run.Full.Ordinary.RankOrigin
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric

/-- All forty actual source steps from the rank guard to typed-buffer argument
preparation. The original receiver's owned private handle and rank cell are
preserved; native shape dispatch is derived at its real call occurrence. -/
theorem shape_path_transport (NR : NumV → NumV → Prop) (FR : Ren → LSt → LSt → Prop)
    (R : Ren) (ν : Nat → F64) (C₀ C : CSrv) (live framed : Nat → Prop) (before after : List Val)
    (old old' : List Event) (s : St LSt)
    (h : StateR NR FR R live framed before after old old' P.micro3275.s19 s)
    (rank : s.heap.get (R.a Variable5.address) = some (.cell (some (natV 3))))
    (rankLive : live Variable5.address) (receiverLive : live Handle40.sourceAddress)
    (field : PrivateData s (R.a Handle40.sourceAddress) (R.a Handle40.sourceBrand)
      Handle40.sourceName (.big (Int.ofNat (R.handle 29363))))
    (NodeRel : Nat → Host.Mlx.Ffi.Node → Host.Mlx.Ffi.Node → Prop)
    (ObjRel : Nat → Host.Mlx.Ffi.Obj → Host.Mlx.Ffi.Obj → Prop)
    (H N : Nat → Prop) (tail : List NumV)
    (native : Host.Mlx.Ffi.NativeRoles.Live NR R NodeRel ObjRel H N tail P.micro3275.s19.ffi.mlx s.ffi.mlx)
    (signatureFrame : ¬ framed ShapeNative.signature) (handleLive : H 29363)
    (region : R.region (4*29363) = 4*R.handle 29363)
    (bound : s.next + 2 + (paramNames EnterGetter28.sourceFunction).length ≤ 2^64)
    (globalLive : live aGlobal) (globalFixed : R.a aGlobal = aGlobal) :
    ∃ result, runC P.F 40 s C = some (result,C) ∧
      StateR NR FR R (GetterLive live) framed before after old old' P.micro3275.s59 result ∧
      result.heap.get (R.a Variable5.address) = some (.cell (some (natV 3))) ∧
      PrivateData result (R.a Handle40.sourceAddress) (R.a Handle40.sourceBrand)
        Handle40.sourceName (.big (Int.ofNat (R.handle 29363))) ∧
      (∀ a, a < s.next → a ≠ R.a PointerBinding48.sourceAddress → result.heap.get a = s.heap.get a) := by
  let GR : Ren → LSt → LSt → Prop := fun Q x y => FR Q x y ∧
    Host.Mlx.Ffi.NativeRoles.Live NR Q NodeRel ObjRel H N tail x.mlx y.mlx
  have hg : StateR NR GR R live framed before after old old' P.micro3275.s19 s :=
    ⟨h.heap,h.control,h.controlLive,h.stack,h.stackLive,h.jobs,h.jobsLive,h.stores,h.storesLive,⟨h.native,native⟩,h.trace⟩
  obtain ⟨s28,hr28,h28,heap28⟩ := shape_getter_preparation NR GR R C₀ C live framed before after old old' s hg
  have hn28 : s28.next = s.next := hg.target_next_eq h28 (by host_kernel_rfl)
  have hb28 : s28.next + 2 + (paramNames EnterGetter28.sourceFunction).length ≤ 2^64 := hn28 ▸ bound
  obtain ⟨s30,hr30,h30,frame30⟩ := getter_entry_transport NR GR R C₀ C live framed before after old old' s28 h28 hb28
  have rank30 : s30.heap.get (R.a Variable5.address) = some (.cell (some (natV 3))) := by
    rw [frame30 _ (h28.heap.targetBound _ rankLive),heap28]
    exact rank
  have field30 := (field.heap_eq heap28).heap_at (frame30 _ (h28.heap.targetBound _ receiverLive))
  obtain ⟨s46,hr46,h46,slot46,heap46⟩ := shape_handle_transport NR GR R C₀ C (GetterLive live) framed before after old old' s30 h30 field30
  have role46 : (Annotated.Value.handle 29363).Holds ν C R (callArgument s46.ctl 0) :=
    slot46.symm ▸ Annotated.Value.Holds.handle 29363
  obtain ⟨s47,hr47,h47,_,heap47⟩ := ShapeNative.transport NR GR R C₀ C ν (GetterLive live) framed before after old old' s46 h46
    NodeRel ObjRel H N tail h46.native.2 signatureFrame handleLive region role46
  have hn47 : s47.next = s.next+2 := hg.target_next_add h47 2 (by host_kernel_rfl)
  have hb47 : s47.next ≤ 2^64 := by rw [hn47]; omega
  have grow : ∀ a, live a → GetterLive live a := ClosureLive.grow live EnterGetter28.input.next
    EnterGetter28.sourceArrow EnterGetter28.sourceHome EnterGetter28.sourceFunction
  obtain ⟨result,hr59,h59,frame59⟩ := shape_pointer_preparation NR GR R C₀ C (GetterLive live) framed before after old old' s47 h47
    hb47 (grow _ globalLive) globalFixed
  have hl := h47.stackLive
  change listSupport (fun f => treeSupport (GetterLive live) (Encode.frame f)) PointerDeclaration47.input.stack at hl
  rw [PointerDeclaration47.source_frame] at hl
  have pointerLookup : lookupEnv PointerBinding48.sourceName PointerDeclaration47.sourceEnv = some PointerBinding48.sourceAddress := by host_kernel_rfl
  have pointerLive := env_lookup_live PointerBinding48.sourceName PointerDeclaration47.sourceEnv PointerBinding48.sourceAddress
    hl.1.1.2.2.2.1 pointerLookup
  have distinctRank : R.a Variable5.address ≠ R.a PointerBinding48.sourceAddress := by
    intro he
    have hn := h47.heap.inj _ _ (grow _ rankLive) pointerLive he
    have hn' : Variable5.address ≠ PointerBinding48.sourceAddress := by decide +kernel
    exact hn' hn
  have distinctReceiver : R.a Handle40.sourceAddress ≠ R.a PointerBinding48.sourceAddress := by
    intro he
    have hn := h47.heap.inj _ _ (grow _ receiverLive) pointerLive he
    have hn' : Handle40.sourceAddress ≠ PointerBinding48.sourceAddress := by decide +kernel
    exact hn' hn
  have rank59 : result.heap.get (R.a Variable5.address) = some (.cell (some (natV 3))) := by
    rw [frame59 _ distinctRank,heap47,heap46]
    exact rank30
  have field47 := field30.heap_eq (heap47.trans heap46)
  have field59 := field47.heap_at (frame59 _ distinctReceiver)
  have oldFields : ∀ a, a < s.next → a ≠ R.a PointerBinding48.sourceAddress → result.heap.get a = s.heap.get a := by
    intro a ha hn
    have ha28 : a < s28.next := hn28.symm ▸ ha
    rw [frame59 _ hn,heap47,heap46,frame30 _ ha28,heap28]
  have final := h59.native_map (fun _ _ _ p => p.1)
  refine ⟨result,?_,final,rank59,field59,oldFields⟩
  have one : runC P.F 1 s46 C = some (s47,C) := by
    apply runC_cons P.F 0 s46 s47 s47 C C C (h46.control.isHalt_eq.trans (by host_kernel_rfl)) hr47
    rfl
  have first11 : runC P.F 11 s C = some (s30,C) := runC_join P.F (m:=9) (n:=2) hr28 hr30
  have first27 : runC P.F 27 s C = some (s46,C) := runC_join P.F (m:=11) (n:=16) first11 hr46
  have first28 : runC P.F 28 s C = some (s47,C) := runC_join P.F (m:=27) (n:=1) first27 one
  exact runC_join P.F (m:=28) (n:=12) first28 hr59
end Host.Load.Run.Full.Ordinary.RankOrigin
