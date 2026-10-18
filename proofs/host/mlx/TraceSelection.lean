import host.mlx.TraceRoles

set_option Elab.async false

namespace Host.Mlx.Ffi.NativeRoles
open Host.Ts

/-- The first fixed-signature trace is selected when its captured input
metadata and the actual input metadata are equal. Later traces are not read. -/
theorem findTrace_fixed_head_self (s : St) (t : Trace) (rest : List Trace) (xs : List Nat)
    (metadata : List (List Dim × Nat))
    (traceInputs : shapesOf s t.ins = some metadata)
    (realInputs : shapesOf s xs = some metadata) :
    findTrace s false xs (t::rest) = M.pure (some t) := by
  rw [findTrace,traceFits_fixed_self s t xs metadata traceInputs realInputs]
  rfl

/-- Each run checks its own exact fixed signature. The two runs may have
different shapes; fixed occurrence annotations must establish the equality
between traced and actual inputs within each run. -/
theorem findTrace_fixed_head_pair (s s' : St) (t t' : Trace) (rest rest' : List Trace)
    (xs xs' : List Nat) (metadata metadata' : List (List Dim × Nat))
    (traceInputs : shapesOf s t.ins = some metadata)
    (realInputs : shapesOf s xs = some metadata)
    (traceInputs' : shapesOf s' t'.ins = some metadata')
    (realInputs' : shapesOf s' xs' = some metadata') :
    findTrace s false xs (t::rest) = M.pure (some t) ∧
      findTrace s' false xs' (t'::rest') = M.pure (some t') :=
  ⟨findTrace_fixed_head_self s t rest xs metadata traceInputs realInputs,
    findTrace_fixed_head_self s' t' rest' xs' metadata' traceInputs' realInputs'⟩

end Host.Mlx.Ffi.NativeRoles
