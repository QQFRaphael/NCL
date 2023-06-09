load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"   
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRF_contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
load "$GEODIAG_ROOT/geodiag.ncl"

wrfres=addfile("/home/qianqf/wrfout_d01_2013-08-01_00:00:00","r")

res=True
;WRF_map_c(wrfres,res,0)
res@tfDoNDCOverlay=True
res@pmTickMarkDisplayMode="Always"
res@gsnMaximize=True          
res@gsnSpreadColors=True         
res@cnFillOn=True
res@cnLinesOn=False
res@cnLineLabelsOn=False
res@cnFillOn=True
res@cnLinesOn=False
res@cnLineLabelsOn=False

res@isShowProvince = True
res@isShowSouthChinaSea = True
res@isAddMask = False
res@isShowRivers = True
res@riverColor = "black"
res@riverThickness = 0.5
res@boundaryColor = "black"
res@boundaryThickness = 0.5

;res@gsnSpreadColorStart=130
;res@gsnSpreadColorEnd=255
res@cnLevelSelectionMode="ExplicitLevels"
res@cnLevels=ispan(-4,4,1)
;res@cnLevels=(/0,4,8,12,16,20,24,28,32,36,40/)

setup_china_map(res)

res@mpProjection = "LambertConformal"
res@mpLimitMode = "Corners"
res@mpLeftCornerLatF = 10.34379
res@mpLeftCornerLonF =    80.9162
res@mpRightCornerLatF =   52.64054
res@mpRightCornerLonF =   159.5966
res@mpCenterLonF =        107
res@mpCenterLatF =        38.00001
res@mpLambertParallel1F = 30
res@mpLambertParallel2F = 60
res@mpLambertMeridianF =  107
res@mpGridAndLimbOn     = True
res@mpGridSpacingF      = 10
res@mpGridLineDashPattern       = 2
res@mpDataBaseVersion   = "MediumRes"
res@mpDataSetName       = "Earth..4" 
;res@mpMaskAreaSpecifiers     = (/"China","Taiwan","Disputed area between India and China","India:Arunachal Pradesh"/)
;res@cnFillDrawOrder     = "PreDraw"
res@mpOutlineOn              = True
;====================================================================================================

ctldata=addfile("ctl_500hPa_G.nc","r")
ctl=ctldata->ctl_500hPa_G
sendata=addfile("solar_500hPa_G.nc","r")
sen=sendata->solar_500hPa_G

diff=sen-ctl

JJA=(dim_avg_n_Wrap(diff(604:971,:,:),0)+dim_avg_n_Wrap(diff(2064:2431,:,:),0)+dim_avg_n_Wrap(diff(3524:3891,:,:),0)+dim_avg_n_Wrap(diff(4984:5351,:,:),0))/4.0
DJF=(dim_avg_n_Wrap(diff(1336:1695,:,:),0)+dim_avg_n_Wrap(diff(2796:3155,:,:),0)+dim_avg_n_Wrap(diff(4256:4615,:,:),0))/3.0

JJA=JJA/9.8
DJF=DJF/9.8

wks=gsn_open_wks("eps" ,"500hPa_G_JJA")
gsn_define_colormap(wks,"BlueWhiteOrangeRed")
plt=gsn_csm_contour_map(wks,JJA,res)
attach_china_map(wks, plt)
draw(plt)
delete(wks)


wks=gsn_open_wks("eps" ,"500hPa_G_DJF")
gsn_define_colormap(wks,"BlueWhiteOrangeRed")
plt=gsn_csm_contour_map(wks,DJF,res)
attach_china_map(wks, plt)
draw(plt)
delete(wks)