import host.load.boundary.fill.Run
import host.load.boundary.fill.Geometry
import host.load.OraclePrefix
namespace Host.Load.Run.Full.Fill64
open Host.Ts Host.Load.Extract
set_option Elab.async false
set_option maxRecDepth 1000000

/-- The real 64-layer source method and subsequent sampler execute from the
explicit boundary entry, at any valuation matching the entry numeric table.
No future-entry reachability or incoming tensor contents are asserted here. -/
theorem fragment_execution (ρ : Nat → F64) (C : CSrv)
    (table : C.tab = S0.tab.map (SymE.eval ρ)) :
    ∃ C', runC Host.Load.ffi 1490133 entry C = some (s1491,C') ∧
      C'.tab = S1491.tab.map (SymE.eval ρ) := by
  exact Host.Load.OraclePrefix.concrete_prefix F ρ C Fill64.run (front := []) rfl table
    (by intro q hq; cases hq)

theorem method_execution (ρ : Nat → F64) (C : CSrv)
    (table : C.tab = S0.tab.map (SymE.eval ρ)) :
    ∃ C', runC Host.Load.ffi 1486246 entry C = some (s1487,C') ∧
      C'.tab = S1487.tab.map (SymE.eval ρ) := by
  exact Host.Load.OraclePrefix.concrete_prefix F ρ C prefixRun1487 (front := []) rfl table
    (by intro q hq; cases hq)
end Host.Load.Run.Full.Fill64
