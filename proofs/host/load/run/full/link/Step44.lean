import host.load.run.full.link.States
import host.load.run.full.link.Scan44

set_option Elab.async false
set_option maxHeartbeats 0
set_option maxRecDepth 1000000

namespace Host.Load.Run.Full.Link
open Host.Ts

def user44 : UMod := ⟨chars!"packages/inference/src/models/qwen/qwen38-27b-trellis-m1max.ts",
  Sources.Inference.Models.Qwen.Qwen3827bTrellisM1max.ast⟩

theorem L.l44 : linkRun L.cx 44 1 L.x44 = some L.x45 :=
  (RefScan.linkRun_one_user_scanned L.cx 44 L.x44 user44 Scan44.refs
    rfl rfl rfl Scan44.checked).trans (by rfl)

end Host.Load.Run.Full.Link
