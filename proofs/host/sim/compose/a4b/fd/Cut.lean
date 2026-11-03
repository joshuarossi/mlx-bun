import host.sim.compose.a4b.fd.G1Input
import host.sim.compose.a4b.fd.Nps
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option autoImplicit false
namespace Host.Ts.Sim.Compose.FDVW
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill
open Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk Host.Ts.Sim.Compose.Pf

/-! # The final step's cuts, to its dispatch

The chunk is the prompt's last token, its length a literal. The frames are the pre-final cut's and the chunk's. -/

/-- What the prefix carries: the pre-final book's values, the frames over the incoming context, the input's event. -/
structure ForwardBook (i : Cls.Inst) (π : List Nat) (K0 : Ctx) (x : SegInst FF) (cap : Nat) : Prop where
  length : π.length = i.L
  vocab : ∀ k ∈ π, k < 248320
  valuation : VBOkF loopVB x.ν
  promptValue : x.ν 9 = F64.ofNat π.length
  rowValue : x.ν 10 = F64.ofNat (π.length - 1)
  offsetValue : x.ν 11 = F64.ofNat (π.length - 1)
  capValue : x.ν 16 = F64.ofNat (capL (π.length - 1))
  context : Disp.KpJ (FDFrames.typedJ (tokenBytes (lastRows π)) (lastRows π).length) 131072 x.K
  incoming : Disp.Kp FDFrames.startJ K0
  incomingPrompt : K0.fr 2665 = some ([], π.map natV)
  frames : x.K.fr = (g1Framed K0 π).fr
  offset : x.K.D ≤ cap
  lo : x.K.lo = K0.lo
  hi : x.K.hi = K0.hi
  inputEvent : ∃ asR ret pre tr, x.K.base' = pre ++
    ⟨chars!"mlx_array_new_data", .jsPtr (x.M.a FDFrames.buffer) 0 (tokenBytes (lastRows π)) :: asR, ret⟩ :: tr

noncomputable def typedCut (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (cap H N : Nat) (s : St FF.S) (S : SSrv) (i : Cls.Inst) : ICut FF where
  s0 := s
  tab0 := S.tab
  R := fun x s S => ∃ K0,
    RelB FF (Disp.FRJ (FullRXD { setupP with rest := machReads T tk } NB))
      (FDFrames.typedW (tokenBytes (lastRows π)) (lastRows π).length) [] x.M x.ν x.K s S x.t x.C ∧
    ForwardBook i π K0 x cap ∧ InputAt (lastRows π) (x.M.node 15235) x.t x.C ∧
    setupInputs T tk x ∧ MapOk x.ν i fdMap
  B := fun x => AneFresh x.t ∧ fixedCells x ∧ NativeAt H N s x.t

noncomputable abbrev dispatchCut (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (cap H N : Nat) :=
  typedCut NB T tk π cap H N PRE_fd_vw_r0.s21 PRE_fd_vw_r0.S21

theorem rowMap {T cap : Nat} {tk : Nat → Nat} {π : List Nat} {i : Cls.Inst} {x : SegInst FF}
    (hi : InRow final_ord.r0 i) (hL : π.length = i.L) (hb : PfBook T tk cap π x) : MapOk x.ν i fdMap := by
  obtain ⟨_, _, ho, hc⟩ := rowFacts hi
  refine ⟨?_, ?_, ?_, ?_, trivial⟩
  · change x.ν 9 = F64.ofNat i.L
    rw [← hL]
    exact hb.promptValue
  · change x.ν 10 = F64.ofNat i.o
    rw [ho, ← hL]
    exact hb.rowValue
  · change x.ν 11 = F64.ofNat i.o
    rw [ho, ← hL]
    exact hb.offsetValue
  · change x.ν 16 = F64.ofNat i.cap
    rw [hc, ← hL]
    exact hb.capValue

kernel_rfl cnt21 : countersOkB PRE_fd_vw_r0.s2 PRE_fd_vw_r0.s21 = true
theorem inactive2 : (bridgeOf PRE_fd_vw_r0.s2.ffi).active = false := PRE_fd_vw_r0.zbin0
kernel_rfl bridge16 : bridgeOf PRE_fd_vw_r0.s16.ffi = bridgeOf PRE_fd_vw_r0.s2.ffi
kernel_rfl bridge21 : bridgeOf PRE_fd_vw_r0.s21.ffi = bridgeOf PRE_fd_vw_r0.s2.ffi

theorem g1 {NB T cap H N : Nat} {tk : Nat → Nat} {π : List Nat} {i : Cls.Inst} {Mem : SegInst FF → Prop}
    (hMem : ∀ x y, NTrack x y → Mem x → Mem y) (hrow : InRow final_ord.r0 i) (hL : π.length = i.L) (hcap : cap ≤ 131072)
    (horacle : ∀ ν, MapOk ν i fdMap → Good ν g1Oracle) :
    CutStep (withMem Mem (Pf.cut NB T tk π cap H N PRE_fd_vw_r0.s2 PRE_fd_vw_r0.S2))
      (withMem Mem (dispatchCut NB T tk π cap H N i)) 260 := by
  rintro t C ⟨x, rfl, rfl, ⟨hr, hb⟩, ⟨hfresh, hids, hnat⟩, hm⟩
  have hmap := rowMap hrow hL hb
  obtain ⟨h2, hLmax, _, _⟩ := rowFacts hrow
  have hk : Disp.KpJ FDFrames.startJ 131072 x.K := ⟨hb.context.1, Nat.le_trans hb.context.2 hcap⟩
  have hi16 : (bridgeOf PRE_fd_vw_r0.s16.ffi).active = false := by rw [bridge16]; exact inactive2
  have hi21 : (bridgeOf PRE_fd_vw_r0.s21.ffi).active = false := by rw [bridge21]; exact inactive2
  obtain ⟨M', t', C', K', hrun, hext, hrel, hkp, hframes, hD, hlo, hhi, hev, hinput, ng⟩ :=
    g1Run_input hr hk hb.valuation (G1Good.ofGood (horacle x.ν hmap)) hb.prompt (by omega) (by omega)
      hb.promptValue hb.rowValue hi16 hb.vocab
  have hbk : ForwardBook i π x.K ⟨M', x.ν, K', t', C'⟩ cap := by
    refine ⟨hL, hb.vocab, hb.valuation, hb.promptValue, hb.rowValue, hb.offsetValue, hb.capValue, hkp, hk.1, hb.prompt, hframes,
      by change K'.D ≤ cap; rw [hD]; exact hb.context.2, hlo, hhi, ?_⟩
    obtain ⟨asR, ret, tr, hev⟩ := hev
    exact ⟨asR, ret, [], tr, hev⟩
  have fresh : AneFresh t' := by
    obtain ⟨_, _, r0⟩ := hr.ffi.1
    obtain ⟨_, _, r1⟩ := hrel.ffi.1
    have he : bridgeOf t'.ffi = bridgeOf x.t.ffi :=
      (r1.toR hi21).bridge.1.trans (bridge21.trans (r0.toR inactive2).bridge.1.symm)
    intro Cx Pc Kc weights kind NE IP G init
    rw [he]
    exact hfresh Cx Pc Kc weights kind NE IP G init
  have ids : fixedCells (⟨M', x.ν, K', t', C'⟩ : SegInst FF) := by
    change M'.a 2586 = 2586 ∧ M'.a 2589 = 2589
    rw [hext.a]
    exact hids
  have inputs : setupInputs T tk (⟨M', x.ν, K', t', C'⟩ : SegInst FF) :=
    ⟨hb.inputs.1, by change M'.a 2590 = 2590; rw [hext.a]; exact hb.inputs.2⟩
  exact ⟨t', C', hrun, ⟨M', x.ν, K', t', C'⟩, rfl, rfl,
    ⟨x.K, hrel, hbk, hinput, inputs, hmap⟩, ⟨fresh, ids,
    hnat.step (P := { setupP with rest := machReads T tk }) rfl hr hrel hext.big hext.node cnt21⟩,
    hMem x _ ⟨runC_le _ _ _ _ _ hrun, hext.node, ng, tokens_of_grow hr hrel ng (countersOkB_tokens cnt21), congrFun hext.a 12504⟩ hm⟩

end Host.Ts.Sim.Compose.FDVW
