import host.ts.RenameLiteralI32Cells
import host.ts.RenameRetainedTypedAllocation

set_option Elab.async false
namespace Host.Ts.Owned.Annotated
open Parametric

theorem step_construct_i32_array_eq (F : Ffi) (s : St F.S) (fn owner proto : Nat) (object iterable : Obj)
    (newTarget : Val) (x y : F64) (values : List Val) (cells : List Host.Ts.Cell)
    (control : s.ctl = .construct (.obj fn) [.obj owner] newTarget)
    (read : s.heap.get fn = some (.obj object))
    (kind : object.kind = .fn (.native (.buf .typedCtor) [.num (.lit x),.num (.lit y)]))
    (iterableRead : s.heap.get owner = some (.obj iterable)) (iterableKind : iterable.kind = .array values)
    (codeIndex : F64.toIndex? x = some 4) (protoIndex : F64.toIndex? y = some proto)
    (conversion : cellsOf .i32 values = M.pure (some cells)) :
    step F s = M.pure ((newTyped F s .i32 proto (cellBytes .i32 cells) (len cells)).2.ret (.obj (s.next+1))) := by
  simp only [step,control,constructStep,St.obj?,read,kind,constructNative,bufN,codeIndex,protoIndex]
  obtain ⟨k,pr,props,priv,ext⟩ := iterable
  dsimp only at iterableKind
  subst k
  simp only [bufN.typedCtor,Host.Ts.arg,nthD,St.obj?,iterableRead,elemsOf,eltOfCode,retS]
  change M.bind (cellsOf .i32 values) _ = _
  rw [conversion]
  rfl

/-- Current array notes determine the literal operands on both sides. The
original signed-int32 conversion supplies the byte meanings; both allocations
retain all existing inventories and the whole-state native frame. -/
theorem RetainedInventory.typedArray_i32_literals_step (F : Ffi)
    (FR : Ren → F.S → F.S → Prop)
    {notes : RetainedNotes} {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren}
    {live framed : Nat → Prop} {before after : List Val} {old old' : List Event} {s₀ s : St F.S}
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' s₀ s)
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live s₀ s)
    (fn owner proto : Nat) (object : Obj) (newTarget : Val) (x y : F64)
    (metadata : NativeCaptureNote) (roles : List Value)
    (control : s₀.ctl = .construct (.obj fn) [.obj owner] newTarget)
    (read : s₀.heap.get fn = some (.obj object))
    (kind : object.kind = .fn (.native (.buf .typedCtor) [.num (.lit x),.num (.lit y)]))
    (codeIndex : F64.toIndex? x = some 4) (protoIndex : F64.toIndex? y = some proto)
    (selected : notes.captures.owners fn = some metadata)
    (codeNote : metadata.roles 0 = some (.literal (.lit x)))
    (protoNote : metadata.roles 1 = some (.literal (.lit y)))
    (elements : notes.arrays.owners owner = some roles)
    (literalRoles : roles = (literalArrayExpressions roles).map Value.literal)
    (bufferProtoLive : live aArrayBufferProto) (bufferProtoFixed : R.a aArrayBufferProto = aArrayBufferProto)
    (protoLive : live proto) (protoFixed : R.a proto = proto)
    (sourceBound : s₀.next+1 < 2^64) (targetBound : s.next+1 < 2^64) :
    let expressions := literalArrayExpressions roles
    let sourcePost := (newTyped F s₀ .i32 proto (cellBytes .i32 (literalI32Cells ν₀ expressions)) expressions.length).2.ret (.obj (s₀.next+1))
    let targetPost := (newTyped F s .i32 proto (cellBytes .i32 (literalI32Cells ν expressions)) expressions.length).2.ret (.obj (s.next+1))
    interpC (step F s₀).run C₀ = some (sourcePost,C₀) ∧
      interpC (step F s).run C = some (targetPost,C) ∧
      Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R (LiveAfter (LiveAfter live s₀.next) (s₀.next+1))
        framed before after old old' sourcePost targetPost ∧
      RetainedInventory (notes.typedBytes s₀.next (literalI32Bytes expressions)) ν₀ ν C₀ C R
        (LiveAfter (LiveAfter live s₀.next) (s₀.next+1)) sourcePost targetPost := by
  dsimp only
  let expressions := literalArrayExpressions roles
  obtain ⟨sourceArray,targetArray,sourceValues,targetValues,sourceRead,sourceKind,targetRead,targetKind,sourceRoles,targetRoles,_⟩ :=
    inventory.arrays.selected owner roles elements
  rw [literalRoles] at sourceRoles targetRoles
  rw [literal_array_values_exact expressions sourceValues sourceRoles] at sourceKind
  rw [literal_array_values_exact expressions targetValues targetRoles] at targetKind
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
        have sourceRun := step_construct_i32_array_eq F s₀ fn owner proto object sourceArray newTarget x y _ _
          control read kind sourceRead sourceKind codeIndex protoIndex (cellsOf_i32_literals ν₀ expressions)
        have targetRun := step_construct_i32_array_eq F s (R.a fn) (R.a owner) proto targetFunction targetArray targetNewTarget x y _ _
          targetControl targetFunctionRead targetFunctionKind targetRead targetKind codeIndex protoIndex (cellsOf_i32_literals ν expressions)
        have sourceCount : len (literalI32Cells ν₀ expressions) = expressions.length := by simp only [literalI32Cells,len_list_length,List.length_map]
        have targetCount : len (literalI32Cells ν expressions) = expressions.length := by simp only [literalI32Cells,len_list_length,List.length_map]
        rw [sourceCount] at sourceRun
        rw [targetCount] at targetRun
        have post := h.newTyped_roles F (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' s₀ s
          .i32 proto expressions.length _ _ (literal_i32_bytes_paired expressions) bufferProtoLive bufferProtoFixed protoLive protoFixed sourceBound targetBound
        refine ⟨?_,?_,post,inventory.newTyped_buffer F h.heap .i32 proto expressions.length _ _ (literalI32Bytes expressions)
          (literal_i32_byte_roles ν₀ C₀ identity expressions) (literal_i32_byte_roles ν C R expressions) sourceBound targetBound⟩
        · rw [sourceRun]; rfl
        · rw [targetRun]; rfl

end Host.Ts.Owned.Annotated
