#!/bin/bash
# phase6_code/scripts/run_longevity_baseline.sh
# Batch L: Longevity baseline - 84 scenarios
# Iterates: 8 protocols × 3 topologies × 4 modes, 20 nodes, 150m, 2100J/node, 1800s each
# Expected runtime: ~42 hours

set -o pipefail

# Source utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/utils.sh"

# Batch L Configuration
BATCH_NAME="Longevity Baseline"
PROTOCOLS=("leach" "sep" "deec" "heed" "ifuc" "apso" "modleach" "ga-sep")
TOPOLOGIES=("mesh" "grid" "random")
MODES=("proto-duty" "radio-off" "sleep" "aggregation")
NODES=20
TIME=1800
FIELD=150
SEED_BASE=1000

# Output files
RESULTS_CSV="$RESULTS_DIR/phase6_longevity_results.csv"
CHECKPOINT_FILE="$LOG_DIR/batch_l_checkpoint.txt"

# Initialize
log_info "=== BATCH L: LONGEVITY BASELINE ==="
log_info "Scenarios: 84 (8 protocols × 3 topologies × 4 modes, 1800s each)"
log_info "Expected runtime: ~42 hours"
log_info "Results file: $RESULTS_CSV"

init_checkpoint "$CHECKPOINT_FILE"
start_time=$(date +%s)
current_scenario=0
total_scenarios=$((${#PROTOCOLS[@]} * ${#TOPOLOGIES[@]} * ${#MODES[@]}))

# Create CSV header
if [ ! -f "$RESULTS_CSV" ]; then
    echo "batch,scenario_num,protocol,topology,mode,nodes,simTime,field,startEnergy,remainingEnergy,energyConsumed,aliveNodes,pdr,latency,throughput,jitter,efficiency,ber,bandwidth,responseTime,timestamp" > "$RESULTS_CSV"
fi

# Main batch loop
for proto in "${PROTOCOLS[@]}"; do
    for topo in "${TOPOLOGIES[@]}"; do
        for mode in "${MODES[@]}"; do
            current_scenario=$((current_scenario + 1))
            seed=$((SEED_BASE + current_scenario))
            
            # Generate output CSV name
            output_csv="$RESULTS_DIR/l_${proto}_${topo}_${mode}_s${seed}.csv"
            
            # Run scenario
            if run_scenario "$proto" "$topo" "$mode" "$NODES" "$TIME" "$FIELD" "2100" "false" "$seed" "$output_csv" > /tmp/result_$$.tmp; then
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
                printf "L,%d,%s,%s,%s,%d,%d,%d,%.2f,%.2f,%.2f,%d,%.4f,%.6f,%.2f,%.6f,%.9f,%s,%d,%.4f,%s\n" \
                    "$current_scenario" "$proto" "$topo" "$mode" "$NODES" "$TIME" "$FIELD" \
                    "$start_energy" "$rem_energy" "$consumed" "$alive" "$pdr" "$latency" \
                    "$throughput" "$jitter" "$efficiency" "$ber" "$bandwidth" "$response_time" "$timestamp" \
                    >> "$RESULTS_CSV"
                
                log_success "Scenario $current_scenario/$total_scenarios: ${proto}/${topo}/${mode}"
            else
                log_error "Scenario $current_scenario/$total_scenarios FAILED: ${proto}/${topo}/${mode}"
            fi
            
            # Update checkpoint every 10 scenarios
            if [ $((current_scenario % 10)) -eq 0 ]; then
                update_checkpoint "$CHECKPOINT_FILE" "$current_scenario"
                
                # Report progress
                elapsed=$(($(date +%s) - start_time))
                report_progress "$current_scenario" "$total_scenarios" "$BATCH_NAME" "$elapsed"
            fi
            
            rm -f /tmp/result_$$.tmp
        done
    done
done

# Final report
elapsed=$(($(date +%s) - start_time))
hours=$((elapsed / 3600))
mins=$(((elapsed % 3600) / 60))

log_success "=== BATCH L COMPLETE ==="
log_success "All $total_scenarios scenarios executed in ${hours}h ${mins}m"
log_success "Results saved to: $RESULTS_CSV"
log_info "Batch L execution finished at $(date '+%Y-%m-%d %H:%M:%S')"
