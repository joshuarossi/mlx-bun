import host.sim.template.a4pre_d1_body.TraceShapes
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl.D1BodyTrace
open Host.Ts Host.Ts.Sim
open Host.Mlx.Ffi (Dim Trace shapesOf findTrace)

theorem traceFitsSim {ν : Nat → F64} {P : LoadP} {NB : Nat}
    {M : Map} {S : SSrv} {C : CSrv} {x y : NSt} {sl : Bool} {t : Trace} {xs : List Nat}
    {a b : List (List Dim × Nat)} {av bv : List (List Nat × Nat)}
    (hs : Srv M ν S C) (hr : G.MR P NB M S.tab.length x y)
    (ha : shapesOf x t.ins = some a) (hb : shapesOf x xs = some b)
    (hva : ShapesV M C S a av) (hvb : ShapesV M C S b bv) :
    MSim (BPost M ν S C (fitValues sl av bv)) S C
      (Host.Mlx.Ffi.traceFits x sl t xs)
      (Host.Mlx.Ffi.traceFits y sl (M.trace t) (xs.map M.node)) := by
  have ha' := hr.shapesOf_map ha
  have hb' := hr.shapesOf_map hb
  unfold Host.Mlx.Ffi.traceFits
  rw [show (M.trace t).ins = t.ins.map M.node from rfl, ha, hb, ha', hb']
  exact fitsSim sl a b av bv hs hva hvb

def TraceValues (M : Map) (C : CSrv) (S : SSrv) (x : NSt) :
    List Trace → List (List (List Nat × Nat)) → Prop
  | [], [] => True
  | t :: ts, v :: vs =>
    (∃ a, shapesOf x t.ins = some a ∧ ShapesV M C S a v) ∧ TraceValues M C S x ts vs
  | _, _ => False

theorem TraceValues.lift {ν : Nat → F64} {M M' : Map} {S S' : SSrv} {C C' : CSrv}
    {x : NSt} (hg : GrowL M ν S C M' S' C') :
    ∀ {ts : List Trace} {vs : List (List (List Nat × Nat))}, TraceValues M C S x ts vs →
      TraceValues M' C' S' x ts vs
  | [], [], _ => trivial
  | _ :: _, _ :: _, ⟨⟨a, ha, hv⟩, ht⟩ =>
    ⟨⟨a, ha, (ShapesV.lift hg hv).1⟩, TraceValues.lift hg ht⟩
  | [], _ :: _, h => h.elim
  | _ :: _, [], h => h.elim

def selectTrace (sl : Bool) (xs : List (List Nat × Nat)) :
    List Trace → List (List (List Nat × Nat)) → Option Trace
  | t :: ts, v :: vs => bif fitValues sl v xs then some t else selectTrace sl xs ts vs
  | _, _ => none

def LookupPost (M : Map) (ν : Nat → F64) (S : SSrv) (C : CSrv) (chosen : Option Trace) :
    Map → SSrv → CSrv → Option Trace → Option Trace → Prop :=
  fun M' S' C' r r' => r' = r.map M'.trace ∧ r = chosen ∧ GrowL M ν S C M' S' C'

theorem findTraceSim {ν : Nat → F64} {P : LoadP} {NB : Nat} {x y : NSt} {xs : List Nat}
    {b : List (List Dim × Nat)} {bv : List (List Nat × Nat)}
    (hb : shapesOf x xs = some b) :
    ∀ {M : Map} {S : SSrv} {C : CSrv} (sl : Bool)
      (ts : List Trace) (vs : List (List (List Nat × Nat))),
      Srv M ν S C → G.MR P NB M S.tab.length x y →
      ShapesV M C S b bv → TraceValues M C S x ts vs →
      MSim (LookupPost M ν S C (selectTrace sl bv ts vs)) S C
        (findTrace x sl xs ts) (findTrace y sl (xs.map M.node) (ts.map M.trace))
  | _, _, _, _, [], [], hs, _, _, _ => MSim.pure ⟨rfl, rfl, GrowL.refl hs⟩
  | M, S, C, sl, t :: ts, v :: vs, hs, hr, hvb, ⟨⟨a, ha, hva⟩, hvs⟩ => by
    simp only [findTrace, List.map_cons]
    refine MSim.bind (traceFitsSim hs hr ha hb hva hvb) ?_
    rintro M1 S1 C1 e e' ⟨rfl, rfl, hg⟩
    cases he : fitValues sl v bv
    · simp only [he, Bool.cond_false, selectTrace]
      have ht : M1.trace = M.trace := by
        funext tr
        cases tr
        simp only [Map.trace, hg.grow.ext.node]
      rw [← hg.grow.ext.node, ← ht]
      have hvb' := (ShapesV.lift hg hvb).1
      have hvs' := TraceValues.lift hg hvs
      refine MSim.mono (findTraceSim hb sl ts vs hg.grow.srv (hr.grow hg.grow) hvb' hvs') ?_
      rintro M2 S2 C2 r r' ⟨heq, hv, hg2⟩
      exact ⟨heq, hv, hg.trans hg2⟩
    · simp only [he, Bool.cond_true, selectTrace]
      refine MSim.pure ⟨?_, rfl, hg⟩
      change some (M.trace t) = some (M1.trace t)
      cases t
      simp only [Map.trace, hg.grow.ext.node]
  | _, _, _, _, [], _ :: _, _, _, _, h => h.elim
  | _, _, _, _, _ :: _, [], _, _, _, h => h.elim

end Host.Load.Run.Tpl.D1BodyTrace

-- rechecked: literal chunk length
