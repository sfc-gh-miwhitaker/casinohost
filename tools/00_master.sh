#!/usr/bin/env bash
#===============================================================================
# Master Orchestration Script - Casino Host Intelligence Demo
#
# Purpose: Single entry point for all deployment, validation, and cleanup ops
# Usage:   ./tools/00_master.sh [command] [options]
#
# Commands:
#   deploy    - Full deployment (setup + data + ML + semantic model)
#   validate  - Run validation checks
#   cleanup   - Remove all demo objects
#   help      - Show this help message
#
# Options:
#   --verbose    Verbose output
#   --dry-run    Show what would be done without executing
#   --skip-tests Skip validation tests
#
# Examples:
#   ./tools/00_master.sh deploy
#   ./tools/00_master.sh deploy --verbose
#   ./tools/00_master.sh validate
#   ./tools/00_master.sh cleanup --dry-run
#===============================================================================

set -euo pipefail

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
VERBOSE=false
DRY_RUN=false
SKIP_TESTS=false

#===============================================================================
# Helper Functions
#===============================================================================

print_header() {
    echo ""
    echo -e "${BLUE}╔════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║  $1${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ $1${NC}"
}

run_command() {
    local cmd=$1
    local description=$2
    
    if [ "$VERBOSE" = true ]; then
        print_info "Running: $cmd"
    fi
    
    if [ "$DRY_RUN" = true ]; then
        print_warning "[DRY-RUN] Would execute: $cmd"
        return 0
    fi
    
    if [ "$VERBOSE" = true ]; then
        eval "$cmd"
    else
        eval "$cmd" > /dev/null 2>&1
    fi
    
    if [ $? -eq 0 ]; then
        print_success "$description"
        return 0
    else
        print_error "$description failed"
        return 1
    fi
}

check_prerequisites() {
    print_header "Checking Prerequisites"
    
    # Check for Snow CLI or Snowsight instructions
    if command -v snow &> /dev/null; then
        print_success "Snow CLI found"
        return 0
    else
        print_warning "Snow CLI not found"
        print_info ""
        print_info "This demo uses 100% Snowflake-native deployment."
        print_info "No local tools required!"
        print_info ""
        print_info "Recommended deployment method:"
        print_info "  1. Open deploy_all.sql (project root)"
        print_info "  2. Copy entire script"
        print_info "  3. Paste into Snowsight worksheet"
        print_info "  4. Click 'Run All'"
        print_info ""
        print_info "See QUICKSTART.md for detailed instructions"
        return 1
    fi
}

#===============================================================================
# Command Functions
#===============================================================================

cmd_deploy() {
    print_header "Casino Host Intelligence - Full Deployment"
    
    print_info "This script is a helper. Primary deployment method:"
    print_info "  → Copy deploy_all.sql to Snowsight and click 'Run All'"
    print_info ""
    print_info "If you have Snow CLI configured, scripts can run individually:"
    echo ""
    
    if ! command -v snow &> /dev/null; then
        print_error "Snow CLI not found. Use Snowsight deployment method."
        print_info "See QUICKSTART.md for instructions"
        exit 1
    fi
    
    print_info "Running sequential deployment via Snow CLI..."
    echo ""
    
    # Step 1: Setup
    print_info "[1/5] Infrastructure Setup"
    run_command "bash ${SCRIPT_DIR}/01_setup.sh" "Infrastructure created"
    
    # Step 2: Data Generation
    print_info "[2/5] Synthetic Data Generation"
    run_command "bash ${SCRIPT_DIR}/02_generate_data.sh" "Data generated"
    
    # Step 3: ML Models
    print_info "[3/5] ML Models & Scoring"
    run_command "bash ${SCRIPT_DIR}/03_deploy_ml.sh" "ML models deployed"
    
    # Step 4: Semantic Model
    print_info "[4/5] Cortex Analyst Deployment"
    run_command "bash ${SCRIPT_DIR}/04_deploy_semantic_model.sh" "Cortex Analyst deployed"
    
    # Step 5: Validation
    if [ "$SKIP_TESTS" = false ]; then
        print_info "[5/5] Validation"
        run_command "bash ${SCRIPT_DIR}/05_validate.sh" "Validation complete"
    else
        print_warning "[5/5] Validation skipped (--skip-tests)"
    fi
    
    print_header "Deployment Complete"
    print_success "All components deployed successfully"
    print_info ""
    print_info "Next steps:"
    print_info "  1. Test Cortex Analyst in Snowsight"
    print_info "  2. Query: 'Which players should I offer comps to right now?'"
    print_info "  3. See docs/03-USAGE.md for demo scenarios"
    print_info ""
    print_info "Estimated cost: ~$0.50"
    print_info "Time elapsed: ~35 minutes"
}

cmd_validate() {
    print_header "Running Validation Checks"
    
    if ! command -v snow &> /dev/null; then
        print_error "Snow CLI not found"
        print_info "Validation requires Snow CLI for automated checks"
        print_info ""
        print_info "Manual validation:"
        print_info "  Run queries from docs/05-INDUSTRY-VALIDATION.md in Snowsight"
        exit 1
    fi
    
    bash "${SCRIPT_DIR}/05_validate.sh"
    
    if [ $? -eq 0 ]; then
        print_success "All validation checks passed"
    else
        print_error "Some validation checks failed"
        print_info "Review output above for details"
        exit 1
    fi
}

cmd_cleanup() {
    print_header "Cleanup - Remove All Demo Objects"
    
    print_warning "This will remove ALL casino host demo objects:"
    print_info "  • Schemas: RAW_INGESTION, STAGING_LAYER, ANALYTICS_LAYER"
    print_info "  • Warehouse: SFE_CASINO_HOST_WH"
    print_info "  • Roles: SFE_CASINO_DEMO_ADMIN, CASINO_HOST_ANALYST"
    print_info "  • Cortex Analyst: casino_host_analyst"
    print_info ""
    print_info "Preserved:"
    print_info "  • SNOWFLAKE_EXAMPLE database (empty shell)"
    print_info "  • GIT_REPOS schema (shared infrastructure)"
    echo ""
    
    if [ "$DRY_RUN" = false ]; then
        read -p "Continue with cleanup? (yes/no): " confirmation
        if [ "$confirmation" != "yes" ]; then
            print_warning "Cleanup cancelled"
            exit 0
        fi
    fi
    
    print_info "Running cleanup script..."
    
    if command -v snow &> /dev/null; then
        run_command "snow sql -f ${PROJECT_ROOT}/sql/99_cleanup/teardown_all.sql" "Cleanup complete"
    else
        print_warning "Snow CLI not found"
        print_info ""
        print_info "Manual cleanup:"
        print_info "  1. Open sql/99_cleanup/teardown_all.sql"
        print_info "  2. Copy entire script"
        print_info "  3. Paste into Snowsight"
        print_info "  4. Click 'Run All'"
        print_info ""
        print_info "See docs/06-CLEANUP.md for details"
        exit 1
    fi
    
    print_success "Cleanup complete"
    print_info "All demo objects removed"
}

cmd_help() {
    cat << EOF

Casino Host Intelligence - Master Orchestration Script

USAGE:
    ./tools/00_master.sh [COMMAND] [OPTIONS]

COMMANDS:
    deploy      Full deployment (setup + data + ML + semantic model)
    validate    Run validation checks
    cleanup     Remove all demo objects
    help        Show this help message

OPTIONS:
    --verbose       Verbose output (show all command output)
    --dry-run       Show what would be done without executing
    --skip-tests    Skip validation tests during deployment

EXAMPLES:
    # Full deployment
    ./tools/00_master.sh deploy

    # Deployment with verbose output
    ./tools/00_master.sh deploy --verbose

    # Validate existing deployment
    ./tools/00_master.sh validate

    # Cleanup (dry-run first)
    ./tools/00_master.sh cleanup --dry-run
    ./tools/00_master.sh cleanup

RECOMMENDED DEPLOYMENT METHOD:
    For fastest deployment, use Snowsight (100% native):
    
    1. Open deploy_all.sql (project root)
    2. Copy entire script
    3. Paste into Snowsight worksheet
    4. Click "Run All"
    5. Wait ~35 minutes
    
    See QUICKSTART.md for detailed instructions.

DOCUMENTATION:
    QUICKSTART.md                - 5-minute quick start
    docs/01-SETUP.md             - Prerequisites
    docs/02-DEPLOYMENT.md        - Detailed deployment guide
    docs/03-USAGE.md             - Demo scenarios
    docs/04-ARCHITECTURE.md      - Technical deep dive
    docs/05-INDUSTRY-VALIDATION.md - Validation queries
    docs/06-CLEANUP.md           - Cleanup instructions
    docs/07-COST-ESTIMATION.md   - Cost breakdown

SUPPORT:
    GitHub: https://github.com/sfc-gh-miwhitaker/casinohost
    Issues: https://github.com/sfc-gh-miwhitaker/casinohost/issues

EOF
}

#===============================================================================
# Main Script Logic
#===============================================================================

# Parse options
while [[ $# -gt 0 ]]; do
    case $1 in
        --verbose)
            VERBOSE=true
            shift
            ;;
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        --skip-tests)
            SKIP_TESTS=true
            shift
            ;;
        deploy|validate|cleanup|help)
            COMMAND=$1
            shift
            ;;
        *)
            print_error "Unknown option: $1"
            cmd_help
            exit 1
            ;;
    esac
done

# Default command
if [ -z "${COMMAND:-}" ]; then
    COMMAND="help"
fi

# Execute command
case $COMMAND in
    deploy)
        cmd_deploy
        ;;
    validate)
        cmd_validate
        ;;
    cleanup)
        cmd_cleanup
        ;;
    help)
        cmd_help
        ;;
    *)
        print_error "Unknown command: $COMMAND"
        cmd_help
        exit 1
        ;;
esac

exit 0

