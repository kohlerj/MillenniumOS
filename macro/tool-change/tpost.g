; tpost.g: POST TOOL CHANGE - EXECUTE
;
; Called after the tool change, can be used
; to probe tool length or reference surface
; position if touch probe is installed.

var tI = { state.currentTool }
if { var.tI < 0 }
    M99

if { !move.axes[0].homed || !move.axes[1].homed || !move.axes[2].homed }
    M99

; Stop and park the spindle
G27 Z1

; If touch probe is current tool, and enabled, and we have not calculated
; the toolsetter activation position yet, then run G6511 to probe the
; reference surface so we can make this calculation.
; Touchprobe tool ID is only set if the touchprobe feature is enabled.
if { var.tI == global.mosProbeToolID }
    if { global.mosFeatureTouchProbe }
        M291 P{"<b>Touch Probe Detected</b>.<br/>We will now probe the reference surface. Move away from the machine <b>BEFORE</b> pressing <b>OK</b>!"} R"MillenniumOS: Tool Change" S2
        G6511
        if { global.mosToolSetterActivationPos == null }
            echo { "Touch probe reference surface probing failed." }
            M99
    else
        if { !global.mosExpertMode }
            M291 P{"<b>Datum Tool Installed</b>.<br/>We will now probe the tool length. Move away from the machine <b>BEFORE</b> pressing <b>OK</b>!"} R"MillenniumOS: Tool Change" S2

        ; Probe datum tool length
        G37
else
    ; Probe non-probe tool length
    G37

; Continue after operator confirmation if necessary
if { !global.mosExpertMode }
    if { job.file.fileName != null }
        M291 P{"Tool change complete. Press Continue to start the next operation, or Pause to perform further manual tasks (e.g. workpiece fixture changes)"} R"MillenniumOS: Tool Change" S4 K{"Continue", "Pause"}
        if { input != 0 }
            M25.9 S{"Operator paused job after tool change complete." }
    else
        M291 P{"Tool change complete. Press <b>OK</b> to continue!"} R"MillenniumOS: Tool Change" S2 T0