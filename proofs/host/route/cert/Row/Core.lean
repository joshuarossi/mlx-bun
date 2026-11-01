import host.route.cert.Row.Cls
import host.route.GpuMem
import host.sim.compose.MachV
import host.sim.compose.PostCut
import host.simgraph.GenLoadRel
import host.simgraph.Step
import host.simgraph.tpl.ordinary.Join
import host.simgraph.prompt.NativeD
import host.simgraph.prompt.NormalizeX
import host.simgraph.mach.DecodeLayout
import host.simgraph.iter.InputsPrefix
import host.load.CacheCarriersCommand
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
set_option autoImplicit false
namespace Host.Route.Cert.Row
open Host.Load Host.Load.Extract Host.Load.Program Host.Load.Run.Full
open Host.Mlx Host.Mlx.GlueStep Host.Mlx.FfiEval Host.Mlx.SimGraph Host.Ts
open Inference Inference.Contracts.Mlx Inference.Models.Qwen
open Host.Mlx.SimGraph.Iter (Gr TplInputs cachesAt cachesAt_nodes loadedAt tensorAt CachesBelow)
open Host.Mlx.SimGraph.Mach (MRef MRefDecodes WeightShapes template_cached_forwardV compat_of_caps shapesOk_of_caps
  CacheValuesV refPrompt)
open Host.Ts.Sim (LoadP Map SegInst capL)
open Host.Ts.Sim.Full (FF mlxOf)
open Host.Load.Run.Full.Cached.Expected2 (stages head)
open Host.Route.PrefGraph

/-! # POST's decode forwards from their certificates: the row's graph in the target's -/

/-- The box's valuation at a prompt of `L` tokens. -/
def nuRow (L j : Nat) : Int := if j = 16 then 256 else if j = 10 then 1 else L

theorem boxRow_cases {j : Nat} {l h : Int} (hg : Box.get boxRow j = some (l, h)) :
    (j = 9 ∧ l = 1 ∧ h = 224) ∨ (j = 10 ∧ l = 1 ∧ h = 1) ∨ (j = 11 ∧ l = 1 ∧ h = 224) ∨ (j = 16 ∧ l = 256 ∧ h = 256) := by
  unfold Box.get boxRow at hg
  by_cases h9 : j = 9
  · subst h9
    simp at hg
    exact .inl ⟨rfl, hg.1.symm, hg.2.symm⟩
  by_cases h10 : j = 10
  · subst h10
    simp at hg
    exact .inr (.inl ⟨rfl, hg.1.symm, hg.2.symm⟩)
  by_cases h11 : j = 11
  · subst h11
    simp at hg
    exact .inr (.inr (.inl ⟨rfl, hg.1.symm, hg.2.symm⟩))
  by_cases h16 : j = 16
  · subst h16
    simp at hg
    exact .inr (.inr (.inr ⟨rfl, hg.1.symm, hg.2.symm⟩))
  simp [Ne.symm h9, Ne.symm h10, Ne.symm h11, Ne.symm h16] at hg

theorem nuRow_box {L : Nat} (h1 : 1 ≤ L) (h2 : L ≤ 224) : InBox boxRow (nuRow L) := by
  intro j l h hg
  rcases boxRow_cases hg with ⟨rfl, rfl, rfl⟩ | ⟨rfl, rfl, rfl⟩ | ⟨rfl, rfl, rfl⟩ | ⟨rfl, rfl, rfl⟩
  · simp [nuRow]; omega
  · simp [nuRow]
  · simp [nuRow]; omega
  · simp [nuRow]

theorem rowTerms_eval (L : Nat) : ∀ {ts : List (Int × Nat)} {r : Int × Int}, rowTerms ts = some r →
    termsEval (nuRow L) ts = r.1 + r.2 * L
  | [], r, h => by
    simp only [rowTerms, Option.some.injEq] at h
    subst h
    simp [termsEval]
  | t :: ts, r, h => by
    obtain ⟨q, hq, h⟩ := Option.bind_eq_some_iff.mp h
    have ih := rowTerms_eval L hq
    simp only [termsEval, ih]
    split at h
    · rename_i ht
      simp only [Option.some.injEq] at h
      subst h
      have hv : nuRow L t.2 = L := by
        rcases ht with e | e <;> simp [nuRow, e]
      rw [hv]
      simp only [Int.add_mul]
      omega
    · split at h
      · rename_i ht
        simp only [Option.some.injEq] at h
        subst h
        have hv : nuRow L t.2 = 1 := by simp [nuRow, ht]
        rw [hv]
        simp only
        omega
      · split at h
        · rename_i ht
          simp only [Option.some.injEq] at h
          subst h
          have hv : nuRow L t.2 = 256 := by simp [nuRow, ht]
          rw [hv]
          simp only
          omega
        · cases h

theorem rowLin_eval (L : Nat) : ∀ {p : PDim} {r : Int × Int}, rowLin p = some r →
    PDim.eval (nuRow L) p = r.1 + r.2 * L
  | .lit i, r, h => by
    simp only [rowLin, Option.some.injEq] at h
    subst h
    simp [PDim.eval]
  | .lin c ts, r, h => by
    obtain ⟨q, hq, rfl⟩ := Option.map_eq_some_iff.mp h
    simp only [PDim.eval, rowTerms_eval L hq]
    omega
  | .fdiv d k, r, h => by
    obtain ⟨q, hq, h⟩ := Option.bind_eq_some_iff.mp h
    have ih := rowLin_eval L hq
    split at h
    · rename_i h0
      simp only [Option.some.injEq] at h
      subst h
      simp only [PDim.eval, ih, h0]
      simp
    · cases h
  | .cdiv d k, r, h => by
    obtain ⟨q, hq, h⟩ := Option.bind_eq_some_iff.mp h
    have ih := rowLin_eval L hq
    split at h
    · rename_i h0
      simp only [Option.some.injEq] at h
      subst h
      simp only [PDim.eval, ih, h0]
      simp
    · cases h
  | .rup k d, r, h => by
    obtain ⟨q, hq, h⟩ := Option.bind_eq_some_iff.mp h
    have ih := rowLin_eval L hq
    split at h
    · rename_i h0
      simp only [Option.some.injEq] at h
      subst h
      simp only [PDim.eval, ih, h0]
      simp
    · cases h

theorem rowS_eval {L d : Nat} {p : PDim} {s : SDim} (h : rowS (d : Int) p = some s) :
    SDim.eval (L + d) s = PDim.eval (nuRow L) p := by
  obtain ⟨r, hr, h⟩ := Option.bind_eq_some_iff.mp h
  rw [rowLin_eval L hr]
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

theorem clsRow_sound (S : SSrv) {L d : Nat} (h1 : 1 ≤ L) (h2 : L ≤ 224) (ρ : Nat → F64)
    (hρ : ∀ x l h, Box.get boxRow x = some (l, h) → ρ x = F64.ofInt (nuRow L x)) :
    ClsSoundD (clsRow S (d : Int)) (νsOf S ρ) (SDim.eval (L + d)) := by
  intro x s hx
  obtain ⟨p, hp, hs⟩ := Option.bind_eq_some_iff.mp hx
  rw [rowS_eval hs]
  exact clsOfX_sound S boxRow (nuRow L) ρ (nuRow_box h1 h2) hρ x p hp

theorem evalRow_sound (ρ : Nat → F64) (hρ : ρ 10 = F64.ofNat 1) : ∀ e f, evalRow e = some f → e.eval ρ = f := by
  intro e
  induction e with
  | lit a => intro f hf; exact Option.some.inj hf
  | var i =>
    intro f hf
    by_cases hi : i = 10
    · subst i
      change some (F64.ofNat 1) = some f at hf
      exact hρ.trans (Option.some.inj hf)
    · simp [evalRow, hi] at hf
  | un op a ih =>
    intro f hf
    obtain ⟨v, hv, rfl⟩ := Option.map_eq_some_iff.mp hf
    exact congrArg (F64.un op) (ih v hv)
  | bin op a b iha ihb =>
    intro f hf
    change ((evalRow a).bind fun va => (evalRow b).bind fun vb => some (F64.bin op va vb)) = some f at hf
    obtain ⟨va, ha, hr⟩ := Option.bind_eq_some_iff.mp hf
    obtain ⟨vb, hb, hr⟩ := Option.bind_eq_some_iff.mp hr
    exact (congrArg₂ (F64.bin op) (iha va ha) (ihb vb hb)).trans (Option.some.inj hr)

theorem rowNumVal_sound (S : SSrv) (ρ : Nat → F64) (hρ : ρ 10 = F64.ofNat 1) (x : NumV) (f : F64)
    (hf : rowNumVal S x = some f) : νsOf S ρ x = some f := by
  cases x with
  | lit a => exact hf
  | ref i =>
    obtain ⟨e, he, hf⟩ := Option.bind_eq_some_iff.mp hf
    change ((nth? S.tab i).map (SymE.eval ρ)) = some f
    rw [he]
    exact congrArg some (evalRow_sound ρ hρ e f hf)

theorem row_agree (S : SSrv) (d : Int) (ρ : Nat → F64) (hρ : ρ 10 = F64.ofNat 1) (ev : SDim → Int)
    (hcls : ClsSoundD (clsRow S d) (νsOf S ρ) ev) (hlit : ∀ i, ev (SDim.lit i) = i)
    (νt : NumV → Option F64) (μ : NumV → NumV) (β : Int → Int) (α : Arg → Arg) (η : Nat → Nat)
    (hlitμ : ∀ f, μ (.lit f) = .lit f) (hlitt : ∀ f, νt (.lit f) = some f)
    (hν : ∀ x f, νsOf S ρ x = some f → νt (μ x) = some f)
    (A : Arg → Prop) (hα : ∀ a v, A a → Ffi.argNat a = some v → Ffi.argNat (α a) = some v)
    (kn kn' : Nat → Option (List Char)) (hk : ∀ k name, kn k = some name → kn' (η k) = some name) :
    Host.Mlx.SimGraph.Agree (rowNums S d) (concrete νt) ev (numImg μ β α η) kn kn' A := by
  have base := agree_runD (clsRow S d) SDim.lit ev hlit (νsOf S ρ) νt μ β α η hlitμ hlitt hν hcls A hα kn kn' hk
  refine ⟨base.d, base.dim, base.word, ?_, hα, hk⟩
  intro b v hb
  cases b with
  | lit n => exact hb
  | part k c i =>
    cases c with
    | big n => simp [rowNums, rowByte] at hb
    | num x =>
      change concreteByte (rowNumVal S) (.part k (.num x) i) = some v at hb
      change concreteByte νt (.part k (.num (μ x)) i) = some v
      cases hv : rowNumVal S x with
      | none => simp [concreteByte, concreteCell, hv] at hb
      | some f =>
        have ht := hν x f (rowNumVal_sound S ρ hρ x f hv)
        simpa only [concreteByte, concreteCell, ht, hv, Option.map_some] using
          (show concreteByte (rowNumVal S) (.part k (.num x) i) = some v from hb)

/-- The row's graph embeds in the target's at the row's time. -/
theorem row_embeds (s : Ffi.St) (S : SSrv) (d : Nat) (tab : List F64) {Pm : LoadP} {NB m : Nat} {M : Map} {y : Ffi.St}
    (hmr : Host.Ts.Sim.G.MR Pm NB M m s y) (hband : Pm.NL = Pm.N0) (hrope : M.big 5554869888 = 5554869888) (ρ : Nat → F64)
    {L : Nat} (h1 : 1 ≤ L) (h2 : L ≤ 224) (hρ : ∀ x l h, Box.get boxRow x = some (l, h) → ρ x = F64.ofInt (nuRow L x))
    (hnum : ∀ i e, nth? S.tab i = some e → CSrv.val ⟨tab⟩ (M.nv (.ref i)) = some (e.eval ρ)) :
    Embeds M.node M.handle (mapG (SDim.eval (L + d)) (rowGs s S d)) (Gr tab y) := by
  have himg : NativeImage M.node (loadImg M) (exactTplDom 15235 15235 [5554869888] s) s y :=
    nativeImage_of_GMR hmr _
      (fun i _ => by rcases Nat.lt_or_ge i Pm.NL with h | h; exacts [.inl h, .inr (hband ▸ h)])
      (fun _ _ hi hn => exactTplDom_exact hi hn)
  have hargs : ∀ i nd, exactTplDom 15235 15235 [5554869888] s i = true → s.nodes.get i = some nd →
      PrimArgs (fun a => okArg [5554869888] a = true) nd.prim := fun _ _ hi hn => exactTplDom_args hi hn
  have h10 : ρ 10 = F64.ofNat 1 := hρ 10 1 1 (by decide)
  have hag := row_agree S (d : Int) ρ h10 (SDim.eval (L + d)) (clsRow_sound S h1 h2 ρ hρ) (fun _ => rfl) (CSrv.val ⟨tab⟩)
    M.nv M.big M.arg M.handle (nv_lit M) (fun _ => rfl) (numbers_agree S ρ M.nv _ (nv_lit M) (fun _ => rfl) hnum)
    (fun a => okArg [5554869888] a = true)
    (arg_fixed M [5554869888] (fun i hi => by obtain rfl := List.mem_singleton.mp hi; exact hrope))
    _ _ (kernels_of_GMR hmr SourceKernels.sources)
  refine ⟨?_, ?_⟩
  · intro i r hr
    obtain ⟨r0, h0, rfl⟩ := Option.map_eq_some_iff.mp hr
    have hb : exactTplDom 15235 15235 [5554869888] s i = true := by
      cases hd : exactTplDom 15235 15235 [5554869888] s i
      · simp [rowGs, restrictTo, hd] at h0
      · rfl
    simp only [rowGs, restrictTo, hb, ↓reduceIte] at h0
    obtain ⟨nd, hnd, hres⟩ := Option.bind_eq_some_iff.mp h0
    have h2' := resolveNode_img hag M.node nd r0 (hargs i nd hb hnd) hres
    show (y.nodes.get (M.node i)).bind _ = _
    rw [himg.nodes i nd hb hnd, Option.bind_some]
    exact h2'
  · intro i j hi hj
    have hb : exactTplDom 15235 15235 [5554869888] s i = true := by
      cases hd : exactTplDom 15235 15235 [5554869888] s i
      · simp [mapG, rowGs, restrictTo, hd] at hi
      · rfl
    apply himg.order i j hb _ hj
    simp only [mapG, rowGs, restrictTo, hb, ↓reduceIte, ffiGraph, Option.isSome_map] at hi
    cases hs : s.nodes.get i with
    | none => rw [hs] at hi; cases hi
    | some _ => rfl

end Host.Route.Cert.Row
