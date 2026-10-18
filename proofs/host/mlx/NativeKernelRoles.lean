import host.mlx.NativeConfigRoles
import host.mlx.OrdinaryConcatNative
import host.mlx.NativeKernelApply

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

namespace Host.Mlx.Ffi.Annotated
open Host.Ts Host.Ts.Owned

def kernelNodeRole (handle : Nat) (inputs : List Nat) (config : Config) (index : Nat) (output : Shape × Nat) : GraphNode :=
  ⟨output.1,output.2,some (.kernel handle config index,inputs)⟩

def kernelOutputRoles (roles : Nat → GraphNode) (handle : Nat) (inputs : List Nat) (config : Config) :
    Nat → Nat → List (Shape × Nat) → Nat → GraphNode
  | _,_,[] => roles
  | fresh,index,output::outputs =>
    kernelOutputRoles (nodeWrite roles fresh (kernelNodeRole handle inputs config index output))
      handle inputs config (fresh+1) (index+1) outputs

theorem kernel_created {roles : Nat → GraphNode} {ν₀ ν : Nat → F64} {C₀ C : CSrv}
    {R : Ren} {boundary : Nat → Prop} (fresh handle : Nat) (inputs : List Nat) (config : Config) (index : Nat)
    (output : Shape × Nat) (source target : Cfg) (shape₀ shape : List Dim)
    (hc₀ : config.Holds ν₀ C₀ source) (hc : config.Holds ν C target)
    (hs₀ : Shape.Holds ν₀ C₀ output.1 shape₀) (hs : Shape.Holds ν C output.1 shape) :
    NodeRel (nodeWrite roles fresh (kernelNodeRole handle inputs config index output)) ν₀ ν C₀ C R boundary fresh
      ⟨.kernel handle source index,inputs,shape₀,output.2⟩
      ⟨.kernel (R.handle handle) target index,inputs.map R.node,shape,output.2⟩ := by
  constructor
  · simp only [nodeWrite,ite_true]
    refine ⟨hs₀,rfl,?_⟩
    intro p ins he
    cases he
    refine ⟨.kernel handle index hc₀,?_⟩
    simp only [Owned.Annotated.identity,List.map_id_fun,id_eq]
  · simp only [nodeWrite,ite_true]
    refine ⟨hs,rfl,?_⟩
    intro p ins he
    cases he
    exact ⟨.kernel handle index hc,rfl⟩
  · intro he
    simp only [nodeWrite,ite_true] at he
    cases he

end Host.Mlx.Ffi.Annotated

namespace Host.Mlx.Ffi.NativeRoles
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Mlx.Ffi.Annotated

theorem Live.addNodeRoles {NR : NumV → NumV → Prop} {R : Ren}
    {NodeRel NodeRel' : Nat → Node → Node → Prop} {ObjRel : Nat → Obj → Obj → Prop}
    {H N : Nat → Prop} {tail : List NumV} {s s' : St}
    (h : Live NR R NodeRel ObjRel H N tail s s') (n n' : Node)
    (created : NodeRel' s.nnext n n')
    (frame : ∀ i, i ≠ s.nnext → ∀ x y, NodeRel i x y → NodeRel' i x y)
    (bs : s.nnext < 2^64) (bt : s'.nnext < 2^64) :
    Live NR R NodeRel' ObjRel H (fun i => i = s.nnext ∨ N i) tail (s.addNode n).2 (s'.addNode n').2 := by
  have before : Live NR R NodeRel' ObjRel H N tail s s' := h.withNodes (fun i hi =>
    (h.nodes i hi).mono (frame i (Nat.ne_of_lt (h.liveNodeBound i hi))))
  exact before.addNode n n' created bs bt

/-- The original Metal-output loop preserves fixed shape and configuration
meanings in every newly allocated node, in its original output order. -/
theorem kernel_outputs_roles {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren} {boundary : Nat → Prop}
    {ObjRel : Nat → Obj → Obj → Prop} {H : Nat → Prop} {tail : List NumV}
    (handle : Nat) (inputs : List Nat) (config : Config) (source target : Cfg)
    (hc₀ : config.Holds ν₀ C₀ source) (hc : config.Holds ν C target)
    {outputRoles : List (Shape × Nat)} {outputs outputs' : List (List Dim × Nat)}
    (hs : ListR (fun r v => Shape.Holds ν₀ C₀ r.1 v.1 ∧ v.2 = r.2) outputRoles outputs)
    (ht : ListR (fun r v => Shape.Holds ν C r.1 v.1 ∧ v.2 = r.2) outputRoles outputs') :
    ∀ (roles : Nat → GraphNode) (N : Nat → Prop) (s s' : St) (index : Nat),
      Live (NumberRoles ν₀ ν C₀ C) R (NodeRel roles ν₀ ν C₀ C R boundary) ObjRel H N tail s s' →
      s.nnext + outputs.length < 2^64 → s'.nnext + outputs'.length < 2^64 →
      let out := kernelApply.outs handle inputs source s index outputs
      let out' := kernelApply.outs (R.handle handle) (inputs.map R.node) target s' index outputs'
      ∃ K, Live (NumberRoles ν₀ ν C₀ C) R
          (NodeRel (kernelOutputRoles roles handle inputs config s.nnext index outputRoles) ν₀ ν C₀ C R boundary)
          ObjRel H K tail out.1 out'.1 ∧ out'.2 = out.2.map R.node ∧
        (∀ i, N i → K i) ∧ listSupport K out.2 := by
  induction hs generalizing outputs' with
  | nil =>
    cases ht
    intro roles N s s' index h _ _
    exact ⟨N,h,rfl,fun _ hi => hi,True.intro⟩
  | @cons role value outputRoles outputs hsource hrest ih =>
    cases ht with
    | @cons _ value' _ outputs' htarget hrest' =>
      intro roles N s s' index h bs bt
      rcases role with ⟨shapeRole,dtype⟩
      rcases value with ⟨shape₀,dtype₀⟩
      rcases value' with ⟨shape,dtype'⟩
      rcases hsource with ⟨hshape₀,hd₀⟩
      rcases htarget with ⟨hshape,hd⟩
      dsimp only at hd₀ hd hshape₀ hshape
      subst dtype₀
      subst dtype'
      have ns : s.nnext < 2^64 := by simp only [List.length_cons] at bs; omega
      have nt : s'.nnext < 2^64 := by simp only [List.length_cons] at bt; omega
      let node : Node := ⟨.kernel handle source index,inputs,shape₀,dtype⟩
      let node' : Node := ⟨.kernel (R.handle handle) target index,inputs.map R.node,shape,dtype⟩
      let roles' := nodeWrite roles s.nnext (kernelNodeRole handle inputs config index (shapeRole,dtype))
      have created : NodeRel roles' ν₀ ν C₀ C R boundary s.nnext node node' :=
        kernel_created s.nnext handle inputs config index (shapeRole,dtype) source target shape₀ shape hc₀ hc hshape₀ hshape
      have hv := h.addNodeRoles node node' created (fun _ ne _ _ p => NodeRel.write_frame ne p) ns nt
      have bs' : (s.addNode node).2.nnext + outputs.length < 2^64 := by
        change s.nnext+1+outputs.length < 2^64
        simp only [List.length_cons] at bs
        omega
      have bt' : (s'.addNode node').2.nnext + outputs'.length < 2^64 := by
        change s'.nnext+1+outputs'.length < 2^64
        simp only [List.length_cons] at bt
        omega
      obtain ⟨K,hk,he,hinc,hl⟩ := ih hrest' roles' _ (s.addNode node).2 (s'.addNode node').2 (index+1) hv bs' bt'
      refine ⟨K,hk,?_,?_,?_⟩
      · change s'.nnext :: (kernelApply.outs (R.handle handle) (inputs.map R.node) target (s'.addNode node').2 (index+1) outputs').2 =
          R.node s.nnext :: ((kernelApply.outs handle inputs source (s.addNode node).2 (index+1) outputs).2.map R.node)
        rw [he,h.nodeMap.head]
      · intro i hi; exact hinc i (.inr hi)
      · exact ⟨hinc s.nnext (.inl rfl),hl⟩

private theorem metadata_length {α β : Type} {r : α → β → Prop} {xs : List α} {ys : List β}
    (h : ListR r xs ys) : xs.length = ys.length := by
  induction h with
  | nil => rfl
  | cons _ _ ih => exact congrArg Nat.succ ih

/-- The original Metal application writes its existing result vector while
retaining all fixed object annotations outside that precise vector slot. The
configuration lookup and its target payload follow from the source invariant. -/
theorem Live.kernelApply_existing_roles {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren}
    {boundary : Nat → Prop} {roles : Nat → GraphNode} {objects : Nat → Object}
    {H N : Nat → Prop} {tail : List NumV} {s s' : St}
    (h : Live (NumberRoles ν₀ ν C₀ C) R (NodeRel roles ν₀ ν C₀ C R boundary)
      (ObjectRel objects ν₀ ν C₀ C R) H N tail s s')
    (out out' : Arg) (b off slot handle inv cfg : Nat) (name source header : Name)
    (nIn nOut : Nat) (inputs old : List Nat) (config : Config) (c : Cfg)
    (hslot : H slot) (hkernel : H handle) (hinputs : H inv) (hconfig : H cfg)
    (ho : slotOf out = some (b,off,slot)) (ho' : slotOf out' = some (R.a b,off,R.handle slot))
    (hk : s.obj? handle = some (.kernel name source header nIn nOut))
    (hi : s.obj? inv = some (.vec inputs)) (hv : s.obj? slot = some (.vec old))
    (hc : s.obj? cfg = some (.cfg c)) (configRole : objects cfg = .config config)
    (sourceNodes : s.nnext + config.outs.length < 2^64) (targetNodes : s'.nnext + config.outs.length < 2^64)
    (sourceSlot : slot < 2^64) (targetSlot : R.handle slot < 2^64) :
    ∃ c' K,
      s'.obj? (R.handle cfg) = some (.cfg c') ∧
      let result := kernelApply.outs handle inputs c s 0 c.outs
      let result' := kernelApply.outs (R.handle handle) (inputs.map R.node) c' s' 0 c'.outs
      kernelApply s out (.big (Int.ofNat handle)) (.big (Int.ofNat inv)) (.big (Int.ofNat cfg)) =
        okW (result.1.setObj slot (.vec result.2)) status0 [u64Write b off slot] ∧
      kernelApply s' out' (.big (Int.ofNat (R.handle handle))) (.big (Int.ofNat (R.handle inv)))
          (.big (Int.ofNat (R.handle cfg))) =
        okW (result'.1.setObj (R.handle slot) (.vec result'.2)) status0 [u64Write (R.a b) off (R.handle slot)] ∧
      Live (NumberRoles ν₀ ν C₀ C) R
        (NodeRel (kernelOutputRoles roles handle inputs config s.nnext 0 config.outs) ν₀ ν C₀ C R boundary)
        (ObjectRel (objectWrite objects slot (.vec result.2)) ν₀ ν C₀ C R) H K tail
        (result.1.setObj slot (.vec result.2)) (result'.1.setObj (R.handle slot) (.vec result'.2)) ∧
      result'.2 = result.2.map R.node ∧ (∀ i, N i → K i) ∧ listSupport K result.2 ∧
      ListR (ByteR (NumberRoles ν₀ ν C₀ C) R)
        (cellParts .u64 (.big (Int.ofNat slot)) 8 0) (cellParts .u64 (.big (Int.ofNat (R.handle slot))) 8 0) := by
  obtain ⟨c',hc',hc₀,hct⟩ := h.config_view_roles cfg hconfig config c configRole hc
  have sourceBound : s.nnext + c.outs.length < 2^64 := by
    rw [← metadata_length hc₀.output]; exact sourceNodes
  have targetBound : s'.nnext + c'.outs.length < 2^64 := by
    rw [← metadata_length hct.output]; exact targetNodes
  obtain ⟨K,hl,hm,hinc,hsup⟩ := kernel_outputs_roles handle inputs config c c' hc₀ hct hc₀.output hct.output
    roles N s s' 0 h sourceBound targetBound
  let result := kernelApply.outs handle inputs c s 0 c.outs
  let result' := kernelApply.outs (R.handle handle) (inputs.map R.node) c' s' 0 c'.outs
  have hsobj : result.1.objs = s.objs := kernel_outputs_objs handle inputs c c.outs s 0
  have htobj : result'.1.objs = s'.objs := kernel_outputs_objs (R.handle handle) (inputs.map R.node) c' c'.outs s' 0
  have weak := h.mono (fun _ _ p => p) (fun _ _ _ p => p) (fun _ _ _ p => p.base)
  have hv' := weak.vec_view slot hslot old hv
  have hvresult : result.1.obj? slot = some (.vec old) := by
    change result.1.objs.get slot = some (.vec old)
    rw [hsobj]; exact hv
  have hvresult' : result'.1.obj? (R.handle slot) = some (.vec (old.map R.node)) := by
    change result'.1.objs.get (R.handle slot) = some (.vec (old.map R.node))
    rw [htobj]; exact hv'
  have updated := hl.setObjectRoles slot hslot (.vec result.2) (.vec (result.2.map R.node))
    (ObjectRel.write_vec objects ν₀ ν C₀ C R slot result.2)
    (fun _ ne _ _ p => ObjectRel.write_frame ne p) sourceSlot targetSlot
  change Live _ R _ _ H K tail (result.1.setObj slot (.vec result.2))
    (result'.1.setObj (R.handle slot) (.vec (result.2.map R.node))) at updated
  rw [← hm] at updated
  refine ⟨c',K,hc',?_,?_,updated,hm,hinc,hsup,Host.Mlx.Ffi.Parametric.cellParts_roles (.handle slot) .u64 8 0⟩
  · exact NativeRoles.kernelApply_existing s result.1 out b off slot handle inv cfg name source header nIn nOut
      inputs result.2 old c ho hk hi hc rfl hvresult
  · exact NativeRoles.kernelApply_existing s' result'.1 out' (R.a b) off (R.handle slot)
      (R.handle handle) (R.handle inv) (R.handle cfg) name source header nIn nOut
      (inputs.map R.node) result'.2 (old.map R.node) c' ho'
      (weak.kernel_view handle hkernel name source header nIn nOut hk) (weak.vec_view inv hinputs inputs hi) hc' rfl hvresult'

end Host.Mlx.Ffi.NativeRoles
