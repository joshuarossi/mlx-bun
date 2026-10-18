import host.load.RuntimeDriverTest
import host.ts.renameOrdinary.RuntimeRetainedTen
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
namespace Host.Load.Run.Full.Ordinary.RetainedShapePrefix
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated
open SourceDriver

def EndLive (live : Nat → Prop) : Nat → Prop :=
  LiveAfter (LiveAfter (LiveAfter live Source10.input.next) Source12.input.next) Source13.input.next
noncomputable def EndNotes (notes : RetainedNotes) (caller : List Annotated.Tree) (dimensions : List Annotated.Value) : RetainedNotes :=
  ⟨⟨returnNote (.obj Source13.input.next),caller,notes.runtime.cells⟩,notes.privates,notes.captures,
    notes.arrays.write Source13.input.next dimensions,notes.publicFields,notes.buffers⟩

/-- Fourteen continuous original source steps consume one initial retained
state. Native geometry and builtin metadata are carried from that entry;
intermediate ABI roles, shape bytes, typed view and array roles are derived. -/
theorem first_fourteen (notes : RetainedNotes) (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (FR : Ren → P.F.S → P.F.S → Prop) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s : St P.F.S)
    (inst : Inst ν₀ (numberServer P.RestStream.micro0.micro0.S0) C₀)
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old'
      P.RestStream.micro0.micro0.s0 s)
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live P.RestStream.micro0.micro0.s0 s)
    (fnRole thisRole pointerRole : Annotated.Value) (spreadNote : Annotated.Tree) (caller : List Annotated.Tree)
    (pointerEntry : notes.runtime.cells.cells RetainedPrefix.Source0.address = some pointerRole)
    (rankEntry : notes.runtime.cells.cells RetainedPrefix.Source5.address = some (.literal (.lit (F64.ofNat 3))))
    (stackNotes : notes.runtime.stack = argumentFrameNote false RetainedPrefix.Source1.sourceKind fnRole thisRole []
      RetainedPrefix.Source1.sourceRest RetainedPrefix.Source1.sourceEnv::
      argumentFrameNote false Source11.sourceKind (.obj 90) .undef [] Source11.sourceRest Source11.sourceEnv::spreadNote::caller)
    (metadata : NativeCaptureNote) (selected : notes.captures.owners 90 = some metadata)
    (codeNote : metadata.roles 0 = some (.literal (.lit (F64.ofNat 4))))
    (protoNote : metadata.roles 1 = some (.literal (.lit (F64.ofNat 21))))
    (roles : Nat → Host.Mlx.Ffi.Annotated.GraphNode)
    (ObjRel : Nat → Host.Mlx.Ffi.Obj → Host.Mlx.Ffi.Obj → Prop)
    (boundary H N : Nat → Prop) (tail : List NumV)
    (native : Host.Mlx.Ffi.NativeRoles.Live (NumberRoles ν₀ ν C₀ C) R
      (Host.Mlx.Ffi.Annotated.NodeRel roles ν₀ ν C₀ C R boundary) ObjRel H N tail
      P.RestStream.micro0.micro0.s0.ffi.mlx s.ffi.mlx)
    (handleLive : H 29363) (region : R.region (4*29363) = 4*R.handle 29363)
    (arrayBufferLive : live aArrayBufferProto) (arrayBufferFixed : R.a aArrayBufferProto = aArrayBufferProto)
    (typedLive : live 21) (typedFixed : R.a 21 = 21)
    (arrayLive : live aArrayProto) (arrayFixed : R.a aArrayProto = aArrayProto)
    (bound : s.next+3 ≤ 2^64) :
    ∃ result, runC P.F 14 s C = some (result,C) ∧
      Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R (EndLive live) framed before after old old'
        P.RestStream.micro0.micro0.s14 result ∧
      RetainedInventory (EndNotes notes caller (roles 22582).shape.valueRoles) ν₀ ν C₀ C R (EndLive live)
        P.RestStream.micro0.micro0.s14 result ∧ Inst ν₀ (numberServer P.RestStream.micro0.micro0.S14) C₀ := by
  let NR := NumberRoles ν₀ ν C₀ C
  let GR : Ren → P.F.S → P.F.S → Prop := fun Q a b => FR Q a b ∧
    Host.Mlx.Ffi.NativeRoles.Live NR Q (Host.Mlx.Ffi.Annotated.NodeRel roles ν₀ ν C₀ C Q boundary)
      ObjRel H N tail a.mlx b.mlx
  have related : Parametric.StateR NR GR R live framed before after old old' P.RestStream.micro0.micro0.s0 s :=
    ⟨h.heap,h.control,h.controlLive,h.stack,h.stackLive,h.jobs,h.jobsLive,h.stores,h.storesLive,⟨h.native,native⟩,h.trace⟩
  let constructorTail := argumentFrameNote false Source11.sourceKind (.obj 90) .undef []
    Source11.sourceRest Source11.sourceEnv::spreadNote::caller
  obtain ⟨s10,r10,h10,i10,q10⟩ := RetainedPrefix.first_ten notes ν₀ ν C₀ C R GR live framed before after old old'
    s inst related inventory fnRole thisRole pointerRole constructorTail pointerEntry rankEntry stackNotes
  have next10 : s10.next = s.next := related.target_next_eq h10 (by host_kernel_rfl)
  obtain ⟨s11,_,r11,h11,i11,q11⟩ := Source10.retained_transport _ ν₀ ν C₀ C R GR live framed before after old old'
    s10 q10 h10 i10 (.lit (F64.ofNat 0)) (.bin .mul (.lit (F64.ofNat 3)) (.lit (F64.ofNat 4)))
    fnRole thisRole pointerRole rfl (by intro; host_kernel_rfl) (by intro; host_kernel_rfl)
    arrayBufferLive arrayBufferFixed (by rw [next10]; omega)
  obtain ⟨s12,_,r12,h12,i12,q12⟩ := Source11.retained_transport _ ν₀ ν C₀ C R GR _ framed before after old old'
    s11 q11 h11 i11 (.obj Source10.input.next) (.obj 90) .undef [] (spreadNote::caller) rfl rfl
  have next12 : s12.next = s.next+1 := by
    have first := related.heap.fresh 1
    have current := h12.heap.fresh 0
    rw [Nat.add_zero] at current
    change R.a P.RestStream.micro0.micro0.s12.next = s12.next at current
    have source : P.RestStream.micro0.micro0.s12.next = P.RestStream.micro0.micro0.s0.next+1 := by host_kernel_rfl
    rw [source] at current
    exact current.symm.trans first
  obtain ⟨s13,_,r13,h13,i13,q13⟩ := Source12.retained_transport _ ν₀ ν C₀ C R GR _ framed before after old old'
    s12 q12 h12 i12 metadata selected codeNote protoNote (Or.inl typedLive) typedFixed
    (by rw [next12]; omega)
  have next13 : s13.next = s.next+2 := by
    have first := related.heap.fresh 2
    have current := h13.heap.fresh 0
    rw [Nat.add_zero] at current
    change R.a P.RestStream.micro0.micro0.s13.next = s13.next at current
    have source : P.RestStream.micro0.micro0.s13.next = P.RestStream.micro0.micro0.s0.next+2 := by host_kernel_rfl
    rw [source] at current
    exact current.symm.trans first
  obtain ⟨result,_,r14,h14,i14,q14⟩ := Source13.retained_transport _ ν₀ ν C₀ C R GR _ framed before after old old'
    s13 q13 h13 i13 roles ObjRel boundary H N tail h13.native.2 handleLive region
    (Or.inl (Or.inl arrayLive)) arrayFixed (by rw [next13]; omega)
  refine ⟨result,?_,h14.native_map (fun _ _ _ held => held.1),i14,q14⟩
  have last : runC P.F 4 s10 C = some (result,C) := by
    apply runC_cons P.F 3 s10 s11 result C C C (h10.control.isHalt_eq.trans (by host_kernel_rfl)) r11
    apply runC_cons P.F 2 s11 s12 result C C C (h11.control.isHalt_eq.trans (by host_kernel_rfl)) r12
    apply runC_cons P.F 1 s12 s13 result C C C (h12.control.isHalt_eq.trans (by host_kernel_rfl)) r13
    apply runC_cons P.F 0 s13 result result C C C (h13.control.isHalt_eq.trans (by host_kernel_rfl)) r14
    rfl
  exact runC_join P.F (m:=10) (n:=4) r10 last

end Host.Load.Run.Full.Ordinary.RetainedShapePrefix
