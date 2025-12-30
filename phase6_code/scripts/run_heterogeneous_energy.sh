#!/bin/bash
# phase6_code/scripts/run_heterogeneous_energy.sh
# Batch H: Heterogeneous energy validation - 8 scenarios
# Tests: 8 protocols × Mesh/ProtoDuty, 30 nodes, 200m, heterogeneous tiers, 1800s each
# Expected runtime: ~4 hours

set -o pipefail

# Source utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/utils.sh"

# Batch H Configuration
BATCH_NAME="Heterogeneous Energy"
PROTOCOLS=("leach" "sep" "deec" "heed" "ifuc" "apso" "modleach" "ga-sep")
TOPOLOGY="mesh"
MODE="proto-duty"
NODES=30
TIME=1800
FIELD=200
HETEROGENEOUS=true
SEED_BASE=2000

# Output files
RESULTS_CSV="$RESULTS_DIR/phase6_heterogeneous_results.csv"
CHECKPOINT_FILE="$LOG_DIR/batch_h_checkpoint.txt"

# Initialize
log_info "=== BATCH H: HETEROGENEOUS ENERGY VALIDATION ==="
log_info "Scenarios: 8 (8 protocols × Mesh/ProtoDuty, 30 nodes, 200m, heterogeneous, 1800s each)"
log_info "Expected runtime: ~4 hours"
log_info "Results file: $RESULTS_CSV"

init_checkpoint "$CHECKPOINT_FILE"
start_time=$(date +%s)
current_scenario=0
total_scenarios=${#PROTOCOLS[@]}

# Create CSV header
if [ ! -f "$RESULTS_CSV" ]; then
    echo "batch,scenario_num,protocol,topology,mode,nodes,simTime,field,heterogeneous,startEnergy,remainingEnergy,energyConsumed,aliveNodes,pdr,latency,throughput,jitter,efficiency,ber,bandwidth,responseTime,timestamp" > "$RESULTS_CSV"
fi

# Main batch loop
for proto in "${PROTOCOLS[@]}"; do
    current_scenario=$((current_scenario + 1))
    seed=$((SEED_BASE + current_scenario))
    
    # Generate output CSV name
    output_csv="$RESULTS_DIR/h_${proto}_${TOPOLOGY}_${MODE}_s${seed}.csv"
    
    # Run scenario
    if run_scenario "$proto" "$TOPOLOGY" "$MODE" "$NODES" "$TIME" "$FIELD" "hetero" "$HETEROGENEOUS" "$seed" "$output_csv" > /tmp/result_$$.tmp; then
        result_line=$(cat /tmp/result_$$.tmp)
        
        # Parse metrics from result line
        start_energy=$(echo "$result_line" | grep -oP 'START_ENERGY:\K[0-9.]+')
        rem_energy=$(echo "$result_line" | grep -oP 'REM_ENERGY:\K[0-9.]+')
        consumed=$(echo "$result_line" | grep -oP 'ENERGY_CONS:\K[0-9.]+')
        alive=$(echo "$result_line" | grep -oP 'ALIVE_NODES:\K[0-9]+')
        pdr=$(echo "$result_line" | grep -oP 'PDR:\K[0-9.]+')
        latency=$(echo "$result_line" | grep -oP 'LATENCY:\K[0-9.]+')
        throughput=$(echo "$result_line" | grep -oP 'THROUGHPUT:\K[0-9.]+')
        jitter=$(echo "$result_line" | grep -oP 'JITTER:\K[0-9.]+')
        efficiency=$(echo "$result_line" | grep -oP 'EFFICIENCY:\K[0-9.]+')
        ber=$(echo "$result_line" | grep -oP 'BER:\K[0-9.e-]+')
        bandwidth=$(echo "$result_line" | grep -oP 'BANDWIDTH:\K[0-9]+')
        response_time=$(echo "$result_line" | grep -oP 'RESPONSETIME:\K[0-9.]+')
        
        # Append to master results CSV
        timestamp=$(date '+%Y-%m-%d %H:%M:%S')
        printf "H,%d,%s,%s,%s,%d,%d,%d,true,%.2f,%.2f,%.2f,%d,%.4f,%.6f,%.2f,%.6f,%.9f,%s,%d,%.4f,%s\n" \
            "$current_scenario" "$proto" "$TOPOLOGY" "$MODE" "$NODES" "$TIME" "$FIELD" \
            "$start_energy" "$rem_energy" "$consumed" "$alive" "$pdr" "$latency" \
            "$throughput" "$jitter" "$efficiency" "$ber" "$bandwidth" "$response_time" "$timestamp" \
            >> "$RESULTS_CSV"
        
        # Calculate heterogeneity advantage
        # For homogeneous baseline, would need to compare against known baseline
        log_success "Scenario $current_scenario/$total_scenarios: ${proto}/${TOPOLOGY}/${MODE} (PDR=${pdr}%)"
        
        # Verify tier assignment in per-node CSV
        if [ -f "${output_csv}.pernode.csv" ]; then
            tier_count=$(tail -n +2 "${output_csv}.pernode.csv" | awk -F',' '{print $3}' | sort -u | wc -l)
            log_info "  Energy tiers detected: $tier_count different values"
        fi
    else
        log_error "Scenario $current_scenario/$total_scenarios FAILED: ${proto}/${TOPOLOGY}/${MODE}"
    fi
    
    # Update checkpoint
    update_checkpoint "$CHECKPOINT_FILE" "$current_scenario"
    
    # Report progress
    elapsed=$(($(date +%s) - start_time))
    report_progress "$current_scenario" "$total_scenarios" "$BATCH_NAME" "$elapsed"
    
    rm -f /tmp/result_$$.tmp
done

# Final report
elapsed=$(($(date +%s) - start_time))
hours=$((elapsed / 3600))
mins=$(((elapsed % 3600) / 60))

log_success "=== BATCH H COMPLETE ==="
log_success "All $total_scenarios scenarios executed in ${hours}h ${mins}m"
log_success "Results saved to: $RESULTS_CSV"
log_info "Batch H execution finished at $(date '+%Y-%m-%d %H:%M:%S')"

# Analysis: Calculate heterogeneity advantage
log_info "=== HETEROGENEITY ANALYSIS ==="
log_info "Per-protocol PDR comparison (heterogeneous vs baseline expected ~90%):"
awk -F',' 'NR>1 {printf "  %s: %.2f%% PDR\n", $3, $14}' "$RESULTS_CSV"
