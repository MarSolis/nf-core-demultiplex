/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    IMPORT NF-CORE MODULES/SUBWORKFLOWS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

include { MULTIQC                     } from "$projectDir/modules/nf-core/multiqc/main.nf"
include { CUSTOM_DUMPSOFTWAREVERSIONS } from "$projectDir/modules/nf-core/dumpsoftwareversions/main.nf"

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    RUN MAIN WORKFLOW
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

// read params
// multiqc_files = params.multiqc_files

workflow MULTIQC_WF {
  take:
    multiqc_files
    fastqc_step_controller
//    ch_versions = Channel.empty()


    //
    // MODULE: MultiQC
    //
  main:
    MULTIQC (multiqc_files,fastqc_step_controller)
    multiqc_step_controller = MULTIQC.out.multiqc_step_controller
    ch_versions = ch_versions.mix(MULTIQC.out.versions)

    CUSTOM_DUMPSOFTWAREVERSIONS (
        ch_versions.unique().collectFile(name: 'collated_versions.yml')
    )

  emit:
    multiqc_step_controller = multiqc_step_controller

}
