import host.sim.native.Rel
namespace Host.Ts.Sim
open Host.Mlx.Ffi (Dim Prim Node Cfg Clo Trace Pending dimOf)

/-! # Native memory reads commute with the map (`FfiSim.read`)

Host regions are fixed and hold literal bytes; an array's shape region `4h`
reads the imaged shape (symbolic dimensions read back the image number,
`DimCanon`); a string region `4h + 1` holds literal bytes. -/

theorem cellBytes_map (M : Map) (k : EltK) : ∀ cs : List Cell,
    (cellBytes k cs).map M.byte = cellBytes k (cs.map M.cell)
  | [] => rfl
  | c :: cs => by simp only [cellBytes, List.map_append, Map.cellParts, cellBytes_map M k cs, List.map_cons]

theorem shapeBytes_map (M : Map) (s : List Dim) (hc : ∀ d ∈ s, DimCanon M d) :
    (Host.Mlx.Ffi.shapeBytes s).map M.byte = Host.Mlx.Ffi.shapeBytes (M.dims s) := by
  unfold Host.Mlx.Ffi.shapeBytes
  rw [cellBytes_map, List.map_map, Map.dims, List.map_map]
  congr 1
  exact List.map_congr_left fun d hd => by
    show Cell.num (M.nv d.num) = Cell.num (M.dim d).num
    rw [hc d hd]

theorem map_byte_lits (M : Map) : ∀ (l : List Byte), (∀ b ∈ l, ∃ v, b = .lit v) → l.map M.byte = l
  | [], _ => rfl
  | b :: l, h => by
    obtain ⟨v, rfl⟩ := h b (List.mem_cons_self ..)
    rw [List.map_cons, map_byte_lits M l (fun c hc => h c (List.mem_cons_of_mem _ hc))]
    rfl

private theorem lits_of_map (l : List Nat) : ∀ b ∈ l.map Byte.lit, ∃ v, b = .lit v := by
  intro b hb
  obtain ⟨v, _, rfl⟩ := List.mem_map.mp hb
  exact ⟨v, rfl⟩

private theorem lits_drop_take {l : List Byte} (h : ∀ b ∈ l, ∃ v, b = .lit v) (off k : Nat) :
    ∀ b ∈ (l.drop off).take k, ∃ v, b = .lit v :=
  fun b hb => h b (List.mem_of_mem_drop (List.mem_of_mem_take hb))

theorem loadR_read {P : LoadP} {M : Map} {n : Nat} {x y : Host.Load.LSt} {r off k : Nat} {bs : List Byte}
    (hr : LoadR P M n x y) (hx : Host.Load.read x r off k = some bs) :
    Host.Load.read y (M.region r) off k = some (bs.map M.byte) := by
  have mr := hr.mlx
  unfold Host.Load.read at hx ⊢
  cases h3 : Nat.beq (r % 4) 3
  · rw [h3] at hx
    simp only [cond_false] at hx
    have hne : r % 4 ≠ 3 := fun h => by rw [h] at h3; cases h3
    unfold Host.Mlx.Ffi.read at hx
    have hr4 : r % 4 < 4 := Nat.mod_lt _ (by decide)
    rcases (show r % 4 = 0 ∨ r % 4 = 1 ∨ r % 4 = 2 by omega) with h0 | h1 | h2
    · simp only [h0] at hx
      cases hn : x.mlx.node? (r / 4) with
      | none => rw [hn] at hx; cases hx
      | some nd =>
        rw [hn] at hx
        simp only [Option.map_some, Option.some.injEq] at hx
        subst hx
        unfold Host.Mlx.Ffi.St.node? at hn
        cases ha : x.mlx.arrs.get (r / 4) with
        | none => rw [ha] at hn; cases hn
        | some kk =>
          rw [ha] at hn
          simp only [Option.bind_some] at hn
          have hp : PH x.mlx (r / 4) := .inl (by rw [ha]; rfl)
          obtain ⟨nd', hnd', hs, -, hc, -⟩ := mr.nodes kk nd hn
          have hreg : M.region r = 4 * M.handle (r / 4) := by
            have := (mr.present _ hp).2.1
            rwa [show 4 * (r / 4) = r by omega] at this
          rw [hreg]
          have e1 : Nat.beq (4 * M.handle (r / 4) % 4) 3 = false := by
            rw [Nat.mul_mod_right]; rfl
          rw [e1]
          simp only [cond_false]
          unfold Host.Mlx.Ffi.read
          rw [Nat.mul_mod_right]
          simp only [Nat.mul_div_cancel_left _ (by decide : 0 < 4)]
          have hy : y.mlx.node? (M.handle (r / 4)) = some nd' := by
            unfold Host.Mlx.Ffi.St.node?
            rw [mr.arrs _ hp, ha]
            exact hnd'
          rw [hy, Option.map_some, hs, ← shapeBytes_map M nd.shape hc, List.map_take, List.map_drop]
    · simp only [h1] at hx
      cases ho : x.mlx.obj? (r / 4) with
      | none => rw [ho] at hx; cases hx
      | some o =>
        rw [ho] at hx
        cases o with
        | str cs =>
          simp only [Option.some.injEq] at hx
          subst hx
          have hp : PH x.mlx (r / 4) := .inr (by unfold Host.Mlx.Ffi.St.obj? at ho; rw [ho]; rfl)
          have hreg : M.region r = 4 * M.handle (r / 4) + 1 := by
            have := (mr.present _ hp).2.2
            rwa [show 4 * (r / 4) + 1 = r by omega] at this
          rw [hreg]
          have e1 : (4 * M.handle (r / 4) + 1) % 4 = 1 := by omega
          have e2 : (4 * M.handle (r / 4) + 1) / 4 = M.handle (r / 4) := by omega
          rw [show Nat.beq ((4 * M.handle (r / 4) + 1) % 4) 3 = false by rw [e1]; rfl]
          simp only [cond_false]
          unfold Host.Mlx.Ffi.read
          rw [e1, e2]
          have hy : y.mlx.obj? (M.handle (r / 4)) = some (.str cs) := by
            unfold Host.Mlx.Ffi.St.obj? at ho ⊢
            rw [mr.objs _ hp, ho]
            rfl
          simp only [hy]
          congr 1
          refine (map_byte_lits M _ (lits_drop_take ?_ off k)).symm
          intro b hb
          rcases List.mem_append.mp hb with hb | hb
          · obtain ⟨c, _, rfl⟩ := List.mem_map.mp hb
            exact ⟨_, rfl⟩
          · simp only [List.mem_singleton] at hb
            exact ⟨0, hb⟩
        | _ => cases hx
    · simp only [h2] at hx
      cases hx
  · rw [h3] at hx
    simp only [cond_true] at hx
    have h3' : r % 4 = 3 := Nat.eq_of_beq_eq_true h3
    cases ho : x.host.objs.get (r / 4) with
    | none => rw [ho] at hx; cases hx
    | some o =>
      have hreg : M.region r = r := by
        have := hr.hostReg (r / 4) (hr.hostLt (r / 4) (by rw [ho]; rfl))
        rwa [show 4 * (r / 4) + 3 = r by omega] at this
      rw [hreg, h3, hr.host]
      simp only [cond_true, ho]
      rw [ho] at hx
      cases o with
      | mapping p =>
        simp only at hx ⊢
        cases hf : Host.Load.fileOf x.host p with
        | none => rw [hf] at hx; cases hx
        | some fc =>
          rw [hf] at hx
          cases fc with
          | text _ => cases hx
          | blob sz pre =>
            simp only at hx ⊢
            cases hb : Nat.ble (off + k) (len pre)
            · rw [hb] at hx; cases hx
            · rw [hb] at hx
              simp only [cond_true, Option.some.injEq] at hx ⊢
              subst hx
              exact (map_byte_lits M _ (lits_of_map _)).symm
      | cstr cs =>
        simp only [Option.some.injEq] at hx ⊢
        subst hx
        refine (map_byte_lits M _ (lits_drop_take ?_ off k)).symm
        intro b hb
        rcases List.mem_append.mp hb with hb | hb
        · exact lits_of_map _ b hb
        · simp only [List.mem_singleton] at hb
          exact ⟨0, hb⟩
      | _ => cases hx

end Host.Ts.Sim
