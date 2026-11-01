import host.sim.compose.a4b.FillPost
import host.sim.compose.a4b.pl.T1.All
import host.sim.compose.a4b.pl.T1E.All
import host.sim.compose.a4b.pl.T2.All
import host.sim.compose.a4b.pl.T2E.All
import host.sim.compose.a4b.pl.Ta.All
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option autoImplicit false
namespace Host.Ts.Sim.Compose.FillPost
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template Host.Ts.Sim.Compose.Post
open Host.Load.Run.Tpl Host.Route Host.Load.Run.Prompt

/-! # POST's short paths

The five ways out before the decode loop. Each runs the class's POST to the shared tail, the first readback where it comes
before the path's own chain, and that chain to the halted state. -/

section EndFacts

kernel_rfl t2_halt : PRE_pl_t2.s7.ctl = .halt (.normal .undef)
kernel_rfl t2_emit : PRE_pl_t2.s7.heap.get 12504 = some (.obj (objOf PRE_pl_t2.s7 12504))
kernel_rfl t2_kind : (objOf PRE_pl_t2.s7 12504).kind = .array (arrOf PRE_pl_t2.s7 12504)
kernel_rfl t2_cell : PRE_pl_t2.s7.cell? 2590 = some (some (.obj 12504))
kernel_rfl t2_free : (2665 :: [2673435, PRE_pl_t2.cacheArray]).contains 12504 = false
kernel_rfl t2_vals : arrOf PRE_pl_t2.s7 12504 = [.num (.ref 1), .num (.ref 2)]
kernel_rfl t2_tab1 : nth? PRE_pl_t2.S7.tab 1 = some (.var 1)
kernel_rfl t2_tab2 : nth? PRE_pl_t2.S7.tab 2 = some (.var 2)

kernel_rfl t2e_halt : PRE_pl_t2_eos.s7.ctl = .halt (.normal .undef)
kernel_rfl t2e_emit : PRE_pl_t2_eos.s7.heap.get 12504 = some (.obj (objOf PRE_pl_t2_eos.s7 12504))
kernel_rfl t2e_kind : (objOf PRE_pl_t2_eos.s7 12504).kind = .array (arrOf PRE_pl_t2_eos.s7 12504)
kernel_rfl t2e_cell : PRE_pl_t2_eos.s7.cell? 2590 = some (some (.obj 12504))
kernel_rfl t2e_free : (2665 :: [2673435, PRE_pl_t2_eos.cacheArray]).contains 12504 = false
kernel_rfl t2e_vals : arrOf PRE_pl_t2_eos.s7 12504 = [.num (.ref 1)]
kernel_rfl t2e_tab1 : nth? PRE_pl_t2_eos.S7.tab 1 = some (.var 1)

kernel_rfl ta_halt : PRE_pl_ta.s896.ctl = .halt (.normal .undef)
kernel_rfl ta_emit : PRE_pl_ta.s896.heap.get 12504 = some (.obj (objOf PRE_pl_ta.s896 12504))
kernel_rfl ta_kind : (objOf PRE_pl_ta.s896 12504).kind = .array (arrOf PRE_pl_ta.s896 12504)
kernel_rfl ta_cell : PRE_pl_ta.s896.cell? 2590 = some (some (.obj 12504))
kernel_rfl ta_free : (2665 :: [2673435, PRE_pl_ta.cacheArray]).contains 12504 = false
kernel_rfl ta_vals : arrOf PRE_pl_ta.s896 12504 = []

kernel_rfl t1_emit : PRE_pl_t1.s7.heap.get 12504 = some (.obj (objOf PRE_pl_t1.s7 12504))
kernel_rfl t1_kind : (objOf PRE_pl_t1.s7 12504).kind = .array (arrOf PRE_pl_t1.s7 12504)
kernel_rfl t1_free : (2665 :: [2673435, PRE_pl_t1.cacheArray]).contains 12504 = false

kernel_rfl t1e_emit : PRE_pl_t1_eos.s7.heap.get 12504 = some (.obj (objOf PRE_pl_t1_eos.s7 12504))
kernel_rfl t1e_kind : (objOf PRE_pl_t1_eos.s7 12504).kind = .array (arrOf PRE_pl_t1_eos.s7 12504)
kernel_rfl t1e_free : (2665 :: [2673435, PRE_pl_t1_eos.cacheArray]).contains 12504 = false

kernel_rfl t2e_gen : PRE_pl_t2_eos.s7.cell? 2589 = some (some (.obj 2673245))
noncomputable def t2e_stats : Nat :=
  match ownW PRE_pl_t2_eos.s7 (.obj 2673245) chars!"stats" with
  | some (.obj w) => w
  | _ => 0
kernel_rfl t2e_own : ownW PRE_pl_t2_eos.s7 (.obj 2673245) chars!"stats" = some (.obj t2e_stats)
kernel_rfl t2e_stop : ownW PRE_pl_t2_eos.s7 (.obj t2e_stats) chars!"finishReason" = some (.str chars!"stop")
kernel_rfl t2e_wide : wideP t2e_stats = none

kernel_rfl ta_gen : PRE_pl_ta.s896.cell? 2589 = some (some (.obj 2673245))
noncomputable def ta_stats : Nat :=
  match ownW PRE_pl_ta.s896 (.obj 2673245) chars!"stats" with
  | some (.obj w) => w
  | _ => 0
kernel_rfl ta_own : ownW PRE_pl_ta.s896 (.obj 2673245) chars!"stats" = some (.obj ta_stats)
kernel_rfl ta_stop : ownW PRE_pl_ta.s896 (.obj ta_stats) chars!"finishReason" = some (.str chars!"stop")
kernel_rfl ta_wide : wideP ta_stats = none

kernel_rfl t1e_wide : wideP PRE_pl_t1_eos.statsAddr = none

end EndFacts

theorem vals0 {s : St FF.S} {S : List SymE} {ν : Nat → F64} (he : arrOf s 12504 = []) :
    (arrOf s 12504 ++ []).mapM (symValW ⟨S, []⟩ ν) = some [] := by
  rw [he]
  rfl

theorem vals1 {T : Nat} {tk : Nat → Nat} {s : St FF.S} {S : List SymE} {ν : Nat → F64} (he : arrOf s 12504 = [.num (.ref 1)])
    (h1 : nth? S 1 = some (.var 1)) (hν : ∀ j, j < 9 → ν j = machVal T tk j) :
    (arrOf s 12504 ++ []).mapM (symValW ⟨S, []⟩ ν) = some (tokVals tk 1) := by
  have h : ν 1 = F64.ofNat (tk 1) := (hν 1 (by omega)).trans (by simp [machVal])
  rw [he]
  simp [symValW, h1, SymE.eval, h, tokVals]

theorem vals2 {T : Nat} {tk : Nat → Nat} {s : St FF.S} {S : List SymE} {ν : Nat → F64}
    (he : arrOf s 12504 = [.num (.ref 1), .num (.ref 2)]) (h1 : nth? S 1 = some (.var 1)) (h2 : nth? S 2 = some (.var 2))
    (hν : ∀ j, j < 9 → ν j = machVal T tk j) :
    (arrOf s 12504 ++ []).mapM (symValW ⟨S, []⟩ ν) = some (tokVals tk 2) := by
  have h : ν 1 = F64.ofNat (tk 1) := (hν 1 (by omega)).trans (by simp [machVal])
  have h' : ν 2 = F64.ofNat (tk 2) := (hν 2 (by omega)).trans (by simp [machVal])
  rw [he]
  simp [symValW, h1, h2, SymE.eval, h, h', tokVals, List.range_succ]

section
variable {NB T cap nI capC nIC : Nat} {tk : Nat → Nat} {π : List Nat} {P : ClassPre NB T tk π capC nIC}
  (H : Hooks NB T tk π cap nI P) (hcap : cap ≤ 4096 + 1593835520)
  (hL1 : 1 ≤ π.length) (hL2 : π.length ≤ 224) (htk : ∀ j, tk j ≤ 248319) (hTle : T ≤ 262143)

/-- The readback's pop on each path's own chain. -/
structure PopHooks where
  t1 : ∀ L (x y : SegInst FF), (indexedCut NB T tk cap nI π PRE_pl_t1.s0 PRE_pl_t1.S0).R x PRE_pl_t1.s0 ⟨PRE_pl_t1.S0.tab, []⟩ →
    (indexedCut NB T tk cap nI π PRE_pl_t1.s2 PRE_pl_t1.S2).R y PRE_pl_t1.s2 ⟨PRE_pl_t1.S2.tab, []⟩ →
    CSrv.Le x.C y.C → y.M.node = x.M.node → y.M.a 12504 = x.M.a 12504 →
    Host.Mlx.Ffi.NGrow (mlxOf x.t.ffi) (mlxOf y.t.ffi) → H.MemP 0 L x → H.MemP 0 L y
  t1e : ∀ L (x y : SegInst FF), (indexedCut NB T tk cap nI π PRE_pl_t1_eos.s0 PRE_pl_t1_eos.S0).R x PRE_pl_t1_eos.s0 ⟨PRE_pl_t1_eos.S0.tab, []⟩ →
    (indexedCut NB T tk cap nI π PRE_pl_t1_eos.s2 PRE_pl_t1_eos.S2).R y PRE_pl_t1_eos.s2 ⟨PRE_pl_t1_eos.S2.tab, []⟩ →
    CSrv.Le x.C y.C → y.M.node = x.M.node → y.M.a 12504 = x.M.a 12504 →
    Host.Mlx.Ffi.NGrow (mlxOf x.t.ffi) (mlxOf y.t.ffi) → H.MemP 0 L x → H.MemP 0 L y
  ta : ∀ L (x y : SegInst FF), (indexedCut NB T tk cap nI π PRE_pl_ta.s0 PRE_pl_ta.S0).R x PRE_pl_ta.s0 ⟨PRE_pl_ta.S0.tab, []⟩ →
    (indexedCut NB T tk cap nI π PRE_pl_ta.s6 PRE_pl_ta.S6).R y PRE_pl_ta.s6 ⟨PRE_pl_ta.S6.tab, []⟩ →
    CSrv.Le x.C y.C → y.M.node = x.M.node → y.M.a 12504 = x.M.a 12504 →
    Host.Mlx.Ffi.NGrow (mlxOf x.t.ffi) (mlxOf y.t.ffi) → H.MemP 0 L x → H.MemP 0 L y
  t2 : 2 ≤ T → ∀ L (x y : SegInst FF), (indexedCut NB T tk cap nI π PRE_pl_t2.s0 PRE_pl_t2.S0).R x PRE_pl_t2.s0 ⟨PRE_pl_t2.S0.tab, []⟩ →
    (indexedCut NB T tk cap nI π PRE_pl_t2.s2 PRE_pl_t2.S2).R y PRE_pl_t2.s2 ⟨PRE_pl_t2.S2.tab, []⟩ →
    CSrv.Le x.C y.C → y.M.node = x.M.node → y.M.a 12504 = x.M.a 12504 →
    Host.Mlx.Ffi.NGrow (mlxOf x.t.ffi) (mlxOf y.t.ffi) → H.MemP 1 L x → H.MemP 1 L y
  t2e : 2 ≤ T → ∀ L (x y : SegInst FF), (indexedCut NB T tk cap nI π PRE_pl_t2_eos.s0 PRE_pl_t2_eos.S0).R x PRE_pl_t2_eos.s0 ⟨PRE_pl_t2_eos.S0.tab, []⟩ →
    (indexedCut NB T tk cap nI π PRE_pl_t2_eos.s2 PRE_pl_t2_eos.S2).R y PRE_pl_t2_eos.s2 ⟨PRE_pl_t2_eos.S2.tab, []⟩ →
    CSrv.Le x.C y.C → y.M.node = x.M.node → y.M.a 12504 = x.M.a 12504 →
    Host.Mlx.Ffi.NGrow (mlxOf x.t.ffi) (mlxOf y.t.ffi) → H.MemP 1 L x → H.MemP 1 L y

variable (Q : PopHooks H)

/-- The class's POST, to the shared tail. -/
theorem toTailStep (L : Nat) :
    CutStep (withMem (H.Mem0 L) (indexedCut NB T tk capC nIC π P.sH P.SH))
      (withMem (H.MemP 0 L) (indexedCut NB T tk cap nI π PRE_pl_tail.s0 PRE_pl_tail.S0)) P.n :=
  (hookMemV (fun x0 => P.run (NTrackV x0) (fun _ _ h h0 => ⟨h0.toNTrack.trans h.toNTrack, h.val.trans h0.val⟩))
      (fun x y _ hy _ htr hm => H.hsmp L x y hy htr hm)).convR (H.hlink L)

include hcap in
/-- The first readback and the first warm forward. -/
theorem toR1Step (L : Nat) (hT2 : 2 ≤ T) (hne : tk 1 ≠ 248044) (ht : tk 1 < 2 ^ 31) (hT31 : T < 2 ^ 31)
    (hb : π.length ≤ 253) :
    CutStep (withMem (H.MemP 0 L) (indexedCut NB T tk cap nI π PRE_pl_tail.s0 PRE_pl_tail.S0))
      (withMem (H.MemP 1 L) (indexedCut NB T tk cap nI π PRE_pl_r1.s890 PRE_pl_r1.S890))
      ((nth? PRE_pl_t2p.ks 0).getD 0 + PL.R1.N) :=
  ((popM (nI := nI) (π := π) (modeOk NB T tk cap hcap) PRE_pl_t2p.accepted0 PRE_pl_t2p.run0 t2pTop
      (fun _ h => PRE_pl_t2p.good (T := T) (t := tk 1) (by omega) hT31 ht hne
        ((h.reserved 0 (by omega)).trans rfl) ((h.reserved 1 (by omega)).trans (by simp [machVal])))
      (Host.Load.Boot.replay_active _) t2pBr
      (fun x y hx hy hle hn ha hg hm => H.hpop L x y hx hy hle hn ha hg hm) rfl).convL
      (idxConv PRE_pl_t2p.s0_eq PRE_pl_t2p.s0_tab)).trans
    ((hookMem (fun x0 => PL.R1.all NB T tk cap nI π hcap
        (fun _ h => PRE_pl_r1.good (b := 0) (r := π.length) (by omega) (by have := h.nonempty; omega) (by omega) h.rowValue
          (by simpa using h.offsetValue) (by rw [h.capValue]; unfold capL; have := h.nonempty; congr 1; omega))
        (NTrack x0) (fun _ _ h h0 => h0.trans h.toNTrack))
      (fun x y _ hy _ htr hm => H.hfw0 L x y hy htr.server htr.map htr.nodes htr.tokens htr.emit hm)).convL
      (idxConv PRE_pl_r1.s0_eq PRE_pl_r1.s0_tab))

include hcap Q htk hL2 hL1 in
/-- `T = 1`, the first token the end. -/
noncomputable def pC1 (h : T = 1) (he : tk 1 = 248044) :
    PathW (fullWorldXD NB) addrPrompt wideP setupP shortFixP (withMem (H.Mem0 π.length) (indexedCut NB T tk capC nIC π P.sH P.SH)) [] :=
  haltPath (cap := cap) (T := T) (tk := tk) (NB := NB)
    ((toTailStep H π.length).trans
      ((PL.T1E.all NB T tk cap nI π hcap
          (fun _ b => PRE_pl_t1_eos.good b.rowValue ((b.reserved 0 (by omega)).trans (by rw [h]; rfl))
            ((b.reserved 1 (by omega)).trans (by simp [machVal, he])))
          (H.MemP 0 π.length) (fun x y t => H.hMP 0 π.length x y t.toNTrack) (Q.t1e π.length)).convL
        (idxConv PRE_pl_t1_eos.s0_eq PRE_pl_t1_eos.s0_tab)))
    .undef PRE_pl_t1_eos.halt _ t1e_emit t1e_kind PRE_pl_t1_eos.emissionCell t1e_free (H.fixE 0 π.length)
    (fun _ _ => vals0 PRE_pl_t1_eos.emission)

include hcap Q htk hL2 hL1 in
/-- `T = 1`, the first token not the end. -/
noncomputable def pC0 (h : T = 1) (hne : tk 1 ≠ 248044) :
    PathW (fullWorldXD NB) addrPrompt wideP setupP shortFixP (withMem (H.Mem0 π.length) (indexedCut NB T tk capC nIC π P.sH P.SH))
      (tokVals tk 1) :=
  haltPath (cap := cap) (T := T) (tk := tk) (NB := NB)
    ((toTailStep H π.length).trans
      ((PL.T1.all NB T tk cap nI π hcap
          (fun _ b => PRE_pl_t1.good (t := tk 1) (by have := htk 1; omega) hne b.rowValue
            ((b.reserved 0 (by omega)).trans (by rw [h]; rfl))
            ((b.reserved 1 (by omega)).trans (by simp [machVal])))
          (H.MemP 0 π.length) (fun x y t => H.hMP 0 π.length x y t.toNTrack) (Q.t1 π.length)).convL
        (idxConv PRE_pl_t1.s0_eq PRE_pl_t1.s0_tab)))
    .undef PRE_pl_t1.halt _ t1_emit t1_kind PRE_pl_t1.emissionCell t1_free (H.fixE 0 π.length)
    (fun _ hν => vals1 PRE_pl_t1.emission PRE_pl_t1.tokenVar hν)

include hcap Q htk hL2 hL1 hTle in
/-- `T ≥ 2`, the first token the end. -/
noncomputable def pA (h : 2 ≤ T) (he : tk 1 = 248044) :
    PathW (fullWorldXD NB) addrPrompt wideP setupP shortFixP (withMem (H.Mem0 π.length) (indexedCut NB T tk capC nIC π P.sH P.SH)) [] :=
  haltPath (cap := cap) (T := T) (tk := tk) (NB := NB)
    ((toTailStep H π.length).trans
      ((PL.Ta.all NB T tk cap nI π hcap
          (fun _ b => PRE_pl_ta.good (b := 0) (r := π.length) (T := T) (by omega) hL1 (by omega) h hTle
            ((b.reserved 0 (by omega)).trans rfl) ((b.reserved 1 (by omega)).trans (by simp [machVal, he])) b.rowValue
            (by simpa using b.offsetValue) (by rw [b.capValue, capShort π hL1 hL2]))
          (H.MemP 0 π.length) (fun x y t => H.hMP 0 π.length x y t.toNTrack) (Q.ta π.length)).convL
        (idxConv PRE_pl_ta.s0_eq PRE_pl_ta.s0_tab)))
    .undef ta_halt _ ta_emit ta_kind ta_cell ta_free (H.fixE 0 π.length)
    (fun _ _ => vals0 ta_vals)

include hcap Q htk hL1 hL2 in
/-- `T = 2`, the second token the end. -/
noncomputable def pB2 (h : T = 2) (hne : tk 1 ≠ 248044) (he : tk 2 = 248044) :
    PathW (fullWorldXD NB) addrPrompt wideP setupP shortFixP (withMem (H.Mem0 π.length) (indexedCut NB T tk capC nIC π P.sH P.SH))
      (tokVals tk 1) :=
  haltPath (cap := cap) (T := T) (tk := tk) (NB := NB)
    (((toTailStep H π.length).trans
        (toR1Step H hcap π.length (by omega) hne (by have := htk 1; omega) (by omega) (by omega))).trans
      ((PL.T2E.all NB T tk cap nI π hcap
          (fun _ b => PRE_pl_t2_eos.good (t1 := tk 1) (by have := htk 1; omega) hne
            ((b.reserved 0 (by omega)).trans (by rw [h]; rfl)) ((b.reserved 1 (by omega)).trans (by simp [machVal]))
            ((b.reserved 2 (by omega)).trans (by simp [machVal, he])))
          (H.MemP 1 π.length) (fun x y t => H.hMP 1 π.length x y t.toNTrack) (Q.t2e (by omega) π.length)).convL
        (idxConv PRE_pl_t2_eos.s0_eq PRE_pl_t2_eos.s0_tab)))
    .undef t2e_halt _ t2e_emit t2e_kind t2e_cell t2e_free (H.fixE 1 π.length)
    (fun _ hν => vals1 t2e_vals t2e_tab1 hν)

include hcap Q htk hL1 hL2 in
/-- `T = 2`, neither token the end. -/
noncomputable def pB0 (h : T = 2) (hne : tk 1 ≠ 248044) (hne2 : tk 2 ≠ 248044) :
    PathW (fullWorldXD NB) addrPrompt wideP setupP shortFixP (withMem (H.Mem0 π.length) (indexedCut NB T tk capC nIC π P.sH P.SH))
      (tokVals tk 2) :=
  haltPath (cap := cap) (T := T) (tk := tk) (NB := NB)
    (((toTailStep H π.length).trans
        (toR1Step H hcap π.length (by omega) hne (by have := htk 1; omega) (by omega) (by omega))).trans
      ((PL.T2.all NB T tk cap nI π hcap
          (fun _ b => PRE_pl_t2.good (t1 := tk 1) (t2 := tk 2) (by have := htk 1; omega) hne (by have := htk 2; omega) hne2
            ((b.reserved 0 (by omega)).trans (by rw [h]; rfl)) ((b.reserved 1 (by omega)).trans (by simp [machVal]))
            ((b.reserved 2 (by omega)).trans (by simp [machVal])))
          (H.MemP 1 π.length) (fun x y t => H.hMP 1 π.length x y t.toNTrack) (Q.t2 (by omega) π.length)).convL
        (idxConv PRE_pl_t2.s0_eq PRE_pl_t2.s0_tab)))
    .undef t2_halt _ t2_emit t2_kind t2_cell t2_free (H.fixE 1 π.length)
    (fun _ hν => vals2 t2_vals t2_tab1 t2_tab2 hν)

end

end Host.Ts.Sim.Compose.FillPost
