/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    PRINT PARAMS SUMMARY
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

// include { paramsSummaryLog; paramsSummaryMap } from 'plugin/nf-validation'

// def logo = NfcoreTemplate.logo(workflow, params.monochrome_logs)
// def citation = '\n' + WorkflowMain.citation(workflow) + '\n'
// def summary_params = paramsSummaryMap(workflow)

// Print parameter summary log to screen
// log.info logo + paramsSummaryLog(workflow) + citation

// WorkflowDemultiplexing.initialise(params, log)

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    PRINT PARAMS TO LOG
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

// Print some info
// if (params.help) {
// log.info """\
//
// Demultiplexing Pipeline. Started 2023-08-21.
//	     ==============================
//         	 Demultiplexing & QC
//	          Fujitsu. 2023.
//         ==============================
//	Usage:
//	    Run the pipeline with default parameters:
//	    nextflow run main.nf -profile docker
//
//	    Run with user parameters:
//
// 	    nextflow run main.nf -profile docker
//
//        Common Arguments:
//	    Mandatory :
//            --run-dir: Input Run Directory
//            --output-dir: Output Directory
//        Optional:
//            --samplesheet_dir: Input Samplesheet
//            --interop_dir: Interop Directory
//
//    Pipeline steps and specific arguments:
//
//    1. Demultiplexing
//        BCL2FASTQ -- fastq-dump sra to generate fastq file
//         Parameters:
//            --loading_threads: Number of threads to load BCL data(-r)
//            --processing_threads: Number of threads to process demultiplexing data (-p)
//            --writing_threads: Number of threads to write FASTQ data (-w)
//            --adapter_stringency : The minimum match rate that triggers masking or trimming.
//            --barcode_mismatches: Number of allowed mismatches per index Multiple, comma delimited, entries allowed.
//            --create_fastq_for_index_reads: Create FASTQ files also for index reads
//            --ignore_missing_filter: Assume 'true' for missing filters
//            --ignore_missing_positions: assume [0,i] for missing positions, where i is incremented starting from 0
//            --minimum_trimmed_read_length: minimum read length after adapter trimming(=35)
//            --mask_short_adapter_reads:  smallest number of remaining bases (after masking bases below the minimum trimmed read length) below which whole read is masked (=22)
//            --tiles: Selects a subset of available tiles for processing.
//            --use_bases_mask: specifies how to use each cycle.
//            --with_failed_reads: include non-PF clusters
//            --write_fastq_reverse_complement: generate FASTQs containing reverse complements of actual data
//            --no_bgzf_compression: turn off BGZF compression for FASTQ files
//            --fastq_compression_level: zlib compression level (1-9) used for FASTQ files (=4)
//            --no_lane_splitting: do not split fastq files by lane
//            --find_adapters_with_sliding_window: find adapters with simple sliding window algorithm
//
//
//    3. Illumina-InterOp
//
//    2. Quality
//        FastQC -- perform fastq quality
//            --nogroup: Disable grouping of bases for reads >50bp
//            --noextract: Do not uncompress the output file after creating it
//   """
//
//         .stripIndent()
//	exit 1
// } else {
//   log.info """
//         ==================================
//         FUJINOMICS DEMULTIPLEXING PIPELINE
//         ==================================
//	Input Run Directory =${params.run_dir}
//    Input Samplesheet Path=${params.samplesheet_dir}
//    Interop Directory=${params.interop_dir}
//    Output Directory = ${params.output_dir}
//
//         ==========BCL2FASTQ===============
//    loading_threads: ${params.loading_threads}
//    processing_threads: ${params.processing_threads}
//    writing_threads: ${params.writing_threads}
//    adapter_stringency=${params.adapter_stringency}
//    barcode_mismatches=${params.barcode_mismatches}
//    create_fastq_for_index_reads=${params.create_fastq_for_index_reads}
//    ignore_missing_filter=${params.ignore_missing_filter}
//    ignore_missing_positions=${params.ignore_missing_positions}
//    minimum_trimmed_read_length=${params.minimum_trimmed_read_length}
//    mask_short_adapter_reads=${params.mask_short_adapter_reads}
//    tiles=${params.tiles}
//    use_bases_mask=${params.use_bases_mask}
//    with_failed_reads=${params.with_failed_reads}
//    write_fastq_reverse_complement=${params.write_fastq_reverse_complement}
//    no_bgzf_compression=${params.no_bgzf_compression}
//    fastq_compression_level=${params.fastq_compression_level}
//    no_lane_splitting=${params.no_lane_splitting}
//    find_adapters_with_sliding_window=${params.find_adapters_with_sliding_window}
//
//         ==============FASTQC===============
//    reads=${params.reads}
//    nogroup =${params.nogroup}
//    noextract =${params.noextract}
//   """
// }
//
/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    IMPORT LOCAL MODULES/SUBWORKFLOWS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

//
// SUBWORKFLOW: Consisting of a mix of local and nf-core/modules
//
// include { INPUT_CHECK } from '../subworkflows/local/input_check'

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    IMPORT NF-CORE MODULES/SUBWORKFLOWS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

//
// MODULE: Installed directly from nf-core/modules
//
include { BCL2FASTQ                   } from "$projectDir/modules/nf-core/bcl2fastq/main.nf"
include { INTEROP_SUMMARY             } from "$projectDir/modules/local/interop-summary/main.nf"
include { FASTQC                      } from "$projectDir/modules/nf-core/fastqc/main.nf"
include { CUSTOM_DUMPSOFTWAREVERSIONS } from "$projectDir/modules/nf-core/dumpsoftwareversions/main"

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    RUN MAIN WORKFLOW
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

// read params
run_dir = params.run_dir
samplesheet_dir = file(params.samplesheet_dir)
interop_dir = file(params.interop_dir)
output_dir = params.output_dir
nogroup = params.nogroup
noextract = params.noextract


workflow DEMULTIPLEXING {
  take:
    run_dir
    samplesheet_dir
    interop_dir
    output_dir
    nogroup
    noextract



  main:
    // MODULE: Run BCL2FASTQ
    //
    // BCL2FASTQ(run_dir,samplesheet_dir,interop_dir,output_dir,use_bases_mask,barcode_mismatches,ignore_missing_bcls)
    BCL2FASTQ(samplesheet_dir, run_dir, output_dir)
    //
    // MODULE: Run INTEROP
    //
    INTEROP_SUMMARY(run_dir)
    //
    // MODULE: Run FastQC
    //
    sample_reads_ch = (BCL2FASTQ.out.fastq).flatten()
    //FASTQC(sample_reads_ch,output_dir,run_dir,nogroup,noextract)
    FASTQC (sample_reads_ch)
    output_zip = FASTQC.out.zip

    fastqc_step_controller = FASTQC.out.fastqc_step_controller
    interop_step_controller = INTEROP_SUMMARY.out.interop_step_controller

    ch_versions = Channel.empty()
    ch_versions = ch_versions.mix(FASTQC.out.versions.first())
    ch_versions = ch_versions.mix(BCL2FASTQ.out.versions)
    ch_versions = ch_versions.mix(INTEROP_SUMMARY.out.versions)
    CUSTOM_DUMPSOFTWAREVERSIONS (
        ch_versions.unique().collectFile(name: 'collated_versions.yml')
    )
  emit:
    output_zip = output_zip
    fastqc_step_controller = fastqc_step_controller
    interop_step_controller = interop_step_controller


}

