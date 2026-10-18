import host.load.Native
import host.load.Route
import host.ts.RefScanCommand

set_option Elab.async false
set_option interpreter.prefer_native true
set_option maxHeartbeats 0
set_option maxRecDepth 1000000

namespace Host.Load.Run.Full.Link
open Host.Ts

ref_scan_checked Scan43 : Sources.Inference.Models.Qwen.Qwen3827bTrellisM4pro.ast, 100

end Host.Load.Run.Full.Link
