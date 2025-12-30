# Phase 6 Post-Batch Execution Plan

**Status:** Batch L running (PID 78362, ETA ~42 hours)  
**Date:** 2025-12-30  

---

## Batch Execution Timeline

```
BATCH L (84 scenarios):
Start:  2025-12-30 09:35 UTC
End:    2025-12-31 15:35 UTC (+42 hours)
Status: RUNNING (PID 78362)

BATCH H (8 scenarios):
Start:  2025-12-31 15:35 UTC (after L completes)
End:    2025-12-31 19:35 UTC (+4 hours)
Status: QUEUED

BATCH D (88 scenarios):
Start:  2025-12-31 19:35 UTC (after H completes)
End:    2026-01-02 19:35 UTC (+44 hours)
Status: QUEUED

TOTAL: 180 scenarios | ~90 hours
```

---

## What Happens After Batch L Completes

### Step 1: Verify Batch L Results
```bash
# Check results file
wc -l /home/aegant/ns-allinone-3.44/ns-3.44/phase6_results/phase6_longevity_results.csv
# Expected: 85 lines (1 header + 84 data rows)

# Check individual scenario files
ls /home/aegant/ns-allinone-3.44/ns-3.44/phase6_results/l_*.csv | wc -l
# Expected: 84 CSV files
```

### Step 2: Commit Batch L Results (MILESTONE 3)
```bash
cd /home/aegant/ns-allinone-3.44/ns-3.44
git add phase6_results/phase6_longevity_results.csv phase6_logs/batch_l_full.log
git commit -m "MILESTONE 3: Batch L complete - longevity baseline (84 scenarios executed, ~42hrs)"
git push origin master
```

### Step 3: Start Batch H
```bash
cd /home/aegant/ns-allinone-3.44/ns-3.44/phase6_code/scripts
nohup ./run_heterogeneous_energy.sh > ../../phase6_logs/batch_h_full.log 2>&1 &
```

### Step 4: Start Batch D (after H completes)
```bash
cd /home/aegant/ns-allinone-3.44/ns-3.44/phase6_code/scripts
nohup ./run_density_validation.sh > ../../phase6_logs/batch_d_full.log 2>&1 &
```

---

## Post-Batch Analysis (After All 180 Scenarios)

### 1. Data Aggregation
```bash
# Combine all batch results
cat phase6_results/phase6_longevity_results.csv > phase6_results/FINAL_RESULTS_ALL_180.csv
tail -n +2 phase6_results/phase6_heterogeneous_results.csv >> phase6_results/FINAL_RESULTS_ALL_180.csv
tail -n +2 phase6_results/phase6_density_validation.csv >> phase6_results/FINAL_RESULTS_ALL_180.csv

# Verify
wc -l phase6_results/FINAL_RESULTS_ALL_180.csv
# Expected: 181 lines (1 header + 180 data rows)
```

### 2. Statistical Analysis
Key metrics to analyze:
- **FND (First Node Dead) timing** by protocol
- **PDR degradation curves** over 1800s
- **Energy consumption patterns** across protocols
- **Protocol performance ranking** by metric
- **Heterogeneity impact** (Batch H comparison)
- **Critical density threshold** for >60% PDR (Batch D)

### 3. Research Question Answers

**RQ1 (Batch L):** How do WSN protocols degrade over 30-minute continuous operation?
- Analyze PDR, FND, throughput degradation curves
- Compare protocol resilience

**RQ2 (Batch H):** How does distance-based energy allocation affect sustainability?
- Calculate improvement: (PDR_hetero - PDR_homo) / PDR_homo
- Expected: SEP/DEEC >20%, LEACH <5%

**RQ3 (Batch D):** Can HEED/IFUC/APSO achieve >60% PDR across 1800s?
- Find critical density for each protocol
- Identify amortization patterns

---

## Stage Documentation to Write

After all batches complete:

**Stages 3-10 (Methodology):**
- Stage 3: Topology & Propagation (incorporate L/H results)
- Stage 4: Energy Modeling (actual consumption patterns from batches)
- Stage 5: Protocols (performance comparison from 180 scenarios)
- Stage 6: Metrics (empirical KPI validation)
- Stage 7: Simulation Parameters (parameter justification with results)
- Stage 8: Workflow (actual execution timeline, overhead measurements)
- Stage 9: Data Architecture (CSV schema validation, 180 scenario structure)
- Stage 10: Statistical Analysis (actual methods + results)

**Stages 11-12 (Synthesis):**
- Stage 11: Limitations & Future Work (based on findings)
- Stage 12: Phase 4-6 Synthesis & Dissertation Integration
  - Answer all 3 RQs with data
  - Create protocol selection matrix
  - Integrate into dissertation narrative

---

## Monitoring Batch Execution

**To check Batch L progress (while running):**
```bash
# See current scenario count
tail -1 /home/aegant/ns-allinone-3.44/ns-3.44/phase6_logs/batch_l_checkpoint.txt

# See latest results
tail -10 /home/aegant/ns-allinone-3.44/ns-3.44/phase6_results/phase6_longevity_results.csv

# Check if process still running
ps aux | grep run_longevity_baseline | grep -v grep

# Monitor log in real-time
tail -f /home/aegant/ns-allinone-3.44/ns-3.44/phase6_logs/batch_l_full.log | grep -E "(Scenario|Progress|✓)"
```

---

## Expected Batch L Results Summary

**Scenario Distribution:**
- 8 protocols × 3 topologies × 4 modes = 84 scenarios
- 20 nodes each
- 1800s duration each
- Random seeds (1001-1084)

**Expected PDR Ranges (from validation tests):**
- SEP: 90-98%
- LEACH: 70-85%
- DEEC: 85-92%
- HEED: 75-88%
- IFUC: 65-80%
- APSO: 40-60%
- ModLEACH: 70-82%
- GA-SEP: 85-95%

**Expected Output Files:**
- `phase6_longevity_results.csv` (84 rows × 21 KPIs)
- `l_PROTO_TOPO_MODE_sSEED.csv` (84 individual files)
- `l_*.csv.pernode.csv` (84 per-node tracking files)
- `batch_l_full.log` (comprehensive execution log)

---

## Next Actions (Sequential)

1. **Monitor:** Watch Batch L progress (~42 hours)
2. **When L done:** Commit MILESTONE 3 + Start Batch H
3. **When H done:** Commit MILESTONE 4 + Start Batch D
4. **When D done:** Commit MILESTONE 5 + Aggregate all 180 results
5. **Write Stages 3-10:** Incorporate findings from batches
6. **Write Stages 11-12:** Synthesize RQ answers + dissertation integration
7. **Commit MILESTONE 6:** Documentation complete
8. **Commit MILESTONE 7:** Phase 6 complete (final deliverable)

---

## Success Criteria for All Batches

✅ **Batch L:** 84 scenarios complete, all CSV files created, PDR values 40-98%
✅ **Batch H:** 8 scenarios complete, heterogeneous tier assignment verified
✅ **Batch D:** 88 scenarios complete, density scaling patterns visible

**Combined:** 180 scenario results answering all 3 RQs

---

**Batch L Status:** 🚀 RUNNING (PID 78362)  
**ETA Completion:** 2025-12-31 15:35 UTC  
**Total Phase 6 Duration:** ~90 hours from start to completion of all batches
