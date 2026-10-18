import host.ts.RefScanElide
import host.ts.Source
set_option Elab.async false
set_option maxRecDepth 100000

namespace Host.Ts.RefScan.Tests

def module : Module := [
  .import_ [.named chars!"unused" chars!"unused"] chars!"other.ts",
  .stmt (.expr (.bin .add (.id chars!"x") (.id chars!"x"))),
  .exportNamed [(chars!"y", chars!"z")] none]

theorem ordered_duplicates : refsM module = [pack chars!"y", pack chars!"x", pack chars!"x"] :=
  completed module 32 ⟨[], [pack chars!"y", pack chars!"x", pack chars!"x"]⟩ rfl rfl

theorem exhaustion_marker : run 2 ⟨[.expr 0 (.id chars!"x")], []⟩ = ⟨[], [0]⟩ := rfl

theorem dropped_import_preserves_refs :
    refsM (elideItems [pack chars!"x", pack chars!"y"] module) = refsM module :=
  refsM_elideItems _ _

kernel_rfl removes_unused_import : elide module = some [
    .stmt (.expr (.bin .add (.id chars!"x") (.id chars!"x"))),
    .exportNamed [(chars!"y", chars!"z")] none]

end Host.Ts.RefScan.Tests
