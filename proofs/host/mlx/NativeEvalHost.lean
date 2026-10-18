import host.mlx.OrdinaryVectorHost
import host.mlx.NativeVectorFreeHost
import host.mlx.FixedNativeRoles

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

namespace Host.Load.Run.Full.Ordinary.EvalHost
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric
open Host.Mlx.Ffi Host.Mlx.Ffi.NativeRoles Host.Mlx.Ffi.Annotated

abbrev F : Host.Ts.Ffi := ⟨LSt,Host.Load.call,Host.Load.read,fun _ => 4096,Host.Load.back⟩

inductive Mode where | arrayEval | vector | asyncVector
def Mode.name : Mode → Name
  | .arrayEval => chars!"mlx_array_eval"
  | .vector => chars!"mlx_eval"
  | .asyncVector => chars!"mlx_async_eval"
def Mode.Input (kind : Mode) (s : Host.Mlx.Ffi.St) (handle : Nat) : Prop :=
  match kind with
  | .arrayEval => ∃ node, s.node? handle = some node
  | .vector | .asyncVector => ∃ nodes, s.obj? handle = some (.vec nodes)

theorem Mode.mlx (kind : Mode) : Host.Load.isMlx kind.name = true := by cases kind <;> decide +kernel

theorem Mode.call (kind : Mode) (s : Host.Mlx.Ffi.St) (handle : Nat) (valid : kind.Input s handle) :
    Host.Mlx.Ffi.call s kind.name [.big (Int.ofNat handle)] = ok s status0 := by
  cases kind with
  | arrayEval =>
    obtain ⟨node,hn⟩ := valid
    have sy : symOf chars!"mlx_array_eval" = some .arrayEval := by decide +kernel
    simp only [Mode.name]
    unfold Host.Mlx.Ffi.call
    rw [sy]
    simp only [argNat_big_nat,Option.bind_some,hn]
  | vector =>
    obtain ⟨nodes,hn⟩ := valid
    have sy : symOf chars!"mlx_eval" = some .eval := by decide +kernel
    simp only [Mode.name]
    unfold Host.Mlx.Ffi.call
    rw [sy]
    simp only [argNat_big_nat,Option.bind_some,hn]
  | asyncVector =>
    obtain ⟨nodes,hn⟩ := valid
    have sy : symOf chars!"mlx_async_eval" = some .asyncEval := by decide +kernel
    simp only [Mode.name]
    unfold Host.Mlx.Ffi.call
    rw [sy]
    simp only [argNat_big_nat,Option.bind_some,hn]

theorem Mode.load_call (kind : Mode) (s : LSt) (handle : Nat) (valid : kind.Input s.mlx handle) :
    Host.Load.call s kind.name [.big (Int.ofNat handle)] = M.pure (some (s,status0,[])) := by
  funext β k
  simp only [Host.Load.call,kind.mlx,Bool.cond_true,kind.call s.mlx handle valid,ok,M.bind,M.pure]

theorem Mode.input_target (kind : Mode) {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren}
    {roles : Nat → GraphNode} {boundary : Nat → Prop} {objects : Nat → Object}
    {H N : Nat → Prop} {tail : List NumV} {s s' : Host.Mlx.Ffi.St}
    (h : Live (NumberRoles ν₀ ν C₀ C) R (NodeRel roles ν₀ ν C₀ C R boundary) (ObjectRel objects ν₀ ν C₀ C R) H N tail s s')
    (handle : Nat) (held : H handle) (valid : kind.Input s handle) : kind.Input s' (R.handle handle) := by
  have loose : Live (NumberRoles ν₀ ν C₀ C) R (NodeRel roles ν₀ ν C₀ C R boundary)
      (fun _ => Host.Mlx.Ffi.NativeRoles.ObjectR (NumberRoles ν₀ ν C₀ C) R) H N tail s s' :=
    h.mono (fun _ _ p => p) (fun _ _ _ p => p) (fun _ _ _ p => p.base)
  cases kind with
  | arrayEval =>
    obtain ⟨node,hn⟩ := valid
    obtain ⟨i,node',_,hn',_⟩ := h.node? held hn
    exact ⟨node',hn'⟩
  | vector => obtain ⟨nodes,hn⟩ := valid; exact ⟨nodes.map R.node,loose.vec_view handle held nodes hn⟩
  | asyncVector => obtain ⟨nodes,hn⟩ := valid; exact ⟨nodes.map R.node,loose.vec_view handle held nodes hn⟩

/-- Evaluation validates the source-owned array/vector and derives the target
validity. Its original native model and full strong invariant stay unchanged. -/
theorem from_source (kind : Mode) (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (roles : Nat → GraphNode) (boundary : Nat → Prop) (objects : Nat → Object)
    (H N : Nat → Prop) (tail : List NumV) (host : HostSt → HostSt → Prop)
    (live framed : Nat → Prop) (before after : List Val) (old old' : List Event) (s₀ s : Host.Ts.St LSt)
    (h : StateR (NumberRoles ν₀ ν C₀ C) (VectorHost.NativeRelation ν₀ ν C₀ C roles boundary objects H N tail host)
      R live framed before after old old' s₀ s)
    (fn types handle : Nat) (fo signature₀ : Host.Ts.Obj) (returns : Name) (receiver : Val)
    (hc₀ : s₀.ctl = .call (.obj fn) receiver [.big (Int.ofNat handle)])
    (hf₀ : s₀.heap.get fn = some (.obj fo))
    (hk₀ : fo.kind = .fn (.native (.ffi .symbol) [.str kind.name,.obj types,.str returns]))
    (ht₀ : s₀.heap.get types = some (.obj signature₀)) (htk₀ : signature₀.kind = .array [.str chars!"u64"])
    (signatureFrame : ¬ framed types) (handleLive : H handle) (valid : kind.Input s₀.ffi.mlx handle)
    (handleRole : (Host.Ts.Owned.Annotated.Value.handle handle).Holds ν C R (callArgument s.ctl 0)) :
    ∃ t, interpC (step Host.Load.ffi s₀).run C₀ = some (finishStatus s₀ s₀.ffi kind.name [.big (Int.ofNat handle)],C₀) ∧
      interpC (step Host.Load.ffi s).run C = some (t,C) ∧
      StateR (NumberRoles ν₀ ν C₀ C) (VectorHost.NativeRelation ν₀ ν C₀ C roles boundary objects H N tail host)
        R live framed before after old old' (finishStatus s₀ s₀.ffi kind.name [.big (Int.ofNat handle)]) t ∧
      t.ffi = s.ffi ∧ t.heap = s.heap ∧ t.next = s.next ∧ t.ctl = .ret (.num zeroN) := by
  have calleeLive : live fn := by have hl := h.controlLive; rw [hc₀] at hl; exact hl.1
  obtain ⟨_,_,_,hol⟩ := h.heap.readObject fn fo calleeLive
    (h.heap.function_notFramed fn fo _ calleeLive hf₀ hk₀) hf₀
  have signatureLive : live types := by have hl := hol.1; rw [hk₀] at hl; exact hl.1.2.1.2.1
  obtain ⟨fo',data,this,args,hc,hfo,hfk,hd,_,ha⟩ := h.native_call_view fn fo (.ffi .symbol) _ receiver _ hc₀ hf₀ hk₀
  cases hd with | cons hn hd =>
    cases hd with | cons ht hd =>
      cases hd with | cons hr hd =>
        cases hd
        cases hn; cases ht; cases hr
        cases ha with | cons hv ha =>
          cases ha
          have exactHandle := fixed_handle_value handleRole
          simp only [hc,callArgument,Host.Ts.arg,nthD] at exactHandle
          rw [exactHandle] at hc
          obtain ⟨signature',hto,htr,_⟩ := h.heap.readObject types signature₀ signatureLive signatureFrame ht₀
          have htKind := htr.kind
          rw [htk₀] at htKind
          obtain ⟨tys,htKind,htys⟩ := kind_array htKind
          have exactTypes := string_values_exact [chars!"u64"] htys
          rw [exactTypes] at htKind
          have targetValid := kind.input_target h.native.2 handle handleLive valid
          have zeroRole : NumberRoles ν₀ ν C₀ C zeroN zeroN := ⟨.lit (F64.zero false),⟨rfl,rfl⟩⟩
          have events : TreeR (NumberRoles ν₀ ν C₀ C) R
              (event ⟨kind.name,[.big (Int.ofNat handle)],status0⟩) (event ⟨kind.name,[.big (Int.ofNat (R.handle handle))],status0⟩) :=
            .node _ (.cons (.atom _ _) (.cons (.node _ (.cons (.node _ (.cons (.value (.handle handle)) .nil)) .nil))
              (.cons (.node _ (.cons (.number zeroRole) .nil)) .nil)))
          refine ⟨finishStatus s s.ffi kind.name [.big (Int.ofNat (R.handle handle))],?_,?_,
            h.finishStatus s₀.ffi s.ffi h.native _ _ _ events zeroRole,rfl,rfl,rfl,rfl⟩
          · change interpC (step F s₀).run C₀ = _
            have call : F.call s₀.ffi kind.name [.big (Int.ofNat handle)] = M.pure (some (s₀.ffi,status0,[])) := by
              simpa only [F] using kind.load_call s₀.ffi handle valid
            rw [step_ffi_one_u64 F s₀ fn types (Int.ofNat handle) kind.name returns fo signature₀ receiver s₀.ffi status0 hc₀
              (by simp only [Host.Ts.St.obj?,hf₀]) hk₀ (by simp only [Host.Ts.St.obj?,ht₀]) htk₀ call]
            rfl
          · change interpC (step F s).run C = _
            have call : F.call s.ffi kind.name [.big (Int.ofNat (R.handle handle))] = M.pure (some (s.ffi,status0,[])) := by
              simpa only [F] using kind.load_call s.ffi (R.handle handle) targetValid
            rw [step_ffi_one_u64 F s (R.a fn) (R.a types) (Int.ofNat (R.handle handle)) kind.name returns fo' signature' this s.ffi status0 hc
              (by simp only [Host.Ts.St.obj?,hfo]) hfk (by simp only [Host.Ts.St.obj?,hto]) htKind call]
            rfl

end Host.Load.Run.Full.Ordinary.EvalHost
