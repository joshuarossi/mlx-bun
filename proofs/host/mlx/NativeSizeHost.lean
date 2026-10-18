import host.mlx.NativeSizeGeometry
import host.mlx.NativeEvalHost

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

namespace Host.Load.Run.Full.Ordinary.SizeHost
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric
open Host.Mlx.Ffi Host.Mlx.Ffi.NativeRoles Host.Mlx.Ffi.Annotated

abbrev F : Host.Ts.Ffi := ⟨LSt,Host.Load.call,Host.Load.read,fun _ => 4096,Host.Load.back⟩
def symbol : Name := chars!"mlx_array_size"
def product (dims : List Nat) : Int := Int.ofNat (dims.foldr (·*·) 1)

theorem load_size (s : LSt) (handle : Nat) (node : Node) (dims : List Nat)
    (source : s.mlx.node? handle = some node) (decode : natsOfDims node.shape = some dims) :
    Host.Load.call s symbol [.big (Int.ofNat handle)] = M.pure (some (s,.big (product dims),[])) := by
  have native := Host.Mlx.Ffi.Parametric.call_size s.mlx handle node dims source decode
  funext β k
  simp only [Host.Load.call,symbol,native,M.pure]
  rfl

/-- The native product is derived from the selected owned node's fixed literal
dimension annotations. Exact bounded products supply an ordinary integer role,
independently of owned handles with the same numeric value. -/
theorem from_source (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (roles : Nat → GraphNode) (boundary : Nat → Prop) (objects : Nat → Object)
    (H N : Nat → Prop) (tail : List NumV) (host : HostSt → HostSt → Prop)
    (live framed : Nat → Prop) (before after : List Val) (old old' : List Event) (s₀ s : Host.Ts.St LSt)
    (h : StateR (NumberRoles ν₀ ν C₀ C) (VectorHost.NativeRelation ν₀ ν C₀ C roles boundary objects H N tail host)
      R live framed before after old old' s₀ s)
    (fn types handle input : Nat) (fo signature₀ : Host.Ts.Obj) (returns : Name) (receiver : Val) (node : Node)
    (sourceDims targetDims : List Nat)
    (hc₀ : s₀.ctl = .call (.obj fn) receiver [.big (Int.ofNat handle)])
    (hf₀ : s₀.heap.get fn = some (.obj fo))
    (hk₀ : fo.kind = .fn (.native (.ffi .symbol) [.str symbol,.obj types,.str returns]))
    (ht₀ : s₀.heap.get types = some (.obj signature₀)) (htk₀ : signature₀.kind = .array [.str chars!"u64"])
    (signatureFrame : ¬ framed types) (handleLive : H handle)
    (producer : s₀.ffi.mlx.arrs.get handle = some input) (sourceNode : s₀.ffi.mlx.nodes.get input = some node)
    (sourceGeometry : NaturalSize ν₀ (roles input).shape sourceDims)
    (targetGeometry : NaturalSize ν (roles input).shape targetDims)
    (handleRole : (Host.Ts.Owned.Annotated.Value.handle handle).Holds ν C R (callArgument s.ctl 0)) :
    ∃ t, interpC (step Host.Load.ffi s₀).run C₀ =
        some (finishBig s₀ s₀.ffi symbol [.big (Int.ofNat handle)] (product sourceDims),C₀) ∧
      interpC (step Host.Load.ffi s).run C = some (t,C) ∧
      StateR (NumberRoles ν₀ ν C₀ C) (VectorHost.NativeRelation ν₀ ν C₀ C roles boundary objects H N tail host)
        R live framed before after old old'
        (finishBig s₀ s₀.ffi symbol [.big (Int.ofNat handle)] (product sourceDims)) t ∧
      t.ffi = s.ffi ∧ t.heap = s.heap ∧ t.next = s.next ∧ t.stack = s.stack ∧
      t.ctl = .ret (.big (product targetDims)) ∧
      (Host.Ts.Owned.Annotated.Value.exactInteger (roles input).shape.sizeMeaning).Holds ν C R (.big (product targetDims)) := by
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
          have native := h.native.2
          have inputLive := native.arrLive handle input handleLive producer
          obtain ⟨node',hn',hrn⟩ := native.node_view inputLive sourceNode
          have sourceHandle : s₀.ffi.mlx.node? handle = some node := by
            simp only [Host.Mlx.Ffi.St.node?,producer,Option.bind_some,sourceNode]
          have targetHandle : s.ffi.mlx.node? (R.handle handle) = some node' := by
            simp only [Host.Mlx.Ffi.St.node?,native.arrs handle handleLive,producer,Option.map_some,Option.bind_some,hn']
          have sourceDecode := sourceGeometry.decode hrn.source.shape
          have targetDecode := targetGeometry.decode hrn.target.shape
          have sizeRole : NumberRoles ν₀ ν C₀ C
              (.lit (F64.ofInt (product sourceDims))) (.lit (F64.ofInt (product targetDims))) :=
            ⟨(roles input).shape.sizeMeaning,sourceGeometry.denote,targetGeometry.denote⟩
          have events : TreeR (NumberRoles ν₀ ν C₀ C) R
              (event ⟨symbol,[.big (Int.ofNat handle)],.big (product sourceDims)⟩)
              (event ⟨symbol,[.big (Int.ofNat (R.handle handle))],.big (product targetDims)⟩) :=
            .node _ (.cons (.atom _ _) (.cons (.node _ (.cons (.node _ (.cons (.value (.handle handle)) .nil)) .nil))
              (.cons (.node _ (.cons (.value (.numericInteger sizeRole)) .nil)) .nil)))
          refine ⟨finishBig s s.ffi symbol [.big (Int.ofNat (R.handle handle))] (product targetDims),?_,?_,
            h.finishBig s₀.ffi s.ffi h.native _ _ _ _ _ events (.numericInteger sizeRole),rfl,rfl,rfl,rfl,rfl,
            targetGeometry.exactInteger⟩
          · change interpC (step F s₀).run C₀ = _
            have call : F.call s₀.ffi symbol [.big (Int.ofNat handle)] = M.pure (some (s₀.ffi,.big (product sourceDims),[])) := by
              simpa only [F] using load_size s₀.ffi handle node sourceDims sourceHandle sourceDecode
            rw [step_ffi_one_u64 F s₀ fn types (Int.ofNat handle) symbol returns fo signature₀ receiver s₀.ffi
              (.big (product sourceDims)) hc₀ (by simp only [Host.Ts.St.obj?,hf₀]) hk₀
              (by simp only [Host.Ts.St.obj?,ht₀]) htk₀ call]
            rfl
          · change interpC (step F s).run C = _
            have call : F.call s.ffi symbol [.big (Int.ofNat (R.handle handle))] =
                M.pure (some (s.ffi,.big (product targetDims),[])) := by
              simpa only [F] using load_size s.ffi (R.handle handle) node' targetDims targetHandle targetDecode
            rw [step_ffi_one_u64 F s (R.a fn) (R.a types) (Int.ofNat (R.handle handle)) symbol returns fo' signature' this s.ffi
              (.big (product targetDims)) hc (by simp only [Host.Ts.St.obj?,hfo]) hfk
              (by simp only [Host.Ts.St.obj?,hto]) htKind call]
            rfl

end Host.Load.Run.Full.Ordinary.SizeHost
