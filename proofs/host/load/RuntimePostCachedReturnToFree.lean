import host.load.RuntimePostCachedReturnPlan

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

namespace Host.Load.Run.Full.Ordinary.PostCachedReturn
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated

/- Twenty-five host steps stop before vector-free dispatch. Current entry
cells fix the slot pointer and input vector, and the current buffer note fixes
the output handle. No native policy, support, or future-state premise is used. -/

theorem entry_state : From2383.s0 = P.RestStream.micro0.micro23.s83 := by
  host_kernel_rfl

host_retained_theorem retained_to_vector_free := fun (notes : RetainedNotes)
    (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (FR : Ren → P.F.S → P.F.S → Prop)
    (live framed : Nat → Prop) (before after : List Val) (old old' : List Event) (s : St P.F.S)
    (inst : Inst ν₀ BeforeFree.Block0.initialServer C₀)
    (h : StateR (NumberRoles ν₀ ν C₀ C) FR
      R live framed before after old old' From2383.s0 s)
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live From2383.s0 s)
    (budget : s.next+64 ≤ 2^64)
    (returned : Annotated.Value) (entryReturn : notes.runtime.control = returnNote returned)
    (slotPointer : notes.runtime.cells.cells 3126903 = some (.ptr (.js 3126924) 0))
    (inputVector : notes.runtime.cells.cells 3126901 = some (.handle 29376))
    (outputSlot : notes.buffers.owners 3126924 = some (handleSlotNotes 29377)) => by
  host_normalize_retained h, inventory
  host_retained_plan_chain P.F, BeforeFree using h, inventory, inst
host_assert_retained_schema retained_to_vector_free, 25

open Lean Elab Command in
run_cmd do
  for claim in [
      "host_assert_retained_schema retained_to_vector_free, 26",
      "theorem wrong_free_state : From2383.s25 = P.RestStream.micro0.micro24.s9 := by host_kernel_rfl"] do
    let saved : Lean.Elab.Command.State ← get
    let count := saved.messages.toList.length
    let mut rejected := false
    let mut seen := ""
    try
      Host.Ts.Owned.Parametric.Driver.emit claim
    catch exception =>
      let text ← exception.toMessageData.toString
      seen := text
      rejected := (text.splitOn "retained batch schema: target run has the wrong step count").length > 1
        || (text.splitOn "(kernel) declaration type mismatch").length > 1
    for message in (← get).messages.toList.drop count do
      let text ← message.data.toString
      seen := seen ++ text
      if (text.splitOn "retained batch schema: target run has the wrong step count").length > 1
          || (text.splitOn "(kernel) declaration type mismatch").length > 1 then
        rejected := true
    set saved
    unless rejected do throwError "post-cached prefix negative did not reach the intended rejection: {claim}\n{seen}"

end Host.Load.Run.Full.Ordinary.PostCachedReturn
