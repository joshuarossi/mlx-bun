import host.ts.renameOrdinary.RuntimeRetainedTen
import host.ts.RenameRetainedChain
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
namespace Host.Load.Run.Full.Ordinary.RetainedPrefix
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated
theorem automatic_ten (notes : RetainedNotes) (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (FR : Ren → P.F.S → P.F.S → Prop) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s : St P.F.S)
    (inst : Inst ν₀ (numberServer P.RestStream.micro0.micro0.S0) C₀)
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old'
      P.RestStream.micro0.micro0.s0 s)
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live P.RestStream.micro0.micro0.s0 s)
    (fnRole thisRole pointerRole : Annotated.Value) (tailNotes : List Annotated.Tree)
    (pointerEntry : notes.runtime.cells.cells Source0.address = some pointerRole)
    (rankEntry : notes.runtime.cells.cells Source5.address = some (.literal (.lit (F64.ofNat 3))))
    (stackNotes : notes.runtime.stack = argumentFrameNote false Source1.sourceKind fnRole thisRole []
      Source1.sourceRest Source1.sourceEnv::tailNotes) :
    ∃ result, runC P.F 10 s C = some (result,C) ∧
      Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old'
        P.RestStream.micro0.micro0.s10 result ∧
      RetainedInventory (notes.withRuntime {notes.runtime with control := (callNote fnRole thisRole
        [pointerRole,.literal (.lit (F64.ofNat 0)),
          .literal (.bin .mul (.lit (F64.ofNat 3)) (.lit (F64.ofNat 4)))]),stack := tailNotes})
        ν₀ ν C₀ C R live P.RestStream.micro0.micro0.s10 result ∧
      Inst ν₀ (numberServer P.RestStream.micro0.micro0.S10) C₀ := by
  host_retained_chain P.F, [Source0.retained_transport,Source1.retained_transport,Source2.retained_transport,Source3.retained_transport,Source4.retained_transport,Source5.retained_transport,Source6.retained_transport,Source7.retained_transport,Source8.retained_transport,Source9.retained_transport] using h, inventory, inst

host_retained_theorem automatic_inferred_ten := fun (notes : RetainedNotes) (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (FR : Ren → P.F.S → P.F.S → Prop) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s : St P.F.S)
    (inst : Inst ν₀ (numberServer P.RestStream.micro0.micro0.S0) C₀)
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old'
      P.RestStream.micro0.micro0.s0 s)
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live P.RestStream.micro0.micro0.s0 s)
    (fnRole thisRole pointerRole : Annotated.Value) (tailNotes : List Annotated.Tree)
    (pointerEntry : notes.runtime.cells.cells Source0.address = some pointerRole)
    (rankEntry : notes.runtime.cells.cells Source5.address = some (.literal (.lit (F64.ofNat 3))))
    (stackNotes : notes.runtime.stack = argumentFrameNote false Source1.sourceKind fnRole thisRole []
      Source1.sourceRest Source1.sourceEnv::tailNotes) => by
  host_retained_chain P.F, [Source0.retained_transport,Source1.retained_transport,Source2.retained_transport,Source3.retained_transport,Source4.retained_transport,Source5.retained_transport,Source6.retained_transport,Source7.retained_transport,Source8.retained_transport,Source9.retained_transport] using h, inventory, inst

open Lean Elab Command in
run_cmd do
  for (source,expected) in [("theorem missing_rank (notes : RetainedNotes) (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)\n    (FR : Ren → P.F.S → P.F.S → Prop) (live framed : Nat → Prop)\n    (before after : List Val) (old old' : List Event) (s : St P.F.S)\n    (inst : Inst ν₀ (numberServer P.RestStream.micro0.micro0.S0) C₀)\n    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old'\n      P.RestStream.micro0.micro0.s0 s)\n    (inventory : RetainedInventory notes ν₀ ν C₀ C R live P.RestStream.micro0.micro0.s0 s)\n    (fnRole thisRole pointerRole : Annotated.Value) (tailNotes : List Annotated.Tree)\n    (pointerEntry : notes.runtime.cells.cells Source0.address = some pointerRole)\n    (stackNotes : notes.runtime.stack = argumentFrameNote false Source1.sourceKind fnRole thisRole []\n      Source1.sourceRest Source1.sourceEnv::tailNotes) :\n    ∃ result, runC P.F 10 s C = some (result,C) ∧\n      Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old'\n        P.RestStream.micro0.micro0.s10 result ∧\n      RetainedInventory (notes.withRuntime {notes.runtime with control := (callNote fnRole thisRole\n        [pointerRole,.literal (.lit (F64.ofNat 0)),\n          .literal (.bin .mul (.lit (F64.ofNat 3)) (.lit (F64.ofNat 4)))]),stack := tailNotes})\n        ν₀ ν C₀ C R live P.RestStream.micro0.micro0.s10 result ∧\n      Inst ν₀ (numberServer P.RestStream.micro0.micro0.S10) C₀ := by\n  host_retained_chain P.F, [Source0.retained_transport,Source1.retained_transport,Source2.retained_transport,Source3.retained_transport,Source4.retained_transport,Source5.retained_transport,Source6.retained_transport,Source7.retained_transport,Source8.retained_transport,Source9.retained_transport] using h, inventory, inst","rule premises"),
("theorem wrong_endpoint (notes : RetainedNotes) (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)\n    (FR : Ren → P.F.S → P.F.S → Prop) (live framed : Nat → Prop)\n    (before after : List Val) (old old' : List Event) (s : St P.F.S)\n    (inst : Inst ν₀ (numberServer P.RestStream.micro0.micro0.S0) C₀)\n    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old'\n      P.RestStream.micro0.micro0.s0 s)\n    (inventory : RetainedInventory notes ν₀ ν C₀ C R live P.RestStream.micro0.micro0.s0 s)\n    (fnRole thisRole pointerRole : Annotated.Value) (tailNotes : List Annotated.Tree)\n    (pointerEntry : notes.runtime.cells.cells Source0.address = some pointerRole)\n    (rankEntry : notes.runtime.cells.cells Source5.address = some (.literal (.lit (F64.ofNat 3))))\n    (stackNotes : notes.runtime.stack = argumentFrameNote false Source1.sourceKind fnRole thisRole []\n      Source1.sourceRest Source1.sourceEnv::tailNotes) :\n    ∃ result, runC P.F 10 s C = some (result,C) ∧\n      Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old'\n        P.RestStream.micro0.micro0.s11 result ∧\n      RetainedInventory (notes.withRuntime {notes.runtime with control := (callNote fnRole thisRole\n        [pointerRole,.literal (.lit (F64.ofNat 0)),\n          .literal (.bin .mul (.lit (F64.ofNat 3)) (.lit (F64.ofNat 4)))]),stack := tailNotes})\n        ν₀ ν C₀ C R live P.RestStream.micro0.micro0.s11 result ∧\n      Inst ν₀ (numberServer P.RestStream.micro0.micro0.S10) C₀ := by\n  host_retained_chain P.F, [Source0.retained_transport,Source1.retained_transport,Source2.retained_transport,Source3.retained_transport,Source4.retained_transport,Source5.retained_transport,Source6.retained_transport,Source7.retained_transport,Source8.retained_transport,Source9.retained_transport] using h, inventory, inst","missing derived fact")] do
    let saved : Lean.Elab.Command.State ← get
    let mut rejected := false
    try
      Parametric.Driver.emit source
    catch exception =>
      let message ← exception.toMessageData.toString
      rejected := (message.splitOn expected).length > 1
    for message in (← get).messages.toList do
      let rendered ← message.data.toString
      if (rendered.splitOn expected).length > 1 then rejected := true
    set saved
    unless rejected do throwError "retained chain accepted missing initial role or incorrect endpoint"

open Lean Elab Command in
run_cmd do
  let saved : Lean.Elab.Command.State ← get
  let mut rejected := false
  try
    Parametric.Driver.emit "host_retained_theorem CannotProveData := (0 : Nat)"
  catch _ => rejected := true
  for message in (← get).messages.toList do
    let rendered ← message.data.toString
    if (rendered.splitOn "expected a closed proof").length > 1 then rejected := true
  let created := (← getEnv).contains ((← getCurrNamespace) ++ `CannotProveData)
  set saved
  unless rejected && !created do throwError "retained theorem command accepted data as a proof"
end Host.Load.Run.Full.Ordinary.RetainedPrefix
