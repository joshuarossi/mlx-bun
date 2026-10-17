import models.qwen.CheckpointFileRead
import models.qwen.CheckpointFileCheck

namespace Inference.Models.Qwen.CheckpointFileMain
open CheckpointFile CheckpointFileCheck

-- Runner: ranged reads of the index and literal tensors, then `check`.
-- PASS means `check` returned true, so `check_sound` yields `Accepted` for
-- any disk contents the reads were faithful to.
theorem pass_sound (index : ByteArray) (shards : List (String × View)) (disk : String → ByteArray)
    (faithful : Faithful ⟨index, shards⟩ disk) (pass : check ⟨index, shards⟩ = true) : Accepted index disk :=
  check_sound ⟨index, shards⟩ disk faithful pass

end Inference.Models.Qwen.CheckpointFileMain

open Inference.Models.Qwen in
def main (args : List String) : IO UInt32 := do
  let [directory] := args | IO.eprintln "usage: CheckpointFileMain.lean CHECKPOINT_DIRECTORY"; return 2
  let start ← IO.monoMsNow
  let (index, shards) ← CheckpointFile.load directory CheckpointFileCheck.required
  let loaded ← IO.monoMsNow
  let bytes := shards.foldl (fun n s => s.2.ranges.foldl (fun n r => n + r.2.size) (n + s.2.head.size)) index.size
  let pass ← IO.lazyPure fun _ => CheckpointFileCheck.check ⟨index, shards⟩
  let checked ← IO.monoMsNow
  IO.println s!"{if pass then "PASS" else "FAIL"}: {CheckpointFileCheck.required.length} tensors, {shards.length} shards, {bytes} bytes read; read {loaded - start} ms, check {checked - loaded} ms"
  return if pass then 0 else 1
