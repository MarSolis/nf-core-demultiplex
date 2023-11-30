#!/usr/bin/env nextflow
#!/usr/bin/python3

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    nf-core/demultiplex
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    Github : https://github.com/nf-core/demultiplex
    Website: https://nf-co.re/demultiplex
    Slack  : https://nfcore.slack.com/channels/demultiplex
----------------------------------------------------------------------------------------
*/

nextflow.enable.dsl = 2

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    GENOME PARAMETER VALUES
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

//   This is an example of how to use getGenomeAttribute() to fetch parameters
//   from igenomes.config using `--genome`

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    VALIDATE & PRINT PARAMETER SUMMARY
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

include { validateParameters; paramsHelp } from 'plugin/nf-validation'

// Print some info
if (params.help!="null") {
log.info """\
    ================================
      DEMULTIPLEX ALIGNMENT PIPELINE
             Fujitsu. 2023.
    ================================

  Usage:
      Run the pipeline with default parameters:
      nextflow run main.nf -profile docker

      Run with user parameters:

      it is possible to add the following parameters after the command to customize them

    Input Output Parameters:
	  Mandatory :
        --run-dir: Input Run Directory
        --output-dir: Output Directory
      Optional:
        --samplesheet_dir: Input Samplesheet
        --interop_dir: Interop Directory
        --compute_script

    Parameters:
      Demultiplexing (BCL2FASTQ -- fastq-dump sra to generate fastq file)
        --loading_threads: Number of threads to load BCL data(-r)
        --processing_threads: Number of threads to process demultiplexing data (-p)
        --writing_threads: Number of threads to write FASTQ data (-w)
        --adapter_stringency : The minimum match rate that triggers masking or trimming.
        --barcode_mismatches: Number of allowed mismatches per index Multiple, comma delimited, entries allowed.
        --create_fastq_for_index_reads: Create FASTQ files also for index reads
        --ignore_missing_filter: Assume 'true' for missing filters
        --ignore_missing_positions: assume [0,i] for missing positions, where i is incremented starting from 0
        --minimum_trimmed_read_length: minimum read length after adapter trimming(=35)
        --mask_short_adapter_reads:  smallest number of remaining bases (after masking bases below the minimum trimmed read length) below which whole read is masked (=22)
        --tiles: Selects a subset of available tiles for processing.
        --use_bases_mask: specifies how to use each cycle.
        --with_failed_reads: include non-PF clusters
        --write_fastq_reverse_complement: generate FASTQs containing reverse complements of actual data
        --no_bgzf_compression: turn off BGZF compression for FASTQ files
        --fastq_compression_level: zlib compression level (1-9) used for FASTQ files (=4)
        --no_lane_splitting: do not split fastq files by lane
        --find_adapters_with_sliding_window: find adapters with simple sliding window algorithm

      Quality (FastQC -- perform fastq quality)
        --nogroup: Disable grouping of bases for reads >50bp
        --noextract: Do not uncompress the output file after creating it

      InterOP Graphs Generation (
        --path_interop
        --command: list of commands to execute from list ('plot_by_cycle','plot_by_lane','plot_flowcell','plot_qscore_heatmap','plot_qscore_histogram','plot_sample_qc')
        --width : image width
        --height: image height
        --dpi: image resolution

         """
         .stripIndent()
    exit 1
}

// Validate input parameters
//if (params.validate_params) {
//    validateParameters()
//}
//
//WorkflowMain.initialise(workflow, params, log)

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    NAMED WORKFLOW FOR PIPELINE
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

include { DEMULTIPLEXING } from "$projectDir/subworkflows/local/demultiplexing/main.nf"
include { MULTIQC } from "$projectDir/subworkflows/local/multiqc/main.nf"
include { INTEROPGRAPHS } from "$projectDir/subworkflows/local/interopgraphs/main.nf"
include { DEMULTIPARSER_WF } from "$projectDir/subworkflows/local/demultiplex-parser/main.nf"

//input-output Params
run_dir = params.run_dir
output_dir = params.output_dir

//demultiplex Params
samplesheet_dir = file(params.samplesheet_dir)
interop_dir = file(params.interop_dir)

//fastqc Params
nogroup = params.nogroup
noextract = params.noextract

//multiqc Params
multiqc_files = file(params.workdir)


//interograph params
compute_script = params.compute_script
path_interop = params.path_interop
command = params.command
width = params.width
height = params.height
dpi = params.dpi

//demultiplex-parser params
input_dir = params.input_dir
multiqc_file = params.multiqc_file
script_parser = params.script_parser

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    RUN MAIN WORKFLOW
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
workflow DEMULTIPLEX {
  DEMULTIPLEXING(run_dir,samplesheet_dir,interop_dir,output_dir,nogroup,noextract)
  fastqc_step_controller = DEMULTIPLEXING.out.fastqc_step_controller
  interop_step_controller = DEMULTIPLEXING.out.interop_step_controller

  INTEROPGRAPHS(compute_script,run_dir,output_dir,path_interop,command,width,height,dpi,interop_step_controller)

  MULTIQC(multiqc_files,fastqc_step_controller)
  multiqc_step_controller = MULTIQC.out.multiqc_step_controller

  DEMULTIPARSER_WF(input_dir,multiqc_file,output_dir,script_parser,interop_step_controller,multiqc_step_controller)
}





/*
 * completion handler
 */
workflow.onComplete {
  log.info ( workflow.success ? "\nDone!\n" : "Oops .. something went wrong" )
}
