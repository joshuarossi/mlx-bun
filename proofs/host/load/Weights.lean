import host.load.Data
namespace Host.Load
open Host.Ts Host.Mlx.Ffi

/-! # Weight loads are checkpoint tensors

Every array the load route obtains from a safetensors map
(`mlx_map_string_to_array_get`, `Weights.#get`) is a fresh `load` node keyed
by the requested name, an entry of the mapped shard's weight table, with
the entry's shape and dtype. The weight tables are `stHeader` of the
shards' JSON headers (`Data.header_eq*`): the bytes the TypeScript side
parses from the same files (`Route.modelFiles`). -/

/-- A successful `mlx_map_string_to_array_get` adds node `s.nnext`, `load file k`,
for an entry `(n, shape, dt)` of `file`'s header with `n` the requested name `k`. -/
theorem mapGet_load (s : St) (o m key : Arg) (s' : St) (r : Ret) (ws : List (Nat × Nat × List Byte)) :
    (mapGet s o m key).run = .pure (some (s', r, ws)) →
    ∃ file k n shape dt, cstrArg key = some k ∧
      ((headerOf s file).bind fun h => h.find? fun (n, _, _) => nameEq n k) = some (n, shape, dt) ∧
      nameEq n k = true ∧
      s'.nodes = s.nodes.set s.nnext ⟨.load file k, [], lits (shape.map Int.ofNat), dt⟩ := by
  unfold mapGet
  split
  · rename_i b off slot file k _ _ hk
    split
    · rename_i n shape dt hf
      intro h
      refine ⟨file, k, n, shape, dt, hk, hf, ?_, ?_⟩
      · obtain ⟨_, _, h2⟩ := Option.bind_eq_some_iff.mp hf
        exact List.find?_some (p := fun x : List Char × List Nat × Nat => nameEq x.1 k) h2
      · simp only [okW, St.addNode, St.setArr, M.run, M.pure, Free.pure.injEq, Option.some.injEq, Prod.mk.injEq] at h
        obtain ⟨rfl, -, -⟩ := h
        cases Nat.beq slot 0 <;> rfl
    · intro h; simp [stuck, M.run, M.pure] at h
  · intro h; simp [stuck, M.run, M.pure] at h

end Host.Load
