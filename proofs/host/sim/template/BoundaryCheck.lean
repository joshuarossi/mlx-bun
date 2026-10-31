import host.sim.conv.Compact
namespace Host.Ts.Sim.Template

theorem boundary_map_parts {α β : Type} {xs : List α} {ys : List β} {f : α → β}
    (n : Nat) (h₁ : (xs.take n).map f = ys.take n)
    (h₂ : (xs.drop n).map f = ys.drop n) : xs.map f = ys := by
  calc
    xs.map f = (xs.take n ++ xs.drop n).map f := by rw [List.take_append_drop]
    _ = (xs.take n).map f ++ (xs.drop n).map f := List.map_append
    _ = ys.take n ++ ys.drop n := by rw [h₁, h₂]
    _ = ys := List.take_append_drop n ys

theorem boundary_map_drop {α β : Type} {xs : List α} {ys : List β} {f : α → β}
    (n k : Nat) (h₁ : ((xs.drop k).take n).map f = (ys.drop k).take n)
    (h₂ : (xs.drop (k + n)).map f = ys.drop (k + n)) :
    (xs.drop k).map f = ys.drop k :=
  boundary_map_parts n h₁ (by simpa only [List.drop_drop, Nat.add_comm] using h₂)

theorem boundary_map_nil {α β : Type} {xs : List α} {ys : List β} {f : α → β}
    (hx : xs = []) (hy : ys = []) : xs.map f = ys := by rw [hx, hy]; rfl

end Host.Ts.Sim.Template
