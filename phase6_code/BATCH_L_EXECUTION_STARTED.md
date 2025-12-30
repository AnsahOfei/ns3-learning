# Batch L Execution - Started

**Date:** December 30, 2025, 09:31 UTC  
**Status:** 🚀 **IN PROGRESS**  
**Terminal ID:** 29625e49-8412-40bf-a001-381735f657f3

---

## Batch L Details

**Batch:** Longevity Baseline  
**Total Scenarios:** 84  
**Configuration:**
- Protocols: 8 (LEACH, SEP, DEEC, HEED, IFUC, APSO, ModLEACH, GA-SEP)
- Topologies: 3 (mesh, grid, random)
- Modes: 4 (proto-duty, radio-off, sleep, aggregation)
- Network: 20 nodes, 150m field, 2100J/node, 1800s each

**Expected Duration:** ~42 hours  
**Start Time:** 2025-12-30 09:31 UTC  
**Estimated End:** 2025-12-31 15:31 UTC  

---

## Execution Status

**Current Stage:** Starting first protocol/topology/mode combinations  
**Log File:** `/phase6_logs/batch_l_full_execution.log`  
**Results File:** `/phase6_results/phase6_longevity_results.csv`  
**Checkpoint:** `/phase6_logs/batch_l_checkpoint.txt`

---

## Scenario Execution Order

Batch L iterates through:

1. **LEACH protocol:**
   - Mesh: proto-duty, radio-off, sleep, aggregation (4)
   - Grid: proto-duty, radio-off, sleep, aggregation (4)
   - Random: proto-duty, radio-off, sleep, aggregation (4)
   - Subtotal: 12 scenarios

2. **SEP protocol:** 12 scenarios
3. **DEEC protocol:** 12 scenarios
4. **HEED protocol:** 12 scenarios
5. **IFUC protocol:** 12 scenarios
6. **APSO protocol:** 12 scenarios
7. **ModLEACH protocol:** 12 scenarios
8. **GA-SEP protocol:** 12 scenarios

**Total:** 8 × 12 = 84 scenarios

---

## Progress Tracking

Use these commands to monitor progress:

```bash
# Check current checkpoint (completed scenarios)
cat /home/aegant/ns-allinone-3.44/ns-3.44/phase6_logs/batch_l_checkpoint.txt

# Monitor live log
tail -f /home/aegant/ns-allinone-3.44/ns-3.44/phase6_logs/batch_l_full_execution.log

# Check results accumulating
wc -l /home/aegant/ns-allinone-3.44/ns-3.44/phase6_results/phase6_longevity_results.csv

# Check scenario results files created
ls -la /home/aegant/ns-allinone-3.44/ns-3.44/phase6_results/l_* | wc -l
```

---

## Expected Milestones

| Time | Scenarios | Progress | Notes |
|------|-----------|----------|-------|
| 09:31 | 0/84 | 0% | Start |
| ~11:31 | ~5/84 | ~6% | 1 hour mark |
| ~15:31 | ~15/84 | ~18% | 6 hours (LEACH complete) |
| ~19:31 | ~25/84 | ~30% | 10 hours (SEP starting) |
| 2025-12-31 23:31 | ~50/84 | ~60% | 38 hours (halfway) |
| 2025-12-31 15:31 | 84/84 | 100% | Complete (~42 hours) |

---

## What's Happening

The batch script is currently:
1. ✅ Initialized checkpoint file
2. ✅ Created results CSV with header
3. ⏳ Starting scenario execution (first: LEACH/mesh/proto-duty/seed=1001)
4. ⏳ Each scenario: 1800s simulation + ~2 min overhead = ~30 min per scenario
5. ⏳ Updating checkpoint every 10 scenarios
6. ⏳ Appending results to phase6_longevity_results.csv

---

## Monitoring

To watch progress without interrupting:

```bash
# Terminal 1: Check checkpoint
watch -n 60 'cat /home/aegant/ns-allinone-3.44/ns-3.44/phase6_logs/batch_l_checkpoint.txt'

# Terminal 2: Count results
watch -n 300 'wc -l /home/aegant/ns-allinone-3.44/ns-3.44/phase6_results/phase6_longevity_results.csv'

# Terminal 3: See latest results
tail -f /home/aegant/ns-allinone-3.44/ns-3.44/phase6_logs/batch_l_full_execution.log | grep -E "(✓|Scenario|Progress)"
```

---

## Next Steps

After Batch L completes (~42 hours):
1. Verify all 84 scenario results in CSV
2. Commit Batch L results (MILESTONE 3)
3. Start Batch H (8 scenarios, ~4 hours)
4. Start Batch D (88 scenarios, ~44 hours)

**Total time to complete all 180 scenarios:** ~90 hours (3.75 days)

---

**Batch L Status:** 🚀 Running  
**Timestamp:** 2025-12-30 09:31 UTC
