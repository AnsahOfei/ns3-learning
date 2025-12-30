#!/bin/bash
# phase6_code/scripts/run_density_validation.sh
# Batch D: Density validation - 88 scenarios
# Tests: 8 protocols × 11 densities [2,5,10,15,20,25,30,35,40,45,50], Mesh/ProtoDuty, 150m, 2100J/node, 1800s
# Expected runtime: ~44 hours

set -o pipefail

# Source utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/utils.sh"

# Batch D Configuration
BATCH_NAME="Density Validation"
PROTOCOLS=("leach" "sep" "deec" "heed" "ifuc" "apso" "modleach" "ga-sep")
DENSITIES=(2 5 10 15 20 25 30 35 40 45 50)
TOPOLOGY="mesh"
MODE="proto-duty"
TIME=1800
FIELD=150
SEED_BASE=3000

# Output files
RESULTS_CSV="$RESULTS_DIR/phase6_density_validation.csv"
CHECKPOINT_FILE="$LOG_DIR/batch_d_checkpoint.txt"

# Initialize
log_info "=== BATCH D: DENSITY VALIDATION ==="
log_info "Scenarios: 88 (8 protocols × 11 densities [2-50 nodes], Mesh/ProtoDuty, 1800s each)"
log_info "Expected runtime: ~44 hours"
log_info "Results file: $RESULTS_CSV"

init_checkpoint "$CHECKPOINT_FILE"
start_time=$(date +%s)
current_scenario=0
total_scenarios=$((${#PROTOCOLS[@]} * ${#DENSITIES[@]}))

# Create CSV header
if [ ! -f "$RESULTS_CSV" ]; then
    echo "batch,scenario_num,protocol,topology,mode,nodes,density,simTime,field,startEnergy,remainingEnergy,energyConsumed,aliveNodes,pdr,latency,throughput,jitter,efficiency,ber,bandwidth,responseTime,timestamp" > "$RESULTS_CSV"
fi

# Main batch loop
for proto in "${PROTOCOLS[@]}"; do
    for density in "${DENSITIES[@]}"; do
        current_scenario=$((current_scenario + 1))
        seed=$((SEED_BASE + current_scenario))
        
        # Generate output CSV name
        output_csv="$RESULTS_DIR/d_${proto}_${TOPOLOGY}_${MODE}_${density}n_s${seed}.csv"
        
        # Run scenario
        if run_scenario "$proto" "$TOPOLOGY" "$MODE" "$density" "$TIME" "$FIELD" "2100" "false" "$seed" "$output_csv" > /tmp/result_$$.tmp; then
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
            printf "D,%d,%s,%s,%s,%d,%d,%d,%d,%.2f,%.2f,%.2f,%d,%.4f,%.6f,%.2f,%.6f,%.9f,%s,%d,%.4f,%s\n" \
                "$current_scenario" "$proto" "$TOPOLOGY" "$MODE" "$density" "$density" "$TIME" "$FIELD" \
                "$start_energy" "$rem_energy" "$consumed" "$alive" "$pdr" "$latency" \
                "$throughput" "$jitter" "$efficiency" "$ber" "$bandwidth" "$response_time" "$timestamp" \
                >> "$RESULTS_CSV"
            
            log_success "Scenario $current_scenario/$total_scenarios: ${proto}/${density}n (PDR=${pdr}%)"
        else
            log_error "Scenario $current_scenario/$total_scenarios FAILED: ${proto}/${density}n"
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

# Final report
elapsed=$(($(date +%s) - start_time))
hours=$((elapsed / 3600))
mins=$(((elapsed % 3600) / 60))

log_success "=== BATCH D COMPLETE ==="
log_success "All $total_scenarios scenarios executed in ${hours}h ${mins}m"
log_success "Results saved to: $RESULTS_CSV"
log_info "Batch D execution finished at $(date '+%Y-%m-%d %H:%M:%S')"

# Analysis: Identify critical density for >60% PDR
log_info "=== DENSITY CRITICAL POINT ANALYSIS ==="
log_info "Identifying minimum density for >60% PDR by protocol:"

for proto in "${PROTOCOLS[@]}"; do
    critical_density=$(awk -F',' -v p="$proto" '$3==p && $14>60 {print $6; exit}' "$RESULTS_CSV")
    if [ -z "$critical_density" ]; then
        critical_density="N/A (never exceeded 60%)"
    fi
    log_info "  $proto: $critical_density nodes"
done
