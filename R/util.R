
#' Generate palette suitable for coloring a set
#'
#' Takes a simple palette and expands / oscillates
#' it for use with Mandelbrot sets.
#'
#' @param palette vector of colour hex strings (e.g. '#FFFFFF')
#' @param folds number of times to wrap or 'fold' the palette
#' @param in_set colour for areas in the Mandelbrot set
#'
#' @examples
#' view <- mandelbrot(xlim = c(-0.8438146, -0.8226294),
#'   ylim = c(0.1963144, 0.2174996), iter = 500)
#'
#' blues <- RColorBrewer::brewer.pal(9, "Blues")
#' cols <- mandelbrot_palette(blues, in_set = "white")
#' image(log(view$z), col = cols, axes = FALSE)
#'
#' spectral <- RColorBrewer::brewer.pal(11, "Spectral")
#' cols <- mandelbrot_palette(spectral)
#' image(-1/view$z, col = cols, axes = FALSE)
#'
#' @export
mandelbrot_palette <- function(palette, folds = 2, in_set = "black") {
  if (length(palette) < 50) {
    palette <- grDevices::colorRampPalette(palette)(50)
  }
  c(rep(c(palette, rev(palette)), folds), in_set)
}

#' Plot a Mandelbrot set using base graphics
#'
#' Draws coloured set membership using \code{image}.
#'
#' @param x an object generated by \code{\link[mandelbrot]{mandelbrot}}
#' @param col a vector of colours, such as those generated by
#'   \code{\link[mandelbrot]{mandelbrot_palette}}
#' @param transform the name of a transformation to apply to the number
#'   of iterations matrix
#' @param ... extra arguments passed to \code{\link[graphics]{image}}
#'
#' @importFrom grDevices grey.colors
#'
#' @export
plot.mandelbrot <- function(x,
  col = mandelbrot_palette(c("white", grey.colors(50))),
  transform = c("none", "inverse", "log"), ...) {

  transform <- match.arg(transform)
  old_par <- par()

  par(mar = rep(1, 4))

  if (transform != "none") {
    if (transform == "inverse") {
      x$z <- 1/x$z
    } else {
      if (transform == "log") {
        x$z <- log(x$z)
      } else {
        stop("transform not recognised: ", transform)
      }
    }
  }

  graphics::image(x, col = col, axes = FALSE, ...)

  par <- old_par
}

#' @export
print.mandelbrot <- function(x, ...) {
  cat(" Mandelbrot set view object within limits x:",
    paste(range(x$x), collapse = ", "),
    "and y:",
    paste(range(x$y), collapse = ", "),
    "\n")
  cat(" Iterations matrix:",
    paste(dim(x$z), collapse = " x "))

   invisible(x)
}

#' Convert Mandelbrot object to data.frame for plotting
#'
#' Converts objects produced by \code{\link[mandelbrot]{mandelbrot}}
#' to tidy data.frames for use with ggplot and other tidyverse packages.
#'
#' @param x a Mandelbrot set object produced by \code{\link[mandelbrot]{mandelbrot}}
#' @param ... ignored
#'
#' @return a 3-column \code{data.frame}
#'
#' @examples
#'
#' mb <- mandelbrot()
#' df <- as.data.frame(mb)
#' head(df)
#'
#' @export
as.data.frame.mandelbrot <- function(x, ...) {
  df <- reshape2::melt(x$z)
  #df <- data.table::melt(mandelbrot$z)
  df$x <- x$x[df$Var1]
  df$y <- x$y[df$Var2]
  df[,c("x", "y", "value")]
}

