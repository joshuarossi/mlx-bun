import host.load.boot.ane.Transfer
import host.load.boot.ane.Bridge
import host.load.run.full.Parameters
set_option Elab.async false
namespace Host.Load.Run.Prompt
open Host.Ts Host.Mlx Host.Mlx.GlueStep Host.Load Host.Load.Boot Host.Load.Extract
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

/-! # The Neural Engine side the boot leaves, checked

At `loadDone` (`P.at2818`, the boundary over every prompt and readback suffix; checked at the empty
ones, the template's): the model object's Neural Engine buckets (`aneX`, `aneLd`) pass `aneCheck` on
the bridge the boot leaves (`replay P.oblog2818 = aneB4`, `aneB_eq`) at the loaded stages' layouts
(`aneLays`, those of `weights` at any tensor contents: `aneLays_any`).

The kernel reads the buckets one at a time at `aneSp`, the template with the prompt array poisoned
(`ane_prompt`: the model's prompt ranges and their units; `ane_bucket<i>`: bucket `i`'s range and
`bucketOk`); the template's buckets are those (`aneX_tr`, `aneSp_tpl`). -/

/-- The route's model object. -/
def aneModel : Val := .obj 80731

/-- **The Neural Engine buckets at `loadDone`.** -/
noncomputable def aneLd : List ABucket := (aneX (P.at2818 [] []) aneModel).getD []

/-- The loaded stages' kinds, projection layouts and MLP widths. -/
noncomputable def aneLays : List LayS := (stageWeights (Run.Full.weights (headerValues fun _ _ => 0))).map laySum

-- the layouts at any tensor contents
kernel_rfl_eager aneLays_any : ∀ c : Nat → Nat → Nat,
  (stageWeights (Run.Full.weights (headerValues c))).map laySum = aneLays

/-- The template at `loadDone` with the prompt array poisoned. -/
noncomputable def aneSp : St LSt := (P.at2818 [] []).setObj 2665 anePoison

/-- The model's prompt ranges of unit `"ane"`. -/
def aneRangeObjs : List Val :=
  [.obj 2671678, .obj 2671680, .obj 2671682, .obj 2671684, .obj 2671686, .obj 2671688, .obj 2671690, .obj 2671692,
    .obj 2671694, .obj 2671696, .obj 2671698, .obj 2671700, .obj 2671702, .obj 2671704, .obj 2671706]

kernel_rfl_eager ane_prompt : ((own aneSp aneModel chars!"prompt").bind (elements aneSp)).map
  (fun pr => (pr.filter (isAne aneSp), pr.all fun r => (own aneSp r chars!"unit").isSome)) = some (aneRangeObjs, true)

kernel_rfl_eager ane_tpl_cell : (P.at2818 [] []).cell? 2665 = none

/-- A bucket's check: its range and `bucketOk` on the boot's bridge. -/
noncomputable def bucketChk (c : Nat × Nat) (b : ABucket) : Bool :=
  decide ((b.lo, b.rows) = c) && bucketOk aneB4 aneLays b

kernel_rfl_eager ane_bucket0 : (aBucket aneSp (.obj 2671678)).map (bucketChk (224, 256)) = some true
kernel_rfl_eager ane_bucket1 : (aBucket aneSp (.obj 2671680)).map (bucketChk (257, 320)) = some true
kernel_rfl_eager ane_bucket2 : (aBucket aneSp (.obj 2671682)).map (bucketChk (321, 384)) = some true
kernel_rfl_eager ane_bucket3 : (aBucket aneSp (.obj 2671684)).map (bucketChk (385, 448)) = some true
kernel_rfl_eager ane_bucket4 : (aBucket aneSp (.obj 2671686)).map (bucketChk (449, 512)) = some true
kernel_rfl_eager ane_bucket5 : (aBucket aneSp (.obj 2671688)).map (bucketChk (513, 576)) = some true
kernel_rfl_eager ane_bucket6 : (aBucket aneSp (.obj 2671690)).map (bucketChk (577, 640)) = some true
kernel_rfl_eager ane_bucket7 : (aBucket aneSp (.obj 2671692)).map (bucketChk (641, 704)) = some true
kernel_rfl_eager ane_bucket8 : (aBucket aneSp (.obj 2671694)).map (bucketChk (705, 768)) = some true
kernel_rfl_eager ane_bucket9 : (aBucket aneSp (.obj 2671696)).map (bucketChk (769, 896)) = some true
kernel_rfl_eager ane_bucket10 : (aBucket aneSp (.obj 2671698)).map (bucketChk (897, 1024)) = some true
kernel_rfl_eager ane_bucket11 : (aBucket aneSp (.obj 2671700)).map (bucketChk (1025, 1280)) = some true
kernel_rfl_eager ane_bucket12 : (aBucket aneSp (.obj 2671702)).map (bucketChk (1281, 1536)) = some true
kernel_rfl_eager ane_bucket13 : (aBucket aneSp (.obj 2671704)).map (bucketChk (1537, 1792)) = some true
kernel_rfl_eager ane_bucket14 : (aBucket aneSp (.obj 2671706)).map (bucketChk (1793, 2048)) = some true

/-! ## The buckets together -/

theorem mapM_zip {α β γ : Type} {f : α → Option β} {P : γ → β → Bool} :
    ∀ (xs : List α) (cs : List γ), xs.length = cs.length → (∀ q ∈ xs.zip cs, (f q.1).map (P q.2) = some true) →
      ∃ bs, xs.mapM f = some bs ∧ bs.length = cs.length ∧ ∀ q ∈ bs.zip cs, P q.2 q.1 = true
  | [], [], _, _ => ⟨[], rfl, rfl, by simp⟩
  | x :: xs, c :: cs, hl, hq => by
    obtain ⟨b, hb, hP⟩ := Option.map_eq_some_iff.mp (hq (x, c) (by simp))
    obtain ⟨bs, hbs, hlen, hall⟩ :=
      mapM_zip xs cs (by simpa using hl) (fun q hq' => hq q (List.mem_cons_of_mem _ hq'))
    refine ⟨b :: bs, ?_, by simp [hlen], ?_⟩
    · simp [List.mapM_cons, hb, hbs]
    · intro q hq'
      simp only [List.zip_cons_cons, List.mem_cons] at hq'
      rcases hq' with rfl | hq'
      · exact hP
      · exact hall q hq'
  | [], _ :: _, hl, _ => absurd hl (by simp)
  | _ :: _, [], hl, _ => absurd hl (by simp)

theorem ranges_of_zip {B : FfiAne.St} {lays : List LayS} :
    ∀ (bs : List ABucket) (cs : List (Nat × Nat)), bs.length = cs.length →
      (∀ q ∈ bs.zip cs, (decide ((q.1.lo, q.1.rows) = q.2) && bucketOk B lays q.1) = true) →
      bs.map (fun b => (b.lo, b.rows)) = cs ∧ bs.all (bucketOk B lays) = true
  | [], [], _, _ => ⟨rfl, rfl⟩
  | b :: bs, c :: cs, hl, hq => by
    have h1 := hq (b, c) (by simp)
    simp only [Bool.and_eq_true, decide_eq_true_eq] at h1
    obtain ⟨e1, e2⟩ := ranges_of_zip bs cs (by simpa using hl) (fun q hq' => hq q (List.mem_cons_of_mem _ hq'))
    simp [h1.1, h1.2, e1, e2]
  | [], _ :: _, hl, _ => absurd hl (by simp)
  | _ :: _, [], hl, _ => absurd hl (by simp)

theorem ane_buckets : ∀ q ∈ aneRangeObjs.zip aneRangesT, (aBucket aneSp q.1).map (bucketChk q.2) = some true := by
  intro q hq
  simp only [aneRangeObjs, aneRangesT, List.zip_cons_cons, List.zip_nil_left, List.mem_cons, List.not_mem_nil,
    or_false] at hq
  rcases hq with rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl
  exacts [ane_bucket0, ane_bucket1, ane_bucket2, ane_bucket3, ane_bucket4, ane_bucket5, ane_bucket6, ane_bucket7,
    ane_bucket8, ane_bucket9, ane_bucket10, ane_bucket11, ane_bucket12, ane_bucket13, ane_bucket14]

/-- The buckets at the poisoned template pass the check. -/
theorem aneSp_check : ∃ D, aneX aneSp aneModel = some D ∧ aneCheck D aneB4 aneLays = true := by
  obtain ⟨pr, hpr, he⟩ := Option.map_eq_some_iff.mp ane_prompt
  simp only [Prod.mk.injEq] at he
  obtain ⟨bs, hbs, hlen, hall⟩ := mapM_zip (f := aBucket aneSp) aneRangeObjs aneRangesT rfl ane_buckets
  obtain ⟨e1, e2⟩ := ranges_of_zip bs aneRangesT hlen hall
  refine ⟨bs, ?_, ?_⟩
  · unfold aneX
    exact Option.bind_eq_some_iff.mpr ⟨pr, hpr, by rw [he.1]; exact hbs⟩
  · simp [aneCheck, e1, e2]

/-- The template differs from the poisoned one only at the prompt array. -/
theorem aneSp_tpl : Tr aneSp (P.at2818 [] []) where
  obj a ha := by
    show (P.at2818 [] []).obj? a = St.obj? { P.at2818 [] [] with heap := (P.at2818 [] []).heap.set 2665 (.obj anePoison) } a
    unfold St.obj?
    rw [PTrie.get_set_ne _ _ _ (by decide) _ ha]
  cell c := by
    show (P.at2818 [] []).cell? c = St.cell? { P.at2818 [] [] with heap := (P.at2818 [] []).heap.set 2665 (.obj anePoison) } c
    by_cases hc : c = 2665
    · subst hc
      rw [ane_tpl_cell]
      unfold St.cell?
      rw [PTrie.get_set_self _ _ _ (by decide)]
    · unfold St.cell?
      rw [PTrie.get_set_ne _ _ _ (by decide) _ hc]
  poison := by
    show St.obj? { P.at2818 [] [] with heap := (P.at2818 [] []).heap.set 2665 (.obj anePoison) } 2665 = some anePoison
    unfold St.obj?
    rw [PTrie.get_set_self _ _ _ (by decide)]
  host := rfl
  arrs := rfl
  nodes := rfl

theorem aneSp_units : ∀ pr, (own aneSp aneModel chars!"prompt").bind (elements aneSp) = some pr →
    ∀ r ∈ pr, (own aneSp r chars!"unit").isSome = true := by
  intro pr hpr
  obtain ⟨pr', hpr', he⟩ := Option.map_eq_some_iff.mp ane_prompt
  rw [hpr] at hpr'
  cases hpr'
  simp only [Prod.mk.injEq] at he
  exact List.all_eq_true.mp he.2

/-- **The buckets at `loadDone` pass the check** on the bridge the boot leaves. -/
theorem aneLd_check : aneCheck aneLd (replay P.oblog2818) aneLays = true := by
  obtain ⟨D, hD, hc⟩ := aneSp_check
  have hT := aneX_tr aneSp_tpl aneSp_units hD
  unfold aneLd
  rw [hT, aneB_eq]
  exact hc

end Host.Load.Run.Prompt
