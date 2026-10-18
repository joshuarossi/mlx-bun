import host.mlx.NativeSymbol
import host.mlx.FixedNativeRoles
import host.mlx.NativeDtypeHost
import host.mlx.NativeConfigFreeHost
import host.ts.RenameRuntimeArguments

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

namespace Host.Ts.Owned.Annotated
open Parametric

private theorem fixed_list {ν : Nat → F64} {C : CSrv} {R : Ren} (arguments : List FixedArgument) :
    ∀ values, ListR (fun role value => role.Holds ν C R value) (arguments.map FixedArgument.role) values →
      ListR (fun argument value => argument.role.Holds ν C R value) arguments values := by
  induction arguments with
  | nil => intro values roles; cases roles; exact .nil
  | cons argument arguments ih =>
    intro values roles
    cases roles with
    | cons head rest => exact .cons head (ih _ rest)

/-- Native family argument premises come from the retained call note. No new
interpretation is selected at the FFI boundary or read from a future operand. -/
theorem RuntimeInventory.native_arguments {S : Type} {notes : RuntimeNotes} {ν₀ ν : Nat → F64}
    {C₀ C : CSrv} {R : Ren} {live : Nat → Prop} {s₀ s : St S}
    (inventory : RuntimeInventory notes ν₀ ν C₀ C R live s₀ s)
    (fnRole thisRole : Value) (arguments : List FixedArgument) (fn this : Val) (args : List Val)
    (control : s₀.ctl = .call fn this args)
    (note : notes.control = callNote fnRole thisRole (arguments.map FixedArgument.role)) :
    ListR (fun argument value => argument.role.Holds ν₀ C₀ identity value) arguments (callArguments s₀.ctl) ∧
    ListR (fun argument value => argument.role.Holds ν C R value) arguments (callArguments s.ctl) := by
  have sourceNotes := inventory.source.control
  rw [note,control] at sourceNotes
  have source := fixed_list arguments args (callNote_view sourceNotes).2.2
  have paired := inventory.control_pair
  rw [control] at paired
  obtain ⟨targetFn,targetThis,targetArgs,targetControl,_,_,_⟩ := paired.call_view
  have targetNotes := inventory.target.control
  rw [note,targetControl] at targetNotes
  have target := fixed_list arguments targetArgs (callNote_view targetNotes).2.2
  simpa only [control,targetControl,callArguments] using And.intro source target

def nativeStatusRole : Value := .literal (.lit (F64.zero false))

theorem nativeStatusRole_holds (ν : Nat → F64) (C : CSrv) (R : Ren) :
    nativeStatusRole.Holds ν C R (.num zeroN) := .literal _ _ rfl

/-- No-write native status returns preserve every saved frame/cell note and
install the fixed literal zero return role. -/
theorem RuntimeInventory.finishStatus {S : Type} {notes : RuntimeNotes} {ν₀ ν : Nat → F64}
    {C₀ C : CSrv} {R : Ren} {live : Nat → Prop} {s₀ s : St S}
    (inventory : RuntimeInventory notes ν₀ ν C₀ C R live s₀ s)
    (native₀ native : S) (name : Name) (args₀ args : List Arg) :
    RuntimeInventory {notes with control := returnNote nativeStatusRole} ν₀ ν C₀ C R live
      (finishStatus s₀ native₀ name args₀) (finishStatus s native name args) :=
  ⟨inventory.keyLive,⟨returnNote_holds (nativeStatusRole_holds ν₀ C₀ identity),inventory.source.stack,inventory.source.cells⟩,
    ⟨returnNote_holds (nativeStatusRole_holds ν C R),inventory.target.stack,inventory.target.cells⟩⟩

theorem RuntimeInventory.finishBig_role {S : Type} {notes : RuntimeNotes} {ν₀ ν : Nat → F64}
    {C₀ C : CSrv} {R : Ren} {live : Nat → Prop} {s₀ s : St S}
    (inventory : RuntimeInventory notes ν₀ ν C₀ C R live s₀ s)
    (native₀ native : S) (name : Name) (args₀ args : List Arg) (value₀ value : Int) (role : Value)
    (source : role.Holds ν₀ C₀ identity (.big value₀)) (target : role.Holds ν C R (.big value)) :
    RuntimeInventory {notes with control := returnNote role} ν₀ ν C₀ C R live
      (finishBig s₀ native₀ name args₀ value₀) (finishBig s native name args value) :=
  ⟨inventory.keyLive,⟨returnNote_holds source,inventory.source.stack,inventory.source.cells⟩,
    ⟨returnNote_holds target,inventory.target.stack,inventory.target.cells⟩⟩

theorem RuntimeInventory.finishBig_constant {S : Type} {notes : RuntimeNotes} {ν₀ ν : Nat → F64}
    {C₀ C : CSrv} {R : Ren} {live : Nat → Prop} {s₀ s : St S}
    (inventory : RuntimeInventory notes ν₀ ν C₀ C R live s₀ s)
    (native₀ native : S) (name : Name) (args₀ args : List Arg) (value : Int) :
    RuntimeInventory {notes with control := returnNote (.ordinaryBig value)} ν₀ ν C₀ C R live
      (finishBig s₀ native₀ name args₀ value) (finishBig s native name args value) :=
  inventory.finishBig_role native₀ native name args₀ args value value (.ordinaryBig value) (.ordinaryBig value) (.ordinaryBig value)

/-- Native factory return handles are annotated from the current resource
counter relation. No target return role or post-counter relation is a premise. -/
theorem RuntimeInventory.finishBig_fresh_handle {notes : RuntimeNotes} {ν₀ ν : Nat → F64}
    {C₀ C : CSrv} {R : Ren} {live : Nat → Prop} {s₀ s : St Host.Load.LSt}
    (inventory : RuntimeInventory notes ν₀ ν C₀ C R live s₀ s)
    {NR : NumV → NumV → Prop} {NodeRel : Nat → Host.Mlx.Ffi.Node → Host.Mlx.Ffi.Node → Prop}
    {ObjRel : Nat → Host.Mlx.Ffi.Obj → Host.Mlx.Ffi.Obj → Prop} {H N : Nat → Prop} {tail : List NumV}
    (nativeRelation : Host.Mlx.Ffi.NativeRoles.Live NR R NodeRel ObjRel H N tail s₀.ffi.mlx s.ffi.mlx)
    (native₀ native : Host.Load.LSt) (name : Name) (args₀ args : List Arg) :
    RuntimeInventory {notes with control := returnNote (.handle s₀.ffi.mlx.next)} ν₀ ν C₀ C R live
      (finishBig s₀ native₀ name args₀ (Int.ofNat s₀.ffi.mlx.next))
      (finishBig s native name args (Int.ofNat s.ffi.mlx.next)) := by
  apply inventory.finishBig_role native₀ native name args₀ args _ _ (.handle s₀.ffi.mlx.next)
  · exact .handle _
  · rw [← nativeRelation.handleMap.head]
    exact .handle _

theorem RuntimeInventory.finishBig_pointer {S : Type} {notes : RuntimeNotes} {ν₀ ν : Nat → F64}
    {C₀ C : CSrv} {R : Ren} {live : Nat → Prop} {s₀ s : St S}
    (inventory : RuntimeInventory notes ν₀ ν C₀ C R live s₀ s)
    (native₀ native : S) (name : Name) (args₀ args : List Arg) (memory : Mem) (off : Nat) :
    RuntimeInventory {notes with control := returnNote (.pointerInteger memory off)} ν₀ ν C₀ C R live
      (finishBig s₀ native₀ name args₀ (ptrInt memory off))
      (finishBig s native name args (ptrInt (R.mem memory) off)) := by
  apply inventory.finishBig_role native₀ native name args₀ args _ _ (.pointerInteger memory off)
  · cases memory <;> exact .pointerInteger _ _
  · exact .pointerInteger _ _

/-- Dtype codes and other fixed literal numeric returns keep the stronger
literal representation used by later enum/ABI decoding. -/
theorem RuntimeInventory.finishNumber_literal {S : Type} {notes : RuntimeNotes} {ν₀ ν : Nat → F64}
    {C₀ C : CSrv} {R : Ren} {live : Nat → Prop} {s₀ s : St S}
    (inventory : RuntimeInventory notes ν₀ ν C₀ C R live s₀ s)
    (native₀ native : S) (name : Name) (args₀ args : List Arg) (value : F64) :
    RuntimeInventory {notes with control := returnNote (.literal (.lit value))} ν₀ ν C₀ C R live
      (finishNumber s₀ native₀ name args₀ (.lit value)) (finishNumber s native name args (.lit value)) :=
  ⟨inventory.keyLive,⟨returnNote_holds (.literal _ _ rfl),inventory.source.stack,inventory.source.cells⟩,
    ⟨returnNote_holds (.literal _ _ rfl),inventory.target.stack,inventory.target.cells⟩⟩

theorem RuntimeInventory.finishVoid {S : Type} {notes : RuntimeNotes} {ν₀ ν : Nat → F64}
    {C₀ C : CSrv} {R : Ren} {live : Nat → Prop} {s₀ s : St S}
    (inventory : RuntimeInventory notes ν₀ ν C₀ C R live s₀ s)
    (native₀ native : S) (name : Name) (args₀ args : List Arg) :
    RuntimeInventory {notes with control := returnNote .undef} ν₀ ν C₀ C R live
      (finishVoid s₀ native₀ name args₀) (finishVoid s native name args) :=
  ⟨inventory.keyLive,⟨returnNote_holds .undef,inventory.source.stack,inventory.source.cells⟩,
    ⟨returnNote_holds .undef,inventory.target.stack,inventory.target.cells⟩⟩

end Host.Ts.Owned.Annotated
