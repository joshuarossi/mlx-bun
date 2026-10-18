import host.mlx.OrdinaryVectorCut
import host.ts.RenameParametricPropWrites

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

namespace Host.Load.Run.Full.Ordinary.VectorHost
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric
open Host.Mlx.Ffi Host.Mlx.Ffi.NativeRoles Host.Mlx.Ffi.Annotated

abbrev F : Ffi := ⟨LSt,Host.Load.call,Host.Load.read,fun _ => 4096,Host.Load.back⟩

noncomputable def sourceArgs : List Arg := [.jsPtr 3126688 0 VectorCall.actualBytes,.big (Int.ofNat 2)]
noncomputable def sourceNative : LSt := {VectorCall.input.ffi with mlx := (VectorCall.native.newObj (.vec [20208,22582])).2}
noncomputable def sourcePost : Host.Ts.St LSt :=
  finishBig VectorCall.input sourceNative chars!"mlx_vector_array_new_data" sourceArgs (Int.ofNat 29371)

theorem source_post : sourcePost = VectorCall.output := by host_kernel_rfl

theorem load_vector_call (s : LSt) (args : List Arg) (native : Host.Mlx.Ffi.St) (handle : Nat)
    (hc : Host.Mlx.Ffi.call s.mlx chars!"mlx_vector_array_new_data" args = ok native (.big (Int.ofNat handle))) :
    Host.Load.call s chars!"mlx_vector_array_new_data" args =
      M.pure (some ({s with mlx := native},.big (Int.ofNat handle),[])) := by
  have hm : isMlx chars!"mlx_vector_array_new_data" = true := by decide +kernel
  funext β k
  simp only [Host.Load.call,hm,Bool.cond_true,hc,ok,M.bind,M.pure]

theorem source_native_call : Host.Mlx.Ffi.call VectorCall.native chars!"mlx_vector_array_new_data" sourceArgs =
    ok (VectorCall.native.newObj (.vec [20208,22582])).2 (.big (Int.ofNat 29371)) := by
  have hs := call_vector_data VectorCall.native
    (.jsPtr 3126688 0 (VectorBuffer.bytes [25732,29363])) (.big (Int.ofNat 2)) [25732,29363] [20208,22582]
    (VectorBuffer.handles 3126688 0 [25732,29363]) VectorCall.source_inputs
  simpa only [sourceArgs,VectorCall.source_bytes,VectorCall.source_counter] using hs

theorem source_step : step F VectorCall.input = M.pure VectorCall.output := by
  have hb : bufBytes F VectorCall.input 3126688 = some VectorCall.actualBytes :=
    bufBytes_of_obj _ _ _ _ _ (by simp only [Host.Ts.St.obj?,VectorCall.source_buffer]) VectorCall.source_buffer_kind
  have hk := VectorCall.source_callee_kind
  rw [VectorCall.source_caps] at hk
  have hc : F.call VectorCall.input.ffi chars!"mlx_vector_array_new_data"
      [.jsPtr 3126688 0 (VectorCall.actualBytes.drop 0),.big (Int.ofNat 2)] =
      M.pure (some (sourceNative,.big (Int.ofNat 29371),[])) := by
    simpa only [List.drop_zero,sourceArgs,F,sourceNative] using
      load_vector_call VectorCall.input.ffi sourceArgs _ 29371 source_native_call
  rw [step_ffi_ptr_u64 F VectorCall.input 4709 4411 3126688 0 (Int.ofNat 2)
    chars!"mlx_vector_array_new_data" chars!"u64" VectorCall.calleeObject VectorCall.signatureObject
    VectorCall.actualBytes sourceNative (.big (Int.ofNat 29371)) [] VectorCall.source_control
    (by simp only [Host.Ts.St.obj?,VectorCall.source_callee]) hk
    (by simp only [Host.Ts.St.obj?,VectorCall.source_signature]) VectorCall.source_signature_kind hb hc,
    ffiDone_big_empty]
  change M.pure sourcePost = _
  rw [source_post]

def NativeRelation (ν₀ ν : Nat → F64) (C₀ C : CSrv) (nodes : Nat → GraphNode) (boundary : Nat → Prop)
    (objects : Nat → Object) (H N : Nat → Prop) (tail : List NumV)
    (host : HostSt → HostSt → Prop) (R : Ren) (s₀ s : LSt) : Prop :=
  host s₀.host s.host ∧ Live (NumberRoles ν₀ ν C₀ C) R (NodeRel nodes ν₀ ν C₀ C R boundary)
    (ObjectRel objects ν₀ ν C₀ C R) H N tail s₀.mlx s.mlx

theorem source_buffer_role (ν : Nat → F64) (C : CSrv) :
    (VectorBuffer.role [25732,29363]).Holds ν C Host.Ts.Owned.Annotated.identity
      (objectKindAt VectorCall.input 3126688) := by
  simp only [objectKindAt,Host.Ts.St.obj?,VectorCall.source_buffer,
    VectorCall.source_buffer_kind,VectorCall.source_bytes]
  have hi : [25732,29363].map Host.Ts.Owned.Annotated.identity.handle = [25732,29363] := by rfl
  simpa only [hi] using
    VectorBuffer.annotated ν C Host.Ts.Owned.Annotated.identity [25732,29363]

/-- The first real vector construction in the ordinary body, including its
fresh owned native handle, fixed vector payload, original host wrapper and
u64 return. Target lookups and the native call are derived from the source. -/
theorem transport (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (nodes : Nat → GraphNode) (boundary : Nat → Prop) (objects : Nat → Object)
    (H N : Nat → Prop) (tail : List NumV) (host : HostSt → HostSt → Prop)
    (live framed : Nat → Prop) (before after : List Val) (old old' : List Event) (s : Host.Ts.St LSt)
    (h : StateR (NumberRoles ν₀ ν C₀ C) (NativeRelation ν₀ ν C₀ C nodes boundary objects H N tail host)
      R live framed before after old old' VectorCall.input s)
    (countRole : (Host.Ts.Owned.Annotated.Value.ordinaryBig (Int.ofNat 2)).Holds ν C R (callArgument s.ctl 1))
    (bufferRole : (VectorBuffer.role [25732,29363]).Holds ν C R (objectKindAt s (R.a 3126688)))
    (signatureFrame : ¬ framed 4411) (firstLive : H 25732) (secondLive : H 29363)
    (bound : s.ffi.mlx.next < 2^64) :
    ∃ t, interpC (step F VectorCall.input).run C₀ = some (VectorCall.output,C₀) ∧
      interpC (step F s).run C = some (t,C) ∧
      StateR (NumberRoles ν₀ ν C₀ C)
        (NativeRelation ν₀ ν C₀ C nodes boundary (objectWrite objects 29371 (.vec [20208,22582]))
          (fun a => a = 29371 ∨ H a) N tail host)
        R live framed before after old old' VectorCall.output t ∧
      t.ctl = .ret (.big (Int.ofNat (R.handle 29371))) := by
  have hk := VectorCall.source_callee_kind
  rw [VectorCall.source_caps] at hk
  have calleeLive : live 4709 := by
    have hl := h.controlLive
    rw [VectorCall.source_control] at hl
    exact hl.1
  obtain ⟨_,_,_,hol⟩ := h.heap.readObject 4709 VectorCall.calleeObject calleeLive
    (h.heap.function_notFramed 4709 VectorCall.calleeObject _ calleeLive VectorCall.source_callee hk)
    VectorCall.source_callee
  have signatureLive : live 4411 := by
    have hl := hol.1
    rw [hk] at hl
    exact hl.1.2.1.2.1
  obtain ⟨fo,data,this,args,hc,hfo,hfk,hd,_,ha⟩ := h.native_call_view 4709 VectorCall.calleeObject
    (.ffi .symbol) _ (.obj 4817) _ VectorCall.source_control VectorCall.source_callee hk
  cases hd with | cons hn hd =>
    cases hd with | cons ht hd =>
      cases hd with | cons hr hd =>
        cases hd
        cases hn; cases ht; cases hr
        cases ha with | cons hp ha =>
          cases ha with | cons hn ha =>
            cases ha
            cases hp
            have hecount := fixed_ordinary_big_value countRole
            simp only [hc,callArgument,Host.Ts.arg,nthD] at hecount
            rw [hecount] at hc
            obtain ⟨signature,hsig,hsigr,_⟩ := h.heap.readObject 4411 VectorCall.signatureObject signatureLive
              signatureFrame VectorCall.source_signature
            have hsKind := hsigr.kind
            rw [VectorCall.source_signature_kind] at hsKind
            obtain ⟨tys,hsKind,htys⟩ := kind_array hsKind
            cases htys with | cons hp htys =>
              cases htys with | cons hu htys =>
                cases htys
                cases hp; cases hu
                have bufferLive : live 3126688 := by
                  have hl := h.controlLive
                  rw [VectorCall.source_control] at hl
                  exact hl.2.2.1.1
                obtain ⟨bo,hbo,hbr,_⟩ := h.heap.readObject 3126688 VectorCall.bufferObject bufferLive
                  (h.heap.buffer_notFramed 3126688 VectorCall.bufferObject _ bufferLive
                    VectorCall.source_buffer VectorCall.source_buffer_kind) VectorCall.source_buffer
                have hbKind := hbr.kind
                rw [VectorCall.source_buffer_kind] at hbKind
                obtain ⟨bytes,hbKind,hbytes⟩ := kind_buffer hbKind
                have hbRole : (VectorBuffer.role [25732,29363]).Holds ν C R (Encode.kind (.buf bytes)) := by
                  simpa only [objectKindAt,Host.Ts.St.obj?,hbo,hbKind] using bufferRole
                have hebytes := VectorBuffer.exact_bytes hbRole
                subst bytes
                have hn := h.native.2
                change Live _ R _ _ H N tail VectorCall.native s.ffi.mlx at hn
                obtain ⟨_,hncall,hnAfter,_⟩ := hn.vector_data 3126688 0 [25732,29363] [20208,22582]
                  ⟨firstLive,secondLive,True.intro⟩ VectorCall.source_inputs
                  (by rw [VectorCall.source_counter]; decide +kernel) bound
                have nextMapped : s.ffi.mlx.next = R.handle 29371 := by
                  have hh := hn.handleMap.head
                  rw [VectorCall.source_counter] at hh
                  exact hh.symm
                rw [nextMapped] at hncall
                let native' : LSt := {s.ffi with mlx := (s.ffi.mlx.newObj (.vec ([20208,22582].map R.node))).2}
                have nativeRelated : NativeRelation ν₀ ν C₀ C nodes boundary
                    (objectWrite objects 29371 (.vec [20208,22582])) (fun a => a = 29371 ∨ H a) N tail host
                    R sourceNative native' := by
                  refine ⟨h.native.1,?_⟩
                  simpa only [sourceNative,native',VectorCall.source_counter] using hnAfter
                let args' : List Arg := [.jsPtr (R.a 3126688) 0 (VectorBuffer.bytes ([25732,29363].map R.handle)),.big (Int.ofNat 2)]
                let t := finishBig s native' chars!"mlx_vector_array_new_data" args' (Int.ofNat (R.handle 29371))
                have hval : ValueR (NumberRoles ν₀ ν C₀ C) R (.big (Int.ofNat 29371)) (.big (Int.ofNat (R.handle 29371))) :=
                  .handle 29371
                have hevent : TreeR (NumberRoles ν₀ ν C₀ C) R
                    (event ⟨chars!"mlx_vector_array_new_data",sourceArgs,.big (Int.ofNat 29371)⟩)
                    (event ⟨chars!"mlx_vector_array_new_data",args',.big (Int.ofNat (R.handle 29371))⟩) :=
                  .node _ (.cons (.atom _ _) (.cons (.node _ (.cons
                    (.node _ (.cons (.address _) (.cons (.atom _ _) (.cons (bytes_roles hbytes) .nil))))
                    (.cons (.node _ (.cons (.value (.ordinaryBig _)) .nil)) .nil)))
                    (.cons (.node _ (.cons (.value hval) .nil)) .nil)))
                have hpost := h.finishBig sourceNative native' nativeRelated chars!"mlx_vector_array_new_data"
                  sourceArgs args' (Int.ofNat 29371) (Int.ofNat (R.handle 29371)) hevent hval
                have htBuf : bufBytes F s (R.a 3126688) = some (VectorBuffer.bytes ([25732,29363].map R.handle)) :=
                  bufBytes_of_obj _ _ _ _ _ (by simp only [Host.Ts.St.obj?,hbo]) hbKind
                have hcall : F.call s.ffi chars!"mlx_vector_array_new_data"
                    [.jsPtr (R.a 3126688) 0 ((VectorBuffer.bytes ([25732,29363].map R.handle)).drop 0),.big (Int.ofNat 2)] =
                    M.pure (some (native',.big (Int.ofNat (R.handle 29371)),[])) := by
                  simpa only [F,native',List.drop_zero,List.length_cons,List.length_nil] using
                    load_vector_call s.ffi _ _ (R.handle 29371) hncall
                refine ⟨t,?_,?_,?_,rfl⟩
                · rw [source_step]; rfl
                · rw [step_ffi_ptr_u64 F s (R.a 4709) (R.a 4411) (R.a 3126688) 0 (Int.ofNat 2)
                    chars!"mlx_vector_array_new_data" chars!"u64" fo signature _ native'
                    (.big (Int.ofNat (R.handle 29371))) [] hc (by simp only [Host.Ts.St.obj?,hfo]) hfk
                    (by simp only [Host.Ts.St.obj?,hsig]) hsKind htBuf hcall,ffiDone_big_empty]
                  rfl
                · change StateR _ _ _ _ _ _ _ _ _ sourcePost t at hpost
                  rw [source_post] at hpost
                  exact hpost

end Host.Load.Run.Full.Ordinary.VectorHost
