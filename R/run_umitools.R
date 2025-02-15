#' Run UMITools
#'
#' @description UMITools are a set of tools for dealing with Unique Molecular Identifiers.
#' Runs the commands whitelist, extract, group, dedup, count and count_tab.
#'
#' @param command Umitools command
#' @param input1 List of the paths to files containing to the forward reads
#' @param input2 List of the paths to files containing to the reverse reads
#' @param output1 List of paths to the files to write the processed forward reads
#' @param output2 List of paths to the files to write the processed reverse reads
#' @param sample.names List of sample names
#' @param umi.pattern Barcode/UMI pattern, N = UMI position (required),
#'                    C = cell barcode position (optional),
#'                    X = sample position (optional)
#' @param umi.position Read with the UMI, forward or reverse
#' @param three.prime Barcode/UMI at 3' end of read
#' @param parallel Run in parallel, default set to FALSE
#' @param cores Number of cores/threads to use for parallel processing, default set to 4
#' @param execute Whether to execute the commands or not, default set to TRUE
#' @param umitools Path to the Umitools program, required
#' @param version Returns the version number
#'
#' @return A file with the Umitools commands
#' @export
#'
#' @examples
#'  \dontrun{
#'  # Version number
#'  umitools.path <- "/software/anaconda3/bin/umi_tools"
#'
#'  run_umitools(umitools = umitools.path,
#'               version = TRUE)
#'
#'  run_umitools(command = "extract",
#'               input1 = "reads1.fq",
#'               input2 = "reads2.fq",
#'               output1 = "umi.reads1.fq",
#'               output2 = "umi.reads2.fq",
#'               umi.pattern = "NNNNNNNN",
#'               umi.position = "reverse",
#'               execute = FALSE,
#'               umitools = umitools.path)
#'
#'  run_umitools(command = "dedup",
#'               input1 = "align.bam",
#'               output1 = "dedup.align.bam",
#'               sample.names = "align1",
#'               execute = FALSE,
#'               umitools = umitools.path)
#'}
#'
run_umitools <- function(command = NULL,
                         input1 = NULL,
                         input2 = NULL,
                         output1 = NULL,
                         output2 = NULL,
                         sample.names = NULL,
                         umi.pattern = NULL,
                         umi.position = NULL,
                         three.prime = NULL,
                         parallel = FALSE,
                         cores = 4,
                         execute = TRUE,
                         umitools = NULL,
                         version = FALSE){
  # Check umitools program can be found
  sprintf("type -P %s &>//dev//null && echo 'Found' || echo 'Not Found'", umitools)

  # Version
  if (isTRUE(version)){
    umitools.run <- sprintf('%s --version',
                            umitools)
    result <- system(umitools.run, intern = TRUE)
    return(result)
  }

  # Set the additional arguments
  args <- ""

  # UMI extract
  if (command == "extract"){
    if (umi.position == "forward"){
      umitools.run <- sprintf('%s %s -I %s -S %s --read2-in=%s --read2-out=%s --bc-pattern=',
                              umitools,command,input1,output1,input2,output2,umi.pattern)
    }else if (umi.position == "reverse"){
      umitools.run <- sprintf('%s %s -I %s -S %s --read2-in=%s --read2-out=%s --bc-pattern=%s',
                              umitools,command,input2,output2,input1,output1,umi.pattern)
    }
  }

  # UMI dedup
  if (command == "dedup"){
      umitools.run <- sprintf('%s %s --log=%s_dedup.log --stdin=%s --stdout=%s',
                              umitools,command,sample.names,input1,output1)
  }

  # Execute the commands
  if (isTRUE(execute)){
    if (isTRUE(parallel)){
      cluster <- makeCluster(cores)
      parLapply(cluster, umitools.run, function (cmd)  system(cmd))
      stopCluster(cluster)
    }else{
      lapply(umitools.run, function (cmd)  system(cmd))
    }
  }

  return(umitools.run)
}
