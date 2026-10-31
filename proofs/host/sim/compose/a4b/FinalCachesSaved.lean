import host.sim.compose.a4b.FinalCaches
import host.sim.template.SavedBindings
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option autoImplicit false
namespace Host.Ts.Sim.Compose
open _root_.Host.Ts _root_.Host.Ts.Sim _root_.Host.Ts.Sim.Full
open _root_.Host.Load.Layers _root_.Host.Mlx.SimGraph

/-- The actual saved boot environment discharges the cache-cell lookup without a premise. -/
noncomputable def DEC.finalPlain_savedCacheTpl (b0 : BSt) (NB : Nat) (q : List Val)
    (r : List NumV) (fw : List Val) (tail : List NumV) :
    FinalCacheTpl (fullProjFb b0 NB) terminalFixP DEC.inputs
      (entryEnv (_root_.Host.Load.Run.Prompt.P.at0 fw tail)) ((DEC.finalPlain b0 NB q).seg r) :=
  DEC.finalPlain_cacheTpl b0 NB q r _ (_root_.Host.Load.Run.Prompt.saved_cache fw tail)

noncomputable def DEC.finalClear0_savedCacheTpl (b0 : BSt) (NB : Nat) (q : List Val)
    (r : List NumV) (fw : List Val) (tail : List NumV) :
    FinalCacheTpl (fullProjFb b0 NB) terminalFixP DEC.inputs
      (entryEnv (_root_.Host.Load.Run.Prompt.P.at0 fw tail)) ((DEC.finalClear0 b0 NB q).seg r) :=
  DEC.finalClear0_cacheTpl b0 NB q r _ (_root_.Host.Load.Run.Prompt.saved_cache fw tail)

end Host.Ts.Sim.Compose
