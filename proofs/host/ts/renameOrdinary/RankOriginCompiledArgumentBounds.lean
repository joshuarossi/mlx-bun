import host.ts.renameOrdinary.RankOriginCompiledArgumentInputFacts

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 1000000
namespace Host.Load.Run.Full.Ordinary.RankOrigin.CompiledArgumentInputFacts
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated

theorem current_live (a : Nat) (alive : InitialRetained.live a) : InitializedPostConcatFree.live a := by
  repeat (first | exact alive | apply Or.inl)

theorem current_intrinsic (a : Nat) (small : a < 100) : InitializedPostConcatFree.live a :=
  current_live a (by rw [InitialRetained.live,InitialClosure.source_address_limit]; omega)

end Host.Load.Run.Full.Ordinary.RankOrigin.CompiledArgumentInputFacts
