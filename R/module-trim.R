
#' ACE/SEA module trimming
#'
#' Methods for trimming trials out of user data.
#'
#' @keywords internal
#' @name ace_trims
NULL

#' Trim trials from ACE/SEA data by reaction time
#'
#' Applies corresponding \code{\link{ace_trims}} to every session of data.
#'
#' @section Assumptions:
#' Assumes the \code{\link{data.frame}} is nested, with two columns:
#' \code{module} (character) and \code{data} (list, each containing a \code{\link{data.frame}}).
#'
#' @export
#' @import dplyr
#' @importFrom purrr map
#' @importFrom rlang !!
#' @importFrom tidyr nest
#' @param df a \code{\link{data.frame}} containing formatted trialwise ACE data. 
#'
#' This includes data loaded with the following methods: 
#' \enumerate{
#'   \item \code{\link{load_ace_file}}
#'   \item \code{\link{load_ace_bulk}}
#' }
#' 
#' @param range_cutoff numeric vector, length 2. Remove within-subject RTs outside of
#' this specified range? Enter min and max accepted RTs as a vector length 2. If min or max
#' not specified, enter that value as NA in the vector. Defaults to \code{FALSE}.
#' @param sd_cutoff numeric. Remove within-subject RTs further than this many SD from
#' within-subject mean RT? Enter as one number. If both range and SD are specified,
#' will apply range cutoff \emph{first,} and then will apply SD cutoff \emph{afterward}.
#' Defaults to \code{FALSE}.
#' @param verbose logical. Print details? Defaults to \code{TRUE}.
#' @return Returns the input data, with RTs corresponding to offending trials rendered as NA.

trim_rt_trials <- function(df, sd_cutoff = FALSE,
                           range_cutoff = FALSE, verbose = TRUE) {
  
  # Quasiquoting does not seem to behave as planned inside of map()
  for (i in 1:nrow(df)) {
    
    if (!(df$module[i] %in% c(DEMOS, ISHIHARA))) {
      
      df$data[[i]] <- df$data[[i]] %>%
        group_by(!!Q_COL_BID) %>%
        mutate(!!COL_RT := as.numeric(!!Q_COL_RT))
      
      # ordered so that removing acc first doesn't alter RT for the RT calculation
      if (range_cutoff != FALSE) {
        if (!is.na(range_cutoff[1])) {
          df$data[[i]] <- df$data[[i]] %>%
            mutate(!!COL_CORRECT_BUTTON := na_if_true(!!Q_COL_CORRECT_BUTTON, !!Q_COL_RT < range_cutoff[1]),
                   !!COL_RT := na_if_true(!!Q_COL_RT, !!Q_COL_RT < range_cutoff[1]))
        }
        if (!is.na(range_cutoff[2])) {
          df$data[[i]] <- df$data[[i]] %>%
            mutate(!!COL_CORRECT_BUTTON := na_if_true(!!Q_COL_CORRECT_BUTTON, !!Q_COL_RT > range_cutoff[2]),
                   !!COL_RT := na_if_true(!!Q_COL_RT, !!Q_COL_RT > range_cutoff[2]))
        }
      }
      
      if (sd_cutoff != FALSE) {
        df$data[[i]] <- df$data[[i]] %>%
          mutate(!!COL_CORRECT_BUTTON := na_if_true(!!Q_COL_CORRECT_BUTTON, c(abs(scale(!!Q_COL_RT))) > sd_cutoff),
                 !!COL_RT := na_if_true(!!Q_COL_RT, c(abs(scale(!!Q_COL_RT))) > sd_cutoff))
      }
      
      # needs to be grouped to prevent previous_correct_button from bleeding over between records
      df$data[[i]] <- df$data[[i]] %>%
        mutate(!!Q_COL_PREV_CORRECT_BUTTON := make_lagged_col(!!Q_COL_CORRECT_BUTTON)) %>%
        ungroup()
    }
  }
  return (df)
}
