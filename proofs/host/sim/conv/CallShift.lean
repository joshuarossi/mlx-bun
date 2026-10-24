import host.sim.conv.CompactShift
import host.sim.world.IterCut
import host.sim.full.World
import host.sim.conv.CompactFull
namespace Host.Ts.Sim.Conv
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill Host.Load.Layers

/-! # A decode call's compaction shift

`compact_shift` at a decode chain's call link (`callShift`, the call link's `hshift`): every segment
instance at the merged cut, its context framed as the acceptance's (`Disp.Kp`) and its frames the
iteration's (`IterGhostCW.fr`: `frA`, the kept arrays at the chain start's prefixes, `framed_of_frA`),
from the generator's checks of the call (its `SiteZ` facts). -/

/-- **The kept arrays' frame facts from the iteration's frames**: each kept array's prefix is the
chain start's array (`frA`'s forwarded and emitted arrays, the further frames by `hX`). -/
theorem framed_of_frA {S : Type} {A : Addr} {s0 sc sm : St S} {X : Nat → Option (List Val × List Val)}
    {p q : List Val} {K : Ctx} {W : Nat → Option WFrame} {κ : Map} {Xs : List Nat}
    (hfr : K.fr = frA A s0 X p q) (hX : ∀ a pre pre', X a = some (pre, pre') → pre = arrOf s0 a)
    (hXs : ∀ a, K.fr a ≠ none → W a = none → a ∈ Xs)
    (hk : ∀ a ∈ Xs, ∃ o xs, sc.heap.get a = some (.obj o) ∧ o.kind = .array (arrOf s0 a) ∧
      sm.heap.get a = some (.obj { κ.obj o with kind := .array (arrOf s0 a ++ xs) })) :
    ∀ a pre pre', K.fr a = some (pre, pre') → W a = none → ∃ o xs, sc.heap.get a = some (.obj o) ∧
      o.kind = .array pre ∧ sm.heap.get a = some (.obj { κ.obj o with kind := .array (pre ++ xs) }) := by
  intro a pre pre' hka hw
  have hne : K.fr a ≠ none := by rw [hka]; exact Option.some_ne_none _
  have hpre : pre = arrOf s0 a := by
    rw [hfr] at hka
    by_cases h1 : a = A.fwd
    · subst h1; rw [frA_fwd] at hka; cases hka; rfl
    · by_cases h2 : a = A.emit
      · subst h2; rw [frA_emit] at hka; cases hka; rfl
      · rw [frA_other A s0 X p q h1 h2] at hka; exact hX a pre pre' hka
  subst hpre
  exact hk a (hXs a hne hw)

/-- **A decode call's compaction shift** (the call link's `hshift`): `compact_shift` at every
instance of the merged cut, from the call's bookkeeping `hclean`, the map's fixed names `hfix`, the
native shift `hffi`, the iteration's further frames' prefixes `hX`, and the generator's checks (the
`z` facts; `nC` the canonical table's length). -/
theorem callShift {NB : Nat} {P : LoadP} {J : Disp.JSP FF} {A : Addr} {Fr : LoopFramesA A} {s0 : St FF.S}
    {tab0 : List SymE} {fixA : List Nat} {θ : Nat → SymE} {g : GhostP} {W : Nat → Option WFrame}
    {sa sc sm s2 s20 : St FF.S} {xm : FF.S} {τ : Map} {rs : List Frame} {tab tabm : List SymE}
    {ws cws nr pl Xs l wr : List Nat} {n1 nC n : Nat} {D : RData} {c : Cnt} {κ : Map}
    (hκ : κ = Map.compact sa.next n1 tab.length pl (nr.map NumV.ref) D.big D.region D.nodeF)
    (hclean : JClean c sa) (hfix : FixOld c κ) (hffi : FullShiftQ P n κ sc.ffi sm.ffi)
    (hJlo : J.lo = P.lo) (hJhi : J.hi = P.E)
    -- the map's places and counters
    (zpl : pl.all (Nat.ble sa.next) = true) (zplnd : nodupT pl PTrie.nil = true) (zn1 : Nat.ble sa.next n1 = true)
    (zfirst : Nat.ble aFirst sa.next = true) (zscn : sc.next = sa.next + pl.length) (zsmn : sm.next = n1)
    (zgrow : Nat.ble sc.next sm.next = true)
    -- the tables
    (hmtab : tabm = tab ++ resTab ws) (zfresh : tab.all (fun e => cws.all fun v => e.noVar v) = true)
    (zcnd : nodupT cws PTrie.nil = true) (hlenc : cws.length = nr.length)
    (znrHi : nr.all (fun r => Nat.blt r tabm.length) = true) (hnC : tab.length + cws.length = nC)
    -- the frames
    (zfrlt : J.framed.all (fun a => Nat.blt a sa.next) = true)
    (hXs : ∀ a, a ∈ Xs ↔ a ∈ J.framed ∧ W a = none) (hWfr : ∀ a w, W a = some w → a ∈ J.framed)
    (hX : ∀ a pre pre', Fr.X a = some (pre, pre') → pre = arrOf s0 a)
    (hkept : ∀ a ∈ Xs, ∃ o xs, sc.heap.get a = some (.obj o) ∧ o.kind = .array (arrOf s0 a) ∧
      sm.heap.get a = some (.obj { κ.obj o with kind := .array (arrOf s0 a ++ xs) }))
    (hWP : ∀ a w, W a = some w → Present sc a) (hWF : ∀ a w, W a = some w → WFix κ (Present sc) w)
    -- the heap
    (zclbd : l.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true)
    (cheap : sc.heap = Stage.setAll sa.heap (l.filterMap fun a => (sc.heap.get a).map (a, ·)))
    (hmer : sm = mergeSt Map.id τ rs wr sa s2 s20 xm) (hwrbd : ∀ b ∈ wr, b / 4096 < 4 ^ 31)
    (zwr : wr.all (fun b => !Nat.blt b sa.next || l.contains b) = true)
    (ckeep : keptPresentB sa sc l = true) (csupp : suppListB sc nC l = true) (cbound : boundListB sc l = true)
    (zimg : HeapImg κ sc sm (l.filter fun a => !Xs.contains a))
    -- the roots
    (zctl : sm.ctl = κ.ctl sc.ctl) (zstack : sm.stack = sc.stack.map κ.frame)
    (zjobs : sm.jobs = sc.jobs.map κ.job) (zstores : sm.stores = κ.stores sc.stores)
    (zroots : checkRootsSupp sc nC = true) :
    ∀ x0 x : SegInst FF, CallFacts sa tab.length → Disp.Kp J x.K →
      IterGhostCW (fullWorld NB) A P Fr s0 tab0 fixA θ g x0 x →
      ShiftD FF (fun _ _ _ => True) κ (compactθ cws (nr.map fun r => (nth? tabm r).getD (.var 0))) (kpOf x.K W) W
        x.K sc ⟨tab ++ cws.map SymE.var, []⟩ sm ⟨tabm, []⟩ := by
  intro x0 x hcf hK hB
  obtain ⟨_, _, _, -, hfrx⟩ := hB.fr
  have hframed := framed_of_frA (sc := sc) (sm := sm) (κ := κ) (W := W) hfrx hX
    (fun a hne hw => (hXs a).mpr ⟨(hK.2.2 a).mp hne, hw⟩) hkept
  obtain ⟨hctlS, hstackS, hjobsS, hstoresS⟩ := checkRootsSupp_sound zroots
  subst hnC
  refine compact_shift hκ hcf hclean hfix (fun p hp => Nat.le_of_ble_eq_true (List.all_eq_true.mp zpl p hp))
    (nodupT_sound zplnd).2 (Nat.le_of_ble_eq_true zn1) (Nat.le_of_ble_eq_true zfirst) zscn zsmn
    (Nat.le_of_ble_eq_true zgrow) hmtab (fun e he w hw => List.all_eq_true.mp (List.all_eq_true.mp zfresh e he) w hw)
    (nodupT_sound zcnd).2 hlenc (fun r hr => Nat.blt_eq.mp (List.all_eq_true.mp znrHi r hr)) hK.2.2
    (fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp zfrlt a ha)) hXs hWfr hframed hWP hWF
    (heap_off_setAll cheap fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp zclbd a ha))
    (mergeSt_heap_off hmer hwrbd fun b hb hlt => ?_) ckeep csupp cbound zimg zctl zstack zjobs zstores
    hctlS hstackS hjobsS hstoresS
    (bigFixed_of_mshift hffi.load.mlx (hK.1.trans hJlo) (hK.2.1.trans hJhi))
  have h := List.all_eq_true.mp zwr b hb
  simp only [Bool.or_eq_true, Bool.not_eq_true'] at h
  rcases h with h | h
  · rw [Nat.blt_eq.mpr hlt] at h; cases h
  · exact List.contains_iff_mem.mp h

end Host.Ts.Sim.Conv
