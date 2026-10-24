import host.load.boot.ane.BridgeCmd
set_option Elab.async false
set_option interpreter.prefer_native true
set_option maxRecDepth 1000000
namespace Host.Load.Run.Prompt

/-! The bridge after the oldest 548, 1096, 1644 and all 2192 creates (`aneB1` … `aneB4`), chosen by a native run
of the boot. -/

boot_ane_bridge [548, 1096, 1644, 2192]

end Host.Load.Run.Prompt
