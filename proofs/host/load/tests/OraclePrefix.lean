import host.load.OraclePrefix
set_option Elab.async false
namespace Host.Load.Tests.OraclePrefix
open Host.Ts

def used : Ans := ⟨.eq, .var 0, .lit (F64.ofNat 0), false⟩
def ignored : Ans := ⟨.eq, .var 1, .lit (F64.ofNat 0), false⟩
def operation : Free Bool := .test .eq (.ref 0) (.lit (F64.ofNat 0)) .pure
def initial : SSrv := ⟨[.var 0], [used, ignored]⟩
def final : SSrv := ⟨[.var 0], [ignored]⟩

theorem execution : interpS operation initial = some (false, final) := by rfl

theorem unused_removed :
    interpS operation { initial with oracle := [used] } =
      some (false, { final with oracle := [] }) :=
  Host.Load.OraclePrefix.interpS_strip operation execution (by rfl)

theorem needed_answer_preserved : interpS operation { initial with oracle := [] } = none := by rfl

def numbers (i : Nat) : F64 := F64.ofNat (if i = 0 then 1 else 0)

theorem used_good : Good numbers [used] := by
  simp only [Good, List.forall_mem_cons]
  constructor
  · rfl
  · intro q hq
    cases hq

theorem ignored_bad : ¬ Good numbers initial.oracle := by
  intro h
  have bad := h ignored (by decide)
  have actual : F64.test ignored.op (ignored.a.eval numbers) (ignored.b.eval numbers) = true := by rfl
  rw [actual] at bad
  cases bad

end Host.Load.Tests.OraclePrefix
