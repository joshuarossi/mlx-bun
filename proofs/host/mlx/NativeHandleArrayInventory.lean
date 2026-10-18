import host.mlx.NativeHandleArrayCells
import host.mlx.NativeTypedArrayInventory

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

namespace Host.Ts.Owned.Annotated
open Parametric

theorem step_construct_u64_array_eq (F : Ffi) (s : St F.S) (fn owner proto : Nat) (object iterable : Obj)
    (newTarget : Val) (x y : F64) (values : List Val) (cells : List Host.Ts.Cell)
    (control : s.ctl = .construct (.obj fn) [.obj owner] newTarget)
    (read : s.heap.get fn = some (.obj object))
    (kind : object.kind = .fn (.native (.buf .typedCtor) [.num (.lit x),.num (.lit y)]))
    (iterableRead : s.heap.get owner = some (.obj iterable)) (iterableKind : iterable.kind = .array values)
    (codeIndex : F64.toIndex? x = some 9) (protoIndex : F64.toIndex? y = some proto)
    (conversion : cellsOf .u64 values = M.pure (some cells)) :
    step F s = M.pure ((newTyped F s .u64 proto (cellBytes .u64 cells) (len cells)).2.ret (.obj (s.next+1))) := by
  simp only [step,control,constructStep,St.obj?,read,kind,constructNative,bufN,codeIndex,protoIndex]
  obtain ⟨k,pr,props,priv,ext⟩ := iterable
  dsimp only at iterableKind
  subst k
  simp only [bufN.typedCtor,Host.Ts.arg,nthD,St.obj?,iterableRead,elemsOf,eltOfCode,retS]
  change M.bind (cellsOf .u64 values) _ = _
  rw [conversion]
  rfl

private theorem handles_supported_mono {P Q : Nat → Prop} (inclusion : ∀ i, P i → Q i) :
    ∀ values, listSupport P values → listSupport Q values
  | [], _ => True.intro
  | value::values, held => ⟨inclusion value held.1,handles_supported_mono inclusion values held.2⟩

/-- The original BigUint64Array iterable conversion retains each current
owned-handle note. Bounds come from native Live and both native counters, so
the real uint64 modulus cannot silently change a resource identifier. -/
theorem RetainedInventory.typedArray_handles_step
    (FR : Ren → Host.Load.LSt → Host.Load.LSt → Prop)
    {notes : RetainedNotes} {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren}
    {live framed : Nat → Prop} {before after : List Val} {old old' : List Event} {s₀ s : St Host.Load.LSt}
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' s₀ s)
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live s₀ s)
    {NodeRelation : Nat → Host.Mlx.Ffi.Node → Host.Mlx.Ffi.Node → Prop}
    {ObjectRelation : Nat → Host.Mlx.Ffi.Obj → Host.Mlx.Ffi.Obj → Prop} {H N : Nat → Prop} {tail : List NumV}
    (native : Host.Mlx.Ffi.NativeRoles.Live (NumberRoles ν₀ ν C₀ C) R NodeRelation ObjectRelation H N tail s₀.ffi.mlx s.ffi.mlx)
    (fn owner proto : Nat) (object : Obj) (newTarget : Val) (x y : F64) (metadata : NativeCaptureNote) (handles : List Nat)
    (control : s₀.ctl = .construct (.obj fn) [.obj owner] newTarget)
    (read : s₀.heap.get fn = some (.obj object))
    (kind : object.kind = .fn (.native (.buf .typedCtor) [.num (.lit x),.num (.lit y)]))
    (codeIndex : F64.toIndex? x = some 9) (protoIndex : F64.toIndex? y = some proto)
    (selected : notes.captures.owners fn = some metadata)
    (codeNote : metadata.roles 0 = some (.literal (.lit x)))
    (protoNote : metadata.roles 1 = some (.literal (.lit y)))
    (elements : notes.arrays.owners owner = some (handles.map Value.handle))
    (owned : listSupport H handles)
    (sourceHandles : s₀.ffi.mlx.next < 2^64) (targetHandles : s.ffi.mlx.next < 2^64)
    (bufferProtoLive : live aArrayBufferProto) (bufferProtoFixed : R.a aArrayBufferProto = aArrayBufferProto)
    (protoLive : live proto) (protoFixed : R.a proto = proto)
    (sourceBound : s₀.next+1 < 2^64) (targetBound : s.next+1 < 2^64) :
    let sourcePost := (newTyped Host.Load.ffi s₀ .u64 proto (cellBytes .u64 (handleArrayCells identity handles)) handles.length).2.ret (.obj (s₀.next+1))
    let targetPost := (newTyped Host.Load.ffi s .u64 proto (cellBytes .u64 (handleArrayCells R handles)) handles.length).2.ret (.obj (s.next+1))
    interpC (step Host.Load.ffi s₀).run C₀ = some (sourcePost,C₀) ∧
      interpC (step Host.Load.ffi s).run C = some (targetPost,C) ∧
      Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R (LiveAfter (LiveAfter live s₀.next) (s₀.next+1))
        framed before after old old' sourcePost targetPost ∧
      RetainedInventory (notes.typedBytes s₀.next (handleArrayBytes handles)) ν₀ ν C₀ C R
        (LiveAfter (LiveAfter live s₀.next) (s₀.next+1)) sourcePost targetPost := by
  dsimp only
  obtain ⟨sourceArray,targetArray,sourceValues,targetValues,sourceRead,sourceKind,targetRead,targetKind,sourceRoles,targetRoles,_⟩ :=
    inventory.arrays.selected owner (handles.map Value.handle) elements
  rw [handle_values_exact handles sourceValues sourceRoles] at sourceKind
  rw [handle_values_exact handles targetValues targetRoles] at targetKind
  have sourceBounds : listSupport (fun handle => identity.handle handle < 2^64) handles :=
    handles_supported_mono (fun handle held => Nat.lt_trans (native.liveHandleBound handle held) sourceHandles) handles owned
  have targetBounds : listSupport (fun handle => R.handle handle < 2^64) handles :=
    handles_supported_mono (fun handle held => Nat.lt_trans
      (native.handleMap.bound handle (native.liveHandleBound handle held)) targetHandles) handles owned
  have sourceConversion := cellsOf_u64_handles identity handles sourceBounds
  have targetConversion := cellsOf_u64_handles R handles targetBounds
  have codeRole := (inventory.captures.argument fn metadata selected 0 _ codeNote).2.2
  have protoRole := (inventory.captures.argument fn metadata selected 1 _ protoNote).2.2
  obtain ⟨targetFunction,data,targetNewTarget,args,targetControl,targetFunctionRead,targetFunctionKind,dataRole,_,argRole⟩ :=
    h.native_construct_view fn object (.buf .typedCtor) [.num (.lit x),.num (.lit y)] newTarget _ control read kind
  cases argRole with | cons argument rest =>
    cases rest
    cases argument
    cases dataRole with | cons code rest =>
      cases rest with | cons protoRole' rest =>
        cases rest
        have exactCode := fixed_literal_value codeRole
        have exactProto := fixed_literal_value protoRole
        simp only [nativeDataArgument,St.obj?,targetFunctionRead,targetFunctionKind,Host.Ts.arg,nthD] at exactCode exactProto
        rw [exactCode,exactProto] at targetFunctionKind
        have sourceRun := step_construct_u64_array_eq Host.Load.ffi s₀ fn owner proto object sourceArray newTarget x y _ _
          control read kind sourceRead sourceKind codeIndex protoIndex sourceConversion
        have targetRun := step_construct_u64_array_eq Host.Load.ffi s (R.a fn) (R.a owner) proto targetFunction targetArray targetNewTarget x y _ _
          targetControl targetFunctionRead targetFunctionKind targetRead targetKind codeIndex protoIndex targetConversion
        have sourceCount : len (handleArrayCells identity handles) = handles.length := by simp only [handleArrayCells,len_list_length,List.length_map]
        have targetCount : len (handleArrayCells R handles) = handles.length := by simp only [handleArrayCells,len_list_length,List.length_map]
        rw [sourceCount] at sourceRun
        rw [targetCount] at targetRun
        have post := h.newTyped_roles Host.Load.ffi (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' s₀ s
          .u64 proto handles.length _ _ (handle_array_bytes_paired handles) bufferProtoLive bufferProtoFixed protoLive protoFixed sourceBound targetBound
        refine ⟨?_,?_,post,inventory.newTyped_buffer Host.Load.ffi h.heap .u64 proto handles.length _ _ (handleArrayBytes handles)
          (handle_array_byte_roles ν₀ C₀ identity handles) (handle_array_byte_roles ν C R handles) sourceBound targetBound⟩
        · rw [sourceRun]; rfl
        · rw [targetRun]; rfl

end Host.Ts.Owned.Annotated
