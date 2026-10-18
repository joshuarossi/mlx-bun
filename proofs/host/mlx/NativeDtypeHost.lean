import host.mlx.OrdinaryVectorHost
import host.mlx.NativeVectorFreeHost

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

namespace Host.Ts
def finishNumber {S : Type} (s : St S) (native : S) (name : Name) (args : List Arg) (value : NumV) : St S :=
  ((s.setFfi native).setTrace (⟨name,args,.num value⟩ :: s.trace)).ret (.num value)
end Host.Ts

namespace Host.Load.Owned
open Host.Ts Host.Mlx.Ffi Host.Mlx.Ffi.NativeRoles

theorem load_dtype (s : LSt) (handle : Nat) (node : Node) (hn : s.mlx.node? handle = some node) :
    Host.Load.call s chars!"mlx_array_dtype" [.big (Int.ofNat handle)] =
      M.pure (some (s,.num (.lit (F64.ofNat node.dtype)),[])) := by
  have sy : symOf chars!"mlx_array_dtype" = some .arrayDtype := by decide +kernel
  have hc : Host.Mlx.Ffi.call s.mlx chars!"mlx_array_dtype" [.big (Int.ofNat handle)] =
      ok s.mlx (.num (.lit (F64.ofNat node.dtype))) := by
    unfold Host.Mlx.Ffi.call
    rw [sy]
    simp only [argNat_big_nat,Option.bind_some,hn]
  have hm : isMlx chars!"mlx_array_dtype" = true := by decide +kernel
  funext β k
  simp only [Host.Load.call,hm,Bool.cond_true,hc,ok,M.bind,M.pure]

end Host.Load.Owned

namespace Host.Load.Run.Full.Ordinary.DtypeHost
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric
open Host.Mlx.Ffi Host.Mlx.Ffi.NativeRoles Host.Mlx.Ffi.Annotated

abbrev F : Host.Ts.Ffi := ⟨LSt,Host.Load.call,Host.Load.read,fun _ => 4096,Host.Load.back⟩

/-- The indexed node annotation fixes dtype independently of variable shape
and numeric table contents. The original native result is an actual Number
literal, so later enum uses retain their representation witness. -/
theorem from_source (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (nodes : Nat → GraphNode) (boundary : Nat → Prop) (objects : Nat → Object)
    (H N : Nat → Prop) (tail : List NumV) (host : HostSt → HostSt → Prop)
    (live framed : Nat → Prop) (before after : List Val) (old old' : List Event) (s₀ s : Host.Ts.St LSt)
    (h : StateR (NumberRoles ν₀ ν C₀ C) (VectorHost.NativeRelation ν₀ ν C₀ C nodes boundary objects H N tail host)
      R live framed before after old old' s₀ s)
    (fn types handle : Nat) (fo signature₀ : Host.Ts.Obj) (returns : Name) (receiver : Val) (node : Node)
    (hc₀ : s₀.ctl = .call (.obj fn) receiver [.big (Int.ofNat handle)])
    (hf₀ : s₀.heap.get fn = some (.obj fo))
    (hk₀ : fo.kind = .fn (.native (.ffi .symbol) [.str chars!"mlx_array_dtype",.obj types,.str returns]))
    (ht₀ : s₀.heap.get types = some (.obj signature₀)) (htk₀ : signature₀.kind = .array [.str chars!"u64"])
    (signatureFrame : ¬ framed types) (handleLive : H handle) (sourceNode : s₀.ffi.mlx.node? handle = some node)
    (handleRole : (Host.Ts.Owned.Annotated.Value.handle handle).Holds ν C R (callArgument s.ctl 0)) :
    interpC (step Host.Load.ffi s₀).run C₀ = some
      (finishNumber s₀ s₀.ffi chars!"mlx_array_dtype" [.big (Int.ofNat handle)] (.lit (F64.ofNat node.dtype)),C₀) ∧
    interpC (step Host.Load.ffi s).run C = some
      (finishNumber s s.ffi chars!"mlx_array_dtype" [.big (Int.ofNat (R.handle handle))] (.lit (F64.ofNat node.dtype)),C) ∧
    StateR (NumberRoles ν₀ ν C₀ C) (VectorHost.NativeRelation ν₀ ν C₀ C nodes boundary objects H N tail host)
      R live framed before after old old'
      (finishNumber s₀ s₀.ffi chars!"mlx_array_dtype" [.big (Int.ofNat handle)] (.lit (F64.ofNat node.dtype)))
      (finishNumber s s.ffi chars!"mlx_array_dtype" [.big (Int.ofNat (R.handle handle))] (.lit (F64.ofNat node.dtype))) := by
  have calleeLive : live fn := by have hl := h.controlLive; rw [hc₀] at hl; exact hl.1
  obtain ⟨_,_,_,hol⟩ := h.heap.readObject fn fo calleeLive
    (h.heap.function_notFramed fn fo _ calleeLive hf₀ hk₀) hf₀
  have signatureLive : live types := by
    have hl := hol.1
    rw [hk₀] at hl
    exact hl.1.2.1.2.1
  obtain ⟨fo',data,this,args,hc,hfo,hfk,hd,_,ha⟩ := h.native_call_view fn fo (.ffi .symbol)
    _ receiver _ hc₀ hf₀ hk₀
  cases hd with | cons hn hd =>
    cases hd with | cons ht hd =>
      cases hd with | cons hr hd =>
        cases hd
        cases hn; cases ht; cases hr
        cases ha with | cons hh ha =>
          cases ha
          have he := fixed_handle_value handleRole
          simp only [hc,callArgument,Host.Ts.arg,nthD] at he
          rw [he] at hc
          obtain ⟨signature',hto,htr,_⟩ := h.heap.readObject types signature₀ signatureLive signatureFrame ht₀
          have htKind := htr.kind
          rw [htk₀] at htKind
          obtain ⟨tys,htKind,htys⟩ := kind_array htKind
          cases htys with | cons hu htys =>
            cases htys
            cases hu
            obtain ⟨i,node',hi,hn',nodeRoles⟩ := h.native.2.node? handleLive sourceNode
            have dtype : node'.dtype = node.dtype := nodeRoles.target.dtype.trans nodeRoles.source.dtype.symm
            have numberRole : NumberRoles ν₀ ν C₀ C (.lit (F64.ofNat node.dtype)) (.lit (F64.ofNat node.dtype)) :=
              ⟨.lit (F64.ofNat node.dtype),⟨rfl,rfl⟩⟩
            have hevent : TreeR (NumberRoles ν₀ ν C₀ C) R
                (event ⟨chars!"mlx_array_dtype",[.big (Int.ofNat handle)],.num (.lit (F64.ofNat node.dtype))⟩)
                (event ⟨chars!"mlx_array_dtype",[.big (Int.ofNat (R.handle handle))],.num (.lit (F64.ofNat node.dtype))⟩) :=
              .node _ (.cons (.atom _ _) (.cons
                (.node _ (.cons (.node _ (.cons (.value (.handle handle)) .nil)) .nil))
                (.cons (.node _ (.cons (.number numberRole) .nil)) .nil)))
            refine ⟨?_,?_,(h.traceCons _ _ hevent).go
              (.node _ (.cons (.value (.num numberRole)) .nil)) ⟨True.intro,True.intro⟩⟩
            · change interpC (step F s₀).run C₀ = _
              have hcall : Host.Load.call s₀.ffi chars!"mlx_array_dtype" [.big (Int.ofNat handle)] =
                  M.pure (some (s₀.ffi,.num (.lit (F64.ofNat node.dtype)),[])) :=
                Host.Load.Owned.load_dtype s₀.ffi handle node sourceNode
              rw [step_ffi_one_u64 F s₀ fn types (Int.ofNat handle) chars!"mlx_array_dtype" returns
                fo signature₀ receiver s₀.ffi (.num (.lit (F64.ofNat node.dtype))) hc₀
                (by simp only [Host.Ts.St.obj?,hf₀]) hk₀ (by simp only [Host.Ts.St.obj?,ht₀]) htk₀
                (by simpa only [F] using hcall)]
              rfl
            · change interpC (step F s).run C = _
              have hcall : Host.Load.call s.ffi chars!"mlx_array_dtype" [.big (Int.ofNat (R.handle handle))] =
                  M.pure (some (s.ffi,.num (.lit (F64.ofNat node.dtype)),[])) := by
                simpa only [dtype] using Host.Load.Owned.load_dtype s.ffi (R.handle handle) node' hn'
              rw [step_ffi_one_u64 F s (R.a fn) (R.a types) (Int.ofNat (R.handle handle)) chars!"mlx_array_dtype" returns
                fo' signature' this s.ffi (.num (.lit (F64.ofNat node.dtype))) hc
                (by simp only [Host.Ts.St.obj?,hfo]) hfk (by simp only [Host.Ts.St.obj?,hto]) htKind
                (by simpa only [F] using hcall)]
              rfl

end Host.Load.Run.Full.Ordinary.DtypeHost
