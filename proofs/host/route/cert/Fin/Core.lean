import host.route.cert.Fin.Cls
import host.route.cert.Row.Layout
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
set_option autoImplicit false
namespace Host.Route.Cert.Fin
open Host.Load Host.Load.Extract Host.Load.Program Host.Load.Run.Full
open Host.Mlx Host.Mlx.GlueStep Host.Mlx.FfiEval Host.Mlx.SimGraph Host.Ts
open Host.Mlx.SimGraph.Iter (Gr)
open Host.Ts.Sim (LoadP Map SegInst)

/-! # A class's graph in the target's

`nuV`: the table's variables at a prompt of `L` tokens. `clsV_sound`, `row_agree`'s analogue `agreeV`, `embedsV`: a class's graph embeds in
the target's at the time `L + d`. -/

/-- The variables' values at a prompt of `L` tokens. -/
def nuV (V : VarV) (L j : Nat) : Int :=
  match varGet V j with
  | some q => q.1 + q.2 * L
  | none => 0

theorem termsV_eval (V : VarV) (L : Nat) : ∀ {ts : List (Int × Nat)} {r : Int × Int}, termsV V ts = some r →
    termsEval (nuV V L) ts = r.1 + r.2 * L
  | [], r, h => by
    simp only [termsV, Option.some.injEq] at h
    subst h
    simp [termsEval]
  | t :: ts, r, h => by
    obtain ⟨q, hq, h⟩ := Option.bind_eq_some_iff.mp h
    obtain ⟨c, hc, rfl⟩ := Option.map_eq_some_iff.mp h
    have ih := termsV_eval V L hq
    simp only [termsEval, ih, nuV, hc, Int.mul_add, Int.add_mul, Int.mul_assoc]
    omega

theorem linV_eval (V : VarV) (L : Nat) : ∀ {p : PDim} {r : Int × Int}, linV V p = some r →
    PDim.eval (nuV V L) p = r.1 + r.2 * L
  | .lit i, r, h => by
    simp only [linV, Option.some.injEq] at h
    subst h
    simp [PDim.eval]
  | .lin c ts, r, h => by
    obtain ⟨q, hq, rfl⟩ := Option.map_eq_some_iff.mp h
    simp only [PDim.eval, termsV_eval V L hq]
    omega
  | .fdiv d k, r, h => by
    obtain ⟨q, hq, h⟩ := Option.bind_eq_some_iff.mp h
    have ih := linV_eval V L hq
    split at h
    · rename_i h0
      simp only [Option.some.injEq] at h
      subst h
      simp only [PDim.eval, ih, h0]
      simp
    · cases h
  | .cdiv d k, r, h => by
    obtain ⟨q, hq, h⟩ := Option.bind_eq_some_iff.mp h
    have ih := linV_eval V L hq
    split at h
    · rename_i h0
      simp only [Option.some.injEq] at h
      subst h
      simp only [PDim.eval, ih, h0]
      simp
    · cases h
  | .rup k d, r, h => by
    obtain ⟨q, hq, h⟩ := Option.bind_eq_some_iff.mp h
    have ih := linV_eval V L hq
    split at h
    · rename_i h0
      simp only [Option.some.injEq] at h
      subst h
      simp only [PDim.eval, ih, h0]
      simp
    · cases h

theorem sdimV_eval {V : VarV} {L n : Nat} {d : Int} (hn : (n : Int) = L + d) {p : PDim} {s : SDim} (h : sdimV V d p = some s) :
    SDim.eval n s = PDim.eval (nuV V L) p := by
  obtain ⟨r, hr, h⟩ := Option.bind_eq_some_iff.mp h
  rw [linV_eval V L hr]
  split at h
  · rename_i h0
    simp only [Option.some.injEq] at h
    subst h
    simp [SDim.eval, h0]
  · split at h
    · rename_i h1
      split at h
      · rename_i hc
        simp only [Option.some.injEq] at h
        subst h
        simp only [SDim.eval, h1, hc]
        omega
      · split at h
        · rename_i hc
          simp only [Option.some.injEq] at h
          subst h
          simp only [SDim.eval, h1, hc]
          omega
        · cases h
    · cases h

theorem clsV_sound (S : SSrv) (B : Box) (V : VarV) {L n : Nat} {d : Int} (hn : (n : Int) = L + d) (hB : InBox B (nuV V L)) (ρ : Nat → F64)
    (hρ : ∀ x l h, B.get x = some (l, h) → ρ x = F64.ofInt (nuV V L x)) :
    ClsSoundD (clsV S B V d) (νsOf S ρ) (SDim.eval n) := by
  intro x s hx
  obtain ⟨p, hp, hs⟩ := Option.bind_eq_some_iff.mp hx
  rw [sdimV_eval hn hs]
  exact clsOfX_sound S B (nuV V L) ρ hB hρ x p hp

theorem truncInt_of_toInt {f : F64} {i : Int} (h : F64.toInt? f = some i) : F64.truncInt f = some i := by
  cases f with
  | zero s => simpa [F64.toInt?, F64.truncInt] using h
  | fin s m e =>
    cases e with
    | ofNat k => simpa [F64.toInt?, F64.truncInt] using h
    | negSucc k => simp [F64.toInt?] at h
  | _ => simp [F64.toInt?] at h

theorem constV_sound {S : SSrv} {B : Box} {V : VarV} {L : Nat} (hB : InBox B (nuV V L)) {ρ : Nat → F64}
    (hρ : ∀ x l h, B.get x = some (l, h) → ρ x = F64.ofInt (nuV V L x)) {x : NumV} {c : Int} (h : constV S B V x = some c) :
    ∃ f, νsOf S ρ x = some f ∧ F64.toInt? f = some c := by
  obtain ⟨r, hr, h⟩ := Option.bind_eq_some_iff.mp h
  obtain ⟨p, hp, hl⟩ := Option.bind_eq_some_iff.mp hr
  split at h
  · rename_i h0
    obtain rfl := Option.some.inj h
    have hs := clsOfX_sound S B (nuV V L) ρ hB hρ x p hp
    rw [linV_eval V L hl, h0] at hs
    obtain ⟨f, hf, ht⟩ := Option.bind_eq_some_iff.mp hs
    exact ⟨f, hf, by simpa using ht⟩
  · cases h

theorem agreeV (S : SSrv) (B : Box) (V : VarV) {L n : Nat} {d : Int} (hn : (n : Int) = L + d) (hB : InBox B (nuV V L)) (ρ : Nat → F64)
    (hρ : ∀ x l h, B.get x = some (l, h) → ρ x = F64.ofInt (nuV V L x))
    (νt : NumV → Option F64) (μ : NumV → NumV) (β : Int → Int) (α : Arg → Arg) (η : Nat → Nat)
    (hlitμ : ∀ f, μ (.lit f) = .lit f) (hlitt : ∀ f, νt (.lit f) = some f)
    (hν : ∀ x f, νsOf S ρ x = some f → νt (μ x) = some f)
    (A : Arg → Prop) (hα : ∀ a v, A a → Ffi.argNat a = some v → Ffi.argNat (α a) = some v)
    (kn kn' : Nat → Option (List Char)) (hk : ∀ k name, kn k = some name → kn' (η k) = some name) :
    Host.Mlx.SimGraph.Agree (numsV S B V d) (concrete νt) (SDim.eval n) (numImg μ β α η) kn kn' A := by
  have base := agree_runD (clsV S B V d) SDim.lit (SDim.eval n) (fun _ => rfl) (νsOf S ρ) νt μ β α η hlitμ hlitt hν
    (clsV_sound S B V hn hB ρ hρ) A hα kn kn' hk
  refine ⟨base.d, base.dim, base.word, ?_, hα, hk⟩
  intro b v hb
  have key : ∀ (k : EltK) (x : NumV) (i : Nat), (k = .i32 ∨ k = .u32) →
      ((constV S B V x).bind fun c => nth? (leBytes 4 (F64.modNat c (2 ^ 32))) i) = some v →
      concreteByte νt (.part k (.num (μ x)) i) = some v := by
    intro k x i hk' hc
    obtain ⟨c, hc1, hc2⟩ := Option.bind_eq_some_iff.mp hc
    obtain ⟨f, hf, ht⟩ := constV_sound hB hρ hc1
    have hu : F64.toUint32 f = F64.modNat c (2 ^ 32) := by
      simp only [F64.toUint32, truncInt_of_toInt ht]
    rcases hk' with rfl | rfl <;>
      · simp only [concreteByte, concreteCell, hν x f hf, Option.map_some, encodeCell]
        change nth? (leBytes 4 (F64.toUint32 f)) i = some v
        rw [hu]
        exact hc2
  cases b with
  | lit n => exact hb
  | part k c i =>
    cases c with
    | big n => cases k <;> simp [numsV, byteV] at hb
    | num x =>
      cases x with
      | lit f =>
        have e : (numImg μ β α η).byte (.part k (.num (.lit f)) i) = .part k (.num (.lit f)) i := by
          simp [numImg, byteI, hlitμ]
        rw [e]
        change concreteByte litVal (.part k (.num (.lit f)) i) = some v at hb
        simp only [concreteByte, concreteCell, litVal, Option.map_some] at hb
        change concreteByte νt (.part k (.num (.lit f)) i) = some v
        simp only [concreteByte, concreteCell, hlitt, Option.map_some]
        exact hb
      | ref j =>
        cases k
        all_goals first
          | exact key _ (.ref j) i (by simp) hb
          | simp [numsV, byteV] at hb

/-- **A class's graph embeds in the target's** at its time. -/
theorem embedsV (s : Ffi.St) (S : SSrv) (B : Box) (V : VarV) {L n : Nat} {d : Int} (hn : (n : Int) = L + d) (hB : InBox B (nuV V L))
    (tab : List F64) {Pm : LoadP} {NB m : Nat} {M : Map} {y : Ffi.St} (hmr : Host.Ts.Sim.G.MR Pm NB M m s y) (hband : Pm.NL = Pm.N0)
    (hrope : M.big 5554869888 = 5554869888) (ρ : Nat → F64) (hρ : ∀ x l h, B.get x = some (l, h) → ρ x = F64.ofInt (nuV V L x))
    (hnum : ∀ i e, nth? S.tab i = some e → CSrv.val ⟨tab⟩ (M.nv (.ref i)) = some (e.eval ρ))
    (hdown : (List.range s.nnext).all (downB (exactTplDom 15235 15235 [5554869888] s) s) = true) :
    Embeds M.node M.handle (mapG (SDim.eval n) (gsV s S B V d)) (Gr tab y) := by
  have himg : NativeImage M.node (loadImg M) (exactTplDom 15235 15235 [5554869888] s) s y :=
    nativeImage_of_GMR hmr _
      (fun i _ => by rcases Nat.lt_or_ge i Pm.NL with h | h; exacts [.inl h, .inr (hband ▸ h)])
      (fun _ _ hi hn => exactTplDom_exact hi hn) (down_of_all hdown hmr.nlt)
  have hargs : ∀ i nd, exactTplDom 15235 15235 [5554869888] s i = true → s.nodes.get i = some nd →
      PrimArgs (fun a => okArg [5554869888] a = true) nd.prim := fun _ _ hi hn => exactTplDom_args hi hn
  have hag := agreeV S B V hn hB ρ hρ (CSrv.val ⟨tab⟩) M.nv M.big M.arg M.handle (nv_lit M) (fun _ => rfl)
    (numbers_agree S ρ M.nv _ (nv_lit M) (fun _ => rfl) hnum) (fun a => okArg [5554869888] a = true)
    (arg_fixed M [5554869888] (fun i hi => by obtain rfl := List.mem_singleton.mp hi; exact hrope))
    _ _ (kernels_of_GMR hmr SourceKernels.sources)
  refine ⟨?_, ?_⟩
  · intro i r hr
    obtain ⟨r0, h0, rfl⟩ := Option.map_eq_some_iff.mp hr
    have hb : exactTplDom 15235 15235 [5554869888] s i = true := by
      cases hd : exactTplDom 15235 15235 [5554869888] s i
      · simp [gsV, restrictTo, hd] at h0
      · rfl
    simp only [gsV, restrictTo, hb, ↓reduceIte] at h0
    obtain ⟨nd, hnd, hres⟩ := Option.bind_eq_some_iff.mp h0
    have h2' := resolveNode_img hag M.node nd r0 (hargs i nd hb hnd) hres
    show (y.nodes.get (M.node i)).bind _ = _
    rw [himg.nodes i nd hb hnd, Option.bind_some]
    exact h2'
  · intro i r hr j hj
    obtain ⟨hb, nd, hnd, hins⟩ := ins_of_restrict (SDim.eval n) (numsV S B V d) SourceKernels.sources s (exactTplDom 15235 15235 [5554869888] s) hr
    exact himg.order i nd hb hnd j (hins ▸ hj)

end Host.Route.Cert.Fin
