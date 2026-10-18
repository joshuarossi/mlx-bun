import host.ts.renameOrdinary.RankOriginRemaining
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
namespace Host.Load.Run.Full.Ordinary.RankOrigin
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric

theorem initial_stack : input.stack = .c (.args Collect2.sourceKind Collect2.sourceFunction Collect2.sourceThis
    Collect2.sourceAcc Collect2.sourceRest Collect2.sourceEnv)::Collect2.sourceTail := by host_kernel_rfl
theorem initial_declaration_tail : input.stack.drop 5 = .s (.decl Declare8.sourceKind Declare8.sourcePattern
    Declare8.sourceRest Declare8.sourceEnv)::Declare8.sourceTail := by host_kernel_rfl
theorem initial_rank_lookup : lookupEnv Initialize9.sourceName Declare8.sourceEnv = some Variable5.address := by host_kernel_rfl
theorem initial_receiver_lookup : lookupEnv nThis Declare8.sourceEnv = some This26.sourceAddress := by host_kernel_rfl
theorem initial_receiver_cell : input.heap.get This26.sourceAddress = some (.cell (some (.obj Handle40.sourceAddress))) := by host_kernel_rfl
theorem receiver_not_rank : Handle40.sourceAddress ≠ Variable5.address := by decide +kernel

theorem initial_environment_live (NR : NumV → NumV → Prop) (FR : Ren → LSt → LSt → Prop)
    (R : Ren) (live framed : Nat → Prop) (before after : List Val) (old old' : List Event)
    (s : St LSt) (h : StateR NR FR R live framed before after old old' input s) :
    treeSupport live (Encode.env Declare8.sourceEnv) := by
  have hl := h.stackLive
  change listSupport (fun f => treeSupport live (Encode.frame f)) input.stack at hl
  have hdrop : ∀ (n : Nat) (fs : List Frame), listSupport (fun f => treeSupport live (Encode.frame f)) fs →
      listSupport (fun f => treeSupport live (Encode.frame f)) (fs.drop n) := by
    intro n fs hs
    induction n generalizing fs with
    | zero => exact hs
    | succ n ih =>
      cases fs with
      | nil => exact True.intro
      | cons f fs => exact ih fs hs.2
  have ht := hdrop 5 input.stack hl
  rw [initial_declaration_tail] at ht
  exact ht.1.1.2.2.2.1

theorem initial_owned_addresses (NR : NumV → NumV → Prop) (FR : Ren → LSt → LSt → Prop)
    (R : Ren) (live framed : Nat → Prop) (before after : List Val) (old old' : List Event)
    (s : St LSt) (h : StateR NR FR R live framed before after old old' input s) :
    live Variable5.address ∧ live Handle40.sourceAddress := by
  have he := initial_environment_live NR FR R live framed before after old old' s h
  have rank := env_lookup_live Initialize9.sourceName Declare8.sourceEnv Variable5.address he initial_rank_lookup
  have thisCell := env_lookup_live nThis Declare8.sourceEnv This26.sourceAddress he initial_receiver_lookup
  obtain ⟨_,_,_,support⟩ := h.heap.readCell This26.sourceAddress (.obj Handle40.sourceAddress) thisCell initial_receiver_cell
  exact ⟨rank,support⟩

theorem initial_pointer_lookup : lookupEnv PointerBinding48.sourceName Declare8.sourceEnv = some PointerBinding48.sourceAddress := by host_kernel_rfl

theorem initial_pointer_live (NR : NumV → NumV → Prop) (FR : Ren → LSt → LSt → Prop)
    (R : Ren) (live framed : Nat → Prop) (before after : List Val) (old old' : List Event)
    (s : St LSt) (h : StateR NR FR R live framed before after old old' input s) : live PointerBinding48.sourceAddress :=
  env_lookup_live PointerBinding48.sourceName Declare8.sourceEnv PointerBinding48.sourceAddress
    (initial_environment_live NR FR R live framed before after old old' s h) initial_pointer_lookup

theorem initial_global_object : input.heap.get aGlobal = some (.obj TypedGlobal54.sourceObject) := by host_kernel_rfl
theorem initial_typed_constructor : TypedGlobal54.sourceValue = .obj 90 := by host_kernel_rfl

theorem initial_constructor_live (NR : NumV → NumV → Prop) (FR : Ren → LSt → LSt → Prop)
    (R : Ren) (live framed : Nat → Prop) (before after : List Val) (old old' : List Event)
    (s : St LSt) (h : StateR NR FR R live framed before after old old' input s)
    (globalLive : live aGlobal) : live 90 := by
  obtain ⟨_,_,_,support⟩ := h.heap.readOrdinary aGlobal TypedGlobal54.sourceObject globalLive initial_global_object TypedGlobal54.source_kind
  have hv := (PropsR.support_find support.2.2.1 TypedGlobal54.sourceName TypedGlobal54.source_property).1
  rw [initial_typed_constructor] at hv
  exact hv
end Host.Load.Run.Full.Ordinary.RankOrigin
