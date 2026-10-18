import host.load.run.full.Run
import host.load.run.full.Oracles
set_option Elab.async false
namespace Host.Load.Run.Full
open Host.Ts Host.Load

theorem P.concrete_run (ρ : Nat → F64) (C : CSrv)
    (table : C.tab = P.srv.tab.map (SymE.eval ρ))
    (budget : ρ 0 = .fin false 5 0)
    (notEos : ∀ i ∈ [1, 2, 3, 4, 5],
      F64.test .eq (.fin false 248044 0) (ρ i) = false)
    (n : Nat) (enough : 35698253 ≤ n) :
    ∃ C', runC P.F n P.s0 C = some (P.s3575, C') ∧ Inst ρ P.S3575 C' := by
  have execution : runS P.F n P.s0 P.srv = some (P.s3575, P.S3575) := by
    simpa only [P.boot_eq, Option.bind_some] using P.result n enough
  exact run_sim P.F ρ n P.s0 P.s3575 P.srv P.S3575 C
    ⟨table, P.good_five ρ budget notEos⟩ execution

theorem P.concrete_boot (ρ : Nat → F64) (C : CSrv)
    (table : C.tab = P.srv.tab.map (SymE.eval ρ))
    (budget : ρ 0 = .fin false 5 0)
    (notEos : ∀ i ∈ [1, 2, 3, 4, 5],
      F64.test .eq (.fin false 248044 0) (ρ i) = false)
    (n : Nat) (enough : 35698253 ≤ n) :
    ∃ C', ((bootL Route.cx Decode.world 2000).bind fun s => runC Host.Load.ffi n s C) =
      some (P.s3575, C') ∧ Inst ρ P.S3575 C' := by
  obtain ⟨C', execution, inst⟩ := P.concrete_run ρ C table budget notEos n enough
  refine ⟨C', ?_, inst⟩
  change (P.boot.bind fun s => runC P.F n s C) = _
  rw [P.boot_eq]
  exact execution

end Host.Load.Run.Full
