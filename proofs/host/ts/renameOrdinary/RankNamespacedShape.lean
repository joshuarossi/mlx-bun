import host.ts.renameOrdinary.RankShapeRetained
import host.load.RuntimeNamespacedPrefix
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
namespace Host.Load.Run.Full.Ordinary.RankNamespacedShape
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated
open RankOrigin RankShapeRetained

theorem entry_server : (numberServer P.micro3275.S1).substitute LoopVariables.oracleVariables = NamespacedPrefix.Source0.initialServer := by
  change (numberServer P.micro3275.S1).substitute LoopVariables.oracleVariables =
    (numberServer P.RestStream.micro0.micro0.S0).substitute LoopVariables.oracleVariables
  exact congrArg (fun server => server.substitute LoopVariables.oracleVariables) entry_number_server

theorem enter_and_shape (FR : Ren → LSt → LSt → Prop) (R : Ren) (ν₀ ν : Nat → F64)
    (C₀ C : CSrv) (live framed : Nat → Prop) (before after : List Val) (old old' : List Event)
    (s : St LSt) (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' RankOrigin.input s)
    (inst : Inst ν₀ ((numberServer P.micro3275.S1).substitute LoopVariables.oracleVariables) C₀)
    (notes : RetainedNotes) (inventory : RetainedInventory notes ν₀ ν C₀ C R live RankOrigin.input s)
    (rankAbsent : notes.runtime.cells.cells Variable5.address = none)
    (pointerAbsent : notes.runtime.cells.cells PointerBinding48.sourceAddress = none)
    (metadata : NativeCaptureNote) (selected : notes.captures.owners 90 = some metadata)
    (codeNote : metadata.roles 0 = some (.literal (.lit (F64.ofNat 4))))
    (protoNote : metadata.roles 1 = some (.literal (.lit (F64.ofNat 21))))
    (roles : Nat → Host.Mlx.Ffi.Annotated.GraphNode)
    (ObjRel : Nat → Host.Mlx.Ffi.Obj → Host.Mlx.Ffi.Obj → Prop)
    (boundary H N : Nat → Prop) (tail : List NumV)
    (native : Host.Mlx.Ffi.NativeRoles.Live (NumberRoles ν₀ ν C₀ C) R
      (Host.Mlx.Ffi.Annotated.NodeRel roles ν₀ ν C₀ C R boundary) ObjRel H N tail RankOrigin.input.ffi.mlx s.ffi.mlx)
    (rankSignature : ¬ framed signature) (shapeSignature : ¬ framed ShapeNative.signature) (handleLive : H 29363)
    (handleRole : (Annotated.Value.handle 29363).Holds ν C R (callArgument s.ctl 0))
    (field : PrivateData s (R.a Handle40.sourceAddress) (R.a Handle40.sourceBrand)
      Handle40.sourceName (.big (Int.ofNat (R.handle 29363))))
    (region : R.region (4*29363) = 4*R.handle 29363)
    (bound : s.next + 5 + (paramNames EnterGetter28.sourceFunction).length ≤ 2^64)
    (globalLive : live aGlobal) (globalFixed : R.a aGlobal = aGlobal)
    (arrayBufferLive : live aArrayBufferProto) (arrayBufferFixed : R.a aArrayBufferProto = aArrayBufferProto)
    (typedLive : live 21) (typedFixed : R.a 21 = 21)
    (arrayLive : live aArrayProto) (arrayFixed : R.a aArrayProto = aArrayProto) :
    ∃ (result : St LSt) (control : Annotated.Tree) (fnRole thisRole : Annotated.Value)
        (saved : Annotated.Tree) (caller : List Annotated.Tree),
      runC P.F 72 s C = some (result,C) ∧
      Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R (RetainedShapePrefix.EndLive (GetterLive live))
        framed before after old old' P.RestStream.micro0.micro0.s14 result ∧
      RetainedInventory (RetainedShapePrefix.EndNotes (EntryNotes notes control fnRole thisRole saved caller)
        caller (roles 22582).shape.valueRoles) ν₀ ν C₀ C R (RetainedShapePrefix.EndLive (GetterLive live))
        P.RestStream.micro0.micro0.s14 result ∧ Inst ν₀ NamespacedPrefix.Source13.nextServer C₀ := by
  let NR := NumberRoles ν₀ ν C₀ C
  let GR : Ren → LSt → LSt → Prop := fun Q x y => FR Q x y ∧
    Host.Mlx.Ffi.NativeRoles.Live NR Q (Host.Mlx.Ffi.Annotated.NodeRel roles ν₀ ν C₀ C Q boundary)
      ObjRel H N tail x.mlx y.mlx
  have related : Parametric.StateR NR GR R live framed before after old old' RankOrigin.input s :=
    ⟨h.heap,h.control,h.controlLive,h.stack,h.stackLive,h.jobs,h.jobsLive,h.stores,h.storesLive,⟨h.native,native⟩,h.trace⟩
  obtain ⟨entry,r58,h58,rank,_,frame⟩ := initialize_shape_entry GR R ν₀ ν C₀ C live framed before after old old' s related
    (Host.Mlx.Ffi.Annotated.NodeRel roles ν₀ ν C₀ C R boundary) ObjRel H N tail native
    (fun _ _ _ node => node.base.shape) rankSignature shapeSignature handleLive handleRole field region (by omega) globalLive globalFixed
  obtain ⟨cells,privates,captures,arrayContents,publics,buffers⟩ := inventories_frame related inventory rankAbsent pointerAbsent frame
  obtain ⟨control,fnRole,thisRole,saved,caller,seeded⟩ := RetainedSeed.pair_seed GR R ν₀ ν C₀ C (GetterLive live)
    framed before after old old' entry h58 notes.runtime.cells notes.privates notes.captures notes.arrays notes.publicFields notes.buffers
    cells privates captures arrayContents publics buffers rank
  have grow : ∀ a, live a → GetterLive live a := ClosureLive.grow live EnterGetter28.input.next
    EnterGetter28.sourceArrow EnterGetter28.sourceHome EnterGetter28.sourceFunction
  have next : entry.next = s.next+2 := related.target_next_add h58 2 entry_next
  obtain ⟨result,r14,h14,i14,q14⟩ := NamespacedPrefix.first_fourteen
    (EntryNotes notes control fnRole thisRole saved caller) ν₀ ν C₀ C R GR (GetterLive live) framed before after old old' entry
    (entry_server ▸ inst) h58 seeded fnRole thisRole RetainedSeed.pointerRole saved caller
    (RetainedSeed.pointer_entry _) (RetainedSeed.rank_entry _) rfl metadata selected codeNote protoNote
    roles ObjRel boundary H N tail h58.native.2 handleLive region
    (grow _ arrayBufferLive) arrayBufferFixed (grow _ typedLive) typedFixed (grow _ arrayLive) arrayFixed
    (by rw [next]; omega)
  exact ⟨result,control,fnRole,thisRole,saved,caller,runC_join P.F (m:=58) (n:=14) r58 r14,
    h14.native_map (fun _ _ _ held => held.1),i14,q14⟩
end Host.Load.Run.Full.Ordinary.RankNamespacedShape
