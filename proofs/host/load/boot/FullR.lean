import host.load.boot.Frame
import host.load.boot.Keys
import host.sim.full.Rel
set_option Elab.async false
namespace Host.Load.Run.Prompt
open Host.Ts Host.Ts.Sim Host.Load Host.Load.Layers Host.Load.Boot Host.Ts.Sim.Full

/-! # `loadDone`'s frame hypotheses in the full world

`FrameRel.Hyps` of the full world's `loadDone` state (`ldSt []`) from the load world's
(`P.a2818 []`): the JavaScript side is the same, so only the native relation of the state to itself
is new (`hyps_full`). For `Full.FullR`, its load-world part is the load world's (`G.LoadR`), and the
bridge, liveness and kernel-recording parts hold of the boot's layers' states (`ld_fullR`: the
released handles and recorded kernels are objects of the boot's MLX state, below its handle
counter); so the load world's hypotheses for `G.LoadR` give the full world's for `FullR`
(`hyps_fullR`, `rel_loadDone_fullR`). -/

/-- The full world's hypotheses from the load world's and the native relation of the state to itself. -/
theorem hyps_full {FR0 : Map → Nat → LSt → LSt → Prop} {FR : Map → Nat → full.S → full.S → Prop}
    {ν : Nat → F64} {S : SSrv} {C : CSrv} {lo hi : Nat}
    (h : FrameRel.Hyps Host.Load.ffi FR0 ν S C lo hi (P.a2818 []))
    (hffi : FR Map.id S.tab.length (ldFull []) (ldFull [])) : FrameRel.Hyps full FR ν S C lo hi (ldSt []) :=
  ⟨h.srv, hffi, h.band, h.presentBound, h.heapSupp, h.ctlSupp, h.stackSupp, h.jobsSupp, h.storesSupp⟩

/-! ## The layers' states are related to themselves -/

theorem foldl_set_get {α : Type} : ∀ (L : List (Nat × α)) (t : PTrie α) (m : Nat) (v : α),
    (∀ p ∈ L, p.1 < 2 ^ 64) → (L.foldl (fun t p => t.set p.1 p.2) t).get m = some v →
      m ∈ L.map Prod.fst ∨ t.get m = some v
  | [], _, _, _, _, h => .inr h
  | p :: L, t, m, v, hb, h => by
    rcases foldl_set_get L (t.set p.1 p.2) m v (fun q hq => hb q (List.mem_cons_of_mem _ hq)) h with h1 | h1
    · exact .inl (List.mem_cons_of_mem _ h1)
    · rw [PTrie.get_set_u64 t p.1 p.2 (hb p List.mem_cons_self)] at h1
      by_cases hm : m = p.1
      · exact .inl (by rw [hm]; exact List.mem_cons_self)
      · simp only [hm, ite_false] at h1
        exact .inr h1

theorem insAll_get {α : Type} {L : List (Nat × α)} {m : Nat} {v : α} (hb : (L.map Prod.fst).all (· < 2 ^ 64) = true)
    (h : (insAll L).get m = some v) : m ∈ L.map Prod.fst := by
  have hb' : ∀ p ∈ L, p.1 < 2 ^ 64 := fun p hp => by
    have := List.all_eq_true.mp hb p.1 (List.mem_map_of_mem hp)
    simpa using this
  rcases foldl_set_get L PTrie.nil m v hb' h with h1 | h1
  · exact h1
  · exact absurd h1 (by simp [PTrie.get, PTrie.nil])

theorem toLoad_toFull (l : LSt) (w : OSt) : toLoad (toFull (l, w)) = l := rfl

theorem toLoad_ld : toLoad (ldFull []) = (P.a2818 []).ffi := toLoad_toFull _ _

/-- The boot's MLX state at `loadDone`. -/
noncomputable abbrev ldMlx : NSt := mlxOf (ldFull [])

/-- No trace is being recorded at `loadDone`. -/
theorem pending_ld : ldMlx.pending.isEmpty = true := by decide +kernel

theorem obfr_bound : (P.obfrKeys.map Prod.fst).all (· < 2 ^ 64) = true := by decide +kernel
theorem obfr_objs : (P.obfrKeys.map Prod.fst).all (fun h => (ldMlx.objs.get h).isSome) = true := by decide +kernel
theorem obfr_next : (P.obfrKeys.map Prod.fst).all (· < ldMlx.next) = true := by decide +kernel
theorem obkr_bound : (P.obkrKeys.map Prod.fst).all (· < 2 ^ 64) = true := by decide +kernel
theorem obkr_objs : (P.obkrKeys.map Prod.fst).all (fun h => (ldMlx.objs.get h).isSome) = true := by decide +kernel
theorem obkr_next : (P.obkrKeys.map Prod.fst).all (· < ldMlx.next) = true := by decide +kernel

theorem freedR_ld : FreedR Map.id ldMlx ldMlx P.obfr2818 P.obfr2818 where
  obj := fun h hh => by
    rw [P.obfr_keys] at hh
    exact List.all_eq_true.mp obfr_objs h (insAll_get obfr_bound hh)
  img := fun h _ => by rw [Map.handle_id]
  lt := fun h hh => by
    rw [P.obfr_keys] at hh
    simpa using List.all_eq_true.mp obfr_next h (insAll_get obfr_bound hh)

theorem targs_ld (h : Nat) : P.obkr2818.targs.get h = none := by rw [P.obkr_targs]; rfl

theorem krecR_ld (n : Nat) : KRecR Map.id n ldMlx ldMlx P.obkr2818 P.obkr2818 where
  flagsObj := fun h hh => by
    obtain ⟨v, hv⟩ := Option.isSome_iff_exists.mp hh
    rw [P.obkr_keys] at hv
    exact List.all_eq_true.mp obkr_objs h (insAll_get obkr_bound hv)
  targsObj := fun h hh => by rw [targs_ld] at hh; cases hh
  flags := fun h _ => by rw [Map.handle_id]
  targs := fun h _ => by rw [Map.handle_id, targs_ld]; rfl
  flagsLt := fun h hh => by
    obtain ⟨v, hv⟩ := Option.isSome_iff_exists.mp hh
    rw [P.obkr_keys] at hv
    simpa using List.all_eq_true.mp obkr_next h (insAll_get obkr_bound hv)
  targsLt := fun h hh => by rw [targs_ld] at hh; cases hh
  cl := fun h l hl => by rw [targs_ld] at hl; cases hl

/-- **`FullR` of `loadDone`'s layers.** The full world's `loadDone` native state is related to itself
under the identity map whenever its load-world state is (`G.LoadR`). -/
theorem ld_fullR (P0 : LoadP) (NB n : Nat) (hl : G.LoadR P0 NB Map.id n (P.a2818 []).ffi (P.a2818 []).ffi) :
    FullR P0 NB Map.id n (ldFull []) (ldFull []) where
  load := by rw [toLoad_ld]; exact hl
  bridge := ⟨rfl, replay_active _⟩
  live := fun fx hx => by
    have e : fx = P.obfr2818 := (Option.some.inj hx).symm
    refine ⟨fx, hx, ?_⟩
    rw [e]
    exact freedR_ld
  kern := fun kx hx => by
    have e : kx = P.obkr2818 := (Option.some.inj hx).symm
    refine ⟨kx, hx, ?_⟩
    rw [e]
    exact krecR_ld n
  pend := ⟨fun p hp => absurd hp (by
      have e : ldMlx.pending = [] := List.isEmpty_iff.mp pending_ld
      rw [show (mlxOf (ldFull [])).pending = ldMlx.pending from rfl, e]
      exact List.not_mem_nil), fun _ _ => rfl⟩

/-- **The full world's `loadDone` hypotheses for `FullR`** from the load world's for `G.LoadR`. -/
theorem hyps_fullR (P0 : LoadP) (NB : Nat) {ν : Nat → F64} {S : SSrv} {C : CSrv} {lo hi : Nat}
    (h : FrameRel.Hyps Host.Load.ffi (G.LoadR P0 NB) ν S C lo hi (P.a2818 [])) :
    FrameRel.Hyps full (FullR P0 NB) ν S C lo hi (ldSt []) :=
  hyps_full h (ld_fullR P0 NB _ h.ffi)

/-- **The relation at `loadDone` in the full world under `FullR`.** -/
theorem rel_loadDone_fullR (P0 : LoadP) (NB : Nat) {ν : Nat → F64} {S : SSrv} {C : CSrv} (lo hi : Nat)
    (fw : List Val) (h : FrameRel.Hyps Host.Load.ffi (G.LoadR P0 NB) ν S C lo hi (P.a2818 [])) :
    Rel full (FullR P0 NB) Map.id ν (FrameRel.ctx (ldSt []) 2665 fw lo hi) (ldSt []) S (ldSt fw) C :=
  rel_loadDone_full lo hi fw (hyps_fullR P0 NB h)


/-- The same for the full world's relation with remaining readbacks `r` (`FLR`, `Full.fullWorld`'s). -/
theorem rel_loadDone_flr (P0 : LoadP) (NB : Nat) (r : List NumV) {ν : Nat → F64} {S : SSrv} {C : CSrv} (lo hi : Nat)
    (fw : List Val) (h : FrameRel.Hyps Host.Load.ffi (G.LoadR { P0 with rest := r } NB) ν S C lo hi (P.a2818 [])) :
    Rel full (FLR P0 NB r) Map.id ν (FrameRel.ctx (ldSt []) 2665 fw lo hi) (ldSt []) S (ldSt fw) C :=
  rel_loadDone_fullR { P0 with rest := r } NB lo hi fw h

end Host.Load.Run.Prompt
