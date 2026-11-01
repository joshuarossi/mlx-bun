import host.sim.full.Record
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl.D1BodyTrace
open Host.Ts Host.Ts.Sim Host.Ts.Sim.G
open Host.Mlx.Ffi (Dim Trace)

private theorem lenL_eq (xs : List α) (n : Nat) : lenL xs n = xs.length + n := by
  induction xs generalizing n with
  | nil => simp only [lenL, List.length_nil, Nat.zero_add]
  | cons x xs ih => simp only [lenL, ih, List.length_cons]; omega

private theorem len_eq (xs : List α) : len xs = xs.length := by
  simp only [len, lenL_eq, Nat.add_zero]

/-- Closed source shapes with bounded natural values at the current server. -/
def ShapesV (M : Map) (C : CSrv) (S : SSrv) :
    List (List Dim × Nat) → List (List Nat × Nat) → Prop
  | [], [] => True
  | (ds, dt) :: rest, (ks, kt) :: vals =>
    dt = kt ∧ DVSs M C S ds ks ∧ Bd ks ∧ ShapesV M C S rest vals
  | _, _ => False

theorem ShapesV.lift {ν : Nat → F64} {M M' : Map} {S S' : SSrv} {C C' : CSrv}
    (hg : GrowL M ν S C M' S' C') :
    ∀ {a : List (List Dim × Nat)} {v : List (List Nat × Nat)}, ShapesV M C S a v →
      ShapesV M' C' S' a v ∧ a.map M'.shp = a.map M.shp
  | [], [], _ => ⟨trivial, rfl⟩
  | (ds, dt) :: rest, (ks, kt) :: vals, ⟨hd, hs, hb, hr⟩ => by
    obtain ⟨hs', he⟩ := DVSs.lift hg hs
    obtain ⟨hr', her⟩ := ShapesV.lift hg hr
    refine ⟨⟨hd, hs', hb, hr'⟩, ?_⟩
    change (M'.dims ds, dt) :: rest.map M'.shp = (M.dims ds, dt) :: rest.map M.shp
    rw [he, her]
  | [], _ :: _, h => h.elim
  | _ :: _, [], h => h.elim

def fitValues (sl : Bool) : List (List Nat × Nat) → List (List Nat × Nat) → Bool
  | [], [] => true
  | (sa, da) :: ra, (sb, db) :: rb =>
    bif !(Nat.beq da db) || !(Nat.beq sa.length sb.length) then false
    else bif sl then fitValues sl ra rb
    else bif decide (sa = sb) then fitValues sl ra rb else false
  | _, _ => false

/-- Shaped lookup comparisons are simulated as effects, including their source
oracle consumption and both servers' growth. -/
theorem fitsSim {ν : Nat → F64} :
    ∀ {M : Map} {S : SSrv} {C : CSrv} (sl : Bool)
      (a b : List (List Dim × Nat)) (av bv : List (List Nat × Nat)),
      Srv M ν S C → ShapesV M C S a av → ShapesV M C S b bv →
      MSim (BPost M ν S C (fitValues sl av bv)) S C
        (Host.Mlx.Ffi.traceFits.go sl a b)
        (Host.Mlx.Ffi.traceFits.go sl (a.map M.shp) (b.map M.shp))
  | _, _, _, _, [], [], [], [], hs, _, _ => MSim.pure ⟨rfl, rfl, GrowL.refl hs⟩
  | _, _, _, _, [], _ :: _, [], _ :: _, hs, _, _ => MSim.pure ⟨rfl, rfl, GrowL.refl hs⟩
  | _, _, _, _, _ :: _, [], _ :: _, [], hs, _, _ => MSim.pure ⟨rfl, rfl, GrowL.refl hs⟩
  | M, S, C, sl, (sa, da) :: ra, (sb, db) :: rb, (ka, va) :: ar, (kb, vb) :: br,
      hs, ⟨hda, hsa, bsa, hra⟩, ⟨hdb, hsb, bsb, hrb⟩ => by
    subst va vb
    have hla := DVSs.length hsa
    have hlb := DVSs.length hsb
    simp only [Host.Mlx.Ffi.traceFits.go, List.map_cons, Map.shp, Map.dims,
      Native.len_map, len_eq, List.length_map, hla, hlb, fitValues]
    cases hbad : (!(Nat.beq da db) || !(Nat.beq ka.length kb.length))
    · simp only [hbad, Bool.cond_false]
      cases sl
      · simp only [Bool.cond_false]
        refine MSim.bind (allEq_simV hs hsa hsb bsa bsb) ?_
        rintro M1 S1 C1 e e' ⟨rfl, rfl, hg⟩
        by_cases heq : ka = kb
        · simp only [decide_eq_true heq, Bool.cond_true]
          obtain ⟨hra', hea⟩ := ShapesV.lift hg hra
          obtain ⟨hrb', heb⟩ := ShapesV.lift hg hrb
          rw [← hea, ← heb]
          refine MSim.mono (fitsSim false ra rb ar br hg.grow.srv hra' hrb') ?_
          rintro M2 S2 C2 r r' ⟨he, hv, hg2⟩
          exact ⟨he, hv, hg.trans hg2⟩
        · simp only [decide_eq_false heq, Bool.cond_false]
          exact MSim.pure ⟨rfl, rfl, hg⟩
      · simp only [Bool.cond_true]
        exact fitsSim true ra rb ar br hs hra hrb
    · simp only [hbad, Bool.cond_true]
      exact MSim.pure ⟨rfl, rfl, GrowL.refl hs⟩
  | _, _, _, _, [], _, _ :: _, _, _, h, _ => h.elim
  | _, _, _, _, _ :: _, _, [], _, _, h, _ => h.elim
  | _, _, _, _, _, [], _, _ :: _, _, _, h => h.elim
  | _, _, _, _, _, _ :: _, _, [], _, _, h => h.elim

end Host.Load.Run.Tpl.D1BodyTrace
