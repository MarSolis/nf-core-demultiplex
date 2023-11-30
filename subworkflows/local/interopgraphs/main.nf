include { GENERATEPNG } from "$projectDir/modules/local/interop-graphs/main.nf"

workflow INTEROPGRAPHS{
  take:
    compute_script
    run_dir
    output
    path_interop
    command
    width
    height
    dpi
    interop_step_controller

  main:
    GENERATEPNG(compute_script,run_dir,output,path_interop,command,width,height,dpi,interop_step_controller)
}

