import host.ts.renameOrdinary.DriverMapFor
import host.ts.renameOrdinary.MapStorageRoles
import host.ts.RenameMapIndexEffects
import host.ts.RenameParametricTests

set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false

namespace Host.Load.Run.Full.Ordinary
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric

namespace MapIndex

theorem source_control : P.RestStream.micro0.micro0.s89.ctl =
    .ex (.for_ (some (.decl .let_ [(.id ['i'],some (.lit (.num ['0'])))]))
      (some (.bin .lt (.id ['i']) (.id ['n']))) MapFor89.sourceUpdate MapFor89.sourceBody) MapFor89.sourceEnv := by host_kernel_rfl

theorem lookup_n : lookupEnv ['n'] MapFor89.sourceEnv = some 3126675 := by host_kernel_rfl

theorem source_compare_control : P.RestStream.micro0.micro0.s99.ctl = .ret (natV 2) := by host_kernel_rfl

theorem source_compare_frame : P.RestStream.micro0.micro0.s99.stack =
    .e (.binR .lt (natV 0))::P.RestStream.micro0.micro0.s99.stack.tail := by host_kernel_rfl

theorem source_compare_run (C₀ : CSrv) : interpC (step P.F P.RestStream.micro0.micro0.s99).run C₀ =
    some (P.RestStream.micro0.micro0.s100,C₀) := by host_kernel_rfl

end MapIndex

/-- The first map loop comparison reads the literal index zero and length
two from the actual initializer, copied iteration cell, and existing length cell. -/
theorem map_for_literals_fields (FR : Ren → P.F.S → P.F.S → Prop)
    (R : Ren) (ν₀ ν : Nat → F64) (C₀ C : CSrv) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event)
    (s : St P.F.S) (h : StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' P.RestStream.micro0.micro0.s88 s)
    (lengthCell : s.heap.get (R.a 3126675) = some (.cell (some (natV 2))))
    (targetBound : s.next+2 ≤ 2^64) :
    ∃ result, runC P.F 11 s C = some (result,C) ∧
      StateR (NumberRoles ν₀ ν C₀ C) FR R (mapIterationLive live) framed before after old old'
        P.RestStream.micro0.micro0.s99 result ∧
      result.ctl = .ret (natV 2) ∧ (∃ fs, result.stack = .e (.binR .lt (natV 0))::fs) ∧
      result.heap.get (R.a 3126679) = some (.cell (some (natV 0))) ∧
      (∀ k, live k → result.heap.get (R.a k) = s.heap.get (R.a k)) := by
  let NR := NumberRoles ν₀ ν C₀ C
  obtain ⟨result,hr,hresult⟩ := map_for_transport FR R ν₀ ν C₀ C live framed before after old old' s h targetBound
  obtain ⟨s89,hr88,h89⟩ := MapFor88.transport NR FR R C₀ C live framed before after old old' s h
  change St P.F.S at s89
  change StateR NR FR R live framed before after old old' P.RestStream.micro0.micro0.s89 s89 at h89
  have hp1 : runC P.F 1 s C = some (s89,C) :=
    runC_cons P.F 0 s s89 s89 C C C (h.control.isHalt_eq.trans map_for_active88) hr88 rfl
  have ht : runC P.F 10 s89 C = some (result,C) := by
    change runWith P.F interpC (1+10) s C = some (result,C) at hr
    have hp : runWith P.F interpC 1 s C = some (s89,C) := hp1
    rw [runWith_add,hp] at hr
    exact hr
  have heap89 : s89.heap = s.heap := step_map_block_next_heap P.F NR FR R C C live framed before after old old'
    MapFor88.input s s89 h MapFor88.sourceValue MapFor88.sourceStatement MapFor88.sourceRest
    MapFor88.sourceEnv MapFor88.sourceTail MapFor88.source_control MapFor88.source_frame hr88
  have hc89 := (h89.control_view MapIndex.source_control).ex_view
  have hl := h89.controlLive
  change treeSupport live (Encode.ctl P.RestStream.micro0.micro0.s89.ctl) at hl
  rw [MapIndex.source_control] at hl
  have hnl := env_lookup_live ['n'] MapFor89.sourceEnv 3126675 hl.2.1 MapIndex.lookup_n
  have hn : lookupEnv ['n'] (R.env MapFor89.sourceEnv) = some (R.a 3126675) := by
    rw [lookupEnv_map,MapIndex.lookup_n]; rfl
  have hv : s89.heap.get (R.a 3126675) = some (.cell (some (natV 2))) := by rw [heap89]; exact lengthCell
  have hb : s89.next+1 < 2^64 := by rw [h.target_next_eq h89 map_for_next89]; omega
  have actual := map_index_run P.F s89 C ['i'] ['n'] MapFor89.sourceUpdate MapFor89.sourceBody
    (R.env MapFor89.sourceEnv) (R.a 3126675) (natV 2) hc89 (by rfl) hn hv
    (h89.heap.targetBound 3126675 hnl) hb
  rw [ht] at actual
  have he := congrArg Prod.fst (Option.some.inj actual)
  dsimp only at he
  refine ⟨result,hr,hresult,?_,?_,?_,?_⟩
  · rw [he]; rfl
  · rw [he]; exact ⟨_,rfl⟩
  · have source_index : P.RestStream.micro0.micro0.s89.next+1 = 3126679 := by host_kernel_rfl
    have mapped : R.a 3126679 = s89.next+1 := by simpa only [source_index] using h89.heap.fresh 1
    rw [he,mapped]
    exact mapIndexResult_index s89 ['i'] ['n'] MapFor89.sourceUpdate MapFor89.sourceBody
      (R.env MapFor89.sourceEnv) (natV 2) hb
  · intro k hk
    rw [he]
    exact (mapIndexResult_frame s89 ['i'] ['n'] MapFor89.sourceUpdate MapFor89.sourceBody
      (R.env MapFor89.sourceEnv) (natV 2) (R.a k) (h89.heap.targetBound k hk) hb).trans
        (congrArg (fun heap => heap.get (R.a k)) heap89)

theorem map_for_literals (FR : Ren → P.F.S → P.F.S → Prop)
    (R : Ren) (ν₀ ν : Nat → F64) (C₀ C : CSrv) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event)
    (s : St P.F.S) (h : StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' P.RestStream.micro0.micro0.s88 s)
    (lengthCell : s.heap.get (R.a 3126675) = some (.cell (some (natV 2))))
    (targetBound : s.next+2 ≤ 2^64) :
    ∃ result, runC P.F 11 s C = some (result,C) ∧
      StateR (NumberRoles ν₀ ν C₀ C) FR R (mapIterationLive live) framed before after old old'
        P.RestStream.micro0.micro0.s99 result ∧
      result.ctl = .ret (natV 2) ∧ ∃ fs, result.stack = .e (.binR .lt (natV 0))::fs := by
  obtain ⟨result,hr,hs,hc,hf,_,_⟩ := map_for_literals_fields FR R ν₀ ν C₀ C live framed before after old old'
    s h lengthCell targetBound
  exact ⟨result,hr,hs,hc,hf⟩

/-- The original first map guard is true because its two concrete operands
were obtained by execution. No target guard or target comparison is assumed. -/
theorem map_comparison_transport (FR : Ren → P.F.S → P.F.S → Prop)
    (R : Ren) (ν₀ ν : Nat → F64) (C₀ C : CSrv) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event)
    (s : St P.F.S) (h : StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' P.RestStream.micro0.micro0.s99 s)
    (hc : s.ctl = .ret (natV 2)) (frames : ∃ fs, s.stack = .e (.binR .lt (natV 0))::fs) :
    ∃ result, interpC (step P.F s).run C = some (result,C) ∧
      StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old'
        P.RestStream.micro0.micro0.s100 result ∧ result.ctl = .ret (.bool true) := by
  obtain ⟨fs,hf⟩ := frames
  obtain ⟨hr₀,hr,hpost⟩ := step_comparison_roles P.F FR R ν₀ ν C₀ C live framed before after old old'
    P.RestStream.micro0.micro0.s99 s h .lt (.lit (F64.ofNat 0)) (.lit (F64.ofNat 0))
    (.lit (F64.ofNat 2)) (.lit (F64.ofNat 2)) (.lit (F64.ofNat 0)) (.lit (F64.ofNat 2))
    P.RestStream.micro0.micro0.s99.stack.tail fs
    (.literal ν₀ ν C₀ C _) (.literal ν₀ ν C₀ C _)
    MapIndex.source_compare_control hc MapIndex.source_compare_frame hf true (by rfl) (by rfl)
  rw [MapIndex.source_compare_run] at hr₀
  have he := congrArg Prod.fst (Option.some.inj hr₀)
  dsimp only at he
  rw [← he] at hpost
  exact ⟨_,hr,hpost,rfl⟩

theorem map_for_guard (FR : Ren → P.F.S → P.F.S → Prop)
    (R : Ren) (ν₀ ν : Nat → F64) (C₀ C : CSrv) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event)
    (s : St P.F.S) (h : StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' P.RestStream.micro0.micro0.s88 s)
    (lengthCell : s.heap.get (R.a 3126675) = some (.cell (some (natV 2))))
    (targetBound : s.next+2 ≤ 2^64) :
    ∃ result, runC P.F 12 s C = some (result,C) ∧
      StateR (NumberRoles ν₀ ν C₀ C) FR R (mapIterationLive live) framed before after old old'
        P.RestStream.micro0.micro0.s100 result ∧ result.ctl = .ret (.bool true) := by
  obtain ⟨s99,hr99,h99,hctl,hframes⟩ := map_for_literals FR R ν₀ ν C₀ C live framed before after old old'
    s h lengthCell targetBound
  obtain ⟨result,hr,hresult,hguard⟩ := map_comparison_transport FR R ν₀ ν C₀ C (mapIterationLive live)
    framed before after old old' s99 h99 hctl hframes
  have ht : runC P.F 1 s99 C = some (result,C) := runC_cons P.F 0 s99 result result C C C
    (by rw [hctl]; rfl) hr rfl
  exact ⟨result,runC_join P.F hr99 ht,hresult,hguard⟩

theorem map_setup_next88 : P.RestStream.micro0.micro0.s88.next = P.RestStream.micro0.micro0.s74.next+1 := by host_kernel_rfl

theorem map_for_guard_fields (FR : Ren → P.F.S → P.F.S → Prop)
    (R : Ren) (ν₀ ν : Nat → F64) (C₀ C : CSrv) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event)
    (s : St P.F.S) (h : StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' P.RestStream.micro0.micro0.s88 s)
    (lengthCell : s.heap.get (R.a 3126675) = some (.cell (some (natV 2))))
    (targetBound : s.next+2 ≤ 2^64) :
    ∃ result, runC P.F 12 s C = some (result,C) ∧
      StateR (NumberRoles ν₀ ν C₀ C) FR R (mapIterationLive live) framed before after old old'
        P.RestStream.micro0.micro0.s100 result ∧ result.ctl = .ret (.bool true) ∧
      result.heap.get (R.a 3126679) = some (.cell (some (natV 0))) ∧
      (∀ k, live k → result.heap.get (R.a k) = s.heap.get (R.a k)) := by
  obtain ⟨s99,hr99,h99,hctl,hframes,hindex,hframe⟩ := map_for_literals_fields FR R ν₀ ν C₀ C live framed before after old old'
    s h lengthCell targetBound
  obtain ⟨result,hr,hresult,hguard⟩ := map_comparison_transport FR R ν₀ ν C₀ C (mapIterationLive live)
    framed before after old old' s99 h99 hctl hframes
  have heap : result.heap = s99.heap := by
    obtain ⟨fs,hf⟩ := hframes
    have hs : step P.F s99 = M.pure ({s99 with stack := fs}.ret (.bool true)) := by
      rw [step_comparison_eq P.F s99 .lt (.lit (F64.ofNat 0)) (.lit (F64.ofNat 2)) fs hctl hf]
      rfl
    rw [hs] at hr
    have he := congrArg Prod.fst (Option.some.inj hr)
    exact (congrArg St.heap he).symm
  have ht : runC P.F 1 s99 C = some (result,C) := runC_cons P.F 0 s99 result result C C C
    (by rw [hctl]; rfl) hr rfl
  refine ⟨result,runC_join P.F hr99 ht,hresult,hguard,?_,?_⟩
  · rw [heap]; exact hindex
  · intro k hk; rw [heap]; exact hframe k hk

/-- The actual map setup and first loop guard execute in twenty-six steps.
The length-two and index-zero facts are both derived from program operations. -/
theorem map_setup_guard (FR : Ren → P.F.S → P.F.S → Prop)
    (R : Ren) (ν₀ ν : Nat → F64) (C₀ C : CSrv) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event)
    (s : St P.F.S) (h : StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' P.RestStream.micro0.micro0.s74 s)
    (notFramed : ¬ framed 3126664)
    (prototypeLive : live aArrayProto) (prototypeFixed : R.a aArrayProto = aArrayProto)
    (targetBound : s.next+3 ≤ 2^64) :
    ∃ result, runC P.F 26 s C = some (result,C) ∧
      StateR (NumberRoles ν₀ ν C₀ C) FR R (mapIterationLive (LiveAfter live P.RestStream.micro0.micro0.s84.next))
        framed before after old old' P.RestStream.micro0.micro0.s100 result ∧ result.ctl = .ret (.bool true) := by
  obtain ⟨s88,hr88,h88,hlength⟩ := map_setup_literal (NumberRoles ν₀ ν C₀ C) FR R C₀ C live framed before after old old'
    s h notFramed ⟨_,NumRole.literal ν₀ ν C₀ C (F64.ofNat 2)⟩ prototypeLive prototypeFixed (by omega)
  have hb88 : s88.next+2 ≤ 2^64 := by rw [h.target_next_add h88 1 map_setup_next88]; omega
  obtain ⟨result,hr,hresult,hguard⟩ := map_for_guard FR R ν₀ ν C₀ C
    (LiveAfter live P.RestStream.micro0.micro0.s84.next) framed before after old old' s88 h88 hlength hb88
  exact ⟨result,runC_join P.F hr88 hr,hresult,hguard⟩

/-- Preserve the source-derived index occurrence for the subsequent actual
bracket access, as well as the true first guard. -/
theorem map_setup_guard_index (FR : Ren → P.F.S → P.F.S → Prop)
    (R : Ren) (ν₀ ν : Nat → F64) (C₀ C : CSrv) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event)
    (s : St P.F.S) (h : StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' P.RestStream.micro0.micro0.s74 s)
    (notFramed : ¬ framed 3126664)
    (prototypeLive : live aArrayProto) (prototypeFixed : R.a aArrayProto = aArrayProto)
    (targetBound : s.next+3 ≤ 2^64) :
    ∃ result, runC P.F 26 s C = some (result,C) ∧
      StateR (NumberRoles ν₀ ν C₀ C) FR R (mapIterationLive (LiveAfter live P.RestStream.micro0.micro0.s84.next))
        framed before after old old' P.RestStream.micro0.micro0.s100 result ∧ result.ctl = .ret (.bool true) ∧
      result.heap.get (R.a 3126679) = some (.cell (some (natV 0))) := by
  obtain ⟨s88,hr88,h88,hlength⟩ := map_setup_literal (NumberRoles ν₀ ν C₀ C) FR R C₀ C live framed before after old old'
    s h notFramed ⟨_,NumRole.literal ν₀ ν C₀ C (F64.ofNat 2)⟩ prototypeLive prototypeFixed (by omega)
  have hb88 : s88.next+2 ≤ 2^64 := by rw [h.target_next_add h88 1 map_setup_next88]; omega
  obtain ⟨result,hr,hresult,hguard,hindex,_⟩ := map_for_guard_fields FR R ν₀ ν C₀ C
    (LiveAfter live P.RestStream.micro0.micro0.s84.next) framed before after old old' s88 h88 hlength hb88
  exact ⟨result,runC_join P.F hr88 hr,hresult,hguard,hindex⟩

end Host.Load.Run.Full.Ordinary
