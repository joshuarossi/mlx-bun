import host.load.RuntimePostCachedReturnCuts
import host.mlx.OrdinaryCachedStrongHost
import host.mlx.NativeAnnotationSupport

set_option Elab.async false
namespace Host.Load.Run.Full.Ordinary.PostCachedReturn
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated
open Host.Mlx.Ffi Host.Mlx.Ffi.NativeRoles Host.Mlx.Ffi.Annotated
open Host.Load.Run.Full.Ordinary.CachedCall
open Host.Load.Run.Full.Ordinary.CachedStrongHost

/-- The original vector-free branch retains its stores. Remove the released
input vector from the selected live handles, retaining the full node and
fixed object relations on every remaining resource. -/
def releasedHandles (H : Nat → Prop) (i : Nat) : Prop := H i ∧ i ≠ 29376

theorem release_native {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren}
    {base : Nat → GraphNode} {objects : Nat → Object} {H frame : Nat → Prop}
    {tail : List NumV} {host : HostSt → HostSt → Prop} {source target : LSt}
    (h : NativeRelation ν₀ ν C₀ C base (outputObjectRoles objects) H
      (fun i => N3 i ∨ frame i) tail host R source target) :
    NativeRelation ν₀ ν C₀ C base (outputObjectRoles objects) (releasedHandles H)
      (fun i => N3 i ∨ frame i) tail host R source target := by
  exact ⟨h.1,{h.2 with
    arrs := fun i selected => h.2.arrs i selected.1,
    objs := fun i selected => h.2.objs i selected.1,
    arrLive := fun i node selected read => h.2.arrLive i node selected.1 read,
    liveHandleBound := fun i selected => h.2.liveHandleBound i selected.1}⟩

theorem release_policy {base : Nat → GraphNode} {objects : Nat → Object}
    {roots H frame : Nat → Prop}
    (policy : ProducerAnnotations roots H (fun i => N3 i ∨ frame i)
      (roles (coupledRoles base)) (outputObjectRoles objects)) :
    ProducerAnnotations roots (releasedHandles H) (fun i => N3 i ∨ frame i)
      (roles (coupledRoles base)) (outputObjectRoles objects) :=
  ⟨fun i selected => policy.objects i selected.1,policy.roots,policy.nodes⟩

theorem input_released (H : Nat → Prop) : ¬ releasedHandles H 29376 :=
  fun selected => selected.2 rfl

theorem output_retained {H : Nat → Prop} (selected : H 29377) : releasedHandles H 29377 :=
  ⟨selected,by decide⟩


/-- Use the existing source-selected free adapter at 2408, then retire that
input vector from live support at this call boundary. Native stores retain the
original interpreter semantics; every remaining fixed annotation is framed. -/
theorem VectorFree2408.retained_release
    (notes : RetainedNotes) (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (base : Nat → GraphNode) (objects : Nat → Object) (H frame : Nat → Prop)
    (tail : List NumV) (host : HostSt → HostSt → Prop)
    (live framed : Nat → Prop) (before after : List Val) (old old' : List Event)
    (s : St P.F.S) (inst : Inst ν₀ VectorFree2408.initialServer C₀)
    (h : StateR (NumberRoles ν₀ ν C₀ C)
      (NativeRelation ν₀ ν C₀ C base (outputObjectRoles objects) H (fun i => N3 i ∨ frame i) tail host)
      R live framed before after old old' VectorFree2408.input s)
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live VectorFree2408.input s)
    (signatureFrame : ¬ framed VectorFree2408.types)
    (fnRole thisRole : Annotated.Value)
    (note : notes.runtime.control = callNote fnRole thisRole [.handle VectorFree2408.handle]) :
    ∃ result, interpC (step P.F VectorFree2408.input).run C₀ = some (VectorFree2408.output,C₀) ∧
      interpC (step P.F s).run C = some (result,C) ∧
      StateR (NumberRoles ν₀ ν C₀ C)
        (NativeRelation ν₀ ν C₀ C base (outputObjectRoles objects) (releasedHandles H)
          (fun i => N3 i ∨ frame i) tail host)
        R live framed before after old old' VectorFree2408.output result ∧
      RetainedInventory (notes.withRuntime ⟨returnNote nativeStatusRole,notes.runtime.stack,notes.runtime.cells⟩)
        ν₀ ν C₀ C R live VectorFree2408.output result ∧ result.ffi = s.ffi ∧
      Inst ν₀ VectorFree2408.nextServer C₀ := by
  obtain ⟨result,left,right,post,retained,ffi,inst'⟩ := VectorFree2408.retained_transport
    notes ν₀ ν C₀ C R _ live framed before after old old' s inst h inventory signatureFrame fnRole thisRole note
  exact ⟨result,left,right,StateR.mono (fun _ _ p => p) post (fun hn => release_native hn),retained,ffi,inst'⟩

end Host.Load.Run.Full.Ordinary.PostCachedReturn
