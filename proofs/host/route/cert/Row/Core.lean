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

/-! # POST's decode forwards from their certificates

A POST row runs the ordinary decode forward at time `L + d` while its table reads the prompt's length: the table's
numbers are `L + c`, so its dimensions are the template's `pos` at `c = d` and `pos1` at `c = d + 1` (`clsRow`). The chain's
variable never holds the time, which is why this reads the template through `template_cached_forwardV` directly and not
through `CaseFwdAtV`'s `A.tvar`. `row_fwd`: the next time's token and handles at the row's carriers. `row_next`: the
reference held through it. -/

def boxRow : Box := [(9, 1, 224), (10, 1, 1), (11, 1, 224), (16, 256, 256)]

/-- A normal form at the row's offset `d`, read as the template's dimension. -/
def rowS (d : Int) : PDim → Option SDim
  | .lit i => some (.lit i)
  | .lin c [t] =>
    if t.1 = 1 ∧ (t.2 = 9 ∨ t.2 = 11) then
      if c = d then some .pos else if c = d + 1 then some .pos1 else none
    else none
  | _ => none

/-- The template's number at the row's offset. -/
def clsRow (S : SSrv) (d : Int) (x : NumV) : Option SDim := (clsOfX S boxRow x).bind (rowS d)

noncomputable def rowGs (s : Ffi.St) (S : SSrv) (d : Int) : Nat → Option (RNode SDim InKey) :=
  restrictTo (exactTplDom 15235 15235 [5554869888] s) (symGraphD (clsRow S d) SDim.lit SourceKernels.sources s)

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

theorem rowS_eval {L d : Nat} {p : PDim} {s : SDim} (h : rowS (d : Int) p = some s) :
    SDim.eval (L + d) s = PDim.eval (nuRow L) p := by
  cases p with
  | lit i =>
    simp only [rowS, Option.some.injEq] at h
    subst h
    rfl
  | lin c ts =>
    match ts, h with
    | [t], h =>
      simp only [rowS] at h
      split at h
      · rename_i ht
        obtain ⟨ht1, ht2⟩ := ht
        have hv : nuRow L t.2 = L := by
          rcases ht2 with e | e <;> simp [nuRow, e]
        have hb : PDim.eval (nuRow L) (.lin c [t]) = c + L := by
          simp only [PDim.eval, termsEval, ht1, hv]
          omega
        rw [hb]
        split at h
        · rename_i hc
          simp only [Option.some.injEq] at h
          subst h
          simp only [SDim.eval, hc]
          omega
        · split at h
          · rename_i hc
            simp only [Option.some.injEq] at h
            subst h
            simp only [SDim.eval, hc]
            omega
          · cases h
      · cases h
    | [], h => simp [rowS] at h
    | _ :: _ :: _, h => simp [rowS] at h
  | fdiv _ _ => simp [rowS] at h
  | cdiv _ _ => simp [rowS] at h
  | rup _ _ => simp [rowS] at h

theorem clsRow_sound (S : SSrv) {L d : Nat} (h1 : 1 ≤ L) (h2 : L ≤ 224) (ρ : Nat → F64)
    (hρ : ∀ x l h, Box.get boxRow x = some (l, h) → ρ x = F64.ofInt (nuRow L x)) :
    ClsSoundD (clsRow S (d : Int)) (νsOf S ρ) (SDim.eval (L + d)) := by
  intro x s hx
  obtain ⟨p, hp, hs⟩ := Option.bind_eq_some_iff.mp hx
  rw [rowS_eval hs]
  exact clsOfX_sound S boxRow (nuRow L) ρ (nuRow_box h1 h2) hρ x p hp

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
  exact embeds_of_imageD (κ := InKey) (clsRow S (d : Int)) SDim.lit (SDim.eval (L + d)) (fun _ => rfl)
    SourceKernels.sources s y (exactTplDom 15235 15235 [5554869888] s) (νsOf S ρ) (CSrv.val ⟨tab⟩)
    M.nv M.big M.arg M.handle M.node (nv_lit M) (fun _ => rfl)
    (numbers_agree S ρ M.nv _ (nv_lit M) (fun _ => rfl) hnum) (clsRow_sound S h1 h2 ρ hρ)
    (fun a => okArg [5554869888] a = true)
    (arg_fixed M [5554869888] (fun i hi => by obtain rfl := List.mem_singleton.mp hi; exact hrope))
    (fun _ _ hi hn => exactTplDom_args hi hn) (kernels_of_GMR hmr _) himg

end Host.Route.Cert.Row
