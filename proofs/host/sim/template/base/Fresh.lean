import host.sim.template.base.Closed
import host.sim.BigFree
import host.sim.native.RebigR
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

/-! The template start mentions no bigint in its fresh handle range
`[Base.s0.ffi.mlx.next, 131072)`, so the restart may reassign their images
(`Rel.rebig`). Kernel evaluation block by block over the heap. -/

kernel_rfl Base.hnext : Base.s0.aux.ffi.mlx.next = 29302

noncomputable def Base.freshAt (a : Nat) : Bool := noBigAtB 29302 131072 Base.s0 a

tpl_all_blocks Base.FB from Base : Base.freshAt
kernel_rfl Base.freshFramed : framedList.all Base.freshAt = true
kernel_rfl Base.freshRoots : noBigRootsB 29302 131072 Base.s0.trace Base.s0 = true

-- The native state references no handle in the fresh range.
kernel_rfl Base.nativeFresh : bigsOutB 29302 131072 Base.s0.aux.ffi.mlx = true

theorem Base.noBigFresh : NoBigSt (fun i => (29302 : Int) ≤ i ∧ i < 131072) Base.s0.trace Base.s0 :=
  NoBigSt.of_checks (fun a ha => Base.allPresent Base.FB.all Base.freshFramed a ha) Base.freshRoots

end Host.Load.Run.Tpl
