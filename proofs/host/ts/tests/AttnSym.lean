import host.ts.tests.AttnSrc
namespace Host.Ts.Tests.AttnSym
open Host.Ts Host.Ts.Tests

/-! One `Qwen3TextAttention.forward` decode step at symbolic cache offset
`n` (no cache growth), kernel-checked, and transferred to every concrete
`n < 256` answer by `run_sim`. -/

def nPlus1 : SymE := .bin .add (.var 0) (.lit (F64.fin false 1 0))
def oracle : List Ans := [⟨.lt, .lit (F64.ofNat 256), nPlus1, false⟩]

def symRun : Option (St Mock.St × SSrv) := attnBoot.bind fun s => runS Mock.ffi 40000 s ⟨[.var 0], oracle⟩
def concRun (ρ : Nat → F64) : Option (St Mock.St × CSrv) := attnBoot.bind fun s => runC Mock.ffi 40000 s ⟨[ρ 0]⟩

/-- FFI call count, output shape, new offset (through the table), RoPE
offsets passed to `mlx_fast_rope`, unused oracle answers. -/
def summary : Option (Nat × List SymE × SymE × List (Option SymE) × List Ans) :=
  symRun.bind fun (s, S) => (attnBoot.map entryEnv).bind fun env => (bindingOf s env chars!"out").bind fun out =>
    (elemOf s out 0).bind fun y => (symsOf s S y).bind fun ys => (elemOf s out 1).bind fun off =>
      (symOf S off).map fun o =>
        (s.trace.length, ys, o,
         (s.trace.filter fun e => nameEq e.sym chars!"mlx_fast_rope").reverse.map fun e => match nth? e.args 6 with
           | some (Arg.num x) => S.val x
           | _ => none,
         S.oracle)

kernel_rfl forward : summary = some (108, [.lit (F64.ofNat 1), .lit (F64.ofNat 1), .lit (F64.ofNat 64)], nPlus1,
    [some (.un .int32 (.var 0)), some (.un .int32 (.var 0))], [])

theorem forward_at (ρ : Nat → F64) (h : F64.test .lt (F64.ofNat 256) (nPlus1.eval ρ) = false) :
    ∀ s' S', symRun = some (s', S') → ∃ C', concRun ρ = some (s', C') ∧ Inst ρ S' C' :=
  fun s' S' => boot_sim Mock.ffi ρ attnBoot 40000 ⟨[.var 0], oracle⟩ ⟨[ρ 0]⟩
    ⟨rfl, by intro q hq; simp only [oracle, List.mem_singleton] at hq; subst hq; simpa [SymE.eval] using h⟩ s' S'

end Host.Ts.Tests.AttnSym
