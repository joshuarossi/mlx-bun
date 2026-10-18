import host.ts.RefScanCommand
import host.ts.Source

set_option Elab.async false
set_option maxRecDepth 100000

namespace Host.Ts.RefScan.CommandTests

def module : Module := [
  .import_ [.named chars!"unused" chars!"unused"] chars!"other.ts",
  .stmt (.expr (.bin .add (.id chars!"x") (.id chars!"x"))),
  .exportNamed [(chars!"y", chars!"z")] none]

ref_scan_checked R : module, 3

theorem ordered_duplicates : refsM module =
    [pack chars!"y", pack chars!"x", pack chars!"x"] := R.checked

theorem endpoint : R.s4.todo = [] := R.done

end Host.Ts.RefScan.CommandTests
