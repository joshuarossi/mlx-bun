import host.sim.compose.a4b.SetupDropData
import host.sim.compose.a4b.SetupLiteralCommon
import host.sim.compose.NumSource

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.SetupDrop
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

noncomputable def cut (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (L : Nat) : ICut FF :=
  { pbCut (Disp.FRJ (FullRXD { setupP with rest := machReads T tk } NB)) setupJ wideP [(9, .L)]
      PRE_setup_early_r0.s16 PRE_setup_early_r0.S16 (setupI L) with
    B := fun x => SetupCommon.ChunkBook L x ∧ setupInputs T tk x ∧ fixedCells x ∧ baseNums ∧
      PromptFr π x ∧ NativeAt 0 0 PRE_setup_early_r0.s16 x.t }

/-- Bounded vocabulary values are decoded from the retained floating-point prefix. -/
theorem natV_map_inj {a b : List Nat} (ha : ∀ k ∈ a, k < 248320) (hb : ∀ k ∈ b, k < 248320)
    (h : a.map natV = b.map natV) : a = b := by
  induction a generalizing b with
  | nil =>
    cases b with
    | nil => rfl
    | cons _ _ => simp at h
  | cons p a ih =>
    cases b with
    | nil => simp at h
    | cons q b =>
      have hc := List.cons.inj h
      have hn : F64.ofNat p = F64.ofNat q := NumV.lit.inj (Val.num.inj hc.1)
      have hi := congrArg F64.truncInt hn
      have hp := ha p List.mem_cons_self
      have hq := hb q List.mem_cons_self
      rw [Disp.truncInt_ofNat (by omega), Disp.truncInt_ofNat (by omega)] at hi
      have hpq : p = q := Int.ofNat_inj.mp (Option.some.inj hi)
      rw [hpq, ih (b := b) (fun k hk => ha k (List.mem_cons_of_mem _ hk))
        (fun k hk => hb k (List.mem_cons_of_mem _ hk)) hc.2]

/-- The prompt a book's frame holds is the route's. -/
theorem promptEq {π' π : List Nat} {x : SegInst FF} (hv : ∀ k ∈ π', k < 248320)
    (hπ : ∀ k ∈ π, k < 248320) (hf : x.K.fr 2665 = some ([], π'.map natV)) (hp : PromptFr π x) :
    π' = π :=
  natV_map_inj hv hπ (congrArg Prod.snd (Option.some.inj (hf.symm.trans hp)))

private theorem map_fixed_tail {α : Type} {f : α → α} : ∀ (r s : List α),
    (r ++ s).map f = r ++ s → s.map f = s := by
  intro r
  induction r with
  | nil => intro s h; exact h
  | cons a r ih =>
    intro s h
    exact ih s (List.cons.inj h).2

theorem tableAt {j : Nat} {e : SymE} (h : nth? PRE_setup_early_r0.S16.tab j = some e) :
    nth? PRE_g0b.S10.tab (Sim.skipNum 10 j) = some e := by
  have hj : j < 14 := by simpa only [oldLen] using nth?_lt _ _ _ h
  have he := List.all_eq_true.mp tableImage j (List.mem_range.mpr hj)
  exact (of_decide_eq_true he).symm.trans h

/-- Remove the setup-only C entry while retaining the actual lookahead queue,
loaded values, prompt frame, native state and fixed driver cells. -/
theorem toOld {NB T L : Nat} {tk : Nat → Nat} {ρ : List Nat} {Mem : SegInst FF → Prop}
    (hMem : ∀ x y, NTrack x y → Mem x → Mem y) (hC : chunkC L = 2048) :
    CutConv (withMem Mem (SetupCommon.nextCut NB T tk ρ L)) (withMem Mem (cut NB T tk ρ L)) := by
  rintro x ⟨hr, hq⟩ ⟨⟨⟨⟨hk, hmemo, π, hlen, hvocab, hframe, hfresh, hnum⟩, hv, hbase, hsmall⟩, hids, hp, hnat⟩, hm⟩
  change RelB FF (Disp.FRJ (FullRXD { setupP with rest := machReads T tk } NB)) wideP []
    x.M x.ν x.K (PRE_g0b.s10 : St FF.S) ⟨PRE_g0b.S10.tab, []⟩ x.t x.C at hr
  change x.M.num 10 = .lit (F64.ofNat (chunkC L)) at hnum
  let N := x.M.skipNum 10
  have hcomp : N.after σ = x.M := eraseNum_after x.M 10 (F64.ofNat 2048) (by rwa [hC] at hnum)
  have hnames : Ext x.M N 0 := (Map.skipNum_ext x.M 10).mono (by decide)
  have hbound : ∀ a ∈ writes, a / 4096 < 4 ^ 31 :=
    fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp writesBound a ha)
  have hheap : ∀ a, PRE_setup_early_r0.s16.heap.get a = (PRE_g0b.s10.heap.get a).map σ.hobj :=
    heap_eraseNum_of_off (b := (PRE_setup_early_r0.s6 : St FF.S))
      (s := (PRE_g0b.s10 : St FF.S)) (s' := (PRE_setup_early_r0.s16 : St FF.S)) hbase
      (Conv.heap_off_setAll newWrites hbound) (Conv.heap_off_setAll oldWrites hbound) heapImage
  have hpre : ∀ a pre pre', x.K.fr a = some (pre, pre') → σ.vals pre = pre := by
    intro a pre pre' ha
    have hm : a ∈ [2665] := (hq.2.1.2.2 a).mp (by rw [ha]; exact Option.some_ne_none _)
    obtain rfl := List.mem_singleton.mp hm
    rw [hframe] at ha
    cases ha
    rfl
  have hbaseTrace : x.K.base.map σ.event = x.K.base := by
    obtain ⟨fresh, hs, _⟩ := hr.trace
    apply map_fixed_tail fresh x.K.base
    rw [← hs]
    exact traceEq.symm.trans traceSame
  have hsrv : Srv N x.ν ⟨PRE_setup_early_r0.S16.tab, []⟩ x.C :=
    hr.srv.skipNum 10 (fun j e he => ⟨e, tableAt he, rfl⟩) (fun _ h => nomatch h)
  have hffi := fullRXDJ_skipNum hr.ffi (numClosedB_sound nativeClosed) (by decide : 9 ≤ 10) (by decide : 9 ≤ 14)
  have hffi' : Disp.FRJ (FullRXD { setupP with rest := machReads T tk } NB)
      N PRE_setup_early_r0.S16.tab.length PRE_setup_early_r0.s16.ffi x.t.ffi := by
    rw [oldLen, nativeEq]
    exact hffi
  have hr' := rel_numImage (S' := ⟨PRE_setup_early_r0.S16.tab, []⟩) hr
    (by rfl : σ.a = id) hcomp hnames hheap nextEq ctlEq stackEq jobsEq
    storesEq traceEq hbaseTrace hpre
    (fun j hj => by
      change Supp.nv _ PRE_setup_early_r0.S16.tab.length ((eraseNum 10 (F64.ofNat 2048)).num j)
      rw [oldLen]
      exact eraseNum_supp (F64.ofNat 2048) (by decide : 10 ≤ 14) (by simpa only [newLen] using hj))
    hsrv hffi'
  refine ⟨⟨N, x.ν, x.K, x.t, x.C⟩, rfl, rfl, ⟨hr', hq.1, hq.2.1, ?_⟩,
    ⟨⟨⟨hk, hmemo, π, hlen, hvocab, hframe, hfresh⟩, hsmall⟩, ?_, ?_, hbase, hp, ?_⟩,
    hMem x _ (NTrack.conv rfl rfl hnames.node) hm⟩
  · exact ⟨hq.2.2.1, trivial⟩
  · exact ⟨hv.1, hv.2⟩
  · exact hids
  · have e : mlxOf (PRE_setup_early_r0.s16 : St FF.S).ffi = mlxOf (PRE_g0b.s10 : St FF.S).ffi :=
      congrArg mlxOf nativeEq
    change (mlxOf x.t.ffi).next ≤ (mlxOf (PRE_setup_early_r0.s16 : St FF.S).ffi).next + 0 ∧
      (mlxOf x.t.ffi).nnext ≤ (mlxOf (PRE_setup_early_r0.s16 : St FF.S).ffi).nnext + 0
    rw [e]
    exact hnat

end Host.Ts.Sim.Compose.SetupDrop
