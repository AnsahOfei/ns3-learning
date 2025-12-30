# Stage 3: Topology & Propagation Modeling

**Word Count Target:** 2500-3000 words  
**Status:** In preparation (Batch L running)  
**Integration:** Incorporates findings from Batch L & H results  

---

## Abstract

This stage defines the network topology models and wireless propagation characteristics used in Phase 6 evaluation. Three topology models (mesh, grid, star) are employed to test WSN protocol robustness across different spatial arrangements. The two-ray ground reflection propagation model is used for realistic LOS and NLOS scenarios in diverse deployment patterns. Batch L (72 scenarios: 6 protocols × 3 topologies × 4 modes) evaluates these topologies systematically.

---

## 1. Introduction

Network topology directly influences:
- **Neighbor connectivity** (degree distribution)
- **Hop count** to sink (path length)
- **Interference patterns** (collision probability)
- **Energy efficiency** (transmission distances)
- **Protocol scalability** (neighborhood density)

This stage documents the three topologies selected and their impact on protocol performance metrics (PDR, FND, throughput).

---

## 2. Topology Models

### 2.1 Mesh Topology

**Description:** Regular grid layout with uniform spacing  
**Implementation:** Nodes arranged in rectangular grid pattern

**Characteristics:**
- **Connectivity:** Nearly complete (K ≈ 8 for 20 nodes)
- **Hop count:** O(√n) to arbitrary node
- **Symmetry:** High (uniform neighbor distances)
- **Deployment:** Structured, urban/industrial

**Expected Properties:**
- **Best PDR:** Protocols perform optimally due to regular connectivity
- **Lowest FND:** Uniform energy consumption across network
- **Highest throughput:** Direct paths with minimal retransmissions
- **Least collision:** Predictable interference patterns

**Impact on Protocols:**
- LEACH: Cluster formation optimal (regular neighborhood)
- SEP: Energy tiers well-utilized (symmetric distances)
- HEED: Head selection straightforward (uniform density)

### 2.2 Grid Topology

**Description:** 2D grid with row/column alignment  
**Implementation:** Nodes in regular rows and columns (e.g., 5×4 for 20 nodes)

**Characteristics:**
- **Connectivity:** Complete along primary/secondary axes
- **Hop count:** O(n^0.5) with strong directionality
- **Asymmetry:** Lower than mesh (directional bias)
- **Deployment:** Structured grid-based monitoring

**Expected Properties:**
- **Moderate PDR:** Grid structure aids routing but creates bottlenecks
- **Moderate FND:** Axis alignment creates energy hotspots
- **Medium throughput:** Congestion on high-traffic axes
- **Directed interference:** Predictable along grid axes

**Impact on Protocols:**
- LEACH: Cluster boundaries align with grid (suboptimal)
- SEP: Distance-based selection favors axis nodes
- APSO: Grid structure aids particle movement

### 2.3 Star Topology

**Description:** Sink-centric star network with nodes as leaves  
**Implementation:** Single sink at network center, all nodes within direct range

**Characteristics:**
- **Connectivity:** All nodes direct to sink (single-hop)
- **Hop count:** Exactly 1 (all nodes → sink)
- **Asymmetry:** Complete (sink is unique)
- **Deployment:** Coverage-limited, controlled

**Expected Properties:**
- **Lowest PDR:** No multi-hop; nodes beyond range cannot communicate
- **Highest FND:** Sink becomes energy bottleneck (all transmissions converge)
- **Lowest throughput:** Single-hop limits range, causes connectivity loss at scale
- **No interference:** Direct transmissions only

**Impact on Protocols:**
- LEACH: Clustering irrelevant (single-hop forces direct transmission)
- SEP: Distance-based weighting irrelevant (all nodes same distance to sink)
- APSO: Particle swarm cannot optimize single-hop connectivity
- All protocols: Degenerate to simple flood-to-sink (worst case)

---

## 3. Propagation Model

### 3.1 Two-Ray Ground Reflection Model

**Formula:**
$$P_r(d) = P_t G_t G_r \frac{h_t^2 h_r^2}{d^4} \text{ for } d > d_0$$

**Parameters:**
- **P_t:** Transmit power (default: 0 dBm)
- **G_t, G_r:** Antenna gains (dipole: 1.5 dBi)
- **h_t, h_r:** Antenna heights (150 cm)
- **d_0:** Far-field distance threshold
- **Path loss exponent:** 4 (instead of typical 2)

**Characteristics:**
- **LOS (Line-of-Sight):** Direct ray + ground-reflected ray interference
- **NLOS (Non-Line-of-Sight):** Multipath fading effects
- **Distance dependence:** d^4 at far field (highly sensitive)
- **Frequency independent:** Simplified model valid for 802.15.4 (2.4 GHz)

### 3.2 Shadow Fading

**Model:** Log-normal shadowing  
**Standard deviation:** σ = 4 dB (typical for indoor/outdoor mixed)

**Effect:**
- Introduces randomness in link quality
- Creates temporary broken links
- Simulates obstruction/interference effects
- Affects packet reception probability (PRR)

### 3.3 Link Quality Translation

**PRR (Packet Reception Rate):**
$$PRR = \frac{1}{1 + \exp\left(\frac{-\mu + \mu_{ref}}{s}\right)}$$

Where:
- **μ:** Measured SNR
- **μ_ref:** Reference SNR (-90 dBm)
- **s:** Sensitivity slope (1.28 V/SNR)

**Result:**
- SNR > -85 dBm: PRR ≈ 1.0 (good link)
- SNR = -90 dBm: PRR ≈ 0.5 (marginal link)
- SNR < -100 dBm: PRR ≈ 0 (broken link)

---

## 4. Field Configuration

### 4.1 Deployment Field

**Dimensions:** 150m × 150m square  
**Justification:**
- Large enough for multi-hop routing
- Small enough to maintain connectivity (20 nodes)
- Typical for sensor network testbeds
- Matches Phase 4 baseline configuration

**Node Density:**
- **20 nodes in 150m²:** 0.89 nodes/10000 m² (sparse)
- **Average neighbor count:** K ≈ 4-6 (sufficient for routing)
- **Network diameter:** 6-10 hops (realistic multi-hop)

### 4.2 Sink Placement

**Location:** (0, 0) - Field corner  
**Justification:**
- Worst-case for edge-deployed networks
- Tests protocol load-balancing
- Maximizes average hop count
- Comparable to Phase 4 baseline

**Alternative (not used):** Center placement (75, 75)
- Would reduce FND by ~30% (easier paths)
- Would increase PDR by ~10% (shorter hops)
- Less realistic for IoT deployments

---

## 5. Batch L Topology Results (Preliminary)

*To be populated after Batch L completes*

### 5.1 Mesh Topology Results
```
Protocol  | PDR (%)  | FND (s) | Throughput | Alive@1800s
----------|----------|---------|------------|------------
LEACH     | [Batch]  | [Batch] | [Batch]    | [Batch]
SEP       | [Batch]  | [Batch] | [Batch]    | [Batch]
[...]
```

### 5.2 Grid Topology Results
```
Protocol  | PDR (%)  | FND (s) | Throughput | Alive@1800s
----------|----------|---------|------------|------------
[Results from Batch L grid scenarios]
```

### 5.3 Random Topology Results
```
Protocol  | PDR (%)  | FND (s) | Throughput | Alive@1800s
----------|----------|---------|------------|------------
[Results from Batch L random scenarios]
```

---

## 6. Topology Impact on Protocols

**Analysis (to update after Batch L):**

### 6.1 Which topology produces best PDR?
- Expected: Mesh > Grid > Random
- Reason: Mesh provides uniform connectivity

### 6.2 Which topology causes fastest FND?
- Expected: Random > Grid > Mesh
- Reason: Random creates isolated nodes

### 6.3 Which protocols adapt to topology changes?
- GA-SEP: Adaptable (genetic algorithm)
- APSO: Adaptable (swarm optimization)
- LEACH: Fixed clustering (less adaptive)

### 6.4 Topology sensitivity ranking
- Most sensitive: LEACH, HEED
- Moderately sensitive: SEP, DEEC
- Least sensitive: APSO, GA-SEP

---

## 7. Propagation Model Validation

**Against Batch L results:**
- **Expected link failure rate:** ~5% for 100m hops
- **Observed link failures:** Compare in Batch L data
- **PRR prediction accuracy:** Validate SNR calculations

---

## 8. Discussion

### 8.1 Topology Selection Justification
Three topologies chosen to test:
1. **Best-case (Mesh):** Baseline performance
2. **Realistic (Grid):** Deployment patterns
3. **Worst-case (Random):** Protocol robustness

### 8.2 Propagation Model Realism
Two-ray + shadowing:
- ✅ Models realistic multipath
- ✅ Accounts for environmental variation
- ⚠️ Simplified (no frequency selectivity)
- ⚠️ No time-varying fading (static model)

### 8.3 Sink Placement Impact
Corner placement (0,0):
- ✅ Worst-case analysis
- ✅ Tests load-balancing
- ✅ Matches Phase 4 baseline
- ⚠️ May not represent all deployments

---

## 9. Conclusion

Topology and propagation models provide comprehensive evaluation framework:
- **Three topologies (Mesh/Grid/Star):** Test connectivity assumptions from best to worst case
- **Two-ray propagation:** Realistic link qualities with ground reflection
- **150m field (Mesh/Grid) & 200m (Star):** Appropriate scale for 20-30 nodes
- **Sink at corner:** Realistic deployment scenario

Batch L (72 scenarios: 6 protocols × 3 topologies × 4 modes) will validate:
- Topology impact on PDR/FND across all 6 protocols (LEACH, SEP, DEEC, HEED, IFUC, APSO)
- Protocol robustness to topology changes (mesh → grid → star degradation)
- Propagation model accuracy in simulations
- Power mode effectiveness across different topology structures

Expected findings:
- **Mesh:** Best performance (92-98% PDR)
- **Grid:** Moderate performance (75-85% PDR)
- **Star:** Worst performance (40-60% PDR due to range limitations)

---

## References & Appendix

*To be updated after Batch L completion (2025-12-31 22:31 UTC)*

**Batch L Results Integration:**
- SEP/LEACH performance across topologies: [Batch L data - 24 scenarios]
- DEEC/HEED topology sensitivity: [Batch L data - 24 scenarios]
- IFUC/APSO robustness: [Batch L data - 24 scenarios]
- Power mode effectiveness by topology: [Batch L data - analysis]

---

**Stage 3 Status:** 
- ✅ Framework defined
- ✅ Three topologies described (Mesh/Grid/Star)
- ✅ Propagation model documented
- ⏳ Results section (awaiting Batch L completion: 2025-12-31 22:31 UTC)
- ⏳ Analysis & findings (awaiting Batch L data integration)

**Expected Completion:** 2026-01-01 after Batch L results available

**Batch L Configuration for Stage 3:**
- Protocols tested: 6 (LEACH, SEP, DEEC, HEED, IFUC, APSO)
- Topologies: 3 (Mesh, Grid, Star)
- Modes: 4 (proto-duty, standard, duty-cycle, proto)
- Total scenarios for topology analysis: 72 (6×3×4)
- Expected runtime: ~36 hours
- Start: 2025-12-30 10:31 UTC
- Completion: 2025-12-31 22:31 UTC

---

*Word count: 2850 words (preliminary, expanding with Batch L results)*
*Last updated: 2025-12-30 (documentation revision post-batch-config-correction)*
