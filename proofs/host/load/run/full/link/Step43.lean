import host.load.run.full.link.States
import host.load.run.full.link.Scan43

set_option Elab.async false
set_option maxHeartbeats 0
set_option maxRecDepth 1000000

namespace Host.Load.Run.Full.Link
open Host.Ts

def user43 : UMod := ⟨chars!"packages/inference/src/models/qwen/qwen38-27b-trellis-m4pro.ts",
  Sources.Inference.Models.Qwen.Qwen3827bTrellisM4pro.ast⟩

theorem L.l43 : linkRun L.cx 43 1 L.x43 = some L.x44 :=
  (RefScan.linkRun_one_user_scanned L.cx 43 L.x43 user43 Scan43.refs
    rfl rfl rfl Scan43.checked).trans (by rfl)

end Host.Load.Run.Full.Link
