import host.sim.compose.a4b.fd.G2
import host.sim.compose.HookMem
import host.sim.template.FlatFwdCap
import host.sim.template.a4pre_fd_vw_r0_body.m.B13
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option autoImplicit false
namespace Host.Ts.Sim.Compose.FDVW
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

/-! # The final forward

The flat body at the class's frames (`FlatFwd`). Its book reads only the valuation and the context, which a forward's stretches keep. -/

abbrev fr : FlatFwd.Fr := PRE_fd_vw_r0_body.fr

/-- What the forward keeps, over the valuation and the context. -/
structure FlatBook (T : Nat) (tk : Nat → Nat) (π : List Nat) (K0 : Ctx) (cap : Nat) (ν : Nat → F64) (K : Ctx) : Prop where
  vocab : ∀ k ∈ π, k < 248320
  valuation : VBOkF loopVB ν
  rowOne : ν 12 = F64.ofNat 1
  promptValue : ν 9 = F64.ofNat π.length
  rowValue : ν 10 = F64.ofNat (π.length - 1)
  offsetValue : ν 11 = F64.ofNat (π.length - 1)
  capValue : ν 16 = F64.ofNat (capL (π.length - 1))
  reserved : ∀ j, j < 9 → ν j = machVal T tk j
  context : Disp.KpJ (fr.typedJ (tokenBytes (lastRows π))) cap K
  incomingPrompt : K0.fr 2665 = some ([], π.map natV)
  frames : K.fr = (g1Framed K0 π).fr
  box : ∃ v, Lin.InBox PRE_fd_vw_r0_body.ps 0 v ∧ Lin.VarsOk ν v PRE_fd_vw_r0_body.V

theorem flatLaws {T cap : Nat} {tk : Nat → Nat} {π : List Nat} {K0 : Ctx} (hcap : cap ≤ 4096 + 1593835520) :
    FlatFwd.LawsCap fr (tokenBytes (lastRows π)) cap PRE_fd_vw_r0_body.ps PRE_fd_vw_r0_body.V
      (fun x => FlatBook T tk π K0 cap x.ν x.K) where
  hcap := hcap
  context _ h := h.context
  valuation _ h := ⟨h.valuation, h.rowOne⟩
  box _ h := h.box
  ext h _ := h
  restart h _ _ _ := { h with context := ⟨h.context.1, h.context.2⟩ }

/-- The forward's return. -/
noncomputable def returnCut (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (cap H N : Nat) : ICut FF where
  s0 := PRE_fd_vw_r0_body.s900
  tab0 := PRE_fd_vw_r0_body.S900.tab
  R := fun x s S => ∃ K0,
    RelB FF (Disp.FRJ (FullRXD { setupP with rest := machReads T tk } NB))
      (fr.typedW (tokenBytes (lastRows π))) [] x.M x.ν x.K s S x.t x.C ∧
    FlatBook T tk π K0 cap x.ν x.K ∧ InputAt (lastRows π) (x.M.node 19057) x.t x.C ∧ x.M.a 2590 = 2590
  B := fun x => AneFresh x.t ∧ fixedCells x ∧ NativeAt H N PRE_fd_vw_r0_body.s900 x.t

kernel_rfl fresh12 : PRE_fd_vw_r0.S24.tab.all (·.noVar 12) = true
kernel_rfl bodyTab : PRE_fd_vw_r0_body.S0.tab = PRE_fd_vw_r0.S24.tab
kernel_rfl cntBody : countersOkB PRE_fd_vw_r0_body.s0 PRE_fd_vw_r0_body.s900 = true

theorem frames_swap (a : Nat) :
    a ∈ 2665 :: 4910 :: (ghostPf ++ [FDFrames.chunk, FDFrames.buffer, FDFrames.view]) ↔ a ∈ [2665, fr.chunk, fr.buffer, fr.view] ++ framedOf fr.memo fr.ghosts := by
  have e : [2665, fr.chunk, fr.buffer, fr.view] ++ framedOf fr.memo fr.ghosts =
      [2665, FDFrames.chunk, FDFrames.buffer, FDFrames.view, 4910, 1824, 1834, 1852, 1993, 2001] := rfl
  rw [e]
  simp only [ghostPf, List.cons_append, List.nil_append, List.mem_cons, List.not_mem_nil, or_false]
  constructor <;> (intro h; rcases h with rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl <;> simp)

theorem rowBox {i : Cls.Inst} {ν : Nat → F64} (hi : InRow final_ord.r0 i) (h12 : ν 12 = F64.ofNat 1)
    (h10 : ν 10 = F64.ofNat (i.L - 1)) (h11 : ν 11 = F64.ofNat (i.L - 1)) (h16 : ν 16 = F64.ofNat (capL (i.L - 1))) :
    ∃ v, Lin.InBox PRE_fd_vw_r0_body.ps 0 v ∧ Lin.VarsOk ν v PRE_fd_vw_r0_body.V := by
  obtain ⟨_, x, hx, hq⟩ := hi
  simp only [final_ord.r0, InBox, QOk, Inst.get, eval_mk, dot] at hx hq
  refine ⟨x, ?_, ?_⟩
  · simp only [PRE_fd_vw_r0_body.ps, InBox]
    omega
  · simp only [PRE_fd_vw_r0_body.V, Lin.VarsOk]
    refine ⟨?_, ?_, ?_, ?_, trivial⟩
    · rw [h10]; exact ofNat_ofInt (by simp [Aff.eval, dot, Lin.P]; omega)
    · rw [h11]; exact ofNat_ofInt (by simp [Aff.eval, dot, Lin.P]; omega)
    · rw [h12]; exact ofNat_ofInt (by simp [Aff.eval, dot])
    · rw [h16]; exact ofNat_ofInt (by unfold capL; simp [Aff.eval, dot, Lin.P]; omega)

theorem flatStep {NB T cap H N : Nat} {tk : Nat → Nat} {π : List Nat} {i : Cls.Inst} (x0 : SegInst FF)
    (hcap : cap ≤ 4096 + 1593835520) (hi : InRow final_ord.r0 i) :
    CutStep (withMem (NTrack x0) (forwardCut NB T tk π cap H N i))
      (withMem (NTrack x0) (returnCut NB T tk π cap H N)) 1502774 := by
  rintro t C ⟨x, rfl, rfl, ⟨K0, hr, hb, hip, hins, -⟩, ⟨hf, hids, hnat⟩, htr⟩
  obtain ⟨h2, hLmax, -, -⟩ := rowFacts hi
  have hlen : (lastRows π).length = 1 := lastRows_length (by rw [hb.length]; omega)
  have hL := hb.length
  let ν' := upd x.ν 12 (F64.ofNat 1)
  have hfree : ∀ e ∈ PRE_fd_vw_r0.S24.tab, e.noVar 12 = true := fun e he => List.all_eq_true.mp fresh12 e he
  have hoff : ∀ {j : Nat}, j ≠ 12 → ν' j = x.ν j := fun hj => upd_other _ _ hj
  have hrel0 : RelB FF (Disp.FRJ (FullRXD { setupP with rest := machReads T tk } NB))
      (FDFrames.typedW (tokenBytes (lastRows π)) (lastRows π).length) [] x.M ν' x.K PRE_fd_vw_r0.s24 ⟨PRE_fd_vw_r0.S24.tab, []⟩ x.t x.C := by
    refine hr.withTab rfl ⟨fun j e he => ?_, fun _ h => nomatch h⟩
    rw [hr.srv.num j e he]
    exact congrArg some (SymE.eval_upd _ _ _ e (hfree e (nth?_mem_some he))).symm
  have hrel1 : RelB FF (FlatFwd.Native NB T tk (mlxOf x.t.ffi)) (fr.typedW (tokenBytes (lastRows π))) [] x.M ν' x.K
      PRE_fd_vw_r0_body.s0 ⟨PRE_fd_vw_r0_body.S0.tab, []⟩ x.t x.C := by
    rw [PRE_fd_vw_r0_body.s0_eq, bodyTab]
    rw [hlen] at hrel0
    exact { hrel0 with ffi := ⟨⟨hrel0.ffi.1, Host.Mlx.Ffi.NGrow.refl _⟩, hrel0.ffi.2⟩ }
  have hbook : FlatBook T tk π K0 cap ν' x.K := by
    refine
      { vocab := hb.vocab
        valuation := ?_
        rowOne := upd_self _ _ _
        promptValue := (hoff (by decide)).trans hb.promptValue
        rowValue := (hoff (by decide)).trans hb.rowValue
        offsetValue := (hoff (by decide)).trans hb.offsetValue
        capValue := (hoff (by decide)).trans hb.capValue
        reserved := fun j hj => (hoff (by omega)).trans (hins.1 j hj)
        context := ?_
        incomingPrompt := hb.incomingPrompt
        frames := hb.frames
        box := rowBox hi (upd_self _ _ _) ?_ ?_ ?_ }
    · intro j
      by_cases h : j = 12
      · subst h
        exact ⟨1, by decide, upd_self _ _ _⟩
      · rw [hoff h]
        exact hb.valuation j
    · refine ⟨⟨hb.context.1.1, hb.context.1.2.1, fun a => ?_⟩, hb.offset⟩
      rw [hb.context.1.2.2 a]
      exact frames_swap a
    · rw [← hL]; exact (hoff (by decide)).trans hb.rowValue
    · rw [← hL]; exact (hoff (by decide)).trans hb.offsetValue
    · rw [← hL]; exact (hoff (by decide)).trans hb.capValue
  obtain ⟨t', C', hrun, z, rfl, rfl, ⟨hz, hbz⟩, hfz, hidsz, hext⟩ :=
    (PRE_fd_vw_r0_body.fullRun (NB := NB) (T := T) (tk := tk) (cap := cap) (M0 := x.M) (y0 := mlxOf x.t.ffi)
      (flatLaws (T := T) (tk := tk) (π := π) (K0 := K0) hcap)) x.t x.C
      ⟨⟨x.M, ν', x.K, x.t, x.C⟩, rfl, rfl, ⟨hrel1, hbook⟩, hf, hids, Ext.refl _ _⟩
  have ng : Host.Mlx.Ffi.NGrow (mlxOf x.t.ffi) (mlxOf z.t.ffi) := hz.ffi.1.2
  have hz' : RelB FF (Disp.FRJ (FullRXD { setupP with rest := machReads T tk } NB))
      (fr.typedW (tokenBytes (lastRows π))) [] z.M z.ν z.K PRE_fd_vw_r0_body.s900 ⟨PRE_fd_vw_r0_body.S900.tab, []⟩ z.t z.C :=
    { hz with ffi := ⟨hz.ffi.1.1, hz.ffi.2⟩ }
  have hx0 : RelB FF (Disp.FRJ (FullRXD { setupP with rest := machReads T tk } NB))
      (fr.typedW (tokenBytes (lastRows π))) [] x.M ν' x.K PRE_fd_vw_r0_body.s0 ⟨PRE_fd_vw_r0_body.S0.tab, []⟩ x.t x.C :=
    { hrel1 with ffi := ⟨hrel1.ffi.1.1, hrel1.ffi.2⟩ }
  have hnat0 : NativeAt H N PRE_fd_vw_r0_body.s0 x.t := by
    rw [PRE_fd_vw_r0_body.s0_eq]
    exact hnat
  have tr : NTrack x z :=
    ⟨runC_le _ _ _ _ _ hrun, hext.node, ng, tokens_of_grow hx0 hz' ng (countersOkB_tokens cntBody), congrFun hext.a 12504⟩
  refine ⟨z.t, z.C, hrun, z, rfl, rfl, ⟨K0, hz', hbz, ?_, ?_⟩, ⟨hfz, hidsz, ?_⟩, htr.trans tr⟩
  · rw [hext.node]
    exact hip.grow ng tr.server
  · exact (congrFun hext.a 2590).trans hins.2
  · exact NativeAt.step hnat0 rfl hx0 hz' hext.big hext.node cntBody

end Host.Ts.Sim.Compose.FDVW
