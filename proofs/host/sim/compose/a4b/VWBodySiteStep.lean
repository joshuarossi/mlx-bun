import host.sim.compose.a4b.VWBodyCut
import host.sim.compose.PostValue
import host.sim.compose.JsAbove
import host.sim.compose.PreGrow
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill
open Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

/-- The checked facts of one compacting call in the VW body: every field is a kernel fact the
site's generated modules state, so an instance only names them. -/
structure BodySiteFacts (sa sm sc s0 : St FF.S) (Sa Sm Sc : SSrv) (ws cws nr pl l : List Nat)
    (n1 nC : Nat) (D : RData) (κ : Map) (P0 : LoadP) (c c2 : Conv.Cnt) : Prop where
  zkap : κ = Conv.Map.compact sa.next n1 Sa.tab.length pl (nr.map NumV.ref) D.big D.region D.nodeF
  clean : Conv.JClean c sa
  cfix : Conv.FixOld c κ
  zpl : pl.all (Nat.ble sa.next) = true
  zplnd : nodupT pl PTrie.nil = true
  zn1 : Nat.ble sa.next n1 = true
  zfirst : Nat.ble aFirst sa.next = true
  zscn : sc.next = sa.next + pl.length
  zsmn : sm.next = n1
  zgrow : Nat.ble sc.next sm.next = true
  mergeTab : Sm.tab = Sa.tab ++ Conv.resTab ws
  zfresh : Sa.tab.all (fun e => cws.all fun v => e.noVar v) = true
  zcnd : nodupT cws PTrie.nil = true
  lenc : cws.length = nr.length
  znrHi : nr.all (fun r => Nat.blt r Sm.tab.length) = true
  zfrlt : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => Nat.blt a sa.next) = true
  zgP : sc.heap.get 2665 = some (.obj (Template.objOf sc 2665))
  zkP : (Template.objOf sc 2665).kind = .array (arrOf s0 2665)
  zmP : sm.heap.get 2665 = some (.obj { κ.obj (Template.objOf sc 2665) with
    kind := .array (arrOf s0 2665 ++ (arrOf sm 2665).drop (arrOf s0 2665).length) })
  zgC : sc.heap.get VWFrames.chunk = some (.obj (Template.objOf sc VWFrames.chunk))
  zkC : (Template.objOf sc VWFrames.chunk).kind = .array (arrOf s0 VWFrames.chunk)
  zmC : sm.heap.get VWFrames.chunk = some (.obj { κ.obj (Template.objOf sc VWFrames.chunk) with
    kind := .array (arrOf s0 VWFrames.chunk ++ (arrOf sm VWFrames.chunk).drop (arrOf s0 VWFrames.chunk).length) })
  start2665 : arrOf s0 2665 = []
  startChunk : arrOf s0 VWFrames.chunk = []
  zwB : (sc.heap.get VWFrames.buffer).isSome = true
  zwV : (sc.heap.get VWFrames.view).isSome = true
  cheap : sc.heap = Stage.setAll sa.heap (l.filterMap fun a => (sc.heap.get a).map (a, ·))
  zclbd : l.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
  hml : ∀ a, a ∉ l → a < sa.next → sm.heap.get a = sa.heap.get a
  ckeepP : Conv.keptPresentB sa sc l = true
  csupp : Conv.suppListB sc nC l = true
  cbound : Conv.boundListB sc l = true
  zimg : HeapImg κ sc sm (l.filter fun a => !([2665, VWFrames.chunk].contains a))
  zctl : sm.ctl = κ.ctl sc.ctl
  zstack : sm.stack = sc.stack.map κ.frame
  zjobs : sm.jobs = sc.jobs.map κ.job
  zstores : sm.stores = κ.stores sc.stores
  zroots : checkRootsSupp sc nC = true
  znC : Sa.tab.length + cws.length = nC
  ctab : Sc.tab = Sa.tab ++ cws.map SymE.var
  zbin : (bridgeOf sc.ffi).active = false
  cbridge : bridgeOf sm.ffi = bridgeOf sc.ffi
  sbridge : bridgeOf sm.ffi = bridgeOf sa.ffi
  cwsDisj : cws.all (fun c => !ws.contains c) = true
  cshiftR : ∀ {BR : Map → FF.S → FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map} {y : FF.S},
    FullRB BR P NB M Sa.tab.length sa.ffi y → P.NL ≤ P0.NL → Conv.FullShiftQ P0 nC κ sc.ffi sm.ffi
  nnextLe : (mlxOf sa.ffi).nnext ≤ P0.NL
  raised : Raised setupP P0
  cbigs : bigsOutB (mlxOf sc.ffi).next setupP.E (mlxOf sc.ffi) = true
  cjcl : Conv.JClean c sa → Conv.JClean c2 sc
  xnLe : c2.xn ≤ (mlxOf sc.ffi).next
  loLe : setupP.lo ≤ (mlxOf sc.ffi).next
  zroots2 : noBigRootsP (fun i => !Conv.oldBigB c2 i) sc.trace sc = true
  sameH : (mlxOf sm.ffi).next = (mlxOf sc.ffi).next
  sameN : (mlxOf sm.ffi).nnext = (mlxOf sc.ffi).nnext
  jsHeap : JsHeapAbove sa.next sc
  jsRoots : noBigRootsP (jsAboveB sa.next) sc.trace sc = true
  jsNative : bigsOutB jsLoN jsHiN (mlxOf sc.ffi) = true
  framesEmpty : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf sm a).isEmpty) = true
  inputOld : 15235 < c.nn
  lowVars : (cws ++ ws).all (Nat.ble 9) = true

section
variable {sa sm sc s0 : St FF.S} {Sa Sm Sc : SSrv} {ws cws nr pl l : List Nat}
  {n1 nC : Nat} {D : RData} {κ : Map} {P0 : LoadP} {c c2 : Conv.Cnt}

private theorem framedNext_empty {F : Ffi} {s : St F.S} {a : Nat} (M : Map) (K : Ctx)
    (he : arrOf s a = []) : Shift.framedNext M K s a = K.fr a := by
  unfold Shift.framedNext
  cases hf : K.fr a with
  | none => rfl
  | some p =>
    obtain ⟨pre, pre'⟩ := p
    cases hg : s.heap.get a with
    | none => rfl
    | some obj =>
      cases obj with
      | cell v => rfl
      | obj o =>
        cases hk : o.kind <;>
          simp_all only [arrOf, hg, hk, List.drop_nil, Map.vals, List.map_nil, List.append_nil]

theorem bodyFramesNext {s : St FF.S} {M : Map} {K : Ctx} {bs : List Byte} {n : Nat}
    (hemp : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf s a).isEmpty) = true)
    (hk : Disp.Kp (VWFrames.typedJ bs n) K) : Shift.framedNext M K s = K.fr := by
  funext a
  by_cases hf : K.fr a = none
  · exact (framedNext_none_iff (M := M) (s1 := s) a).mpr hf |>.trans hf.symm
  · have ha := (hk.2.2 a).mp hf
    have he := List.all_eq_true.mp hemp a ha
    apply framedNext_empty
    exact List.isEmpty_iff.mp he

/-- A site's shift under the body's wide frames (`Conv.compact_shift`). -/
theorem bodyShift (F : BodySiteFacts sa sm sc s0 Sa Sm Sc ws cws nr pl l n1 nC D κ P0 c c2)
    {K : Ctx} {bs : List Byte} {n : Nat} {π γ : List Nat}
    (hk : Disp.Kp (VWFrames.typedJ bs n) K)
    (hframe : K.fr 2665 = some ([], π.map natV))
    (hchunk : K.fr VWFrames.chunk = some ([], γ.map natV))
    (hcall : Conv.CallFacts sa Sa.tab.length)
    (hnative : Conv.FullShiftQ P0 nC κ sc.ffi sm.ffi)
    (hfreshW : ∀ e ∈ Sa.tab, ∀ w ∈ ws, e.noVar w = true) :
    ShiftD FF (fun σ x y => x = sc.ffi ∧ Conv.FullShiftQX P0 Sc.tab.length σ x y)
      κ (Conv.compactθZ cws (nr.map fun r => (nth? Sm.tab r).getD (.var 0)) ws)
      (kpOf K (compactW bs n)) (compactW bs n) K sc ⟨Sc.tab, []⟩ sm ⟨Sm.tab, []⟩ := by
  have hroots := checkRootsSupp_sound (s := sc) F.zroots
  rw [← F.znC] at hroots
  have hkeptP : ∃ xs, sm.heap.get 2665 = some (.obj { κ.obj (Template.objOf sc 2665) with kind := .array ([] ++ xs) }) := by
    refine ⟨arrOf sm 2665, ?_⟩
    have h := F.zmP
    rw [F.start2665] at h
    simpa only [List.length_nil, List.drop_zero] using h
  have hkeptC : ∃ xs, sm.heap.get VWFrames.chunk =
      some (.obj { κ.obj (Template.objOf sc VWFrames.chunk) with kind := .array ([] ++ xs) }) := by
    refine ⟨arrOf sm VWFrames.chunk, ?_⟩
    have h := F.zmC
    rw [F.startChunk] at h
    simpa only [List.length_nil, List.drop_zero] using h
  have hband : P0.lo = setupP.lo ∧ P0.E = setupP.E := by
    rcases F.raised with h | ⟨_, -, -, h⟩ <;> rw [h] <;> exact ⟨rfl, rfl⟩
  have hs := Conv.compact_shift (F := FF) (W := compactW bs n) (K1 := K)
    (s := sa) (sc := sc) (sm := sm) (tab := Sa.tab) (tabm := Sm.tab)
    (ws := ws) (cws := cws) (nr := nr) (pl := pl) (l := l) (n1 := n1) (D := D) (c := c) (κ := κ)
    (Xs := [2665, VWFrames.chunk]) (Fd := [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view])
    F.zkap hcall F.clean F.cfix
    (fun p hp => Nat.le_of_ble_eq_true (List.all_eq_true.mp F.zpl p hp))
    (nodupT_sound F.zplnd).2 (Nat.le_of_ble_eq_true F.zn1)
    (Nat.le_of_ble_eq_true F.zfirst) F.zscn F.zsmn
    (Nat.le_of_ble_eq_true F.zgrow) F.mergeTab
    (noVar_of_all F.zfresh) (nodupT_sound F.zcnd).2 F.lenc
    (fun r hr => Nat.blt_eq.mp (List.all_eq_true.mp F.znrHi r hr))
    hk.2.2 (fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp F.zfrlt a ha))
    (by
      intro a
      by_cases hv : a = VWFrames.view
      · subst hv; simp [compactW, Disp.wAt, VWFrames.view, VWFrames.buffer, VWFrames.chunk]
      · by_cases hb : a = VWFrames.buffer
        · subst hb; simp [compactW, Disp.wAt, VWFrames.view, VWFrames.buffer, VWFrames.chunk]
        · rw [compactW_none hb hv]
          simp only [and_true, List.mem_cons, List.not_mem_nil, or_false, hv, hb, or_false])
    (by
      intro a w hw
      rcases compactW_domain hw with rfl | rfl <;> simp)
    (by
      intro a pre pre' hka hw
      have ha := (hk.2.2 a).mp (by rw [hka]; exact Option.some_ne_none _)
      have hx : a = 2665 ∨ a = VWFrames.chunk := by
        by_cases hv : a = VWFrames.view
        · subst hv
          simp [compactW, Disp.wAt] at hw
        · by_cases hb : a = VWFrames.buffer
          · subst hb
            simp [compactW, Disp.wAt, VWFrames.view, VWFrames.buffer] at hw
          · change a ∈ [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view] at ha
            simp only [List.mem_cons, List.not_mem_nil, or_false] at ha
            rcases ha with h | h | h | h
            · exact .inl h
            · exact .inr h
            · exact (hb h).elim
            · exact (hv h).elim
      rcases hx with rfl | rfl
      · rw [hframe] at hka
        cases hka
        obtain ⟨xs, hxs⟩ := hkeptP
        refine ⟨_, xs, F.zgP, ?_, hxs⟩
        rw [F.zkP, F.start2665]
      · rw [hchunk] at hka
        cases hka
        obtain ⟨xs, hxs⟩ := hkeptC
        refine ⟨_, xs, F.zgC, ?_, hxs⟩
        rw [F.zkC, F.startChunk])
    (by
      intro a w hw
      rcases compactW_domain hw with rfl | rfl
      · exact F.zwB
      · exact F.zwV)
    (by
      intro a w hw
      rcases compactW_domain hw with rfl | rfl
      · have he : compactW bs n VWFrames.buffer = some (.buf bs) := rfl
        rw [he] at hw
        cases hw
        trivial
      · have he : compactW bs n VWFrames.view = some (.typed .i32 VWFrames.buffer 0 n) := rfl
        rw [he] at hw
        cases hw
        change κ.a VWFrames.buffer = VWFrames.buffer
        rw [F.zkap]
        exact Conv.Map.compact_lt (Nat.blt_eq.mp (List.all_eq_true.mp F.zfrlt VWFrames.buffer (by simp))))
    (Conv.heap_off_setAll F.cheap (fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp F.zclbd a ha)))
    F.hml F.ckeepP (by rw [F.znC]; exact F.csupp) F.cbound F.zimg
    F.zctl F.zstack F.zjobs F.zstores
    hroots.1 hroots.2.1 hroots.2.2.1 hroots.2.2.2
    (Conv.bigFixed_of_mshift hnative.load.mlx (hk.1.trans hband.1.symm) (hk.2.1.trans hband.2.symm))
  have hs' : ShiftD FF (fun _ _ _ => True) κ
      (Conv.compactθ cws (nr.map fun r => (nth? Sm.tab r).getD (.var 0)))
      (kpOf K (compactW bs n)) (compactW bs n) K sc ⟨Sc.tab, []⟩ sm ⟨Sm.tab, []⟩ := by
    rw [F.ctab]
    exact hs
  have hθ := hs'.retheta (θ' := Conv.compactθZ cws (nr.map fun r => (nth? Sm.tab r).getD (.var 0)) ws) (by
    rw [F.ctab]
    exact Conv.compactθZ_tab hfreshW (disj_of_all F.cwsDisj))
  have hlen : Sc.tab.length = nC := by
    rw [F.ctab, List.length_append, List.length_map]
    exact F.znC
  exact { hθ with ffi := ⟨rfl, by
    rw [hlen]
    exact hnative.toX F.zbin⟩ }

end

end Host.Ts.Sim.Compose.VWFirst
