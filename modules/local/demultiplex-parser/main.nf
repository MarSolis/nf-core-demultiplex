#!/usr/bin/python3

process DEMULTIPARSER{
  tag "Parsing outputs from QC and demultiplexing"

  container "demultiplex-parser:latest"
  input:
    val input_dir
    val multiqc_file
    val output_dir
    val script_parser
    val interop_step_controller
    val multiqc_step_controller

  script:
    """
    python3 $script_parser --input_dir $input_dir --multiqc_file $multiqc_file --output_dir $output_dir
    echo ${interop_step_controller}
    echo ${multiqc_step_controller}
    """
}
