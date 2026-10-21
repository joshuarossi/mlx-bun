import host.simgraph.Native
namespace Host.Mlx.SimGraph
open Host.Ts Host.Mlx.FfiEval

/-! # Classifying the template's offset numbers

The template is a symbolic run: a number is a literal or a reference into
the symbolic server's table `S.tab`, whose entries are expressions over
symbolic positions (`SymE.var`). The decode iteration's cache offset is
position `p`; the interpreter writes it and its successor to MLX as `int32`
cells, so the offset dimensions are references whose entries are
`int32(var p)` and `int32(var p + 1)`.

* `clsOf S p`: literals by value, references by the shape of their entry
  (`entryDim`: `var p`, `int32(var p)` give `pos`; `var p + 1`, `1 + var p`
  and their `int32` give `pos1`); nothing else is a dimension.
* `νsOf S ρ`: the template's numbers at the iteration's valuation `ρ`.
* `clsOf_sound`: `ClsSound (clsOf S p) (νsOf S ρ) n` whenever `ρ p` is the
  offset `n` (below `2^31 - 1`).
* `numbers_agree`: the agreement `embeds_of_image` needs follows from the
  number map's correctness on the table (`NumOK` of the simulation).
* `embeds_of_run`: the iteration's graph carries the template run's graph
  on domain `D`, read with `clsOf S p`, at offset `n = ρ p`. -/

/-- The offset dimension an entry denotes, by its shape. -/
def entryDim (p : Nat) : SymE → Option SDim
  | .var q => if q = p then some .pos else none
  | .un .int32 (.var q) => if q = p then some .pos else none
  | .bin .add (.var q) (.lit o) => if q = p ∧ o = F64.ofNat 1 then some .pos1 else none
  | .bin .add (.lit o) (.var q) => if q = p ∧ o = F64.ofNat 1 then some .pos1 else none
  | .un .int32 (.bin .add (.var q) (.lit o)) => if q = p ∧ o = F64.ofNat 1 then some .pos1 else none
  | .un .int32 (.bin .add (.lit o) (.var q)) => if q = p ∧ o = F64.ofNat 1 then some .pos1 else none
  | _ => none

/-- The template's classifier: offset position `p` in table `S`. -/
def clsOf (S : SSrv) (p : Nat) : NumV → Option SDim
  | .lit f => (F64.toInt? f).map SDim.lit
  | .ref i => (nth? S.tab i).bind (entryDim p)

/-- The template's numbers at valuation `ρ`. -/
def νsOf (S : SSrv) (ρ : Nat → F64) (x : NumV) : Option F64 := (S.val x).map (SymE.eval ρ)

theorem νsOf_lit (S : SSrv) (ρ : Nat → F64) (f : F64) : νsOf S ρ (.lit f) = some f := rfl

theorem toInt32_ofNat (n : Nat) (h : n < 2 ^ 31) : F64.toInt32 (F64.ofNat n) = n := by
  rw [F64.ofNat_exact32 n h]
  by_cases hz : n = 0
  · subst hz; rfl
  · have hm : ((n : Int) % ((2 ^ 32 : Nat) : Int)).toNat = n := by
      have : (n : Int) % ((2 ^ 32 : Nat) : Int) = n := Int.emod_eq_of_lt (by omega) (by simp; omega)
      rw [this]; rfl
    have hl : Nat.blt n (2 ^ 31) = true := Nat.blt_eq.mpr h
    simp only [F64.toInt32, F64.toUint32, F64.natExact, hz, ↓reduceIte, F64.truncInt, F64.modNat, Nat.pow_zero,
      Nat.mul_one, Bool.cond_false]
    rw [hm, hl]
    rfl

theorem int32_ofNat (n : Nat) (h : n < 2 ^ 31) : F64.un .int32 (F64.ofNat n) = F64.ofNat n := by
  show F64.ofInt (F64.toInt32 (F64.ofNat n)) = F64.ofNat n
  rw [toInt32_ofNat n h]
  rfl

theorem entryDim_sound (ρ : Nat → F64) (p n : Nat) (hρ : ρ p = F64.ofNat n) (hn : n + 1 < 2 ^ 31)
    (e : SymE) (d : SDim) (h : entryDim p e = some d) : F64.toInt? (e.eval ρ) = some (SDim.eval n d) := by
  have v0 : F64.toInt? (F64.ofNat n) = some (n : Int) := F64.toInt_ofNat32 n (by omega)
  have v1 : F64.toInt? (F64.ofNat (n + 1)) = some ((n : Int) + 1) := by
    rw [F64.toInt_ofNat32 (n + 1) hn]; simp
  have a1 : F64.add (F64.ofNat n) (F64.ofNat 1) = F64.ofNat (n + 1) := F64.add_ofNat53 n 1 (by omega)
  have a2 : F64.add (F64.ofNat 1) (F64.ofNat n) = F64.ofNat (n + 1) := by
    rw [F64.add_ofNat53 1 n (by omega), Nat.add_comm]
  have i0 : F64.un .int32 (F64.ofNat n) = F64.ofNat n := int32_ofNat n (by omega)
  have i1 : F64.un .int32 (F64.ofNat (n + 1)) = F64.ofNat (n + 1) := int32_ofNat (n + 1) hn
  unfold entryDim at h
  split at h <;> (try split at h) <;> simp only [Option.some.injEq, reduceCtorEq] at h <;> subst h <;>
    rename_i hq <;>
    first
      | (subst hq; simp only [SymE.eval, hρ, i0, v0, SDim.eval])
      | (obtain ⟨hq, ho⟩ := hq; subst hq ho;
         simp only [SymE.eval, F64.bin, hρ, a1, a2, i1, v1, SDim.eval])

/-- **The classifier is sound** at every offset the valuation gives position `p`. -/
theorem clsOf_sound (S : SSrv) (p : Nat) (ρ : Nat → F64) (n : Nat) (hρ : ρ p = F64.ofNat n) (hn : n + 1 < 2 ^ 31) :
    ClsSound (clsOf S p) (νsOf S ρ) n := by
  intro x d hx
  cases x with
  | lit f =>
    obtain ⟨i, hi, rfl⟩ := Option.map_eq_some_iff.mp hx
    show (some f).bind F64.toInt? = some i
    exact hi
  | ref i =>
    obtain ⟨e, he, hd⟩ := Option.bind_eq_some_iff.mp hx
    show ((nth? S.tab i).map (SymE.eval ρ)).bind F64.toInt? = _
    rw [he]
    exact entryDim_sound ρ p n hρ hn e d hd

/-- The numbers agree along `μ` when `μ` keeps literals and is correct on the
table at `ρ` (the simulation's `NumOK` for `μ = M.nv`, `νt = C.val`). -/
theorem numbers_agree (S : SSrv) (ρ : Nat → F64) (μ : NumV → NumV) (νt : NumV → Option F64)
    (hlit : ∀ f, μ (.lit f) = .lit f) (hlitt : ∀ f, νt (.lit f) = some f)
    (hnum : ∀ i e, nth? S.tab i = some e → νt (μ (.ref i)) = some (e.eval ρ)) :
    ∀ x f, νsOf S ρ x = some f → νt (μ x) = some f := by
  intro x f hx
  cases x with
  | lit g =>
    cases hx
    rw [hlit, hlitt]
    rfl
  | ref i =>
    obtain ⟨e, he, rfl⟩ := Option.map_eq_some_iff.mp hx
    exact hnum i e he

/-- **The template run carries every iteration.** Template state `s` of a
symbolic run with table `S` and offset position `p`; iteration state `t`
of the concrete run with number reading `νt`, valuation `ρ` giving `p`
the offset `n`; the iteration map `μ β α η σ` correct on the table
(`hnum`, the simulation's `NumOK`), keeping the rope arguments `D`'s
nodes use (`A`), and relating the nodes on `D` (`NativeImage`). -/
theorem embeds_of_run (S : SSrv) (p : Nat) (Ks : KernelSources) (s t : Ffi.St) (n : Nat) (D : Nat → Bool)
    (ρ : Nat → F64) (hρ : ρ p = F64.ofNat n) (hn : n + 1 < 2 ^ 31)
    (νt : NumV → Option F64) (μ : NumV → NumV) (β : Int → Int) (α : Arg → Arg) (η σ : Nat → Nat)
    (hlitμ : ∀ f, μ (.lit f) = .lit f) (hlitt : ∀ f, νt (.lit f) = some f)
    (hnum : ∀ i e, nth? S.tab i = some e → νt (μ (.ref i)) = some (e.eval ρ))
    (A : Arg → Prop) (hα : ∀ a v, A a → Ffi.argNat a = some v → Ffi.argNat (α a) = some v)
    (hargs : ∀ i nd, D i = true → s.nodes.get i = some nd → PrimArgs A nd.prim)
    (hk : ∀ k name, kernelName? Ks s k = some name → kernelName? Ks t (η k) = some name)
    (himg : NativeImage σ (numImg μ β α η) D s t) :
    Embeds σ η (mapG (SDim.eval n) (restrictTo D (symGraph (clsOf S p) Ks s))) (ffiGraph (concrete νt) Ks t) :=
  embeds_of_image (clsOf S p) Ks s t n D (νsOf S ρ) νt μ β α η σ hlitμ hlitt
    (numbers_agree S ρ μ νt hlitμ hlitt hnum) (clsOf_sound S p ρ n hρ hn) A hα hargs hk himg

end Host.Mlx.SimGraph
