import host.ts.RenameRuntimeNotes

set_option Elab.async false
namespace Host.Ts.Owned.Annotated
open Parametric

/-- Initial annotations may be selected once from the related entry state.
Subsequent dispatch rules retain and transform that same data. Critical entry
roles can be supplied separately through the selected cell inventory. -/
theorem ValueR.annotations {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren} {v₀ v : Val}
    (h : Parametric.ValueR (NumberRoles ν₀ ν C₀ C) R v₀ v) :
    ∃ role : Value, role.Holds ν₀ C₀ identity v₀ ∧ role.Holds ν C R v := by
  cases h with
  | undef => exact ⟨.undef,.undef,.undef⟩
  | null => exact ⟨.null,.null,.null⟩
  | bool b => exact ⟨.bool b,.bool b,.bool b⟩
  | str value => exact ⟨.str value,.str value,.str value⟩
  | num h => obtain ⟨e,h⟩ := h; exact ⟨.num e,.num _ _ h.left,.num _ _ h.right⟩
  | ordinaryBig i => exact ⟨.ordinaryBig i,.ordinaryBig i,.ordinaryBig i⟩
  | numericInteger h => obtain ⟨e,h⟩ := h; exact ⟨.numericInteger e,.numericInteger _ _ h.left,.numericInteger _ _ h.right⟩
  | handle handle => exact ⟨.handle handle,.handle handle,.handle handle⟩
  | pointerInteger mem off => cases mem <;> exact ⟨.pointerInteger _ off,.pointerInteger _ off,.pointerInteger _ off⟩
  | obj address => exact ⟨.obj address,.obj address,.obj address⟩
  | sym address => exact ⟨.sym address,by simpa only [identity_sym] using Value.Holds.sym (ν:=ν₀) (C:=C₀) (R:=identity) address,.sym address⟩
  | ptr mem off => cases mem <;> exact ⟨.ptr _ off,.ptr _ off,.ptr _ off⟩

theorem CellR.annotations {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren} {c₀ c : Host.Ts.Cell}
    (h : Parametric.CellR (NumberRoles ν₀ ν C₀ C) R c₀ c) :
    ∃ role : Cell, role.Holds ν₀ C₀ identity c₀ ∧ role.Holds ν C R c := by
  cases h with
  | num h => obtain ⟨e,h⟩ := h; exact ⟨.num e,.num _ _ h.left,.num _ _ h.right⟩
  | ordinaryBig i => exact ⟨.ordinaryBig i,.ordinaryBig i,.ordinaryBig i⟩
  | numericInteger h => obtain ⟨e,h⟩ := h; exact ⟨.numericInteger e,.numericInteger _ _ h.left,.numericInteger _ _ h.right⟩
  | handle handle => exact ⟨.handle handle,.handle handle,.handle handle⟩
  | pointerInteger mem off => cases mem <;> exact ⟨.pointerInteger _ off,.pointerInteger _ off,.pointerInteger _ off⟩

theorem ByteR.annotations {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren} {b₀ b : Host.Ts.Byte}
    (h : Parametric.ByteR (NumberRoles ν₀ ν C₀ C) R b₀ b) :
    ∃ role : Byte, role.Holds ν₀ C₀ identity b₀ ∧ role.Holds ν C R b := by
  cases h with
  | lit b => exact ⟨.lit b,.lit b,.lit b⟩
  | part k i h => obtain ⟨role,source,target⟩ := CellR.annotations h; exact ⟨.part k role i,.part k role i _ source,.part k role i _ target⟩

mutual
  theorem TreeR.annotations {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren} {t₀ t : Owned.Tree}
      (h : Parametric.TreeR (NumberRoles ν₀ ν C₀ C) R t₀ t) :
      ∃ role : Tree, role.Holds ν₀ C₀ identity t₀ ∧ role.Holds ν C R t := by
    cases h with
    | atom α x => exact ⟨.atom α x,.atom α x,.atom α x⟩
    | value h => obtain ⟨role,source,target⟩ := ValueR.annotations h; exact ⟨.value role,.value source,.value target⟩
    | cell h => obtain ⟨role,source,target⟩ := CellR.annotations h; exact ⟨.cell role,.cell source,.cell target⟩
    | byte h => obtain ⟨role,source,target⟩ := ByteR.annotations h; exact ⟨.byte role,.byte source,.byte target⟩
    | address a => exact ⟨.address a,.address a,.address a⟩
    | symbol a => exact ⟨.symbol a,by simpa only [identity_sym] using Tree.Holds.symbol (ν:=ν₀) (C:=C₀) (R:=identity) a,.symbol a⟩
    | region a => exact ⟨.region a,.region a,.region a⟩
    | number h => obtain ⟨e,h⟩ := h; exact ⟨.number e,.number e _ h.left,.number e _ h.right⟩
    | node tag h => obtain ⟨roles,source,target⟩ := ForestR.annotations h; exact ⟨.node tag roles,.node tag source,.node tag target⟩
  theorem ForestR.annotations {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren} {ts₀ ts : List Owned.Tree}
      (h : Parametric.ForestR (NumberRoles ν₀ ν C₀ C) R ts₀ ts) :
      ∃ roles : List Tree, ForestHolds ν₀ C₀ identity roles ts₀ ∧ ForestHolds ν C R roles ts := by
    cases h with
    | nil => exact ⟨[],.nil,.nil⟩
    | cons hh ht =>
      obtain ⟨role,source,target⟩ := TreeR.annotations hh
      obtain ⟨roles,sources,targets⟩ := ForestR.annotations ht
      exact ⟨role::roles,.cons source sources,.cons target targets⟩
end

theorem frameList_forest {NR : NumV → NumV → Prop} {R : Ren} {fs₀ fs : List Frame}
    (h : ListR (Parametric.FrameR NR R) fs₀ fs) :
    Parametric.ForestR NR R (fs₀.map Encode.frame) (fs.map Encode.frame) := by
  induction h with
  | nil => exact .nil
  | cons hh ht ih => exact .cons hh ih

theorem RuntimeInventory.of_state {F : Ffi} {FR : Ren → F.S → F.S → Prop}
    {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren} {live framed : Nat → Prop}
    {before after : List Val} {old old' : List Event} {s₀ s : St F.S} {cells : Notes}
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' s₀ s)
    (inventory : CellInventory cells ν₀ ν C₀ C R live s₀ s) :
    ∃ control stack, RuntimeInventory ⟨control,stack,cells⟩ ν₀ ν C₀ C R live s₀ s := by
  obtain ⟨control,sourceControl,targetControl⟩ := TreeR.annotations h.control
  obtain ⟨stack,sourceStack,targetStack⟩ := ForestR.annotations (frameList_forest h.stack)
  exact ⟨control,stack,inventory.keyLive,⟨sourceControl,sourceStack,inventory.source⟩,
    ⟨targetControl,targetStack,inventory.target⟩⟩

end Host.Ts.Owned.Annotated
