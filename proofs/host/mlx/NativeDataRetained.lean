import host.mlx.NativeDataHost
import host.mlx.NativeClosedArguments
import host.mlx.NativeSliceDynamicRetained
import host.mlx.NativeClosedShapeBuffer
import host.mlx.NativeAbsentObjectRoles
import host.ts.RenameRetainedHeapFrame

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

namespace Host.Mlx.Ffi.Annotated
open Host.Ts Host.Ts.Owned NativeRoles

theorem dataRole_subst (θ : Nat → SymE) (shape : List Dim) (dtype : Nat)
    (shapeRoles : Shape) (bytes : List Owned.Annotated.Byte) :
    (dataRole shape dtype shapeRoles bytes).subst θ =
      dataRole shape dtype (Shape.subst θ shapeRoles) (bytes.map (Owned.Annotated.Byte.subst θ)) := by
  cases geometry : natsOfDims shape <;>
    simp only [dataRole,GraphNode.subst,Option.map_some,Primitive.subst,dataCopy,geometry,List.map_take]

end Host.Mlx.Ffi.Annotated

namespace Host.Load.Run.Full.Ordinary.DataHost
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated
open Host.Mlx.Ffi Host.Mlx.Ffi.NativeRoles Host.Mlx.Ffi.Annotated

def dataArgumentNotes (dataBuffer shapeBuffer : Nat) (count dtype : Value) : List Value :=
  [.ptr (.js dataBuffer) 0,.ptr (.js shapeBuffer) 0,count,dtype]

private theorem data_arguments_fixed {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren}
    (dataBuffer shapeBuffer : Nat) (countArg dtypeArg : F64) (count dtype : Value)
    (countSchema : ClosedLiteralNote count) (dtypeSchema : ClosedLiteralNote dtype) (values : List Val)
    (source : ListR (fun role value => role.Holds ν₀ C₀ identity value) (dataArgumentNotes dataBuffer shapeBuffer count dtype)
      [.ptr (.js dataBuffer) 0,.ptr (.js shapeBuffer) 0,.num (.lit countArg),.num (.lit dtypeArg)])
    (target : ListR (fun role value => role.Holds ν C R value) (dataArgumentNotes dataBuffer shapeBuffer count dtype) values) :
    ListR (fun role value => role.role.Holds ν C R value) (arguments dataBuffer shapeBuffer countArg dtypeArg) values := by
  cases source with | cons _ h =>
    cases h with | cons _ h =>
      cases h with | cons cs h =>
        cases h with | cons ds h =>
          cases h
          cases target with | cons a h =>
            cases h with | cons b h =>
              cases h with | cons c h =>
                cases h with | cons d h =>
                  cases h
                  exact .cons a (.cons b (.cons (countSchema.exact cs c) (.cons (dtypeSchema.exact ds d) .nil)))

/-- Copied-data construction retains the selected payload's current byte
annotations, including varying integer/number meanings and the original
shape-dependent truncation. No payload value is selected afresh. -/
theorem retained_from_source {notes : RetainedNotes}
    (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (roles : Nat → GraphNode) (boundary : Nat → Prop) (objects : Nat → Object)
    (H N : Nat → Prop) (tail : List NumV) (host : HostSt → HostSt → Prop)
    (live framed : Nat → Prop) (before after : List Val) (old old' : List Event) (s₀ s : Host.Ts.St LSt)
    (h : StateR (NumberRoles ν₀ ν C₀ C) (VectorHost.NativeRelation ν₀ ν C₀ C roles boundary objects H N tail host)
      R live framed before after old old' s₀ s)
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live s₀ s)
    (fn types dataBuffer shapeBuffer dtype : Nat) (countArg dtypeArg : F64)
    (function signatureObject : Host.Ts.Obj) (returns : Name) (receiver : Val) (shape : List Int)
    (payload : List Host.Ts.Owned.Annotated.Byte)
    (control : s₀.ctl = .call (.obj fn) receiver [.ptr (.js dataBuffer) 0,.ptr (.js shapeBuffer) 0,.num (.lit countArg),.num (.lit dtypeArg)])
    (read : s₀.heap.get fn = some (.obj function))
    (functionKind : function.kind = .fn (.native (.ffi .symbol) [.str symbol,.obj types,.str returns]))
    (signatureRead : s₀.heap.get types = some (.obj signatureObject)) (signatureKind : signatureObject.kind = .array signature)
    (signatureFrame : ¬ framed types)
    (sourceShape : dimsArg (.jsPtr shapeBuffer 0 (shapeBytes (shape.map Dim.lit))) (.num (.lit countArg)) = some (shape.map Dim.lit))
    (sourceDtype : argNat (.num (.lit dtypeArg)) = some dtype)
    (countSame : F64.un .int32 countArg = countArg) (dtypeSame : F64.un .int32 dtypeArg = dtypeArg)
    (shapeExact : ExactDimensions shape)
    (sourceNodes : s₀.ffi.mlx.nnext < 2^64) (targetNodes : s.ffi.mlx.nnext < 2^64)
    (sourceHandles : s₀.ffi.mlx.next < 2^64) (targetHandles : s.ffi.mlx.next < 2^64)
    (roots : Nat → Prop) (policy : ProducerAnnotations roots H N roles objects)
    (fnRole thisRole countNote dtypeNote : Value) (countSchema : ClosedLiteralNote countNote) (dtypeSchema : ClosedLiteralNote dtypeNote)
    (note : notes.runtime.control = callNote fnRole thisRole (dataArgumentNotes dataBuffer shapeBuffer countNote dtypeNote))
    (selectedData : notes.buffers.owners dataBuffer = some payload)
    (selectedShape : notes.buffers.owners shapeBuffer = some (literalShapeByteNotes (constantExpressions shape))) :
    let newRoles := nodeWrite roles s₀.ffi.mlx.nnext (dataRole (shape.map Dim.lit) dtype (constantShape shape) payload)
    let newObjects := objectWrite objects s₀.ffi.mlx.next .stream
    let newH := fun a => a = s₀.ffi.mlx.next ∨ H a
    let newN := fun i => i = s₀.ffi.mlx.nnext ∨ N i
    ∃ sourcePost targetPost, interpC (step Host.Load.ffi s₀).run C₀ = some (sourcePost,C₀) ∧
      interpC (step Host.Load.ffi s).run C = some (targetPost,C) ∧
      StateR (NumberRoles ν₀ ν C₀ C) (VectorHost.NativeRelation ν₀ ν C₀ C newRoles boundary newObjects newH newN tail host)
        R live framed before after old old' sourcePost targetPost ∧
      RetainedInventory (notes.withRuntime {notes.runtime with control := returnNote (.handle s₀.ffi.mlx.next)})
        ν₀ ν C₀ C R live sourcePost targetPost ∧
      ProducerAnnotations roots newH newN newRoles newObjects ∧ ProducerSupport roots newH newN sourcePost.ffi.mlx := by
  dsimp only
  obtain ⟨dataObject,_,bytes₀,_,dataRead,dataKind,_,_,dataRoles,_⟩ := inventory.buffers.selected dataBuffer payload selectedData
  obtain ⟨shapeObject,targetShapeObject,shapeBytes₀,targetShapeBytes,shapeRead,shapeKind,targetShapeRead,targetShapeKind,shapeRoles,targetShapeRoles⟩ :=
    inventory.buffers.selected shapeBuffer _ selectedShape
  have sv₀ : LiteralDimensions ν₀ ((constantExpressions shape).map Dimension.literal) shape := by
    rw [constantExpressions_shape]; exact .constants ν₀ shape shapeExact
  have sv : LiteralDimensions ν ((constantExpressions shape).map Dimension.literal) shape := by
    rw [constantExpressions_shape]; exact .constants ν shape shapeExact
  have shapeBytesEq := literal_shape_bytes_exact _ _ _ sv₀ shapeRoles
  have targetShapeEq := literal_shape_bytes_exact _ _ _ sv targetShapeRoles
  have shapeKindFixed : shapeObject.kind = .buf ((fixedI32 shape).map FixedByte.value) := by
    rw [fixedI32_value]; exact shapeKind.trans (congrArg Kind.buf shapeBytesEq)
  have targetShapeFixed : (fixedBufferRole (fixedI32 shape)).Holds ν C R (objectKindAt s (R.a shapeBuffer)) := by
    simpa only [objectKindAt,Host.Ts.St.obj?,targetShapeRead,targetShapeKind,targetShapeEq,fixedI32_value] using
      fixedBuffer_holds ν C R (fixedI32 shape)
  have targetPayload : ListR (Host.Ts.Owned.Annotated.Byte.Holds ν C R) payload (ShapeBuffer.bytesAt s (R.a dataBuffer)) := by
    obtain ⟨object,bytes,read,kind,held⟩ := inventory.buffers.target dataBuffer payload selectedData
    simpa only [ShapeBuffer.bytesAt,Host.Ts.St.obj?,read,kind] using held
  obtain ⟨_,_,targetThis,targetArgs,targetControl,_,_,_,_,_⟩ := h.native_call_view fn function (.ffi .symbol) _ receiver _ control read functionKind
  have sourceCurrent := inventory.runtime.source.control
  rw [note,control] at sourceCurrent
  have targetCurrent := inventory.runtime.target.control
  rw [note,targetControl] at targetCurrent
  have argumentRoles := data_arguments_fixed dataBuffer shapeBuffer countArg dtypeArg countNote dtypeNote countSchema dtypeSchema targetArgs
    (callNote_view sourceCurrent).2.2 (callNote_view targetCurrent).2.2
  have argumentRoles' : ListR (fun role value => role.role.Holds ν C R value) (arguments dataBuffer shapeBuffer countArg dtypeArg) (callArguments s.ctl) := by
    simpa only [targetControl,callArguments] using argumentRoles
  obtain ⟨bytes,left,right,post⟩ := from_source ν₀ ν C₀ C R roles boundary objects H N tail host live framed before after old old' s₀ s h
    fn types dataBuffer shapeBuffer dtype countArg dtypeArg function signatureObject dataObject shapeObject returns receiver bytes₀
    (fixedI32 shape) (shape.map Dim.lit) (constantShape shape) payload control read functionKind signatureRead signatureKind
    dataRead dataKind shapeRead shapeKindFixed signatureFrame (by simpa only [fixedI32_value] using sourceShape) sourceDtype
    countSame dtypeSame ((LiteralDimensions.constants ν₀ shape shapeExact).holds C₀) ((LiteralDimensions.constants ν shape shapeExact).holds C)
    dataRoles targetPayload argumentRoles' targetShapeFixed sourceNodes targetNodes sourceHandles targetHandles
  let sourcePost := finishBig s₀ (resultWorld s₀.ffi (shape.map Dim.lit) dtype bytes₀) symbol
    (callArgs dataBuffer shapeBuffer bytes₀ ((fixedI32 shape).map FixedByte.value) countArg dtypeArg) (Int.ofNat s₀.ffi.mlx.next)
  let targetPost := finishBig s (resultWorld s.ffi (shape.map Dim.lit) dtype bytes) symbol
    (callArgs (R.a dataBuffer) (R.a shapeBuffer) bytes ((fixedI32 shape).map FixedByte.value) countArg dtypeArg) (Int.ofNat s.ffi.mlx.next)
  have targetReturn : (Value.handle s₀.ffi.mlx.next).Holds ν C R (.big (Int.ofNat s.ffi.mlx.next)) := by
    rw [←h.native.2.handleMap.head]; exact .handle _
  have runtime : RuntimeInventory {notes.runtime with control := returnNote (.handle s₀.ffi.mlx.next)} ν₀ ν C₀ C R live sourcePost targetPost :=
    ⟨inventory.runtime.keyLive,
      ⟨returnNote_holds (.handle _),inventory.runtime.source.stack,inventory.runtime.source.cells⟩,
      ⟨returnNote_holds targetReturn,inventory.runtime.target.stack,inventory.runtime.target.cells⟩⟩
  have retained := inventory.heap_step runtime rfl rfl (.refl C₀) (.refl C)
  have absent : sourcePost.ffi.mlx.objs.get s₀.ffi.mlx.next = none := h.native.2.source_fresh_obj (Nat.le_refl _)
  have nativePost := post.native.2.reannotate_absent_object s₀.ffi.mlx.next .stream absent
  have nativePair : VectorHost.NativeRelation ν₀ ν C₀ C
      (nodeWrite roles s₀.ffi.mlx.nnext (dataRole (shape.map Dim.lit) dtype (constantShape shape) payload)) boundary
      (objectWrite objects s₀.ffi.mlx.next .stream) (fun a => a = s₀.ffi.mlx.next ∨ H a)
      (fun i => i = s₀.ffi.mlx.nnext ∨ N i) tail host R sourcePost.ffi targetPost.ffi := ⟨post.native.1,nativePost⟩
  have updated := post.setFfi sourcePost.ffi targetPost.ffi nativePair
  have nodePolicy := policy.write_node s₀.ffi.mlx.nnext (dataRole (shape.map Dim.lit) dtype (constantShape shape) payload)
    (.data (dataCopy (shape.map Dim.lit) dtype payload)) [] rfl True.intro
  have newPolicy := nodePolicy.new_object s₀.ffi.mlx.next .stream True.intro
  exact ⟨sourcePost,targetPost,left,right,updated,retained,newPolicy,newPolicy.source nativePost⟩

end Host.Load.Run.Full.Ordinary.DataHost
