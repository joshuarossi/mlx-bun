import host.sim.native.Objects
import host.sim.native.gen.Simple
namespace Host.Ts.Sim.G
open Host.Mlx.Ffi (Dim Prim Node Cfg Clo Trace Pending dimOf)

/-! `host.sim.native.Objects` for the general native relation `G.MR` (`host.sim.native.gen.Rel`):
the same statements and proofs, with the pre-load band bound `NB` threaded through. -/

section

variable {P : LoadP} {NB : Nat} {M : Map} {ν : Nat → F64} {S : SSrv} {C : CSrv} {x y : NSt} {name : Name}
  (hs : Srv M ν S C) (hr : MR P NB M S.tab.length x y)

include hs hr

omit hr in

/-- A pure target computation. -/
theorem msim_stuck' {m' : Host.Ts.M NRes} (hm' : ∃ b, ∀ γ k, m' γ k = k b) :
    MSim (MPost P NB M ν S C) S C Host.Mlx.Ffi.stuck m' := msim_stuck hs m' hm'

theorem sim_vecGet (hsym : Host.Mlx.Ffi.symOf name = some Host.Mlx.Ffi.Sym.vecGet) {o v i : Arg}
    (ho : slotOk P x o = true) (hv : vecOk x v = true) (hi : natOk P i = true) (hE : x.next + 1 ≤ P.E) :
    MSim (MPost P NB M ν S C) S C (Host.Mlx.Ffi.call x name [o, v, i])
      (Host.Mlx.Ffi.call y name [M.arg o, M.arg v, M.arg i]) := by
  obtain ⟨b, off, sl, h1, h2, hsl⟩ := hr.slot_map ho
  obtain ⟨k, ns, rfl, hm, hp, h3, h4⟩ := hr.vecArg hv
  rw [hm]; unfold Host.Mlx.Ffi.call; rw [hsym]
  simp only [h1, h2, argNat_nat, Option.bind_some, h3, h4, hr.natOk_argNat hi]
  cases hj : Host.Mlx.Ffi.argNat i with
  | none => exact msim_stuck' hs ⟨_, fun _ _ => rfl⟩
  | some j =>
    simp only [nth?_map]
    cases hn : nth? ns j with
    | none => exact msim_stuck' hs ⟨_, fun _ _ => rfl⟩
    | some nd =>
      obtain ⟨h, x', h', y', e1, e2, hr', hb⟩ := hr.setArr_map hsl (fun _ => hE) nd
      simp only [Option.map_some, e1, e2]
      exact msim_okW' hs hr rfl (by simp only [List.map_cons, List.map_nil, Map.write_u64 M hb]) hr'

theorem sim_vecNewData (hsym : Host.Mlx.Ffi.symOf name = some Host.Mlx.Ffi.Sym.vecNewData) {p c : Arg}
    (hok : handlesOk P x p c = true) (hE : x.next + 1 ≤ P.E) :
    MSim (MPost P NB M ν S C) S C (Host.Mlx.Ffi.call x name [p, c])
      (Host.Mlx.Ffi.call y name [M.arg p, M.arg c]) := by
  unfold Host.Mlx.Ffi.call; rw [hsym]
  simp only
  cases hh : Host.Mlx.Ffi.handlesArg p c with
  | none =>
    simp only [Option.bind_none]
    exact msim_stuck' hs (by
      cases (Host.Mlx.Ffi.handlesArg (M.arg p) (M.arg c)).bind (Host.Mlx.Ffi.nodesOf y) <;>
        exact ⟨_, fun _ _ => rfl⟩)
  | some hds =>
    obtain ⟨e1, hp⟩ := hr.handlesArg_map hok hh
    simp only [Option.bind_some, e1, hr.nodesOf_map hp]
    cases hn : Host.Mlx.Ffi.nodesOf x hds with
    | none => exact msim_stuck' hs ⟨_, fun _ _ => rfl⟩
    | some ns =>
      simp only [Option.map_some, Host.Mlx.Ffi.St.newObj]
      have h := hr.newObj (.vec ns) hE trivial (fun c h => by cases h) (fun i h => by cases h)
      refine msim_ok' hs hr ?_ h
      show Ret.big _ = Ret.big (M.big _)
      rw [show ((x.next : Nat) : Int) = Int.ofNat x.next from rfl, (hr.fresh0 (by omega)).1]; rfl

theorem sim_cfgUpdate {c : Arg} (hc : cfgOk x c) (g g' : Cfg → Cfg) (hg : ∀ k, g' (M.cfg k) = M.cfg (g k))
    (hcl : ∀ k, SCfg (· < S.tab.length) k → SCfg (· < S.tab.length) (g k))
    (hcan : ∀ k, (∀ p ∈ k.outs, ∀ d ∈ p.1, DimCanon M d) → ∀ p ∈ (g k).outs, ∀ d ∈ p.1, DimCanon M d) :
    MSim (MPost P NB M ν S C) S C (Host.Mlx.Ffi.cfgUpdate x c fun k => some (g k))
      (Host.Mlx.Ffi.cfgUpdate y (M.arg c) fun k => some (g' k)) := by
  simp only [cfgOk, Bool.and_eq_true] at hc
  obtain ⟨k, rfl, hp, hm⟩ := hr.hdOk_spec hc.1
  rw [argNat_nat, Option.bind_some] at hc
  cases ho : x.obj? k with
  | none => rw [ho] at hc; cases hc.2
  | some o =>
    rw [ho] at hc
    cases o with
    | cfg kc =>
      have hy : y.obj? (M.handle k) = some (.cfg (M.cfg kc)) := by rw [hr.obj? hp, ho]; rfl
      rw [hm]; unfold Host.Mlx.Ffi.cfgUpdate
      simp only [argNat_nat, Option.bind_some, ho, hy, Option.map_some, hg]
      have hcl0 := hr.cl.2.1 k _ ho
      have hcan0 := hr.cfgCanon k kc ho
      have h := hr.setObj hp (.cfg (g kc)) (hcl kc hcl0) (fun c' h => by cases h; exact hcan kc hcan0)
        (fun i h => by cases h)
      exact msim_ok' hs hr rfl h
    | _ => cases hc.2

theorem sim_cfgOutput (hsym : Host.Mlx.Ffi.symOf name = some Host.Mlx.Ffi.Sym.cfgOutput) {c sh m dt : Arg}
    (hc : cfgOk x c) (hd : dimsOk P sh m = true) (hl : dimsLitOk sh m = true) (hdt : natOk P dt = true) :
    MSim (MPost P NB M ν S C) S C (Host.Mlx.Ffi.call x name [c, sh, m, dt])
      (Host.Mlx.Ffi.call y name [M.arg c, M.arg sh, M.arg m, M.arg dt]) := by
  unfold Host.Mlx.Ffi.call; rw [hsym]
  simp only [hr.natOk_argNat hdt]
  cases hds : Host.Mlx.Ffi.dimsArg sh m with
  | none =>
    simp only
    exact msim_stuck' hs (by
      cases Host.Mlx.Ffi.dimsArg (M.arg sh) (M.arg m) <;> cases Host.Mlx.Ffi.argNat dt <;>
        first | exact ⟨_, fun _ _ => rfl⟩ | exact cfgUpdate_pure _ _ _)
  | some ds =>
    rw [hr.dimsArg_map hd hds]
    have hlit : ds.all dimLit = true := by simp only [dimsLitOk, hds] at hl; exact hl
    cases hn : Host.Mlx.Ffi.argNat dt with
    | none => exact msim_stuck' hs ⟨_, fun _ _ => rfl⟩
    | some d =>
      simp only
      refine sim_cfgUpdate hs hr hc (fun k => { k with outs := k.outs ++ [(ds, d)] })
        (fun k => { k with outs := k.outs ++ [(M.dims ds, d)] }) (fun k => (Map.cfg_outs M k ds d).symm) ?_ ?_
      · intro k hk
        refine ⟨fun p hp => ?_, hk.2.1, hk.2.2.1, hk.2.2.2.1, hk.2.2.2.2⟩
        rcases List.mem_append.mp hp with hp | hp
        · exact hk.1 p hp
        · simp only [List.mem_singleton] at hp; subst hp; exact SDs.of_lit hlit
      · intro k hk p hp e he
        rcases List.mem_append.mp hp with hp | hp
        · exact hk p hp e he
        · simp only [List.mem_singleton] at hp; subst hp
          exact dimCanon_lit M (List.all_eq_true.mp hlit e he)

theorem sim_cfgGrid (hsym : Host.Mlx.Ffi.symOf name = some Host.Mlx.Ffi.Sym.cfgGrid) {c : Arg} {a b d : NumV}
    (hc : cfgOk x c) (ha : SN (· < S.tab.length) a) (hb : SN (· < S.tab.length) b) (hd : SN (· < S.tab.length) d) :
    MSim (MPost P NB M ν S C) S C (Host.Mlx.Ffi.call x name [c, .num a, .num b, .num d])
      (Host.Mlx.Ffi.call y name [M.arg c, .num (M.nv a), .num (M.nv b), .num (M.nv d)]) := by
  unfold Host.Mlx.Ffi.call; rw [hsym]
  refine sim_cfgUpdate hs hr hc (fun k => { k with grid := [a, b, d] })
    (fun k => { k with grid := [M.nv a, M.nv b, M.nv d] }) (fun k => by simp [Map.cfg]) ?_ (fun k hk => hk)
  intro k hk
  refine ⟨hk.1, fun v hv => ?_, hk.2.2⟩
  simp only [List.mem_cons, List.mem_nil_iff, or_false] at hv
  rcases hv with rfl | rfl | rfl <;> assumption

theorem sim_cfgGroup (hsym : Host.Mlx.Ffi.symOf name = some Host.Mlx.Ffi.Sym.cfgGroup) {c : Arg} {a b d : NumV}
    (hc : cfgOk x c) (ha : SN (· < S.tab.length) a) (hb : SN (· < S.tab.length) b) (hd : SN (· < S.tab.length) d) :
    MSim (MPost P NB M ν S C) S C (Host.Mlx.Ffi.call x name [c, .num a, .num b, .num d])
      (Host.Mlx.Ffi.call y name [M.arg c, .num (M.nv a), .num (M.nv b), .num (M.nv d)]) := by
  unfold Host.Mlx.Ffi.call; rw [hsym]
  refine sim_cfgUpdate hs hr hc (fun k => { k with group := [a, b, d] })
    (fun k => { k with group := [M.nv a, M.nv b, M.nv d] }) (fun k => by simp [Map.cfg]) ?_ (fun k hk => hk)
  intro k hk
  refine ⟨hk.1, hk.2.1, fun v hv => ?_, hk.2.2.2⟩
  simp only [List.mem_cons, List.mem_nil_iff, or_false] at hv
  rcases hv with rfl | rfl | rfl <;> assumption

theorem sim_cfgInt (hsym : Host.Mlx.Ffi.symOf name = some Host.Mlx.Ffi.Sym.cfgInt) {c nm : Arg} {v : NumV}
    (hc : cfgOk x c) (hv : SN (· < S.tab.length) v) :
    MSim (MPost P NB M ν S C) S C (Host.Mlx.Ffi.call x name [c, nm, .num v])
      (Host.Mlx.Ffi.call y name [M.arg c, M.arg nm, .num (M.nv v)]) := by
  unfold Host.Mlx.Ffi.call; rw [hsym]
  simp only [cstrArg_map]
  cases hn : Host.Mlx.Ffi.cstrArg nm with
  | none => exact msim_stuck' hs ⟨_, fun _ _ => rfl⟩
  | some s =>
    refine sim_cfgUpdate hs hr hc (fun k => { k with ints := k.ints ++ [(s, v)] })
      (fun k => { k with ints := k.ints ++ [(s, M.nv v)] }) (fun k => by simp [Map.cfg]) ?_ (fun k hk => hk)
    intro k hk
    refine ⟨hk.1, hk.2.1, hk.2.2.1, fun p hp => ?_, hk.2.2.2.2⟩
    rcases List.mem_append.mp hp with hp | hp
    · exact hk.2.2.2.1 p hp
    · simp only [List.mem_singleton] at hp; subst hp; exact hv

theorem sim_cfgDtype (hsym : Host.Mlx.Ffi.symOf name = some Host.Mlx.Ffi.Sym.cfgDtype) {c nm dt : Arg}
    (hc : cfgOk x c) (hdt : natOk P dt = true) :
    MSim (MPost P NB M ν S C) S C (Host.Mlx.Ffi.call x name [c, nm, dt])
      (Host.Mlx.Ffi.call y name [M.arg c, M.arg nm, M.arg dt]) := by
  unfold Host.Mlx.Ffi.call; rw [hsym]
  simp only [cstrArg_map, hr.natOk_argNat hdt]
  cases hn : Host.Mlx.Ffi.cstrArg nm with
  | none => exact msim_stuck' hs ⟨_, fun _ _ => rfl⟩
  | some s =>
    cases hd : Host.Mlx.Ffi.argNat dt with
    | none => exact msim_stuck' hs ⟨_, fun _ _ => rfl⟩
    | some d =>
      exact sim_cfgUpdate hs hr hc (fun k => { k with dtypes := k.dtypes ++ [(s, d)] })
        (fun k => { k with dtypes := k.dtypes ++ [(s, d)] }) (fun k => by simp [Map.cfg]) (fun k hk => hk)
        (fun k hk => hk)

end

section

variable {P : LoadP} {NB : Nat} {M : Map} {n : Nat} {x y : NSt} (hr : MR P NB M n x y)

include hr

theorem MR.kouts (kh : Nat) (xs : List Nat) (c : Cfg) (hcl : SCfg (· < n) c)
    (hcan : ∀ p ∈ c.outs, ∀ d ∈ p.1, DimCanon M d) :
    ∀ (l : List (List Dim × Nat)) (i : Nat), (∀ p ∈ l, p ∈ c.outs) → x.nnext + l.length ≤ P.NE →
      ∃ x' y' ns, Host.Mlx.Ffi.kernelApply.outs kh xs c x i l = (x', ns) ∧
        Host.Mlx.Ffi.kernelApply.outs (M.handle kh) (xs.map M.node) (M.cfg c) y i
          (l.map fun p => (M.dims p.1, p.2)) = (y', ns.map M.node) ∧
        MR P NB M n x' y' ∧ x'.next = x.next ∧ x'.arrs = x.arrs ∧ x'.objs = x.objs := by
  intro l
  induction l generalizing x y with
  | nil => intro i _ _; exact ⟨x, y, [], rfl, rfl, hr, rfl, rfl, rfl⟩
  | cons p r ih =>
    intro i hl hroom
    obtain ⟨sh, dt⟩ := p
    have hp : (sh, dt) ∈ c.outs := hl _ (List.mem_cons_self ..)
    have h1 := hr.addNode ⟨.kernel kh c i, xs, sh, dt⟩ (by simp at hroom; omega) ⟨hcl, hcl.1 _ hp⟩
      (hcan _ hp)
    obtain ⟨x', y', ns, e1, e2, h2, h3, h4, h5⟩ := ih h1 (i + 1) (fun q hq => hl q (List.mem_cons_of_mem _ hq))
      (by simp at hroom ⊢; omega)
    refine ⟨x', y', x.nnext :: ns, ?_, ?_, h2, h3, h4, h5⟩
    · simp only [Host.Mlx.Ffi.kernelApply.outs, Host.Mlx.Ffi.St.addNode]; rw [e1]
    · simp only [List.map_cons, Host.Mlx.Ffi.kernelApply.outs, Host.Mlx.Ffi.St.addNode]
      have : (⟨.kernel (M.handle kh) (M.cfg c) i, xs.map M.node, M.dims sh, dt⟩ : Node) =
          M.nnode ⟨.kernel kh c i, xs, sh, dt⟩ := rfl
      rw [this, e2, hr.node_next]

end

section

variable {P : LoadP} {NB : Nat} {M : Map} {ν : Nat → F64} {S : SSrv} {C : CSrv} {x y : NSt} {name : Name}
  (hs : Srv M ν S C) (hr : MR P NB M S.tab.length x y)

include hs hr

theorem sim_kernelApply (hsym : Host.Mlx.Ffi.symOf name = some Host.Mlx.Ffi.Sym.kernelApply)
    {o k v c e : Arg} (ho : slotOk P x o = true) (hk : kernOk x k = true) (hv : vecOk x v = true)
    (hc : cfgOk x c = true) (hE : x.next + 1 ≤ P.E)
    (hNE : ∀ cf, (Host.Mlx.Ffi.argNat c).bind x.obj? = some (.cfg cf) → x.nnext + cf.outs.length ≤ P.NE) :
    MSim (MPost P NB M ν S C) S C (Host.Mlx.Ffi.call x name [o, k, v, c, e])
      (Host.Mlx.Ffi.call y name [M.arg o, M.arg k, M.arg v, M.arg c, M.arg e]) := by
  obtain ⟨b, off, sl, h1, h2, hsl⟩ := hr.slot_map ho
  obtain ⟨kv, ns, rfl, hmv, hpv, h3, h4⟩ := hr.vecArg hv
  simp only [kernOk, Bool.and_eq_true] at hk
  obtain ⟨kk, rfl, hpk, hmk⟩ := hr.hdOk_spec hk.1
  simp only [cfgOk, Bool.and_eq_true] at hc
  obtain ⟨kc, rfl, hpc, hmc⟩ := hr.hdOk_spec hc.1
  rw [argNat_nat, Option.bind_some] at hk hc
  cases hok : x.obj? kk with
  | none => rw [hok] at hk; cases hk.2
  | some ok =>
    rw [hok] at hk
    cases ok with
    | kernel kn ks khd ni no =>
      cases hoc : x.obj? kc with
      | none => rw [hoc] at hc; cases hc.2
      | some oc =>
        rw [hoc] at hc
        cases oc with
        | cfg cf =>
          have hyk : y.obj? (M.handle kk) = some (.kernel kn ks khd ni no) := by rw [hr.obj? hpk, hok]; rfl
          have hyc : y.obj? (M.handle kc) = some (.cfg (M.cfg cf)) := by rw [hr.obj? hpc, hoc]; rfl
          rw [hmv, hmk, hmc]
          unfold Host.Mlx.Ffi.call; rw [hsym]
          simp only
          unfold Host.Mlx.Ffi.kernelApply
          simp only [h1, h2, argNat_nat, Option.bind_some, hok, hoc, hyk, hyc, h3, h4, Option.map_some]
          have hroom := hNE cf (by rw [argNat_nat, Option.bind_some, hoc])
          obtain ⟨x', y', nds, e1, e2, hr1, hn1, ha1, ho1⟩ :=
            hr.kouts kk ns cf (hr.cl.2.1 kc _ hoc) (hr.cfgCanon kc cf hoc) cf.outs 0 (fun _ h => h) hroom
          have e2' : Host.Mlx.Ffi.kernelApply.outs (M.handle kk) (ns.map M.node) (M.cfg cf) y 0 (M.cfg cf).outs =
              (y', nds.map M.node) := e2
          rw [e1, e2']
          simp only
          have hsl' : sl = 0 ∨ PH x' sl := by
            rcases hsl with h | h
            · exact .inl h
            · right; unfold PH; rw [ha1, ho1]; exact h
          obtain ⟨hh, x'', hh', y'', e3, e4, hr2, hb⟩ := hr1.setVec_map hsl' (by rw [hn1]; exact hE) nds
          rw [e3, e4]
          exact msim_okW' hs hr rfl (by simp only [List.map_cons, List.map_nil, Map.write_u64 M hb]) hr2
        | _ => cases hc.2
    | _ => cases hk.2

end

end Host.Ts.Sim.G
