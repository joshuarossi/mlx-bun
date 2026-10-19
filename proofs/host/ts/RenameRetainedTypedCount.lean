import host.ts.RenameRetainedTypedAllocation
import host.ts.RenameParametricArrayBuffer
import host.ts.RenameRuntimeArguments
set_option Elab.async false
namespace Host.Ts.Owned.Annotated
open Parametric

def zeroByteNotes : Nat → List Annotated.Byte
  | 0 => []
  | n+1 => .lit 0 :: zeroByteNotes n

theorem zero_byte_roles (ν : Nat → F64) (C : CSrv) (R : Ren) (n : Nat) :
    ListR (fun role byte => role.Holds ν C R byte) (zeroByteNotes n) (zeroBytes n) := by
  induction n with
  | zero => exact .nil
  | succ n ih => exact .cons (.lit 0) ih

theorem zero_bytes_paired (NR : NumV → NumV → Prop) (R : Ren) (n : Nat) :
    ListR (Parametric.ByteR NR R) (zeroBytes n) (zeroBytes n) := by
  induction n with
  | zero => exact .nil
  | succ n ih => exact .cons (.lit 0) ih

theorem step_construct_typed_count_eq (F : Ffi) (s : St F.S) (fn code proto count : Nat)
    (object : Obj) (newTarget : Val) (x y z : F64)
    (control : s.ctl = .construct (.obj fn) [.num (.lit z)] newTarget)
    (read : s.heap.get fn = some (.obj object))
    (kind : object.kind = .fn (.native (.buf .typedCtor) [.num (.lit x),.num (.lit y)]))
    (codeIndex : F64.toIndex? x = some code) (protoIndex : F64.toIndex? y = some proto)
    (countIndex : F64.toIndex? z = some count) :
    step F s = M.pure ((newTyped F s (eltOfCode code) proto
      (zeroBytes (count * (eltOfCode code).size)) count).2.ret (.obj (s.next+1))) := by
  simp only [step,control,constructStep,St.obj?,read,kind,constructNative,bufN,codeIndex,protoIndex,
    bufN.typedCtor,Host.Ts.arg,nthD,countIndex,retS]
  rfl

/-- The current constructor control supplies the exact literal length. Native
capture notes supply the element code and prototype. Both original allocations
preserve the whole native frame and all six retained inventories. -/
theorem RetainedInventory.typed_count_step (F : Ffi) (FR : Ren → F.S → F.S → Prop)
    {notes : RetainedNotes} {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren}
    {live framed : Nat → Prop} {before after : List Val} {old old' : List Event} {s₀ s : St F.S}
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' s₀ s)
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live s₀ s)
    (fn code proto count : Nat) (object : Obj) (newTarget : Val) (x y z : F64)
    (metadata : NativeCaptureNote) (fnRole : Annotated.Value)
    (control : s₀.ctl = .construct (.obj fn) [.num (.lit z)] newTarget)
    (read : s₀.heap.get fn = some (.obj object))
    (kind : object.kind = .fn (.native (.buf .typedCtor) [.num (.lit x),.num (.lit y)]))
    (codeIndex : F64.toIndex? x = some code) (protoIndex : F64.toIndex? y = some proto)
    (countIndex : F64.toIndex? z = some count)
    (selected : notes.captures.owners fn = some metadata)
    (codeNote : metadata.roles 0 = some (.literal (.lit x)))
    (protoNote : metadata.roles 1 = some (.literal (.lit y)))
    (controlNote : notes.runtime.control = constructNote fnRole [.literal (.lit z)])
    (bufferProtoLive : live aArrayBufferProto) (bufferProtoFixed : R.a aArrayBufferProto = aArrayBufferProto)
    (protoLive : live proto) (protoFixed : R.a proto = proto)
    (sourceBound : s₀.next+1 < 2^64) (targetBound : s.next+1 < 2^64) :
    let bytes := zeroBytes (count * (eltOfCode code).size)
    let sourcePost := (newTyped F s₀ (eltOfCode code) proto bytes count).2.ret (.obj (s₀.next+1))
    let targetPost := (newTyped F s (eltOfCode code) proto bytes count).2.ret (.obj (s.next+1))
    interpC (step F s₀).run C₀ = some (sourcePost,C₀) ∧
      interpC (step F s).run C = some (targetPost,C) ∧
      Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R (LiveAfter (LiveAfter live s₀.next) (s₀.next+1))
        framed before after old old' sourcePost targetPost ∧
      RetainedInventory (notes.typedBytes s₀.next (zeroByteNotes (count * (eltOfCode code).size)))
        ν₀ ν C₀ C R (LiveAfter (LiveAfter live s₀.next) (s₀.next+1)) sourcePost targetPost := by
  dsimp only
  have codeRole := (inventory.captures.argument fn metadata selected 0 _ codeNote).2.2
  have protoRole := (inventory.captures.argument fn metadata selected 1 _ protoNote).2.2
  obtain ⟨targetFunction,data,targetNewTarget,args,targetControl,targetRead,targetKind,dataRole,_,argRole⟩ :=
    h.native_construct_view fn object (.buf .typedCtor) [.num (.lit x),.num (.lit y)] newTarget _ control read kind
  have annotatedControl := inventory.runtime.target.control
  rw [controlNote,targetControl] at annotatedControl
  have arguments := (constructNote_view annotatedControl).2.2
  cases arguments with | cons argument rest =>
    cases rest
    have exactCount := fixed_literal_value argument
    rw [exactCount] at targetControl
    cases dataRole with | cons codeRole' rest =>
      cases rest with | cons protoRole' rest =>
        cases rest
        have exactCode := fixed_literal_value codeRole
        have exactProto := fixed_literal_value protoRole
        simp only [nativeDataArgument,St.obj?,targetRead,targetKind,Host.Ts.arg,nthD] at exactCode exactProto
        rw [exactCode,exactProto] at targetKind
        have sourceRun := step_construct_typed_count_eq F s₀ fn code proto count object newTarget x y z
          control read kind codeIndex protoIndex countIndex
        have targetRun := step_construct_typed_count_eq F s (R.a fn) code proto count targetFunction targetNewTarget x y z
          targetControl targetRead targetKind codeIndex protoIndex countIndex
        refine ⟨?_,?_,h.newTyped_roles F _ FR R live framed before after old old' s₀ s
          (eltOfCode code) proto count _ _ (zero_bytes_paired _ _ _) bufferProtoLive bufferProtoFixed
          protoLive protoFixed sourceBound targetBound,
          inventory.newTyped_buffer F h.heap (eltOfCode code) proto count _ _ _
            (zero_byte_roles ν₀ C₀ identity _) (zero_byte_roles ν C R _) sourceBound targetBound⟩
        · rw [sourceRun]; rfl
        · rw [targetRun]; rfl

end Host.Ts.Owned.Annotated
