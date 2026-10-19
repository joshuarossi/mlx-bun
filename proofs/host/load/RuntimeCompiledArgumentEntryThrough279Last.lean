import host.load.RuntimeCompiledArgumentEntryThrough279BigInt
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 2000000
namespace Host.Load.Run.Full.Ordinary.CompiledArgumentEntry
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated
namespace Through279Last
noncomputable def rules := ((From64.starts.zip From64.rules).filter (fun pair => 277 ≤ pair.1 ∧ pair.1 < 279)).map Prod.snd
end Through279Last
host_retained_theorem retained_from277_to279 := fun (notes : RetainedNotes)
    (role cellRole receiverRole : Annotated.Value)
    (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (FR : Ren → P.F.S → P.F.S → Prop) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s : St P.F.S)
    (inst : Inst ν₀ From64.Span244.Block277.initialServer C₀)
    (state : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' Region.s277 s)
    (inventory : RetainedInventory (Through277.notes notes role cellRole receiverRole) ν₀ ν C₀ C R live Region.s277 s) => by
  have control := through277_control notes role cellRole receiverRole
  have closed := through277_closed notes role cellRole receiverRole
  host_normalize_retained state, inventory
  host_retained_plan_chain P.F, Through279Last using state, inventory, inst
host_assert_retained_schema retained_from277_to279, 2
end Host.Load.Run.Full.Ordinary.CompiledArgumentEntry
