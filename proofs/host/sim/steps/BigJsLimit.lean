import host.sim.steps.BigJsImage
namespace Host.Ts.Sim
open Host.Ts

/-- Uniform target-address limit ensuring every encoded offset fits signed 64-bit storage. -/
def jsSignedLimit : Nat := 2130706432

theorem jsSignedLimit_eq : jsSignedLimit = 2 ^ 31 - 2 ^ 24 := by decide

theorem ptrInt_js_signed_room {b off : Nat} (hb : b < jsSignedLimit) (hoff : off < 2 ^ 32) :
    jsBase + b * jsOff + off < 2 ^ 63 := by
  have hb' : b < 2130706432 := hb
  have ho' : off < 4294967296 := hoff
  simp only [jsBase, jsOff]
  omega

namespace BufSim
theorem toCellBig_js_limit {M : Map} (hJ : BigJs M) {b off limit : Nat}
    (hb : b < 2 ^ 29) (hoff : off < 2 ^ 32) (hlimit : limit ≤ jsSignedLimit)
    (himg : M.a b < limit) (k : EltK) :
    toCellBig k (M.big (ptrInt (.js b) off)) =
      (toCellBig k (ptrInt (.js b) off)).map M.cell :=
  toCellBig_js_image hJ hb hoff (ptrInt_js_signed_room (Nat.lt_of_lt_of_le himg hlimit) hoff) k
end BufSim

end Host.Ts.Sim
