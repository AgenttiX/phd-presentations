#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
GIT_DIR="$(dirname "$(dirname "${SCRIPT_DIR}")")"
PTTOOLS_FIG_DIR="${GIT_DIR}/pttools/examples/fig"
PTPLOT_FIG_DIR="${GIT_DIR}/PTPlot/examples/fig"

copy_fig() {
  if [ $# -gt 1 ]; then
    TARGET="${SCRIPT_DIR}/$2.svg"
  else
    TARGET="${SCRIPT_DIR}/$1.svg"
  fi
  cp "$1" "${TARGET}"
}

copy_fig_pttools() {
  copy_fig "${PTTOOLS_FIG_DIR}/svg/$1.svg" $2
}

copy_fig_ptplot() {
  copy_fig "${PTPLOT_FIG_DIR}/svg/$1.svg" $2
}

echo "Copying figures."

copy_fig_pttools "const_cs_gw" "const_cs_gw_v2"
copy_fig_pttools "const_cs_gw_1" "const_cs_gw_1_v2"
copy_fig_pttools "const_cs_gw_2" "const_cs_gw_2_v2"
copy_fig_pttools "const_cs_gw_omgw0_1" "const_cs_gw_omgw0_1_v2"
copy_fig_pttools "const_cs_gw_omgw0_2" "const_cs_gw_omgw0_2_v2"
copy_fig_pttools "const_cs_gw_v" "const_cs_gw_v_v2"
copy_fig_pttools "const_cs_gw_v_1" "const_cs_gw_v_1_v2"
copy_fig_pttools "const_cs_gw_v_2" "const_cs_gw_v_2_v2"
copy_fig_pttools "suppression_no_hybrids_ext_cropped" "suppression_no_hybrids_ext_cropped_v2"

copy_fig_ptplot "singlet_jonathan_snr_alpha_beta_bpl" "singlet_jonathan_snr_alpha_beta_bpl_v2"
copy_fig_ptplot "singlet_jonathan_snr_alpha_beta_dbpl" "singlet_jonathan_snr_alpha_beta_dbpl_v2"
copy_fig_ptplot "singlet_jonathan_snr_alpha_beta_ssm" "singlet_jonathan_snr_alpha_beta_ssm_v2"
copy_fig_ptplot "singlet_jonathan_snr_histogram" "singlet_jonathan_snr_histogram_v2"

echo "Figures copied."
