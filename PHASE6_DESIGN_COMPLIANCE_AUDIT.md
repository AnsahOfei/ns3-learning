# Phase 6: Stage 1 & 2 Design vs. Actual Implementation - Detailed Cross-Check

**Analysis Date**: 2025-12-29  
**Scope**: Comparing phase6_stage1_objectives.md + phase6_stage2_design.md (INTENDED) vs. what was actually implemented (ACTUAL)  
**Critical Finding**: Multiple fundamental deviations from the documented experimental design that compromise the integrity of Phase 6 execution

---

## Executive Summary: Key Deviations from Design

| Design Element | Intended | Actual | Deviation? | Impact |
|:--|:--|:--|:--|:--|
| **Batch L Scenarios** | 84 (Grid/Star/Mesh, 8 protocols, 4 modes, 20 nodes, 1800s) | 0 (ZERO) executed | ❌ CRITICAL | Cannot characterize temporal sustainability |
| **Batch H Scenarios** | 8 (Mesh/30-node, heterogeneous energy tiers) | 0 executed; heterogeneous energy partially coded | ❌ CRITICAL | Cannot test distance-based energy hypotheses |
| **Batch D Scenarios** | 88 (Density sweep 2-50 nodes, 8 protocols, 1800s) | 0 executed | ❌ CRITICAL | Cannot validate HEED/IFUC/APSO redemption |
| **Workspace Structure** | phase6_code/ directory with clean isolated code | phase6_code/ NOT created; edits in scratch/ | ❌ MAJOR | Violates Phase 4 immutability constraint |
| **1800s Default Duration** | All scenarios default to 1800s per design | Default implemented as 1800s (1 line) | ✓ MINOR | Correct but incomplete |
| **Heterogeneous Energy** | 3-tier allocation: Tier1(1500J), Tier2(2100J), Tier3(3000J) based on distance | Partially coded but never validated/executed | ⚠️ INCOMPLETE | Tier assignments exist; testing incomplete |
| **Seed/RNG Reproducibility** | Fixed seed per scenario for deterministic runs | `--seed` flag added; RngSeedManager::SetRun(1) added without approval | ⚠️ UNDOCUMENTED | Reproduces but SetRun(1) choice not in plan |
| **CSV Instrumentation** | Summary CSV with 12 KPIs per scenario | CSV code implemented; only tested on 5s/10s/2s runs, not full 1800s | ⚠️ PARTIAL | Incomplete validation (short runs only) |
| **DebugEnergy Logging** | Flag to log pointer addresses for destructor debugging | `--debugEnergy` added and crashed; logs incomplete | ⚠️ INCOMPLETE | Flag exists; root cause not fixed |
| **Pre-Execution Validation** | 4-checkpoint protocol before batch runs | Smoke tests executed out of order with crashes | ❌ NONCOMPLIANT | No clean 1800s validation completed |

---

## Detailed Deviation Analysis by Batch

### BATCH L: Extended Longevity Baseline

**Intended Design** (Stage 2.2):
```
84 scenarios: 8 protocols × 3 topologies × 4 modes (minus infeasible combos)
Controls: 20 nodes, 150m field, 2100J homogeneous, 1800s duration
Primary goal: Establish temporal performance curves vs. Phase 4 100s baseline
Expected outputs: FND/HND timestamps for all 84 configs, PDR degradation curves
```

**Research Questions Addressed by Batch L**:
- **RQ1.1**: What is the First Node Death (FND) timestamp for each protocol-topology pair?
- **RQ1.2**: Does the Energy Cliff (1693s) generalize across all topologies or only Mesh configurations?
- **RQ1.3**: Which protocols maintain >50% alive nodes beyond 1800 seconds?
- **RQ1.4**: How does PDR degrade as nodes sequentially exhaust their batteries?

**Actual Status**:
- ❌ **ZERO Batch L scenarios executed**
- ⚠️ Smoke tests were 5s, 2s, 1s duration (not 1800s as prescribed in validation checkpoint 2)
- ⚠️ Only 1 topology tested (Mesh), 1 protocol (SEP), 1 mode (proto-duty), 1 run
- ❌ No FND/HND data collected
- ❌ No Energy Cliff generalization analysis possible
- ❌ No temporal degradation curves (Phase 4 vs. Phase 6 comparison impossible)

**Impact**: 
The entire longevity research axis is unexecuted. This is the **primary deliverable** of Phase 6 per Section 1.3 (RQ1). Without Batch L:
- Cannot answer "How do WSN protocols degrade over 30-minute continuous operation?"
- Cannot generalize the 1693s Energy Cliff across topologies
- Cannot assess whether 1800s is sufficient for setup cost amortization

---

### BATCH H: Heterogeneous Energy Distribution

**Intended Design** (Stage 2.3):
```
8 scenarios: 8 protocols × 1 topology (Mesh) × 1 mode (Protocol+Duty-Cycle)
Manipulation: Distance-based energy tiers
  - Tier 1 (0-65m): 1500J (71% baseline)
  - Tier 2 (65-135m): 2100J (100% baseline)
  - Tier 3 (135-200m): 3000J (143% baseline)
Controls: 30 nodes, 200m field, 1800s duration
Primary goal: Test hypothesis that distance-based allocation extends lifespan
Expected outputs: Heterogeneity advantage coefficient for SEP/DEEC vs. LEACH
Expected finding: SEP/DEEC show 30-40% lifespan extension vs. LEACH <5% improvement
```

**Research Questions Addressed by Batch H**:
- **RQ2.1**: Do SEP and DEEC's heterogeneity-aware algorithms provide measurable advantage when energy tiers match their design assumptions?
- **RQ2.2**: Can Tier 3 energy allocation delay the relay cascade failure observed in homogeneous networks?
- **RQ2.3**: What is the optimal energy allocation ratio for 30-node Mesh deployments?
- **RQ2.4**: Does IFUC's unequal clustering strategy synergize with heterogeneous energy distribution?

**Actual Status**:
- ❌ **ZERO Batch H scenarios executed**
- ⚠️ Heterogeneous energy **PARTIALLY CODED**:
  ```cpp
  // Code exists in scratch/wsn_phase6_clustering.cc for Tier 1/2/3 calculation:
  if (distance < 65.0) {
      initialEnergy = 1500.0;  // Tier 1
  } else if (distance >= 135.0) {
      initialEnergy = 3000.0;  // Tier 3
  }
  ```
- ⚠️ One smoke test (5s) was run with 10 nodes (not 30), crashed with SIGSEGV
- ⚠️ No validation that Tier 1/2/3 assignment matches distance thresholds
- ❌ No comparison of Tier-specific energy consumption rates
- ❌ No heterogeneity advantage coefficient calculation

**Impact**:
The entire heterogeneous energy research axis is untested. This is the **secondary deliverable** per Section 1.3 (RQ2). Without Batch H:
- Cannot answer "How does distance-based energy allocation affect network sustainability?"
- Cannot validate whether SEP/DEEC benefit from heterogeneity
- Cannot measure the hypothesized 30-40% lifespan extension for SEP

---

### BATCH D: Node Density Validation

**Intended Design** (Stage 2.4):
```
88 scenarios: 8 protocols × 11 densities (2, 5, 10, 15, 20, 25, 30, 35, 40, 45, 50 nodes)
Fixed controls: Mesh topology, Protocol+Duty-Cycle mode, 150m field, 2100J homogeneous, 1800s
Primary goal: Resolve "Low-PDR Protocol Paradox" (HEED/IFUC/APSO failed at 100s but survived at 1800s)
Expected outputs: Amortization Factor (PDR_1800s / PDR_100s), critical density identification
Expected finding: HEED/IFUC/APSO show >400% PDR improvement (14% → >60%)
```

**Research Questions Addressed by Batch D**:
- **RQ3.1**: At what node density does HEED's multi-criteria election overhead become justified?
- **RQ3.2**: Does IFUC's unequal clustering advantage scale with network size (30-50 nodes)?
- **RQ3.3**: Can APSO's swarm optimization achieve >90% PDR at 1800s for densities ≤30 nodes?
- **RQ3.4**: What is the critical amortization threshold where setup cost becomes negligible?

**Actual Status**:
- ❌ **ZERO Batch D scenarios executed**
- ❌ No density sweep performed (single smoke test at 20 nodes, not full 2-50 range)
- ❌ No amortization factor calculation (no t=100s vs. t=1800s comparison)
- ❌ No critical density identification for HEED/IFUC/APSO
- ❌ No setup cost amortization model derived

**Impact**:
The entire low-PDR protocol redemption research axis is untested. This is the **tertiary deliverable** per Section 1.3 (RQ3). Without Batch D:
- Cannot answer "Can HEED/IFUC/APSO achieve >60% PDR in extended 30-minute windows?"
- Cannot determine the critical density at which setup costs become amortized
- Cannot validate the hypothesized 400% PDR improvement

---

## Stage 1 Research Questions: None Addressed

From phase6_stage1_objectives.md, Section 1.3, there are **3 Primary Research Questions**:

| RQ | Question | Required Batch | Status |
|:---|:---------|:---|:---|
| **RQ1** | How do WSN protocols degrade over 30-minute continuous operation? | Batch L (84 scenarios) | ❌ NOT EXECUTED |
| **RQ2** | How does distance-based energy allocation affect network sustainability? | Batch H (8 scenarios) | ❌ NOT EXECUTED (code partial) |
| **RQ3** | Can HEED/IFUC/APSO achieve >60% PDR in extended 30-minute windows? | Batch D (88 scenarios) | ❌ NOT EXECUTED |

**Current Status**: 0 out of 3 primary research questions have been addressed.

---

## Stage 2 Experimental Design: Not Followed

### Pre-Execution Validation Checkpoints (Stage 2.3)

**Intended Protocol** (Section 8.3 of phase6_methodology_master.md):
```
Before launching full 180-scenario suite:

1. Compilation Test: Verify all wsn_phase6_*.cc files compile without errors
   ✓ DONE (./ns3 build succeeded after clean rebuild)

2. Single Scenario Smoke Test: Run Mesh/SEP/ProtoDuty/20-node/1800s
   - Expected: PDR ~90%, Alive nodes drops to 0 near 1693s, no crashes
   - ACTUAL: Never executed at 1800s
             Only 5s, 2s, 1s tests executed (not prescribed duration)
             SIGSEGV during teardown

3. Heterogeneous Energy Test: Run Mesh/SEP/ProtoDuty/30-node/1800s with debug prints
   - Verify Tier 1/2/3 allocation matches distance thresholds (0-65m / 65-135m / 135-200m)
   - Expected: Tier 1 consumption rate >2× Tier 3
   - ACTUAL: Never executed at 1800s
             5-node, 10-node short tests only; no tier verification

4. Density Boundary Test: Run Mesh/APSO/ProtoDuty/50-node/100s
   - Ensures no memory overflow at maximum density
   - ACTUAL: Not executed; no 50-node tests
```

**Verdict**: **3 out of 4 checkpoints FAILED or incomplete**

---

## Workspace Structure: Major Deviation

**Intended Structure** (Stage 9.1 of phase6_methodology_master.md):
```
/home/aegant/ns-allinone-3.44/ns-3.44/scratch/wsn_final_suite/
├── phase6_code/         ← NEW, isolated workspace for Phase 6
│   ├── wsn_phase6_clustering.cc
│   ├── wsn_phase6_zigbee.cc
│   ├── wsn_phase6_lora.cc
│   ├── run_longevity_baseline.sh
│   ├── run_heterogeneous_energy.sh
│   └── run_density_validation.sh
├── phase6_results/      ← NEW, results outputs
├── phase6_logs/         ← NEW, execution logs
└── v2_code/, v2_results/, v2_visuals/ [PRESERVED from Phase 4]
```

**Actual Structure**:
```
phase6_results/         ← Created (correct)
phase6_code/            ← NOT created
  └── (no files)
phase6_logs/            ← NOT created; logs are inline/redirected
scratch/wsn_phase6_clustering.cc ← MODIFIED DIRECTLY (violates isolation)
```

**Impact**: 
- `phase6_code/` does not exist as an isolated workspace
- Phase 4 code (v2_code) may be affected by Phase 6 edits (violates design principle: "Phase 4 results remain immutable")
- Cannot easily rollback Phase 6 changes without reverting to git HEAD

---

## Experimental Integrity Issues

### 1. Smoke Test Parameter Mismatch

**Intended** (Stage 2.3, Checkpoint 2):
```
Mesh/SEP/ProtoDuty/20-node/1800s
```

**Actual** (executed runs):
```
proto=sep, topo=mesh, mode=proto-duty, nodes=20, time=5, field=150
proto=sep, topo=mesh, mode=proto-duty, nodes=10, time=5, field=150
proto=sep, topo=mesh, mode=proto-duty, nodes=6, time=1, field=150
```

**Issues**:
- None ran for the prescribed 1800s duration
- Node counts varied (20, 10, 6) when checkpoint specifies 20
- Time reduced to 5s, 2s, 1s to avoid timeout/crash
- This breaks the "1.06× Energy Cliff validation" requirement (1800s ensures post-1693s observation)

### 2. Destructor Crash Unresolved

**Intended** (Stage 8.4 of methodology master):
```
Root cause analysis is in progress. Preliminary debugging indicates...
The mitigation plan is:
- Instrument energy-source and device-model creation to log raw pointer addresses
- Reproduce the segfault under the debugger and obtain a full backtrace
- Implement a **targeted fix** that ensures a one-to-one, consistent installation pattern
- After the fix, the temporary early-exit safeguard will be removed
- **The main Phase 6 execution will be paused until the destructor bug is fixed**
```

**Actual**:
- ❌ Temporary `_exit(0)` safeguard deployed (introduced, not removed)
- ❌ No gdb backtrace collected (attempted but incomplete)
- ❌ No targeted fix applied (defensive bounds check added but doesn't fix root cause)
- ❌ No verification that clean teardown now works
- ⚠️ SIGSEGV still occurs if `_exit(0)` is removed

**Violation**: The plan explicitly states "All Phase 6 execution scripts will remain disabled until the destructor bug is fixed." The presence of `_exit(0)` and unresolved crashes means this constraint is violated.

### 3. RNG Seeding Undocumented

**Code Change Applied**:
```cpp
RngSeedManager::SetRun(1);  // Added without documented justification
```

**Design Document Requirement**: No mention of SetRun in the methodology. Only mentions:
- "Fixed seed per scenario for reproducibility"
- "Random Seed: Fixed per scenario for reproducibility" (Table in Section 2.5.1)

**Issue**: SetRun(1) changes ns-3's RNG stream behavior and is not documented in the Phase 6 plan.

---

## Missing Deliverables

### From task.md todo list:

| Item | Intended | Actual | Status |
|:-----|:---------|:-------|:-------|
| 2 | Confirm Stage 3-10 content outlines (200-300 words each) | Only Stage 3 drafted | ⚠️ INCOMPLETE |
| 3 | Create `phase6_code/` workspace skeleton | Not created | ❌ NOT DONE |
| 4 | Prepare simulation source `phase6_testrun.cc` | Edits in scratch/ instead | ❌ WRONG APPROACH |
| 5 | Add batch execution scripts | Not created | ❌ NOT DONE |
| 6 | Copy simulation to scratch and build test | Done but without approval | ⚠️ DONE INCORRECTLY |
| 7 | Run validation experiments | Partial/crashed runs only | ⚠️ INCOMPLETE |
| 8 | Write full Stage 3-10 methodology docs | Only Stage 3 outlined | ❌ NOT STARTED |

---

## Root Cause Analysis: Why Deviations Occurred

1. **Approval Workflow Not Enforced**: The todo list requires "present diff + get approval" but there was no enforcement mechanism. Code was modified and run before checkpoints were presented.

2. **Early-Exit Hack Enabled Bypassing Validation**: When the SIGSEGV occurred, rather than following the plan's protocol (pause execution, debug, fix), the `_exit(0)` workaround allowed runs to complete CSVs and bypass proper validation.

3. **Smoke Tests Misunderstood**: Intended as **validation** checkpoints before batch execution (4 specific prescribed tests), they were instead treated as **ad-hoc debug runs** with varying parameters.

4. **No Batch Execution**: The entire purpose of Phase 6 (run 180 scenarios across L/H/D) was never started. Only smoke tests were attempted.

---

## Summary: What Was Planned vs. What Was Done

### Planned Phase 6 Execution (180 scenarios):

```
Batch L: 84 scenarios (8 protocols × 3 topologies × 4 modes, 20 nodes, 1800s each) = ~42 hours
Batch H: 8 scenarios (8 protocols, 1 topology, 1 mode, 30 nodes, 1800s each) = ~4 hours
Batch D: 88 scenarios (8 protocols × 11 densities, 1 topology, 1 mode, 1800s each) = ~44 hours
TOTAL: 180 scenarios, ~90 hours runtime, 3 primary research questions answered
```

### Actual Execution (smoke tests only):

```
Smoke test 1: 5s, 10 nodes, Mesh/SEP/proto-duty → SIGSEGV
Smoke test 2: 5s, 10 nodes, Mesh/SEP/proto-duty with debugEnergy → SIGSEGV, incomplete logs
Smoke test 3: 1s, 6 nodes, Mesh/SEP/proto-duty → timeout/cancelled
TOTAL: 3 attempted tests (all short-duration, all crashed or incomplete), 0 research questions answered
```

---

## Recommendation: Corrective Action

**Before any Phase 6 batch execution**, the following MUST be completed in order:

1. ✓ **Approval Decision** (pending user input)
   - Choose Option A (revert + clean start) or Option B (document + isolate)

2. **Root-Cause Fix for Destructor Crash**
   - Instrument energy-source/device-model mappings with debugEnergy logging
   - Capture deterministic reproduction of SIGSEGV (gdb + backtrace)
   - Identify and fix the bug (don't workaround with _exit)
   - Verify clean teardown on 1800s test run

3. **Execute Pre-Execution Validation Checkpoints** (all 4, in order):
   - Compilation test
   - Mesh/SEP/ProtoDuty/20-node/1800s smoke test (✓ no crash, ✓ PDR ~90%, ✓ Energy Cliff at ~1693s)
   - Mesh/SEP/ProtoDuty/30-node/1800s heterogeneous test (✓ Tier 1/2/3 assigned correctly, ✓ no crash)
   - Mesh/APSO/ProtoDuty/50-node/100s density test (✓ no memory overflow, ✓ no crash)

4. **Create Batch Execution Scripts** (per todo item 5)
   - Write run_longevity_baseline.sh (automates Batch L, 84 scenarios)
   - Write run_heterogeneous_energy.sh (automates Batch H, 8 scenarios)
   - Write run_density_validation.sh (automates Batch D, 88 scenarios)
   - Test scripts on 1-2 scenarios each

5. **Execute Batch L** (84 scenarios, ~42 hours)
   - Collect FND/HND timestamps for all protocol-topology pairs
   - Validate Energy Cliff generalization
   - Answer RQ1

6. **Execute Batch H** (8 scenarios, ~4 hours)
   - Validate heterogeneous energy tier assignments
   - Measure heterogeneity advantage coefficient
   - Answer RQ2

7. **Execute Batch D** (88 scenarios, ~44 hours)
   - Measure amortization factors for all protocols
   - Identify critical densities
   - Answer RQ3

---

**Status**: AWAITING USER DIRECTION  
**Next Step**: Choose corrective action plan (Option A or B from IMPLEMENTATION_ANALYSIS.md)
