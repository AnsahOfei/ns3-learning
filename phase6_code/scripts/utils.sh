#!/bin/bash
# phase6_code/scripts/utils.sh - Shared utilities for batch execution
# Provides logging, checkpointing, and result parsing functions for all batch scripts

set -o pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$(dirname "$SCRIPT_DIR")")"
NS3_EXECUTABLE="${PROJECT_ROOT}/ns3"
LOG_DIR="${PROJECT_ROOT}/phase6_logs"
RESULTS_DIR="${PROJECT_ROOT}/phase6_results"

# Create directories
mkdir -p "$LOG_DIR" "$RESULTS_DIR"

# ============================================================================
# Logging Functions
# ============================================================================

log_info() {
    local message="$1"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo -e "${BLUE}[${timestamp}]${NC} ${message}" | tee -a "$LOG_DIR/batch_execution.log"
}

log_success() {
    local message="$1"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo -e "${GREEN}[${timestamp}] ✓${NC} ${message}" | tee -a "$LOG_DIR/batch_execution.log"
}

log_error() {
    local message="$1"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo -e "${RED}[${timestamp}] ✗${NC} ${message}" | tee -a "$LOG_DIR/batch_execution.log"
}

log_warning() {
    local message="$1"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo -e "${YELLOW}[${timestamp}] !${NC} ${message}" | tee -a "$LOG_DIR/batch_execution.log"
}

# ============================================================================
# Checkpoint Functions
# ============================================================================

init_checkpoint() {
    local checkpoint_file="$1"
    if [ ! -f "$checkpoint_file" ]; then
        echo "0" > "$checkpoint_file"
        log_info "Initialized checkpoint: $checkpoint_file"
    fi
}

get_checkpoint() {
    local checkpoint_file="$1"
    if [ -f "$checkpoint_file" ]; then
        cat "$checkpoint_file"
    else
        echo "0"
    fi
}

update_checkpoint() {
    local checkpoint_file="$1"
    local count="$2"
    echo "$count" > "$checkpoint_file"
}

# ============================================================================
# Execution Functions
# ============================================================================

run_scenario() {
    local proto="$1"
    local topo="$2"
    local mode="$3"
    local nodes="$4"
    local time="$5"
    local field="$6"
    local energy="$7"
    local hetero="$8"
    local seed="$9"
    local output_csv="${10}"
    
    # Build command
    local cmd="${NS3_EXECUTABLE} run scratch/wsn_phase6_clustering --"
    cmd="${cmd} --proto=${proto}"
    cmd="${cmd} --topo=${topo}"
    cmd="${cmd} --mode=${mode}"
    cmd="${cmd} --nodes=${nodes}"
    cmd="${cmd} --time=${time}"
    cmd="${cmd} --field=${field}"
    cmd="${cmd} --csvOut=${output_csv}"
    cmd="${cmd} --seed=${seed}"
    
    if [ "$hetero" = "true" ] || [ "$hetero" = "1" ]; then
        cmd="${cmd} --heterogeneous"
    fi
    
    # Execute
    local result_line=""
    local exit_code=0
    local output
    
    log_info "Executing: ${proto}/${topo}/${mode}/${nodes}n/${time}s (seed=${seed})"
    
    output=$(eval "$cmd" 2>&1)
    exit_code=$?
    
    # Extract RESULT line
    result_line=$(echo "$output" | grep "^RESULT|" | head -1)
    
    if [ -n "$result_line" ]; then
        log_success "Scenario completed: ${proto}/${topo}/${mode}/${nodes}n"
        
        # Verify CSV was created
        if [ -f "$output_csv" ]; then
            log_success "CSV output created: $output_csv"
            echo "$result_line"
            return 0
        else
            log_error "CSV output NOT created: $output_csv"
            return 1
        fi
    else
        log_error "No RESULT line found for: ${proto}/${topo}/${mode}/${nodes}n"
        log_warning "Exit code: $exit_code"
        return 1
    fi
}

# ============================================================================
# CSV/Result Parsing Functions
# ============================================================================

parse_result_pdr() {
    local result_line="$1"
    echo "$result_line" | grep -oP 'PDR:\K[0-9.]+' | head -1
}

parse_result_fnd() {
    local result_line="$1"
    # FND is not directly in RESULT line, would need to parse per-node CSV
    # For now, return calculated FND based on alive nodes
    local alive=$(echo "$result_line" | grep -oP 'ALIVE_NODES:\K[0-9]+' | head -1)
    local nodes=$(echo "$result_line" | grep -oP 'nodes=\K[0-9]+' || echo "unknown")
    
    if [ "$alive" -eq "$nodes" ] 2>/dev/null; then
        echo "1800" # All nodes alive
    else
        echo "unknown"
    fi
}

# ============================================================================
# CSV Appending Functions
# ============================================================================

append_result_to_csv() {
    local result_file="$1"
    local proto="$2"
    local topo="$3"
    local mode="$4"
    local nodes="$5"
    local time="$6"
    local start_energy="$7"
    local rem_energy="$8"
    local consumed="$9"
    local alive="${10}"
    local pdr="${11}"
    local latency="${12}"
    local throughput="${13}"
    local jitter="${14}"
    local efficiency="${15}"
    local ber="${16}"
    local bandwidth="${17}"
    local response_time="${18}"
    
    # Create header if file doesn't exist
    if [ ! -f "$result_file" ]; then
        echo "proto,topo,mode,nodes,simTime,startEnergy,remainingEnergy,energyConsumed,aliveNodes,pdr,latency,throughput,jitter,efficiency,ber,bandwidth,responseTime" > "$result_file"
    fi
    
    # Append row
    printf "%s,%s,%s,%d,%d,%.2f,%.2f,%.2f,%d,%.4f,%.6f,%.2f,%.6f,%.9f,%.9f,%d,%.4f\n" \
        "$proto" "$topo" "$mode" "$nodes" "$time" "$start_energy" "$rem_energy" "$consumed" \
        "$alive" "$pdr" "$latency" "$throughput" "$jitter" "$efficiency" "$ber" "$bandwidth" "$response_time" \
        >> "$result_file"
}

# ============================================================================
# Progress Reporting Functions
# ============================================================================

report_progress() {
    local current="$1"
    local total="$2"
    local batch_name="$3"
    local elapsed_seconds="$4"
    
    local percent=$((current * 100 / total))
    local estimated_total_seconds=$((elapsed_seconds * total / current))
    local remaining_seconds=$((estimated_total_seconds - elapsed_seconds))
    
    local elapsed_hours=$((elapsed_seconds / 3600))
    local elapsed_mins=$(((elapsed_seconds % 3600) / 60))
    local remaining_hours=$((remaining_seconds / 3600))
    local remaining_mins=$(((remaining_seconds % 3600) / 60))
    
    log_info "${batch_name} Progress: ${current}/${total} (${percent}%) - Elapsed: ${elapsed_hours}h ${elapsed_mins}m - ETA: ${remaining_hours}h ${remaining_mins}m"
}

# ============================================================================
# Export functions for use in calling scripts
# ============================================================================

export -f log_info log_success log_error log_warning
export -f init_checkpoint get_checkpoint update_checkpoint
export -f run_scenario parse_result_pdr parse_result_fnd
export -f append_result_to_csv report_progress

export LOG_DIR RESULTS_DIR NS3_EXECUTABLE PROJECT_ROOT SCRIPT_DIR
