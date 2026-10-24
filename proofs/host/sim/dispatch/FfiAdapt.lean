import host.sim.dispatch.DecideFfi
import host.sim.FfiCall
namespace Host.Ts.Sim.Disp
open Host.Ts Host.Ts.Sim Host.Ts.Sim.BufSim

/-! # Adapter: `dlopen` symbol calls with a positional `bool` condition

`step_ffi_symbol` asks `BoolOK` of every argument against every parameter type
(`hbool`), so a call with one `bool` parameter rejects every renamed handle
argument. `decodeArg` converts only the argument at a `bool` position, so
`step_ffi_symbolP` asks `BoolOK` positionally (`BoolsP`); the proof is that of
`step_ffi_symbol` with `decodeArgs_simP` (`decodeArgs_sim` with `BoolsP`). The native call goes through `FfiCallSim` (FfiCall.lean)
with its smallness premise `small ν S1 x name as` on the source run (`hsm`). -/

/-- `BoolOK` of each argument at its parameter type (as `decodeArgs` pairs them). -/
def BoolsP (K : Ctx) : List Val → List Val → Prop
  | .str ty :: ts, v :: vs => BoolOK K ty v ∧ BoolsP K ts vs
  | .str _ :: ts, [] => BoolsP K ts []
  | _, _ => True

section
variable {F : Ffi} {FR : Map → Nat → F.S → F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame} {M : Map} {ν : Nat → F64} {K : Ctx}
  {s t : St F.S} {S : SSrv} {C : CSrv} {okCall : F.S → Name → List Arg → Bool}
  {okBack : F.S → Arg → Bool}


theorem decodeArgs_simP (hFR : FRLaws FR) (hF : FfiSim F FR okCall okBack) :
    ∀ (ts vs : List Val) {M : Map} {S : SSrv} {C : CSrv}, RelB F FR W stk M ν K s S t C →
    Supp.vals (Present s) S.tab.length ts → Supp.vals (Present s) S.tab.length vs →
    (∀ v ∈ vs, ArgBufOK F K W s S.tab.length v) → BoolsP K ts vs →
    MSim (ArgsP (Present s) M ν S C) S C (decodeArgs F s ts vs) (decodeArgs F t (M.vals ts) (M.vals vs))
  | [], [], M, S, C, h, _, _, _, _ => MSim.pure ⟨rfl, Grow.refl h.srv, fun as has a ha => by
      cases has; exact nomatch ha⟩
  | [], _ :: _, M, S, C, h, _, _, _, _ => MSim.pure ⟨rfl, Grow.refl h.srv, fun _ h => nomatch h⟩
  | t0 :: ts, vs, M, S, C, h, hts, hvs, hbuf, hbool => by
    have tail : ∀ (v : Val) (vs' : List Val), Supp.val (Present s) S.tab.length v →
        ArgBufOK F K W s S.tab.length v → BoolOK K (match t0 with | .str ty => ty | _ => []) v →
        Supp.vals (Present s) S.tab.length vs' → (∀ v ∈ vs', ArgBufOK F K W s S.tab.length v) →
        BoolsP K ts vs' →
        ∀ ty, t0 = .str ty →
        MSim (ArgsP (Present s) M ν S C) S C
          (Host.Ts.M.bind (decodeArg F s ty v) fun
            | some a => Host.Ts.M.bind (decodeArgs F s ts vs') fun r => Host.Ts.M.pure (r.map (a :: ·))
            | none => Host.Ts.M.pure none)
          (Host.Ts.M.bind (decodeArg F t ty (M.val v)) fun
            | some a => Host.Ts.M.bind (decodeArgs F t (M.vals ts) (M.vals vs')) fun r =>
                Host.Ts.M.pure (r.map (a :: ·))
            | none => Host.Ts.M.pure none) := by
      intro v vs' hv hb hbo hvs' hbuf' hbool' ty hty
      subst hty
      refine MSim.bind (decodeArg_sim h hF ty v hv hb hbo) ?_
      rintro M1 S1 C1 r r' ⟨rfl, g1, hs1⟩
      cases r with
      | none => exact MSim.pure ⟨rfl, g1, fun _ h => nomatch h⟩
      | some a =>
        have hts' : Supp.vals (Present s) S.tab.length ts := fun w hw => hts w (List.mem_cons_of_mem _ hw)
        rw [Map.vals_agree (g1.ext.agree (A := Present s)) hts',
          Map.vals_agree (g1.ext.agree (A := Present s)) hvs']
        refine MSim.bind (decodeArgs_simP hFR hF ts vs' (h.grow hFR g1) (Supp.vals_mono (fun _ h => h) g1.len hts')
          (Supp.vals_mono (fun _ h => h) g1.len hvs') (fun w hw => ArgBufOK.mono (hbuf' w hw) g1.len)
          hbool') ?_
        rintro M2 S2 C2 r2 r2' ⟨rfl, g2, hs2⟩
        have ha : Supp.arg (Present s) S1.tab.length a := hs1 a rfl
        have hma : M1.arg a = M2.arg a := Map.arg_agree (g2.ext.agree (A := Present s)) ha
        refine MSim.pure ⟨?_, g1.trans g2, fun as has x hx => ?_⟩
        · cases r2 <;> simp [hma]
        · cases r2 with
          | none => cases has
          | some as2 =>
            simp only [Option.map_some, Option.some.injEq] at has
            subst has
            rcases List.mem_cons.1 hx with rfl | hx
            · exact Supp.arg_mono (fun _ h => h) g2.len ha
            · exact hs2 as2 rfl x hx
    cases t0 with
    | str ty =>
      cases vs with
      | nil =>
        exact tail .undef [] trivial trivial (fun _ _ hi => nomatch hi) (fun _ h => nomatch h)
          (fun _ h => nomatch h) hbool ty rfl
      | cons v vs =>
        obtain ⟨hb0, hb1⟩ := hbool
        exact tail v vs (hvs v (List.mem_cons_self ..)) (hbuf v (List.mem_cons_self ..))
          hb0 (fun w hw => hvs w (List.mem_cons_of_mem _ hw))
          (fun w hw => hbuf w (List.mem_cons_of_mem _ hw)) hb1 ty rfl
    | _ => exact MSim.pure ⟨rfl, Grow.refl h.srv, fun _ h => nomatch h⟩



theorem step_ffi_symbolP {okCall0 : F.S → Name → List Arg → Bool}
    {small : (Nat → F64) → SSrv → F.S → Name → List Arg → Prop} (h : RelB F FR W stk M ν K s S t C) (hFR : FRLaws FR)
    (hF : FfiSim F FR okCall0 okBack) (hC : FfiCallSim F FR okCall small) (hL : FfiLawful F) {a : Nat} {this : Val} {args : List Val}
    {o : Obj} {name rt : Name} {ta : Nat} {oa : Obj} {tys : List Val}
    (hc : s.ctl = .call (.obj a) this args) (ho : s.obj? a = some o)
    (hk : o.kind = .fn (.native (.ffi .symbol) [.str name, .obj ta, .str rt]))
    (hta : s.obj? ta = some oa) (htk : oa.kind = .array tys) (hn : s.next < Sim.bound)
    (hfr : K.fr ta = none) (hbuf : ∀ v ∈ args, ArgBufOK F K W s S.tab.length v)
    (hbool : BoolsP K tys args)
    (hok : SymOK F K okCall s S name tys args)
    (hsm : ∀ as S1, interpS (decodeArgs F s tys args).run S = some (some as, S1) → small ν S1 s.ffi name as)
    (hcbr : ∀ f, cbBase ≤ f → Present s (f - cbBase) → M.region f = cbBase + M.a (f - cbBase)) :
    MSim (StepPostB F FR W stk M ν K S C) S C (step F s) (step F t) := by
  rw [step_call_native hc ho hk, step_call_native_t h hc ho hk]
  have htt : t.obj? (M.a ta) = some (M.obj oa) := h.obj? hta hfr
  have hso : Supp.vals (Present s) S.tab.length tys := by
    have := (h.obj?_supp hta).1
    rw [htk] at this
    exact this
  obtain ⟨kd, pr, ps, pv, e⟩ := oa
  simp only at htk
  subst htk
  show MSim _ S C (ffiN F s this args [.str name, .obj ta, .str rt] .symbol)
    (ffiN F t (M.val this) (M.vals args) (M.vals [.str name, .obj ta, .str rt]) .symbol)
  simp only [ffiN, Map.vals, List.map, Map.val, elemsOf, hta, htt, Map.obj, Map.kind]
  show MSim _ S C (Host.Ts.M.bind (decodeArgs F s tys args) _)
    (Host.Ts.M.bind (decodeArgs F t (M.vals tys) (M.vals args)) _)
  refine MSim.bind (MSim.withRun (decodeArgs_simP hFR hF tys args h hso (call_supp h hc).2 hbuf hbool)
    (decodeArgs_lawful _ _ _ _) (decodeArgs_lawful _ _ _ _)) ?_
  rintro M1 S1 C1 r r' ⟨⟨rfl, g1, hs1⟩, hrun⟩
  cases r with
  | none => exact MSim.fail _ _
  | some as =>
    obtain ⟨hokc, hres⟩ := hok as S1 hrun
    have h1 := h.grow hFR g1
    have hcall := hC.call M1 ν S1 C1 s.ffi t.ffi name as h1.srv h1.ffi hokc
      (fun x hx => Supp.arg_mono (fun _ _ => trivial) (Nat.le_refl _) (hs1 as rfl x hx)) (hsm as S1 hrun)
    simp only [Option.map_some]
    refine MSim.bind (MSim.withRun hcall (hL.call _ _ _) (hL.call _ _ _)) ?_
    rintro M2 S2 C2 cr cr' ⟨⟨g2, hcr⟩, hrun2⟩
    have h2 := h1.grow hFR g2
    have has2 : ∀ x ∈ as, Supp.arg (Present s) S2.tab.length x :=
      fun x hx => Supp.arg_mono (fun _ h => h) g2.len (hs1 as rfl x hx)
    have hmap : as.map M1.arg = as.map M2.arg :=
      List.map_congr_left fun x hx => Map.arg_agree (g2.ext.agree (A := Present s)) (hs1 as rfl x hx)
    rw [hmap]
    have g := g1.trans g2
    exact StepPost.after g (ffiDone_sim h2 hn has2 (by rw [g.ext.region, g.ext.a]; exact hcbr) hcr
      (hres cr S2 hrun2))

end

/-- `BoolsP`. -/
def boolsPB {F : Ffi} (P : JSP F) : List Val → List Val → Bool
  | .str ty :: ts, v :: vs => (!(nameEq ty (chars!"bool")) || bfVB P v) && boolsPB P ts vs
  | .str _ :: ts, [] => boolsPB P ts []
  | _, _ => true

theorem Kp.boolsP {F : Ffi} {P : JSP F} {K : Ctx} (hK : Kp P K) :
    ∀ {tys args : List Val}, boolsPB P tys args = true → BoolsP K tys args
  | [], [], _ => trivial
  | [], _ :: _, _ => trivial
  | .str ty :: ts, v :: vs, h => by
    simp only [boolsPB, Bool.and_eq_true, Bool.or_eq_true, Bool.not_eq_true'] at h
    refine ⟨fun hb => ?_, hK.boolsP h.2⟩
    rcases h.1 with h1 | h1
    · rw [hb] at h1; cases h1
    · exact hK.bfBig h1
  | .str _ :: ts, [], h => hK.boolsP (tys := ts) (args := []) h
  | .undef :: _, _, _ => trivial
  | .null :: _, _, _ => trivial
  | .bool _ :: _, _, _ => trivial
  | .num _ :: _, _, _ => trivial
  | .big _ :: _, _, _ => trivial
  | .sym _ :: _, _, _ => trivial
  | .obj _ :: _, _, _ => trivial
  | .ptr _ _ :: _, _, _ => trivial

end Host.Ts.Sim.Disp
