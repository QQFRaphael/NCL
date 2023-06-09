load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
load "$GEODIAG_ROOT/geodiag.ncl"

  wks = gsn_open_wks("eps", "slp")  ; Open graphics file
  gsn_define_colormap(wks,"cmp_b2r")

  ;d1 = addfile("./case10/wrfpress_d01_1998-06-16_00:00:00", "r")
  ;d2 = addfile("./case10/wrfpress_d02_1998-06-16_00:00:00", "r")

  wrff1=addfile("./case10/wrfout_d01_1998-06-16_00:00:00","r")
  wrff2=addfile("./case10/wrfout_d02_1998-06-16_00:00:00","r")

  tmp1 = wrf_user_getvar(wrff1,"slp",-1)
  var1=dim_avg_n_Wrap(tmp1,0)
  lat1 = wrf_user_getvar(wrff1,"XLAT",0)
  lon1 = wrf_user_getvar(wrff1,"XLONG",0)
  
  tmp2 = wrf_user_getvar(wrff2,"slp",-1)
  var2=dim_avg_n_Wrap(tmp2,0)
  lat2 = wrf_user_getvar(wrff2,"XLAT",0)
  lon2 = wrf_user_getvar(wrff2,"XLONG",0)

  var1@lat2d = lat1
  var1@lon2d = lon1
  var2@lat2d = lat2
  var2@lon2d = lon2

  
  
  
  
  
  ;d3 = addfile("./case11/wrfpress_d01_1998-06-16_00:00:00", "r")
  ;d4 = addfile("./case11/wrfpress_d02_1998-06-16_00:00:00", "r")

  wrff3=addfile("./case11/wrfout_d01_1998-06-16_00:00:00","r")
  wrff4=addfile("./case11/wrfout_d02_1998-06-16_00:00:00","r")

  tmp3 = wrf_user_getvar(wrff3,"slp",-1)
  var3=dim_avg_n_Wrap(tmp3,0)
  lat3 = wrf_user_getvar(wrff3,"XLAT",0)
  lon3 = wrf_user_getvar(wrff3,"XLONG",0)
  
  tmp4 = wrf_user_getvar(wrff4,"slp",-1)
  var4=dim_avg_n_Wrap(tmp4,0)
  lat4 = wrf_user_getvar(wrff4,"XLAT",0)
  lon4 = wrf_user_getvar(wrff4,"XLONG",0)

  var3@lat2d = lat3
  var3@lon2d = lon3
  var4@lat2d = lat4
  var4@lon2d = lon4
  
  var5=var3-var1
  var6=var4-var2
  var5@lat2d = lat3
  var5@lon2d = lon3
  var6@lat2d = lat4
  var6@lon2d = lon4
  
  
  
  
  
  
  dom_dims = dimsizes(var1)
  dom_rank = dimsizes(dom_dims)
  nx1 = dom_dims(dom_rank - 1) - 1
  ny1 = dom_dims(dom_rank - 2) - 1
  dom_dims = dimsizes(var2)
  dom_rank = dimsizes(dom_dims)
  nx2 = dom_dims(dom_rank - 1) - 1
  ny2 = dom_dims(dom_rank - 2) - 1


res                 = True
res@cnFillOn        = True
res@cnLinesOn       = False
res@cnLineLabelsOn  = False
res@cnInfoLabelOn   = False
res@gsnSpreadColors = True
res@cnLevelSelectionMode = "ExplicitLevels"
res@cnLevels=(/-2.4,-2.0,-1.6,-1.2,-0.8,-0.4,0,0.4,0.8,1.2,1.6,2.0,2.4/)
res@gsnLeftString = ""
res@gsnRightString = ""
res@gsnDraw         = False
res@gsnFrame        = False

res2 = res

res@isShowProvince = True
res@isShowSouthChinaSea = False
res@isAddMask = False
res@isShowRivers = True
res@riverColor = "black"
res@riverThickness = 0.5
res@boundaryColor = "black"
res@boundaryThickness = 0.5
setup_china_map(res)

res@mpProjection = "LambertConformal"
res@mpLambertParallel1F = 30
res@mpLambertParallel2F = 60
res@mpLambertMeridianF =  107
res@mpDataBaseVersion     = "MediumRes"          ; Default is LowRes
res@mpOutlineOn              = True
res@mpOutlineDrawOrder    = "PostDraw"           ; Draw map outlines last
res@mpGridAndLimbOn       = True                ; Turn off lat/lon lines
res@mpGridLineDashPattern       = 2
res@pmTickMarkDisplayMode = "Always"             ; Turn on map tickmarks
res = set_mp_wrf_map_resources(wrff1,res)
res@mpLimitMode        = "Corners"               ; Portion of map to zoom
res@mpLeftCornerLatF   = lat1(0,0)
res@mpLeftCornerLonF   = lon1(0,0)
res@mpRightCornerLatF  = lat1(ny1,nx1)
res@mpRightCornerLonF  = lon1(ny1,nx1)
res@lbLabelAutoStride = True
res@gsnMaximize     = True    ; Maximize plot in frame

res2@lbLabelBarOn = False  ; Labelbar already created in 1st plot
res2@gsnMaximize  = False  ; Use maximization from original plot


xbox_out = new(5,float)
ybox_out = new(5,float)
lnres = True
lnres@gsLineThicknessF  = 1.5


map = gsn_csm_contour_map(wks, var5(:,:), res)
plot = gsn_csm_contour(wks, var6(:,:), res2)
attach_china_map(wks, map)

draw(map) 
gsn_polyline(wks,map,lon2(0,:),lat2(0,:),True)
gsn_polyline(wks,map,lon2(:,0),lat2(:,0),True)
gsn_polyline(wks,map,lon2(ny2,:),lat2(ny2,:),True)
gsn_polyline(wks,map,lon2(:,nx2),lat2(:,nx2),True)

frame(wks)


