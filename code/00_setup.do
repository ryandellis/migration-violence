* ==============================================================================
* 00_setup.do — Install all required user-written Stata packages
*
* Run this ONCE on a new machine before running the pipeline.
* Packages install to the project-local library (code/libraries/stata/).
* ==============================================================================

do "_config.do"

local packages estout reghdfe ftools geodist gtools combomarginsplot blindschemes coefplot

foreach pkg of local packages {
    capture which `pkg'
    if _rc {
        di "Installing `pkg'..."
        ssc install `pkg', replace
    }
    else {
        di "`pkg' already installed."
    }
}

* reghdfe requires ftools to be loaded
cap reghdfe, compile
ftools, compile

di _n "Setup complete. All packages installed to: ${root}/code/libraries/stata/"
