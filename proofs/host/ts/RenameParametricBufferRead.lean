import host.ts.RenameParametricNativeCall
import host.ts.RenameOwnedBuffer
import host.mlx.NativeSymbol
set_option Elab.async false
namespace Host.Ts.Owned.Parametric

/-- Bun's original read.u64 builtin reads the coherent native-written cell,
including its owned-handle role; it does not interpret the handle as an
ordinary integer or require a target memory-read premise. -/
theorem step_readU64_buffer_eq (F : Ffi) (s : St F.S) (a buffer handle : Nat)
    (fn : Obj) (data : List Val) (this : Val)
    (hc : s.ctl = .call (.obj a) this [.ptr (.js buffer) 0,.num zeroN])
    (hf : s.heap.get a = some (.obj fn)) (hk : fn.kind = .fn (.native (.ffi .readU64) data))
    (hb : bufBytes F s buffer = some (cellParts .u64 (.big (Int.ofNat handle)) 8 0)) :
    step F s = M.pure (s.ret (.big (Int.ofNat handle))) := by
  rw [step_native_eq F s a fn (.ffi .readU64) data this _ hc hf hk]
  funext β k
  simp only [callNative,ffiN,ffiN.rd,Host.Ts.arg,nthD,offsetArg,zeroN,readMem,hb,
    List.drop_zero,Host.Ts.Owned.readCell_parts,cellVal,retS,M.bind,M.pure]
  rfl

theorem step_readU64_buffer_from_source (F : Ffi) (NR : NumV → NumV → Prop)
    (FR : Ren → F.S → F.S → Prop) (R : Ren) (C₀ C : CSrv) (ν : Nat → F64)
    (live framed : Nat → Prop) (before after : List Val) (old old' : List Event)
    (s₀ s : St F.S) (h : StateR NR FR R live framed before after old old' s₀ s)
    (a buffer handle : Nat) (fn bo : Obj) (data₀ : List Val) (this₀ : Val)
    (hc₀ : s₀.ctl = .call (.obj a) this₀ [.ptr (.js buffer) 0,.num zeroN])
    (hf₀ : s₀.heap.get a = some (.obj fn)) (hk₀ : fn.kind = .fn (.native (.ffi .readU64) data₀))
    (hb₀ : s₀.heap.get buffer = some (.obj bo))
    (hbk₀ : bo.kind = .buf (cellParts .u64 (.big (Int.ofNat handle)) 8 0))
    (offset : (Annotated.Value.literal (.lit (F64.zero false))).Holds ν C R (callArgument s.ctl 1))
    (slot : (slotKindRole handle).Holds ν C R (objectKindAt s (R.a buffer))) :
    interpC (step F s₀).run C₀ = some (s₀.ret (.big (Int.ofNat handle)),C₀) ∧
    interpC (step F s).run C = some (s.ret (.big (Int.ofNat (R.handle handle))),C) ∧
    StateR NR FR R live framed before after old old'
      (s₀.ret (.big (Int.ofNat handle))) (s.ret (.big (Int.ofNat (R.handle handle)))) := by
  obtain ⟨fn',data,this,args,hc,hf,hk,_,_,ha⟩ := h.native_call_view a fn (.ffi .readU64) data₀ this₀ _ hc₀ hf₀ hk₀
  cases ha with | cons hp ha =>
    cases ha with | cons hoff ha =>
      cases ha
      cases hp
      have heoff := fixed_literal_value offset
      simp only [hc,callArgument,Host.Ts.arg,nthD] at heoff
      rw [heoff] at hc
      have hl := h.controlLive
      rw [hc₀] at hl
      have bufferLive : live buffer := hl.2.2.1.1
      obtain ⟨bo',hbo,_,_⟩ := h.heap.readObject buffer bo bufferLive
        (h.heap.buffer_notFramed buffer bo _ bufferLive hb₀ hbk₀) hb₀
      have hslot : (slotKindRole handle).Holds ν C R (Encode.kind bo'.kind) := by
        simpa only [objectKindAt,St.obj?,hbo] using slot
      have hbk := slot_kind_exact hslot
      have sourceBytes : bufBytes F s₀ buffer = some (cellParts .u64 (.big (Int.ofNat handle)) 8 0) :=
        bufBytes_of_obj F s₀ buffer bo _ (by simp only [St.obj?,hb₀]) hbk₀
      have targetBytes : bufBytes F s (R.a buffer) = some (cellParts .u64 (.big (Int.ofNat (R.handle handle))) 8 0) :=
        bufBytes_of_obj F s (R.a buffer) bo' _ (by simp only [St.obj?,hbo]) hbk
      refine ⟨?_,?_,h.go (.node _ (.cons (.value (.handle handle)) .nil)) ⟨True.intro,True.intro⟩⟩
      · rw [step_readU64_buffer_eq F s₀ a buffer handle fn data₀ this₀ hc₀ hf₀ hk₀ sourceBytes]; rfl
      · rw [step_readU64_buffer_eq F s (R.a a) (R.a buffer) (R.handle handle) fn' data this hc hf hk targetBytes]; rfl

end Host.Ts.Owned.Parametric
