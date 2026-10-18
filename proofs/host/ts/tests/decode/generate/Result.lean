import host.ts.tests.decode.generate.Run
import host.ts.Loop
namespace Host.Ts.Tests.Decode.Generate
open Host.Ts

/-! What the generation run computes (76 chunks, `P.result`), its transfer to concrete
numbers (`generate_at`), and the iterations' independence of `forwarded` (`P.absRun`).

The run: gen0 (the one-token prompt through `phases.prompt("decode", 1, 1)` = D1 at offset 0,
H1, `normalizedArgmax`), iteration 0 (early yield of token 0, forward at offset 1), iteration 1
(offset 2, yield 1), iteration 2 at offset `n` (the steady step; the driver repositioned the
caches to `n`, capacity `c`), iteration 3 at offset `c` = capacity (the growth step), iteration
4 (`4 + 1 < M` false: no forward, yield, stop), the generator's return and the wired scope's
exit. Its 75 oracle answers are its branch facts on the symbolic numbers: `t + 1 < M` for
`t < 4` and `¬ 5 < M`; every read token `≠ 248044` (no EOS); at offset `n`
`¬ (n + 1 > c)` (no growth); at offset `c` `c + 1 > c` and `c % 256 = 0` (growth, no trim);
and the int32 bounds MLX's slice and shape inference test. -/

/-- The run from the boot with the chain's fuel. -/
noncomputable def symRun : Option (St Host.Mlx.Ffi.St × SSrv) :=
  boot0.bind fun s => runS Host.Mlx.Ffi.ffi 760000 s ⟨tab, P.O⟩

theorem symRun_eq : symRun = some (P.s76, P.S76) := P.result 760000 (by decide)

/-- The driver's `out` (yielded tokens, `stats.generatedTokens`, the attention cache's offset
and key shape, the first recurrent cache's offset) through the number table, the FFI call
count and the FFI model's node count. -/
noncomputable def summary (r : Option (St Host.Mlx.Ffi.St × SSrv)) :
    Option (List SymE × SymE × SymE × List SymE × SymE × Nat × Nat) :=
  r.bind fun (s, S) => (bindingOf s (entryEnv P.s0) chars!"out").bind fun out =>
    (elemOf s out 0).bind fun ts => (symsOf s S ts).bind fun toks =>
    (elemOf s out 1).bind fun g => (symOf S g).bind fun gen =>
    (elemOf s out 2).bind fun o3 => (symOf S o3).bind fun off3 =>
    (elemOf s out 3).bind fun k => (symsOf s S k).bind fun shape =>
    (elemOf s out 4).bind fun o0 => (symOf S o0).map fun off0 =>
      (toks, gen, off3, shape, off0, s.trace.length, s.ffi.nnext)

def one : SymE := .lit (F64.fin false 1 0)

def expected : Option (List SymE × SymE × SymE × List SymE × SymE × Nat × Nat) :=
  some ([.var 3, .var 4, .var 5, .var 6, .var 7], .lit (F64.fin false 5 0), .bin .add (.var 1) one,
    [one, .lit (F64.fin false 4 0), .bin .add (.un .int32 (.var 1)) (.lit (F64.fin false 256 0)), .lit (F64.fin false 256 0)],
    .bin .add (.var 1) one, 6432, 995)

kernel_rfl final : summary (some (P.s76, P.S76)) = expected

/-- **The generation loop at a symbolic position.** For a one-token prompt,
`generateAutoregressive` yields the five read tokens in order (number-table entries 3 … 7),
reports five generated tokens, and leaves the attention cache at offset `c + 1` with keys of
capacity `c + 256` (the growth step) and the recurrent caches at `c + 1`; 6432 FFI calls
over 995 graph nodes. -/
theorem generate : summary symRun = expected := by rw [symRun_eq]; exact final

theorem oracle_length : P.O.length = 75 := by decide

/-- Every valuation whose test answers are the oracle's (the branch facts above) runs the
same: the concrete run reaches the same final state, its table the symbolic one's
instantiation. -/
theorem generate_at (ρ : Nat → F64) (h : Good ρ P.O) :
    ∃ C', (boot0.bind fun s => runC Host.Mlx.Ffi.ffi 760000 s ⟨tab.map (SymE.eval ρ)⟩) = some (P.s76, C') ∧
      Inst ρ P.S76 C' :=
  boot_sim Host.Mlx.Ffi.ffi ρ boot0 760000 ⟨tab, P.O⟩ ⟨tab.map (SymE.eval ρ)⟩ ⟨rfl, h⟩ P.s76 P.S76 symRun_eq

/-! ### `forwarded`, the array that grows with the position

From state 37 (inside iteration 0) to state 75 (before `makeStats` spreads it) the
run holds for any contents of `forwarded`: the iterations only push to it. -/

host_chain_abs_run P

/-- The concrete contents are an instance: `P.a<k> P.base` is the chain's state. -/
theorem abs_base : P.a37 P.base = P.s37 ∧ P.a75 P.base = P.s75 := ⟨rfl, rfl⟩

end Host.Ts.Tests.Decode.Generate
