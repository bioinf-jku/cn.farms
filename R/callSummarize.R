#' Defines which variables should be written back when calling a cn.farms run
#' @param object an matrix with normalized intensity values.
#' @param psInfo a data frame stating the physical position.
#' @param summaryMethod the summarization method.
#' @param summaryParam a list with the parameters of the summarization method.
#' @param batchList batchList
#' @param cores cores
#' @param runtype mode how the results are saved. Possible values are ff or bm. 
#' If ff is chosen the data will not be saved automatically. With bm the 
#' results will be saved permanently. 
#' @param returnValues list with return values. 
#' For possible values see summaryMethod.
#' @param saveFile name of the file to save.
#' @return Results of FARMS run with specified parameters - exact FARMS version
#' @author Djork-Arne Clevert \email{okko@@clevert.de} and 
#' Andreas Mitterecker \email{mitterecker@@bioinf.jku.at}
callSummarize <- function(
        object, 
        psInfo, 
        summaryMethod, 
        summaryParam,
        batchList = NULL, 
        cores = 1, 
        runtype = "ff", 
        returnValues, 
        saveFile = "summData") {

    cat(paste(Sys.time(), " |   Starting summarization \n", sep = ""))
    
    if (is.null(batchList)) {
        batchList <- rep(1, ncol(object))
    }
    
    cat(paste(Sys.time(), " |   Computations will take some time,", 
                    " please be patient \n", sep = ""))
    
    if (runtype == "ram") cores = 1
    
    nbrOfSamples <- ncol(object)
    maxNbrOfProbes <- max((psInfo$end - psInfo$start) + 1)
    nbrOfProbes <- length(psInfo$start)
    
    varNames <- rbind(
            c("slot01", "intensity",               nbrOfSamples, nbrOfProbes),
            c("slot02", "maxZ",                    nbrOfSamples, nbrOfProbes),
            c("slot03", "ICtransform",             nbrOfSamples, nbrOfProbes),
            c("slot04", "KL",                      nbrOfSamples, nbrOfProbes),
            c("slot05", "L_z",                     nbrOfSamples, nbrOfProbes),
            c("slot06", "SNR",                     nbrOfSamples, nbrOfProbes),
            c("slot07", "IC",                      nbrOfSamples, nbrOfProbes),
            c("slot08", "cns",                     nbrOfSamples, nbrOfProbes),
            c("slot09", "medianSample",            nbrOfSamples, nbrOfProbes),
            c("slot10", "z",                       nbrOfSamples, nbrOfProbes),
            c("slot11", "lapla",                   nbrOfSamples, nbrOfProbes),
            c("slot12", "INICall",                 1,            nbrOfProbes),
            c("slot13", "probesize",               1,            nbrOfProbes), 
            c("slot14", "INI_sigVar",              1,            nbrOfProbes),
            c("slot15", "INI",                     1,            nbrOfProbes),
            c("slot16", "ExactMaxZ",               nbrOfSamples, nbrOfProbes),
            c("slot17", "ExactMaxZScaled",         nbrOfSamples, nbrOfProbes),
            c("slot18", "ExactP",                  1,            nbrOfProbes),
            c("slot19", "ExactMLQ",                1,            nbrOfProbes),
            c("slot20", "ExactCase",               nbrOfSamples, nbrOfProbes),
            c("slot21", "IndividualExactKL",       nbrOfSamples, nbrOfProbes),
            c("slot22", "SummaryExactKL",          1,            nbrOfProbes),
            c("slot23", "IndividualExactKLScaled", nbrOfSamples, nbrOfProbes),
            c("slot24", "SummaryExactKLScaled",    1,            nbrOfProbes), 
            c("slot25", "IndividualKL",            nbrOfSamples, nbrOfProbes),
            c("slot26", "SummaryKL",               1,            nbrOfProbes),
            c("slot27", "IndividualKLScaled",      nbrOfSamples, nbrOfProbes),
            c("slot28", "SummaryKLScaled",         1,            nbrOfProbes), 
            c("slot29", "IndividualIC",            nbrOfSamples, nbrOfProbes),
            c("slot30", "SummaryIC",               1,            nbrOfProbes),
            c("slot31", "IndividualICScaled",      nbrOfSamples, nbrOfProbes),
            c("slot32", "SummaryICScaled",         1,            nbrOfProbes),
            c("slot33", "ICtransform",             nbrOfSamples, nbrOfProbes),
            c("slot34", "ICtransformScaled",       nbrOfSamples, nbrOfProbes),
            c("slot35", "IndividualINICall",       nbrOfSamples, nbrOfProbes),
            c("slot36", "SummaryINICall",          1,            nbrOfProbes),
            c("slot37", "varzx",                   nbrOfSamples, nbrOfProbes),
            c("slot38", "varzxScaled",             nbrOfSamples, nbrOfProbes),
            c("slot39", "lambdaMeanNormalized",    1,            nbrOfProbes),
            c("slot40", "lambdaMedianNormalized",  1,            nbrOfProbes),
            c("slot41", "lambda1Mean",             1,            nbrOfProbes),
            c("slot42", "lambda1Median",           1,            nbrOfProbes),
            c("slot43", "cnINIMean",               nbrOfSamples, nbrOfProbes),
            c("slot44", "cnINIMedian",             nbrOfSamples, nbrOfProbes),
            c("slot45", "cnINIMeanSignal",         nbrOfSamples, nbrOfProbes),
            c("slot46", "cnINIMedianSignal",       nbrOfSamples, nbrOfProbes),
            c("slot47", "L_z_Normalized",          nbrOfSamples, nbrOfProbes),
            c("slot48", "L_c_Linear",              nbrOfSamples, nbrOfProbes),
            c("slot49", "L_c_Linear_Normalized",   nbrOfSamples, nbrOfProbes),
            c("slot50", "expressLinear",           nbrOfSamples, nbrOfProbes),
            c("slot51", "L_c_Square",              nbrOfSamples, nbrOfProbes),
            c("slot52", "L_c_Square_Normalized",   nbrOfSamples, nbrOfProbes),
            c("slot53", "expressSquare",           nbrOfSamples, nbrOfProbes),
            c("slot54", "L_c_Softmax",             nbrOfSamples, nbrOfProbes),
            c("slot55", "L_c_Softmax_Normalized",  nbrOfSamples, nbrOfProbes),
            c("slot56", "expressSoftmax",          nbrOfSamples, nbrOfProbes),
            c("slot57", "L_c_Mean",                nbrOfSamples, nbrOfProbes),
            c("slot58", "L_c_Mean_Normalized",     nbrOfSamples, nbrOfProbes),
            c("slot59", "expressMeanBC",           nbrOfSamples, nbrOfProbes),
            c("slot60", "expressMedianBC",         nbrOfSamples, nbrOfProbes),
            c("slot61", "L_c_Median",              nbrOfSamples, nbrOfProbes),
            c("slot62", "L_c_Median_Normalized",   nbrOfSamples, nbrOfProbes),
            c("slot63", "expressBCMean",           nbrOfSamples, nbrOfProbes),
            c("slot64", "expressBCMedian",         nbrOfSamples, nbrOfProbes),
            c("slot65", "colMean",                 nbrOfSamples, nbrOfProbes),
            c("slot66", "colMedian",               nbrOfSamples, nbrOfProbes),
            c("slot67", "allMedian",               1,            nbrOfProbes),
            c("slot68", "twoMedian",               1,            nbrOfProbes),
            c("slot69", "allMean",                 1,            nbrOfProbes),
            c("slot70", "twoMean",                 1,            nbrOfProbes))
    
    varNames <- data.frame(varNames, stringsAsFactors = FALSE)
    varNames[, 3] <- as.numeric(varNames[, 3])
    varNames[, 4] <- as.numeric(varNames[, 4])
    
    if (missing(returnValues)) {
        if (summaryMethod == "summarizeFarmsVariational") {
            idxNames <- c(1, 5, 7, 11)   # 12
        } else if (summaryMethod == "summarizeFarmsExact") {
            idxNames <- c(1, 2, 5)
        } else if (summaryMethod == "summarizeFarmsGaussian"){
            idxNames <- c(1, 5, 12) # 14
        } else {
            idxNames <- c(1, 5)
        }
    } else {
        ##FIXME: check for valid slots
        idxNames <- which(varNames[, 2] %in% returnValues)
    }
    
    ## create objects
    for (i in idxNames) {
        tmp <- paste(
                varNames[i, 1],
                " <- createMatrix(\'",
                runtype, "\'",
                ", nrow = ", varNames[i, 4],
                ", ncol = ", varNames[i, 3],
                ", bmName = \'", gsub("\\.RData", "", saveFile), "\'",
                ")",
                sep = "")
        eval(parse(text = tmp))
    }
    
    ## create assignment calls
    resCommands <- vector(length = length(idxNames))
    for (i in seq(length(idxNames))) {
        if (varNames[idxNames[i], 3] != 1) {
            resCommands[i] <- paste(varNames[idxNames[i], 1],
                    "[i, sampleIndices] <- exprs$",
                    varNames[idxNames[i], 2], sep = "")
        } else {
            resCommands[i] <- paste(varNames[idxNames[i], 1],
                    "[i] <- exprs$",
                    varNames[idxNames[i], 2], sep = "")
        }
    }
    
    if (cores == 1) {
        sfInit(parallel = FALSE)
    } else {
        sfInit(parallel = TRUE, cpus = cores, type = "SOCK")
    }
    
    cnLibrary("cn.farms", character.only = TRUE)
    suppressWarnings(sfExport("summarizeFarmsGaussian", namespace = "cn.farms"))
    suppressWarnings(sfExport("summarizeFarmsVariational", namespace = "cn.farms"))
    suppressWarnings(sfExport("summarizeFarmsExact", namespace = "cn.farms"))
    suppressWarnings(sfExport("summarizeFarmsStatistics", namespace = "cn.farms"))
    
    suppressWarnings(sfExport("psInfo"))
    suppressWarnings(sfExport("object"))
    suppressWarnings(sfExport("summaryParam"))
    suppressWarnings(sfExport("resCommands"))
    
    for (i in idxNames) {
        tmp <- paste("sfExport(\"", varNames[i, 1],"\")", sep = "")
        suppressWarnings(eval(parse(text = tmp)))
    }
    
    batches <- as.character(sort(unique(batchList)))
    for(i in 1:length(batches)){
        cat(paste(Sys.time(), " |   Summarizing ... \n", sep = ""))
        sampleIndices <- which(batchList == batches[i])
        res <- suppressWarnings(sfLapply(seq(nbrOfProbes), callSummarizeH01, sampleIndices, 
                summaryMethod))
    }

    suppressWarnings(sfStop())
    result <- list()
    tmp <- paste("result <- list(",
            paste(paste(varNames[idxNames, 2], varNames[idxNames, 1], sep = "="), 
                    collapse = ", "), ")")
    suppressWarnings(eval(parse(text = tmp)))
    cat(paste(Sys.time(), " |   Summarization done \n", sep = ""))
    return(result)
}


#' Helper function
#' @param i i
#' @param sampleIndices sampleIndices
#' @return Data
#' @author Djork-Arne Clevert \email{okko@@clevert.de} and
#' Andreas Mitterecker \email{mitterecker@@bioinf.jku.at}
#' @noRd
callSummarizeH01 <- function(i, sampleIndices, summaryMethod) {
    
    ## non-visible bindings
    psInfo <- psInfo
    object <- object
    summaryParam <- summaryParam
    resCommands <- resCommands
    
    tmpIndices <- psInfo$start[i]:psInfo$end[i]
    pps <- object[tmpIndices, sampleIndices]
    
    ## special case if there is no variation in the data
    tmp <- apply(pps, 1, var) > 1e-20
    if (!all(tmp)) {
        for (m in which(!tmp)) {
            pps[m, ] <- pps[m, ] + rnorm(length(sampleIndices), 0, 0.00005)
        }
    }

    exprs <- do.call(summaryMethod, c(alist(pps), summaryParam))
    summarizeFarmsExact(as.matrix(pps))
    sapply(resCommands, function (x)  eval(parse(text = x)))
    
    invisible()
}

