import host.ts.tests.attn.Run
namespace Host.Ts.Tests.AttnSym
open Host.Ts Host.Ts.Tests

/-! One `Qwen3TextAttention.forward` decode step at symbolic cache offset
`n` (no cache growth), kernel-checked in chunks (`tests/attn`: boot and
three runs of 6000 steps between explicit states), and transferred to
every concrete `n < 256` answer by `run_sim`. -/

def nPlus1 : SymE := AttnChain.nPlus1
def oracle : List Ans := AttnChain.oracle

def symRun : Option (St Mock.St × SSrv) := attnBoot.bind fun s => runS Mock.ffi 40000 s ⟨[.var 0], oracle⟩
def concRun (ρ : Nat → F64) : Option (St Mock.St × CSrv) := attnBoot.bind fun s => runC Mock.ffi 40000 s ⟨[ρ 0]⟩

/-- The run halts within the chain's 18000 steps. -/
theorem symRun_eq : symRun = some (AttnChain.P.s3, AttnChain.P.S3) := AttnChain.P.result 40000 (by decide)

/-- FFI call count, output shape, new offset (through the table), RoPE
offsets passed to `mlx_fast_rope`, unused oracle answers. -/
def summary (env : Env) (r : Option (St Mock.St × SSrv)) : Option (Nat × List SymE × SymE × List (Option SymE) × List Ans) :=
  r.bind fun (s, S) => (bindingOf s env chars!"out").bind fun out =>
    (elemOf s out 0).bind fun y => (symsOf s S y).bind fun ys => (elemOf s out 1).bind fun off =>
      (symOf S off).map fun o =>
        (s.trace.length, ys, o,
         (s.trace.filter fun e => nameEq e.sym chars!"mlx_fast_rope").reverse.map fun e => match nth? e.args 6 with
           | some (Arg.num x) => S.val x
           | _ => none,
         S.oracle)

def expected : Option (Nat × List SymE × SymE × List (Option SymE) × List Ans) :=
  some (108, [.lit (F64.ofNat 1), .lit (F64.ofNat 1), .lit (F64.ofNat 64)], nPlus1,
    [some (.un .int32 (.var 0)), some (.un .int32 (.var 0))], [])

kernel_rfl final : summary (entryEnv AttnChain.P.s0) (some (AttnChain.P.s3, AttnChain.P.S3)) = expected

theorem forward : summary (entryEnv AttnChain.P.s0) symRun = expected := by rw [symRun_eq]; exact final

theorem forward_at (ρ : Nat → F64) (h : F64.test .lt (F64.ofNat 256) (nPlus1.eval ρ) = false) :
    ∀ s' S', symRun = some (s', S') → ∃ C', concRun ρ = some (s', C') ∧ Inst ρ S' C' :=
  fun s' S' => boot_sim Mock.ffi ρ attnBoot 40000 ⟨[.var 0], oracle⟩ ⟨[ρ 0]⟩
    ⟨rfl, by intro q hq; simp only [oracle, AttnChain.oracle, List.mem_singleton] at hq; subst hq
             simpa [SymE.eval, nPlus1] using h⟩ s' S'

end Host.Ts.Tests.AttnSym
