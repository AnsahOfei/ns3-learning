# Phase 6 Implementation Plan: Complete 12-Stage Index & Acceptance Criteria

**Document Type**: Master Implementation Plan  
**Scope**: All stages of Phase 6 (Research through Dissertation Integration)  
**Status**: PRE-EXECUTION (Stages 1-10 pre-registered; 11-12 pending post-execution)  
**Last Updated**: 2025-12-29

---

## Stages Overview & Acceptance Criteria

### **Stage 1: Research Objectives & Motivation** ✓ COMPLETE
**Location**: `../reports/phase6_stage1_objectives.md`  
**Word Count**: ~2,150 words  
**Status**: Complete - Available for reference  
**Content**:
- Phase 4 achievements & identified gaps (3 critical gaps)
- Core research questions (RQ1, RQ2, RQ3) with sub-questions
- Expected theoretical, practical, and methodological contributions
- Stakeholder impact analysis (Precision Ag, Environmental Monitoring, Smart Cities)
- Experimental philosophy & design constraints
- Success metrics for Phase 6 (quantitative & qualitative)
- Integration with broader WSN research landscape

**Acceptance Criteria**:
- ✓ Clear articulation of 3 primary RQs
- ✓ Justification for each RQ with Phase 4 baseline
- ✓ Explicit success targets (e.g., "Batch L: ±30s precision for FND")
- ✓ Stakeholder alignment with real-world deployment scenarios

**Next Stage**: Stage 2

---

### **Stage 2: Experimental Design Framework** ✓ COMPLETE
**Location**: `../reports/phase6_stage2_design.md`  
**Word Count**: ~2,400 words  
**Status**: Complete - Available for reference  
**Content**:
- Three-batch factorial design philosophy (L, H, D)
- **Batch L**: 72 scenarios (6 protocols × 3 topologies × 4 modes), 20 nodes, 1800s
- **Batch H**: 6 scenarios (6 protocols, Mesh, Protocol+Duty-Cycle), 30 nodes, heterogeneous energy
- **Batch D**: 66 scenarios (6 protocols × 11 densities), Mesh, Protocol+Duty-Cycle
- Cross-batch control invariants (ns-3.44, SADC, hard cut-off, propagation model)
- NetAnim exclusion rationale
- Execution sequencing (L → H → D) & checkpoint strategy
- Counterfactual analysis framework
- Experimental threats & mitigation (internal, external, construct validity)
- Power analysis & sample size justification
- Ethical & resource considerations

**Acceptance Criteria**:
- ✓ Clear factorial structure for each batch (factors, levels, N scenarios)
- ✓ Justified control variable selections
- ✓ Cross-batch comparability constraints
- ✓ Threat identification & mitigation strategies
- ✓ Temporal sequencing that enables RQ answering

**Next Stage**: Stage 3

---

### **Stage 3: Network Topology & Spatial Configuration** ⏳ OUTLINED
**Target Location**: `../reports/phase6_stage3_topology.md` (to be created)  
**Target Word Count**: 2,000-2,500 words  
**Status**: Outline provided; full write pending approval  

**Outline** (200 words - provided for review):
> Stage 3 establishes the spatial and radio environment used across Phase‑6 experiments and defines the propagation, mobility, and deployment patterns that determine connectivity and energy cost. Topology: three canonical deployments (grid, mesh, star) are defined to exercise centralized‑to‑distributed path diversity and clustering behavior; grid is used for uniform density baseline, mesh for irregular connectivity and multi‑hop load, star for sink‑adjacent concentration. Node counts will scale (10, 20, 50, 100) to measure both per‑node and network‑level scaling. Mobility: nodes are stationary for baseline experiments; a small set of trials will use low‑speed random waypoint to validate cluster stability. Propagation: SingleModelSpectrumChannel with LogDistancePropagationLossModel (path‑loss exponent tunable 2.7–3.5) and ConstantSpeedPropagationDelayModel to capture realistic RSSI variability; packet error will be estimated using empirical BER mapping from SNR to packet loss calibrated on LR‑WPAN PHY parameters. Interference/noise: optional background interferer nodes can be enabled for robustness tests. Energy and placement: sink position is configurable (center or corner) and used to compute distance‑based heterogeneous initial energy tiers (Tier1: sink‑adjacent low energy, Tier2: nominal, Tier3: periphery high energy) for Batch H. Field sizing and node density are chosen so average neighbor degree covers 3–6 links; sensitivity sweeps (density and path‑loss) will appear in Stage‑level experimental plan. Verification & outputs: sanity checks include connectivity matrices, node degree histograms, RSSI distributions, and per‑node distance-to-sink statistics; these are output as CSVs and small plots for validation before proceeding to protocol experiments.

**Expected Content**:
- Field geometry specifications (150m × 150m standard, 200m × 200m expanded for Batch H)
- Grid/Star/Mesh topology definitions & use cases
- Distance calculation methodology for energy tier assignment
- Collision domain analysis (CSMA/CA parameters)
- Mobility model specifications (static + optional RWP)
- Propagation model details (LogDistance γ=3.0, delay model)
- Sink placement strategies (center vs. corner)
- Sanity checks & verification outputs (connectivity matrices, RSSI histograms)
- Python/plotting utilities for topology visualization

**Acceptance Criteria**:
- [ ] Detailed field geometry justification (why 150m, 200m)
- [ ] Precise definition of Grid/Star/Mesh in ns-3 code terms
- [ ] Distance-to-energy-tier mapping algorithm (pseudocode or C++)
- [ ] Connectivity validation method (how to verify 3-6 average neighbor degree)
- [ ] Per-topology RSSI/delay expectations based on propagation model

**Next Stage**: Stage 4 (blocks all Batches on completion)

---

### **Stage 4: Energy Modeling & Battery Physics** ⏳ OUTLINED
**Target Location**: `../reports/phase6_stage4_energy.md` (to be created)  
**Target Word Count**: 2,500-3,000 words  
**Status**: Outline to be drafted; includes code from phase6_methodology_master.md Section 4

**Expected Content** (from methodology master):
- BasicEnergySource model & chemical basis (Lithium-ion equivalent)
- Energy allocations per batch (Batch L: 2100J homogeneous; Batch H: 1500J/2100J/3000J tiers)
- State-based current draw model (TX/RX/Idle/Sleep currents & durations)
- Hard cut-off logic (0.0J floor) & RemainingEnergyTrace callback
- Energy Cliff forensics (1693s phenomenon, FND/HND definitions)
- Energy Cliff hypothesis for Phase 6 (varies by topology/protocol/mode)
- Per-node energy accounting & validation checks
- Heterogeneous energy tier justification (inverted energy-to-relay-load relationship)
- Energy efficiency metrics (J/bit)

**Acceptance Criteria**:
- [ ] Clear current draw table (mA per radio state)
- [ ] Explanation of why Tier 3 (periphery) gets highest energy
- [ ] Validation that Tier 1/2/3 assignment is deterministic & reproducible
- [ ] Code walkthrough: RemainingEnergyTrace callback
- [ ] Expected energy consumption curves for LEACH/SEP/DEEC (reference to Phase 4)

**Dependency**: Blocks Batch H execution; Stage 3 should be complete first

**Next Stage**: Stage 5

---

### **Stage 5: Protocol Selection & Implementation** ⏳ OUTLINED
**Target Location**: `../reports/phase6_stage5_protocols.md` (to be created)  
**Target Word Count**: 2,500-3,000 words  
**Status**: Outline to be drafted; includes code from phase6_methodology_master.md Section 5

**Expected Content**:
- LEACH algorithm & Phase 4 performance (92.2% PDR at 100s)
- HEED algorithm & Phase 4 failure (14.2% PDR, expected to improve >60% at 1800s)
- SEP algorithm & heterogeneity advantage (94.8% PDR, +18% FND)
- DEEC algorithm & scalability (93.1% PDR, 92.3% at 50 nodes)
- IFUC algorithm & unequal clustering (14.8% PDR at 100s, expected redemption at 1800s)
- APSO algorithm & swarm optimization (14.1% PDR at 100s, 97.4% at 50 nodes)
- Zigbee (IEEE 802.15.4 mesh) & industry baseline (95.0% at 20 nodes, collapses at 50 nodes)
- LoRa-like LPWAN & long-range tradeoff (100% Star PDR, 2× energy cost)
- State-Aware Duty Cycling (SADC) integration (Phase 4 verified)
- Protocol-mode infeasibility logic (e.g., Zigbee Standard mode requires protocol layer)

**Acceptance Criteria**:
- [ ] Phase 4 baseline PDR for each protocol-topology pair (for comparison)
- [ ] Election algorithm pseudocode for at least 3 protocols
- [ ] Justification for HEED/IFUC/APSO expected >60% PDR improvement at 1800s
- [ ] SADC integration strategy (desynchronization, state tracking, guarded transitions)
- [ ] Code walkthrough: LEACHApp, SEPApp, DEECApp classes

**Dependency**: Stage 3 should be complete; needed for all Batch L/H/D protocols

**Next Stage**: Stage 6

---

### **Stage 6: Metrics & Instrumentation** ⏳ OUTLINED
**Target Location**: `../reports/phase6_stage6_metrics.md` (to be created)  
**Target Word Count**: 2,000-2,500 words  
**Status**: Outline to be drafted; includes code from phase6_methodology_master.md Section 6

**Expected Content**:
- 12-metric KPI suite:
  - Reliability: PDR, Latency, Jitter, BER, Throughput, Bandwidth
  - Sustainability: Total Starting Energy, Total Remaining Energy, Total Consumed Energy, Alive Nodes, Energy Efficiency, Response Time
- FlowMonitor integration & layer-specific tracking
- RemainingEnergy trace callback & sampling interval (100ms)
- Jitter calculation methodology
- Per-node energy accounting (initial, remaining, consumed per node)
- CSV output format & field definitions
- Real-time console output (live countdown every 60s)
- Energy Cliff forensics log format (Time, Node ID, Remaining Energy, Status)

**Acceptance Criteria**:
- [ ] Clear definition of all 12 metrics with units
- [ ] FlowMonitor query code walkthrough (how PDR/latency/jitter extracted)
- [ ] CSV header row matches implementation
- [ ] Example console output + log format samples
- [ ] Per-node energy verification method (spot checks during execution)

**Dependency**: Stages 3-5 should be referenced; needed for all batch executions

**Next Stage**: Stage 7

---

### **Stage 7: Simulation Parameterization** ⏳ OUTLINED
**Target Location**: `../reports/phase6_stage7_parameters.md` (to be created)  
**Target Word Count**: 1,500-2,000 words  
**Status**: Outline to be drafted; includes code from phase6_methodology_master.md Section 7

**Expected Content** (from methodology master Section 7):
- ns-3.44 configuration (optimized build profile: `-O3 -DNDEBUG`)
- Temporal window justification (1800s = 30 min = 1.06× Energy Cliff)
- Setup cost amortization argument (18× Phase 4 100s baseline)
- Computational feasibility (90 hours for 180 scenarios)
- Event density estimation (21.6M events for 50-node Mesh at 1800s)
- Packet size justification (100 bytes = single 802.15.4 frame)
- PHY/MAC parameters locked across all scenarios (table in Section 7.5)
- Memory & disk budgeting
- RNG seeding strategy (fixed seed per scenario for reproducibility)

**Acceptance Criteria**:
- [ ] Justification for each locked parameter (why not changed mid-experiment)
- [ ] Memory footprint estimate for maximum-density scenario (50-node × 1800s)
- [ ] Disk space calculation (27MB final, vs 2GB with NetAnim)
- [ ] Build command & verification that `-O3` flags are present
- [ ] RNG seeding code & explanation of seed selection

**Dependency**: Stages 3-6 context needed; required for final build/run validation

**Next Stage**: Stage 8

---

### **Stage 8: Execution Workflow & Quality Assurance** ⏳ OUTLINED
**Target Location**: `../reports/phase6_stage8_workflow.md` (to be created)  
**Target Word Count**: 2,000-2,500 words  
**Status**: Outline to be drafted; includes code from phase6_methodology_master.md Section 8

**Expected Content**:
- Batch sequencing (L → H → D) rationale
- Checkpoint strategy & auto-save frequency (every 10 scenarios)
- Pre-execution validation checkpoints (4 required tests):
  1. Compilation test
  2. Mesh/SEP/ProtoDuty/20-node/1800s smoke test
  3. Mesh/SEP/ProtoDuty/30-node/1800s heterogeneous test
  4. Mesh/APSO/ProtoDuty/50-node/100s density boundary test
- Mid-batch validation (every 25 scenarios)
- Progress logging format & timestamp convention
- Error handling & crash recovery protocol
- Result validation sanity checks (PDR bounds, energy conservation, alive node monotonicity)

**Acceptance Criteria**:
- [ ] All 4 pre-execution checkpoints pass WITHOUT crashes
- [ ] Checkpoint 2 (1800s smoke test) produces valid FND timestamp near 1693s
- [ ] Checkpoint 3 (heterogeneous) verifies Tier 1 consumption >2× Tier 3
- [ ] Checkpoint 4 (50-node) completes without memory errors
- [ ] Batch script can auto-recover from transient failures (e.g., transient disk error)

**Dependency**: All prior stages should be complete & validated; this is the gate for Phase 6B (batch execution)

**Next Stage**: Stage 9

---

### **Stage 9: Data Collection & Storage Architecture** ⏳ OUTLINED
**Target Location**: `../reports/phase6_stage9_data.md` (to be created)  
**Target Word Count**: 1,500-2,000 words  
**Status**: Outline to be drafted; includes code from phase6_methodology_master.md Section 9

**Expected Content**:
- Directory structure (phase6_code/, phase6_results/, phase6_logs/)
- File naming conventions (phase6_longevity_results.txt, phase6_heterogeneous_results.txt, etc.)
- CSV format specification (tab-delimited, column order, data types)
- Log file format (timestamped events, INFO/WARN/CRITICAL levels)
- Per-batch result aggregation (Batch L: 84 rows, Batch H: 8 rows, Batch D: 88 rows)
- Checkpoint backup strategy (copy full result file after every 10 scenarios)
- Disk space budget (22MB result files, 5MB logs, <1MB forensics = 28MB total)
- Data retention & archival plan (all Phase 6 artifacts preserved in git/archive)

**Acceptance Criteria**:
- [ ] All output paths exist and are writable
- [ ] CSV headers match metric definitions from Stage 6
- [ ] Log files rotate properly (no single log >1GB)
- [ ] Backup copies are timestamped & diff-able (for recovery)
- [ ] Phase 4 data (v2_results/) remains completely untouched

**Dependency**: Stages 6-8 should define data formats; workspace structure created

**Next Stage**: Stage 10

---

### **Stage 10: Statistical Analysis & Validation** ⏳ OUTLINED
**Target Location**: `../reports/phase6_stage10_analysis.md` (to be created)  
**Target Word Count**: 2,000-2,500 words  
**Status**: Outline to be drafted; includes code from phase6_methodology_master.md Section 10 (partial)

**Expected Content** (to be derived from full methodology):
- Descriptive statistics for each batch (means, medians, 95% CIs)
- Within-batch comparative analysis (Batch L: protocol-topology-mode heatmaps)
- Cross-batch validation (Batch L 20-node baseline vs. Batch D 20-node density sweep)
- FND/HND timestamp collection & Energy Cliff generalization test
- Heterogeneity advantage coefficient calculation (Batch H: \[Lifespan_het - Lifespan_hom\] / Lifespan_hom)
- Amortization factor definition (Batch D: PDR_1800s / PDR_100s)
- Critical density identification per protocol
- Visualization strategy (temporal curves, heatmaps, scatter plots)
- P-values & hypothesis testing (if applicable; note: exploratory, not confirmatory)
- Limitations & confounding factors

**Acceptance Criteria**:
- [ ] All 3 RQs can be addressed with collected data
- [ ] FND timestamps collected for all Batch L scenarios (84 data points)
- [ ] Heterogeneity advantage calculated for all Batch H protocols (6 protocols × comparison)
- [ ] Amortization factors calculated for Batch D (88 scenarios × analysis)
- [ ] Visualization code produces publication-quality figures

**Dependency**: Batches L/H/D must be complete; Phase 6B fully executed

**Next Stage**: Stage 11 (post-execution, after Phase 6B complete)

---

### **Stage 11: Limitations & Future Work** ⏳ PENDING
**Target Location**: `../reports/phase6_stage11_limitations.md` (to be created post-Phase 6B)  
**Target Word Count**: 1,500-2,000 words  
**Status**: Blocked until Phase 6B complete  

**Expected Content**:
- Simulation limitations (static topology, homogeneous traffic, ideal link layer)
- Generalizability constraints (150m/200m fields, 2-50 nodes, specific propagation model)
- Temporal window limitations (1800s ≠ real 24-hour deployment)
- Protocol implementation fidelity (simplified clustering vs. full ZigBee/LoRa stacks)
- Energy model simplifications (linear discharge, no voltage sag)
- Future work directions (mobility, heterogeneous traffic, real hardware validation)
- Cross-protocol artifact issues (e.g., HEED vs. LEACH election timing differences)
- Sensitivity analysis needed (path-loss exponent, initial energy scaling)

**Acceptance Criteria**:
- [ ] All major limitations explicitly acknowledged
- [ ] Clear explanation of how limitations affect RQ conclusions
- [ ] Concrete proposals for future work (specific experiments/protocols)
- [ ] Guidance for practitioners adapting results to real deployments

**Dependency**: All Phase 6B data & Stage 10 analysis complete

**Next Stage**: Stage 12 (post-execution, final synthesis)

---

### **Stage 12: Phase 4-6 Synthesis & Dissertation Integration** ⏳ PENDING
**Target Location**: `../reports/phase6_stage12_synthesis.md` (to be created post-Phase 6B)  
**Target Word Count**: 3,000-4,000 words  
**Status**: Blocked until Phase 6B & Stage 10 complete  

**Expected Content**:
- Executive summary of Phase 4 (237 scenarios, 100s window, 6 protocols, 3 topologies)
- Phase 6 results summary (180 scenarios, 1800s window, heterogeneity, density)
- Longitudinal findings (100s vs. 1800s comparison across all protocols)
- Energy Cliff generalization (does 1693s hold across topologies/protocols?)
- Heterogeneity impact (SEP/DEEC 30-40% advantage validated?)
- Low-PDR protocol redemption (HEED/IFUC/APSO >60% PDR achieved?)
- Practical recommendations for WSN deployment (protocol selection matrix)
- Dissertation structure & integration (how Phase 4-6 fit into larger thesis narrative)
- Contribution assessment (theoretical, practical, methodological)
- Publication strategy (journal papers, conference abstracts, technical reports)

**Acceptance Criteria**:
- [ ] Clear summary of findings for each RQ
- [ ] Protocol selection decision matrix (field size × duration × density → best protocol)
- [ ] Energy sizing recommendations (battery requirements for 24-hour autonomous op)
- [ ] Integrated 12-stage report combines Phases 4-6 into unified narrative
- [ ] Reproducibility statement (all code/data archived, pre-registration documented)

**Dependency**: All Phase 6B data, Stage 10 analysis, Stage 11 limitations complete

---

## Workflow Summary: Sequential Execution Plan

```
Phase 6A: Pre-Execution (THIS WEEK)
├─ Stage 1 & 2: ✓ Complete (reference only)
├─ Stage 3-10: Create in isolation (pending per-stage approval)
├─ Destructor Crash Fix: Root-cause debugging & targeted patch
├─ Validation Checkpoints 1-4: Execute prescribed smoke tests
└─ Batch Script Testing: Verify run_*.sh can complete 1 scenario

Phase 6B: Batch Execution (NEXT 2-3 WEEKS)
├─ Batch L: 72 scenarios, 36 hours (produces RQ1 answer)
├─ Batch H: 8 scenarios, 4 hours (produces RQ2 answer)
└─ Batch D: 88 scenarios, 44 hours (produces RQ3 answer)

Phase 6C: Post-Execution (FINAL WEEK)
├─ Stage 10: Statistical analysis & visualization
├─ Stage 11: Limitations & future work
└─ Stage 12: Phase 4-6 synthesis & dissertation integration
```

---

## Approval Checkpoints Summary

| Checkpoint | Status | Deliverable | Approval Gate |
|:-----------|:-------|:------------|:--------------|
| **Checkpoint A** | TODO | Implementation diff (CLI flags, CSV, debugEnergy) | REQUIRED before builds |
| **Checkpoint B** | TODO | Destructor crash fix + clean teardown test | REQUIRED before Batch L |
| **Checkpoint C** | TODO | 4 validation tests all pass (no crashes) | REQUIRED before Batch H/D |
| **Checkpoint D** | TODO | Batch script test (1 scenario completes) | REQUIRED before full execution |
| **Checkpoint E** | TODO | Stage 3-10 full write-ups (one per week) | REQUIRED before Phase 6C |
| **Checkpoint F** | TODO | Batch L results aggregated & validated | REQUIRED before Batch H |
| **Checkpoint G** | TODO | Batch H results aggregated & validated | REQUIRED before Batch D |
| **Checkpoint H** | TODO | Batch D results aggregated & validated | REQUIRED before Stage 10 |

---

## Key Metrics for Success

- ✓ All 3 RQs answered with high confidence
- ✓ 180 out of 180 scenarios complete (100% success rate)
- ✓ Zero corrupted outputs (all CSVs valid, all logs parseable)
- ✓ No crashes during 1800s smoke tests
- ✓ FND timestamps collected for 84 Batch L scenarios (±30s precision)
- ✓ Heterogeneity advantage measured for 8 Batch H scenarios
- ✓ Amortization factors calculated for 88 Batch D scenarios
- ✓ All 12 stages documented (2,000-3,000 words each)
- ✓ Phase 4 data (v2_code/, v2_results/, v2_visuals/) remains untouched

---

**Status**: AWAITING APPROVAL TO PROCEED WITH CHECKPOINT A  
**Next Action**: Implement Phase 6 CLI flags in isolated `phase6_code/wsn_phase6_clustering.cc` and present diff for review
