import host.route.cert.Row.Layout
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
set_option autoImplicit false
namespace Host.Route.Cert.Row
open Host.Load Host.Load.Extract Host.Load.Program Host.Load.Run.Full
open Host.Mlx Host.Mlx.GlueStep Host.Mlx.FfiEval Host.Mlx.SimGraph Host.Ts
open Inference Inference.Contracts.Mlx Inference.Models.Qwen
open Host.Mlx.SimGraph.Iter (Gr TplInputs cachesAt cachesAt_nodes loadedAt tensorAt CachesBelow)
open Host.Mlx.SimGraph.Mach (MRef MRefDecodes WeightShapes template_cached_forwardV compat_of_caps shapesOk_of_caps
  CacheValuesV refPrompt)
open Host.Ts.Sim (LoadP Map SegInst capL)
open Host.Ts.Sim.Full (FF mlxOf)
open Host.Load.Run.Full.Cached.Expected2 (stages head)
open Host.Route.PrefGraph

variable {C : M1Max.Contract} (P : MlxPrefillContract C) (KR : RouteKernelContract C) (env : FfiEval.Env InKey)
  (kind : Nat → Option Compiled)

local notation "Mx" => P.toMlxContract
local notation "Kx" => KR.toKernelContract
local notation "Vs" => routeVs P KR env kind

/-- **A POST row's forward at time `L + d`**: the next time's token and handles at the row's outputs. -/
theorem row_fwd (leaves : Leaves code env.weights) (typed : TypedCheckpoint env.weights) {R : MRef} {L0 : Nat}
    (hdec : MRefDecodes Mx Kx (fun tab => weights (firstValues Mx Kx env tab)) R L0)
    {s : Ffi.St} {S : SSrv} {d : Nat} (c : RowCert s S d) (tab : List F64) {Pm : LoadP} {NB m : Nat} {M : Map} {y : Ffi.St}
    (hmr : Host.Ts.Sim.G.MR Pm NB M m s y) (hNB : 15235 ≤ NB) (hband : Pm.NL = Pm.N0)
    (hrope : M.big 5554869888 = 5554869888) (ρ : Nat → F64) {L : Nat} (h1 : 1 ≤ L) (h2 : L ≤ 224)
    (hρ : ∀ x l h, Box.get boxRow x = some (l, h) → ρ x = F64.ofInt (nuRow L x))
    (hnum : ∀ i e, nth? S.tab i = some e → CSrv.val ⟨tab⟩ (M.nv (.ref i)) = some (e.eval ρ))
    {tok tok' : Nat} {hs hs' : List Handles} (hR1 : R tab (L + d) = some (tok, hs)) (hR2 : R tab (L + d + 1) = some (tok', hs'))
    (hb : tok < 2 ^ 31) (hL0 : L0 ≤ L + d) (hint : L + d + 1 < capL (L + d))
    (hcaps : CapsFor (capL (L + d)) (stageWeights (weights (firstValues Mx Kx env tab))) hs)
    (hcv : CacheValuesV ((routeVs P KR env kind).val tab y) (cachesAt M.node c.ps) hs)
    (hfed : ∃ r, (routeVs P KR env kind).val tab y (M.node c.fed) = some r ∧ itemUint32 r = some tok)
    (hpar : ∀ t ∈ parameterTensors parameterChoice, (routeVs P KR env kind).val tab y t.node = some (firstValues Mx Kx env tab t)) :
    (∃ r, (routeVs P KR env kind).val tab y (M.node (certAt c.cert Tpl.Ordinary.tokenNode)) = some r ∧ itemUint32 r = some tok') ∧
      CacheValuesV ((routeVs P KR env kind).val tab y) (cachesAt M.node c.outs) hs' ∧
      CapsFor (capL (L + d + 1)) (stageWeights (weights (firstValues Mx Kx env tab))) hs' := by
  have hstep : stepTrace Mx Kx (weights (firstValues Mx Kx env tab)) (L + d) tok hs = some (tok', hs') := by
    have h := hdec tab (L + d) hL0
    rw [hR2, hR1] at h
    exact h.symm
  have emb : Embeds M.node M.handle (mapG (SDim.eval (L + d)) (rowGs s S d)) (Gr tab y) :=
    row_embeds s S d tab hmr hband hrope ρ h1 h2 hρ hnum
  have hin : ∀ key j, c.insT key = some j → inputNode (loadedAt M.node c.ps) (tensorAt (M.node c.tokenNode)) key = some (M.node j) :=
    c.hins M.node (fun j hj => hmr.nid j (Nat.lt_of_lt_of_le hj hNB))
  obtain ⟨hbr, hfb, hea, hout, hinp, hto⟩ := row_tpl _ (populatedLayoutHandles 256) (caps_eq P KR env tab)
    (layout_eq P KR env tab) (head_eq P KR env tab) c (Gr tab y) M.node M.handle (L + d) emb (loadedAt M.node c.ps)
    (tensorAt (M.node c.tokenNode)) hs (cachesAt M.node c.outs) (capL (L + d)) hcaps hint hin rfl (cachesAt_nodes M.node c.outs)
  obtain ⟨h1', h2', h3⟩ := template_cached_forwardV P KR env kind (fun _ => none) leaves typed tab (L + d) y
    (loadedAt M.node c.ps) (tensorAt (M.node c.tokenNode)) (M.node c.fed) (M.node (certAt c.cert Tpl.Ordinary.tokenNode))
    tok tok' hs hs' (cachesAt M.node c.outs) (capL (L + d)) hstep hb (compat_of_caps hcaps)
    (shapesOk_of_caps _ _ (Host.Ts.Sim.Compose.weightShapes_first Mx Kx env leaves typed tab) hcaps) _ M.node M.handle rfl hpar hcaps hbr hcv
    hfb hea hfed emb hinp hout (congrArg (fun k => M.node (certAt c.cert k)) hto)
  refine ⟨h1', h2', ?_⟩
  rw [Host.Ts.Sim.Compose.kvCap_capL_succ] at h3
  exact h3

end Host.Route.Cert.Row
