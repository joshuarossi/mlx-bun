import host.route.PostSimulation
import host.sim.compose.PostTransport
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
namespace Host.Ts.Sim.Compose.Post
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Route
open Host.Load.Run.Tpl

/-- A wider offset bound keeps the book. -/
theorem Book.mono {T cap cap' : Nat} {tk : Nat → Nat} {π γ : List Nat} {x : SegInst FF}
    (h : Book T tk cap π γ x) (hc : cap ≤ cap') : Book T tk cap' π γ x :=
  { h with context := ⟨h.context.1, Nat.le_trans h.context.2 hc⟩ }

theorem indexedCut_mono {NB T cap cap' : Nat} {tk : Nat → Nat} {π : List Nat} {s : St FF.S} {S : SSrv}
    (hc : cap ≤ cap') : CutConv (indexedCut NB T tk cap π s S) (indexedCut NB T tk cap' π s S) := by
  rintro x ⟨γ, hr, hb⟩ hB
  exact ⟨x, rfl, rfl, ⟨γ, hr, hb.mono hc⟩, hB⟩

/-- A step of every prompt's indexed cut is a step of the length's cut. -/
theorem cut_step {NB T cap cap' L n : Nat} {tk : Nat → Nat} {s s' : St FF.S} {S S' : SSrv}
    (h : ∀ π, π.length = L → CutStep (indexedCut NB T tk cap π s S) (indexedCut NB T tk cap' π s' S') n) :
    CutStep (cut NB T tk cap L s S) (cut NB T tk cap' L s' S') n := by
  rintro t C ⟨x, rfl, rfl, ⟨π, hπ, hr⟩, hB⟩
  obtain ⟨t', C', hrun, y, ht, hC, hr', hB'⟩ := h π hπ x.t x.C ⟨x, rfl, rfl, hr, hB⟩
  exact ⟨t', C', hrun, y, ht, hC, ⟨π, hπ, hr'⟩, hB'⟩

/-- A checked POST glue stretch keeps the prompt book.  Row ten's singleton fact proves its checks;
the acceptance is transported to the admitted offset. -/
theorem glue {NB T cap n : Nat} {tk : Nat → Nat} {π : List Nat} {sa sb : St FF.S} {Sa Sb : SSrv}
    (hcap : cap ≤ 4096 + 1593835520)
    (ha : ∀ bs, PostHeadSmall.ok bs sa Sa = true)
    (hrun : ∀ bs, runOk FF (PostHeadSmall.ok bs) n sa Sa = some (sb, Sb))
    (htop : noRetBlock sb = true)
    (hgood : ∀ ν : Nat → F64, ν 10 = F64.ofNat 1 → Good ν Sa.oracle)
    (hi : (bridgeOf sa.ffi).active = false) (hbr : bridgeOf sb.ffi = bridgeOf sa.ffi) :
    CutStep (indexedCut NB T tk cap π sa Sa) (indexedCut NB T tk cap π sb Sb) n := by
  rintro t C ⟨x, rfl, rfl, ⟨γ, hr, hb⟩, hf, hanc⟩
  let bs := bytes γ
  have hs := hr.withOracle (hgood x.ν hb.rowValue)
  have hq : RelB FF
      (Disp.FRJ (FRQ (FullRXD (PostSimulation.params T tk) NB)
        fun y => Host.Mlx.Ffi.NGrow (mlxOf x.t.ffi) (mlxOf y)))
      (D1Frames.typedW bs) [] x.M x.ν x.K sa Sa x.t x.C :=
    { hs with ffi := ⟨⟨hs.ffi.1, Host.Mlx.Ffi.NGrow.refl _⟩, hs.ffi.2⟩ }
  have hok := PostSimulation.accepted_signed hcap (ha bs)
  have hrun' := PostSimulation.run_signed hcap (hrun bs)
  have hsim := PostSimulation.simulationQ NB T tk bs jsSignedLimit cap le_rfl [] (mlxOf x.t.ffi)
  obtain ⟨M', t', C', ht, he, hx⟩ :=
    Disp.runOk_simXVB FF _ _ _ _ [] _ hsim.xv (fun _ _ _ => .inl rfl) x.ν x.K
      hb.context ⟨hb.valuation, hb.rowValue⟩ n x.M sa Sa x.t x.C sb Sb (.inl hq) hok hrun'
  have hrel := (hx.rel_noRet htop).withOracle (o := []) (fun _ h => nomatch h)
  have hout : RelB FF (Disp.FRJ (FullRXD (PostSimulation.params T tk) NB))
      (D1Frames.typedW bs) [] M' x.ν x.K sb ⟨Sb.tab, []⟩ t' C' :=
    { hrel with ffi := ⟨hrel.ffi.1.1, hrel.ffi.2⟩ }
  have hbook := hb.grow he hrel.ffi.1.2 (runC_le _ _ _ _ _ ht)
  obtain ⟨_, _, r0⟩ := hs.ffi.1
  obtain ⟨_, _, r1⟩ := hout.ffi.1
  have hi' : (bridgeOf sb.ffi).active = false :=
    (congrArg (fun b : Host.Mlx.FfiAne.St => b.active) hbr).trans hi
  have hbridge : bridgeOf t'.ffi = bridgeOf x.t.ffi :=
    (r1.toR hi').bridge.1.trans (hbr.trans (r0.toR hi).bridge.1.symm)
  have hf' : AneFresh t' := by
    intro Cx Pc Kc weights kind NE IP G init
    rw [hbridge]
    exact hf Cx Pc Kc weights kind NE IP G init
  exact ⟨t', C', ht, ⟨M', x.ν, x.K, t', C'⟩, rfl, rfl, ⟨γ, hout, hbook⟩, hf',
    ⟨(congrFun he.a 2586).trans hanc.1, (congrFun he.a 2589).trans hanc.2⟩⟩

end Host.Ts.Sim.Compose.Post
