import host.mlx.OrdinaryArrayCut
import host.mlx.OrdinaryVectorHost

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

namespace Host.Load.Run.Full.Ordinary.ArrayHost
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric
open Host.Mlx.Ffi Host.Mlx.Ffi.NativeRoles Host.Mlx.Ffi.Annotated

abbrev F : Ffi := ⟨LSt,Host.Load.call,Host.Load.read,fun _ => 4096,Host.Load.back⟩

noncomputable def sourcePost : Host.Ts.St LSt :=
  finishBig ArrayCall.input ArrayCall.input.ffi chars!"mlx_array_new" [] 0

theorem source_post : sourcePost = ArrayCall.output := by host_kernel_rfl

theorem call_array_new (s : Host.Mlx.Ffi.St) :
    Host.Mlx.Ffi.call s chars!"mlx_array_new" [] = ok s (.big 0) := by
  have hs : symOf chars!"mlx_array_new" = some .arrayNew := by decide +kernel
  unfold Host.Mlx.Ffi.call
  rw [hs]

theorem load_array_new (s : LSt) :
    Host.Load.call s chars!"mlx_array_new" [] = M.pure (some (s,.big 0,[])) := by
  have hm : isMlx chars!"mlx_array_new" = true := by decide +kernel
  funext β k
  simp only [Host.Load.call,hm,Bool.cond_true,call_array_new,ok,M.bind,M.pure]

theorem source_step : step F ArrayCall.input = M.pure ArrayCall.output := by
  have hk := ArrayCall.source_callee_kind
  rw [ArrayCall.source_caps] at hk
  have hc : F.call ArrayCall.input.ffi chars!"mlx_array_new" [] =
      M.pure (some (ArrayCall.input.ffi,.big 0,[])) := by
    simpa only [F] using load_array_new ArrayCall.input.ffi
  rw [step_ffi_noargs F ArrayCall.input 4630 4253 chars!"mlx_array_new" chars!"u64"
    ArrayCall.calleeObject ArrayCall.signatureObject ArrayCall.input.ffi (.big 0) []
    ArrayCall.source_control (by simp only [Host.Ts.St.obj?,ArrayCall.source_callee]) hk
    (by simp only [Host.Ts.St.obj?,ArrayCall.source_signature]) ArrayCall.source_signature_kind
    hc,ffiDone_big_empty]
  change M.pure sourcePost = _
  rw [source_post]

/-- The actual empty-array constructor returns the fixed null handle and
preserves the entire native relation, including all selected object roles. -/
theorem transport_heap (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (nodes : Nat → GraphNode) (boundary : Nat → Prop) (objects : Nat → Object)
    (H N : Nat → Prop) (tail : List NumV) (host : HostSt → HostSt → Prop)
    (live framed : Nat → Prop) (before after : List Val) (old old' : List Event) (s : Host.Ts.St LSt)
    (h : StateR (NumberRoles ν₀ ν C₀ C)
      (VectorHost.NativeRelation ν₀ ν C₀ C nodes boundary objects H N tail host)
      R live framed before after old old' ArrayCall.input s)
    (signatureFrame : ¬ framed 4253) :
    ∃ t, interpC (step F ArrayCall.input).run C₀ = some (ArrayCall.output,C₀) ∧
      interpC (step F s).run C = some (t,C) ∧
      StateR (NumberRoles ν₀ ν C₀ C)
        (VectorHost.NativeRelation ν₀ ν C₀ C nodes boundary objects H N tail host)
        R live framed before after old old' ArrayCall.output t ∧
      t.ctl = .ret (.big 0) ∧ t.ffi = s.ffi ∧
      (Host.Ts.Owned.Annotated.Value.ordinaryBig 0).Holds ν C R (.big 0) ∧ t.heap = s.heap ∧ t.next = s.next := by
  have hk := ArrayCall.source_callee_kind
  rw [ArrayCall.source_caps] at hk
  have calleeLive : live 4630 := by
    have hl := h.controlLive
    rw [ArrayCall.source_control] at hl
    exact hl.1
  obtain ⟨_,_,_,hol⟩ := h.heap.readObject 4630 ArrayCall.calleeObject calleeLive
    (h.heap.function_notFramed 4630 ArrayCall.calleeObject _ calleeLive ArrayCall.source_callee hk)
    ArrayCall.source_callee
  have signatureLive : live 4253 := by
    have hl := hol.1
    rw [hk] at hl
    exact hl.1.2.1.2.1
  obtain ⟨fo,data,this,args,hc,hfo,hfk,hd,_,ha⟩ := h.native_call_view 4630 ArrayCall.calleeObject
    (.ffi .symbol) _ (.obj 4817) [] ArrayCall.source_control ArrayCall.source_callee hk
  cases hd with | cons hn hd =>
    cases hd with | cons ht hd =>
      cases hd with | cons hr hd =>
        cases hd
        cases hn; cases ht; cases hr
        cases ha
        obtain ⟨signature,hsig,hsigr,_⟩ := h.heap.readObject 4253 ArrayCall.signatureObject signatureLive
          signatureFrame ArrayCall.source_signature
        have hsKind := hsigr.kind
        rw [ArrayCall.source_signature_kind] at hsKind
        obtain ⟨tys,hsKind,htys⟩ := kind_array hsKind
        cases htys
        let t := finishBig s s.ffi chars!"mlx_array_new" [] 0
        have hv : ValueR (NumberRoles ν₀ ν C₀ C) R (.big 0) (.big 0) := .ordinaryBig 0
        have he : TreeR (NumberRoles ν₀ ν C₀ C) R
            (event ⟨chars!"mlx_array_new",[],.big 0⟩) (event ⟨chars!"mlx_array_new",[],.big 0⟩) :=
          .node _ (.cons (.atom _ _) (.cons (.node _ .nil)
            (.cons (.node _ (.cons (.value hv) .nil)) .nil)))
        have hpost := h.finishBig ArrayCall.input.ffi s.ffi h.native chars!"mlx_array_new" [] [] 0 0 he hv
        have hcall : F.call s.ffi chars!"mlx_array_new" [] = M.pure (some (s.ffi,.big 0,[])) := by
          simpa only [F] using load_array_new s.ffi
        refine ⟨t,?_,?_,?_,rfl,rfl,.ordinaryBig 0,rfl,rfl⟩
        · rw [source_step]; rfl
        · rw [step_ffi_noargs F s (R.a 4630) (R.a 4253) chars!"mlx_array_new" chars!"u64"
            fo signature s.ffi (.big 0) [] hc (by simp only [Host.Ts.St.obj?,hfo]) hfk
            (by simp only [Host.Ts.St.obj?,hsig]) hsKind hcall,ffiDone_big_empty]
          rfl
        · change StateR _ _ _ _ _ _ _ _ _ sourcePost t at hpost
          rw [source_post] at hpost
          exact hpost

theorem transport (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (nodes : Nat → GraphNode) (boundary : Nat → Prop) (objects : Nat → Object)
    (H N : Nat → Prop) (tail : List NumV) (host : HostSt → HostSt → Prop)
    (live framed : Nat → Prop) (before after : List Val) (old old' : List Event) (s : Host.Ts.St LSt)
    (h : StateR (NumberRoles ν₀ ν C₀ C)
      (VectorHost.NativeRelation ν₀ ν C₀ C nodes boundary objects H N tail host)
      R live framed before after old old' ArrayCall.input s)
    (signatureFrame : ¬ framed 4253) :
    ∃ t, interpC (step F ArrayCall.input).run C₀ = some (ArrayCall.output,C₀) ∧
      interpC (step F s).run C = some (t,C) ∧
      StateR (NumberRoles ν₀ ν C₀ C)
        (VectorHost.NativeRelation ν₀ ν C₀ C nodes boundary objects H N tail host)
        R live framed before after old old' ArrayCall.output t ∧
      t.ctl = .ret (.big 0) ∧ t.ffi = s.ffi ∧
      (Host.Ts.Owned.Annotated.Value.ordinaryBig 0).Holds ν C R (.big 0) := by
  obtain ⟨t,h₀,ht,hr,hctl,hffi,hrole,_,_⟩ := transport_heap ν₀ ν C₀ C R nodes boundary objects H N tail host
    live framed before after old old' s h signatureFrame
  exact ⟨t,h₀,ht,hr,hctl,hffi,hrole⟩

end Host.Load.Run.Full.Ordinary.ArrayHost
