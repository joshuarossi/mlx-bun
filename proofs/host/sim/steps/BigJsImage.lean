import host.sim.steps.BigJs
namespace Host.Ts.Sim.BufSim
open Host.Ts Host.Ts.Sim

/-- Conversion only requires the target pointer integer to fit a signed 64-bit cell.
The source still lies in the existing JavaScript pointer band. -/
theorem toCellBig_js_image {M : Map} (hJ : BigJs M) {b off : Nat}
    (hb : b < 2 ^ 29) (hoff : off < 2 ^ 32)
    (himg : jsBase + M.a b * jsOff + off < 2 ^ 63) (k : EltK) :
    toCellBig k (M.big (ptrInt (.js b) off)) =
      (toCellBig k (ptrInt (.js b) off)).map M.cell := by
  rw [hJ b off hb hoff, ptrInt_js, ptrInt_js]
  have hb' : b < 536870912 := hb
  have ho' : off < 4294967296 := hoff
  have h1 : jsBase + b * jsOff + off < 9223372036854775808 := by
    simp only [jsBase, jsOff]
    omega
  have h2 : jsBase + M.a b * jsOff + off < 9223372036854775808 := himg
  have hJ' := hJ b off hb hoff
  rw [ptrInt_js, ptrInt_js] at hJ'
  cases k <;> simp only [toCellBig, Option.map_some, Option.map_none, Map.cell]
  · rw [signed_small (Int.natCast_nonneg _) (by show _ < (9223372036854775808 : Int); omega),
      signed_small (Int.natCast_nonneg _) (by show _ < (9223372036854775808 : Int); omega), hJ']
  · rw [modInt_js h2, modInt_js h1, hJ']

/-- A target address below `2^30` gives sufficient room for either 64-bit element kind. -/
theorem toCellBig_js30 {M : Map} (hJ : BigJs M) {b off : Nat}
    (hb : b < 2 ^ 29) (hoff : off < 2 ^ 32) (himg : M.a b < 2 ^ 30) (k : EltK) :
    toCellBig k (M.big (ptrInt (.js b) off)) =
      (toCellBig k (ptrInt (.js b) off)).map M.cell := by
  apply toCellBig_js_image hJ hb hoff _ k
  have hi : M.a b < 1073741824 := himg
  have ho : off < 4294967296 := hoff
  simp only [jsBase, jsOff]
  omega

end Host.Ts.Sim.BufSim
