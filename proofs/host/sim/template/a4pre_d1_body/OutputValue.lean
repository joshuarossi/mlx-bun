import host.sim.template.a4pre_d1_body.OutputProjection
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl.D1BodyOutputValue
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template

def pin9 (ν : Nat → F64) (v : Nat) : F64 := if v = 9 then F64.ofNat 1 else ν v

theorem pin9_eq {ν : Nat → F64} (h : ν 9 = F64.ofNat 1) : pin9 ν = ν := by
  funext v
  by_cases hv : v = 9
  · subst v
    simp [pin9, h]
  · simp [pin9, hv]

kernel_rfl lengthOne : (fun ν : Nat → F64 =>
    (nth? D1Body.S155.tab 55).map (fun e => e.eval (pin9 ν))) = fun _ => some (F64.ofNat 1)

theorem lengthValue {M : Map} {ν : Nat → F64} {C : CSrv}
    (hs : Srv M ν ⟨D1Body.S155.tab, []⟩ C) (hν : ν 9 = F64.ofNat 1) :
    C.val (M.num 55) = some (F64.ofNat 1) := by
  have he := congrFun lengthOne ν
  cases h : nth? D1Body.S155.tab 55 with
  | none => rw [h] at he; cases he
  | some e =>
    rw [h, pin9_eq hν] at he
    simp only [Option.map_some, Option.some.injEq] at he
    rw [hs.num 55 e h, he]

theorem dimensions {M : Map} {ν : Nat → F64} {C : CSrv}
    (hs : Srv M ν ⟨D1Body.S155.tab, []⟩ C) (hν : ν 9 = F64.ofNat 1) :
    DVSs M C ⟨D1Body.S155.tab, []⟩ [.lit 1, .sym (.ref 55), .lit 5120] [1, 1, 5120] := by
  refine ⟨DVS.lit _ _ _ 1, ⟨⟨?_, ?_⟩, DVS.lit _ _ _ 5120, trivial⟩⟩
  · exact .inr ⟨55, rfl, lengthValue hs hν⟩
  · change 55 < D1Body.S155.tab.length
    rw [D1Body.tableCount]
    decide

end Host.Load.Run.Tpl.D1BodyOutputValue
