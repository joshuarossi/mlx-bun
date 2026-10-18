import host.mlx.OrdinaryConcatHost
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
namespace Host.Load.Run.Full.Ordinary.ConcatHost
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric
open Host.Mlx.Ffi Host.Mlx.Ffi.NativeRoles Host.Mlx.Ffi.Annotated

/-- The original native concat dispatch returns literal status zero. This
operational companion also exposes its only JS heap write; numeric relatedness
alone deliberately does not imply an exact literal return. -/
theorem concat_status_step (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (base : Nat → GraphNode) (boundary : Nat → Prop) (objects : Nat → Object)
    (H N : Nat → Prop) (tail : List NumV) (host : HostSt → HostSt → Prop)
    (live framed : Nat → Prop) (before after : List Val) (old old' : List Event) (s : Host.Ts.St LSt)
    (h : StateR (NumberRoles ν₀ ν C₀ C)
      (VectorHost.NativeRelation ν₀ ν C₀ C (ConcatNative.preRoles base) boundary objects H N tail host)
      R live framed before after old old' ConcatCall.input s)
    (vectorRole : (Host.Ts.Owned.Annotated.Value.handle 29371).Holds ν C R (callArgument s.ctl 1))
    (axisRole : (Host.Ts.Owned.Annotated.Value.literal (.lit (F64.fin false 1 0))).Holds ν C R (callArgument s.ctl 2))
    (streamRole : (Host.Ts.Owned.Annotated.Value.handle 2).Holds ν C R (callArgument s.ctl 3))
    (slotRole : (slotKindRole 0).Holds ν C R (objectKindAt s (R.a 3126700)))
    (signatureFrame : ¬ framed 4409) (vectorLive : H 29371) (firstLive : N 20208) (secondLive : N 22582)
    (nodeBound : s.ffi.mlx.nnext < 2^64) (handleBound : s.ffi.mlx.next < 2^64) (heapBound : s.next < 2^64) :
    ∃ t, interpC (step F s).run C = some (t,C) ∧
      t.ctl = .ret (.num zeroN) ∧ t.next = s.next ∧
      (∀ a, a ≠ R.a 3126700 → t.heap.get a = s.heap.get a) := by
  have hk := ConcatCall.source_callee_kind
  rw [ConcatCall.source_caps] at hk
  have calleeLive : live 4708 := by
    have hl := h.controlLive
    rw [ConcatCall.source_control] at hl
    exact hl.1
  obtain ⟨_,_,_,hol⟩ := h.heap.readObject 4708 ConcatCall.calleeObject calleeLive
    (h.heap.function_notFramed 4708 ConcatCall.calleeObject _ calleeLive ConcatCall.source_callee hk)
    ConcatCall.source_callee
  have signatureLive : live 4409 := by
    have hl := hol.1
    rw [hk] at hl
    exact hl.1.2.1.2.1
  obtain ⟨fo,data,this,args,hc,hfo,hfk,hd,_,ha⟩ := h.native_call_view 4708 ConcatCall.calleeObject
    (.ffi .symbol) _ (.obj 4817) _ ConcatCall.source_control ConcatCall.source_callee hk
  cases hd with | cons hn hd =>
    cases hd with | cons ht hd =>
      cases hd with | cons hr hd =>
        cases hd
        cases hn; cases ht; cases hr
        cases ha with | cons hp ha =>
          cases ha with | cons hv ha =>
            cases ha with | cons ha1 ha =>
              cases ha with | cons hs ha =>
                cases ha
                cases hp
                have hevec := fixed_handle_value vectorRole
                have heaxis := fixed_literal_value axisRole
                have hestream := fixed_handle_value streamRole
                simp only [hc,callArgument,Host.Ts.arg,nthD] at hevec heaxis hestream
                rw [hevec,heaxis,hestream] at hc
                obtain ⟨signature,hsig,hsigr,_⟩ := h.heap.readObject 4409 ConcatCall.signatureObject signatureLive
                  signatureFrame ConcatCall.source_signature
                have hsKind := hsigr.kind
                rw [ConcatCall.source_signature_kind] at hsKind
                obtain ⟨tys,hsKind,htys⟩ := kind_array hsKind
                cases htys with | cons hp htys =>
                  cases htys with | cons hu htys =>
                    cases htys with | cons hi htys =>
                      cases htys with | cons hu2 htys =>
                        cases htys
                        cases hp; cases hu; cases hi; cases hu2
                        have bufferLive : live 3126700 := by
                          have hl := h.controlLive
                          rw [ConcatCall.source_control] at hl
                          exact hl.2.2.1.1
                        obtain ⟨bo,hbo,hbr,hbl⟩ := h.heap.readObject 3126700 ConcatCall.bufferObject bufferLive
                          (h.heap.buffer_notFramed 3126700 ConcatCall.bufferObject _ bufferLive
                            ConcatCall.source_buffer ConcatCall.source_buffer_kind) ConcatCall.source_buffer
                        have hbKind := hbr.kind
                        rw [ConcatCall.source_buffer_kind] at hbKind
                        obtain ⟨bytes,hbKind,hbytes⟩ := kind_buffer hbKind
                        have hbRole : (slotKindRole 0).Holds ν C R (Encode.kind bo.kind) := by
                          simpa only [objectKindAt,Host.Ts.St.obj?,hbo] using slotRole
                        have hebytes := Kind.buf.inj (hbKind.symm.trans (slot_kind_exact hbRole))
                        have hn := h.native.2
                        change Live _ R _ _ H N tail ConcatCall.native s.ffi.mlx at hn
                        rw [hn.handleZero] at hebytes
                        subst bytes
                        let bs' := cellParts .u64 (.big (Int.ofNat 0)) 8 0
                        let ws' := cellParts .u64 (.big (Int.ofNat (R.handle 29372))) 8 0
                        let args' : List Arg := [.jsPtr (R.a 3126700) 0 bs',.big (Int.ofNat (R.handle 29371)),
                          .num one,.big (Int.ofNat (R.handle 2))]
                        obtain ⟨nativeCall,hnAfter⟩ := ConcatNative.transport base objects boundary hn vectorLive firstLive secondLive
                          nodeBound handleBound (.big (Int.ofNat (R.handle 2)))
                        let native' : LSt := {s.ffi with mlx := createZero s.ffi.mlx (ConcatNative.targetNode R)}
                        let t := finishBuffer s native' (R.a 3126700) 0 bo bs' ws' chars!"mlx_concatenate_axis" args'
                        have htBuf : bufBytes F s (R.a 3126700) = some bs' :=
                          bufBytes_of_obj _ _ _ _ _ (by simp only [Host.Ts.St.obj?,hbo]) hbKind
                        have hcall : F.call s.ffi chars!"mlx_concatenate_axis"
                            [.jsPtr (R.a 3126700) 0 (bs'.drop 0),.big (Int.ofNat (R.handle 29371)),.num one,.big (Int.ofNat (R.handle 2))] =
                            M.pure (some (native',status0,[u64Write (R.a 3126700) 0 (R.handle 29372)])) := by
                          simpa only [F,native',bs',List.drop_zero] using load_call_concat s.ffi _ _ _ nativeCall
                        refine ⟨t,?_,rfl,rfl,?_⟩
                        · rw [step_ffi_ptr_u64_one_u64 F s (R.a 4708) (R.a 4409) (R.a 3126700) 0
                            (Int.ofNat (R.handle 29371)) (Int.ofNat (R.handle 2)) chars!"mlx_concatenate_axis" chars!"i32"
                            fo signature bs' native' status0 [u64Write (R.a 3126700) 0 (R.handle 29372)] hc
                            (by simp only [Host.Ts.St.obj?,hfo]) hfk (by simp only [Host.Ts.St.obj?,hsig]) hsKind htBuf hcall]
                          simp only [u64Write,← Int.ofNat_eq_natCast]
                          rw [ffiDone_status0_buffer F s native' (R.a 3126700) 0 bo bs' ws' chars!"mlx_concatenate_axis" _
                            (by simp only [Host.Ts.St.obj?,hbo]) hbKind]
                          rfl
                        · intro a ha
                          simp only [t,finishBuffer,St.ret,St.setTrace,St.setFfi,Host.Ts.St.setObj]
                          rw [PTrie.get_set_u64 _ _ _ (Nat.lt_trans (h.heap.targetBound _ bufferLive) heapBound)]
                          simp only [ite_eq_right ha]

/-- The established native/host state relation, with its operationally derived
exact status and heap frame exposed for the subsequent source status check. -/
theorem transport_status (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (base : Nat → GraphNode) (boundary : Nat → Prop) (objects : Nat → Object)
    (H N : Nat → Prop) (tail : List NumV) (host : HostSt → HostSt → Prop)
    (live framed : Nat → Prop) (before after : List Val) (old old' : List Event) (s : Host.Ts.St LSt)
    (h : StateR (NumberRoles ν₀ ν C₀ C)
      (VectorHost.NativeRelation ν₀ ν C₀ C (ConcatNative.preRoles base) boundary objects H N tail host)
      R live framed before after old old' ConcatCall.input s)
    (vectorRole : (Host.Ts.Owned.Annotated.Value.handle 29371).Holds ν C R (callArgument s.ctl 1))
    (axisRole : (Host.Ts.Owned.Annotated.Value.literal (.lit (F64.fin false 1 0))).Holds ν C R (callArgument s.ctl 2))
    (streamRole : (Host.Ts.Owned.Annotated.Value.handle 2).Holds ν C R (callArgument s.ctl 3))
    (slotRole : (slotKindRole 0).Holds ν C R (objectKindAt s (R.a 3126700)))
    (signatureFrame : ¬ framed 4409) (vectorLive : H 29371) (firstLive : N 20208) (secondLive : N 22582)
    (nodeBound : s.ffi.mlx.nnext < 2^64) (handleBound : s.ffi.mlx.next < 2^64) (heapBound : s.next < 2^64) :
    ∃ t, interpC (step F ConcatCall.input).run C₀ = some (ConcatCall.output,C₀) ∧
      interpC (step F s).run C = some (t,C) ∧
      StateR (NumberRoles ν₀ ν C₀ C)
        (VectorHost.NativeRelation ν₀ ν C₀ C (ConcatNative.postRoles base) boundary objects
          (fun a => a = 29372 ∨ H a) (fun i => i = 22587 ∨ N i) tail host)
        R live framed before after old old' ConcatCall.output t ∧
      (slotKindRole 29372).Holds ν C R (objectKindAt t (R.a 3126700)) ∧
      t.ctl = .ret (.num zeroN) ∧ t.next = s.next ∧
      (∀ a, a ≠ R.a 3126700 → t.heap.get a = s.heap.get a) := by
  obtain ⟨exactResult,exactRun,hctl,hnext,hheap⟩ := concat_status_step ν₀ ν C₀ C R base boundary objects H N tail host live framed before after old old' s h
    vectorRole axisRole streamRole slotRole signatureFrame vectorLive firstLive secondLive nodeBound handleBound heapBound
  obtain ⟨result,sourceRun,targetRun,related,slot⟩ := transport ν₀ ν C₀ C R base boundary objects H N tail host live framed before after old old' s h
    vectorRole axisRole streamRole slotRole signatureFrame vectorLive firstLive secondLive nodeBound handleBound heapBound
  have he := congrArg Prod.fst (Option.some.inj (targetRun.symm.trans exactRun))
  dsimp only at he
  subst exactResult
  exact ⟨result,sourceRun,targetRun,related,slot,hctl,hnext,hheap⟩

end Host.Load.Run.Full.Ordinary.ConcatHost
