import host.sim.template.EndGen
set_option Elab.async false

/-! # The cells no class's shared templates read

The classes share their templates from the pre-final cut on, but each class has created only the kernels its row counts used: lazily
filled closure variables, the Neural Engine's closures, and the compiled-function registry, which hold different things in different
classes. No step from a shared template on reads them (a read would be rejected: they are framed and wide). So they are `WFrame.ghost`. -/

namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim

/-- The kernels only some classes' first forwards create: `affineSplitMma`, `affine3Rows`, `affine4Rows`, `gateUpMmaWide`,
`gateUpCodebookMma`. From the pre-final template on. -/
def ghostPf : List Nat := [1824, 1834, 1852, 1993, 2001]

/-- With those, from POST's shared cut on: `_preciseSwigluClosure`, `_siluClosure`, `downK3InterleavedMmaWide`'s kernels and the trace
registry, which holds different closures per class but is not read once the sampler has compiled. -/
def ghostAddrs : List Nat := ghostPf ++ [1279, 1281, 1958, 1959, 4941]

/-- The wide frames from the pre-final template: the memo and its ghosts. -/
def wideListPf : List (Nat × WFrame) := (4910, .memo []) :: ghostPf.map (fun a => (a, .ghost))

def wideGPf : Nat → Option WFrame := fun a => Disp.lookupW a wideListPf

/-- The wide frames from POST's shared cut. -/
def wideList : List (Nat × WFrame) := (4910, .memo []) :: ghostAddrs.map (fun a => (a, .ghost))

/-- Those frames as a function. -/
def wideG : Nat → Option WFrame := fun a => Disp.lookupW a wideList

end Host.Load.Run.Tpl
