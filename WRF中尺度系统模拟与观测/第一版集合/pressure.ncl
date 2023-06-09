;   Example script to produce plots for a WRF real-data run,
;   with the ARW coordinate dynamics option.
;   Interpolating to specified pressure levels
;   In this example we get all data first, the interpolate to a
;   series of pressure levels before plotting the data

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"

begin
;
; The WRF ARW input file.  
; This needs to have a ".nc" appended, so just do it.
a=addfile("/home2_hn/QQF/MCS/2014/SBU_YSU/wrfout/wrfout_d03_2014-05-23_03:10:00","r")


; We generate plots, but what kind do we prefer?
;  type = "x11"
; type = "pdf"
 type = "ps"
; type = "ncgm"
;type="eps"

wks = gsn_open_wks(type, "wrfout_d03_2014-05-23_03:10:00")

; Set some Basic Plot options
  res = True
  res@MainTitle                   = "REAL-TIME WRF"
  res@Footer = False

  pltres = True
  mpres = True
  mpres@mpGeophysicalLineColor      = "Black"
  mpres@mpNationalLineColor         = "Black"
  mpres@mpUSStateLineColor          = "Black"
  mpres@mpGridLineColor             = "Black"
  mpres@mpLimbLineColor             = "Black"
  mpres@mpPerimLineColor            = "Black"
  mpres@mpGeophysicalLineThicknessF = 2.0
  mpres@mpGridLineThicknessF        = 2.0
  mpres@mpLimbLineThicknessF        = 2.0
  mpres@mpNationalLineThicknessF    = 2.0
  mpres@mpUSStateLineThicknessF     = 2.0
  mpres@mpDataBaseVersion           = "HighRes"

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; What times and how many time steps are in the data set?
  times = wrf_user_getvar(a,"times",-1)  ; get all times in the file
  ntimes = dimsizes(times)         ; number of times in the file

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; First get the variables we will need        

    tc = wrf_user_getvar(a,"tc",-1)        ; T in C
    u  = wrf_user_getvar(a,"ua",-1)        ; u averaged to mass points
    v  = wrf_user_getvar(a,"va",-1)        ; v averaged to mass points
    p  = wrf_user_getvar(a, "pressure",-1) ; pressure is our vertical coordinate
    z  = wrf_user_getvar(a, "z",-1)        ; grid point height
    rh = wrf_user_getvar(a,"rh",-1)        ; relative humidity

; The specific pressure levels that we want the data interpolated to.
; Interpolate to these levels
  pressure_levels = (/925, 850., 700., 500., 200./)   ; pressure levels to plot
  nlevels         = dimsizes(pressure_levels)     ; number of pressure levels

  tc_plane = wrf_user_intrp3d(tc,p,"h",pressure_levels,0.,False)
  z_plane  = wrf_user_intrp3d( z,p,"h",pressure_levels,0.,False)
  rh_plane = wrf_user_intrp3d(rh,p,"h",pressure_levels,0.,False)
  u_plane  = wrf_user_intrp3d( u,p,"h",pressure_levels,0.,False)
  v_plane  = wrf_user_intrp3d( v,p,"h",pressure_levels,0.,False)

  spd     = (u_plane*u_plane + v_plane*v_plane)^(0.5) ; m/sec
    spd@description = "Wind Speed"
    spd@units = "m/s"
  u_plane = u_plane*1.94386     ; kts
  v_plane = v_plane*1.94386     ; kts
    u_plane@units = "kts"
    v_plane@units = "kts"


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  do it = 0,ntimes-1,2             ; TIME LOOP

    print("Working on time: " + times(it) )
    res@TimeLabel = times(it)   ; Set Valid time to use on plots


    do level = 0,nlevels-1                 ; LOOP OVER LEVELS

      pressure = pressure_levels(level)

      ; Add some level info to the plot
        res@PlotLevelID = pressure + " hPa"
          


      ; Plotting options for T                
        opts = res                          
        opts@cnLineColor = "Red"
        opts@ContourParameters = (/ 5.0 /)
        opts@cnInfoLabelOrthogonalPosF = 0.07  ; offset second label information
        opts@gsnContourLineThicknessesScale = 2.0
        contour_tc = wrf_contour(a,wks,tc_plane(it,level,:,:),opts)
        delete(opts)


      ; Plotting options for RH                
        opts = res                          
        opts@cnFillOn = True  
        opts@pmLabelBarOrthogonalPosF = -0.1
        opts@ContourParameters = (/ 10., 90., 10./)
        opts@cnFillColors = (/"White","White","White", \
                              "White","Chartreuse","Green",\
                              "Green3","Green4", \
                              "ForestGreen","PaleGreen4"/)
        contour_rh = wrf_contour(a,wks,rh_plane(it,level,:,:),opts)
        delete(opts)


      ; Plotting options for Wind Speed                
        opts = res                          
        opts@cnLineColor = "MediumSeaGreen"
        opts@ContourParameters = (/ 10. /)
        opts@cnInfoLabelOrthogonalPosF = 0.07  ; offset second label information
        opts@gsnContourLineThicknessesScale = 3.0
        contour_spd = wrf_contour(a,wks,spd(it,level,:,:),opts)
        delete(opts)


      ; Plotting options for Wind Vectors                 
        opts = res          
        opts@FieldTitle = "Wind"   ; overwrite Field Title
        opts@NumVectors = 47       ; wind barb density
        vector = wrf_vector(a,wks,u_plane(it,level,:,:),v_plane(it,level,:,:),opts)
        delete(opts)


      ; Plotting options for Geopotential Height
        opts_z = res                          
        opts_z@cnLineColor = "Blue"
        opts_z@gsnContourLineThicknessesScale = 3.0


      ; MAKE PLOTS                                       

        if ( pressure .eq. 850 ) then   ; plot temp, rh, height, wind barbs
          opts_z@ContourParameters = (/ 20.0 /)
          contour_height = wrf_contour(a,wks,z_plane(it,level,:,:),opts_z)
          plot = wrf_map_overlays(a,wks,(/contour_rh,contour_tc,contour_height, \
                                    vector/),pltres,mpres)
        end if

        if ( pressure .eq. 700 ) then   ; plot temp, height, wind barbs
          opts_z@ContourParameters = (/ 30.0 /)
          contour_height = wrf_contour(a,wks, z_plane(it,level,:,:),opts_z)
          plot = wrf_map_overlays(a,wks,(/contour_tc,contour_height, \
                                    vector/),pltres,mpres)
        end if

        if ( pressure .eq. 500 ) then   ; plot temp, height, wind barbs
          opts_z@ContourParameters = (/ 60.0 /)
          contour_height = wrf_contour(a,wks, z_plane(it,level,:,:),opts_z)
          plot = wrf_map_overlays(a,wks,(/contour_tc,contour_height, \
                                    vector/),pltres,mpres)
        end if

        if ( pressure .eq. 200 ) then   ; plot windspeed, height, wind barbs
          opts_z@ContourParameters = (/ 60.0 /)
          contour_height = wrf_contour(a,wks, z_plane(it,level,:,:),opts_z)
          plot = wrf_map_overlays(a,wks,(/contour_spd,contour_height, \
                                    vector/),pltres,mpres)
        end if

	if ( pressure .eq. 925 ) then   ; plot windspeed, height, wind barbs
          opts_z@ContourParameters = (/ 60.0 /)
          contour_height = wrf_contour(a,wks, z_plane(it,level,:,:),opts_z)
          plot = wrf_map_overlays(a,wks,(/contour_spd,contour_height, \
                                    vector/),pltres,mpres)
        end if
        delete(opts_z)

    end do      ; END OF LEVEL LOOP

  end do        ; END OF TIME LOOP

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

end
