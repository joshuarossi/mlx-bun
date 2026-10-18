import host.ts.RenameLiteralI32Cells

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 1000000
namespace Host.Ts.Owned.Annotated.Tests.LiteralI32Array

example : F64.un .int32 (F64.ofInt 2147483648) = F64.ofInt (-2147483648) := by decide +kernel

example : cellsOf .i32 [.num (.lit (F64.ofInt 2147483648))] =
    M.pure (some [.num (.lit (F64.ofInt (-2147483648)))]) := by rfl

example : literalI32Bytes [.lit (F64.ofNat 1)] =
    cellPartNotes .i32 (.literal (.un .int32 (.lit (F64.ofNat 1)))) 4 0 := rfl

example : [Value.num (.var 0)] ≠ (literalArrayExpressions [.num (.var 0)]).map Value.literal := by
  intro same
  cases same

example {ν : Nat → F64} {C : CSrv} {R : Ren} {meaning : SymE} {i : Nat} :
    ¬ Value.Holds ν C R (.literal meaning) (.num (.ref i)) := by
  intro held
  cases held

end Host.Ts.Owned.Annotated.Tests.LiteralI32Array
