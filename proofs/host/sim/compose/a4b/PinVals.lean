import host.sim.compose.TailVals
set_option autoImplicit false
namespace Host.Ts.Sim.Compose.Post
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Load.Run.Tpl

/-- What a class pinned at one prompt length holds on entering POST: the trace ids and payloads, and the offset's copy, at the
literals its entry link sets. -/
structure PinVals (a21 a22 a24 a28 : Nat) (ν : Nat → F64) : Prop where
  v21 : ν 21 = F64.ofNat a21
  v22 : ν 22 = F64.ofNat a22
  v24 : ν 24 = F64.ofNat a24
  v28 : ν 28 = F64.ofNat a28

/-- A pinned class's link to the shared tail: the hand-off's literals, the trace counter `v21 + 1`, the entry's trace id and payload
kept, and the final forward's offsets from the entry's `v28`. `hv` lists the length's hand-off values. -/
theorem handPin {θ : Nat → SymE} {ν : Nat → F64} {L a20 a21 a22 a23 a24 a25 a26 a28 a200 a259 a260 : Nat}
    (hv : ∀ v k, handVal L v = some k →
      (v, k) ∈ [(20, a20), (22, a22), (23, a23), (24, a24), (25, a25), (26, a26), (200, a200), (259, a259), (260, a260)])
    (i20 : litAt θ 20 a20 = true) (i22 : θ 22 = .var 22) (i23 : litAt θ 23 a23 = true) (i24 : θ 24 = .var 24)
    (i25 : litAt θ 25 a25 = true) (i26 : litAt θ 26 a26 = true) (i200 : θ 200 = .bin .add (.var 21) (.lit (F64.ofNat 1)))
    (i259 : θ 259 = .un .int32 (.var 28)) (i260 : θ 260 = .un .int32 (.bin .add (.var 28) (.lit (F64.ofNat 1))))
    (h200 : a21 + 1 = a200) (h259 : a28 = a259) (h260 : a28 + 1 = a260) (hsmall : a200 < 2 ^ 53) (h31 : a260 < 2 ^ 31)
    (h : PinVals a21 a22 a24 a28 ν) :
    tail.hand L (Shift.valuation θ ν) := by
  intro v k hk
  have hm := hv v k hk
  simp only [List.mem_cons, List.not_mem_nil, or_false, Prod.mk.injEq] at hm
  rcases hm with ⟨rfl, rfl⟩ | ⟨rfl, rfl⟩ | ⟨rfl, rfl⟩ | ⟨rfl, rfl⟩ | ⟨rfl, rfl⟩ | ⟨rfl, rfl⟩ | ⟨rfl, rfl⟩ | ⟨rfl, rfl⟩ | ⟨rfl, rfl⟩
  · exact litAt_eval i20 ν
  · change (θ 22).eval ν = _
    rw [i22]
    exact h.v22
  · exact litAt_eval i23 ν
  · change (θ 24).eval ν = _
    rw [i24]
    exact h.v24
  · exact litAt_eval i25 ν
  · exact litAt_eval i26 ν
  · change (θ 200).eval ν = _
    rw [i200]
    change F64.bin .add (ν 21) (F64.ofNat 1) = _
    rw [h.v21, bin_add_ofNat a21 1 (by omega), h200]
  · change (θ 259).eval ν = _
    rw [i259, ← h259]
    exact eval_int32 h.v28 (by omega)
  · change (θ 260).eval ν = _
    rw [i260, ← h260]
    refine eval_int32 ?_ (by omega)
    change F64.bin .add (ν 28) (F64.ofNat 1) = _
    rw [h.v28, bin_add_ofNat a28 1 (by omega)]

end Host.Ts.Sim.Compose.Post
