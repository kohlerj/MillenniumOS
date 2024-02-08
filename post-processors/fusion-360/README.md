# Fusion360 Post Processor for MillenniumOS

## Intro
The Fusion360 post-processor for MillenniumOS outputs a relatively basic gcode flavour that is designed to work with the RRF 3.5+ gcode format. It also targets some custom gcodes implemented by MillenniumOS, used for workpiece probing, reference surface probing and tool length probing.

## Usage
By default, the post-processor will wrap your operations with a number of commands that are designed to make life easier for novice machinists. In short, these make your programs feel slightly more like they're running on a 3D printer than a CNC mill.

By default, a program will follow roughly these steps:
  1. Pass tool details from Fusion360 to RepRapFirmware to ease tool changes
  2. Home machine in X, Y and Z using G28
  3. Configure movement options
  4. Probe reference surface using touch probe if using more than 1 tool
  5. Run operations
  6. Park the spindle (this also triggers a spindle stop)
  7. End program

For each of your operations, the following steps will be taken:
  1. If the new work offset is not the current work offset:
     1. Park the spindle (including stop)
     2. Prompt the operator to probe the work piece and save its' zero to the new work offset
  2. Switch into the new work offset
  3. If the new tool is not current tool, or probe was required:
     1. Set new tool
     2. Run tool change process (M6)
     3. Tool change process prompts operator to install right tool, and
     4. Runs G37 to probe the new tool's offset.
  5. Enable VSSC if requested
  6. Start spindle at requested RPM
  7. Wait for spindle to reach target RPM
  8. Move to operation starting position in Z
  9. Move to operation starting position in X and Y
  10. Run cutting moves
  11. Disable VSSC if it was enabled

## Probing
When the operator is prompted to probe the work piece, our default behaviour is to run `G6600` which is a "meta macro" that collects information from the operator before running the actual probing macros to find the work piece.

`G6600` allows the operator to select the type of probing operation they want, and then guides the user through filling out the relevant settings for the probing operation they chose.

The default sequential-probing functionality allows you to run operations on a single work piece in multiple planes, by treating each change in work offset as a change in plane.

`G54` (work offset 1) might indicate machining the top of the work piece, while `G55` (work offset 2) might indicate operations that work on the bottom of the work piece.

As the work offsets are probed just prior to being switched into, the work piece can be rotated manually during the guided probing operation.

If, however, you are working on multiple work pieces in a _single_ plane, then it might make sense to probe all of the work offsets before running any operations.

The `WCS Origin Probing Mode` setting allows you to configure this behaviour.

The default option is `On Change` and means that work offsets will be probed just prior to switching into the work offset.

To work on multiple work pieces in a single plane, you can select `At Start`, which will find all work offsets used within the program and prompt the operator to probe each of them before starting any operations.

The final setting is `None (Expert Mode)`, which will assume that all used work offsets are already configured.

In this mode, no work piece probing code will be generated automatically - but you can still use Fusion360's Inspection -> Probing functionality to create probing operations where and when you need them. Please note the Probing functionality requires a paid Fusion360 license.

You can set individual output settings to `No` to disable some of the default functionality (e.g. "Home Before Start" can be turned off, amongst others), or you can disable all the pre-configuration commands by setting "Output job setup commands" to `No`.

If disabling any or all of these settings, please read the output g-code before running it on your machine to confirm that you have configured the machine in the way that the g-code expects prior to running the program.
