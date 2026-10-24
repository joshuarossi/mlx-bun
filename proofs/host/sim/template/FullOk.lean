import host.sim.full.StepX
import host.sim.full.Raise
import host.sim.full.BridgeStepD
import host.sim.LoadSim
namespace Host.Ts.Sim.Template
open Host.Ts Host.Ts.Sim Host.Load.Layers

/-! # The generated modules' acceptance function in the full stack

The full-world template streams are checked runs (`sim_chunk … okFull0`) with the dispatcher's `okJS` at
the full world's acceptance parameters with symbolic shapes, `Full.fullJSPX` (A1: `okCallFS`, `smallFSB`;
its one-step theorems `Full.fullStepSimX*`, `Full.fullJSPXStepSim`), at the template's native parameters
`loadP0` and value bound `loopVB`. This is the default of `fullWorld` (`okModule`, `okName`) and of
`gen.ts --world full` and `genStage.ts` (`fullJSP` with a stage's framed arrays). -/

/-- The acceptance parameters with framed arrays `framed`. -/
abbrev fullJSP (framed : List Nat) : Disp.JSP full := Full.fullJSPX loadP0 loopVB framed

/-- The acceptance parameters with framed arrays `framed` and wide frames `wide` (a site's or a class's under the
caller's: `Conv.isoCtxW`'s preimages). -/
abbrev fullJSPW (framed : List Nat) (wide : List (Nat × WFrame)) : Disp.JSP full := Full.fullJSPX loadP0 loopVB framed wide

/-- The acceptance parameters at load parameters `P` (a route chain's, from its start's counters), framed arrays and wide
frames. -/
abbrev fullJSPP (P : LoadP) (framed : List Nat) (wide : List (Nat × WFrame)) : Disp.JSP full := Full.fullJSPX P loopVB framed wide

/-- The acceptance parameters of a band-free chain (P.NL = P.N0): its calls also at the raise to the state's node counter
(`Full.okCallFSD`, A1's host.sim.full.Raise). -/
abbrev fullJSPPD (P : LoadP) (framed : List Nat) (wide : List (Nat × WFrame)) : Disp.JSP full := Full.fullJSPXD P loopVB framed wide

/-- The acceptance parameters of a chain whose Neural Engine bridge goes active (A1's host.sim.full.BridgeStepD: the calls at
`Full.okCallFXD`, the bridge's small steps). -/
abbrev fullJSPPX (P : LoadP) (framed : List Nat) (wide : List (Nat × WFrame)) : Disp.JSP full := Full.fullJSPXX P loopVB framed wide

/-- The acceptance function with the decode loop's framed arrays (noncomputable: it is only
evaluated by the kernel). -/
noncomputable def okFull0 : St full.S → SSrv → Bool := Disp.okJS (fullJSP [2673447, 12502])

end Host.Ts.Sim.Template
