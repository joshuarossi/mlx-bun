import host.ts.renameOrdinary.RankPrefix
import host.ts.renameOrdinary.TypedBufferCase
import host.ts.renameOrdinary.ShapeSpreadCase
import host.ts.renameOrdinary.DriverReturns
import host.ts.renameOrdinary.DriverBinding
import host.ts.renameOrdinary.DriverPreparation

set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
namespace Host.Load.Run.Full.Ordinary.Prefix
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric

/-- The fixed native graph/resource annotation is part of the initial host
invariant and is preserved by the actual JS-only preparation steps. -/
def NativeFrame (FR : Ren → LSt → LSt → Prop) (ν₀ ν : Nat → F64) (C₀ C : CSrv)
    (roles : Nat → Host.Mlx.Ffi.Annotated.GraphNode)
    (ObjRel : Ren → Nat → Host.Mlx.Ffi.Obj → Host.Mlx.Ffi.Obj → Prop)
    (boundary H N : Nat → Prop) (tail : List NumV) : Ren → LSt → LSt → Prop :=
  fun R a b => FR R a b ∧ Host.Mlx.Ffi.NativeRoles.Live (NumberRoles ν₀ ν C₀ C) R
    (Host.Mlx.Ffi.Annotated.NodeRel roles ν₀ ν C₀ C R boundary) (ObjRel R) H N tail a.mlx b.mlx

noncomputable def input : St LSt := P.RestStream.micro0.micro0.s0
noncomputable def output : St LSt := P.RestStream.micro0.micro0.s39

theorem next12 : P.RestStream.micro0.micro0.s12.next = input.next + 1 := by host_kernel_rfl
theorem next13 : P.RestStream.micro0.micro0.s13.next = input.next + 2 := by host_kernel_rfl
theorem next18 : P.RestStream.micro0.micro0.s18.next = input.next + 3 := by host_kernel_rfl
theorem next25 : P.RestStream.micro0.micro0.s25.next = input.next + 3 := by host_kernel_rfl

theorem counter_add {S : Type} {NR : NumV → NumV → Prop} {FR : Ren → S → S → Prop}
    {R : Ren} {live live' framed : Nat → Prop} {before after : List Val} {old old' : List Event}
    {a₀ a b₀ b : St S} (h : StateR NR FR R live framed before after old old' a₀ a)
    (hb : StateR NR FR R live' framed before after old old' b₀ b)
    (n : Nat) (hn : b₀.next = a₀.next+n) : b.next = a.next+n := by
  have ha := h.heap.fresh n
  have ht := hb.heap.fresh 0
  simp only [Nat.add_zero,hn] at ht
  exact ht.symm.trans ha

theorem nativeDataArgument_heap_eq {S : Type} (s t : St S) (a i : Nat)
    (he : s.heap.get a = t.heap.get a) : nativeDataArgument s a i = nativeDataArgument t a i := by
  simp only [nativeDataArgument,St.obj?,he]

/-- All thirty-nine original interpreter steps reach the first real concatAxis
call. Rank and immutable constructor roles are supplied at entry and transported
through execution; no future-cut numeric/native/read/run premise is used. -/
theorem transport
    (FR : Ren → LSt → LSt → Prop) (R : Ren) (ν₀ ν : Nat → F64) (C₀ C : CSrv)
    (roles : Nat → Host.Mlx.Ffi.Annotated.GraphNode)
    (ObjRel : Ren → Nat → Host.Mlx.Ffi.Obj → Host.Mlx.Ffi.Obj → Prop)
    (boundary H N : Nat → Prop) (tail : List NumV)
    (live framed : Nat → Prop) (before after : List Val) (old old' : List Event) (s : St LSt)
    (h : StateR (NumberRoles ν₀ ν C₀ C) (NativeFrame FR ν₀ ν C₀ C roles ObjRel boundary H N tail)
      R live framed before after old old' input s)
    (rank : s.heap.get (R.a Variable5.address) = some (.cell (some (natV 3))))
    (code : (Annotated.Value.literal (.lit (F64.ofNat 4))).Holds ν C R (nativeDataArgument s (R.a 90) 0))
    (proto : (Annotated.Value.literal (.lit (F64.ofNat 21))).Holds ν C R (nativeDataArgument s (R.a 90) 1))
    (bufferProtoLive : live aArrayBufferProto) (bufferProtoFixed : R.a aArrayBufferProto = aArrayBufferProto)
    (typedProtoLive : live 21) (typedProtoFixed : R.a 21 = 21)
    (arrayProtoLive : live aArrayProto) (arrayProtoFixed : R.a aArrayProto = aArrayProto)
    (nativeHandle : H 29363) (region : R.region 117452 = 4*R.handle 29363)
    (bound : s.next + 4 ≤ 2^64) :
    ∃ result, runC P.F 39 s C = some (result,C) ∧
      StateR (NumberRoles ν₀ ν C₀ C) (NativeFrame FR ν₀ ν C₀ C roles ObjRel boundary H N tail) R
        (LiveAfter (LiveAfter (LiveAfter (LiveAfter live NativeBuffer.input.next)
          TypedBuffer.input.next) ShapeSpread.input.next) P.RestStream.micro0.micro0.s35.next)
        framed before after old old' output result := by
  let nr := NumberRoles ν₀ ν C₀ C
  let fr := NativeFrame FR ν₀ ν C₀ C roles ObjRel boundary H N tail
  let live1 := LiveAfter live NativeBuffer.input.next
  let live2 := LiveAfter live1 TypedBuffer.input.next
  let live3 := LiveAfter live2 ShapeSpread.input.next
  obtain ⟨s12,hr12,h12,frame12⟩ := first_twelve_rank_frame_transport fr R ν₀ ν C₀ C live framed
    before after old old' s h rank bufferProtoLive bufferProtoFixed (by omega)
  have hnext12 : s12.next = s.next + 1 := counter_add h h12 1 next12
  have h90 : live 90 := by
    have hl := h12.controlLive
    change treeSupport live1 (Encode.ctl TypedBuffer.input.ctl) at hl
    rw [TypedBuffer.source_control] at hl
    have hc : live1 90 := hl.1
    rcases hc with hc|hc
    · exact hc
    · have hn : 90 ≠ NativeBuffer.input.next := by decide +kernel
      exact False.elim (hn hc)
  have he90 := frame12 (R.a 90) (h.heap.targetBound 90 h90)
  have code12 : (Annotated.Value.literal (.lit (F64.ofNat 4))).Holds ν C R
      (nativeDataArgument s12 (R.a 90) 0) :=
    (nativeDataArgument_heap_eq s12 s (R.a 90) 0 he90).symm ▸ code
  have proto12 : (Annotated.Value.literal (.lit (F64.ofNat 21))).Holds ν C R
      (nativeDataArgument s12 (R.a 90) 1) :=
    (nativeDataArgument_heap_eq s12 s (R.a 90) 1 he90).symm ▸ proto
  obtain ⟨s13,hr13,h13⟩ := TypedBuffer.transport nr fr R C₀ C ν live1 framed before after old old'
    s12 h12 code12 proto12 (Or.inl typedProtoLive) typedProtoFixed (by omega)
  have hnext13 : s13.next = s.next + 2 := counter_add h h13 2 next13
  obtain ⟨s14,hr14,h14⟩ := ShapeSpread.transport fr R ν₀ ν C₀ C live2 framed before after old old'
    s13 h13 roles (ObjRel R) boundary H N tail h13.native.2 nativeHandle region
    (Or.inl (Or.inl arrayProtoLive)) arrayProtoFixed (by omega)
  obtain ⟨s18,hr18,h18⟩ := shape_return_transport nr fr R C₀ C live3 framed before after old old' s14 h14
  have hnext18 : s18.next = s.next + 3 := counter_add h h18 3 next18
  have notFramed : ¬ framed Binding19.sourceAddress := by
    intro hf
    have hb := h.heap.sourceBound _ (h.heap.prefixLive _ hf)
    have hn : input.next ≤ Binding19.sourceAddress := by decide +kernel
    omega
  obtain ⟨s25,hr25,h25⟩ := shape_binding_transport nr fr R C₀ C live3 framed before after old old'
    s18 h18 notFramed (by omega)
  have hnext25 : s25.next = s.next + 3 := counter_add h h25 3 next25
  obtain ⟨result,hr39,h39⟩ := concat_preparation_transport fr R ν₀ ν C₀ C live3 framed before after old old'
    s25 h25 (Or.inl (Or.inl (Or.inl arrayProtoLive))) arrayProtoFixed (by omega)
  have hh12 : isHalt s12.ctl = false := h12.control.isHalt_eq.trans (by host_kernel_rfl)
  have hh13 : isHalt s13.ctl = false := h13.control.isHalt_eq.trans (by host_kernel_rfl)
  have one13 : runC P.F 1 s12 C = some (s13,C) := runC_cons P.F 0 s12 s13 s13 C C C hh12 hr13 rfl
  have one14 : runC P.F 1 s13 C = some (s14,C) := runC_cons P.F 0 s13 s14 s14 C C C hh13 hr14 rfl
  exact ⟨result,runC_join P.F (runC_join P.F (runC_join P.F
    (runC_join P.F (runC_join P.F hr12 one13) one14) hr18) hr25) hr39,h39⟩
end Host.Load.Run.Full.Ordinary.Prefix
