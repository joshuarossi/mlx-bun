import host.mlx.OrdinaryVectorHost
import host.mlx.NativeAnnotationRebase

set_option Elab.async false

namespace Host.Load.Run.Full.Ordinary.VectorHost
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric
open Host.Mlx.Ffi Host.Mlx.Ffi.NativeRoles Host.Mlx.Ffi.Annotated

/-- Independent numeric decoder allocations retain all fixed graph,
configuration and callback-payload meanings in the complete native relation. -/
theorem NativeRelation.mono {ν₀ ν : Nat → F64} {C₀ C D₀ D : CSrv}
    {nodes : Nat → GraphNode} {boundary : Nat → Prop} {objects : Nat → Object}
    {H N : Nat → Prop} {tail : List NumV} {host : HostSt → HostSt → Prop}
    {R : Ren} {s₀ s : LSt}
    (h : NativeRelation ν₀ ν C₀ C nodes boundary objects H N tail host R s₀ s)
    (he₀ : TableExtends C₀ D₀) (he : TableExtends C D) :
    NativeRelation ν₀ ν D₀ D nodes boundary objects H N tail host R s₀ s :=
  ⟨h.1,h.2.mono (NumberRoles.mono he₀ he) (fun _ _ _ p => p.mono he₀ he) (fun _ _ _ p => p.mono he₀ he)⟩

theorem state_mono {ν₀ ν : Nat → F64} {C₀ C D₀ D : CSrv} {R : Ren}
    {nodes : Nat → GraphNode} {boundary : Nat → Prop} {objects : Nat → Object}
    {H N : Nat → Prop} {tail : List NumV} {host : HostSt → HostSt → Prop}
    {live framed : Nat → Prop} {before after : List Val} {old old' : List Event} {s₀ s : Host.Ts.St LSt}
    (h : StateR (NumberRoles ν₀ ν C₀ C) (NativeRelation ν₀ ν C₀ C nodes boundary objects H N tail host)
      R live framed before after old old' s₀ s)
    (he₀ : TableExtends C₀ D₀) (he : TableExtends C D) :
    StateR (NumberRoles ν₀ ν D₀ D) (NativeRelation ν₀ ν D₀ D nodes boundary objects H N tail host)
      R live framed before after old old' s₀ s :=
  h.mono (NumberRoles.mono he₀ he) (fun p => p.mono he₀ he)

end Host.Load.Run.Full.Ordinary.VectorHost
