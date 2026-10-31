import host.load.boot.States
import host.load.run.tail.Command
import host.ts.Harness
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Prompt
open Host.Ts

/- The saved entry environment's driver cells are independent of prompt and readback values. -/
kernel_rfl_eager saved_cache : ∀ (fw : List Val) (tail : List NumV),
  lookupEnv chars!"cache" (entryEnv (P.at0 fw tail)) = some 2586

kernel_rfl_eager saved_generation : ∀ (fw : List Val) (tail : List NumV),
  lookupEnv chars!"generation" (entryEnv (P.at0 fw tail)) = some 2589

kernel_rfl_eager saved_emitted : ∀ (fw : List Val) (tail : List NumV),
  lookupEnv chars!"emitted" (entryEnv (P.at0 fw tail)) = some 2590

end Host.Load.Run.Prompt
