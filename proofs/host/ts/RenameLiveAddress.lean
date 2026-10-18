import host.ts.RenameParametricState

set_option Elab.async false
namespace Host.Ts.Owned

def valueHasAddress (a : Nat) : Val → Bool
  | .obj b => Nat.beq a b
  | .ptr (.js b) _ => Nat.beq a b
  | _ => false

mutual
  /-- A positive structural witness for a directly supported JS address. -/
  def treeHasAddress (a : Nat) : Tree → Bool
    | .value v => valueHasAddress a v
    | .address b => Nat.beq a b
    | .node _ fs => forestHasAddress a fs
    | _ => false
  def forestHasAddress (a : Nat) : List Tree → Bool
    | [] => false
    | f::fs => treeHasAddress a f || forestHasAddress a fs
end

theorem valueHasAddress_live (live : Nat → Prop) (a : Nat) (v : Val)
    (support : valueSupport live v) (found : valueHasAddress a v = true) : live a := by
  cases v <;> simp only [valueHasAddress] at found
  all_goals try contradiction
  case obj b => exact (Nat.eq_of_beq_eq_true found) ▸ support
  case ptr m off =>
    cases m with
    | js b => exact (Nat.eq_of_beq_eq_true found) ▸ support
    | ext r => cases found

mutual
  theorem treeHasAddress_live (live : Nat → Prop) (a : Nat) (t : Tree) :
      treeSupport live t → treeHasAddress a t = true → live a :=
    match t with
    | .value v => valueHasAddress_live live a v
    | .address b => fun support found => (Nat.eq_of_beq_eq_true found) ▸ support
    | .node _ fs => forestHasAddress_live live a fs
    | .atom _ _ => fun _ found => by cases found
    | .cell _ => fun _ found => by cases found
    | .byte _ => fun _ found => by cases found
    | .symbol _ => fun _ found => by cases found
    | .region _ => fun _ found => by cases found
    | .number _ => fun _ found => by cases found
  theorem forestHasAddress_live (live : Nat → Prop) (a : Nat) (fs : List Tree) :
      forestSupport live fs → forestHasAddress a fs = true → live a :=
    match fs with
    | [] => fun _ found => by cases found
    | f::fs => fun support found => by
      cases head : treeHasAddress a f with
      | true => exact treeHasAddress_live live a f support.1 head
      | false =>
        have tail : forestHasAddress a fs = true := by
          simpa only [forestHasAddress,head,Bool.false_or] using found
        exact forestHasAddress_live live a fs support.2 tail
end

end Host.Ts.Owned
namespace Host.Ts.Owned.Parametric

theorem StateR.stack_address_live {S : Type} {NR : NumV → NumV → Prop}
    {FR : Ren → S → S → Prop} {R : Ren} {live framed : Nat → Prop}
    {before after : List Val} {old old' : List Event} {s₀ s : St S}
    (h : StateR NR FR R live framed before after old old' s₀ s) (a : Nat)
    (found : forestHasAddress a (s₀.stack.map Encode.frame) = true) : live a := by
  have support : ∀ fs, listSupport (fun f => treeSupport live (Encode.frame f)) fs →
      forestSupport live (fs.map Encode.frame) := by
    intro fs
    induction fs with
    | nil => exact fun _ => True.intro
    | cons f fs ih => exact fun hs => ⟨hs.1,ih hs.2⟩
  exact forestHasAddress_live live a _ (support _ h.stackLive) found

end Host.Ts.Owned.Parametric
