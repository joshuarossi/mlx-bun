import host.ts.renameOrdinary.DriverMapSetup
import host.ts.RenameMapStorageEffects

set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false

namespace Host.Load.Run.Full.Ordinary
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric

namespace MapStorage

noncomputable def input := P.RestStream.micro0.micro0.s79
noncomputable def env := MapSetup79.sourceEnv
noncomputable def rest : List Stmt := match MapSetup79.sourceTail with
  | .s (.block (_::ss) _)::_ => ss
  | _ => []
noncomputable def tail : List Frame := MapSetup79.sourceTail.tail

theorem source_frame : input.stack = .s (.decl .const (.id ['n']) [] env)::
    .s (.block (.decl .const [(.id ['r'],some (.array []))]::rest) env)::tail := by host_kernel_rfl

theorem lookup_n : lookupEnv ['n'] env = some 3126675 := by host_kernel_rfl
theorem lookup_r : lookupEnv ['r'] env = some 3126676 := by host_kernel_rfl

/-- The executed source segment retains the exact length value and every
other old live cell except the two initialized local bindings. -/
theorem effects (NR : NumV → NumV → Prop) (FR : Ren → P.F.S → P.F.S → Prop)
    (R : Ren) (C : CSrv) (live framed : Nat → Prop) (before after : List Val) (old old' : List Event)
    (s result : St P.F.S) (h : StateR NR FR R live framed before after old old' input s)
    (value : Val) (hc : s.ctl = .ret value) (bound : s.next < 2^64)
    (run : runC P.F 9 s C = some (result,C)) :
    result.heap.get (R.a 3126675) = some (.cell (some value)) ∧
    (∀ k, live k → k ≠ 3126675 → k ≠ 3126676 →
      result.heap.get (R.a k) = s.heap.get (R.a k)) := by
  obtain ⟨f,fs,hf,hfr,hfs⟩ := h.stack_view source_frame
  cases hfs with | cons hblock htail =>
    rw [hfr.decl_view,hblock.block_view] at hf
    have hl := h.stackLive
    rw [source_frame] at hl
    have hel : treeSupport live (Encode.env env) := hl.1.1.2.2.2.1
    have hnl := env_lookup_live ['n'] env 3126675 hel lookup_n
    have hrl := env_lookup_live ['r'] env 3126676 hel lookup_r
    have hn : lookupEnv ['n'] (R.env env) = some (R.a 3126675) := by rw [lookupEnv_map,lookup_n]; rfl
    have hr : lookupEnv ['r'] (R.env env) = some (R.a 3126676) := by rw [lookupEnv_map,lookup_r]; rfl
    have actual := map_storage_run P.F s C ['n'] ['r'] (R.a 3126675) (R.a 3126676)
      value rest (R.env env) _ hc hf hn hr
    rw [run] at actual
    have he := congrArg Prod.fst (Option.some.inj actual)
    dsimp only at he
    rw [he]
    have hnb := h.heap.targetBound 3126675 hnl
    have hrb := h.heap.targetBound 3126676 hrl
    have hnr : R.a 3126675 ≠ R.a 3126676 := by
      intro heq
      have bad := h.heap.inj 3126675 3126676 hnl hrl heq
      contradiction
    refine ⟨mapStorageResult_length s _ _ value rest (R.env env) _ hnb (Nat.lt_trans hrb bound) bound hnr,?_⟩
    intro k hkl hkn hkr
    exact mapStorageResult_frame s _ _ _ value rest (R.env env) _ (Nat.lt_trans hnb bound)
      (Nat.lt_trans hrb bound) bound
      (fun eq => hkn (h.heap.inj k 3126675 hkl hnl eq))
      (fun eq => hkr (h.heap.inj k 3126676 hkl hrl eq))
      (h.heap.targetBound k hkl)

end MapStorage

theorem map_setup_next79 : P.RestStream.micro0.micro0.s79.next = P.RestStream.micro0.micro0.s74.next := by host_kernel_rfl

/-- The exact length-two occurrence is established by the real length read
and retained in the actual local cell after the map prelude executes. -/
theorem map_setup_literal (NR : NumV → NumV → Prop) (FR : Ren → P.F.S → P.F.S → Prop)
    (R : Ren) (C₀ C : CSrv) (live framed : Nat → Prop) (before after : List Val) (old old' : List Event)
    (s : St P.F.S) (h : StateR NR FR R live framed before after old old' P.RestStream.micro0.micro0.s74 s)
    (notFramed : ¬ framed 3126664) (literalTwo : NR (.lit (F64.ofNat 2)) (.lit (F64.ofNat 2)))
    (prototypeLive : live aArrayProto) (prototypeFixed : R.a aArrayProto = aArrayProto)
    (targetBound : s.next+1 ≤ 2^64) :
    ∃ result, runC P.F 14 s C = some (result,C) ∧
      StateR NR FR R (LiveAfter live P.RestStream.micro0.micro0.s84.next) framed before after old old'
        P.RestStream.micro0.micro0.s88 result ∧
      result.heap.get (R.a 3126675) = some (.cell (some (natV 2))) := by
  obtain ⟨result,hr,hresult⟩ := map_setup_transport NR FR R C₀ C live framed before after old old'
    s h notFramed literalTwo prototypeLive prototypeFixed targetBound
  obtain ⟨s79,hr79,h79,hctl79⟩ := map_length_transport NR FR R C₀ C live framed before after old old'
    s h notFramed literalTwo
  have hb79 : s79.next < 2^64 := by rw [h.target_next_eq h79 map_setup_next79]; omega
  have ht : runC P.F 9 s79 C = some (result,C) := by
    change runWith P.F interpC (5+9) s C = some (result,C) at hr
    have hp : runWith P.F interpC 5 s C = some (s79,C) := hr79
    rw [runWith_add,hp] at hr
    exact hr
  exact ⟨result,hr,hresult,(MapStorage.effects NR FR R C live framed before after old old'
    s79 result h79 (natV 2) hctl79 hb79 ht).1⟩

end Host.Load.Run.Full.Ordinary
