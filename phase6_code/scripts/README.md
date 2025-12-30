# Phase 6 Batch Execution Scripts

This directory contains the three batch execution scripts for Phase 6 comprehensive WSN protocol evaluation.

## Overview

- **Batch L (Longevity Baseline):** 84 scenarios testing protocol longevity across topology/mode variations
- **Batch H (Heterogeneous Energy):** 8 scenarios testing heterogeneous energy allocation impact
- **Batch D (Density Validation):** 88 scenarios testing protocol performance scaling with network density

## Files

### `utils.sh`
Shared utility functions used by all batch scripts:
- **Logging functions:** `log_info`, `log_success`, `log_error`, `log_warning`
- **Checkpoint functions:** `init_checkpoint`, `get_checkpoint`, `update_checkpoint`
- **Execution functions:** `run_scenario`
- **Parsing functions:** `parse_result_pdr`, `parse_result_fnd`
- **CSV functions:** `append_result_to_csv`
- **Progress reporting:** `report_progress`

### `run_longevity_baseline.sh`
**Batch L: Longevity Baseline**

**Scope:** 84 scenarios
- **Protocols:** 8 (LEACH, SEP, DEEC, HEED, IFUC, APSO, ModLEACH, GA-SEP)
- **Topologies:** 3 (mesh, grid, random)
- **Modes:** 4 (proto-duty, radio-off, sleep, aggregation)
- **Network:** 20 nodes, 150m field, 2100J/node, 1800s duration

**Run:**
```bash
./run_longevity_baseline.sh
```

**Output:** `phase6_results/phase6_longevity_results.csv`

**Expected runtime:** ~42 hours

**Research Question:** How do WSN protocols degrade over 30-minute continuous operation?

### `run_heterogeneous_energy.sh`
**Batch H: Heterogeneous Energy Validation**

**Scope:** 8 scenarios
- **Protocols:** 8 (LEACH, SEP, DEEC, HEED, IFUC, APSO, ModLEACH, GA-SEP)
- **Network:** 30 nodes, 200m field, heterogeneous tiers (Tier 1: 1500J, Tier 2: 2100J, Tier 3: 1750J), 1800s
- **Topology:** Mesh
- **Mode:** Proto-duty

**Run:**
```bash
./run_heterogeneous_energy.sh
```

**Output:** `phase6_results/phase6_heterogeneous_results.csv`

**Expected runtime:** ~4 hours

**Research Question:** How does distance-based energy allocation affect WSN sustainability?

### `run_density_validation.sh`
**Batch D: Density Validation**

**Scope:** 88 scenarios
- **Protocols:** 8 (LEACH, SEP, DEEC, HEED, IFUC, APSO, ModLEACH, GA-SEP)
- **Densities:** 11 levels (2, 5, 10, 15, 20, 25, 30, 35, 40, 45, 50 nodes)
- **Network:** 150m field, 2100J/node, 1800s duration
- **Topology:** Mesh
- **Mode:** Proto-duty

**Run:**
```bash
./run_density_validation.sh
```

**Output:** `phase6_results/phase6_density_validation.csv`

**Expected runtime:** ~44 hours

**Research Question:** Can HEED/IFUC/APSO achieve >60% PDR across 1800s operation at critical network densities?

## Usage

### Running Individual Batches

**Single batch (e.g., Batch L):**
```bash
cd /path/to/phase6_code/scripts
./run_longevity_baseline.sh
```

**With output redirection to file:**
```bash
./run_longevity_baseline.sh 2>&1 | tee ../logs/batch_l_execution.log
```

### Running All Batches Sequentially

```bash
#!/bin/bash
cd /path/to/phase6_code/scripts

echo "Starting Batch L..."
./run_longevity_baseline.sh 2>&1 | tee ../logs/batch_all_l.log

echo "Starting Batch H..."
./run_heterogeneous_energy.sh 2>&1 | tee ../logs/batch_all_h.log

echo "Starting Batch D..."
./run_density_validation.sh 2>&1 | tee ../logs/batch_all_d.log

echo "All batches complete!"
```

### Resuming from Checkpoint

Each batch script maintains a checkpoint file tracking completed scenarios:
- Batch L checkpoint: `phase6_logs/batch_l_checkpoint.txt`
- Batch H checkpoint: `phase6_logs/batch_h_checkpoint.txt`
- Batch D checkpoint: `phase6_logs/batch_d_checkpoint.txt`

If a batch is interrupted, re-run the script - it will resume from the checkpoint.

## Output Structure

### Results CSV Files
Located in `phase6_results/`:

**Main batch results:**
- `phase6_longevity_results.csv` (84 rows, Batch L)
- `phase6_heterogeneous_results.csv` (8 rows, Batch H)
- `phase6_density_validation.csv` (88 rows, Batch D)

**Schema:**
```
batch,scenario_num,protocol,topology,mode,nodes,simTime,field,startEnergy,
remainingEnergy,energyConsumed,aliveNodes,pdr,latency,throughput,jitter,
efficiency,ber,bandwidth,responseTime,timestamp
```

**Individual scenario outputs:**
- `l_PROTO_TOPO_MODE_sSEED.csv` - Batch L individual results
- `h_PROTO_TOPO_MODE_sSEED.csv` - Batch H individual results
- `d_PROTO_TOPO_MODE_NODESn_sSEED.csv` - Batch D individual results
- `.pernode.csv` variants - Per-node energy tracking

### Log Files
Located in `phase6_logs/`:
- `batch_execution.log` - Master execution log (all batches)
- `batch_l_checkpoint.txt` - Batch L completion checkpoint
- `batch_h_checkpoint.txt` - Batch H completion checkpoint
- `batch_d_checkpoint.txt` - Batch D completion checkpoint

## Monitoring Progress

### Real-time Progress
Each script prints progress every 10 scenarios:
```
[2025-12-30 12:34:56] Longevity Baseline Progress: 50/84 (59%) - Elapsed: 25h 14m - ETA: 18h 30m
```

### Check Checkpoint Status
```bash
cat phase6_logs/batch_l_checkpoint.txt  # Shows completed scenarios
```

### Monitor Active Execution
```bash
tail -f phase6_logs/batch_execution.log
```

## Known Issues & Mitigation

### Post-Execution SIGSEGV
- **Issue:** Simulator exits with SIGSEGV (signal 11) after completing the scenario
- **Root Cause:** ns-3 container destruction order during `Simulator::Destroy()`
- **Impact:** Zero - all data is written to CSV before crash
- **Mitigation:** Scripts parse RESULT line and CSV files before checking exit code
- **Expected Behavior:** Normal (exit code 245 = signal 11 + 128)

### CSV Parsing Edge Cases
- **PDR values:** Extracted as floating-point, range 0.0-100.0
- **Energy values:** Extracted as floating-point, units are Joules
- **Missing metrics:** If a metric cannot be parsed, "0" is used (rare)

## Performance Expectations

### Batch L (Longevity Baseline)
- **Duration:** ~42 hours
- **Scenarios:** 84
- **Per-scenario time:** ~30 minutes (1800s simulation + ~2 min overhead)
- **Expected PDR range:** 50-98% depending on protocol/topology/mode

### Batch H (Heterogeneous Energy)
- **Duration:** ~4 hours
- **Scenarios:** 8
- **Per-scenario time:** ~30 minutes
- **Expected PDR improvement:** SEP/DEEC >20%, LEACH <5% over homogeneous

### Batch D (Density Validation)
- **Duration:** ~44 hours
- **Scenarios:** 88
- **Per-scenario time:** ~30 minutes (1800s simulation + ~2 min overhead)
- **Critical density:** Varies by protocol (expected 15-25 nodes for >60% PDR)

## Troubleshooting

### Script won't start
```bash
# Verify script is executable
chmod +x run_longevity_baseline.sh

# Verify ns-3 build is available
./ns3 build

# Check directory permissions
ls -ld phase6_results phase6_logs
```

### CSV parsing fails
```bash
# Check if RESULT line is printed
./ns3 run scratch/wsn_phase6_clustering -- --proto=sep --nodes=20 --time=100 2>&1 | grep RESULT

# Check CSV file exists
ls -la phase6_results/l_sep_mesh_proto-duty_s1001.csv
```

### Out of disk space
```bash
# Each batch produces ~1-2 MB of CSV results
# Estimated total: ~8 MB for all 180 scenarios
# Plus log files: ~5-10 MB

# Check available space
df -h phase6_results phase6_logs
```

## Next Steps

After batch execution:
1. **Verify all results files created:** 84+8+88 = 180 rows total
2. **Run statistical analysis** (Stage 10 methodology)
3. **Generate protocol selection matrix** (Stage 12 synthesis)
4. **Write stage documentation** (Stages 3-10 full methodology)
5. **Publish final dissertation** (Stage 12 integration)

---

**Phase 6 Implementation:** December 2025  
**Repository:** https://github.com/AnsahOfei/ns3-learning  
**Total Scenario Coverage:** 180 scenarios × 1800s simulation = 90 hours of simulated time
