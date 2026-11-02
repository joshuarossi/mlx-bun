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

/-- The memo's key `causal`: the mask a multi-row forward caches. Only some classes' first forwards create it, and no shared template holds it. -/
def causalKey : Nat := 85074607649212392847764531980401639532

theorem causalKey_pack : causalKey = pack ['c', 'a', 'u', 's', 'a', 'l'] := rfl

/-- The cells those frames act on: a wide frame only acts on a framed cell, so the memo is framed when it has ghost keys. -/
def framedOf (memo ghosts : List Nat) : List Nat := (match memo with | [] => [] | _ => [4910]) ++ ghosts

/-- The wide frames of a chain: the memo with its ghost keys, and those ghosts. -/
def wideListOf (memo ghosts : List Nat) : List (Nat × WFrame) := (4910, .memo memo) :: ghosts.map (fun a => (a, .ghost))

/-- Those frames as a function. -/
def wideOf (memo ghosts : List Nat) : Nat → Option WFrame := fun a => Disp.lookupW a (wideListOf memo ghosts)

/-- From the pre-final template. -/
abbrev wideListPf : List (Nat × WFrame) := wideListOf [causalKey] ghostPf
abbrev wideGPf : Nat → Option WFrame := wideOf [causalKey] ghostPf

/-- From POST's shared cut. -/
abbrev wideList : List (Nat × WFrame) := wideListOf [causalKey] ghostAddrs
abbrev wideG : Nat → Option WFrame := wideOf [causalKey] ghostAddrs

end Host.Load.Run.Tpl
