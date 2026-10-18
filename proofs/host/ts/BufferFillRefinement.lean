import host.ts.Builtins

namespace Host.Ts

/-- The optimized builtin has exactly the original request computation and
state update, including all failures and malformed-view cases. -/
theorem bufN_taFill_eq_original (F : Ffi) (s : St F.S) (this : Val) (args data : List Val) :
    bufN F s this args data .taFill =
      match typedOf F s this with
      | some (_, _, k, b, off, n) =>
        M.bind (relIdx n (arg args 1) 0) fun i => M.bind (relIdx n (arg args 2) n) fun j =>
        M.bind (toCell k (arg args 0)) fun
        | some c => match s.obj? b with
          | some ⟨.buf bs, p, ps, pr, ex⟩ =>
            let bs := (List.range (j-i)).foldl
              (fun bs t => writeCell k c bs (off + (i+t) * k.size)) bs
            retS F (s.setObj b ⟨.buf bs, p, ps, pr, ex⟩) this
          | _ => M.fail "fill of native memory"
        | none => typeErr s chars!"fill value"
      | none => typeErr s chars!"fill of a non-typed array" := by
  simp only [bufN, fillCells_eq_original]
  rfl

end Host.Ts
