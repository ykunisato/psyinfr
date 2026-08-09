#' @title Set up a Quarto Manuscripts project with the senshuQmd template
#' @description
#' Creates a Quarto manuscript project (`project: type: manuscript`) whose
#' article is `paper.qmd` taken from the senshuQmd template
#' (<https://github.com/ykunisato/senshuQmd>), together with two notebooks,
#' `notebooks/Analysis_01.qmd` and `notebooks/Data_collection.qmd`.
#'
#' The layout created is:
#'
#' ```
#' <project>/
#'   _quarto.yml
#'   paper.qmd            article (senshuQmd template)
#'   bibliography.bib
#'   figures/
#'   _extensions/senshu/  senshu-pdf format
#'   notebooks/
#'     Analysis_01.qmd
#'     Data_collection.qmd
#' ```
#'
#' `Data_collection.qmd` holds an example of building an online survey with
#' \pkg{cbat4r} (`set_ic()`, `set_qnr()`, `set_cc()`, `jatosify()`) in an R
#' chunk, and `Analysis_01.qmd` an analysis skeleton that reads the collected
#' JATOS data with [readJatos()].
#'
#' @importFrom utils download.file unzip
#' @importFrom rstudioapi navigateToFile isAvailable
#' @param project_name Name of the manuscript project. Default `"manuscript"`.
#'   Used as the folder name when `add_root_dir = TRUE`.
#' @param output_dir Where the project is created. Default `"."`.
#' @param add_root_dir If `TRUE` (default), a `project_name` folder is created
#'   inside `output_dir` and the files are placed there. If `FALSE`, the files
#'   are placed directly in `output_dir`.
#' @param overwrite If `TRUE`, existing files are overwritten. Default `FALSE`,
#'   which stops when `paper.qmd` or `_quarto.yml` already exists.
#' @param open If `TRUE` (default in RStudio), `paper.qmd` is opened.
#' @param branch Branch of the senshuQmd repository to download. Default
#'   `"main"`.
#' @return The path of the created project, invisibly.
#' @examples # set_manuscript()
#' # set_manuscript("paper2026", output_dir = "paper")
#' @export
set_manuscript <- function(project_name = "manuscript",
                           output_dir = ".",
                           add_root_dir = TRUE,
                           overwrite = FALSE,
                           open = rstudioapi::isAvailable(),
                           branch = "main") {
  if (!is.character(project_name) || length(project_name) != 1 ||
      !nzchar(project_name)) {
    stop("Please set project_name as a single non-empty string.")
  }
  proj_dir <- if (isTRUE(add_root_dir)) {
    file.path(output_dir, project_name)
  } else {
    output_dir
  }

  if (!isTRUE(overwrite)) {
    exists_already <- c("paper.qmd", "_quarto.yml")
    exists_already <- exists_already[file.exists(file.path(proj_dir, exists_already))]
    if (length(exists_already) > 0) {
      stop(paste(exists_already, collapse = " and "), " already exist(s) in ",
           normalizePath(proj_dir, mustWork = FALSE),
           ". Set overwrite = TRUE to replace them.")
    }
  }
  dir.create(file.path(proj_dir, "notebooks"), recursive = TRUE,
             showWarnings = FALSE)
  if (!dir.exists(proj_dir)) {
    stop("Could not create the directory: ", proj_dir)
  }

  # article and format extension from senshuQmd
  .copy_senshuQmd(proj_dir, branch = branch, overwrite = overwrite)

  # manuscript settings and notebooks shipped with psyinfr
  skeleton <- system.file("quarto/manuscript", package = "psyinfr")
  if (!nzchar(skeleton)) {
    stop("The manuscript skeleton was not found in the psyinfr package.")
  }
  file.copy(file.path(skeleton, "_quarto.yml"), proj_dir, overwrite = TRUE)
  notebooks <- c("Analysis_01.qmd", "Data_collection.qmd")
  file.copy(file.path(skeleton, "notebooks", notebooks),
            file.path(proj_dir, "notebooks"), overwrite = TRUE)

  # .gitignore for the Quarto outputs
  gitignore <- file.path(proj_dir, ".gitignore")
  if (!file.exists(gitignore)) {
    writeLines(c("/.quarto/", "/_manuscript/", ".Rproj.user", ".Rhistory",
                 ".DS_Store"), gitignore)
  }

  message("Quarto manuscript project was created in ",
          normalizePath(proj_dir, mustWork = FALSE), ".\n",
          "Run psyinfr::render_manuscript(\"", proj_dir,
          "\") to build the website and the PDF.")
  if (isTRUE(open) && rstudioapi::isAvailable()) {
    rstudioapi::navigateToFile(file.path(proj_dir, "paper.qmd"))
  }
  invisible(proj_dir)
}


#' @title Render a Quarto Manuscripts project into all of its formats
#' @description
#' Runs `quarto render` in the manuscript project, which produces the website
#' (`_manuscript/index.html`) **and** the PDF (`_manuscript/paper.pdf`).
#'
#' The Render button of RStudio runs `quarto preview`, and a preview renders
#' only the first format of the project (the website), leaving the PDF to be
#' built when its download link is clicked. Use this function when the PDF
#' should be built every time.
#'
#' @param project_dir Directory of the manuscript project (the folder holding
#'   `_quarto.yml`). Default `"."`.
#' @param preview If `TRUE`, `quarto preview --render all` is run instead, so
#'   that all formats are rendered and the preview server is started. Default
#'   `FALSE`.
#' @return The exit status of the quarto command, invisibly.
#' @examples # render_manuscript()
#' # render_manuscript("manuscript")
#' @export
render_manuscript <- function(project_dir = ".", preview = FALSE) {
  quarto <- Sys.which("quarto")
  if (!nzchar(quarto)) {
    stop("The quarto command was not found. Please install Quarto ",
         "(https://quarto.org) or use the Render button of RStudio.")
  }
  if (!file.exists(file.path(project_dir, "_quarto.yml"))) {
    stop("_quarto.yml was not found in ", project_dir,
         ". Please set project_dir to the folder of the manuscript project.")
  }
  old <- setwd(project_dir)
  on.exit(setwd(old), add = TRUE)

  args <- if (isTRUE(preview)) c("preview", "--render", "all") else "render"
  status <- system2(quarto, args)
  if (!identical(status, 0L)) {
    warning("quarto ", paste(args, collapse = " "),
            " exited with status ", status, ".", call. = FALSE)
  }
  invisible(status)
}


# Download the senshuQmd template and copy the article, the bibliography, the
# figures directory and the format extension into the project.
.copy_senshuQmd <- function(proj_dir, branch = "main", overwrite = FALSE) {
  url <- paste0("https://github.com/ykunisato/senshuQmd/archive/refs/heads/",
                branch, ".zip")
  tmp <- file.path(tempdir(), paste0("senshuQmd-", as.integer(Sys.time())))
  dir.create(tmp, recursive = TRUE, showWarnings = FALSE)
  on.exit(unlink(tmp, recursive = TRUE), add = TRUE)

  zip_file <- file.path(tmp, "senshuQmd.zip")
  ok <- tryCatch({
    utils::download.file(url, destfile = zip_file, mode = "wb", quiet = TRUE)
    TRUE
  }, error = function(e) FALSE, warning = function(w) FALSE)
  if (!ok || !file.exists(zip_file)) {
    stop("Could not download the senshuQmd template from ", url,
         ". Please check the internet connection.")
  }
  utils::unzip(zip_file, exdir = tmp)

  src <- file.path(tmp, paste0("senshuQmd-", branch))
  if (!dir.exists(src)) {
    stop("Unexpected contents in the downloaded senshuQmd template.")
  }
  contents <- c("paper.qmd", "bibliography.bib", "figures", "_extensions")
  contents <- contents[file.exists(file.path(src, contents))]
  file.copy(file.path(src, contents), proj_dir, recursive = TRUE,
            overwrite = TRUE)

  # In a manuscript project the output formats are set in _quarto.yml, so the
  # format key of the article is removed to keep the two in one place.
  paper <- file.path(proj_dir, "paper.qmd")
  if (file.exists(paper)) {
    writeLines(.drop_yaml_format(readLines(paper, warn = FALSE)), paper,
               useBytes = TRUE)
  }
  invisible(proj_dir)
}

# Drop a "format: senshu-pdf" style line from the YAML header of a qmd file.
.drop_yaml_format <- function(lines) {
  fence <- which(trimws(lines) == "---")
  if (length(fence) < 2 || fence[1] != 1) {
    return(lines)
  }
  header <- seq.int(fence[1] + 1, fence[2] - 1)
  hit <- header[grepl("^format:[[:space:]]*[^[:space:]]", lines[header])]
  if (length(hit) == 0) {
    return(lines)
  }
  lines[-hit]
}
