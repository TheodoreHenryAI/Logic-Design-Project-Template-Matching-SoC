# Design name
set ::env(DESIGN_NAME) SAD_calc

# RTL sources
set ::env(VERILOG_FILES) [glob $::env(DESIGN_DIR)/src/*.v]

# Clock
set ::env(CLOCK_PORT) "clk"
set ::env(CLOCK_PERIOD) 10.0   ;# 100 MHz

# Reset is active low (for tools that care)
set ::env(RST_PORT) "rst_n"
set ::env(RST_ACTIVE_HIGH) 0

# Core utilization and aspect ratio
set ::env(FP_CORE_UTIL) 45
set ::env(FP_ASPECT_RATIO) 1

# Placement
set ::env(PL_TARGET_DENSITY) 0.55

# Routing effort
set ::env(ROUTING_CORES) 2

# Disable useless checks for now
set ::env(RUN_CVC) 0

# Allow big designs (your RAM arrays are large)
set ::env(SYNTH_MAX_FANOUT) 10
set ::env(SYNTH_BUFFERING) 1
set ::env(SYNTH_STRATEGY) "AREA 0"

# Because you use large memories as reg arrays
set ::env(SYNTH_READ_BLACKBOX_LIB) 0
