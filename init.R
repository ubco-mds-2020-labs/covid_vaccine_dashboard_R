# Install from CRAN
helpers.installPackages(c('dash', 'remotes', 'reticulate', 'dplyr', 'altair'))

remotes::install_github('plotly/dashR', upgrade=TRUE)
remotes::install_github('facultyai/dash-bootstrap-components@r-release')
