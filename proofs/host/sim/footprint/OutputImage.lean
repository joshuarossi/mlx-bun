import host.sim.footprint.NativeFrozen
import host.sim.footprint.Kernel
import host.sim.footprint.Config
import host.sim.footprint.Vectors
import host.sim.footprint.Compiled

namespace Host.Mlx.Ffi.Footprint
open Host.Ts Host.Ts.Sim Host.Ts.Sim.G

/-- A caller-only handle has a positive image. Thus support at null, allowed by
object APIs on arbitrary states, cannot modify any caller-only entry. -/
theorem Writes.nfrozen_pos {H I : Nat → Prop} {P0 P1 : LoadP} {NB n0 n1 : Nat}
    {M σ : Map} {x0 x1 y y' : NSt} (w : Writes H I y y')
    (hr : MRw P1 NB M n1 x1 y) (iso : MIso P0 P1 n0 σ x0 x1)
    (hh : ∀ h, 0 < h → h < y.next → H h → ∃ h0, PH x0 h0 ∧ h = M.handle (σ.handle h0))
    (hi : ∀ i, i < y.nnext → I i → ∃ i0, PN x0 i0 ∧ i = M.node (σ.node i0)) :
    NFrozen M σ x0 x1 y y' := by
  have hH : ∀ h, PH x1 h → (∀ h0, PH x0 h0 → σ.handle h0 ≠ h) → ¬ H (M.handle h) := by
    intro h hp hout hw
    obtain ⟨h0, hp0, he⟩ := hh _ (hr.himg h hp).1 (hr.himg h hp).2 hw
    exact hout h0 hp0 (hr.hinj _ _ (iso.present h0 hp0).2 hp he.symm)
  have hI : ∀ i, PN x1 i → (∀ i0, PN x0 i0 → σ.node i0 ≠ i) → ¬ I (M.node i) := by
    intro i hp hout hw
    obtain ⟨i0, hp0, he⟩ := hi _ (hr.nimg i hp) hw
    exact hout i0 hp0 (hr.ninj _ _ (iso_node_present iso hp0) hp he.symm)
  exact ⟨fun h hp hout => w.arrs _ (hr.himg h hp).2 (hH h hp hout),
    fun h hp hout => w.objs _ (hr.himg h hp).2 (hH h hp hout), w.nodes,
    fun i hp hout => w.items _ (hI i hp hout)⟩

/-- The actual decoder of a mapped first output argument yields the image of a
present source handle whenever the decoded target handle is positive. -/
theorem outSlot_image {P : LoadP} {NB n : Nat} {R : Map} {x y : NSt}
    (hr : MR P NB R n x y) (o : Arg) (rest : List Arg) (ho : slotOk P x o = true)
    {h : Nat} (hh : 0 < h) (hs : OutSlot ((o :: rest).map R.arg) h) :
    ∃ h0, PH x h0 ∧ h = R.handle h0 := by
  obtain ⟨b, off, sl, _, he, hp⟩ := hr.slot_map ho
  obtain ⟨o', rest', b', off', e, hs⟩ := hs
  have ea : o' = R.arg o := (List.cons.inj e.symm).1
  subst o'
  rw [he] at hs
  have es : R.handle sl = h := congrArg (fun p : Nat × Nat × Nat => p.2.2) (Option.some.inj hs)
  rcases hp with rfl | hp
  · rw [hr.handle0] at es
    exact (Nat.ne_of_gt hh es.symm).elim
  · exact ⟨sl, hp, es.symm⟩

theorem output_image {P : LoadP} {NB n : Nat} {R : Map} {x y : NSt}
    (hr : MR P NB R n x y) (o : Arg) (rest : List Arg) (ho : slotOk P x o = true)
    {h : Nat} (hs : Output ((o :: rest).map R.arg) h) :
    ∃ h0, PH x h0 ∧ h = R.handle h0 := by
  obtain ⟨o', rest', e, b, off, he, hn⟩ := hs
  exact outSlot_image hr o rest ho (Nat.pos_of_ne_zero hn) ⟨o', rest', b, off, e, he⟩

theorem firstHandle_image {P : LoadP} {NB n : Nat} {R : Map} {x y : NSt}
    (hr : MR P NB R n x y) (a : Arg) (rest : List Arg) (ha : hdOk x a = true)
    {h : Nat} (hs : FirstHandle ((a :: rest).map R.arg) h) :
    ∃ h0, PH x h0 ∧ h = R.handle h0 := by
  obtain ⟨k, _, hp, he⟩ := hr.hdOk_spec ha
  obtain ⟨a', rest', ea, hn⟩ := hs
  have ehead : a' = R.arg a := (List.cons.inj ea.symm).1
  rw [ehead, he, argNat_nat] at hn
  exact ⟨k, hp, (Option.some.inj hn).symm⟩

/-- A mapped call's first output slot supplies old support; fresh handles are
irrelevant to `nfrozen_pos`, whose support obligation stops at the initial counter. -/
theorem Writes.outSlot_nfrozen {P0 P1 : LoadP} {NB n0 n1 : Nat} {M σ : Map} {x0 x1 y y' : NSt}
    (o : Arg) (rest : List Arg) (w : Writes (OutSlot ((o :: rest).map (M.after σ).arg)) (fun _ => False) y y')
    (hr : MRw P1 NB M n1 x1 y) (iso : MIso P0 P1 n0 σ x0 x1)
    (hs : MR P0 NB (M.after σ) n0 x0 y) (ho : slotOk P0 x0 o = true) :
    NFrozen M σ x0 x1 y y' := by
  apply w.nfrozen_pos hr iso ?_ (fun _ _ hi => hi.elim)
  intro h hpos _ hout
  obtain ⟨h0, hp0, he⟩ := outSlot_image hs o rest ho hpos hout
  exact ⟨h0, hp0, he.trans (Map.handle_after M σ (iso.nonneg h0)).symm⟩

/-- No manual output-support premise: the accepted source slot and its native
relation supply the old image for an actual full-world array call. -/
theorem fullCall_array_nfrozen_mapped {P0 P1 : LoadP} {NB n0 n1 : Nat} {M σ : Map} {x0 x1 : NSt}
    (p q : Host.Ts.Sim.Full.FF.S) (name : Name) (o : Arg) (rest : List Arg)
    (hm : Host.Load.isMlx name = true) (hp : nameEq name FfiAne.payloadName = false)
    (ha : (symOf name).any ArraySym = true)
    (hr : MRw P1 NB M n1 x1 (Host.Ts.Sim.Full.mlxOf p)) (iso : MIso P0 P1 n0 σ x0 x1)
    (hs : MR P0 NB (M.after σ) n0 x0 (Host.Ts.Sim.Full.mlxOf p))
    (ho : slotOk P0 x0 o = true)
    {C C' : CSrv} {r : Ret} {ws : List (Nat × Nat × List Byte)}
    (hc : interpC (Host.Ts.Sim.Full.FF.call p name ((o :: rest).map (M.after σ).arg)).run C =
      some (some (q, r, ws), C')) :
    NFrozen M σ x0 x1 (Host.Ts.Sim.Full.mlxOf p) (Host.Ts.Sim.Full.mlxOf q) := by
  apply fullCall_array_nfrozen p q name _ hm hp ha hr iso ?_ hc
  intro h _ hout
  obtain ⟨h0, hp0, he⟩ := output_image hs o rest ho hout
  exact ⟨h0, hp0, he.trans (Map.handle_after M σ (iso.nonneg h0)).symm⟩

theorem fullCall_kernelApply_nfrozen_mapped {P0 P1 : LoadP} {NB n0 n1 : Nat} {M σ : Map} {x0 x1 : NSt}
    (p q : Host.Ts.Sim.Full.FF.S) (name : Name) (o : Arg) (rest : List Arg)
    (hm : Host.Load.isMlx name = true) (hp : nameEq name FfiAne.payloadName = false)
    (ha : symOf name = some .kernelApply)
    (hr : MRw P1 NB M n1 x1 (Host.Ts.Sim.Full.mlxOf p)) (iso : MIso P0 P1 n0 σ x0 x1)
    (hs : MR P0 NB (M.after σ) n0 x0 (Host.Ts.Sim.Full.mlxOf p))
    (ho : slotOk P0 x0 o = true)
    {C C' : CSrv} {r : Ret} {ws : List (Nat × Nat × List Byte)}
    (hc : interpC (Host.Ts.Sim.Full.FF.call p name ((o :: rest).map (M.after σ).arg)).run C =
      some (some (q, r, ws), C')) :
    NFrozen M σ x0 x1 (Host.Ts.Sim.Full.mlxOf p) (Host.Ts.Sim.Full.mlxOf q) := by
  have w := (fullCall_kernelApply_w p name _ hm hp ha).2 C _ C' hc q r ws rfl
  exact w.outSlot_nfrozen o rest hr iso hs ho

theorem fullCall_vector_nfrozen_mapped {P0 P1 : LoadP} {NB n0 n1 : Nat} {M σ : Map} {x0 x1 : NSt}
    (p q : Host.Ts.Sim.Full.FF.S) (name : Name) (o : Arg) (rest : List Arg)
    (hm : Host.Load.isMlx name = true) (hp : nameEq name FfiAne.payloadName = false)
    (ha : (symOf name).any VectorSym = true)
    (hr : MRw P1 NB M n1 x1 (Host.Ts.Sim.Full.mlxOf p)) (iso : MIso P0 P1 n0 σ x0 x1)
    (hs : MR P0 NB (M.after σ) n0 x0 (Host.Ts.Sim.Full.mlxOf p)) (ho : slotOk P0 x0 o = true)
    {C C' : CSrv} {r : Ret} {ws : List (Nat × Nat × List Byte)}
    (hc : interpC (Host.Ts.Sim.Full.FF.call p name ((o :: rest).map (M.after σ).arg)).run C =
      some (some (q, r, ws), C')) :
    NFrozen M σ x0 x1 (Host.Ts.Sim.Full.mlxOf p) (Host.Ts.Sim.Full.mlxOf q) := by
  have w := (fullCall_vector_w p name _ hm hp ha).2 C _ C' hc q r ws rfl
  exact w.outSlot_nfrozen o rest hr iso hs ho

theorem fullCall_compiled_nfrozen_mapped {P0 P1 : LoadP} {NB n0 n1 : Nat} {M σ : Map} {x0 x1 : NSt}
    (p q : Host.Ts.Sim.Full.FF.S) (name : Name) (o : Arg) (rest : List Arg)
    (hm : Host.Load.isMlx name = true) (hp : nameEq name FfiAne.payloadName = false)
    (ha : (symOf name).any CompiledSym = true)
    (hr : MRw P1 NB M n1 x1 (Host.Ts.Sim.Full.mlxOf p)) (iso : MIso P0 P1 n0 σ x0 x1)
    (hs : MR P0 NB (M.after σ) n0 x0 (Host.Ts.Sim.Full.mlxOf p)) (ho : slotOk P0 x0 o = true)
    {C C' : CSrv} {r : Ret} {ws : List (Nat × Nat × List Byte)}
    (hc : interpC (Host.Ts.Sim.Full.FF.call p name ((o :: rest).map (M.after σ).arg)).run C =
      some (some (q, r, ws), C')) :
    NFrozen M σ x0 x1 (Host.Ts.Sim.Full.mlxOf p) (Host.Ts.Sim.Full.mlxOf q) := by
  have w := (fullCall_compiled_w p name _ hm hp ha).2 C _ C' hc q r ws rfl
  exact w.outSlot_nfrozen o rest hr iso hs ho

theorem fullCall_config_nfrozen_mapped {P0 P1 : LoadP} {NB n0 n1 : Nat} {M σ : Map} {x0 x1 : NSt}
    (p q : Host.Ts.Sim.Full.FF.S) (name : Name) (a : Arg) (rest : List Arg)
    (hm : Host.Load.isMlx name = true) (hp : nameEq name FfiAne.payloadName = false)
    (ha : (symOf name).any ConfigSym = true)
    (hr : MRw P1 NB M n1 x1 (Host.Ts.Sim.Full.mlxOf p)) (iso : MIso P0 P1 n0 σ x0 x1)
    (hs : MR P0 NB (M.after σ) n0 x0 (Host.Ts.Sim.Full.mlxOf p)) (ho : hdOk x0 a = true)
    {C C' : CSrv} {r : Ret} {ws : List (Nat × Nat × List Byte)}
    (hc : interpC (Host.Ts.Sim.Full.FF.call p name ((a :: rest).map (M.after σ).arg)).run C =
      some (some (q, r, ws), C')) :
    NFrozen M σ x0 x1 (Host.Ts.Sim.Full.mlxOf p) (Host.Ts.Sim.Full.mlxOf q) := by
  have w := (fullCall_config_w p name _ hm hp ha).2 C _ C' hc q r ws rfl
  apply w.nfrozen hr iso ?_ (fun _ _ hi => hi.elim)
  intro h _ hout
  obtain ⟨h0, hp0, he⟩ := firstHandle_image hs a rest ho hout
  exact ⟨h0, hp0, he.trans (Map.handle_after M σ (iso.nonneg h0)).symm⟩

end Host.Mlx.Ffi.Footprint
