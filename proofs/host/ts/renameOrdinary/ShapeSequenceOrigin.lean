import host.ts.renameOrdinary.DriverReturns
import host.ts.renameOrdinary.ShapeSequenceBinding
import host.ts.renameOrdinary.ShapeSpreadCase
import host.ts.RenameShapeDimensionFields
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
namespace Host.Load.Run.Full.Ordinary
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric
theorem shape_return_heap_transport (NR : NumV → NumV → Prop) (FR : Ren → P.F.S → P.F.S → Prop)
    (R : Ren) (C₀ C : CSrv) (live framed : Nat → Prop) (before after : List Val)
    (old old' : List Event) (s : St P.F.S)
    (h : StateR NR FR R live framed before after old old' P.RestStream.micro0.micro0.s14 s) :
    ∃ result, runC P.F 4 s C = some (result,C) ∧
      StateR NR FR R live framed before after old old' P.RestStream.micro0.micro0.s18 result ∧ result.heap = s.heap := by
  obtain ⟨s15,hr14,h15⟩ := Return14.transport NR FR R C₀ C live framed before after old old' s h
  obtain ⟨s16,hr15,h16⟩ := Return15.transport NR FR R C₀ C live framed before after old old' s15 h15
  obtain ⟨s17,hr16,h17⟩ := Return16.transport NR FR R C₀ C live framed before after old old' s16 h16
  obtain ⟨result,hr17,h18⟩ := Return17.transport NR FR R C₀ C live framed before after old old' s17 h17
  refine ⟨result,?_,h18,?_⟩
  ·
    apply runC_cons P.F 3 s s15 result C C C (h.control.isHalt_eq.trans return_source_active14) hr14
    apply runC_cons P.F 2 s15 s16 result C C C (h15.control.isHalt_eq.trans return_source_active15) hr15
    apply runC_cons P.F 1 s16 s17 result C C C (h16.control.isHalt_eq.trans return_source_active16) hr16
    apply runC_cons P.F 0 s17 result result C C C (h17.control.isHalt_eq.trans return_source_active17) hr17
    rfl

  ·
    have hh14 := step_return_exit_heap P.F NR FR R live framed before after old old' Return14.input s s15 C C h
      Return14.sourceValue Return14.sourceAction Return14.sourceEnv Return14.sourceTail Return14.source_control Return14.source_frame hr14
    have hh15 := step_return_unwind_heap P.F NR FR R live framed before after old old' Return15.input s15 s16 C C h15
      Return15.sourceValue Return15.sourceAction Return15.sourceEnv Return15.sourceTail Return15.source_control Return15.source_frame hr15
    have hh16 := step_return_unwind_heap P.F NR FR R live framed before after old old' Return16.input s16 s17 C C h16
      Return16.sourceValue Return16.sourceAction Return16.sourceEnv Return16.sourceTail Return16.source_control Return16.source_frame hr16
    have hh17 := step_return_unwind_heap P.F NR FR R live framed before after old old' Return17.input s17 result C C h17
      Return17.sourceValue Return17.sourceAction Return17.sourceEnv Return17.sourceTail Return17.source_control Return17.source_frame hr17
    exact hh17.trans (hh16.trans (hh15.trans hh14))


/-- The actual native shape's fixed second dimension is read through its byte
view, returned as a JS array, and initialized into the real S binding. -/
theorem shape_sequence_origin
    (FR : Ren → LSt → LSt → Prop) (R : Ren) (ν₀ ν : Nat → F64) (C₀ C : CSrv)
    (roles : Nat → Host.Mlx.Ffi.Annotated.GraphNode)
    (ObjRel : Nat → Host.Mlx.Ffi.Obj → Host.Mlx.Ffi.Obj → Prop)
    (boundary H N : Nat → Prop) (tail : List NumV)
    (live framed : Nat → Prop) (before after : List Val) (old old' : List Event) (s : St LSt)
    (h : StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' ShapeSpread.input s)
    (native : Host.Mlx.Ffi.NativeRoles.Live (NumberRoles ν₀ ν C₀ C) R
      (Host.Mlx.Ffi.Annotated.NodeRel roles ν₀ ν C₀ C R boundary) ObjRel H N tail ShapeSpread.input.ffi.mlx s.ffi.mlx)
    (dimension : (roles 22582).shape[1]? = some (.literal (.lit (F64.ofNat 1))))
    (nativeHandle : H 29363) (region : R.region 117452 = 4*R.handle 29363)
    (prototypeLive : live aArrayProto) (prototypeFixed : R.a aArrayProto = aArrayProto)
    (notFramed : ¬ framed Binding19.sourceAddress) (bound : s.next < 2^64) :
    ∃ result, runC P.F 12 s C = some (result,C) ∧
      StateR (NumberRoles ν₀ ν C₀ C) FR R (LiveAfter live ShapeSpread.input.next)
        framed before after old old' P.RestStream.micro0.micro0.s25 result ∧
      result.heap.get (R.a Binding20.sourceAddress) = some (.cell (some (natV 1))) ∧ LiveAfter live ShapeSpread.input.next Binding20.sourceAddress := by
  let nr := NumberRoles ν₀ ν C₀ C
  let live' := LiveAfter live ShapeSpread.input.next
  obtain ⟨s14,hr14,h14,node,relation,arrayHeap⟩ := ShapeSpread.transport_fields FR R ν₀ ν C₀ C live framed
    before after old old' s h roles ObjRel boundary H N tail native nativeHandle region prototypeLive prototypeFixed bound
  obtain ⟨d,hd,hrole⟩ := Host.Ts.Owned.Parametric.ListR.nth_some relation.target.shape 1 (.literal (.lit (F64.ofNat 1))) dimension
  have deq := Host.Mlx.Ffi.Annotated.Dimension.literal_one hrole
  let vs := node.shape.map (fun d : Host.Mlx.Ffi.Dim => Val.num d.num)
  have sequence : vs[1]? = some (natV 1) := by
    simp only [vs,List.getElem?_map,hd,Option.map_some,deq]
    rfl
  obtain ⟨s18,hr18,h18,heap18⟩ := shape_return_heap_transport nr FR R C₀ C live' framed before after old old' s14 h14
  have at18 : s18.heap.get (R.a Binding19.sourceAddress) = some (valueArray vs) := by
    rw [heap18]
    have ha : Binding19.sourceAddress = ShapeSpread.input.next := by host_kernel_rfl
    rw [ha]
    exact arrayHeap
  have next14 : s14.next = s.next+1 := by
    have hf := h.heap.fresh 1
    have ht := h14.heap.fresh 0
    have hn : ShapeSpread.output.next = ShapeSpread.input.next+1 := by host_kernel_rfl
    simp only [Nat.add_zero,hn] at ht
    exact ht.symm.trans hf
  have next18 : s18.next = s14.next := h14.target_next_eq h18 (by host_kernel_rfl)
  obtain ⟨result,hr25,h25,stored,cellLive⟩ := shape_binding_sequence_transport nr FR R C₀ C live' framed before after old old'
    s18 h18 notFramed (by omega) vs sequence at18
  have one : runC P.F 1 s C = some (s14,C) := runC_cons P.F 0 s s14 s14 C C C
    (h.control.isHalt_eq.trans (by host_kernel_rfl)) hr14 rfl
  exact ⟨result,runC_join P.F (m:=5) (n:=7) (runC_join P.F (m:=1) (n:=4) one hr18) hr25,h25,stored,cellLive⟩
end Host.Load.Run.Full.Ordinary
