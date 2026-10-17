import models.qwen.CheckpointFile

namespace Inference.Models.Qwen.CheckpointFile

-- Trusted host input: positioned reads (checkpoint-file.c, pread) build the
-- views that check_sound assumes faithful. Nothing here is used by `check`.
@[extern "mlx_bun_read_range"]
opaque readRange (path : @& String) (offset : UInt64) (length : USize) : IO ByteArray

/-- Reads a shard's prefix through its header and the payload ranges of `names`. -/
def loadView (path : String) (names : List String) : IO View := do
  let size := (← System.FilePath.metadata path).byteSize.toNat
  let length := le (← readRange path 0 8) 0 8
  if 8 + length > size || length > 100000000 then throw (IO.userError s!"invalid header length in {path}")
  let head ← readRange path 0 (8 + length).toUSize
  let some kvs := header head | throw (IO.userError s!"invalid header in {path}")
  let ranges ← names.filterMapM fun name => do
    match (lookup1 name kvs).bind entry with
    | some e =>
      if e.begin ≤ e.stop && 8 + length + e.stop ≤ size then
        return some (8 + length + e.begin, ← readRange path (8 + length + e.begin).toUInt64 (e.stop - e.begin).toUSize)
      else return none
    | none => return none
  return ⟨size, head, ranges⟩

/-- Index bytes and one view per shard named by the index for `names`. -/
def load (directory : String) (names : List String) : IO (ByteArray × List (String × View)) := do
  let index ← IO.FS.readBinFile (directory ++ "/model.safetensors.index.json")
  let some (.obj top) := parse index | throw (IO.userError "invalid checkpoint index")
  let some (.obj map) := lookup1 "weight_map" top | throw (IO.userError "missing weight_map")
  let pairs := names.filterMap fun name =>
    match lookup1 name map with
    | some (.str s) => some (name, s)
    | _ => none
  let shards := pairs.foldl (fun acc p => if acc.contains p.2 then acc else acc ++ [p.2]) []
  let views ← shards.mapM fun s => do
    return (s, ← loadView (directory ++ "/" ++ s) ((pairs.filter (·.2 == s)).map (·.1)))
  return (index, views)

/-- A view holding the whole file is faithful; ranged views generalize it. -/
theorem whole_faithful (file : ByteArray) : (⟨file.size, file, [(0, file)]⟩ : View).Faithful file := by
  refine ⟨rfl, ByteArray.extract_zero_size, ?_⟩
  intro r hr
  simp only [List.mem_singleton] at hr
  subst hr
  exact ⟨by simp, by simp⟩

end Inference.Models.Qwen.CheckpointFile
