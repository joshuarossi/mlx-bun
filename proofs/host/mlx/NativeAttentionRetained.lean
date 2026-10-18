import host.mlx.NativeAttentionFrame
import host.mlx.NativeBufferResultFrame
import host.mlx.NativeAbsentObjectRoles

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

namespace Host.Mlx.Ffi.Annotated
open Host.Ts Host.Ts.Owned

theorem attentionRole_subst (θ : Nat → SymE) (roles : Nat → GraphNode)
    (q k v : Nat) (scale : Number) (mask : Name) :
    (attentionRole roles q k v scale mask).subst θ =
      attentionRole (fun i => (roles i).subst θ) q k v (scale.subst θ) mask := by
  simp only [attentionRole,GraphNode.subst,Option.map_some,Primitive.subst,attentionShape_subst]

end Host.Mlx.Ffi.Annotated

namespace Host.Load.Run.Full.Ordinary.AttentionHost
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated
open Host.Mlx.Ffi Host.Mlx.Ffi.NativeRoles Host.Mlx.Ffi.Annotated

/-- Attention derives its output shape from the current query/value roles.
The cache time dimension is not fixed by this wrapper. All retained fields
survive the accepted output-slot write, and the producer policy is extended
by the actual SDPA node. -/
theorem retained_from_source {notes : RetainedNotes}
    (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (roles : Nat → GraphNode) (boundary : Nat → Prop) (objects : Nat → Object)
    (H N : Nat → Prop) (tail : List NumV) (host : HostSt → HostSt → Prop)
    (live framed : Nat → Prop) (before after : List Val) (old old' : List Event) (s₀ s : Host.Ts.St LSt)
    (h : StateR (NumberRoles ν₀ ν C₀ C) (VectorHost.NativeRelation ν₀ ν C₀ C roles boundary objects H N tail host)
      R live framed before after old old' s₀ s)
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live s₀ s)
    (fn types out hq hk hv q k v maskBuffer stream : Nat) (scale : F64) (force : Bool)
    (function signatureObject maskObject : Host.Ts.Obj) (returns : Name) (receiver : Val)
    (maskBytes : List Host.Ts.Byte) (mask : Name) (qn kn vn : Node)
    (control : s₀.ctl = .call (.obj fn) receiver [.ptr (.js out) 0,.big (Int.ofNat hq),.big (Int.ofNat hk),.big (Int.ofNat hv),
      .num (.lit scale),.ptr (.js maskBuffer) 0,.big 0,.big 0,.bool force,.big (Int.ofNat stream)])
    (read : s₀.heap.get fn = some (.obj function))
    (functionKind : function.kind = .fn (.native (.ffi .symbol) [.str symbol,.obj types,.str returns]))
    (signatureRead : s₀.heap.get types = some (.obj signatureObject)) (signatureKind : signatureObject.kind = .array signature)
    (maskRead : s₀.heap.get maskBuffer = some (.obj maskObject)) (maskKind : maskObject.kind = .buf maskBytes)
    (signatureFrame : ¬ framed types) (handlesLive : listSupport H [hq,hk,hv])
    (producers : nodesOf s₀.ffi.mlx [hq,hk,hv] = some [q,k,v])
    (sourceQ : s₀.ffi.mlx.nodes.get q = some qn) (sourceK : s₀.ffi.mlx.nodes.get k = some kn)
    (sourceV : s₀.ffi.mlx.nodes.get v = some vn)
    (decode : cstrArg (.jsPtr maskBuffer 0 maskBytes) = some mask)
    (qrank : len qn.shape = 4) (krank : len kn.shape = 4) (vrank : len vn.shape = 4)
    (sourceNodes : s₀.ffi.mlx.nnext < 2^64) (targetNodes : s.ffi.mlx.nnext < 2^64)
    (sourceHandles : s₀.ffi.mlx.next < 2^64) (targetHandles : s.ffi.mlx.next < 2^64)
    (sourceHeap : out < 2^64) (targetHeap : s.next < 2^64)
    (roots : Nat → Prop) (policy : ProducerAnnotations roots H N roles objects)
    (fnRole thisRole : Value)
    (note : notes.runtime.control = callNote fnRole thisRole ((arguments out hq hk hv maskBuffer stream scale force).map FixedArgument.role))
    (selected : notes.buffers.owners out = some (handleSlotNotes 0)) :
    let newRoles := nodeWrite roles s₀.ffi.mlx.nnext (attentionRole roles q k v (scaleRole scale) mask)
    let newObjects := objectWrite objects s₀.ffi.mlx.next .stream
    let newH := fun a => a = s₀.ffi.mlx.next ∨ H a
    let newN := fun i => i = s₀.ffi.mlx.nnext ∨ N i
    ∃ sourcePost targetPost, interpC (step Host.Load.ffi s₀).run C₀ = some (sourcePost,C₀) ∧
      interpC (step Host.Load.ffi s).run C = some (targetPost,C) ∧
      StateR (NumberRoles ν₀ ν C₀ C) (VectorHost.NativeRelation ν₀ ν C₀ C newRoles boundary newObjects newH newN tail host)
        R live framed before after old old' sourcePost targetPost ∧
      RetainedInventory (notes.nativeHandleResult out s₀.ffi.mlx.next) ν₀ ν C₀ C R live sourcePost targetPost ∧
      ProducerAnnotations roots newH newN newRoles newObjects ∧
      ProducerSupport roots newH newN sourcePost.ffi.mlx := by
  dsimp only
  obtain ⟨outObject,targetObject,bytes,targetBytes,outputRead,outputKind,targetRead,targetKind,sourceRoles,targetRoles⟩ :=
    inventory.buffers.selected out (handleSlotNotes 0) selected
  have exactSource := cellPartNotes_handle_exact .u64 0 8 0 bytes sourceRoles
  change bytes = cellParts .u64 (.big (Int.ofNat 0)) 8 0 at exactSource
  rw [exactSource] at outputKind
  have exactTarget := cellPartNotes_handle_exact .u64 0 8 0 targetBytes targetRoles
  rw [h.native.2.handleZero] at exactTarget
  have outputRole : (fixedBufferRole VectorGetHost.nullRole).Holds ν C R (objectKindAt s (R.a out)) := by
    simpa only [objectKindAt,Host.Ts.St.obj?,targetRead,targetKind,exactTarget,VectorGetHost.null_bytes] using
      fixedBuffer_holds ν C R VectorGetHost.nullRole
  have argumentRoles := (inventory.runtime.native_arguments fnRole thisRole (arguments out hq hk hv maskBuffer stream scale force)
    (.obj fn) receiver _ control note).2
  have supported := h.native.2.nodesOf_support [hq,hk,hv] [q,k,v] handlesLive producers
  obtain ⟨_,_,queryRole⟩ := h.native.2.node_view supported.1 sourceQ
  obtain ⟨_,_,keyRole⟩ := h.native.2.node_view supported.2.1 sourceK
  obtain ⟨_,_,valueRole⟩ := h.native.2.node_view supported.2.2.1 sourceV
  have queryRank : len (roles q).shape = 4 := queryRole.source.shape.len_eq.trans qrank
  have keyRank : len (roles k).shape = 4 := keyRole.source.shape.len_eq.trans krank
  have valueRank : len (roles v).shape = 4 := valueRole.source.shape.len_eq.trans vrank
  obtain ⟨t,sourceRun,targetRun,post,slotRole,sourceFrame,targetFrame,outside,targetReturn⟩ :=
    from_source_framed ν₀ ν C₀ C R roles boundary objects H N tail host live framed before after old old' s₀ s h
      fn types out hq hk hv q k v maskBuffer stream scale force function signatureObject outObject maskObject returns receiver
      maskBytes mask qn kn vn control read functionKind signatureRead signatureKind outputRead outputKind maskRead maskKind
      signatureFrame handlesLive producers sourceQ sourceK sourceV decode queryRank keyRank valueRank argumentRoles outputRole
      sourceNodes targetNodes sourceHandles targetHandles sourceHeap targetHeap
  let native₀ := resultWorld s₀.ffi q k v scale mask qn kn vn
  let beforeBytes := cellParts .u64 (.big (Int.ofNat 0)) 8 0
  let afterBytes := cellParts .u64 (.big (Int.ofNat s₀.ffi.mlx.next)) 8 0
  let sourcePost := finishBuffer s₀ native₀ out 0 outObject beforeBytes afterBytes symbol
    (callArgs out hq hk hv maskBuffer stream scale force beforeBytes maskBytes)
  have patch : beforeBytes.take 0 ++ afterBytes ++ beforeBytes.drop (0+len afterBytes) = afterBytes := rfl
  have sourceSlot : (slotKindRole s₀.ffi.mlx.next).Holds ν₀ C₀ identity (objectKindAt sourcePost out) := by
    simp only [sourcePost,objectKindAt,finishBuffer,Host.Ts.St.ret,Host.Ts.St.setTrace,Host.Ts.St.setFfi,
      Host.Ts.St.setObj,Host.Ts.St.obj?,PTrie.get_set_u64 _ _ _ sourceHeap,ite_true,patch]
    exact slot_role ν₀ C₀ identity s₀.ffi.mlx.next
  have sourceOutside : ∀ a, a ≠ out → sourcePost.heap.get a = s₀.heap.get a := by
    intro a different
    change (s₀.heap.set out _).get a = s₀.heap.get a
    rw [PTrie.get_set_u64 _ _ _ sourceHeap,ite_eq_right different]
  have retained := inventory.native_handle_result h.heap out s₀.ffi.mlx.next (handleSlotNotes 0) selected
    sourceFrame targetFrame sourceSlot slotRole sourceOutside outside rfl targetReturn
  have absent : sourcePost.ffi.mlx.objs.get s₀.ffi.mlx.next = none :=
    h.native.2.source_fresh_obj (Nat.le_refl _)
  have nativePost := post.native.2.reannotate_absent_object s₀.ffi.mlx.next .stream absent
  have nativePair : VectorHost.NativeRelation ν₀ ν C₀ C
      (nodeWrite roles s₀.ffi.mlx.nnext (attentionRole roles q k v (scaleRole scale) mask)) boundary
      (objectWrite objects s₀.ffi.mlx.next .stream) (fun a => a = s₀.ffi.mlx.next ∨ H a)
      (fun i => i = s₀.ffi.mlx.nnext ∨ N i) tail host R sourcePost.ffi t.ffi := ⟨post.native.1,nativePost⟩
  have newPost := post.setFfi sourcePost.ffi t.ffi nativePair
  have nodePolicy := policy.write_node s₀.ffi.mlx.nnext (attentionRole roles q k v (scaleRole scale) mask)
    (.sdpa (scaleRole scale) mask) [q,k,v] rfl supported
  have newPolicy := nodePolicy.new_object s₀.ffi.mlx.next .stream True.intro
  exact ⟨sourcePost,t,sourceRun,targetRun,newPost,retained,newPolicy,newPolicy.source nativePost⟩

theorem retained_cut {notes : RetainedNotes}
    (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (roles : Nat → GraphNode) (boundary : Nat → Prop) (objects : Nat → Object)
    (H N : Nat → Prop) (tail : List NumV) (host : HostSt → HostSt → Prop)
    (live framed : Nat → Prop) (before after : List Val) (old old' : List Event) (s₀ s : Host.Ts.St LSt)
    (h : StateR (NumberRoles ν₀ ν C₀ C) (VectorHost.NativeRelation ν₀ ν C₀ C roles boundary objects H N tail host)
      R live framed before after old old' s₀ s)
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live s₀ s)
    (fn types out hq hk hv q k v maskBuffer stream : Nat) (scale : F64) (force : Bool)
    (function signatureObject maskObject : Host.Ts.Obj) (returns : Name) (receiver : Val)
    (maskBytes : List Host.Ts.Byte) (mask : Name) (qn kn vn : Node)
    (control : s₀.ctl = .call (.obj fn) receiver [.ptr (.js out) 0,.big (Int.ofNat hq),.big (Int.ofNat hk),.big (Int.ofNat hv),
      .num (.lit scale),.ptr (.js maskBuffer) 0,.big 0,.big 0,.bool force,.big (Int.ofNat stream)])
    (read : s₀.heap.get fn = some (.obj function))
    (functionKind : function.kind = .fn (.native (.ffi .symbol) [.str symbol,.obj types,.str returns]))
    (signatureRead : s₀.heap.get types = some (.obj signatureObject)) (signatureKind : signatureObject.kind = .array signature)
    (maskRead : s₀.heap.get maskBuffer = some (.obj maskObject)) (maskKind : maskObject.kind = .buf maskBytes)
    (signatureFrame : ¬ framed types) (handlesLive : listSupport H [hq,hk,hv])
    (producers : nodesOf s₀.ffi.mlx [hq,hk,hv] = some [q,k,v])
    (sourceQ : s₀.ffi.mlx.nodes.get q = some qn) (sourceK : s₀.ffi.mlx.nodes.get k = some kn)
    (sourceV : s₀.ffi.mlx.nodes.get v = some vn)
    (decode : cstrArg (.jsPtr maskBuffer 0 maskBytes) = some mask)
    (qrank : len qn.shape = 4) (krank : len kn.shape = 4) (vrank : len vn.shape = 4)
    (sourceNodes : s₀.ffi.mlx.nnext < 2^64) (targetNodes : s.ffi.mlx.nnext < 2^64)
    (sourceHandles : s₀.ffi.mlx.next < 2^64) (targetHandles : s.ffi.mlx.next < 2^64)
    (sourceHeap : out < 2^64) (targetHeap : s.next < 2^64)
    (roots : Nat → Prop) (policy : ProducerAnnotations roots H N roles objects)
    (fnRole thisRole : Value)
    (note : notes.runtime.control = callNote fnRole thisRole ((arguments out hq hk hv maskBuffer stream scale force).map FixedArgument.role))
    (selected : notes.buffers.owners out = some (handleSlotNotes 0))
    (sourceOutput : Host.Ts.St LSt) (initialServer nextServer : SSrv)
    (inst : Inst ν₀ initialServer C₀)
    (sourceStep : interpS (step Host.Load.ffi s₀).run initialServer = some (sourceOutput,nextServer)) :
    let newRoles := nodeWrite roles s₀.ffi.mlx.nnext (attentionRole roles q k v (scaleRole scale) mask)
    let newObjects := objectWrite objects s₀.ffi.mlx.next .stream
    let newH := fun a => a = s₀.ffi.mlx.next ∨ H a
    let newN := fun i => i = s₀.ffi.mlx.nnext ∨ N i
    ∃ targetPost, interpC (step Host.Load.ffi s₀).run C₀ = some (sourceOutput,C₀) ∧
      interpC (step Host.Load.ffi s).run C = some (targetPost,C) ∧
      StateR (NumberRoles ν₀ ν C₀ C) (VectorHost.NativeRelation ν₀ ν C₀ C newRoles boundary newObjects newH newN tail host)
        R live framed before after old old' sourceOutput targetPost ∧
      RetainedInventory (notes.nativeHandleResult out s₀.ffi.mlx.next) ν₀ ν C₀ C R live sourceOutput targetPost ∧
      ProducerAnnotations roots newH newN newRoles newObjects ∧
      ProducerSupport roots newH newN sourceOutput.ffi.mlx ∧ Inst ν₀ nextServer C₀ := by
  dsimp only
  obtain ⟨sourcePost,targetPost,left,right,post,retained,policyPost,support⟩ :=
    retained_from_source ν₀ ν C₀ C R roles boundary objects H N tail host live framed before after old old' s₀ s h inventory
      fn types out hq hk hv q k v maskBuffer stream scale force function signatureObject maskObject returns receiver
      maskBytes mask qn kn vn control read functionKind signatureRead signatureKind maskRead maskKind signatureFrame
      handlesLive producers sourceQ sourceK sourceV decode qrank krank vrank sourceNodes targetNodes sourceHandles targetHandles
      sourceHeap targetHeap roots policy fnRole thisRole note selected
  obtain ⟨D,actual,instAfter⟩ := interp_sim ν₀ (step Host.Load.ffi s₀).run initialServer C₀ sourceOutput nextServer inst sourceStep
  have equality := Option.some.inj (left.symm.trans actual)
  have same : sourcePost = sourceOutput := congrArg Prod.fst equality
  have table : C₀ = D := congrArg Prod.snd equality
  rw [same] at left post retained support
  exact ⟨targetPost,left,right,post,retained,policyPost,support,table ▸ instAfter⟩

end Host.Load.Run.Full.Ordinary.AttentionHost
