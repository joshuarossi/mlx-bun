import host.route.EndExtract
import host.route.PostGoals
import host.route.cert.Row.Hooks
import host.sim.compose.a4b.FillPaths
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
set_option autoImplicit false
namespace Host.Route.Cert.Row
open Host.Load Host.Load.Extract Host.Load.Program Host.Load.Run.Full
open Host.Mlx Host.Mlx.FfiEval Host.Mlx.SimGraph Host.Ts
open Inference Inference.Contracts.Mlx Inference.Models.Qwen
open Host.Ts.Sim (SegInst)
open Host.Ts.Sim.Full (FF)
open Host.Ts.Sim.Compose.Post (haltPath_goal)
open Host.Ts.Sim.Compose.FillPost (ClassPre Hooks PopHooks pA pB2 pB0 pC1 pC0)
open Host.Route.PrefGraph

/-! # The short paths' goals

The five ways out before the decode loop: the reference held far enough at the halt, and on the paths without EOS the program's
caches at the carriers of the last time held. -/

variable {C : M1Max.Contract} {P : MlxPrefillContract C} {KR : RouteKernelContract C} {NE : NeuralEngine}
  {net : Host.Mlx.SimGraph.Ref.AneNet} {env : FfiEval.Env InKey}
  {NB T cap nI capC nIC : Nat} {tk : Nat → Nat} {π : List Nat} {Pc : ClassPre NB T tk π capC nIC}
  (H : Hooks NB T tk π cap nI Pc)
  (hMem : ∀ j L x, H.MemP j L x → memPost P KR NE net env π j rowToks (rowCr j) L x)
  (hcap : cap ≤ 4096 + 1593835520) (hL1 : 1 ≤ π.length) (hL2 : π.length ≤ 224) (htk : ∀ j, tk j ≤ 248319) (hTle : T ≤ 262143)
  (Q : PopHooks H)

include hMem in
/-- `T ≥ 2`, the first token the end. -/
theorem graphA (h : 2 ≤ T) (he : tk 1 = 248044) :
    (pA H hcap hL1 hL2 htk hTle Q h he).Goal (fun tF CF => ∃ kind, goalMV P KR NE net env π kind NB 1 tF CF) :=
  haltPath_goal _ _ _ _ _ _ _ _ _ _ fun x _ _ htr => memPost_goal (hMem 0 _ x htr) (Nat.le_refl _)

include hMem in
/-- `T = 1`, the first token the end. -/
theorem graphC1 (h : T = 1) (he : tk 1 = 248044) :
    (pC1 H hcap hL1 hL2 htk Q h he).Goal (fun tF CF => ∃ kind, goalMV P KR NE net env π kind NB 1 tF CF) :=
  haltPath_goal _ _ _ _ _ _ _ _ _ _ fun x _ _ htr => memPost_goal (hMem 0 _ x htr) (Nat.le_refl _)

include hMem in
/-- `T = 2`, the second token the end. -/
theorem graphB2 (h : T = 2) (hne : tk 1 ≠ 248044) (he : tk 2 = 248044) :
    (pB2 H hcap hL1 hL2 htk h hne he).Goal (fun tF CF => ∃ kind, goalMV P KR NE net env π kind NB 2 tF CF) :=
  haltPath_goal _ _ _ _ _ _ _ _ _ _ fun x _ _ htr => memPost_goal (hMem 1 _ x htr) (Nat.le_refl _)

include hMem in
/-- `T = 1`, the first token not the end. -/
theorem graphC0 (je : Env) (hc : lookupEnv chars!"cache" je = some 2586) (h : T = 1) (hne : tk 1 ≠ 248044) :
    (pC0 H hcap hL1 hL2 htk Q h hne).Goal (fun tF CF => ∃ kind, goalCV P KR NE net env π kind NB T je tF CF) :=
  haltPath_goal _ _ _ _ _ _ _ _ _ _ fun x hr hb htr => by
    change ∃ kind, goalCV P KR NE net env π kind NB T je x.t x.C
    rw [h]
    obtain ⟨cs, h1, h2⟩ := end_caches hr hb hc t1_cell t1_free t1_ok t1_caches
    rw [t1_nodes] at h2
    exact memPost_goalC hL1 (hMem 0 _ x htr) ⟨cs, h1, h2⟩

include hMem in
/-- `T = 2`, neither token the end. -/
theorem graphB0 (je : Env) (hc : lookupEnv chars!"cache" je = some 2586) (h : T = 2) (hne : tk 1 ≠ 248044) (hne2 : tk 2 ≠ 248044) :
    (pB0 H hcap hL1 hL2 htk h hne hne2).Goal (fun tF CF => ∃ kind, goalCV P KR NE net env π kind NB T je tF CF) :=
  haltPath_goal _ _ _ _ _ _ _ _ _ _ fun x hr hb htr => by
    change ∃ kind, goalCV P KR NE net env π kind NB T je x.t x.C
    rw [h]
    obtain ⟨cs, h1, h2⟩ := end_caches hr hb hc t2_cell t2_free t2_ok t2_caches
    rw [t2_nodes] at h2
    exact memPost_goalC hL1 (hMem 1 _ x htr) ⟨cs, h1, h2⟩

end Host.Route.Cert.Row
