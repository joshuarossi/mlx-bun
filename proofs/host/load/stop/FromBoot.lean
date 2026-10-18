import host.load.run.full.Run
import host.load.stop.EntryData
set_option Elab.async false
set_option maxRecDepth 1000000
namespace Host.Load.Run.Full
open Host.Ts Host.Load

namespace StopEntry

def BootRun (ρ : Nat → F64) (C : CSrv) (fuel : Nat) (last : St LSt) (server : SSrv) : Prop :=
  ∃ C', ((bootL Route.cx Decode.world 2000).bind fun s => runC Host.Load.ffi fuel s C) =
    some (last, C') ∧ Inst ρ server C'

theorem first_entry (ρ : Nat → F64) (C : CSrv)
    (table : C.tab = P.S0.tab.map (SymE.eval ρ)) :
    ∃ C', runC P.F 29724699 P.s0 C = some (P.s2973, C') ∧
      C'.tab = P.S2973.tab.map (SymE.eval ρ) :=
  OraclePrefix.concrete_prefix P.F ρ C P.prefixRun2973 first_oracle table
    (by intro q hq; cases hq)

theorem first_yield_entry (ρ : Nat → F64) (C : CSrv)
    (table : C.tab = P.S0.tab.map (SymE.eval ρ))
    (budget : F64.test .lt (.fin false 1 0) (ρ 0) = true)
    (notEos : F64.test .eq (.fin false 248044 0) (ρ 1) = false) :
    ∃ C', runC P.F 29727013 P.s0 C = some (P.s2974, C') ∧
      C'.tab = P.S2974.tab.map (SymE.eval ρ) :=
  OraclePrefix.concrete_prefix P.F ρ C P.prefixRun2974 first_yield_oracle table
    (first_yield_good ρ budget notEos)

theorem cold_entry (ρ : Nat → F64) (C : CSrv)
    (table : C.tab = P.S0.tab.map (SymE.eval ρ))
    (budget : F64.test .lt (.fin false 1 0) (ρ 0) = true)
    (notEos : F64.test .eq (.fin false 248044 0) (ρ 1) = false) :
    ∃ C', runC P.F 31219191 P.s0 C = some (P.s3123, C') ∧
      C'.tab = P.S3123.tab.map (SymE.eval ρ) :=
  OraclePrefix.concrete_prefix P.F ρ C P.prefixRun3123 cold_oracle table
    (cold_good ρ budget notEos)

theorem ordinary_entry (ρ : Nat → F64) (C : CSrv)
    (table : C.tab = P.S0.tab.map (SymE.eval ρ))
    (budget : ρ 0 = .fin false 5 0)
    (notEos : F64.test .eq (.fin false 248044 0) (ρ 1) = false) :
    ∃ C', runC P.F 32711604 P.s0 C = some (P.s3272, C') ∧
      C'.tab = P.S3272.tab.map (SymE.eval ρ) :=
  OraclePrefix.concrete_prefix P.F ρ C P.prefixRun3272 ordinary_oracle table
    (ordinary_good ρ budget notEos)

theorem final_entry (ρ : Nat → F64) (C : CSrv)
    (table : C.tab = P.S0.tab.map (SymE.eval ρ))
    (budget : ρ 0 = .fin false 5 0)
    (notEos : ∀ i ∈ [1, 2, 3, 4], F64.test .eq (.fin false 248044 0) (ρ i) = false) :
    ∃ C', runC P.F 35696943 P.s0 C = some (P.s3573, C') ∧
      C'.tab = P.S3573.tab.map (SymE.eval ρ) :=
  OraclePrefix.concrete_prefix P.F ρ C P.prefixRun3573 final_oracle table
    (final_good ρ budget notEos)

private theorem compose (ρ : Nat → F64) {C C1 C2 : CSrv} {n m : Nat}
    {s1 s2 : St LSt} {server : SSrv}
    (before : runC P.F n P.s0 C = some (s1, C1))
    (after : runC P.F m s1 C1 = some (s2, C2)) (inst : Inst ρ server C2) :
    BootRun ρ C (n + m) s2 server := by
  refine ⟨C2, ?_, inst⟩
  change (P.boot.bind fun s => runC P.F (n + m) s C) = _
  rw [P.boot_eq]
  change runC P.F (n + m) P.s0 C = some (s2, C2)
  unfold runC at *
  rw [runWith_add, before]
  exact after

end StopEntry

theorem OneToken.from_boot (ρ : Nat → F64) (C : CSrv)
    (table : C.tab = P.S0.tab.map (SymE.eval ρ))
    (budget : ρ 0 = .fin false 1 0)
    (notEos : F64.test .eq (.fin false 248044 0) (ρ 1) = false) :
    StopEntry.BootRun ρ C (29724699 + 3144) OneToken.s7 OneToken.S7 := by
  obtain ⟨C1, first, tab⟩ := StopEntry.first_entry ρ C table
  obtain ⟨C2, last, inst⟩ := OneToken.concrete_run ρ C1
    (by rw [StopEntry.one_table]; exact tab) budget notEos
  exact StopEntry.compose ρ (n := 29724699) (m := 3144) first last inst

theorem OneEos.from_boot (ρ : Nat → F64) (C : CSrv)
    (table : C.tab = P.S0.tab.map (SymE.eval ρ))
    (budget : ρ 0 = .fin false 1 0)
    (eos : ρ 1 = .fin false 248044 0) :
    StopEntry.BootRun ρ C (29724699 + 2952) OneEos.s6 OneEos.S6 := by
  obtain ⟨C1, first, tab⟩ := StopEntry.first_entry ρ C table
  obtain ⟨C2, last, inst⟩ := OneEos.concrete_run ρ C1
    (by rw [StopEntry.one_eos_table]; exact tab) budget eos
  exact StopEntry.compose ρ (n := 29724699) (m := 2952) first last inst

theorem EosToken.from_boot (ρ : Nat → F64) (C : CSrv)
    (table : C.tab = P.S0.tab.map (SymE.eval ρ))
    (budget : ρ 0 = .fin false 5 0)
    (notEos : F64.test .eq (.fin false 248044 0) (ρ 1) = false)
    (eos : ρ 2 = .fin false 248044 0) :
    StopEntry.BootRun ρ C (32711604 + 825) EosToken.s2 EosToken.S2 := by
  obtain ⟨C1, first, tab⟩ := StopEntry.ordinary_entry ρ C table budget notEos
  obtain ⟨C2, last, inst⟩ := EosToken.concrete_run ρ C1
    (by rw [StopEntry.ordinary_eos_table]; exact tab) eos
  exact StopEntry.compose ρ (n := 32711604) (m := 825) first last inst

theorem FinalEos.from_boot (ρ : Nat → F64) (C : CSrv)
    (table : C.tab = P.S0.tab.map (SymE.eval ρ))
    (budget : ρ 0 = .fin false 5 0)
    (notEos : ∀ i ∈ [1, 2, 3, 4], F64.test .eq (.fin false 248044 0) (ρ i) = false)
    (eos : ρ 5 = .fin false 248044 0) :
    StopEntry.BootRun ρ C (35696943 + 1134) FinalEos.s3 FinalEos.S3 := by
  obtain ⟨C1, first, tab⟩ := StopEntry.final_entry ρ C table budget notEos
  obtain ⟨C2, last, inst⟩ := FinalEos.concrete_run ρ C1
    (by rw [StopEntry.final_eos_table]; exact tab) budget eos
  exact StopEntry.compose ρ (n := 35696943) (m := 1134) first last inst

theorem FirstEos.from_boot (ρ : Nat → F64) (C : CSrv)
    (table : C.tab = P.S0.tab.map (SymE.eval ρ))
    (budget : F64.test .lt (.fin false 1 0) (ρ 0) = true)
    (eos : ρ 1 = .fin false 248044 0) :
    StopEntry.BootRun ρ C (29724699 + 1495111) FirstEos.s150 FirstEos.S150 := by
  obtain ⟨C1, first, tab⟩ := StopEntry.first_entry ρ C table
  obtain ⟨C2, last, inst⟩ := FirstEos.concrete_run ρ C1
    (by rw [StopEntry.first_eos_table]; exact tab) budget eos
  exact StopEntry.compose ρ (n := 29724699) (m := 1495111) first last inst

theorem TwoToken.from_boot (ρ : Nat → F64) (C : CSrv)
    (table : C.tab = P.S0.tab.map (SymE.eval ρ))
    (budget : ρ 0 = .fin false 2 0)
    (first : F64.test .eq (.fin false 248044 0) (ρ 1) = false)
    (last : F64.test .eq (.fin false 248044 0) (ρ 2) = false) :
    StopEntry.BootRun ρ C (31219191 + 1430) TwoToken.s3 TwoToken.S3 := by
  obtain ⟨C1, start, tab⟩ := StopEntry.cold_entry ρ C table (by rw [budget]; decide) first
  obtain ⟨C2, finish, inst⟩ := TwoToken.concrete_run ρ C1
    (by rw [StopEntry.two_table]; exact tab) budget first last
  exact StopEntry.compose ρ (n := 31219191) (m := 1430) start finish inst

theorem TwoEos.from_boot (ρ : Nat → F64) (C : CSrv)
    (table : C.tab = P.S0.tab.map (SymE.eval ρ))
    (budget : ρ 0 = .fin false 2 0)
    (first : F64.test .eq (.fin false 248044 0) (ρ 1) = false)
    (eos : ρ 2 = .fin false 248044 0) :
    StopEntry.BootRun ρ C (31219191 + 1254) TwoEos.s3 TwoEos.S3 := by
  obtain ⟨C1, start, tab⟩ := StopEntry.cold_entry ρ C table (by rw [budget]; decide) first
  obtain ⟨C2, finish, inst⟩ := TwoEos.concrete_run ρ C1
    (by rw [StopEntry.two_eos_table]; exact tab) budget first eos
  exact StopEntry.compose ρ (n := 31219191) (m := 1254) start finish inst

end Host.Load.Run.Full
