import host.mlx.OrdinaryVectorHost
import host.mlx.NativeConfigRoles

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

namespace Host.Load.Owned
open Host.Ts

def newMetalConfig (s : LSt) : LSt := {s with mlx := (s.mlx.newObj (.cfg .empty)).2}

theorem load_metal_config_new (s : LSt) : Host.Load.call s chars!"mlx_fast_metal_kernel_config_new" [] =
    M.pure (some (newMetalConfig s,.big (Int.ofNat s.mlx.next),[])) := by
  have native : Host.Mlx.Ffi.call s.mlx chars!"mlx_fast_metal_kernel_config_new" [] =
      Host.Mlx.Ffi.ok (s.mlx.newObj (.cfg .empty)).2 (.big (Int.ofNat s.mlx.next)) :=
    Host.Mlx.Ffi.NativeRoles.Constructor.call .config s.mlx
  have hm : Host.Load.isMlx chars!"mlx_fast_metal_kernel_config_new" = true := by decide +kernel
  funext β k
  simp only [Host.Load.call,hm,Bool.cond_true,native,Host.Mlx.Ffi.ok,M.bind,M.pure,newMetalConfig]

end Host.Load.Owned

namespace Host.Load.Run.Full.Ordinary.ConfigFactoryHost
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric
open Host.Mlx.Ffi Host.Mlx.Ffi.NativeRoles Host.Mlx.Ffi.Annotated

/-- The original Metal configuration constructor preserves all selected
objects and assigns its fresh handle the fixed empty configuration role. -/
theorem from_source (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (nodes : Nat → GraphNode) (boundary : Nat → Prop) (objects : Nat → Object)
    (H N : Nat → Prop) (tail : List NumV) (host : HostSt → HostSt → Prop)
    (live framed : Nat → Prop) (before after : List Val) (old old' : List Event) (s₀ s : Host.Ts.St LSt)
    (h : StateR (NumberRoles ν₀ ν C₀ C) (VectorHost.NativeRelation ν₀ ν C₀ C nodes boundary objects H N tail host)
      R live framed before after old old' s₀ s)
    (fn types : Nat) (fo signature₀ : Host.Ts.Obj) (returns : Name) (receiver : Val)
    (hc₀ : s₀.ctl = .call (.obj fn) receiver []) (hf₀ : s₀.heap.get fn = some (.obj fo))
    (hk₀ : fo.kind = .fn (.native (.ffi .symbol) [.str chars!"mlx_fast_metal_kernel_config_new",.obj types,.str returns]))
    (ht₀ : s₀.heap.get types = some (.obj signature₀)) (htk₀ : signature₀.kind = .array [])
    (signatureFrame : ¬ framed types) (sourceBound : s₀.ffi.mlx.next < 2^64) (targetBound : s.ffi.mlx.next < 2^64) :
    interpC (step Host.Load.ffi s₀).run C₀ = some
      (finishBig s₀ (Host.Load.Owned.newMetalConfig s₀.ffi) chars!"mlx_fast_metal_kernel_config_new" [] (Int.ofNat s₀.ffi.mlx.next),C₀) ∧
    interpC (step Host.Load.ffi s).run C = some
      (finishBig s (Host.Load.Owned.newMetalConfig s.ffi) chars!"mlx_fast_metal_kernel_config_new" [] (Int.ofNat s.ffi.mlx.next),C) ∧
    StateR (NumberRoles ν₀ ν C₀ C)
      (VectorHost.NativeRelation ν₀ ν C₀ C nodes boundary
        (objectWrite objects s₀.ffi.mlx.next (.config emptyConfig)) (fun a => a = s₀.ffi.mlx.next ∨ H a) N tail host)
      R live framed before after old old'
      (finishBig s₀ (Host.Load.Owned.newMetalConfig s₀.ffi) chars!"mlx_fast_metal_kernel_config_new" [] (Int.ofNat s₀.ffi.mlx.next))
      (finishBig s (Host.Load.Owned.newMetalConfig s.ffi) chars!"mlx_fast_metal_kernel_config_new" [] (Int.ofNat s.ffi.mlx.next)) := by
  have calleeLive : live fn := by have hl := h.controlLive; rw [hc₀] at hl; exact hl.1
  obtain ⟨_,_,_,hol⟩ := h.heap.readObject fn fo calleeLive
    (h.heap.function_notFramed fn fo _ calleeLive hf₀ hk₀) hf₀
  have signatureLive : live types := by
    have hl := hol.1
    rw [hk₀] at hl
    exact hl.1.2.1.2.1
  obtain ⟨fo',data,this,args,hc,hfo,hfk,hd,_,ha⟩ := h.native_call_view fn fo (.ffi .symbol)
    _ receiver [] hc₀ hf₀ hk₀
  cases hd with | cons hn hd =>
    cases hd with | cons ht hd =>
      cases hd with | cons hr hd =>
        cases hd
        cases hn; cases ht; cases hr
        cases ha
        obtain ⟨signature',hto,htr,_⟩ := h.heap.readObject types signature₀ signatureLive signatureFrame ht₀
        have htKind := htr.kind
        rw [htk₀] at htKind
        obtain ⟨tys,htKind,htys⟩ := kind_array htKind
        cases htys
        have native := h.native.2
        have nativeAfter : VectorHost.NativeRelation ν₀ ν C₀ C nodes boundary
            (objectWrite objects s₀.ffi.mlx.next (.config emptyConfig)) (fun a => a = s₀.ffi.mlx.next ∨ H a) N tail host
            R (Host.Load.Owned.newMetalConfig s₀.ffi) (Host.Load.Owned.newMetalConfig s.ffi) :=
          ⟨h.native.1,native.newObjectRoles (.cfg .empty) (.cfg .empty)
            (ObjectRel.write_config objects ν₀ ν C₀ C R s₀.ffi.mlx.next emptyConfig .empty .empty
              (Config.Holds.empty ν₀ C₀) (Config.Holds.empty ν C))
            (fun _ ne _ _ p => ObjectRel.write_frame ne p) sourceBound targetBound⟩
        have hv : ValueR (NumberRoles ν₀ ν C₀ C) R (.big (Int.ofNat s₀.ffi.mlx.next)) (.big (Int.ofNat s.ffi.mlx.next)) := by
          rw [← native.handleMap.head]
          exact .handle _
        have hevent : TreeR (NumberRoles ν₀ ν C₀ C) R
            (event ⟨chars!"mlx_fast_metal_kernel_config_new",[],.big (Int.ofNat s₀.ffi.mlx.next)⟩)
            (event ⟨chars!"mlx_fast_metal_kernel_config_new",[],.big (Int.ofNat s.ffi.mlx.next)⟩) :=
          .node _ (.cons (.atom _ _) (.cons (.node _ .nil) (.cons (.node _ (.cons (.value hv) .nil)) .nil)))
        refine ⟨?_,?_,h.finishBig _ _ nativeAfter _ _ _ _ _ hevent hv⟩
        · have hcall : Host.Load.ffi.call s₀.ffi chars!"mlx_fast_metal_kernel_config_new" [] =
              M.pure (some (Host.Load.Owned.newMetalConfig s₀.ffi,.big (Int.ofNat s₀.ffi.mlx.next),[])) := by
            simpa only [Host.Load.ffi] using Host.Load.Owned.load_metal_config_new s₀.ffi
          rw [step_ffi_noargs Host.Load.ffi s₀ fn types chars!"mlx_fast_metal_kernel_config_new" returns fo signature₀
            (Host.Load.Owned.newMetalConfig s₀.ffi) (.big (Int.ofNat s₀.ffi.mlx.next)) [] hc₀
            (by simp only [Host.Ts.St.obj?,hf₀]) hk₀ (by simp only [Host.Ts.St.obj?,ht₀]) htk₀ hcall]
          rfl
        · have hcall : Host.Load.ffi.call s.ffi chars!"mlx_fast_metal_kernel_config_new" [] =
              M.pure (some (Host.Load.Owned.newMetalConfig s.ffi,.big (Int.ofNat s.ffi.mlx.next),[])) := by
            simpa only [Host.Load.ffi] using Host.Load.Owned.load_metal_config_new s.ffi
          rw [step_ffi_noargs Host.Load.ffi s (R.a fn) (R.a types) chars!"mlx_fast_metal_kernel_config_new" returns fo' signature'
            (Host.Load.Owned.newMetalConfig s.ffi) (.big (Int.ofNat s.ffi.mlx.next)) [] hc
            (by simp only [Host.Ts.St.obj?,hfo]) hfk (by simp only [Host.Ts.St.obj?,hto]) htKind hcall]
          rfl

end Host.Load.Run.Full.Ordinary.ConfigFactoryHost
