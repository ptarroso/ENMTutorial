# Some cleaning
cleanpaths <- function(paths) {
    for (path in paths) {
        if (file.exists(path)) {
            if (dir.exists(path)) {
                unlink(path, recursive=TRUE)
            } else {
                file.remove(path)
            }
        }
    }
}

paths <- c("_book", 
           "_bookdown_files", 
           "ENM_tutorial_files", 
           "_main.Rmd", 
           "_main.html",
           "ENM_tutorial.Rmd", 
           "models/Vaspis", 
           "models/Vlatastei", 
           "models/Vseoanei", 
           "docs", 
           list.files("data/rasters", "*tif", full.names=TRUE))
cleanpaths(paths)
dir.create("docs")
file.create("docs/.nojekyll")
bookdown::render_book("index.Rmd", "bookdown::gitbook")
bookdown::render_book("index.Rmd", "bookdown::pdf_book")
cleanpaths("ENM_tutorial_files")
