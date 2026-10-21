---
name: hardware-interact
description: Build and flash VCM5 Dashboard or Tiller firmware and run hardware integration tests. Use when asked to build, flash, or test either controller, or inspect its Robot Framework logs.
---

# VCM5 Hardware

Treat `dashboard` or `tiller` in the user's prompt as the target selector, for example: `hardware-interact dashboard build` or `hardware-interact tiller run IntegrationTest/tiller/<test case>`. Skills do not define a validated argument schema; use this text convention. If the target is unclear for a hardware operation, ask which controller before acting.

Run the provided commands from `/home/nthorne/src/vcm5` in a shell where direnv has loaded the repository environment. Do not replace these helpers with guessed direct build, flash, or Robot Framework commands.

Unless explicitly requested, do not select any non-default build or flash options.

If explicitly told to find a suitable truck model yourself, you can look in the files `IntegrationTest/robot_(dashboard|tiller)*.arg`, respectively, and look for the test case that you are requested to run. If it is found on a uncommented line, just look upwards in the file until you find a line that looks like below, and you will have found the truck model to use(in this example, `FOOBAR`):
```
```
###################
## Truck FOOBAR ##
###################

## Dashboard

- Build firmware: `vcm5d-build`
- Flash firmware: `vcm5d-flash`
- Configuring (first time after flash): `conf-reset-dashboard` followed by `conf-<TRUCK MODEL>`
- Run one integration test: `robot-run-d IntegrationTest/dashboard/<test case>`
- Robot log: `/mnt/c/Dev/vcm5/IntegrationTest/output_dashboard/log.html`

## Tiller

- Build firmware: `vcm5t-build`
- Flash firmware: `vcm5t-flash`
- Configuring (first time after flash): `conf-reset-tiller` followed by `conf-<TRUCK MODEL>`
- Run one integration test: `robot-run-t IntegrationTest/tiller/<test case>`
- Robot log: `/mnt/c/Dev/vcm5/IntegrationTest/output_tiller/log.html`

## Workflow

1. Resolve the controller and requested operation from the prompt. Ask for the missing controller or test case when needed.
2. For builds and tests, use the matching command above. Integration tests interact with hardware; run them only when explicitly requested.
3. Flashing changes connected hardware. Flash only when explicitly requested, and confirm the target controller if it is not unambiguous.
4. When asked to check results, inspect the matching Robot log and summarize the relevant outcome and failures. Do not treat a log as belonging to the latest run unless its timestamps or contents support that.
