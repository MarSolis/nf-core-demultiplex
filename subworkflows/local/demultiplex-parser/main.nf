include { DEMULTIPARSER } from "$projectDir/modules/local/demultiplex-parser/main.nf"

workflow DEMULTIPARSER_WF{
  take:
    input_dir
    multiqc_file
    output_dir
    script_parser
    interop_step_controller
    multiqc_step_controller

  main:
    DEMULTIPARSER (input_dir,multiqc_file,output_dir,script_parser,interop_step_controller,multiqc_step_controller)
}

