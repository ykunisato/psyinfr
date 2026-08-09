#' @title Read JATOS/jsPsych results and tidy them for analysis in R
#' @description
#' Reads a JATOS results file (the text file exported from JATOS, in which each
#' line holds the jsPsych data of one component result) collected with
#' `cbat4r::jatosify()`-style tasks, and reshapes it into analysis-ready data
#' frames.
#'
#' Three representations are produced:
#'
#' * `trials`: one row per jsPsych trial. All scalar trial fields (`rt`,
#'   `trial_type`, `trial_index`, `time_elapsed`, ...) become columns; nested
#'   fields (e.g. `question_order`) are collapsed with `sep`, and deeper
#'   structures are kept as JSON text.
#' * `long`: one row per response item (participant x task x trial x item).
#'   `response` objects such as `{"mood_1":1,"mood_2":0}` are unnested into
#'   `item`/`value` pairs, with a numeric copy in `value_num`.
#' * `wide`: one row per participant, one column per response item, which is
#'   the format usually wanted for statistical analysis.
#'
#' Besides the line-delimited text export, a whole-file JSON array and the
#' JATOS "JSON with metadata" export are also accepted; in the latter case the
#' surrounding JATOS metadata (worker id, study result id, ...) is carried
#' along in columns prefixed with `jatos_`.
#'
#' @importFrom jsonlite fromJSON toJSON
#' @importFrom stats setNames ave
#' @param file Path to a JATOS results file (e.g.
#'   `"jatos_results_data_20260809054431.txt"`).
#' @param format One of `"all"` (default, returns a list of the three data
#'   frames), `"trials"`, `"long"` or `"wide"` (returns that data frame only).
#' @param id_col Name of the trial field identifying a participant. Default
#'   `"workerID"`. If absent, JATOS metadata or the result number is used.
#' @param task_col Name of the trial field identifying a task/component.
#'   Default `"taskName"`. If absent, the result number is used.
#' @param response_col Name of the trial field holding the response. Default
#'   `"response"`.
#' @param extra_cols Character vector of trial columns to carry into `wide`
#'   (one value per participant, the first non-missing one). For instance
#'   `extra_cols = "id"` picks up a completion code stored in the trial.
#' @param prefix How to name the columns of `wide`: `"auto"` (default) prefixes
#'   the task name only when an item name is ambiguous (used by more than one
#'   task, or named like `response_col`), `"always"` always prefixes, `"never"`
#'   never does.
#' @param sep Separator used when collapsing a vector-valued field into one
#'   string. Default `"|"`.
#' @param drop_cols Trial columns to drop from `trials`; nothing is dropped by
#'   default. Set e.g. `drop_cols = "stimulus"` to discard long HTML strings.
#' @param encoding Encoding of `file`. Default `"UTF-8"`.
#' @return A list of data frames (`trials`, `long`, `wide`) of class
#'   `jatos_data`, or a single data frame if `format` is not `"all"`.
#' @examples # d <- readJatos("jatos_results_data_20260809054431.txt")
#' # head(d$wide)
#' # readJatos("jatos_results_data_20260809054431.txt",
#' #           format = "wide", extra_cols = "id")
#' @export
readJatos <- function(file,
                      format = c("all", "trials", "long", "wide"),
                      id_col = "workerID",
                      task_col = "taskName",
                      response_col = "response",
                      extra_cols = character(),
                      prefix = c("auto", "always", "never"),
                      sep = "|",
                      drop_cols = character(),
                      encoding = "UTF-8") {
  if (missing(file)) {
    stop("Please set file (a JATOS results file).")
  }
  if (!file.exists(file)) {
    stop("File not found: ", file)
  }
  format <- match.arg(format)
  prefix <- match.arg(prefix)

  results <- .jatos_read(file, encoding = encoding)
  if (length(results) == 0) {
    stop("No jsPsych data could be parsed from: ", file)
  }

  trials <- .jatos_trials(results, response_col = response_col, sep = sep)
  trials <- .jatos_set_ids(trials, id_col = id_col, task_col = task_col)
  long <- .jatos_long(trials, response_col = response_col)
  wide <- .jatos_wide(trials, long,
                      response_col = response_col,
                      extra_cols = extra_cols,
                      prefix = prefix)
  id_name <- attr(trials, "id_name")
  names(long)[names(long) == "id"] <- id_name
  names(wide)[1] <- id_name

  drop_cols <- intersect(c(drop_cols, ".items"), names(trials))
  trials <- trials[, setdiff(names(trials), drop_cols), drop = FALSE]

  out <- switch(format,
    trials = trials,
    long = long,
    wide = wide,
    all = structure(list(trials = trials, long = long, wide = wide),
                    class = "jatos_data")
  )
  out
}

#' @title Print a summary of the object returned by readJatos()
#' @param x object of class `jatos_data`
#' @param ... ignored
#' @export
print.jatos_data <- function(x, ...) {
  cat("<jatos_data>\n")
  cat("  participants:", length(unique(x$trials$.id)), "\n")
  cat("  tasks       :", paste(unique(x$trials$.task), collapse = ", "), "\n")
  cat("  trials      :", nrow(x$trials), "rows x", ncol(x$trials), "cols\n")
  cat("  long        :", nrow(x$long), "rows (response items)\n")
  cat("  wide        :", nrow(x$wide), "rows x", ncol(x$wide), "cols\n")
  invisible(x)
}


# ---- reading -----------------------------------------------------------

# Read a JATOS results file and return a list of
# list(trials = <list of trial lists>, meta = <named list>).
.jatos_read <- function(file, encoding = "UTF-8") {
  con <- file(file, encoding = encoding)
  on.exit(close(con))
  txt <- readLines(con, warn = FALSE)
  txt <- txt[nzchar(trimws(txt))]
  if (length(txt) == 0) {
    stop("The file is empty: ", file)
  }

  # (1) the whole file is valid JSON: plain array of results, or the JATOS
  #     "JSON with metadata" export
  whole <- tryCatch(
    jsonlite::fromJSON(paste(txt, collapse = "\n"), simplifyVector = FALSE),
    error = function(e) NULL
  )
  if (!is.null(whole)) {
    res <- .jatos_from_json(whole)
    if (length(res) > 0) {
      return(res)
    }
  }

  # (2) line-delimited results (the usual JATOS text export)
  out <- list()
  for (i in seq_along(txt)) {
    parsed <- tryCatch(
      jsonlite::fromJSON(txt[i], simplifyVector = FALSE),
      error = function(e) NULL
    )
    if (is.null(parsed)) {
      warning("Line ", i, " is not valid JSON and was skipped.", call. = FALSE)
      next
    }
    out[[length(out) + 1L]] <- list(trials = .jatos_as_trials(parsed),
                                    meta = list())
  }
  out
}

# Coerce a parsed result into a list of trials (a single trial object is
# wrapped into a list of length one).
.jatos_as_trials <- function(x) {
  if (!is.list(x)) {
    return(list())
  }
  if (!is.null(names(x))) {
    return(list(x))
  }
  x
}

.jatos_meta_keys <- c("id", "uuid", "workerId", "workerType", "studyId",
                      "studyUuid", "studyResultId", "componentId",
                      "componentResultId", "comment", "startDate", "endDate")

# JATOS names the primary key of both study results and component results
# "id"; disambiguate it by the array the object was found in.
.jatos_scopes <- c(studyResults = "studyResultId",
                   componentResults = "componentResultId")

# Walk a parsed JSON object, collecting every "data" payload that holds
# jsPsych trials together with the JATOS metadata seen on the way down.
.jatos_from_json <- function(x) {
  found <- list()

  walk <- function(node, meta, scope) {
    if (!is.list(node)) {
      return(invisible(NULL))
    }
    nms <- names(node)
    if (!is.null(nms)) {
      for (key in intersect(.jatos_meta_keys, nms)) {
        val <- node[[key]]
        if (is.atomic(val) && length(val) == 1) {
          out_key <- if (key == "id" && !is.na(scope)) scope else key
          meta[[paste0("jatos_", out_key)]] <- val
        }
      }
      dat <- node[["data"]]
      if (is.character(dat) && length(dat) == 1) {
        parsed <- tryCatch(jsonlite::fromJSON(dat, simplifyVector = FALSE),
                           error = function(e) NULL)
        if (is.list(parsed)) {
          found[[length(found) + 1L]] <<- list(trials = .jatos_as_trials(parsed),
                                               meta = meta)
          return(invisible(NULL))
        }
      }
    } else if (.jatos_is_trial_array(node)) {
      # a bare array of trials (whole-file JSON array of results)
      found[[length(found) + 1L]] <<- list(trials = node, meta = meta)
      return(invisible(NULL))
    }
    for (k in seq_along(node)) {
      child <- node[[k]]
      if (!is.list(child)) {
        next
      }
      key <- if (is.null(nms)) "" else nms[k]
      child_scope <- if (!is.na(key) && key %in% names(.jatos_scopes)) {
        .jatos_scopes[[key]]
      } else {
        scope
      }
      walk(child, meta, child_scope)
    }
    invisible(NULL)
  }

  walk(x, list(), NA_character_)
  found
}

# TRUE when node looks like a jsPsych data array: an unnamed list of named
# lists carrying trial fields.
.jatos_is_trial_array <- function(node) {
  if (length(node) == 0 || !is.null(names(node))) {
    return(FALSE)
  }
  ok <- vapply(node, function(z) is.list(z) && !is.null(names(z)), logical(1))
  if (!all(ok)) {
    return(FALSE)
  }
  keys <- unique(unlist(lapply(node, names)))
  any(c("trial_type", "trial_index", "rt", "response", "time_elapsed") %in% keys)
}


# ---- flattening --------------------------------------------------------

# Collapse an arbitrary JSON value into a single scalar suitable for a column.
.jatos_scalar <- function(v, sep) {
  if (is.null(v)) {
    return(NA)
  }
  if (is.list(v)) {
    if (length(v) == 0) {
      return(NA)
    }
    flat <- vapply(v, function(z) is.null(z) || (is.atomic(z) && length(z) == 1),
                   logical(1))
    if (all(flat)) {
      vals <- vapply(v, function(z) if (is.null(z)) NA_character_ else as.character(z),
                     character(1))
      nms <- names(v)
      if (!is.null(nms) && any(nzchar(nms))) {
        vals <- paste0(nms, "=", vals)
      }
      return(paste(vals, collapse = sep))
    }
    return(as.character(jsonlite::toJSON(v, auto_unbox = TRUE, null = "null")))
  }
  if (length(v) != 1) {
    return(paste(as.character(v), collapse = sep))
  }
  v
}

# Split a response value into named items.
.jatos_items <- function(v, response_col, sep) {
  if (is.null(v)) {
    return(list())
  }
  if (is.list(v) && length(v) > 0 && !is.null(names(v)) && all(nzchar(names(v)))) {
    items <- lapply(v, .jatos_scalar, sep = sep)
    return(items)
  }
  val <- .jatos_scalar(v, sep = sep)
  if (length(val) == 1 && is.na(val)) {
    return(list())
  }
  stats::setNames(list(val), response_col)
}

# Build the trial-level data frame; response items ride along in .items.
.jatos_trials <- function(results, response_col, sep) {
  rows <- list()
  items <- list()
  for (i in seq_along(results)) {
    res <- results[[i]]
    trials <- res$trials
    for (j in seq_along(trials)) {
      tr <- trials[[j]]
      if (!is.list(tr) || is.null(names(tr))) {
        next
      }
      row <- lapply(tr, .jatos_scalar, sep = sep)
      row <- c(list(.result = i), res$meta, row)
      rows[[length(rows) + 1L]] <- row
      items[[length(items) + 1L]] <- .jatos_items(tr[[response_col]],
                                                  response_col = response_col,
                                                  sep = sep)
    }
  }
  if (length(rows) == 0) {
    stop("No trials were found in the file.")
  }
  df <- .jatos_bind(rows)
  df$.items <- items
  df
}

# rbind a list of named lists of scalars into a data frame, typing each column.
.jatos_bind <- function(rows) {
  keys <- unique(unlist(lapply(rows, names)))
  cols <- lapply(keys, function(k) {
    vals <- lapply(rows, function(r) if (is.null(r[[k]])) NA else r[[k]])
    .jatos_col(vals)
  })
  names(cols) <- keys
  df <- as.data.frame(cols, stringsAsFactors = FALSE, check.names = FALSE)
  df
}

.jatos_col <- function(vals) {
  is_na <- vapply(vals, function(v) length(v) == 1 && !is.character(v) && is.na(v),
                  logical(1))
  is_num <- vapply(vals, function(v) is.numeric(v) && length(v) == 1, logical(1))
  if (all(is_num | is_na)) {
    return(vapply(vals, function(v) if (is.numeric(v)) as.numeric(v) else NA_real_,
                  numeric(1)))
  }
  is_lgl <- vapply(vals, function(v) is.logical(v) && length(v) == 1, logical(1))
  if (all(is_lgl)) {
    return(vapply(vals, function(v) as.logical(v)[1], logical(1)))
  }
  vapply(vals, function(v) if (length(v) == 1 && !is.character(v) && is.na(v)) {
    NA_character_
  } else {
    as.character(v)[1]
  }, character(1))
}

# Add the .id / .task helper columns used downstream.
.jatos_set_ids <- function(trials, id_col, task_col) {
  id <- NULL
  id_name <- id_col
  for (cand in c(id_col, "jatos_workerId", "jatos_studyResultId", "jatos_id")) {
    if (cand %in% names(trials)) {
      id <- as.character(trials[[cand]])
      id_name <- cand
      break
    }
  }
  if (is.null(id) || all(is.na(id))) {
    warning("No participant id column (", id_col,
            ") was found; the result number is used instead.", call. = FALSE)
    id <- as.character(trials$.result)
    id_name <- "id"
  }
  id[is.na(id)] <- "NA"

  if (task_col %in% names(trials)) {
    task <- as.character(trials[[task_col]])
  } else {
    task <- paste0("result", trials$.result)
  }
  task[is.na(task)] <- paste0("result", trials$.result[is.na(task)])

  trials <- cbind(data.frame(.id = id, .task = task, stringsAsFactors = FALSE),
                  trials)
  attr(trials, "id_name") <- id_name
  trials
}


# ---- reshaping ---------------------------------------------------------

.jatos_long <- function(trials, response_col) {
  n <- vapply(trials$.items, length, integer(1))
  idx <- rep(seq_len(nrow(trials)), n)
  if (length(idx) == 0) {
    empty <- data.frame(id = character(), task = character(),
                        result = numeric(), trial = integer(),
                        trial_index = numeric(), item = character(),
                        value = character(), value_num = numeric(),
                        stringsAsFactors = FALSE)
    if ("rt" %in% names(trials)) {
      empty$rt <- numeric()
    }
    return(empty)
  }
  item <- unlist(lapply(trials$.items, names), use.names = FALSE)
  value <- vapply(unlist(trials$.items, recursive = FALSE, use.names = FALSE),
                  function(v) if (length(v) == 1 && !is.character(v) && is.na(v)) {
                    NA_character_
                  } else {
                    as.character(v)[1]
                  }, character(1))

  ti <- if ("trial_index" %in% names(trials)) trials$trial_index[idx] else NA_real_
  out <- data.frame(
    id = trials$.id[idx],
    task = trials$.task[idx],
    result = trials$.result[idx],
    trial = idx,
    trial_index = ti,
    item = item,
    value = value,
    value_num = suppressWarnings(as.numeric(value)),
    stringsAsFactors = FALSE
  )
  if ("rt" %in% names(trials)) {
    out$rt <- trials$rt[idx]
  }
  rownames(out) <- NULL
  out
}

.jatos_wide <- function(trials, long, response_col, extra_cols, prefix) {
  ids <- unique(trials$.id)
  wide <- data.frame(.id = ids, stringsAsFactors = FALSE)

  missing_cols <- setdiff(extra_cols, names(trials))
  if (length(missing_cols) > 0) {
    warning("extra_cols not found in the data: ",
            paste(missing_cols, collapse = ", "), call. = FALSE)
  }
  for (cl in intersect(extra_cols, names(trials))) {
    vals <- vapply(ids, function(i) {
      v <- trials[[cl]][trials$.id == i]
      v <- v[!is.na(v)]
      if (length(v) == 0) NA_character_ else as.character(v)[1]
    }, character(1))
    wide[[.jatos_unique_name(cl, names(wide))]] <- .jatos_retype(vals)
  }

  if (nrow(long) == 0) {
    return(wide)
  }

  cname <- .jatos_colnames(long, response_col = response_col, prefix = prefix)
  key <- paste(long$id, cname, sep = "\r")
  occ <- stats::ave(seq_along(key), key, FUN = seq_along)
  maxocc <- tapply(occ, cname, max)
  dup <- names(maxocc)[maxocc > 1]
  if (length(dup) > 0) {
    hit <- cname %in% dup
    cname[hit] <- paste0(cname[hit], "_", occ[hit])
  }

  cols <- .jatos_col_order(cname, long$task, long$item)
  for (cl in cols) {
    vals <- rep(NA_character_, length(ids))
    hit <- cname == cl
    pos <- match(long$id[hit], ids)
    vals[pos] <- long$value[hit]
    wide[[.jatos_unique_name(cl, names(wide))]] <- .jatos_retype(vals)
  }
  rownames(wide) <- NULL
  wide
}

# Order the item columns by task (order of appearance), then by item name in
# natural order (item_2 before item_10). Presentation order is often
# randomised, so it is not a useful column order.
.jatos_col_order <- function(cname, task, item) {
  keep <- !duplicated(cname)
  tab <- data.frame(col = cname[keep], task = task[keep], item = item[keep],
                    stringsAsFactors = FALSE)
  tab$task_rank <- match(tab$task, unique(task))
  ord <- order(tab$task_rank, .jatos_natural_key(tab$item),
               .jatos_natural_key(tab$col))
  tab$col[ord]
}

# Sort key that pads digit runs so that "q2" sorts before "q10".
.jatos_natural_key <- function(x) {
  vapply(x, function(s) {
    parts <- regmatches(s, gregexpr("[0-9]+|[^0-9]+", s))[[1]]
    num <- grepl("^[0-9]+$", parts)
    parts[num] <- formatC(as.numeric(parts[num]), width = 12, flag = "0",
                          format = "d")
    paste(parts, collapse = "")
  }, character(1), USE.NAMES = FALSE)
}

# Column names for the wide format, disambiguated by task when needed.
.jatos_colnames <- function(long, response_col, prefix) {
  item <- long$item
  if (prefix == "always") {
    return(paste(long$task, item, sep = "_"))
  }
  if (prefix == "never") {
    return(item)
  }
  tasks <- tapply(long$task, item, function(z) length(unique(z)))
  ambiguous <- names(tasks)[tasks > 1]
  ambiguous <- unique(c(ambiguous, response_col))
  hit <- item %in% ambiguous
  item[hit] <- paste(long$task[hit], item[hit], sep = "_")
  item
}

.jatos_unique_name <- function(nm, taken) {
  out <- nm
  k <- 1L
  while (out %in% taken) {
    k <- k + 1L
    out <- paste0(nm, ".", k)
  }
  out
}

# Character column -> numeric when every non-missing entry is a number.
.jatos_retype <- function(vals) {
  num <- suppressWarnings(as.numeric(vals))
  if (all(is.na(num) == is.na(vals))) {
    return(num)
  }
  vals
}
