import host.mlx.NativeConvFrame
import host.mlx.NativeClosedArguments
import host.mlx.NativeConvLiteralGeometry
import host.mlx.NativeBufferResultFrame
import host.mlx.NativeAbsentObjectRoles

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

namespace Host.Load.Run.Full.Ordinary.ConvFamilyHost
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated
open Host.Mlx.Ffi Host.Mlx.Ffi.NativeRoles Host.Mlx.Ffi.Annotated

def convArgumentNotes (out hx hy stream : Nat) (stride padding dilation groups : Value) : List Value :=
  [.ptr (.js out) 0,.handle hx,.handle hy,stride,padding,dilation,groups,.handle stream]

private theorem conv_arguments_fixed {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren}
    (p : ConvParameters) (out hx hy stream : Nat) (stride padding dilation groups : Value)
    (strideSchema : ClosedLiteralNote stride) (paddingSchema : ClosedLiteralNote padding)
    (dilationSchema : ClosedLiteralNote dilation) (groupsSchema : ClosedLiteralNote groups)
    (values : List Val)
    (source : ListR (fun role value => role.Holds ν₀ C₀ identity value)
      (convArgumentNotes out hx hy stream stride padding dilation groups)
      [.ptr (.js out) 0,.big (Int.ofNat hx),.big (Int.ofNat hy),.num (.lit p.strideValue),
        .num (.lit p.paddingValue),.num (.lit p.dilationValue),.num (.lit p.groupsValue),.big (Int.ofNat stream)])
    (target : ListR (fun role value => role.Holds ν C R value)
      (convArgumentNotes out hx hy stream stride padding dilation groups) values) :
    ListR (fun role value => role.role.Holds ν C R value) (arguments p out hx hy stream) values := by
  cases source with | cons _ h =>
    cases h with | cons _ h =>
      cases h with | cons _ h =>
        cases h with | cons sa h =>
          cases h with | cons sb h =>
            cases h with | cons sc h =>
              cases h with | cons sd h =>
                cases h with | cons _ h =>
                  cases h
                  cases target with | cons a h =>
                    cases h with | cons b h =>
                      cases h with | cons c h =>
                        cases h with | cons d h =>
                          cases h with | cons e h =>
                            cases h with | cons f h =>
                              cases h with | cons g h =>
                                cases h with | cons i h =>
                                  cases h
                                  exact .cons a (.cons b (.cons c (.cons (strideSchema.exact sa d)
                                    (.cons (paddingSchema.exact sb e) (.cons (dilationSchema.exact sc f)
                                      (.cons (groupsSchema.exact sd g) (.cons i .nil)))))))

/-- Original convolution dispatch consumes current closed literal parameter
notes and current producer geometry. The accepted slot write preserves all
six inventories and extends the indexed producer/object policy. -/
theorem retained_from_source {notes : RetainedNotes}
    (p : ConvParameters) (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (roles : Nat → GraphNode) (boundary : Nat → Prop) (objects : Nat → Object)
    (H N : Nat → Prop) (tail : List NumV) (host : HostSt → HostSt → Prop)
    (live framed : Nat → Prop) (before after : List Val) (old old' : List Event) (s₀ s : Host.Ts.St LSt)
    (h : StateR (NumberRoles ν₀ ν C₀ C) (VectorHost.NativeRelation ν₀ ν C₀ C roles boundary objects H N tail host)
      R live framed before after old old' s₀ s)
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live s₀ s)
    (fn types out hx hy x y stream : Nat) (returns : Name) (function signatureObject : Host.Ts.Obj)
    (receiver : Val) (xn yn : Node) (output : Shape)
    (control : s₀.ctl = .call (.obj fn) receiver [.ptr (.js out) 0,.big (Int.ofNat hx),.big (Int.ofNat hy),
      .num (.lit p.strideValue),.num (.lit p.paddingValue),.num (.lit p.dilationValue),.num (.lit p.groupsValue),.big (Int.ofNat stream)])
    (read : s₀.heap.get fn = some (.obj function))
    (functionKind : function.kind = .fn (.native (.ffi .symbol) [.str symbol,.obj types,.str returns]))
    (signatureRead : s₀.heap.get types = some (.obj signatureObject)) (signatureKind : signatureObject.kind = .array signature)
    (signatureFrame : ¬ framed types) (handlesLive : listSupport H [hx,hy])
    (producers : nodesOf s₀.ffi.mlx [hx,hy] = some [x,y])
    (sourceX : s₀.ffi.mlx.nodes.get x = some xn) (sourceY : s₀.ffi.mlx.nodes.get y = some yn)
    (strideFixed : F64.un .int32 p.strideValue = p.strideValue) (paddingFixed : F64.un .int32 p.paddingValue = p.paddingValue)
    (dilationFixed : F64.un .int32 p.dilationValue = p.dilationValue) (groupsFixed : F64.un .int32 p.groupsValue = p.groupsValue)
    (sourceGeometry : ConvGeometry ν₀ (roles x).shape (roles y).shape output p.stride p.padding p.dilation p.groups)
    (targetGeometry : ConvGeometry ν (roles x).shape (roles y).shape output p.stride p.padding p.dilation p.groups)
    (sourceNodes : s₀.ffi.mlx.nnext < 2^64) (targetNodes : s.ffi.mlx.nnext < 2^64)
    (sourceHandles : s₀.ffi.mlx.next < 2^64) (targetHandles : s.ffi.mlx.next < 2^64)
    (sourceHeap : out < 2^64) (targetHeap : s.next < 2^64)
    (roots : Nat → Prop) (policy : ProducerAnnotations roots H N roles objects)
    (fnRole thisRole stride padding dilation groups : Value)
    (strideSchema : ClosedLiteralNote stride) (paddingSchema : ClosedLiteralNote padding)
    (dilationSchema : ClosedLiteralNote dilation) (groupsSchema : ClosedLiteralNote groups)
    (note : notes.runtime.control = callNote fnRole thisRole (convArgumentNotes out hx hy stream stride padding dilation groups))
    (selected : notes.buffers.owners out = some (handleSlotNotes 0)) :
    let newRoles := nodeWrite roles s₀.ffi.mlx.nnext (convRole roles p x y output)
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
  obtain ⟨_,_,targetThis,targetArgs,targetControl,_,_,_,_,_⟩ :=
    h.native_call_view fn function (.ffi .symbol) _ receiver _ control read functionKind
  have currentSource := inventory.runtime.source.control
  rw [note,control] at currentSource
  have currentTarget := inventory.runtime.target.control
  rw [note,targetControl] at currentTarget
  have argumentRoles := conv_arguments_fixed p out hx hy stream stride padding dilation groups
    strideSchema paddingSchema dilationSchema groupsSchema targetArgs (callNote_view currentSource).2.2 (callNote_view currentTarget).2.2
  have argumentRoles' : ListR (fun role value => role.role.Holds ν C R value) (arguments p out hx hy stream) (callArguments s.ctl) := by
    simpa only [targetControl,callArguments] using argumentRoles
  obtain ⟨shape,t,sourceRun,targetRun,post,slotRole,_,_,outside,supported,sourceFrame,targetFrame,targetReturn⟩ :=
    from_source_framed p ν₀ ν C₀ C R roles boundary objects H N tail host live framed before after old old' s₀ s h
      fn types out hx hy x y stream returns function signatureObject outObject receiver xn yn output control read functionKind
      signatureRead signatureKind outputRead outputKind signatureFrame handlesLive producers sourceX sourceY
      strideFixed paddingFixed dilationFixed groupsFixed sourceGeometry targetGeometry argumentRoles' outputRole
      sourceNodes targetNodes sourceHandles targetHandles sourceHeap targetHeap
  let sourcePost := finishBuffer s₀ (resultWorld p s₀.ffi x y shape xn.dtype yn.dtype) out 0 outObject
    (cellParts .u64 (.big (Int.ofNat 0)) 8 0) (cellParts .u64 (.big (Int.ofNat s₀.ffi.mlx.next)) 8 0)
    symbol (callArgs p out hx hy stream (cellParts .u64 (.big (Int.ofNat 0)) 8 0))
  have sourceSlot : (slotKindRole s₀.ffi.mlx.next).Holds ν₀ C₀ identity (objectKindAt sourcePost out) := by
    simp only [sourcePost,objectKindAt,finishBuffer,Host.Ts.St.ret,Host.Ts.St.setTrace,Host.Ts.St.setFfi,
      Host.Ts.St.setObj,Host.Ts.St.obj?,PTrie.get_set_u64 _ _ _ sourceHeap,ite_true]
    exact slot_role ν₀ C₀ identity s₀.ffi.mlx.next
  have sourceOutside : ∀ a, a ≠ out → sourcePost.heap.get a = s₀.heap.get a := by
    intro a different
    change (s₀.heap.set out _).get a = s₀.heap.get a
    rw [PTrie.get_set_u64 _ _ _ sourceHeap,ite_eq_right different]
  have retained := inventory.native_handle_result h.heap out s₀.ffi.mlx.next (handleSlotNotes 0) selected
    sourceFrame targetFrame sourceSlot slotRole sourceOutside outside rfl targetReturn
  have absent : sourcePost.ffi.mlx.objs.get s₀.ffi.mlx.next = none := h.native.2.source_fresh_obj (Nat.le_refl _)
  have nativePost := post.native.2.reannotate_absent_object s₀.ffi.mlx.next .stream absent
  have nativePair : VectorHost.NativeRelation ν₀ ν C₀ C (nodeWrite roles s₀.ffi.mlx.nnext (convRole roles p x y output)) boundary
      (objectWrite objects s₀.ffi.mlx.next .stream) (fun a => a = s₀.ffi.mlx.next ∨ H a)
      (fun i => i = s₀.ffi.mlx.nnext ∨ N i) tail host R sourcePost.ffi t.ffi := ⟨post.native.1,nativePost⟩
  have newPost := post.setFfi sourcePost.ffi t.ffi nativePair
  have oldInputs := h.native.2.nodesOf_support [hx,hy] [x,y] handlesLive producers
  have nodePolicy := policy.write_node s₀.ffi.mlx.nnext (convRole roles p x y output)
    (.conv1d p.stride p.padding p.dilation p.groups) [x,y] rfl oldInputs
  have newPolicy := nodePolicy.new_object s₀.ffi.mlx.next .stream True.intro
  exact ⟨sourcePost,t,sourceRun,targetRun,newPost,retained,newPolicy,newPolicy.source nativePost⟩

end Host.Load.Run.Full.Ordinary.ConvFamilyHost
