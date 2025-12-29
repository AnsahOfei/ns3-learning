# Phase 6: Extended Analysis Workspace

**Status**: Pre-Execution (Implementation & Validation Phase)  
**Objective**: Execute 180 simulation scenarios across 3 experimental batches to answer 3 core research questions  
**Expected Duration**: ~90 hours runtime (can be parallelized)  
**Output Location**: `../phase6_results/` and `../phase6_logs/`

---

## Quick Start

### Build
```bash
cd ../
./ns3 build
```

### Run Single Smoke Test (Validation)
```bash
./ns3 run scratch/wsn_phase6_clustering -- \
  --proto=sep --topo=mesh --mode=proto-duty \
  --nodes=20 --time=1800 --field=150 \
  --seed=42 --csvOut=phase6_results/validation.csv
```

### Run Batch Execution (After Validation)
```bash
# Batch L: Extended Longevity (84 scenarios, ~42 hours)
bash scripts/run_longevity_baseline.sh

# Batch H: Heterogeneous Energy (8 scenarios, ~4 hours)
bash scripts/run_heterogeneous_energy.sh

# Batch D: Density Validation (88 scenarios, ~44 hours)
bash scripts/run_density_validation.sh
```

---

## Workspace Structure

```
phase6_code/                          # Isolated Phase 6 development & execution
├── README.md                         # This file
├── PHASE6_IMPLEMENTATION_PLAN.md     # Index of all 12 stages + detailed implementation notes
├── wsn_phase6_clustering.cc          # Main clustering simulation source (CLEAN COPY)
├── wsn_phase6_zigbee.cc              # Zigbee protocol variant (planned)
├── wsn_phase6_lora.cc                # LoRa protocol variant (planned)
├── scripts/
│   ├── run_longevity_baseline.sh     # Batch L: 84 scenarios × 1800s
│   ├── run_heterogeneous_energy.sh   # Batch H: 8 scenarios × 1800s (heterogeneous)
│   ├── run_density_validation.sh     # Batch D: 88 scenarios × 1800s (density sweep)
│   └── utils.sh                      # Shared logging/checkpoint functions
└── TESTING_NOTES.md                  # Smoke test results & validation checkpoints

phase6_results/                       # Output data (auto-created by scripts)
├── phase6_longevity_results.csv      # Batch L: 84 rows (one per scenario)
├── phase6_heterogeneous_results.csv  # Batch H: 8 rows
├── phase6_density_validation.csv     # Batch D: 88 rows

phase6_logs/                          # Execution logs (auto-created)
├── phase6_batch_l_progress.log       # Batch L live progress (one line per scenario)
├── phase6_batch_h_progress.log       # Batch H live progress
├── phase6_batch_d_progress.log       # Batch D live progress
└── phase6_execution_summary.log      # Final statistics (runtimes, success rates, etc.)
```

---

## Implementation Phases

### Phase 6A: Pre-Execution (Current)
- [x] Revert `scratch/wsn_phase6_clustering.cc` to baseline
- [x] Create isolated `phase6_code/` workspace
- [ ] Implement clean Phase 6 defaults in `wsn_phase6_clustering.cc` (--seed, --csvOut, --debugEnergy flags)
- [ ] Present implementation diff for explicit approval
- [ ] Fix destructor crash (root-cause debugging)
- [ ] Execute 4 validation checkpoints (Compilation, 3 smoke tests)

### Phase 6B: Batch Execution
- [ ] **Batch L** (Extended Longevity): 84 scenarios, ~42 hours
  - Protocols: 8 (LEACH, HEED, SEP, DEEC, IFUC, APSO, Zigbee, LoRa)
  - Topologies: 3 (Grid, Star, Mesh)
  - Modes: 4 (Standard, Duty-Cycle, Protocol, Protocol+Duty-Cycle)
  - Controls: 20 nodes, 150m field, 2100J homogeneous, 1800s
  - Output: FND/HND timestamps, PDR degradation curves

- [ ] **Batch H** (Heterogeneous Energy): 8 scenarios, ~4 hours
  - Protocols: 8 (same)
  - Topology: 1 (Mesh only)
  - Mode: 1 (Protocol+Duty-Cycle)
  - Controls: 30 nodes, 200m field, 1800s
  - Energy Tiers: Tier1(1500J), Tier2(2100J), Tier3(3000J) by distance
  - Output: Heterogeneity advantage coefficient per protocol

- [ ] **Batch D** (Density Validation): 88 scenarios, ~44 hours
  - Protocols: 8 (same)
  - Node Densities: 11 (2, 5, 10, 15, 20, 25, 30, 35, 40, 45, 50)
  - Topology: 1 (Mesh only)
  - Mode: 1 (Protocol+Duty-Cycle)
  - Controls: 150m field, 2100J homogeneous, 1800s
  - Output: Amortization factors, critical density per protocol

### Phase 6C: Post-Execution
- [ ] Analysis & visualization
- [ ] Draft final reports for each batch
- [ ] Integrate Phase 6 findings into Phase 4 Master Report (Stage 13)

---

## 12-Stage Methodology Documentation

All stages are documented in companion files and indexed in `PHASE6_IMPLEMENTATION_PLAN.md`:

1. **Stage 1**: Research Objectives & Motivation (`reports/phase6_stage1_objectives.md`)
2. **Stage 2**: Experimental Design Framework (`reports/phase6_stage2_design.md`)
3. **Stage 3**: Network Topology & Spatial Configuration (pending full write)
4. **Stage 4**: Energy Modeling & Battery Physics (pending full write)
5. **Stage 5**: Protocol Selection & Implementation (pending full write)
6. **Stage 6**: Metrics & Instrumentation (pending full write)
7. **Stage 7**: Simulation Parameterization (pending full write)
8. **Stage 8**: Execution Workflow & Quality Assurance (pending full write)
9. **Stage 9**: Data Collection & Storage Architecture (pending full write)
10. **Stage 10**: Statistical Analysis & Validation (pending full write)
11. **Stage 11**: Limitations & Future Work (pending full write)
12. **Stage 12**: Phase 4-6 Synthesis & Dissertation Integration (pending until Phase 6C)

See `PHASE6_IMPLEMENTATION_PLAN.md` for full index and per-stage acceptance criteria.

---

## Key Simulation Parameters (All Batches)

| Parameter | Value | Locked? |
|:----------|:------|:--------|
| ns-3 Version | 3.44 | YES |
| Build Profile | optimized (`-O3`) | YES |
| Packet Size | 100 bytes | YES |
| PHY Data Rate | 250 kbps | YES |
| TX Power | 0 dBm | YES |
| RX Sensitivity | -85 dBm (LoRa: -125 dBm) | YES |
| Propagation | LogDistance γ=3.0 | YES |
| SADC Logic | wsn_shared.h (Phase 4) | YES |
| Hard Cut-off | 0.0J | YES |
| Duration | 1800s (all batches) | YES |
| Random Seed | Per-scenario, fixed | YES |
| NetAnim | Disabled (memory savings) | YES |

---

## Research Questions & Batch Alignment

| RQ | Question | Batch | Success Criterion |
|:---|:---------|:------|:------------------|
| **RQ1** | How do WSN protocols degrade over 30-minute continuous operation? | L | FND timestamps ±30s precision; Energy Cliff generalization |
| **RQ2** | How does distance-based energy allocation affect network sustainability? | H | SEP/DEEC >20% lifespan extension vs. LEACH <5% |
| **RQ3** | Can HEED/IFUC/APSO achieve >60% PDR in extended 30-min windows? | D | Amortization Factor >4.0 for HEED/IFUC/APSO |

---

## Checkpoints & Approval Workflow

### Pre-Execution Checkpoints (Phase 6A)

**Checkpoint 1: Implementation Diff**
```
Status: PENDING APPROVAL
Location: This README + PHASE6_IMPLEMENTATION_PLAN.md
Required: Explicit user approval of Phase 6 CLI flags and CSV instrumentation
```

**Checkpoint 2: Destructor Crash Fix**
```
Status: PENDING COMPLETION
Current Issue: SIGSEGV in EnergySourceContainer during Simulator::Destroy()
Required: Root-cause identification & targeted fix (no _exit workarounds)
Validation: Clean teardown on 1800s smoke test
```

**Checkpoint 3: Validation Tests (4 required)**
```
Status: PENDING (BLOCKED until Checkpoint 2)
1. Compilation test: ./ns3 build
2. Mesh/SEP/ProtoDuty/20-node/1800s → expect PDR ~90%, no crashes
3. Mesh/SEP/ProtoDuty/30-node/1800s heterogeneous → verify Tier 1/2/3 assignment
4. Mesh/APSO/ProtoDuty/50-node/100s → verify no memory overflow
```

**Checkpoint 4: Batch Script Testing**
```
Status: PENDING (BLOCKED until Checkpoint 3)
Required: Test run_longevity_baseline.sh on 1 scenario (no crash, valid output)
```

### Execution Checkpoints (Phase 6B)

**Mid-Batch Checkpoints (every 10 scenarios)**
```
- Verify energy trends match Phase 4 baseline ±10%
- Confirm alive node counts align with Energy Cliff predictions
- Validate no catastrophic PDR drops (all protocols >0%)
- Save results to disk immediately
```

---

## Instrumentation & Output Format

### CSV Format (Summary)
```
BATCH,SCENARIO,PROTOCOL,TOPOLOGY,MODE,NODES,DURATION,PDR,LATENCY,JITTER,THROUGHPUT,BANDWIDTH,BER,START_ENERGY,REM_ENERGY,CONSUMED_ENERGY,ALIVE_NODES,EFFICIENCY
L,001,LEACH,Grid,Standard,20,1800,94.2,0.21,0.13,31204,32000,8.1e-05,42000,0.0,42000,0,3.9e-05
```

### Log Format (Progress)
```
[2025-12-29 12:30:45] [INFO] Batch L - Scenario 001 - Grid/LEACH/Standard/20nodes/1800s START
[2025-12-29 12:31:15] [PROGRESS] Batch L - Scenario 001 - t=30s, Alive=20/20, PDR=98.5%
[2025-12-29 13:01:47] [INFO] Batch L - Scenario 001 - Grid/LEACH/Standard/20nodes/1800s COMPLETE - PDR=94.2%
```

---

## Known Issues & Mitigations

### Issue 1: EnergySourceContainer Destructor Crash
- **Symptom**: SIGSEGV during `Simulator::Destroy()` at ~t=1693s
- **Root Cause**: TBD (pending gdb backtrace)
- **Mitigation**: Instrumentation with `--debugEnergy` flag
- **Status**: BLOCKING (must be fixed before Batch L execution)

### Issue 2: Memory Overhead at High Densities
- **Symptom**: Potential OOM at 50-node × 1800s scenarios
- **Mitigation**: NetAnim disabled; FlowMonitor carefully managed
- **Validation**: Checkpoint 4 (Mesh/APSO/50-node/100s) verifies no OOM

### Issue 3: Long Runtime
- **180 scenarios × 1800s ≈ 90 hours sequential execution**
- **Mitigation**: Can parallelize batches (L & H/D run independently)
- **Recommendation**: Run on dedicated machine to avoid interrupts

---

## Quick Reference: Phase 4 Baseline for Comparison

From Phase 4 (100-second window, 20-node Mesh):
```
LEACH:   92.2% PDR, 1693s Energy Cliff (extrapolated)
HEED:    14.2% PDR (FAILED at short duration)
SEP:     94.8% PDR, +18% FND extension vs. LEACH
DEEC:    93.1% PDR, best scalability (92.3% at 50 nodes)
IFUC:    14.8% PDR (FAILED at short duration), +12% longevity at 1800s
APSO:    14.1% PDR (FAILED at short duration), 97.4% at 50 nodes
Zigbee:  95.0% PDR (20-node), collapsed to 81.2% at 50 nodes
LoRa:    100% PDR (Star only), 2× energy cost vs. clustering
```

Phase 6 will test whether these extend favorably to 1800s windows.

---

## Contact & Troubleshooting

**Build Issues**:
```bash
./ns3 clean
./ns3 configure --build-profile=optimized
./ns3 build
```

**Simulation Hangs**:
- Check `phase6_logs/` for last progress line
- Verify node count and field size don't exceed memory
- Confirm ns-3 build is optimized (`-O3` flag present)

**CSV Missing**:
- Verify `--csvOut` path exists and is writable
- Check for crashes in `phase6_logs/`
- Re-run scenario with `--debugEnergy` to capture pointer logs

---

**Last Updated**: 2025-12-29  
**Next Step**: Implement Phase 6 CLI flags in `wsn_phase6_clustering.cc` and present diff for approval
