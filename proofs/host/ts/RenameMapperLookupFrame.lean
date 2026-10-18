import host.ts.RenameLookupFrame
import host.ts.RenameRetainedMapperBody
set_option Elab.async false
namespace Host.Ts.Owned.Annotated
open Parametric

/-- The first actual callback argument is live before any mapper allocation. -/
theorem mapper_owner_live
    {S : Type} {NR : NumV → NumV → Prop} {FR : Ren → S → S → Prop} {R : Ren}
    {live framed : Nat → Prop} {before after : List Val} {old old' : List Event}
    {source target : St S}
    (h : Parametric.StateR NR FR R live framed before after old old' source target)
    (callee owner : Nat) (receiver : Val) (extraArgs : List Val)
    (control : source.ctl = .call (.obj callee) receiver (.obj owner::extraArgs)) : live owner := by
  have support := h.controlLive
  rw [control] at support
  exact (vals_support_of _ support.2.2.1).1

/-- Receiver evaluation only allocates and initializes the fresh parameter
cell. The original owning object and its whole ordinary prototype path remain
available from their entry metadata and the initial heap-closure invariant. -/
theorem mapper_receiver_lookup
    {S : Type} {NR : NumV → NumV → Prop} {FR : Ren → S → S → Prop} {R : Ren}
    {live framed : Nat → Prop} {before after : List Val} {old old' : List Event}
    {source target : St S}
    (h : Parametric.StateR NR FR R live framed before after old old' source target)
    (callee owner : Nat) (receiver : Val) (extraArgs : List Val)
    (env : Env) (name field : Name) (property : Option PropV)
    (control : source.ctl = .call (.obj callee) receiver (.obj owner::extraArgs))
    (bound : source.next < 2^64)
    (path : OrdinaryLookup source field 16 owner property) :
    OrdinaryLookup (mapperReceiverSource source env name field receiver owner extraArgs) field 16 owner property := by
  apply path.frame_live h.heap
  · intro a alive
    exact mapper_entry_heap_below source env name field receiver owner extraArgs bound a (h.heap.sourceBound a alive)
  · exact mapper_owner_live h callee owner receiver extraArgs control

end Host.Ts.Owned.Annotated
