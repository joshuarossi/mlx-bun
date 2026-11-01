import host.sim.template.a4pre_d1_body.TraceLookup
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl.D1BodyTrace
open Host.Ts Host.Ts.Sim Host.Ts.Sim.G
open Host.Mlx.Ffi (Dim Trace Pending shapesOf)

/-- The original closureApply continuation after its lookup returns none. -/
def recordTail (x : NSt) (b off sl ck cb : Nat) (payload : Arg) (xs : List Nat) : Host.Mlx.Ffi.R :=
  match shapesOf x xs with
  | some sh =>
    let (x, ts) := Host.Mlx.Ffi.closureApply.tracers x 0 sh
    let (tv, x) := x.newObj (.vec ts)
    let p : Pending := ⟨x.next, b, off, sl, ck, xs, ts, none⟩
    let x := { x with next := x.next + 1, pending := p :: x.pending }
    Host.Mlx.Ffi.ok x (.callback cb [.extPtr (4 * p.id + 2) 0, .big tv, payload])
  | none => Host.Mlx.Ffi.stuck

theorem recordSim {P : LoadP} {NB : Nat} {M : Map} {ν : Nat → F64}
    {S : SSrv} {C : CSrv} {x y : NSt} {ck cb b off sl : Nat} {pl : Arg} {xs : List Nat}
    (hs : Srv M ν S C) (hr : G.MR P NB M S.tab.length x y)
    (hpr : G.PendReg M x y)
    (hxs : ∀ k ∈ xs, PN x k) (hroomN : x.nnext + xs.length ≤ P.NE)
    (hE : x.next + 2 ≤ P.E) :
    MSim (G.MPost P NB M ν S C) S C (recordTail x b off sl ck cb pl xs)
      (recordTail y (M.a b) off (M.handle sl) (M.handle ck) (M.region cb) (M.arg pl) (xs.map M.node)) := by
  obtain ⟨bb, eb⟩ := G.shapesOf_some hxs
  have eb' := hr.shapesOf_map eb
  unfold recordTail
  rw [eb, eb']
  dsimp only
  have hsh := hr.shapesOf_props eb
  have hlen : bb.length = xs.length := G.shapesOf_length eb
  have hfr := hpr.fresh 1 (by have := hr.hroom; omega)
  obtain ⟨t1, t2, t3, t4, t5, t6⟩ := hr.tracers 0 bb hsh (by rw [hlen]; exact hroomN)
  generalize Host.Mlx.Ffi.closureApply.tracers x 0 bb = T at t1 t2 t3 t5 ⊢
  generalize Host.Mlx.Ffi.closureApply.tracers y 0 (bb.map M.shp) = T' at t1 t2 t4 t6 ⊢
  obtain ⟨s1, ts⟩ := T
  obtain ⟨s1', ts'⟩ := T'
  simp only at t1 t2 t3 t4 t5 t6
  subst t2
  have hE1 : s1.next + 1 ≤ P.E := by rw [t3]; omega
  have m2 := t1.newObj (.vec ts) hE1 trivial (fun c h => nomatch h) (fun i hi => by simp [objTraces] at hi)
  have hb1 : M.handle (x.next + 1) = y.next + 1 := by
    show (M.big (Int.ofNat (x.next + 1))).toNat = _
    rw [hr.hfreshB 1 (by omega)]
    rfl
  have hb0 : M.big (Int.ofNat x.next) = Int.ofNat y.next := by
    have h := hr.hfreshB 0 (by omega)
    simpa using h
  have m3 := m2.bumpPend ⟨s1.next + 1, b, off, sl, ck, xs, ts, none⟩
    ⟨s1'.next + 1, M.a b, off, M.handle sl, M.handle ck, xs.map M.node, ts.map M.node, none⟩
    (by
      rw [t3, t4]
      exact congrArg (fun i => (⟨i, M.a b, off, M.handle sl, M.handle ck, xs.map M.node,
        ts.map M.node, none⟩ : Pending)) hb1.symm)
    (by simp only; omega)
  refine G.msim_ok' hs hr ?_ m3
  show Ret.callback (M.region cb) [.extPtr (4 * (s1'.next + 1) + 2) 0, .big (Int.ofNat s1'.next), M.arg pl] =
    Ret.callback (M.region cb) [.extPtr (M.region (4 * (s1.next + 1) + 2)) 0,
      .big (M.big (Int.ofNat s1.next)), M.arg pl]
  rw [t3, t4, hfr, hb0]

end Host.Load.Run.Tpl.D1BodyTrace
