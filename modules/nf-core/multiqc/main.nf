process MULTIQC {
    label 'process_single'

    conda "bioconda::multiqc=1.14"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/multiqc:1.14--pyhdfd78af_0' :
        'quay.io/biocontainers/multiqc:1.14--pyhdfd78af_0' }"

    input:
    path(multiqc_files)
    val fastqc_step_controller


    output:
    path "*multiqc_report.html", emit: report
    path "*_data"              , emit: data
    path "*_plots"             , optional:true, emit: plots
    path "versions.yml"        , emit: versions
    path  "multiqc_step_controller"           , emit: multiqc_step_controller

    when:
    task.ext.when == null || task.ext.when

    script:

    """
    multiqc \\
    $multiqc_files
    echo ${fastqc_step_controller}
    cat > multiqc_step_controller
    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        multiqc: \$( multiqc --version | sed -e "s/multiqc, version //g" )
    END_VERSIONS
    """

}
